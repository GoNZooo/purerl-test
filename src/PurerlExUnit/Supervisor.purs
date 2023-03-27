module PurerlExUnit.Supervisor
  ( startLink
  ) where

import Prelude

import Data.Maybe (Maybe(..))
import Data.Time.Duration (Seconds(..))
import Effect (Effect)
import Erl.Atom (atom)
import Erl.Data.List as ErlList
import Pinto.GenServer as GenServer
import Pinto.Supervisor (SupervisorPid)
import Pinto.Supervisor as Supervisor
import Pinto.Supervisor.Helpers as SupervisorHelpers
import Pinto.Types (RegistryName(..), StartLinkResult)

startLink :: Effect (StartLinkResult SupervisorPid)
startLink = Supervisor.startLink (Just $ Local $ atom supervisorName) $ pure supervisorSpec
  where
  supervisorSpec = { childSpecs, flags }
  supervisorName = "PurerlExUnit.Supervisor"
  childSpecs =
    ErlList.fromFoldable
      [ SupervisorHelpers.worker "PurerlExUnit.Runner" runner_start_link
      ]
  flags = { strategy, intensity, period }
  strategy = Supervisor.OneForOne
  intensity = 3
  period = Seconds 5.0

--   childSpecs = ErlList.fromFoldable
--     [ SupervisorHelpers.worker "Qlog.Repo" RestartPermanent repo_start_link
--     , SupervisorHelpers.worker "Qlog.Web" RestartPermanent $ Web.startLink {}
--     , SupervisorHelpers.worker "Qlog.Mimer" RestartPermanent $ Mimer.startLink
--     ]
--   flags = { strategy, intensity, period }
--   strategy = Supervisor.OneForOne
--   intensity = 3
--   period = Seconds 5.0
--
-- foreign import repo_start_link
--   :: forall cont stop message state. Effect (StartLinkResult (ServerPid cont stop message state))

foreign import runner_start_link
  :: forall cont stop message state
   . Effect (StartLinkResult (GenServer.ServerPid cont stop message state))

