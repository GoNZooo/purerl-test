module PurerlTest.Reporter.Types
  ( Message(..)
  , ServerType'
  , Pid
  , State
  , Arguments
  ) where

import Prelude

import Pinto.GenServer (ServerPid, ServerType)
import PurerlTest.Reporter.Bus as ReporterBus
import PurerlTest.Types (SuiteName)

type Message = ReporterBus.Message

type State = { suitesInFlight :: Array SuiteName, failures :: Int }

type Arguments = {}

type ServerType' = ServerType Unit Unit Message State
type Pid = ServerPid Unit Unit Message State
