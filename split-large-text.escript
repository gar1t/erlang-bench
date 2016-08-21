#!/usr/bin/env escript
%%% path-split.escript
%%%
%%% If you're parsing a large block of text (e.g. a few K or more)
%%% what's the more efficient method?
%%%
%%% This test is similar to path-split but deals with larger content.
%%%
%%% The test is to split an IO list consisting of 10k chunks separated
%%% by a delimiter.
%%%
%%% These are representative of the results on my laptop (Erlang 18)
%%%
%%% re_string:    349.630 us (2860.17 per second)
%%% re_binary:     60.838 us (16437.10 per second)
%%% binary_split: 157.960 us (6330.72 per second)
%%%
%%% In the case of these larger files, the regular expression out
%%% performs binary split provided a binary is returned rather than a
%%% list.
%%%
-mode(compile).

-include("bench.hrl").

-define(CHUNK_FILE, "10k.txt").
-define(DELIMITER, <<"\n\n">>).
-define(CHUNKS, 5).

-define(TRIALS, 1000).

main(_) ->
    {ok, Bin} = file:read_file(?CHUNK_FILE),
    Str = lists:duplicate(?CHUNKS, [Bin, ?DELIMITER]),
    Expected = ?CHUNKS + 1,
    test_re_string(Str, ?DELIMITER, Expected),
    test_re_binary(Str, ?DELIMITER, Expected),
    test_binary_split(Str, ?DELIMITER, Expected).

test_re_string(Str, Delim, Expected) ->
    bench(
      "re_string",
      fun() -> split_re_string(Str, Delim, Expected) end,
      ?TRIALS).

split_re_string(Str, Delim, Expected) ->
    Parts = re:split(Str, Delim, [{return, list}]),
    Expected = length(Parts).

test_re_binary(Str, Delim, Expected) ->
    bench(
      "re_binary",
      fun() -> split_re_binary(Str, Delim, Expected) end,
      ?TRIALS).

split_re_binary(Str, Delim, Expected) ->
    Parts = re:split(Str, Delim, [{return, binary}]),
    Expected = length(Parts).

test_binary_split(Str, Delim, Expected) ->
    bench(
      "binary_split",
      fun() -> split_binary(Str, Delim, Expected) end,
      ?TRIALS).

split_binary(Str, Delim, Expected) ->
    Parts = binary:split(iolist_to_binary(Str), Delim, [global]),
    Expected = length(Parts).
