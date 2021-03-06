%%%-------------------------------------------------------------------
%%% @copyright (C) 2012-2016, 2600Hz INC
%%% @doc
%%% Iterate over each account, find configured queues and configured
%%% agents, and start the attendant processes
%%% @end
%%% @contributors
%%%   James Aimonetti
%%%-------------------------------------------------------------------
-module(acdc_init).

-export([start_link/0
         ,init_db/0
         ,init_acdc/0
         ,init_acct/1
         ,init_acct_queues/1
         ,init_acct_agents/1
        ]).

-include("acdc.hrl").

-spec start_link() -> 'ignore'.
start_link() ->
    _ = declare_exchanges(),
    _ = wh_util:spawn(fun init_acdc/0, []),
    'ignore'.

-spec init_acdc() -> any().
init_acdc() ->
    wh_util:put_callid(?MODULE),
    case kz_datamgr:get_all_results(?KZ_ACDC_DB, <<"acdc/accounts_listing">>) of
        {'ok', []} ->
            lager:debug("no accounts configured for acdc");
        {'ok', Accounts} ->
            [init_acct(wh_json:get_value(<<"key">>, Account)) || Account <- Accounts];
        {'error', 'not_found'} ->
            lager:debug("acdc db not found, initializing"),
            _ = init_db(),
            lager:debug("consider running acdc_maintenance:migrate() to enable acdc for already-configured accounts");
        {'error', _E} ->
            lager:debug("failed to query acdc db: ~p", [_E])
    end.

-spec init_db() -> any().
init_db() ->
    _ = kz_datamgr:db_create(?KZ_ACDC_DB),
    _ = kz_datamgr:revise_doc_from_file(?KZ_ACDC_DB, 'crossbar', <<"views/acdc.json">>).

-spec init_acct(ne_binary()) -> 'ok'.
init_acct(Account) ->
    AccountDb = wh_util:format_account_id(Account, 'encoded'),
    AccountId = wh_util:format_account_id(Account, 'raw'),

    lager:debug("init acdc account: ~s", [AccountId]),

    acdc_stats:init_db(AccountId),

    init_queues(AccountId
                ,kz_datamgr:get_results(AccountDb, <<"queues/crossbar_listing">>, [])
               ),
    init_agents(AccountId
                ,kz_datamgr:get_results(AccountDb, <<"users/crossbar_listing">>, [])
               ).

-spec init_acct_queues(ne_binary()) -> any().
init_acct_queues(Account) ->
    AccountDb = wh_util:format_account_id(Account, 'encoded'),
    AccountId = wh_util:format_account_id(Account, 'raw'),

    lager:debug("init acdc account queues: ~s", [AccountId]),
    init_agents(AccountId
                ,kz_datamgr:get_results(AccountDb, <<"queues/crossbar_listing">>, [])
               ).

-spec init_acct_agents(ne_binary()) -> any().
init_acct_agents(Account) ->
    AccountDb = wh_util:format_account_id(Account, 'encoded'),
    AccountId = wh_util:format_account_id(Account, 'raw'),

    lager:debug("init acdc account agents: ~s", [AccountId]),
    init_agents(AccountId
                ,kz_datamgr:get_results(AccountDb, <<"users/crossbar_listing">>, [])
               ).

-spec init_queues(ne_binary(), kz_datamgr:get_results_return()) -> any().
init_queues(_, {'ok', []}) -> 'ok';
init_queues(AccountId, {'error', 'gateway_timeout'}) ->
    lager:debug("gateway timed out loading queues in account ~s, trying again in a moment", [AccountId]),
    try_queues_again(AccountId),
    wait_a_bit(),
    'ok';
init_queues(AccountId, {'error', 'not_found'}) ->
    lager:error("the queues view for ~s appears to be missing; you should probably fix that", [AccountId]);
init_queues(AccountId, {'error', _E}) ->
    lager:debug("error fetching queues: ~p", [_E]),
    try_queues_again(AccountId),
    wait_a_bit(),
    'ok';
init_queues(AccountId, {'ok', Qs}) ->
    acdc_stats:init_db(AccountId),
    [acdc_queues_sup:new(AccountId, wh_doc:id(Q)) || Q <- Qs].

-spec init_agents(ne_binary(), kz_datamgr:get_results_return()) -> any().
init_agents(_, {'ok', []}) -> 'ok';
init_agents(AccountId, {'error', 'gateway_timeout'}) ->
    lager:debug("gateway timed out loading agents in account ~s, trying again in a moment", [AccountId]),
    try_agents_again(AccountId),
    wait_a_bit(),
    'ok';
init_agents(AccountId, {'error', 'not_found'}) ->
    lager:error("the agents view for ~s appears to be missing; you should probably fix that", [AccountId]);
init_agents(AccountId, {'error', _E}) ->
    lager:debug("error fetching agents: ~p", [_E]),
    try_agents_again(AccountId),
    wait_a_bit(),
    'ok';
init_agents(AccountId, {'ok', As}) ->
    [acdc_agents_sup:new(AccountId, wh_doc:id(A)) || A <- As].

wait_a_bit() -> timer:sleep(1000 + random:uniform(500)).

try_queues_again(AccountId) ->
    try_again(AccountId, <<"queues/crossbar_listing">>, fun init_queues/2).
try_agents_again(AccountId) ->
    try_again(AccountId, <<"users/crossbar_listing">>, fun init_agents/2).

try_again(AccountId, View, F) ->
    wh_util:spawn(
      fun() ->
              wh_util:put_callid(?MODULE),
              wait_a_bit(),
              AccountDb = wh_util:format_account_id(AccountId, 'encoded'),
              F(AccountId, kz_datamgr:get_results(AccountDb, View, []))
      end).

-spec declare_exchanges() -> 'ok'.
declare_exchanges() ->
    _ = wapi_acdc_agent:declare_exchanges(),
    _ = wapi_acdc_queue:declare_exchanges(),
    _ = wapi_acdc_stats:declare_exchanges(),
    _ = wapi_call:declare_exchanges(),
    _ = wapi_conf:declare_exchanges(),
    _ = wapi_dialplan:declare_exchanges(),
    _ = wapi_notifications:declare_exchanges(),
    _ = wapi_resource:declare_exchanges(),
    _ = wapi_route:declare_exchanges(),
    _ = wapi_presence:declare_exchanges(),
    wapi_self:declare_exchanges().
