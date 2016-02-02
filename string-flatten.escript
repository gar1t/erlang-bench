#!/usr/bin/env escript
%%%
%%% Flattening iolists to form "strings" in Erlang is generally a
%%% waste time and space. Just pass the iolist along and most
%%% everything will happily work with it.
%%%
%%% But what about APIs that overload an argument to be either a
%%% "string" or "list of strings"? It's a bad practice, but sometimes
%%% that's the hand you're dealt.
%%%
%%% What's the most efficient way to flatten an iolist into a so called
%%% string?
%%%
%%% There's lists:flatten/1 - but this works only with lists won't
%%% convert binaries along the way. Why would it? Still, for deeply
%%% nested lists of ints, it will get us our precious string-looking
%%% result.
%%%
%%% Another approach is to convert the iolist to binary with the
%%% venerable iolist_to_binary/1, and convert that to a list.
%%%
%%% Here are the results on my laptop running 18.
%%%
%%% flatten: 780
%%% binary_to_list: 478
%%%
%%% Here it looks like the seemingly more expensive two-step operation
%%% of first converting the iolist to a binary and then converting the
%%% binary to a list is slightly faster.
%%%
-mode(compile).

-include("bench.hrl").

-define(TRIALS, 1000000).
-define(TARGET, "sr0hZUwaVPJETArtq//HQx0YbX4ma3lcuCxzBH4UkGY2yNXz").
-define(IOLIST, [["sr0hZUwaVPJ"], ["ETArtq//HQx0Y", "bX4ma3lcuC"], 
                "xzBH4UkGY2yNXz"]).

main(_) ->
    test_flatten(),
    test_binary_to_list().

test_flatten() ->
    bench(
      "flatten",
      fun() -> flatten(?TARGET, ?IOLIST) end,
      ?TRIALS).

flatten(Target, Data) ->
    Target = lists:flatten(Data).

test_binary_to_list() ->
    bench(
      "binary_to_list",
      fun() -> binary_to_list(?TARGET, ?IOLIST) end,
      ?TRIALS).

binary_to_list(Target, Data) ->
    Target = binary_to_list(iolist_to_binary(Data)).
