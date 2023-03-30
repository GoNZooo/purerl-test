module PurerlExUnit.Test
  ( startLink
  ) where

import Prelude

import Control.Monad.Reader as Reader
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (wrap)
import Data.TraversableWithIndex (traverseWithIndex)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Foreign (Foreign)
import Foreign as Foreign
import Pinto (RegistryName(..), StartLinkResult)
import Pinto.GenServer (InfoFn, InitFn, InitResult(..), ServerSpec)
import Pinto.GenServer as GenServer
import Pinto.Timer as Timer
import PurerlExUnit.Suite.Bus as SuiteBus
import PurerlExUnit.Test.Types (Arguments, Message(..), Pid, ServerType', State)
import PurerlExUnit.Types
  ( Assertion
  , AssertionResult(..)
  , Assertions
  , SuiteName
  , TestName
  , TestResult(..)
  )

serverName :: SuiteName -> TestName -> RegistryName ServerType'
serverName suiteName testName =
  { server: "PurerlExUnit.Test", suite: suiteName, test: testName } # Foreign.unsafeToForeign # Global

startLink :: Arguments -> Effect (StartLinkResult Pid)
startLink arguments = do
  arguments # spec # GenServer.startLink

spec :: Arguments -> ServerSpec Unit Unit Message State
spec arguments = do
  let name = serverName arguments.suiteName arguments.test.name
  (arguments # init # GenServer.defaultSpec) { name = Just name, handleInfo = Just handleInfo }

init :: Arguments -> InitFn Unit Unit Message State
init { suiteName, test } = do
  _timerRef <- Timer.sendAfter (wrap 0.0) Initialize
  { suiteName, test } # InitOk # pure

handleInfo :: InfoFn Unit Unit Message State
handleInfo Initialize state = do
  state.test.assertions # runAssertions state.suiteName state.test.name # liftEffect
  state # GenServer.return # pure

runAssertions :: SuiteName -> TestName -> Assertions -> Effect Unit
runAssertions suiteName testName assertions = do
  assertionsRef <- [] # Ref.new # liftEffect
  Reader.runReaderT assertions assertionsRef
  assertions' <- assertionsRef # Ref.read # liftEffect
  assertionResults <- traverseWithIndex (\i a -> executeAssertion a i testName) assertions'
  let assertionFailures = assertionFailureData assertionResults
  if Array.null assertionFailures then
    { test: testName } # TestDone # SuiteBus.send suiteName
  else
    { test: testName, failures: assertionFailures } # TestFailed # SuiteBus.send suiteName

assertionFailureData :: Array AssertionResult -> Array { index :: Int, message :: String }
assertionFailureData results = do
  let
    stripFailureData (AssertionFailed r) = Just r
    stripFailureData AssertionPassed = Nothing
  results # map stripFailureData # Array.catMaybes

executeAssertion :: Assertion Foreign -> Int -> TestName -> Effect AssertionResult
executeAssertion assertion index testName = executeAssertion_ assertion index testName

foreign import executeAssertion_ :: Assertion Foreign -> Int -> TestName -> Effect AssertionResult
