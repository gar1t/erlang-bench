#!/usr/bin/env escript
%%%
%%% What's the most efficient way to split a binary into two parts using a
%%% pattern?
%%%
%%% This is the sister benchmark to binary-match.
%%%
%%% There are three approaches I can think of:
%%%
%%% - Use binary:match/2 to find the pattern position and split_binary
%%%   to return the parts
%%% - Use binary:split/2
%%% - Use pattern matching
%%%
%%% Typical results on my laptop under R16B:
%%%
%%% binary_match: 67
%%% binary_split: 79
%%% binary_pattern: 3617
%%%
%%% Based on binary-match.escript results, nothing surprising here.
%%% binary:split/2 is the one to use (though strangely, with more moving parts,
%%% the binary:match/2 method is ever so slightly faster).
%%%
-mode(compile).

-include("bench.hrl").

-define(NEEDLE, <<1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16>>).

-define(TRIALS, 100000).

main(_) ->
    test_binary_match(),
    test_binary_split(),
    test_binary_pattern().

haystack() ->
    NeedleRev = lists:reverse(binary_to_list(?NEEDLE)),
    Parts =
        [lists:duplicate(20, NeedleRev),
         ?NEEDLE,
         lists:duplicate(20, NeedleRev)],
    iolist_to_binary(Parts).

test_binary_match() ->
    Haystack = haystack(),
    Target = binary:split(Haystack, ?NEEDLE),
    bench(
      "binary_match",
      fun() -> binary_match(?NEEDLE, Haystack, Target) end,
      ?TRIALS).

binary_match(Needle, Haystack, Target) ->
    {Pos, Len} = binary:match(Haystack, Needle),
    {P1, Rest} = split_binary(Haystack, Pos),
    {_, P2} = split_binary(Rest, Len),
    Target = [P1, P2].

test_binary_split() ->
    Haystack = haystack(),
    Target = binary:split(Haystack, ?NEEDLE),
    bench(
      "binary_split",
      fun() -> binary_split(?NEEDLE, Haystack, Target) end,
      ?TRIALS).

binary_split(Needle, Haystack, Target) ->
    Target = binary:split(Haystack, Needle).


test_binary_pattern() ->
    Haystack = haystack(),
    Target = binary:split(Haystack, ?NEEDLE),
    bench(
      "binary_pattern",
      fun() -> binary_pattern(?NEEDLE, Haystack, Target) end,
      ?TRIALS).

binary_pattern(Needle, Haystack, Target) ->
    NeedleSize = size(Needle),
    Start = 0,
    Stop = size(Haystack) - NeedleSize,
    Target = binary_pattern(Needle, NeedleSize, Haystack, Start, Stop).

binary_pattern(Needle, NeedleSize, Haystack, Pos, Stop) when Pos =< Stop ->
    case Haystack of
        <<P1:Pos/binary, Needle:NeedleSize/binary, P2/binary>> -> [P1, P2];
        _ -> binary_pattern(Needle, NeedleSize, Haystack, Pos + 1, Stop)
    end;
binary_pattern(_, _, _, _, _) -> not_found.
