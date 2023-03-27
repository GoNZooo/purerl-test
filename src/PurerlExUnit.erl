-module(purerlExUnit@foreign).

-export([executeAssertion/2]).

executeAssertion(TestName, Assertion) ->
  fun() ->
      case 'Elixir.PurerlExUnit.Runner':execute(TestName, Assertion) of
        ok -> ok;
        error -> throw(error(test_failure))
      end
  end.
