module PurerlExUnit.Application where

import PurerlExUnit.Supervisor as PurerlExUnitSupervisor
import Effect.Uncurried (EffectFn2)
import Erl.Atom (Atom)
import Erl.Data.List as ErlList
import Foreign (Foreign)
import Pinto.App as Application

start :: forall args. EffectFn2 Atom (ErlList.List args) Foreign
start = Application.simpleStart PurerlExUnitSupervisor.startLink
