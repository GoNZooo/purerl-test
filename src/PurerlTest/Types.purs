module PurerlTest.Types
  ( TestResult(..)
  , AssertionFailure(..)
  , Suites
  , Suite(..)
  , SuiteName(..)
  , SuiteStatus(..)
  , Tests
  , Test(..)
  , TestName(..)
  , Assertions
  , Assertion(..)
  , AssertionResult(..)
  ) where

import Prelude

import Control.Monad.Reader (ReaderT)
import Data.Generic.Rep (class Generic)
import Data.Newtype (class Newtype)
import Data.Show.Generic (genericShow)
import Effect (Effect)
import Effect.Ref (Ref)
import Foreign (Foreign)

newtype SuiteName = SuiteName String

derive newtype instance Eq SuiteName
derive instance Newtype SuiteName _

newtype TestName = TestName String

derive newtype instance Eq TestName
derive instance Newtype TestName _

data TestResult
  = TestFailed { test :: TestName, failures :: Array AssertionFailure }
  | TestDone { test :: TestName }

data AssertionResult
  = AssertionPassed
  | AssertionFailed { index :: Int, message :: String }

derive instance Generic AssertionResult _

instance Show AssertionResult where
  show = genericShow

data SuiteStatus
  = SuiteStarted { name :: SuiteName }
  | SuiteDone { name :: SuiteName }

type AssertionFailure = { index :: Int, message :: String }

type Suite = { name :: SuiteName, tests :: Tests }

type Test = { name :: TestName, assertions :: Assertions }

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

