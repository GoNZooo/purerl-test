module PurerlExUnit.Reporter.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  ) where

import Prelude

import Pinto.GenServer (ServerPid, ServerType)
import PurerlExUnit.Reporter.Bus as ReporterBus
import PurerlExUnit.Types (SuiteName)

type Message = ReporterBus.Message

type State = { suitesInFlight :: Array SuiteName, failures :: Int }

type Arguments = {}

type ServerType' = ServerType Unit Unit Message State
type Pid = ServerPid Unit Unit Message State
