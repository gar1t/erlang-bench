#!/usr/bin/env escript
%%%
%%% What's the most efficient way to dispatch a message to a function?
%%%
%%% The use case driving this is to associate a function handler with a
%%% HTTP request, which contains a method and a path.
%%%
%%% The two ways that are obvious:
%%%
%%% - Erlang function clauses
%%% - Map lookup
%%%
%%% Typical results on my laptop under R16B:
%%%
%%% function_clauses: 175
%%% dict: 580
%%%
%%% So with a relatively small set of messages, Erlang function pattern
%%% matching, even though it's a linear scan, seems like a better option than
%%% dict lookups.
%%%
-mode(compile).

-include("bench.hrl").

-define(
   MSGS, 
   ["p0575t9+KEQpHY9f",
    "EI82ApdVWn0tjD/e",
    "XACxSMLs3O5+W35y",
    "I55Lntpr+tErZNqy",
    "MRY50c6bjnckJ/Yn",
    "VmwLpUin2lpWFnJN",
    "jGWFTqKPUbul1s4L",
    "xytkylrSOKGviFrT",
    "/TV8RbJAnBouSfqQ",
    "WKq038qaueZM9sBf",
    "WBv/Q81iwamxmP1B",
    "GF7Vn041ikzBb0DI",
    "Yas3EljeM8Yjz7sZ",
    "S4Z3upBXzwdblF5L",
    "iY2jsmh0H5kudQKi",
    "uNROG44uhqSj1J2U",
    "GLe6KrdC9Ta5mwCu",
    "s0Ieiaq6ilT5cf1r",
    "p8WPVCrEdRZ1aqB7",
    "9Td9Enk02pMNxNSa",
    "K2Vo+O4yZjo2xfg3",
    "TxnHuLYLjqSyKlY5",
    "Ykk8LaqiDnEHNmDL",
    "pBUcpulFtxI7Cp3z",
    "7btg5o1A70yS5Am2",
    "yP5nrLykp+Dl4aDK",
    "Uplv6IOx011Tg3c8",
    "q9jmXTyKvTCxXD+T",
    "ROSO5FZihF2gpATE",
    "lCVenvgW+zN4qlRh"]).

-define(TRIALS, 100000).

main(_) ->
    test_function_clauses(),
    test_dict().

test_function_clauses() ->
    bench(
      "function_clauses",
      fun() -> function_clauses(?MSGS) end,
      ?TRIALS).

function_clauses([Msg|Rest]) ->
    Msg = dispatch(Msg),
    function_clauses(Rest);
function_clauses([]) -> ok.

dispatch("p0575t9+KEQpHY9f"=Msg) -> Msg;
dispatch("EI82ApdVWn0tjD/e"=Msg) -> Msg;
dispatch("XACxSMLs3O5+W35y"=Msg) -> Msg;
dispatch("I55Lntpr+tErZNqy"=Msg) -> Msg;
dispatch("MRY50c6bjnckJ/Yn"=Msg) -> Msg;
dispatch("VmwLpUin2lpWFnJN"=Msg) -> Msg;
dispatch("jGWFTqKPUbul1s4L"=Msg) -> Msg;
dispatch("xytkylrSOKGviFrT"=Msg) -> Msg;
dispatch("/TV8RbJAnBouSfqQ"=Msg) -> Msg;
dispatch("WKq038qaueZM9sBf"=Msg) -> Msg;
dispatch("WBv/Q81iwamxmP1B"=Msg) -> Msg;
dispatch("GF7Vn041ikzBb0DI"=Msg) -> Msg;
dispatch("Yas3EljeM8Yjz7sZ"=Msg) -> Msg;
dispatch("S4Z3upBXzwdblF5L"=Msg) -> Msg;
dispatch("iY2jsmh0H5kudQKi"=Msg) -> Msg;
dispatch("uNROG44uhqSj1J2U"=Msg) -> Msg;
dispatch("GLe6KrdC9Ta5mwCu"=Msg) -> Msg;
dispatch("s0Ieiaq6ilT5cf1r"=Msg) -> Msg;
dispatch("p8WPVCrEdRZ1aqB7"=Msg) -> Msg;
dispatch("9Td9Enk02pMNxNSa"=Msg) -> Msg;
dispatch("K2Vo+O4yZjo2xfg3"=Msg) -> Msg;
dispatch("TxnHuLYLjqSyKlY5"=Msg) -> Msg;
dispatch("Ykk8LaqiDnEHNmDL"=Msg) -> Msg;
dispatch("pBUcpulFtxI7Cp3z"=Msg) -> Msg;
dispatch("7btg5o1A70yS5Am2"=Msg) -> Msg;
dispatch("yP5nrLykp+Dl4aDK"=Msg) -> Msg;
dispatch("Uplv6IOx011Tg3c8"=Msg) -> Msg;
dispatch("q9jmXTyKvTCxXD+T"=Msg) -> Msg;
dispatch("ROSO5FZihF2gpATE"=Msg) -> Msg;
dispatch("lCVenvgW+zN4qlRh"=Msg) -> Msg.

test_dict() ->
    D = dict:from_list([{Msg, Msg} || Msg <- ?MSGS]),
    bench(
      "dict",
      fun() -> dict(?MSGS, D) end,
      ?TRIALS).

dict([Msg|Rest], Dict) ->
    Msg = dict:fetch(Msg, Dict),
    dict(Rest, Dict);
dict([], _Dict) -> ok.
