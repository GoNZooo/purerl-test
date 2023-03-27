-module(purerlExUnit@foreign).

-export([executeAssertion/3]).

executeAssertion(TestName, Index, Assertion) ->
  fun() ->
      case 'Elixir.PurerlExUnit.Runner':execute(TestName, Index, Assertion) of
        ok -> ok;
        error -> throw(error(test_failure))
      end
  end.
