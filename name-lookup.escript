#!/usr/bin/env escript
%%% name-lookup.escript
%%%
%%% For smallish lists of items that need to be retrieved using a simple name,
%%% what is the fastest structure?
%%%
%%% proplists provide a canonical structure and are almost ubiquitous. But
%%% proplists are just convention that are compatible with the proplists
%%% module. Is there a substantial performance benefit to using one approach
%%% over the other?
%%%
%%% And what about dict and trees?
%%%
%%% The time measures repeated lookup of each member (to test for a match) and
%%% a lookup of each member reverse (to test for a non match).
%%%
%%% These are representative of the results on my laptop (R16B)
%%%
%%% proplists: 680
%%% lists: 227
%%% dict: 361
%%% gb_tree: 215
%%%
%%% As dict and gb_tree require an initial transformation of the property list,
%%% they might not make sense in any general case (these benchmarks only
%%% measure lookup time and don't include the time to create the structure).
%%%
%%% The clear winner here is lists (this is already well known). It's curious
%%% why proplists doesn't use lists:keyfind.
%%%
-mode(compile).

-include("bench.hrl").

-define(VALUE, 9999999).

-define(
   VALUES,
   [{"memory_heap_used", ?VALUE},
    {"memory_ps_old_gen_committed", ?VALUE},
    {"proc_stat", ?VALUE},
    {"proc_rss", ?VALUE},
    {"threads_count", ?VALUE},
    {"classes_loaded", ?VALUE},
    {"memory_ps_perm_gen_peakCommitted", ?VALUE},
    {"pidstat_cpu", ?VALUE},
    {"memory_heap_max", ?VALUE},
    {"proc_vsz", ?VALUE},
    {"classes_loaded", ?VALUE},
    {"memory_ps_perm_gen_peakUsed", ?VALUE},
    {"request_requestCount", ?VALUE},
    {"request_processingTime", ?VALUE},
    {"request_errorCount", ?VALUE},
    {"pidstat_system", ?VALUE},
    {"memory_ps_survivor_space_committed", ?VALUE}]).

-define(TRIALS, 100000).

main(_) ->
    Names = [Name || {Name, _} <- ?VALUES],
    test_proplists(Names, ?VALUES, ?VALUE),
    test_lists(Names, ?VALUES, ?VALUE),
    test_dict(Names, ?VALUES, ?VALUE),
    test_tree(Names, ?VALUES, ?VALUE).

test_proplists(Names, Values, Expected) ->
    bench(
      "proplists",
      fun() -> lookup_names_in_proplist(Names, Values, Expected) end,
      ?TRIALS).

lookup_names_in_proplist([Name|Rest], Proplist, Expected) ->
    Expected = proplists:get_value(Name, Proplist),
    lookup_names_in_proplist(Rest, Proplist, Expected);
lookup_names_in_proplist([], _Proplist, _Expected) -> ok.

test_lists(Names, Values, Expected) ->
    bench(
      "lists",
      fun() -> lookup_name_in_list(Names, Values, Expected) end,
      ?TRIALS).

lookup_name_in_list([Name|Rest], Values, Expected) ->
    {_, Expected} = lists:keyfind(Name, 1, Values),
    lookup_name_in_list(Rest, Values, Expected);
lookup_name_in_list([], _Values, _Expected) -> ok.

test_dict(Names, Values, Expected) ->
    Dict = dict:from_list(Values),
    bench(
      "dict",
      fun() -> lookup_name_in_dict(Names, Dict, Expected) end,
      ?TRIALS).

lookup_name_in_dict([Name|Rest], Dict, Expected) ->
    {ok, Expected} = dict:find(Name, Dict),
    lookup_name_in_dict(Rest, Dict, Expected);
lookup_name_in_dict([], _Dict, _Expected) -> ok.

test_tree(Names, Values, Expected) ->
    Tree = gb_trees:from_orddict(lists:sort(Values)),
    bench(
      "gb_tree",
      fun() -> lookup_name_in_tree(Names, Tree, Expected) end,
      ?TRIALS).

lookup_name_in_tree([Name|Rest], Tree, Expected) ->
    {value, Expected} = gb_trees:lookup(Name, Tree),
    lookup_name_in_tree(Rest, Tree, Expected);
lookup_name_in_tree([], _Tree, _Expected) -> ok.
