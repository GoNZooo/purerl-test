module PurerlExUnit where

import Prelude

import Control.Monad.Reader (ReaderT)
import Control.Monad.Reader as Reader
import Data.Array as Array
import Data.Foldable (traverse_)
import Data.FoldableWithIndex (traverseWithIndex_)
import Effect (Effect)
import Effect.Class (liftEffect)
import Effect.Class.Console as Console
import Effect.Ref (Ref)
import Effect.Ref as Ref
import Foreign (Foreign)
import Foreign as Foreign

type Suite = { name :: String, tests :: Tests }

type Test = { name :: String, assertions :: Assertions }

type Tests = ReaderT (Ref (Array Test)) Effect Unit

type Suites = ReaderT (Ref (Array Suite)) Effect Unit

type Assertions = ReaderT (Ref (Array (Assertion Foreign))) Effect Unit

data Assertion a
  = Assert Boolean
  | Refute Boolean
  | AssertEqual { left :: a, right :: a }
  | AssertNotEqual { left :: a, right :: a }
  | AssertGreaterThan { left :: a, right :: a }
  | AssertLessThan { left :: a, right :: a }
  | AssertGreaterThanOrEqual { left :: a, right :: a }
  | AssertLessThanOrEqual { left :: a, right :: a }

runSuites :: Suites -> Effect Unit
runSuites suitesSpecification = do
  suitesRef <- Ref.new []
  Reader.runReaderT suitesSpecification suitesRef
  suites <- Ref.read suitesRef
  traverse_ runSuite suites

runSuite :: Suite -> Effect Unit
runSuite { name, tests } = do
  Console.log $ "🧪 " <> name
  testsRef <- Ref.new []
  Reader.runReaderT tests testsRef
  tests' <- Ref.read testsRef
  traverse_ runTest tests'

runTest :: Test -> Effect Unit
runTest { name, assertions } = do
  assertionsRef <- Ref.new []
  Reader.runReaderT assertions assertionsRef
  assertions' <- Ref.read assertionsRef
  traverseWithIndex_ (runAssertion name) assertions'

runAssertion :: forall a. String -> Int -> Assertion a -> Effect Unit
runAssertion testName index assertion = do
  executeAssertion testName index assertion

foreign import executeAssertion :: forall a. String -> Int -> Assertion a -> Effect Unit

suite :: String -> Tests -> Suites
suite name tests' = do
  suites <- Reader.ask
  suites # Ref.modify_ (_ `Array.snoc` { name, tests: tests' }) # liftEffect

test :: String -> Assertions -> Tests
test name assertions = do
  tests <- Reader.ask
  tests # Ref.modify_ (_ `Array.snoc` { name, assertions }) # liftEffect

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
