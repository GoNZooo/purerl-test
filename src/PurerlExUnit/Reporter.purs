module PurerlExUnit.Reporter
  ( startLink
  , report
  ) where

import Prelude

import Data.Array as Array
import Data.Maybe (Maybe(..))
import Data.Newtype (unwrap)
import Data.Traversable (traverse_)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Erl.Atom as Atom
import Pinto (RegistryName(..), RegistryReference(..), StartLinkResult)
import Pinto.GenServer (CastFn, InfoFn, InitFn, InitResult(..), ServerSpec)
import Pinto.GenServer as GenServer
import PurerlExUnit.Reporter.Types (Message, Pid, ServerType', State)
import PurerlExUnit.Types (AssertionFailure, SuiteName, TestName)

serverName :: RegistryName ServerType'
serverName = "PurerlExUnit.Reporter" # Atom.atom # Local

startLink :: Effect (StartLinkResult Pid)
startLink = do
  GenServer.startLink spec

spec :: ServerSpec Unit Unit Message State
spec =
  (GenServer.defaultSpec init) { name = Just serverName, handleInfo = Just handleInfo }

init :: InitFn Unit Unit Message State
init = {} # InitOk # pure

report
  :: { suiteName :: SuiteName
     , testCount :: Int
     , successes :: Int
     , failures :: Array { test :: TestName, assertions :: Array AssertionFailure }
     }
  -> Effect Unit
report r = do
  GenServer.cast (ByName serverName) (handleReport r)

handleReport
  :: { suiteName :: SuiteName
     , testCount :: Int
     , successes :: Int
     , failures :: Array { test :: TestName, assertions :: Array AssertionFailure }
     }
  -> CastFn Unit Unit Message State
handleReport { suiteName, testCount, successes, failures } state = do
  [ "🧪 ", unwrap suiteName ] # Array.fold # Console.log
  [ "  ", show successes, "/", show testCount, " successes" ] # Array.fold # Console.log
  failures # traverse_ printFailedTest # liftEffect
  state # GenServer.return # pure

handleInfo :: InfoFn Unit Unit Message State
handleInfo _unit state = state # GenServer.return # pure

printFailedTest :: { test :: TestName, assertions :: Array AssertionFailure } -> Effect Unit
printFailedTest { test, assertions } = do
  [ "  ❌ ", unwrap test ] # Array.fold # Console.log
  traverse_ printAssertionFailure assertions

printAssertionFailure :: AssertionFailure -> Effect Unit
printAssertionFailure { message } = do
  [ "    ", message ] # Array.fold # Console.log
