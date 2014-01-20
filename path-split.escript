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
%%% These are representative of the results on my laptop (R16B)
%%%
%%% re_string: 441
%%% re_binary: 408
%%% binary: 47
%%% string: 48
%%% decons: 27
%%%
%%% On casual glance, the fastest is the Plain Jane Erlang function that pulls
%%% the string apart character by character and builds the result using cons
%%% and lists:reverse/1. This is roughly twice the speed of using the binary
%%% and string modules.
%%%
%%% Using a regular expression is quite costly, not surprisingly.
%%%
%%% Given the simplicity of the code, however, one might consider using the
%%% brinary or string modules (depending on the path type) instead of rolling
%%% an Erlang function.
%%%
-mode(compile).

-include("bench.hrl").

-define(VALUE, 9999999).

-define(PATH, "aaaa/bbbb/cccc/dddd/eeee/ffff").
-define(DELIMITER, "/").
-define(PARTS, ["aaaa", "bbbb", "cccc", "dddd", "eeee", "ffff"]).

-define(TRIALS, 10000).

main(_) ->
    test_re_string(?PATH, ?DELIMITER, ?PARTS),
    test_re_binary(?PATH, ?DELIMITER, ?PARTS),
    test_binary(?PATH, ?DELIMITER, ?PARTS),
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

test_binary(Path, Delimiter, Parts) ->
    PathBin = list_to_binary(Path),
    DelimiterBin = list_to_binary(Delimiter),
    PartsBin = [list_to_binary(Part) || Part <- Parts],
    bench(
      "binary",
      fun() -> parse_binary(PathBin, DelimiterBin, PartsBin) end,
      ?TRIALS).

parse_binary(Path, Delimiter, Parts) ->
    Parts = binary:split(Path, Delimiter, [global]).

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
