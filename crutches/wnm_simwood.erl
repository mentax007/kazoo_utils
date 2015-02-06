%%%-------------------------------------------------------------------
%%% @copyright (C) 2015, 2600Hz INC
%%% @doc
%%%
%%% Handle client requests for phone_number at Simwood (UK based provider)
%%% https://www.simwood.com/services/api
%%%
%%% @end
%%% @contributors
%%%   OnNet (Kirill Sysoev github.com/onnet)
%%%-------------------------------------------------------------------
-module(wnm_simwood).

-export([find_numbers/3
         ,acquire_number/1
         ,disconnect_number/1
         ,should_lookup_cnam/0
        ]).

-export([query_simwood/1
        ,process_response/1
       ]).

-include("../wnm.hrl").

-define(WNM_SW_CONFIG_CAT, <<(?WNM_CONFIG_CAT)/binary, ".simwood">>).

-define(SW_NUMBER_URL, whapps_config:get_string(?WNM_SW_CONFIG_CAT
                                                   ,<<"numbers_api_url">>
                                                   ,<<"https://api.simwood.com/v3/numbers">>)).

-define(SW_ACCOUNT_ID, whapps_config:get_string(?WNM_SW_CONFIG_CAT, <<"simwood_account_id">>, <<>>)).
-define(SW_AUTH_USERNAME, whapps_config:get_string(?WNM_SW_CONFIG_CAT, <<"auth_username">>, <<>>)).
-define(SW_AUTH_PASSWORD, whapps_config:get_string(?WNM_SW_CONFIG_CAT, <<"auth_password">>, <<>>)).


-spec find_numbers(ne_binary(), pos_integer(), wh_proplist()) ->
                          {'ok', wh_json:objects()} |
                          {'error', _}.
find_numbers(Prefix, Quantity, Options) ->
    lager:info("Simwood search. Prefix: ~p. Quantity: ~p. Options: ~p.", [Prefix, Quantity, Options]),
    %%
    %%  As of Feb 2015 Simwood number query supports only 1|10|100 search amount
    %%
    URL = list_to_binary([?SW_NUMBER_URL, "/", ?SW_ACCOUNT_ID, <<"/available/standard/">>, sw_quantity(Quantity), "?pattern=", Prefix]), 
    {'ok', Body} = query_simwood(URL), 
    process_response(wh_json:decode(Body)).

%%--------------------------------------------------------------------
%% @public
%% @doc
%% Acquire a given number from the carrier
%% @end
%%--------------------------------------------------------------------
-spec acquire_number(wnm_number()) -> wnm_number().
acquire_number(#number{}=Number) ->
    Number.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Release a number from the routing table
%% @end
%%--------------------------------------------------------------------
-spec disconnect_number(wnm_number()) -> wnm_number().
disconnect_number(#number{}=Number) -> Number.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% @end
%%--------------------------------------------------------------------
-spec should_lookup_cnam() -> boolean().
should_lookup_cnam() -> 'true'.

%%%===================================================================
%%% Internal functions
%%%===================================================================

query_simwood(URL) ->
    lager:debug("querying Simwood ~s", [URL]),
    HTTPOptions = [{'ssl',[{'verify',0}]}
                   ,{'inactivity_timeout', 180000}
                   ,{'connect_timeout', 180000}
                   ,{'basic_auth', {?SW_AUTH_USERNAME, ?SW_AUTH_PASSWORD}}
                  ],
    case ibrowse:send_req(wh_util:to_list(URL), [], 'post', [], HTTPOptions) of
        {'ok', "200", _RespHeaders, Body} ->
            lager:debug("recv 200: ~s", [Body]),
            {'ok', Body};
        {'error', _R} ->
            lager:debug("error querying: ~p", [_R]),
            {'error', 'not_available'}
    end.

sw_quantity(Quantity) when Quantity == 1 -> <<"1">>;
sw_quantity(Quantity) when Quantity > 1, Quantity =< 10  -> <<"10">>;
sw_quantity(_Quantity) -> <<"100">>.

process_response([]) -> {'ok', wh_json:new()};
process_response(Body) ->
    process_response(Body, []).

process_response([], Acc) -> {'ok', wh_json:from_list(Acc)};
process_response([JObj|T], Acc) -> 
    lager:info("Simwood JObj from List: ~p", [JObj]),
    CountryCode = wh_json:get_value(<<"country_code">>, JObj),
    FoundNumber = wh_json:get_value(<<"number">>, JObj),
    E164 = <<"+", CountryCode/binary, FoundNumber/binary>>, 
    Number = {E164, {[{<<"number">>, E164}, {<<"rate">>,<<"2">>}, {<<"activation_charge">>,<<"0">>}]}}, 
    process_response(T, [Number | Acc]).

