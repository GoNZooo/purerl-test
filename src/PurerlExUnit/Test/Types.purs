module PurerlExUnit.Test.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  ) where

import Prelude

import Pinto.GenServer (ServerPid, ServerType)
import PurerlExUnit.Types (SuiteName, Test)

data Message = Initialize

type State = { suiteName :: SuiteName, test :: Test }

type Arguments = { suiteName :: SuiteName, test :: Test }

type ServerType' = ServerType Unit Unit Message State

type Pid = ServerPid Unit Unit Message State
