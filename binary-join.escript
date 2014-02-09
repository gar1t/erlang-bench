#!/usr/bin/env escript
%%%
%%% What's the most efficient way combine a list of binaries into a single
%%% binary?
%%%
%%% The obvious approach is iolist_to_binary/1. But there's also binary
%%% append.
%%%
%%% Accoding to this:
%%%
%%% http://www.erlang.org/doc/efficiency_guide/binaryhandling.html
%%%
%%% The append operation is efficient - binaries are allocated with
%%% size(B) * 2 when they need more space.
%%%
%%% Typical results on my laptop on R16B03 are:
%%%
%%% iolist_to_binary: 96
%%% binary_append: 610
%%%
%%% I'm a little surprised, though I have no basis for surpsie. Clearly
%%% iolist_to_binary/1, in the case where just binaries are joined, is the
%%% way to go. Unless I'm missing something.
%%%
-mode(compile).

-include("bench.hrl").

-define(PART, <<1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16>>).
-define(PART_COUNT, 1000).

-define(TRIALS, 10000).

main(_) ->
    test_iolist_to_binary(),
    test_binary_append().

test_iolist_to_binary() ->
    Parts = lists:duplicate(?PART_COUNT, ?PART),
    Target = iolist_to_binary(Parts),
    bench(
      "iolist_to_binary",
      fun() -> iolist_to_binary_join(Parts, Target) end,
      ?TRIALS).

iolist_to_binary_join(Parts, Target) ->
    Target = iolist_to_binary(Parts).

test_binary_append() ->
    Parts = lists:duplicate(?PART_COUNT, ?PART),
    Target = iolist_to_binary(Parts),
    bench(
      "binary_append",
      fun() -> binary_append(Parts, Target) end,
      ?TRIALS).

binary_append(Parts, Target) ->
    Target = binary_append_acc(Parts, <<>>).

binary_append_acc([Part|Rest], Acc) ->
    binary_append_acc(Rest, <<Acc/binary, Part/binary>>);
binary_append_acc([], Acc) -> Acc.
