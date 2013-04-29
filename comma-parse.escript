#!/usr/bin/escript
%%%
%%% This test is driven by erlydtl's inability to support yesno filter with
%%% empty values. E.g. "var|yesno:'if-true,'" will fail. It shouldn't.
%%%
%%% The yesno filter uses string:token/2 to parse the string. I was curious
%%% is switching to re:split/3 would cause a significant performance hit.
%%%
%%% Typical results on my laptop under R16B:
%%%
%%%  string_tokens: 3972
%%%  uncompiled_re_split: 7837
%%%  compiled_re_split: 12006
%%%  binary_split: 4998
%%%  binary_split_with_convert: 11005
%%%
%%% It's quite surprising that the compiled regex is several times slower
%%% the uncompiled regex.

-define(TRIALS, 100000).
-define(STRINGS,
        ["yes,no,default",
         "yes,",
         "yes,,",
         "01234567890123456789,01234567890123456789,01234567890123456789"]).
-define(COMMA, ",").
-define(COMMA_REGEX,
        {re_pattern,0,0,
         <<69,82,67,80,57,0,0,0,0,0,0,0,2,0,0,0,0,0,0,0,44,0,0,0,48,0,
           0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,93,0,5,27,44,
           84,0,5,0>>}).

main(_) ->
    test_string_tokens(),
    test_uncompiled_re_split(),
    test_compiled_re_split(),    
    test_bin_split(),
    test_convert_bin_split().

test_string_tokens() ->
    F = fun() -> string_tokenize(?STRINGS, ?COMMA) end,
    print_result("string_tokens", tc(F)).

string_tokenize([S|Rest], Delimiter) ->
    string:tokens(S, Delimiter),
    string_tokenize(Rest, Delimiter);
string_tokenize([], _Delim) -> ok.

test_uncompiled_re_split() ->
    F = fun() -> re_split(?STRINGS, ?COMMA) end,
    print_result("uncompiled_re_split", tc(F)).

re_split([S|Rest], Pattern) ->
    re:split(S, Pattern, [{return, list}]),
    re_split(Rest, Pattern);
re_split([], _Pattern) -> ok.

test_compiled_re_split() ->
    F = fun() -> re_split(?STRINGS, ?COMMA_REGEX) end,
    print_result("compiled_re_split", tc(F)).

test_bin_split() ->
    BinStrings = [list_to_binary(S) || S <- ?STRINGS],
    BinComma = list_to_binary(?COMMA),
    F = fun() -> bin_split(BinStrings, BinComma) end,
    print_result("binary_split", tc(F)).

bin_split([S|Rest], Sep) ->
    binary:split(S, Sep, [global]),
    bin_split(Rest, Sep);
bin_split([], _Sep) -> ok.

test_convert_bin_split() ->
    F = fun() -> convert_bin_split(?STRINGS, ?COMMA) end,
    print_result("binary_split_with_convert", tc(F)).

convert_bin_split([S|Rest], Sep) ->
    SBin = list_to_binary(S),
    SepBin = list_to_binary(Sep),
    [binary_to_list(Part) || Part <- binary:split(SBin, SepBin, [global])],
    convert_bin_split(Rest, Sep);
convert_bin_split([], _Sep) -> ok.

tc(Check) ->
    timer:tc(fun() -> repeat(?TRIALS, Check) end).

repeat(0, _Fun) -> ok;
repeat(N, Fun) -> Fun(), repeat(N - 1, Fun).

print_result(Name, {Time, _}) ->
    io:format("~s: ~w~n", [Name, Time div 1000]).
