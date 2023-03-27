module Test.Main
  ( main
  ) where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
import Erl.Atom as Atom
import Erl.Data.List as List
import Erl.Data.Map as Map
import PurerlExUnit (assert, assertEqual, runSuites, suite, test)

main :: Effect Unit
main = do
  runSuites do
    suite "simple types" do
      test "assertion" do
        assert true

      test "`assertEqual`" do
        assertEqual 1 1

    suite "composite types" do
      test "`assertEqual` with maps" do
        assertEqual
          (Map.fromFoldable [ Atom.atom "hello" /\ 42 ])
          (Map.fromFoldable [ Atom.atom "hello" /\ 42 ])

      test "`assertEqual` with lists" do
        assertEqual (List.fromFoldable [ 1, 2, 3 ]) (List.fromFoldable [ 1, 2, 3 ])

