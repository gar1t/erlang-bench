#!/usr/bin/env escript
%%%
%%% In Erlang you generally don't want to flatten lists to create a plesant
%%% looking "string" - iolists typically work fine with string processing
%%% functions in the core library.
%%%
%%% But what happens when you want to compare a couple strings for euivalence?
%%% Looking over the lists and strings modules, there doesn't appear to be a
%%% function for this. Assuming there isn't a better way to compare two
%%% strings, we need to ensure that both are flattened.
%%%
%%% Typical results on my laptop under R16B:
%%%
%%% flatten: 823
%%% concat: 429
%%% append: 300
%%% to_binary: 554
%%%
%%% These results superficially agree with this:
%%%
%%% http://fdmanana.wordpress.com/2010/09/02/list-concatenation-in-erlang/
%%%
-mode(compile).

-include("bench.hrl").

-define(TRIALS, 1000000).
-define(TARGET, "sr0hZUwaVPJETArtq//HQx0YbX4ma3lcuCxzBH4UkGY2yNXz").
-define(MATCH, ["sr0hZUwaVPJ", "ETArtq//HQx0Y", "bX4ma3lcuC", 
                "xzBH4UkGY2yNXz"]).

main(_) ->
    test_flatten(),
    test_concat(),
    test_append(),
    test_to_binary().

test_flatten() ->
    bench("flatten", fun() -> flatten_cmp(?TARGET, ?MATCH) end, ?TRIALS).

flatten_cmp(Target, Match) ->
    Target = lists:flatten(Match).

test_concat() ->
    bench("concat", fun() -> concat_cmp(?TARGET, ?MATCH) end, ?TRIALS).

concat_cmp(Target, Match) ->
    Target = lists:concat(Match).

test_append() ->
    bench("append", fun() -> append_cmp(?TARGET, ?MATCH) end, ?TRIALS).

append_cmp(Target, Match) ->
    Target = lists:append(Match).

test_to_binary() ->
    bench("to_binary", fun() -> to_binary_cmp(?TARGET, ?MATCH) end, ?TRIALS).

to_binary_cmp(Target, Match) ->
    TargetBin = iolist_to_binary(Target),
    MatchBin = iolist_to_binary(Match),
    TargetBin = MatchBin.
