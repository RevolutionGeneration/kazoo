%%%-------------------------------------------------------------------
%%% @copyright (C) 2011-2015, 2600Hz INC
%%% @doc
%%% @end
%%% @contributors
%%%   Karl Anderson
%%%-------------------------------------------------------------------
-module(cf_temporal_route_test).

-include("callflow.hrl").
-include("module/cf_temporal_route.hrl").
-include_lib("eunit/include/eunit.hrl").

sort_wdays_test() ->
    Sorted = [<<"monday">>, <<"tuesday">>, <<"wednesday">>, <<"thursday">>, <<"friday">>, <<"saturday">>, <<"sunday">>],
    Shuffled = wh_util:shuffle_list(Sorted),
    ?assertEqual(Sorted, cf_temporal_route:sort_wdays(Shuffled)).

daily_recurrence_test() ->
    %% basic increment
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2011,6,1}}, {2011,6,1})),
    %%  increment over month boundary
    ?assertEqual({2011,2,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,7,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2011,6,1}}, {2011,6,30})),
    %% increment over year boundary
    ?assertEqual({2011,1,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2010,6,1}}, {2010,12,31})),
    %% leap year (into)
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2008,1,1}}, {2008,2,28})),
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2008,1,1}}, {2008,2,28})),
    %% leap year (over)
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2008,1,1}}, {2008,2,29})),
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2008,1,1}}, {2008,2,29})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2008,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2009,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, start_date={2010,1,1}}, {2011,1,1})),
    %% even step (small)
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,1,1}}, {2011,1,29})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,6,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,7,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,6,1}}, {2011,6,29})),
    %% odd step (small)
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=7, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=7, start_date={2011,1,1}}, {2011,1,29})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=7, start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,6,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=7, start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,7,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=7, start_date={2011,6,1}}, {2011,6,29})),
    %% even step (large)
    ?assertEqual({2011,2,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=48, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=48, start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,7,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=48, start_date={2011,6,1}}, {2011,6,1})),
    %% odd step (large)
    ?assertEqual({2011,3,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=85, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=85, start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,8,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=85, start_date={2011,6,1}}, {2011,6,1})),
    %% current date on (interval)
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,1,5}}, {2011,1,5})),
    %% current date after (interval)
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,1,5}}, {2011,1,6})),
    %% shift start date
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,2,1}}, {2011,2,3})),
    ?assertEqual({2011,2,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={2011,2,2}}, {2011,2,3})),
    %% long span
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"daily">>, interval=4, start_date={1983,4,11}}, {2011,4,11})).


weekly_recurrence_test() ->
    %% basic increment
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %%  increment over month boundary
    ?assertEqual({2011,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,25})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,26})),
    ?assertEqual({2011,2,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,27})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,28})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,29})),
    ?assertEqual({2011,2,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,30})),
    %%  increment over year boundary
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2010,1,1}}, {2010,12,27})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"tuesday">>], start_date={2010,1,1}}, {2010,12,28})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"wensday">>], start_date={2010,1,1}}, {2010,12,29})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"thursday">>], start_date={2010,1,1}}, {2010,12,30})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"saturday">>], start_date={2010,1,1}}, {2010,12,25})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"sunday">>], start_date={2010,1,1}}, {2010,12,26})),
    %%  leap year (into)
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,28})),
    %%  leap year (over)
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,28})),
    ?assertEqual({2008,3,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,29})),
    %% current date on (simple)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,4})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,6})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,7})),
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2009,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>], start_date={2010,1,2}}, {2011,1,1})),
    %% multiple DOWs
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>,<<"tuesday">>,<<"wensday">>,<<"thursday">>,<<"friday">>,<<"saturday">>,<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>,<<"tuesday">>,<<"wensday">>,<<"thursday">>,<<"friday">>,<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"tuesday">>,<<"wensday">>,<<"thursday">>,<<"friday">>,<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"wensday">>,<<"thursday">>,<<"friday">>,<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"thursday">>,<<"friday">>,<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"friday">>,<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% last DOW of an active week
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, wdays=[<<"monday">>,<<"tuesday">>,<<"wensday">>,<<"thursday">>,<<"friday">>], start_date={2011,1,1}}, {2011,1,7})),
    %% even step (small)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    %%     SIDE NOTE: No event engines seem to agree on this case, so I am doing what makes sense to me
    %%                and google calendar agrees (thunderbird and outlook be damned!)
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% odd step (small)
    ?assertEqual({2011,1,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    %%     SIDE NOTE: No event engines seem to agree on this case, so I am doing what makes sense to me
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% even step (large)
    ?assertEqual({2011,6,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    %%     SIDE NOTE: No event engines seem to agree on this case, so I am doing what makes sense to me
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,6,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=24, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% odd step (large)
    ?assertEqual({2011,9,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=37, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    %%     SIDE NOTE: No event engines seem to agree on this case, so I am doing what makes sense to me
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=36, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,9,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=36, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% multiple DOWs with step (currently on start)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,4})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,6})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,7})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,8})),
    %% multiple DOWs with step (start in past)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,9})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,10})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,11})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,12})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,13})),
    ?assertEqual({2011,1,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,14})),
    ?assertEqual({2011,1,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,15})),
    ?assertEqual({2011,1,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,16})),
    %% multiple DOWs over month boundary
    ?assertEqual({2011,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2011,1,1}}, {2011,1,28})),
    %% multiple DOWs over year boundary
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=2, wdays=[<<"monday">>, <<"wensday">>, <<"friday">>], start_date={2010,1,1}}, {2010,12,31})),
    %% current date on (interval)
    ?assertEqual({2011,1,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,4})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,6})),
    ?assertEqual({2011,1,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,7})),
    ?assertEqual({2011,1,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=3, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    %% shift start date
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"monday">>], start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"tuesday">>], start_date={2005,2,8}}, {2011,1,1})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"wensday">>], start_date={2006,3,15}}, {2011,1,1})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"thursday">>], start_date={2007,4,22}}, {2011,1,1})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"friday">>], start_date={2008,5,29}}, {2011,1,1})),
    ?assertEqual({2011,1,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"saturday">>], start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=5, wdays=[<<"sunday">>], start_date={2010,7,8}}, {2011,1,1})),
    %% long span
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=4, wdays=[<<"monday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,5,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"weekly">>, interval=4, wdays=[<<"monday">>], start_date={1983,4,11}}, {2011,4,11})).

monthly_every_recurrence_test() ->
    %% basic increment (also crosses month boundary)
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,10})),
    ?assertEqual({2011,1,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,17})),
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,24})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,4})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,11})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,18})),
    ?assertEqual({2011,2,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,25})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,12})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,19})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,26})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,6})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,13})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,20})),
    ?assertEqual({2011,2,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,27})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,7})),
    ?assertEqual({2011,1,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,14})),
    ?assertEqual({2011,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,21})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,28})),
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,8})),
    ?assertEqual({2011,1,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,15})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,22})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,29})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,1,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,9})),
    ?assertEqual({2011,1,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,16})),
    ?assertEqual({2011,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,23})),
    ?assertEqual({2011,2,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,30})),
    %% increment over year boundary
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2010,1,1}}, {2010,12,27})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2010,1,1}}, {2010,12,28})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2010,1,1}}, {2010,12,29})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2010,1,1}}, {2010,12,30})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2010,1,1}}, {2010,12,25})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2010,1,1}}, {2010,12,26})),
    %% leap year (into)
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,28})),
    %% leap year (over)
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,28})),
    %% current date on (simple)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,10}}, {2011,1,11})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,17}}, {2011,1,19})),
    %% current date after (simple)
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,10}}, {2011,1,14})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,17}}, {2011,1,21})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2005,2,1}}, {2011,1,4})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2006,3,1}}, {2011,1,12})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2007,4,1}}, {2011,1,20})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2008,5,1}}, {2011,1,28})),
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2010,7,1}}, {2011,1,2})),
    %% even step (small)
    ?assertEqual({2011,3,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,25})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,26})),
    ?assertEqual({2011,3,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,27})),
    ?assertEqual({2011,3,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,28})),
    ?assertEqual({2011,3,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,29})),
    ?assertEqual({2011,3,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,30})),
    %% odd step (small)
    ?assertEqual({2011,9,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,6,1}}, {2011,6,27})),
    ?assertEqual({2011,9,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,6,1}}, {2011,6,28})),
    ?assertEqual({2011,9,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,6,1}}, {2011,6,29})),
    ?assertEqual({2011,9,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2011,6,1}}, {2011,6,30})),
    ?assertEqual({2011,9,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2011,6,1}}, {2011,6,24})),
    ?assertEqual({2011,9,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2011,6,1}}, {2011,6,25})),
    ?assertEqual({2011,9,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2011,6,1}}, {2011,6,26})),
    %% current date on (interval)
    ?assertEqual({2011,5,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,5,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,10}}, {2011,1,25})),
    ?assertEqual({2011,5,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,17}}, {2011,1,26})),
    %% current date after (interval)
    ?assertEqual({2011,5,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,2,2})),
    ?assertEqual({2011,5,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2011,1,10}}, {2011,3,14})),
    ?assertEqual({2011,5,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2011,1,17}}, {2011,3,21})),
    %% shift start date
    ?assertEqual({2011,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,5,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"tuesday">>], start_date={2005,2,1}}, {2011,1,1})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"wensday">>], start_date={2006,3,1}}, {2011,1,1})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"thursday">>], start_date={2007,4,1}}, {2011,1,1})),
    ?assertEqual({2011,4,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"friday">>], start_date={2008,5,1}}, {2011,1,1})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"saturday">>], start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,5,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"sunday">>], start_date={2010,7,1}}, {2011,1,1})),
    %% long span
    ?assertEqual({2011,3,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"every">>, wdays=[<<"monday">>], start_date={1983,4,11}}, {2011,1,1})).

monthly_last_recurrence_test() ->
    %% basic increment
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% basic increment (mid year)
    ?assertEqual({2011,6,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,6,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,6,1}}, {2011,6,1})),
    %% increment over month boundary
    ?assertEqual({2011,2,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,2,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% increment over year boundary
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2010,1,1}}, {2010,12,31})),
    ?assertEqual({2011,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2010,1,1}}, {2010,12,31})),
    %% leap year
    ?assertEqual({2008,2,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2004,12,1}}, {2011,1,1})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2005,10,1}}, {2011,1,1})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2006,11,1}}, {2011,1,1})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2007,9,1}}, {2011,1,1})),
    ?assertEqual({2011,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2008,8,1}}, {2011,1,1})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2009,7,1}}, {2011,1,1})),
    ?assertEqual({2011,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2010,6,1}}, {2011,1,1})),
    %% even step (small)
    ?assertEqual({2011,3,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step (small)
    ?assertEqual({2011,4,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% even step (large)
    ?assertEqual({2014,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=36, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step (large)
    ?assertEqual({2014,2,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2014,2,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% shift start date
    ?assertEqual({2011,3,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={2010,12,1}}, {2011,1,1})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={2010,10,1}}, {2011,1,1})),
    ?assertEqual({2011,2,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={2010,11,1}}, {2011,1,1})),
    ?assertEqual({2011,3,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={2010,9,1}}, {2011,1,1})),
    ?assertEqual({2011,2,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={2010,8,1}}, {2011,1,1})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={2010,7,1}}, {2011,1,1})),
    ?assertEqual({2011,3,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={2010,6,1}}, {2011,1,1})),
    %% long span
    ?assertEqual({2011,3,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"monday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"tuesday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"wensday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"thursday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"friday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"saturday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"last">>, wdays=[<<"sunday">>], start_date={1983,4,11}}, {2011,1,1})).

monthly_every_ordinal_recurrence_test() ->
    %% basic first
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% basic second
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% basic third
    ?assertEqual({2011,1,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% basic fourth
    ?assertEqual({2011,1,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% basic fifth
    ?assertEqual({2011,1,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,1})),
    %% on occurance
    ?assertEqual({2011,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,2,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,10})),
    ?assertEqual({2011,2,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,17})),
    ?assertEqual({2011,2,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,24})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% leap year first
    ?assertEqual({2008,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% leap year second
    ?assertEqual({2008,2,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% leap year third
    ?assertEqual({2008,2,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% leap year fourth
    ?assertEqual({2008,2,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% leap year fifth
    ?assertEqual({2008,3,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"monday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"wensday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"thursday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"saturday">>], start_date={2008,1,1}}, {2008,2,1})),
    ?assertEqual({2008,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"sunday">>], start_date={2008,1,1}}, {2008,2,1})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2005,2,1}}, {2011,1,1})),
    ?assertEqual({2011,1,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2006,3,1}}, {2011,1,1})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2007,4,1}}, {2011,1,1})),
    ?assertEqual({2011,2,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2008,5,1}}, {2011,1,1})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,1,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2010,7,1}}, {2011,1,1})),
    %% even step first (small)
    ?assertEqual({2011,3,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"first">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% even step second (small)
    ?assertEqual({2011,3,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% even step third (small)
    ?assertEqual({2011,3,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"third">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% even step fourth (small)
    ?assertEqual({2011,3,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% even step fifth (small)
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,3,31}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step first (small)
    ?assertEqual({2011,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"first">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step second (small)
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step third (small)
    ?assertEqual({2011,4,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"third">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step fourth (small)
    ?assertEqual({2011,4,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fourth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% odd step fifth (small)
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"monday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"wensday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"thursday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"saturday">>], start_date={2011,1,1}}, {2011,1,31})),
%%!!    ?assertEqual({2011, ?, ??}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, ordinal = <<"fifth">>, wdays=[<<"sunday">>], start_date={2011,1,1}}, {2011,1,31})),
    %% shift start date
    ?assertEqual({2011,2,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"first">>, wdays=[<<"monday">>], start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,5,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"second">>, wdays=[<<"tuesday">>], start_date={2005,2,1}}, {2011,1,1})),
    ?assertEqual({2011,3,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"third">>, wdays=[<<"wensday">>], start_date={2006,3,1}}, {2011,1,1})),
    ?assertEqual({2011,1,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"fourth">>, wdays=[<<"thursday">>], start_date={2007,4,1}}, {2011,1,1})),
    ?assertEqual({2011,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"fifth">>, wdays=[<<"friday">>], start_date={2008,5,1}}, {2011,1,1})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"first">>, wdays=[<<"saturday">>], start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,5,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"second">>, wdays=[<<"sunday">>], start_date={2010,7,1}}, {2011,1,1})),
    %% long span
    ?assertEqual({2011,3,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"fourth">>, wdays=[<<"monday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"first">>, wdays=[<<"wensday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"second">>, wdays=[<<"thursday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"third">>, wdays=[<<"friday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"fourth">>, wdays=[<<"saturday">>], start_date={1983,4,11}}, {2011,1,1})),
    ?assertEqual({2011,3,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=5, ordinal = <<"first">>, wdays=[<<"sunday">>], start_date={1983,4,11}}, {2011,1,1})).

monthly_date_recurrence_test() ->
    %% basic increment
    lists:foreach(fun(D) ->
                          ?assertEqual({2011,1,D + 1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[D + 1], start_date={2011,1,1}}, {2011,1,D}))
                  end, lists:seq(1, 30)),
    lists:foreach(fun(D) ->
                          ?assertEqual({2011,6,D + 1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[D + 1], start_date={2011,6,1}}, {2011,6,D}))
                  end, lists:seq(1, 29)),
    %% same day, before
    ?assertEqual({2011,3,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[25], start_date={2011,1,1}}, {2011,3,24})),
    %% increment over month boundary
    ?assertEqual({2011,2,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[1], start_date={2011,1,1}}, {2011,1,31})),
    ?assertEqual({2011,7,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[1], start_date={2011,6,1}}, {2011,6,30})),
    %% increment over year boundary
    ?assertEqual({2011,1,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[1], start_date={2010,1,1}}, {2010,12,31})),
    %% leap year (into)
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[29], start_date={2008,1,1}}, {2008,2,28})),
    %% leap year (over)
    ?assertEqual({2008,3,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[1], start_date={2008,1,1}}, {2008,2,29})),
    %% shift start date (no impact)
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[2], start_date={2008,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[2], start_date={2009,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[2], start_date={2010,1,1}}, {2011,1,1})),
    %% multiple dates
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,3})),
    ?assertEqual({2011,1,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,4})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,5})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,6})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,7})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,8})),
    ?assertEqual({2011,1,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,9})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,10})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,11})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,12})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,13})),
    ?assertEqual({2011,1,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,14})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,15})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,16})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,17})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,18})),
    ?assertEqual({2011,1,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,19})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,20})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,21})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,22})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,23})),
    ?assertEqual({2011,1,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,24})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,25})),
    ?assertEqual({2011,2,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, days=[5,10,15,20,25], start_date={2011,1,1}}, {2011,1,26})),
    %% even step (small)
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, days=[2], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,5,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, days=[2], start_date={2011,1,1}}, {2011,3,2})),
    ?assertEqual({2011,7,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, days=[2], start_date={2011,1,1}}, {2011,5,2})),
    ?assertEqual({2011,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, days=[2], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,8,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=2, days=[2], start_date={2011,6,1}}, {2011,6,2})),
    %% odd step (small)
    ?assertEqual({2011,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,7,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2011,1,1}}, {2011,4,2})),
    ?assertEqual({2011,10,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2011,1,1}}, {2011,7,2})),
    ?assertEqual({2011,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2011,9,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2011,6,1}}, {2011,6,2})),
    %% even step (large)
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=24, days=[2], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2013,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=24, days=[2], start_date={2011,1,1}}, {2011,1,2})),
    ?assertEqual({2011,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=24, days=[2], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2013,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=24, days=[2], start_date={2011,6,1}}, {2011,6,2})),
    %% odd step (large)
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, days=[2], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2014,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, days=[2], start_date={2011,1,1}}, {2011,4,2})),
    ?assertEqual({2011,6,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, days=[2], start_date={2011,6,1}}, {2011,6,1})),
    ?assertEqual({2014,7,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=37, days=[2], start_date={2011,6,1}}, {2011,6,2})),
    %% shift start date
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2007,5,1}}, {2011,1,1})),
    ?assertEqual({2011,3,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2008,6,2}}, {2011,1,1})),
    ?assertEqual({2011,1,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2009,7,3}}, {2011,1,1})),
    ?assertEqual({2011,2,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=3, days=[2], start_date={2010,8,4}}, {2011,1,1})),
    %% long span
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"monthly">>, interval=4, days=[11], start_date={1983,4,11}}, {2011,1,1})).

yearly_date_recurrence_test() ->
    %% basic increment
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,2,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,3,1})),
    %% same month, before
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,4,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,4,10})),
    %% increment over year boundary
    ?assertEqual({2012,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2011,1,1}}, {2011,4,11})),
    %% leap year (into)
    ?assertEqual({2008,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=2, days=[29], start_date={2008,1,1}}, {2008,2,28})),
    %% leap year (over)
    ?assertEqual({2009,2,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=2, days=[29], start_date={2008,1,1}}, {2008,2,29})),
    %% shift start date (no impact)
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2008,10,11}}, {2011,1,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2009,11,11}}, {2011,1,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11], start_date={2010,12,11}}, {2011,1,1})),
    %% even step (small)
    ?assertEqual({2013,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, month=4, days=[11], start_date={2011,1,1}}, {2011,4,11})),
    ?assertEqual({2015,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, month=4, days=[11], start_date={2011,1,1}}, {2014,4,11})),
    %% odd step (small)
    ?assertEqual({2014,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=3, month=4, days=[11], start_date={2011,1,1}}, {2011,4,11})),
    ?assertEqual({2017,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=3, month=4, days=[11], start_date={2011,1,1}}, {2016,4,11})),
    %% shift start dates
    ?assertEqual({2013,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=5, month=4, days=[11], start_date={2008,10,11}}, {2011,1,1})),
    ?assertEqual({2014,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=5, month=4, days=[11], start_date={2009,11,11}}, {2011,1,1})),
    ?assertEqual({2015,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=5, month=4, days=[11], start_date={2010,12,11}}, {2011,1,1})),
    %% long span
    ?assertEqual({2013,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=5, month=4, days=[11], start_date={1983,4,11}}, {2011,1,1})),
    %% multiple days
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11,12,13], start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11,12,13], start_date={2011,1,1}}, {2011,4,11})),
    ?assertEqual({2011,4,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11,12,13], start_date={2011,1,1}}, {2011,4,12})),
    ?assertEqual({2012,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, month=4, days=[11,12,13], start_date={2011,1,1}}, {2011,4,13})),
    ?assertEqual({2013,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, month=4, days=[11,12,13], start_date={2011,1,1}}, {2011,4,13})),
    ok.

yearly_every_recurrence_test() ->
    ok.

yearly_last_recurrence_test() ->
    ok.

yearly_every_ordinal_recurrence_test() ->
    %% basic first
    ?assertEqual({2011,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    %% basic second
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    %% basic third
    ?assertEqual({2011,4,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    %% basic fourth
    ?assertEqual({2011,4,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    %% basic fifth
    ?assertEqual({2012,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
%%!!    ?assertEqual({2013,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
%%!!    ?assertEqual({2014,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
%%!!    ?assertEqual({2015,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
%%!!    ?assertEqual({2017,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,1,1})),
    %% same month, before
    ?assertEqual({2011,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,4,1})),
    ?assertEqual({2011,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,4,10})),
    %% current date on (simple)
    ?assertEqual({2011,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,3,11})),
    ?assertEqual({2012,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,4,11})),
    %% current date after (simple)
    ?assertEqual({2012,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,6,21})),
    %% shift start dates (no impact)
    ?assertEqual({2011,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2004,1,1}}, {2011,1,1})),
    ?assertEqual({2011,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"tuesday">>], month=4, start_date={2005,2,1}}, {2011,1,1})),
    ?assertEqual({2011,4,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"third">>, wdays=[<<"wensday">>], month=4, start_date={2006,3,1}}, {2011,1,1})),
    ?assertEqual({2011,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fourth">>, wdays=[<<"thursday">>], month=4, start_date={2007,4,1}}, {2011,1,1})),
    ?assertEqual({2011,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"fifth">>, wdays=[<<"friday">>], month=4, start_date={2008,5,1}}, {2011,1,1})),
    ?assertEqual({2011,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"first">>, wdays=[<<"saturday">>], month=4, start_date={2009,6,1}}, {2011,1,1})),
    ?assertEqual({2011,4,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, ordinal = <<"second">>, wdays=[<<"sunday">>], month=4, start_date={2010,7,1}}, {2011,1,1})),
    %% even step first (small)
    ?assertEqual({2013,4,1}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,2}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,3}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,4}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,5}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,6}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,7}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"first">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    %% even step second (small)
    ?assertEqual({2013,4,8}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,9}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,10}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,11}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,12}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,13}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,14}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"second">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    %% even step third (small)
    ?assertEqual({2013,4,15}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,16}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,17}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,18}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,19}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,20}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,21}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"third">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    %% even step fourth (small)
    ?assertEqual({2013,4,22}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,23}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,24}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,25}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,26}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,27}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fourth">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    %% basic fifth (small)
    ?assertEqual({2013,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"monday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    ?assertEqual({2013,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"tuesday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
%%!!    ?assertEqual({2014,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"wensday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
%%!!    ?assertEqual({2015,4,28}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"thursday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
%%!!    ?assertEqual({2013,4,29}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"friday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
%%!!    ?assertEqual({2013,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"saturday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
%%!!    ?assertEqual({2017,4,30}, cf_temporal_route:next_rule_date(#rule{cycle = <<"yearly">>, interval=2, ordinal = <<"fifth">>, wdays=[<<"sunday">>], month=4, start_date={2011,1,1}}, {2011,5,1})),
    'ok'.
