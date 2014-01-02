#!/usr/bin/env escript
%%% element-lookup.escript
%%%
%%% This is the most myopic of tests! I was curious which of these two forms
%%% is "faster":
%%%
%%%    {_, Value} = {ok, Value}
%%%    element(2, {ok, Value})
%%%
%%% Pretty stupid, I know. But I'm curious!
%%%
%%% These results are representative on my laptop (R16B):
%%%
%%% match: 344
%%% element_fun: 183
%%%
%%% A direct tuple element lookup appears to be ~2x faster than an
%%% efficient-looking pattern match bind.
%%%
-mode(compile).

-include("bench.hrl").

-define(VALUE, "Hello").
-define(TUPLE, {ok, ?VALUE}).

-define(TRIALS, 10000000).

main(_) ->
    test_match(),
    test_element_fun().

test_match() ->
    bench("match", fun() -> {_, ?VALUE} = ?TUPLE end, ?TRIALS).

test_element_fun() ->
    bench("element_fun", fun() -> ?VALUE = element(2, ?TUPLE) end, ?TRIALS).
