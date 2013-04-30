bench(Name, Fun, Trials) ->
    print_result(Name, repeat_tc(Fun, Trials)).

repeat_tc(Fun, Trials) ->
    timer:tc(fun() -> repeat(Trials, Fun) end).

repeat(0, _Fun) -> ok;
repeat(N, Fun) -> Fun(), repeat(N - 1, Fun).

print_result(Name, {Time, _}) ->
    io:format("~s: ~w~n", [Name, Time div 1000]).
