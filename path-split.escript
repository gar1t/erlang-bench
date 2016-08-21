#!/usr/bin/env escript
%%% path-split.escript
%%%
%%% Given a path like "foo/bar/baz", what's the fastest way to split it into
%%% its components using the path delimiter?
%%%
%%% Here are some obvious approaches:
%%%
%%% - re:split/3 (both on strings and binaries)
%%% - binary:split/2
%%% - string:tokens/2
%%% - decons/cons recursive function
%%%
%%% These are representative of the results on my laptop (Erlang 18)
%%%
%%% re_string: 6.563 us (152363.77 per second)
%%% re_binary: 5.923 us (168821.39 per second)
%%% binary1: 1.147 us (872037.25 per second)
%%% binary2: 1.319 us (757862.83 per second)
%%% string: 0.444 us (2252404.44 per second)
%%% decons: 0.528 us (1892398.24 per second)
%%%
%%% Regular expressions are, as expected, slower than the other
%%% methods. Working with lists (string and decons) is quite fast. Of
%%% course real word applications memory may be an issue.
%%%
-mode(compile).

-include("bench.hrl").

-define(PATH, "aaaa/bbbb/cccc/dddd/eeee/ffff").
-define(DELIMITER, "/").
-define(PARTS, ["aaaa", "bbbb", "cccc", "dddd", "eeee", "ffff"]).

-define(TRIALS, 100000).

main(_) ->
    test_re_string(?PATH, ?DELIMITER, ?PARTS),
    test_re_binary(?PATH, ?DELIMITER, ?PARTS),
    test_binary1(?PATH, ?DELIMITER, ?PARTS),
    test_binary2(?PATH, ?DELIMITER, ?PARTS),
    test_string(?PATH, ?DELIMITER, ?PARTS),
    test_decons(?PATH, ?DELIMITER, ?PARTS).

test_re_string(Path, Delimiter, Parts) ->
    bench(
      "re_string",
      fun() -> parse_re_string(Path, Delimiter, Parts) end,
      ?TRIALS).

parse_re_string(Path, Delimiter, Parts) ->
    Parts = re:split(Path, Delimiter, [{return, list}]).

test_re_binary(Path, Delimiter, Parts) ->
    PathBin = list_to_binary(Path),
    DelimiterBin = list_to_binary(Delimiter),
    PartsBin = [list_to_binary(Part) || Part <- Parts],
    bench(
      "re_binary",
      fun() -> parse_re_binary(PathBin, DelimiterBin, PartsBin) end,
      ?TRIALS).

parse_re_binary(Path, Delimiter, Parts) ->
    Parts = re:split(Path, Delimiter).

%% This version converts the path to a binary outside the benchmark
%% test - so assumes that the path is already formatted as a binary.
%% Refer to test_binary2 for a test that coverts the path to a binary
%% inside the benchmark.
%%
test_binary1(Path, Delimiter, Parts) ->
    PathBin = list_to_binary(Path),
    DelimiterBin = list_to_binary(Delimiter),
    PartsBin = [list_to_binary(Part) || Part <- Parts],
    bench(
      "binary1",
      fun() -> binary_split_on_bin(PathBin, DelimiterBin, PartsBin) end,
      ?TRIALS).

binary_split_on_bin(Path, Delimiter, Parts) ->
    Parts = binary:split(Path, Delimiter, [global]).

%% This version convers the path to a binary (from a list using
%% iolist_to_binary) as a part of the benchmark.
%%
test_binary2(Path, Delimiter, Parts) ->
    DelimiterBin = list_to_binary(Delimiter),
    PartsBin = [list_to_binary(Part) || Part <- Parts],
    bench(
      "binary2",
      fun() -> binary_split_on_iolist(Path, DelimiterBin, PartsBin) end,
      ?TRIALS).

binary_split_on_iolist(Path, Delimiter, Parts) ->
    Parts = binary:split(iolist_to_binary(Path), Delimiter, [global]).

test_string(Path, Delimiter, Parts) ->
    bench(
      "string",
      fun() -> parse_string(Path, Delimiter, Parts) end,
      ?TRIALS).

parse_string(Path, Delimiter, Parts) ->
    Parts = string:tokens(Path, Delimiter).

test_decons(Path, Delimiter, Parts) ->
    bench(
      "decons",
      fun() -> parse_decons(Path, Delimiter, Parts) end,
      ?TRIALS).

parse_decons(Path, [Delimiter], Parts) ->
    Parts = parse_path(Path, Delimiter, "", []).

parse_path([Delimiter|Rest], Delimiter, Cur, Acc) ->
    parse_path(Rest, Delimiter, "", [lists:reverse(Cur)|Acc]);
parse_path([Char|Rest], Delimiter, Cur, Acc) ->
    parse_path(Rest, Delimiter, [Char|Cur], Acc);
parse_path([], _Delimiter, Last, Acc) ->
    lists:reverse([lists:reverse(Last)|Acc]).
