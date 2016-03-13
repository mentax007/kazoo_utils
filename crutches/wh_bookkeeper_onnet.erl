-module(wh_bookkeeper_onnet).

-export([sync/2]).
-export([is_good_standing/1]).
-export([transactions/3]).
-export([subscriptions/1]).
-export([commit_transactions/2]).
-export([charge_transactions/2]).
-export([already_charged/2]).

-include("../whistle_services.hrl").

-spec sync(wh_service_item:items(), ne_binary()) -> 'ok'.
sync(Items, AccountId) ->
    ItemList = wh_service_items:to_list(Items),
    lager:info("IAM BOOK sync/2 Items: ~p",[Items]),
    lager:info("IAM BOOK sync/2 ItemList: ~p",[ItemList]),
    lager:info("IAM BOOK sync/2 AccountId: ~p",[AccountId]).

-spec is_good_standing(ne_binary()) -> boolean().
is_good_standing(AccountId) ->
    lager:info("IAM BOOK is_good_standing/1 AccountId: ~p",[AccountId]),
    'true'.

-spec transactions(ne_binary(), gregorian_seconds(), gregorian_seconds()) ->
                          {'ok', wh_transaction:transactions()} |
                          {'error', 'not_found'} |
                          {'error', 'unknown_error'}.
transactions(AccountId, From, To) ->
    lager:info("IAM BOOK transactions/3 AccountId: ~p",[AccountId]),
    lager:info("IAM BOOK transactions/3 From: ~p",[From]),
    lager:info("IAM BOOK transactions/3 To: ~p",[To]),
    case wh_transactions:fetch_local(AccountId, From, To) of
        {'error', _Reason}=Error -> Error;
        {'ok', _Transactions}=Res ->
  %          handle_topup(AccountId, Transactions),
            lager:info("IAM transactions Res: ~p",[Res]),
            Res
    end.


-spec subscriptions(ne_binary()) -> atom() | wh_json:objects().
subscriptions(AccountId) ->
    lager:info("IAM BOOK subscriptions/1 AccountId: ~p",[AccountId]).


-spec commit_transactions(ne_binary(),wh_transactions:wh_transactions()) -> 'ok' | 'error'.
-spec commit_transactions(ne_binary(), wh_transactions:wh_transactions(), integer()) -> 'ok' | 'error'.
commit_transactions(BillingId, Transactions) ->
    commit_transactions(BillingId, Transactions, 3).

commit_transactions(BillingId, Transactions, Try) when Try > 0 ->
    lager:info("IAM BOOK commit_transactions/2,3 BillingId: ~p",[BillingId]),
    lager:info("IAM BOOK commit_transactions/2,3 Transactions: ~p",[Transactions]).

-spec charge_transactions(ne_binary(), wh_json:objects()) -> wh_json:objects().
charge_transactions(BillingId, Transactions) ->
    lager:info("IAM BOOK charge_transactions/2,3 BillingId: ~p",[BillingId]),
    lager:info("IAM BOOK charge_transactions/2,3 Transactions: ~p",[Transactions]).

-spec already_charged(ne_binary() | integer() , integer() | wh_json:objects()) -> boolean().
already_charged(BillingId, Code) when is_integer(Code) ->
    lager:debug("checking if ~s has been charged for transaction of type ~p today", [BillingId, Code]),
    lager:info("IAM BOOK already_charged/2,3 BillingId: ~p",[BillingId]),
    lager:info("IAM BOOK already_charged/2,3 Code: ~p",[Code]).

