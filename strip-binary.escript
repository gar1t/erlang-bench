#!/usr/bin/env escript
%%%
%%% It's pretty common to trim spaces (or other characters) from a
%%% string. But what if the string is represented by a binary? Does
%%% it make sense to convert the binary to a list and apply
%%% string:strip to it? Or is there a better way?
%%%
%%% The alternative explored here is taken from this informative
%%% thread:
%%%
%%% http://erlang.org/pipermail/erlang-questions/2009-June/044786.html
%%%
%%% Representative of my results (laptop):
%%%
%%% string_strip: 0.724 us (1381816.67 per second)
%%% re_strip: 5.204 us (192149.17 per second)
%%% compiled_re_strip: 4.244 us (235607.28 per second)
%%%
%%% So stupid is apparently a lot faster!
%%%
-mode(compile).

-include("bench.hrl").

-define(STRING,   <<"    some_value_we_want_stripped         ">>).
-define(STRIPPED, <<"some_value_we_want_stripped">>).
-define(STRIP_RE, "^\\s+|\\s+$").
-define(TRIALS, 1000000).

main(_) ->
    test_string_strip(),
    test_re_strip(),
    test_compiled_re_strip().

test_string_strip() ->
    bench(
      "string_strip",
      fun() -> string_strip(?STRING) end,
      ?TRIALS).

string_strip(Str) ->
    ?STRIPPED = list_to_binary(string:strip(binary_to_list(Str))).

test_re_strip() ->
    bench(
      "re_strip",
      fun() -> re_strip(?STRING, ?STRIP_RE) end,
      ?TRIALS).

re_strip(Str, RE) ->
    ?STRIPPED = re:replace(Str, RE, "", [global, {return, binary}]).

test_compiled_re_strip() ->
    {ok, Compiled} = re:compile(?STRIP_RE),
    bench(
      "compiled_re_strip",
      fun() -> re_strip(?STRING, Compiled) end,
      ?TRIALS).
