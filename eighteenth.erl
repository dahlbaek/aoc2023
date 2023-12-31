-module(eighteenth).

-export([main/0]).

to_direction_1(<<"R">>) ->
    {1, 0};
to_direction_1(<<"U">>) ->
    {0, -1};
to_direction_1(<<"L">>) ->
    {-1, 0};
to_direction_1(<<"D">>) ->
    {0, 1}.

to_direction_2(<<"0">>) ->
    {1, 0};
to_direction_2(<<"3">>) ->
    {0, -1};
to_direction_2(<<"2">>) ->
    {-1, 0};
to_direction_2(<<"1">>) ->
    {0, 1}.

parse(Func) ->
    {ok, Content} = file:read_file("eighteenth.txt"),
    Lines = binary:split(Content, <<"\n">>, [global]),
    lists:map(Func, Lines).

add_value(Index, 0, Value, Array) ->
    array:set(Index, array:get(Index, Array) + Value, Array);
add_value(Index, Len, Value, Array) ->
    add_value(Index, Len - 1, Value, add_value(Index + Len, 0, Value, Array)).

windowed([_ | ListTail] = List) ->
    lists:zip(List, ListTail, trim).

parse_line_1(Line) ->
    [Direction, StepsString, _] = binary:split(Line, <<" ">>, [global]),
    {Steps, <<>>} = string:to_integer(StepsString),
    {to_direction_1(Direction), Steps}.

parse_line_2(Line) ->
    [_, _, Hex] = binary:split(Line, <<" ">>, [global]),
    Direction = string:slice(Hex, 7, 1),
    StepsString = string:slice(Hex, 2, 5),
    {to_direction_2(Direction), erlang:binary_to_integer(StepsString, 16)}.

points({{XDiff, YDiff}, Steps}, [{X, Y} | _] = Points) ->
    [{X + XDiff * Steps, Y + YDiff * Steps} | Points].

coordinate_groups(Coords) ->
    Grouper = fun({Prev, Curr}) ->
        if
            Prev == Curr ->
                [Prev];
            Prev + 1 == Curr ->
                [Prev, Curr];
            true ->
                [Prev, Prev + 1, Curr]
        end
    end,
    lists:usort(lists:flatmap(Grouper, windowed(Coords))).

index_of(Elem, List) ->
    {Index, _} = lists:keyfind(Elem, 2, lists:enumerate(0, List)),
    Index.

single_group_step([Last], Acc) ->
    lists:reverse([Last | Acc]);
single_group_step([{X1, Y1} | [{X2, Y2} | Tail]], Acc) ->
    Steps =
        if
            X2 > X1 ->
                lists:map(fun(X) -> {X, Y1} end, lists:seq(X1, X2 - 1));
            X1 > X2 ->
                lists:map(fun(X) -> {X, Y1} end, lists:seq(X1, X2 + 1, -1));
            Y2 > Y1 ->
                lists:map(fun(Y) -> {X1, Y} end, lists:seq(Y1, Y2 - 1));
            true ->
                lists:map(fun(Y) -> {X1, Y} end, lists:seq(Y1, Y2 + 1, -1))
        end,
    single_group_step([{X2, Y2} | Tail], lists:reverse(Steps) ++ Acc).

prepare(Input) ->
    PointsRaw = lists:foldl(fun points/2, [{0, 0}], Input),
    XGroups = coordinate_groups(lists:map(fun({X, _}) -> X end, PointsRaw)),
    YGroups = coordinate_groups(lists:map(fun({_, Y}) -> Y end, PointsRaw)),
    ToIndex = fun({X, Y}) -> {index_of(X, XGroups), index_of(Y, YGroups)} end,
    XGroupSizes = lists:map(fun({X1, X2}) -> X2 - X1 end, windowed(XGroups)),
    YGroupSizes = lists:map(fun({Y1, Y2}) -> Y2 - Y1 end, windowed(YGroups)),
    ColLen = length(YGroupSizes),
    RowLen = length(XGroupSizes),
    GroupSize = fun(Index, _) ->
        X = 1 + Index div ColLen,
        Y = 1 + Index rem ColLen,
        lists:nth(X, XGroupSizes) * lists:nth(Y, YGroupSizes)
    end,
    GroupSizes = array:map(GroupSize, array:new(ColLen * RowLen)),
    Counts = array:new(ColLen * RowLen, {default, 0}),
    Points = single_group_step(lists:map(ToIndex, PointsRaw), []),
    {ColLen, GroupSizes, Counts, Points}.

enclosed(Input) ->
    {ColLen, GroupSizes, CountsInit, Points} = prepare(Input),
    InnerRounds = fun({{PrevX, _}, {X, Y}}, Acc) ->
        Tmp = add_value(X * ColLen, Y, X - PrevX, Acc),
        add_value(PrevX * ColLen, Y, X - PrevX, Tmp)
    end,
    CountsInner = lists:foldl(InnerRounds, CountsInit, windowed(Points)),
    BoundaryRounds = fun({X, Y}, Acc) -> array:set(X * ColLen + Y, 2, Acc) end,
    Counts = lists:foldl(BoundaryRounds, CountsInner, Points),
    array:foldl(
        fun(Index, V, Acc) -> Acc + (V div 2) * array:get(Index, GroupSizes) end, 0, Counts
    ).

main() ->
    io:fwrite("Part 1: ~w\n", [enclosed(parse(fun parse_line_1/1))]),
    io:fwrite("Part 2: ~w\n", [enclosed(parse(fun parse_line_2/1))]).
