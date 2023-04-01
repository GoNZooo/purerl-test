-module(purerlExUnit_moduleUtilities@foreign).

-export([lowerCaseLetter/1, upperCaseLetter/1]).

lowerCaseLetter(C) ->
  'Elixir.String':downcase(<<C/utf8>>).

upperCaseLetter(C) ->
  'Elixir.String':upcase(<<C/utf8>>).
