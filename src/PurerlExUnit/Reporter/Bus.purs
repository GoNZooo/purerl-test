module PurerlExUnit.Reporter.Bus
  ( subscribe
  , unsubscribe
  , send
  , Message(..)
  ) where

import Prelude

import Effect (Effect)
import Effect.Class (class MonadEffect)
import Erl.Atom (Atom)
import Erl.Atom as Atom
import Erl.Process (class HasSelf)
import PurerlExUnit.Types (SuiteStatus)
import SimpleBus (Bus, SubscriptionRef)
import SimpleBus as SimpleBus

data Message
  = SuiteMessage SuiteStatus
  | AllDone Int

name :: Atom
name = Atom.atom "PurerlExUnit.Reporter.Bus"

bus :: Bus Atom Message
bus = SimpleBus.bus name

subscribe
  :: forall message m
   . HasSelf m message
  => MonadEffect m
  => (Message -> message)
  -> m SubscriptionRef
subscribe f = SimpleBus.subscribe bus f

unsubscribe :: SubscriptionRef -> Effect Unit
unsubscribe = SimpleBus.unsubscribe

send :: Message -> Effect Unit
send result = SimpleBus.raise bus result
