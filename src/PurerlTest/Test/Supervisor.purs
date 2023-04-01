module PurerlTest.Test.Supervisor
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
import PurerlTest.Test as Test
import PurerlTest.Test.Types as TestTypes

type SupervisorType = Supervisor.SupervisorType TestTypes.Arguments TestTypes.Pid
type Pid = Supervisor.SupervisorPid TestTypes.Arguments TestTypes.Pid

name :: RegistryName SupervisorType
name = "PurerlTest.Test.Supervisor" # Atom.atom # Local

startLink :: Effect (StartLinkResult Pid)
startLink = do
  let
    childType = Worker
    intensity = 5
    period = Seconds 10.0
    restartStrategy = RestartTemporary
    start = Test.startLink
    shutdownStrategy = 5000.0 # Milliseconds # ShutdownTimeout
    init = pure { childType, intensity, period, restartStrategy, start, shutdownStrategy }
  Supervisor.startLink (Just name) init

startChild :: TestTypes.Arguments -> Effect TestTypes.Pid
startChild arguments = do
  crashIfChildNotRunning <$> Supervisor.startChild (ByName name) arguments
