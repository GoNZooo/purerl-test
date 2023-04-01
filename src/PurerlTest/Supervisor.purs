module PurerlTest.Supervisor
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
import PurerlTest.Reporter as Reporter
import PurerlTest.Suite.Supervisor as SuiteSupervisor
import PurerlTest.Test.Supervisor as TestSupervisor

startLink :: Effect (StartLinkResult SupervisorPid)
startLink = Supervisor.startLink (Just $ Local $ atom supervisorName) $ pure supervisorSpec
  where
  supervisorSpec = { childSpecs, flags }
  supervisorName = "PurerlTest.Supervisor"
  childSpecs =
    ErlList.fromFoldable
      [ SupervisorHelpers.worker "PurerlTest.Reporter" Reporter.startLink
      , SupervisorHelpers.worker "PurerlTest.Suite.Supervisor" SuiteSupervisor.startLink
      , SupervisorHelpers.worker "PurerlTest.Test.Supervisor" TestSupervisor.startLink
      ]
  flags = { strategy, intensity, period }
  strategy = Supervisor.OneForOne
  intensity = 3
  period = Seconds 5.0

