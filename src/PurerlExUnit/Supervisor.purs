module PurerlExUnit.Supervisor
  ( startLink
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Time.Duration (Seconds(..))
import Effect (Effect)
import Erl.Atom (atom)
import Erl.Data.List as ErlList
import Pinto.Supervisor (SupervisorPid)
import Pinto.Supervisor as Supervisor
import Pinto.Supervisor.Helpers as SupervisorHelpers
import Pinto.Types (RegistryName(..), StartLinkResult)
import PurerlExUnit.Reporter as Reporter
import PurerlExUnit.Suite.Supervisor as SuiteSupervisor
import PurerlExUnit.Test.Supervisor as TestSupervisor

startLink :: Effect (StartLinkResult SupervisorPid)
startLink = Supervisor.startLink (Just $ Local $ atom supervisorName) $ pure supervisorSpec
  where
  supervisorSpec = { childSpecs, flags }
  supervisorName = "PurerlExUnit.Supervisor"
  childSpecs =
    ErlList.fromFoldable
      [ SupervisorHelpers.worker "PurerlExUnit.Reporter" Reporter.startLink
      , SupervisorHelpers.worker "PurerlExUnit.Suite.Supervisor" SuiteSupervisor.startLink
      , SupervisorHelpers.worker "PurerlExUnit.Test.Supervisor" TestSupervisor.startLink
      ]
  flags = { strategy, intensity, period }
  strategy = Supervisor.OneForOne
  intensity = 3
  period = Seconds 5.0

