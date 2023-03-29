module PurerlExUnit.Suite.Bus
  ( subscribe
  , unsubscribe
  , send
  ) where

import Prelude

import Effect (Effect)
import Effect.Class (class MonadEffect)
import Erl.Process (class HasSelf)
import PurerlExUnit.Types (SuiteName, TestResult)
import SimpleBus (Bus, SubscriptionRef)
import SimpleBus as SimpleBus

bus :: SuiteName -> Bus SuiteName TestResult
bus name = SimpleBus.bus name

subscribe
  :: forall message m
   . HasSelf m message
  => MonadEffect m
  => SuiteName
  -> (TestResult -> message)
  -> m SubscriptionRef
subscribe name f = SimpleBus.subscribe (bus name) f

unsubscribe :: SubscriptionRef -> Effect Unit
unsubscribe = SimpleBus.unsubscribe

send :: SuiteName -> TestResult -> Effect Unit
send name result = SimpleBus.raise (bus name) result
