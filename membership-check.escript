#!/usr/bin/env escript
%%% membership-check.escript
%%%
%%% I had a case where I needed to test whether a value was a member of a small
%%% set (~20) of strings. The obvious choices in Erlang for this are: set,
%%% dict, and list.
%%%
%%% The time measures repeated lookup of each member (to test for a match) and
%%% a lookup of each member reverse (to test for a non match).
%%%
%%% These are representative of the results on my laptop (R16B)
%%%
%%% set: 685
%%% dict: 718
%%% list: 396
%%%
%%% Interestingly, the simplest approach (use a list!) appears to be as fast
%%% (faster) than the other two.
%%%
-mode(compile).

-include("bench.hrl").

-define(
   NAMES,
   ["memory_heap_used",
    "memory_ps_old_gen_committed",
    "proc_stat",
    "proc_rss",
    "threads_count",
    "classes_loaded",
    "memory_ps_perm_gen_peakCommitted",
    "pidstat_cpu",
    "memory_heap_max",
    "proc_vsz",
    "classes_loaded",
    "memory_ps_perm_gen_peakUsed",
    "request_requestCount",
    "request_processingTime",
    "request_errorCount",
    "pidstat_system",
    "memory_ps_survivor_space_committed"]).

-define(TRIALS, 100000).

main(_) ->
    Names = ?NAMES,
    NotNames = reverse_each(?NAMES),
    test_set(Names, NotNames),
    test_dict(Names, NotNames),
    test_list(Names, NotNames).

reverse_each(Strings) ->
    [lists:reverse(S) || S <- Strings].

test_set(Names, NotNames) ->
    Set = sets:from_list(Names),
    bench(
      "set",
      fun() ->
              check_each_in_set(Names, true, Set),
              check_each_in_set(NotNames, false, Set)
      end,
      ?TRIALS).

check_each_in_set([], _Expected, _Set) -> ok;
check_each_in_set([Name|Rest], Expected, Set) ->
    Expected = sets:is_element(Name, Set),
    check_each_in_set(Rest, Expected, Set).

test_dict(Names, NotNames) ->
    Dict = dict:from_list([{Name, 0} || Name <- ?NAMES]),
    bench(
      "dict",
      fun() ->
              check_each_in_dict(Names, true, Dict),
              check_each_in_dict(NotNames, false, Dict)
      end,
      ?TRIALS).

check_each_in_dict([], _Expected, _Dict) -> ok;
check_each_in_dict([Name|Rest], Expected, Dict) ->
    Expected = dict:is_key(Name, Dict),
    check_each_in_dict(Rest, Expected, Dict).

test_list(Names, NotNames) ->
    bench(
      "list",
      fun() ->
              check_each_in_list(Names, true, Names),
              check_each_in_list(NotNames, false, Names)
      end,
      ?TRIALS).

check_each_in_list([], _Expected, _List) -> ok;
check_each_in_list([Name|Rest], Expected, List) ->
    Expected = lists:member(Name, List),
    check_each_in_list(Rest, Expected, List).
