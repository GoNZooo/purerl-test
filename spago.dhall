{-
Welcome to a Spago project!
You can edit this file as you like.

Need help? See the following resources:
- Spago documentation: https://github.com/purescript/spago
- Dhall language tour: https://docs.dhall-lang.org/tutorials/Language-Tour.html

When creating a new Spago project, you can use
`spago init --no-comments` or `spago init -C`
to generate this file without the comments in this block.
-}
{ name = "purerl-test"
, dependencies =
  [ "arrays"
  , "console"
  , "datetime"
  , "effect"
  , "erl-atom"
  , "erl-lists"
  , "erl-maps"
  , "erl-pinto"
  , "erl-process"
  , "erl-simplebus"
  , "erl-tuples"
  , "foldable-traversable"
  , "foreign"
  , "maybe"
  , "newtype"
  , "prelude"
  , "refs"
  , "strings"
  , "transformers"
  , "tuples"
  , "purerl-alias"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
, backend = "purerl"
}
