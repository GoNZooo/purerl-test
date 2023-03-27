-module(purerlExUnit_supervisor@foreign).

-export([runner_start_link/0]).

runner_start_link() ->
  fun() ->
     case 'Elixir.PurerlExUnit.Runner':start_link([]) of
       {ok, Pid} -> {right, Pid};
       {error, Reason} -> {left, Reason}
     end
  end.
