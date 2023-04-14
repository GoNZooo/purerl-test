-module(test_purerlTestSpec@foreign).

-export([crash/1]).

crash(Reason) ->
  fun() -> exit(self(), Reason) end.
