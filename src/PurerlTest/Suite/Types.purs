module PurerlTest.Suite.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  , MonitorInfo
  ) where

import Prelude

import Erl.Data.Map (Map)
import Erl.Process.Raw as Process
import Pinto.GenServer (ServerPid, ServerType)
import Pinto.MessageRouting (RouterRef)
import Pinto.Monitor (MonitorMsg, MonitorRef)
import PurerlTest.Test.Types as TestTypes
import PurerlTest.Types (AssertionFailure, Suite, SuiteName, TestName, TestResult)

type MonitorInfo = { suiteName :: SuiteName, test :: TestName, ref :: TestTypes.Pid }

data Message
  = Initialize
  | IncomingTestResult TestResult
  | PrintFinalReport
  | TestDown MonitorMsg

type State =
  { suite :: Suite
  , testCount :: Int
  , successes :: Int
  , monitorInfos :: Map TestTypes.Pid MonitorInfo
  , failures :: Array { test :: TestName, assertions :: Array AssertionFailure }
  }

type Arguments = { suite :: Suite }

type ServerType' = ServerType Unit Unit Message State

type Pid = ServerPid Unit Unit Message State
