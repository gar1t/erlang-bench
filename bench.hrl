bench(Name, Fun, Trials) ->
    print_result(Name, repeat_tc(Fun, Trials)).

repeat_tc(Fun, Trials) ->
    {Time, _} = timer:tc(fun() -> repeat(Trials, Fun) end),
    {Time, Trials}.

repeat(0, _Fun) -> ok;
repeat(N, Fun) -> Fun(), repeat(N - 1, Fun).

print_result(Name, {Time, Trials}) ->
    io:format("~s: ~.3f us (~.2f per second)~n",
              [Name, Time / Trials, Trials / (Time / 1000000)]).
