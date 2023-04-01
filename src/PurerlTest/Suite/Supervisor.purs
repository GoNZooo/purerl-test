module PurerlTest.Suite.Supervisor
  ( startLink
  , startChild
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Time.Duration (Milliseconds(..), Seconds(..))
import Effect (Effect)
import Erl.Atom as Atom
import Pinto (RegistryName(..), RegistryReference(..), StartLinkResult)
import Pinto.Supervisor
  ( ChildShutdownTimeoutStrategy(..)
  , ChildType(..)
  , RestartStrategy(..)
  , crashIfChildNotRunning
  )
import Pinto.Supervisor.SimpleOneForOne as Supervisor
import PurerlTest.Suite as Suite
import PurerlTest.Suite.Types as SuiteTypes

type SupervisorType = Supervisor.SupervisorType SuiteTypes.Arguments SuiteTypes.Pid
type Pid = Supervisor.SupervisorPid SuiteTypes.Arguments SuiteTypes.Pid

name :: RegistryName SupervisorType
name = "PurerlTest.Suite.Supervisor" # Atom.atom # Local

startLink :: Effect (StartLinkResult Pid)
startLink = do
  let
    childType = Worker
    intensity = 5
    period = Seconds 10.0
    restartStrategy = RestartTemporary
    start = Suite.startLink
    shutdownStrategy = 5000.0 # Milliseconds # ShutdownTimeout
    init = pure { childType, intensity, period, restartStrategy, start, shutdownStrategy }
  Supervisor.startLink (Just name) init

startChild :: SuiteTypes.Arguments -> Effect SuiteTypes.Pid
startChild arguments = do
  crashIfChildNotRunning <$> Supervisor.startChild (ByName name) arguments
