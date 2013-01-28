#!/usr/bin/escript
%%% name-lookup.escript
%%%
%%% I had a case where I needed to test whether a value was a member of a small
%%% set (~20) of strings. The obvious choices in Erlang for this are: set,
%%% dict, and list.
%%%
%%% The time measures repeated lookup of each member (to test for a match) and
%%% a lookup of each member reverse (to test for a non match).
%%%
%%% My results on three trials:
%%%
%%% $ ./name-lookup.escript
%%% set: 3646
%%% dict: 3668
%%% list: 3554
%%% $ ./name-lookup.escript
%%% set: 3615
%%% dict: 3573
%%% list: 3458
%%% $ ./name-lookup.escript
%%% set: 3622
%%% dict: 3570
%%% list: 3514
%%%
%%% Interestingly, the simplest approach (use a list!) appears to be as fast
%%% (well, faster) than the other two.

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

-define(TRIALS, 10000).

%%%===================================================================
%%%===================================================================

main(_) ->
    Names = ?NAMES,
    NotNames = reverse_each(?NAMES),
    test_set(Names, NotNames),
    test_dict(Names, NotNames),
    test_list(Names, NotNames).

reverse_each(Strings) ->
    [lists:reverse(S) || S <- Strings].

%%%===================================================================
%%% Set test
%%%===================================================================

test_set(Names, NotNames) ->
    Set = sets:from_list(Names),
    Check =
        fun() ->
                check_each_in_set(Names, true, Set),
                check_each_in_set(NotNames, false, Set)
        end,
    print_result("set", tc(Check)).

check_each_in_set([], _Expected, _Set) -> ok;
check_each_in_set([Name|Rest], Expected, Set) ->
    Expected = sets:is_element(Name, Set),
    check_each_in_set(Rest, Expected, Set).

%%%===================================================================
%%% Dict test
%%%===================================================================

test_dict(Names, NotNames) ->
    Dict = dict:from_list([{Name, 0} || Name <- ?NAMES]),
    Check =
        fun() ->
                check_each_in_dict(Names, true, Dict),
                check_each_in_dict(NotNames, false, Dict)
        end,
    print_result("dict", tc(Check)).

check_each_in_dict([], _Expected, _Dict) -> ok;
check_each_in_dict([Name|Rest], Expected, Dict) ->
    Expected = dict:is_key(Name, Dict),
    check_each_in_dict(Rest, Expected, Dict).

%%%===================================================================
%%% List test
%%%===================================================================

test_list(Names, NotNames) ->
    Check =
        fun() ->
                check_each_in_list(Names, true, Names),
                check_each_in_list(NotNames, false, Names)
        end,
    print_result("list", tc(Check)).

check_each_in_list([], _Expected, _List) -> ok;
check_each_in_list([Name|Rest], Expected, List) ->
    Expected = lists:member(Name, List),
    check_each_in_list(Rest, Expected, List).

%%%===================================================================
%%% Helpers
%%%===================================================================

tc(Check) ->
    timer:tc(fun() -> repeat(?TRIALS, Check) end).

repeat(0, _Fun) -> ok;
repeat(N, Fun) -> Fun(), repeat(N - 1, Fun).

print_result(Name, {Time, _}) ->
    io:format("~s: ~w~n", [Name, Time div 1000]).
