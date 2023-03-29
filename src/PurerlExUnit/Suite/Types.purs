module PurerlExUnit.Suite.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  ) where

import Prelude

import Pinto.GenServer (ServerPid, ServerType)
import PurerlExUnit.Types (AssertionFailure, Suite, TestName, TestResult)

data Message
  = Initialize
  | IncomingTestResult TestResult
  | PrintFinalReport

type State =
  { suite :: Suite
  , testCount :: Int
  , successes :: Int
  , failures :: Array { test :: TestName, assertions :: Array AssertionFailure }
  }

type Arguments = { suite :: Suite }

type ServerType' = ServerType Unit Unit Message State

type Pid = ServerPid Unit Unit Message State
