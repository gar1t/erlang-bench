#!/usr/bin/env escript
%%%
%%% What's the most efficient way to get the Nth item from a list of items?
%%%
%%% Approaches:
%%%
%%% - Erlang list
%%% - Erlang "array"
%%% - Tuple
%%%
%%% Results on my laptop under 17:
%%%
%%% list: 3493
%%% array: 316
%%% tuple: 67
%%%
-mode(compile).

-include("bench.hrl").

-define(TRIALS, 10000).
-define(NUM_ITEMS, 200).
-define(ITEM, 'X').

main(_) ->
    Items = lists:duplicate(?NUM_ITEMS, ?ITEM),
    test_list(Items),
    test_array(Items),
    test_tuple(Items).

test_list(Items) ->
    Max = length(Items),
    Get = fun lists:nth/2,
    bench("list", fun() -> lookup(Items, 1, Max, Get) end, ?TRIALS).

test_array(Items) ->
    Array = array:from_list(Items),
    Max = length(Items),
    Get = fun array:get/2,
    bench("array", fun() -> lookup(Array, 0, Max - 1, Get) end, ?TRIALS).

test_tuple(Items) ->
    Tuple = list_to_tuple(Items),
    Max = length(Items),
    Get = fun element/2,
    bench("tuple", fun() -> lookup(Tuple, 1, Max, Get) end, ?TRIALS).
                        
lookup(Items, N, Max, Get) when N =< Max ->   
    ?ITEM = Get(N, Items),
    lookup(Items, N + 1, Max, Get);
lookup(_, _, _, _) -> ok.
