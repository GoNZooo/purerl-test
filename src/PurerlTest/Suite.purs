module PurerlTest.Suite
  ( startLink
  ) where

import Prelude

import Control.Monad.Reader as Reader
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Maybe as Maybe
import Data.Newtype (wrap)
import Data.Traversable (traverse)
import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Ref as Ref
import Erl.Atom as Atom
import Erl.Data.Map as Map
import Erl.Data.Tuple (tuple2)
import Erl.Process (class HasSelf, Process)
import Erl.Process as Process
import Foreign as Foreign
import Pinto (RegistryName(..), StartLinkResult)
import Pinto.GenServer (Action(..), InfoFn, InitFn, InitResult(..), ServerSpec)
import Pinto.GenServer as GenServer
import Pinto.Monitor as Monitor
import Pinto.Monitor as Pinto
import Pinto.Timer as Timer
import PurerlTest.Reporter as Reporter
import PurerlTest.Suite.Bus as SuiteBus
import PurerlTest.Suite.Types (Arguments, Message(..), Pid, ServerType', State, MonitorInfo)
import PurerlTest.Test.Supervisor as TestSupervisor
import PurerlTest.Types (SuiteName, Test, TestName(..), TestResult(..), Tests)

serverName :: SuiteName -> RegistryName ServerType'
serverName name =
  name # tuple2 (Atom.atom "PurerlTest.Suite") # Foreign.unsafeToForeign # Global

startLink :: Arguments -> Effect (StartLinkResult Pid)
startLink arguments = do
  arguments # spec # GenServer.startLink

spec :: Arguments -> ServerSpec Unit Unit Message State
spec arguments = do
  let name = serverName arguments.suite.name
  (arguments # init # GenServer.defaultSpec) { name = Just name, handleInfo = Just handleInfo }

init :: Arguments -> InitFn Unit Unit Message State
init { suite } = do
  _subscriptionRef <- SuiteBus.subscribe suite.name IncomingTestResult
  _timerRef <- Timer.sendAfter (wrap 0.0) Initialize
  { suite, testCount: 0, successes: 0, failures: [], monitorInfos: Map.empty } # InitOk # pure

handleInfo :: InfoFn Unit Unit Message State
handleInfo Initialize state = do
  self <- Process.self
  testMonitorInfos <- liftEffect $ runTests self state.suite.name state.suite.tests
  let
    testMonitorRefMap =
      testMonitorInfos
        # map (\info -> info.ref /\ info)
        # Map.fromFoldable
  state { testCount = Array.length testMonitorInfos, monitorInfos = testMonitorRefMap }
    # GenServer.return
    # pure
handleInfo (IncomingTestResult (TestDone {})) state = do
  let
    newSuccesses = state.successes + 1
    newState = state { successes = newSuccesses }
  maybePrintReport newState
  newState # GenServer.return # pure
handleInfo (IncomingTestResult (TestFailed { test, failures })) state = do
  let
    newFailures = Array.snoc state.failures { test, assertions: failures }
    newState = state { failures = newFailures }
  maybePrintReport newState
  newState # GenServer.return # pure
handleInfo PrintFinalReport state@{ suite, testCount, successes, failures } = do
  { suiteName: suite.name, testCount, successes, failures } # Reporter.report # liftEffect
  state # GenServer.returnWithAction StopNormal # pure
handleInfo (TestDown (Monitor.Down _ref _type' object _info)) state = do
  let
    maybeTestMonitorInfo = state.monitorInfos # Map.lookup (Foreign.unsafeFromForeign object)
    newFailures =
      maybeTestMonitorInfo
        # map (\testMonitorInfo -> { test: testMonitorInfo.test, assertions: [] })
        # Maybe.fromMaybe { test: TestName "Unknown failure", assertions: [] }
        # Array.singleton
    newState = state { failures = newFailures }
  maybePrintReport newState
  newState # GenServer.return # pure

maybePrintReport :: forall m. HasSelf m Message => MonadEffect m => State -> m Unit
maybePrintReport { successes, failures, testCount } = do
  if successes + Array.length failures == testCount then do
    selfPid <- Process.self
    PrintFinalReport # Process.send selfPid # liftEffect
  else
    pure unit

runTests
  :: Process Message
  -> SuiteName
  -> Tests
  -> Effect (Array MonitorInfo)
runTests self suiteName tests = do
  testsRef <- Ref.new []
  Reader.runReaderT tests testsRef
  tests' <- Ref.read testsRef
  traverse (runTest self suiteName) tests'

runTest
  :: Process Message
  -> SuiteName
  -> Test
  -> Effect MonitorInfo
runTest self suiteName test = do
  pid <- liftEffect $ TestSupervisor.startChild { suiteName, test }
  void $ Pinto.monitorTo pid self TestDown
  pure { suiteName, test: test.name, ref: pid }

