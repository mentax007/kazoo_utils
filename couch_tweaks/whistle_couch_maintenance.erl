

-export([remove_account_doc_by_type/2]).
-export([change_account_timezone/1, change_account_timezone/2]).



remove_account_doc_by_type(Account, DocType) ->
    AccountDb = wh_util:format_account_id(Account, 'encoded'),
    {ok, JObjs} = couch_mgr:all_docs(AccountDb),
    
    _ = [begin
             may_be_delete_doc(AccountDb, wh_json:get_value(<<"id">>, JObj), DocType),
             timer:sleep(100)
         end
         || JObj <- JObjs
        ],
    'ignore'.
 
may_be_delete_doc(AccountDb, DocId, DocType) ->
    {ok, JObj} = couch_mgr:open_doc(AccountDb, DocId),
    case wh_json:get_value(<<"pvt_type">>, JObj) of 
        DocType -> couch_mgr:del_doc(AccountDb, DocId);
        _ -> 'ignore'
    end.

change_account_timezone(Timezone) ->
    Accounts = whapps_util:get_all_accounts(),
    _ = [begin
             change_account_timezone(Timezone, Account),
             timer:sleep(100)
         end
         || Account <- Accounts
        ],
    'ignore'.

change_account_timezone(Timezone, Account) ->
    AccountDb = wh_util:format_account_id(Account, 'encoded'),
    AccountDoc = wh_util:format_account_id(Account, 'raw'),
    {'ok', JObj} = couch_mgr:open_doc(AccountDb, AccountDoc),
    case wh_json:get_value(<<"timezone">>, JObj) of
        Timezone -> ignore;
        _ ->
            couch_mgr:ensure_saved(AccountDb, wh_json:set_value(<<"timezone">>, Timezone, JObj)),
            {'ok', AccDbJObj} = couch_mgr:open_doc(<<"accounts">>, AccountDoc),
            couch_mgr:ensure_saved(<<"accounts">>, wh_json:set_value(<<"timezone">>, Timezone, AccDbJObj))
    end.

