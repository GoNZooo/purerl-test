-module(purerlTest_test@foreign).

-export([executeAssertion_/2]).

executeAssertion_(Assertion, Index) ->
  fun() -> 'Elixir.PurerlTest.Assertion':execute(Assertion, Index) end.
