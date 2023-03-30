-module(purerlExUnit_test@foreign).

-export([executeAssertion_/3]).

executeAssertion_(Assertion, Index, TestName) ->
  fun() -> 'Elixir.PurerlExUnit.Assertion':execute(Assertion, Index, TestName) end.
