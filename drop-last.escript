#!/usr/bin/env escript
%%%
%%% This test is driven by a proposal to implement a drop_last function in
%%% Erlang's lists module.
%%%
%%% http://erlang.org/pipermail/erlang-patches/2013-April/003851.html
%%%
%%% Representative of my results (laptop):
%%%
%%% reverse_reverse:small_list: 166
%%% reverse_reverse:big_list: 3017
%%% recurse:small_list: 210
%%% recurse:small_list: 3115
%%% sublist:small_list: 316
%%% sublist:big_list: 9558
%%%
-mode(compile).

-include("bench.hrl").

-define(SMALL_LIST, lists:seq(1, 100)).
-define(SMALL_LIST_TRIALS, 100000).

-define(BIG_LIST, lists:seq(1, 1000000)).
-define(BIG_LIST_TRIALS, 100).

main(_) ->
    test_reverse_reverse(),
    test_recurse(),
    test_sublist().

test_reverse_reverse() ->
    bench(
      "reverse_reverse:small_list",
      fun() -> reverse_reverse(?SMALL_LIST) end,
      ?SMALL_LIST_TRIALS),
    bench(
      "reverse_reverse:big_list",
      fun() -> reverse_reverse(?BIG_LIST) end,
      ?BIG_LIST_TRIALS).

reverse_reverse(L) ->
    lists:reverse(tl(lists:reverse(L))).

test_recurse() ->
    bench(
      "recurse:small_list",
      fun() -> recurse(?SMALL_LIST) end,
      ?SMALL_LIST_TRIALS),
    bench(
      "recurse:big_list",
      fun() -> recurse(?BIG_LIST) end,
      ?BIG_LIST_TRIALS).

recurse([_]) -> [];
recurse([H|T]) -> [H|recurse(T)].

test_sublist() ->
    bench(
      "sublist:small_list",
      fun() -> sublist(?SMALL_LIST) end,
      ?SMALL_LIST_TRIALS),
    bench(
      "sublist:big_list",
      fun() -> sublist(?BIG_LIST) end,
      ?BIG_LIST_TRIALS).

sublist(L) ->
    lists:sublist(L, 1, length(L) - 1).
