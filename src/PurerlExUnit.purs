module PurerlExUnit where

import Prelude

import Control.Monad.Reader as Reader
import Data.Array as Array
import Data.Foldable (traverse_)
import Data.Newtype (wrap)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Ref as Ref
import Foreign as Foreign
import PurerlExUnit.Reporter.Bus as ReporterBus
import PurerlExUnit.Suite.Supervisor as SuiteSupervisor
import PurerlExUnit.Types (Assertion(..), Assertions, Suite, SuiteStatus(..), Suites, Tests)

runSuites :: Suites -> Effect Unit
runSuites suitesSpecification = do
  suitesRef <- Ref.new []
  Reader.runReaderT suitesSpecification suitesRef
  suites <- Ref.read suitesRef
  traverse_ runSuite suites

runSuite :: Suite -> Effect Unit
runSuite suite' = do
  ReporterBus.send (ReporterBus.SuiteMessage (SuiteStarted { name: suite'.name }))
  { suite: suite' } # SuiteSupervisor.startChild # void

suite :: String -> Tests -> Suites
suite name tests' = do
  suites <- Reader.ask
  suites # Ref.modify_ (_ `Array.snoc` { name: wrap name, tests: tests' }) # liftEffect

test :: String -> Assertions -> Tests
test name assertions = do
  tests <- Reader.ask
  tests # Ref.modify_ (_ `Array.snoc` { name: wrap name, assertions }) # liftEffect

assert :: Boolean -> Assertions
assert b = do
  assertions <- Reader.ask
  assertions # Ref.modify_ (_ `Array.snoc` Assert b) # liftEffect

refute :: Boolean -> Assertions
refute b = do
  assertions <- Reader.ask
  assertions # Ref.modify_ (_ `Array.snoc` Refute b) # liftEffect

assertEqual :: forall a. Eq a => a -> a -> Assertions
assertEqual left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertEqual { left: Foreign.unsafeToForeign left, right: Foreign.unsafeToForeign right }
        )
    # liftEffect

assertNotEqual :: forall a. Eq a => a -> a -> Assertions
assertNotEqual left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertNotEqual
              { left: Foreign.unsafeToForeign left, right: Foreign.unsafeToForeign right }
        )
    # liftEffect

assertGreaterThan :: forall a. Ord a => a -> a -> Assertions
assertGreaterThan left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertGreaterThan
              { left: Foreign.unsafeToForeign left, right: Foreign.unsafeToForeign right }
        )
    # liftEffect

assertLessThan :: forall a. Ord a => a -> a -> Assertions
assertLessThan left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertLessThan
              { left: Foreign.unsafeToForeign left, right: Foreign.unsafeToForeign right }
        )
    # liftEffect

assertGreaterThanOrEqual :: forall a. Ord a => a -> a -> Assertions
assertGreaterThanOrEqual left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertGreaterThanOrEqual
              { left: Foreign.unsafeToForeign left
              , right: Foreign.unsafeToForeign right
              }
        )
    # liftEffect

assertLessThanOrEqual :: forall a. Ord a => a -> a -> Assertions
assertLessThanOrEqual left right = do
  assertions <- Reader.ask
  assertions
    # Ref.modify_
        ( _ `Array.snoc`
            AssertLessThanOrEqual
              { left: Foreign.unsafeToForeign left
              , right: Foreign.unsafeToForeign right
              }
        )
    # liftEffect
