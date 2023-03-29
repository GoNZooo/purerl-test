-module(purerlExUnit_test@foreign).

-export([executeAssertion_/2]).

executeAssertion_(Assertion, Index) ->
  fun() ->
      'Elixir.PurerlExUnit.Assertion':execute(Assertion, Index)
  end.
