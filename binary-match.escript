#!/usr/bin/env escript
%%%
%%% What's the most efficient way to find the offset of a binary pattern?
%%%
%%% binary:match/3 does that, but it uses a "pattern" - I don't know how
%%% efficient this is, when compared to a scan of the binary using the
%%% split_binary or binary_part functions, or pattern matching.
%%%
%%% I think there are four ways to do this:
%%%
%%% - binary:match/2 (using compiled and uncompiled patterns)
%%% - scan using split_binary/2
%%% - scan using binary_part/2
%%% - scan using binary pattern matching
%%%
%%% Typical results on my laptop under R16B:
%%%
%%% binary_match_compiled: 211
%%% binary_match_uncompiled: 210
%%% scan_split: 1666
%%% scan_part: 973
%%% scan_pattern: 206
%%%
%%% Interesting results. binary:match/2 is quite efficient, even when using an
%%% uncompiled pattern (I suspect a single binary is effectively the same as
%%% 'compiled' anyway). Good old bit syntax pattern matching is also very
%%% efficient (but still simpler to just use binary:match/2).
%%%
-mode(compile).

-include("bench.hrl").

-define(NEEDLE, <<1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16>>).
-define(NEEDLE_CP, binary:compile_pattern(?NEEDLE)).

-define(TRIALS, 10000).

main(_) ->
    test_binary_match_compiled(),
    test_binary_match_uncompiled(),
    test_scan_split(),
    test_scan_part(),
    test_scan_pattern().

haystack() ->
    NeedleRev = lists:reverse(binary_to_list(?NEEDLE)),
    Parts =
        [lists:duplicate(20, NeedleRev),
         ?NEEDLE,
         lists:duplicate(20, NeedleRev)],
    NeedlePos = size(?NEEDLE) * 20,
    {NeedlePos, iolist_to_binary(Parts)}.

test_binary_match_compiled() ->
    bench(
      "binary_match_compiled",
      fun() -> binary_match(?NEEDLE_CP, haystack()) end,
      ?TRIALS).

test_binary_match_uncompiled() ->
    bench(
      "binary_match_uncompiled",
      fun() -> binary_match(?NEEDLE, haystack()) end,
      ?TRIALS).

binary_match(Pattern, {Pos, Haystack}) ->
    {Pos, _} = binary:match(Haystack, Pattern).

test_scan_split() ->
    bench(
      "scan_split",
      fun() -> scan_split(?NEEDLE, haystack()) end,
      ?TRIALS).

scan_split(Needle, {Pos, Haystack}) ->
    NeedleSize = size(Needle),
    Start = 0,
    Stop = size(Haystack) - NeedleSize,
    Pos = scan_split(Needle, NeedleSize, Haystack, Start, Stop).

scan_split(Needle, NeedleSize, Haystack, Pos, Stop) when Pos =< Stop ->
    case split_binary(Haystack, Pos) of
        {_, <<Needle:NeedleSize/binary, _/binary>>} -> Pos;
        _ -> scan_split(Needle, NeedleSize, Haystack, Pos + 1, Stop)
    end;
scan_split(_, _, _, _, _) -> not_found. 

test_scan_part() ->
    bench(
      "scan_part",
      fun() -> scan_part(?NEEDLE, haystack()) end,
      ?TRIALS).

scan_part(Needle, {Pos, Haystack}) ->
    NeedleSize = size(Needle),
    Start = 0,
    Stop = size(Haystack) - NeedleSize,
    Pos = scan_part(Needle, NeedleSize, Haystack, Start, Stop).

scan_part(Needle, NeedleSize, Haystack, Pos, Stop) when Pos =< Stop ->
    case binary_part(Haystack, Pos, NeedleSize) of
        Needle -> Pos;
        _ -> scan_part(Needle, NeedleSize, Haystack, Pos + 1, Stop)
    end;
scan_part(_, _, _, _, _) -> not_found.

test_scan_pattern() ->
    bench(
      "scan_pattern",
      fun() -> scan_pattern(?NEEDLE, haystack()) end,
      ?TRIALS).

scan_pattern(Needle, Haystack) ->
    NeedleSize = size(Needle),
    Start = 0,
    Stop = size(Haystack) - NeedleSize,
    scan_pattern(Needle, NeedleSize, Haystack, Start, Stop).

scan_pattern(Needle, NeedleSize, Haystack, Pos, Stop) when Pos =< Stop ->
    case Haystack of
        <<_:Pos/binary, Needle:NeedleSize/binary, _/binary>> -> Pos;
        _ -> scan_pattern(Needle, NeedleSize, Haystack, Pos + 1, Stop)
    end;
scan_pattern(_, _, _, _, _) -> not_found.
