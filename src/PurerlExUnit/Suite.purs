module PurerlExUnit.Suite
  ( startLink
  ) where

import Prelude

import Control.Monad.Reader as Reader
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap, wrap)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class (class MonadEffect, liftEffect)
import Effect.Class.Console as Console
import Effect.Ref as Ref
import Erl.Atom as Atom
import Erl.Data.Tuple (tuple2)
import Erl.Process (class HasSelf)
import Erl.Process as Process
import Foreign as Foreign
import Pinto (RegistryName(..), StartLinkResult)
import Pinto.GenServer (Action(..), InfoFn, InitFn, InitResult(..), ServerSpec)
import Pinto.GenServer as GenServer
import Pinto.Timer as Timer
import PurerlExUnit.Suite.Bus as SuiteBus
import PurerlExUnit.Suite.Types (Arguments, Message(..), Pid, ServerType', State)
import PurerlExUnit.Test.Supervisor as TestSupervisor
import PurerlExUnit.Types (AssertionFailure, SuiteName, Test, TestName, TestResult(..), Tests)

serverName :: SuiteName -> RegistryName ServerType'
serverName name =
  name # tuple2 (Atom.atom "PurerlExUnit.Suite") # Foreign.unsafeToForeign # Global

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
  { suite, testCount: 0, successes: 0, failures: [] } # InitOk # pure

handleInfo :: InfoFn Unit Unit Message State
handleInfo Initialize state = do
  testCount <- state.suite.tests # (runTests state.suite.name) # liftEffect
  state { testCount = testCount } # GenServer.return # pure
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
  [ "🧪 ", unwrap suite.name ] # Array.fold # Console.log
  [ show successes, "/", show testCount, " successes" ] # Array.fold # Console.log
  failures # traverse_ printFailedTest # liftEffect
  state # GenServer.returnWithAction StopNormal # pure

printFailedTest :: { test :: TestName, assertions :: Array AssertionFailure } -> Effect Unit
printFailedTest { test, assertions } = do
  [ "❌ ", unwrap test ] # Array.fold # Console.log
  traverse_ printAssertionFailure assertions

printAssertionFailure :: AssertionFailure -> Effect Unit
printAssertionFailure { message } = do
  [ "  ", message ] # Array.fold # Console.log

maybePrintReport :: forall m. HasSelf m Message => MonadEffect m => State -> m Unit
maybePrintReport { successes, failures, testCount } = do
  if successes + Array.length failures == testCount then do
    selfPid <- Process.self
    PrintFinalReport # Process.send selfPid # liftEffect
  else
    pure unit

runTests :: SuiteName -> Tests -> Effect Int
runTests suiteName tests = do
  testsRef <- [] # Ref.new # liftEffect
  Reader.runReaderT tests testsRef
  tests' <- testsRef # Ref.read # liftEffect
  traverse_ (runTest suiteName) tests'
  tests' # Array.length # pure

runTest :: SuiteName -> Test -> Effect Unit
runTest suiteName test = { suiteName, test } # TestSupervisor.startChild # void