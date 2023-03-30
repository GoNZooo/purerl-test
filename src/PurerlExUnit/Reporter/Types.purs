module PurerlExUnit.Reporter.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  ) where

import Prelude

import Pinto.GenServer (ServerPid, ServerType)

data Message = Unit

type State = {}

type Arguments = {}

type ServerType' = ServerType Unit Unit Message State
type Pid = ServerPid Unit Unit Message State
