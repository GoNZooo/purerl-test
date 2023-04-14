module Test.PurerlTestSpec
  ( main
  ) where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Erl.Atom (Atom)
import Erl.Atom as Atom
import Erl.Data.List as List
import Erl.Data.Map as Map
import PurerlTest
  ( assert
  , assertEqual
  , assertGreaterThan
  , assertGreaterThanOrEqual
  , assertLessThan
  , assertLessThanOrEqual
  , assertNotEqual
  , refute
  , runSuites
  , suite
  , test
  )

main :: Effect Unit
main = do
  runSuites do
    suite "simple types" do
      test "`assert` & `refute`" do
        assert true
        refute false

      test "`assertEqual` & `assertNotEqual`" do
        assertEqual 1 1
        assertNotEqual 1 2

    suite "comparison assertions" do
      test "`assertGreaterThan`" do
        assertGreaterThan 1 0
        assertGreaterThan 1.0 0.9

      test "`assertGreaterThanOrEqual`" do
        assertGreaterThanOrEqual 1 0
        assertGreaterThanOrEqual 1 1
        assertGreaterThanOrEqual 1.0 0.9
        assertGreaterThanOrEqual 1.0 1.0

      test "`assertLessThan`" do
        assertLessThan 0 1
        assertLessThan 0.9 1.0

      test "`assertLessThanOrEqual`" do
        assertLessThanOrEqual 0 1
        assertLessThanOrEqual 1 1
        assertLessThanOrEqual 0.9 1.0
        assertLessThanOrEqual 1.0 1.0

    suite "composite types" do
      test "`assertEqual` with maps" do
        assertEqual
          (Map.fromFoldable [ Atom.atom "hello" /\ 42 ])
          (Map.fromFoldable [ Atom.atom "hello" /\ 42 ])

      test "`assertEqual` & `assertNotEqual` with lists" do
        assertEqual (List.fromFoldable [ 1, 2, 3 ]) (List.fromFoldable [ 1, 2, 3 ])
        assertNotEqual (List.fromFoldable [ 1, 2, 3 ]) (List.fromFoldable [ 1, 2, 4 ])

foreign import crash :: Atom -> Effect Unit
