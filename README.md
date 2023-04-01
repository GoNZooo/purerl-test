# purerl-test

A toolset for running PureScript tests via `mix purerl.test`.

## Installation

Add `:purerl_test` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:purerl_test, "~> 0.1.0"}
  ]
end
```

As well as `purerl-test` to your dependencies in `packages.dhall` & `spago.dhall`:

In `packages.dhall`:

```dhall
let upstream =
      https://github.com/purerl/package-sets/releases/download/erl-0.15.3-20220629/packages.dhall
let purerl-test =
      https://raw.githubusercontent.com/GoNZooo/purerl-test/v0.1.0/spago.dhall
let overrides =
      { purerl-test =
          { repo = "https://github.com/GoNZooo/purerl-test.git"
          , version = "v0.1.0"
          , dependencies = purerl-test.dependencies
          }
      }

in upstream // overrides
```

In `spago.dhall`:

```dhall
{ name = "your-project"
, dependencies = [ "purerl-test" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, backend = "purerl"
}
```


## Usage example (CLI)

```bash
$ mix purerl.test
PurerlEx: assuming the project root is `/home/gonz/code/purescript/purerl-ex-unit`
PurerlEx: no non-dep files changed; skipping running spago to save time.
🧪 simple types
  2/2 successes
🧪 comparison assertions
  4/4 successes
🧪 composite types
  2/2 successes
🎉 All done!
```

## Usage example (code)

```purescript
module Test.MainSpec
  ( main
  ) where

import Prelude

import Data.Tuple.Nested ((/\))
import Effect (Effect)
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
```

Made with [`purerl`](https://github.com/purerl/purerl).
