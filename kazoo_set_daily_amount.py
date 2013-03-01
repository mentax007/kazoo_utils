#!/usr/bin/python

""" Simple script to set accounts to particular amount of funds in order to eliminate fraud losses.
In case Kazoo billing doesn't needed because of third-party billing system utilization, 
setting the amount of funds of personal accounts to daily limit on daily basis 
will prevent from total balance zeroing in case of sip credentials compromise.

This is a temprorary workaround until feature request WHISTLE-1779 would be resolved
(https://2600hz.atlassian.net/browse/WHISTLE-1779)

Usage:

kazoo_set_daily_amount.py parent_api_key parent_daily_amount child_daily_amount

Example:

kazoo_set_daily_amount.py 3118facba0ef1ab5ba5e65rf527b3c6d331874c79be740ffb28b03e746b92bb7 1000 100


Written by Kirill Sysoev kirill.sysoev@gmail.com
http://onnet.su   /   http://onnet.info  
"""

import sys
import os
import datetime
import pycurl
import cjson as json
from cStringIO import StringIO

def simpleCurlPut(uri, body='', content_type='Content-Type: application/json'):
    c = pycurl.Curl()
    c.setopt(c.UPLOAD, 1)
    c.setopt(c.URL, uri)
    c.setopt(c.HTTPHEADER, [content_type, 'Content-Length: %d' % len(body)])
    c.setopt(c.HTTP_VERSION, c.CURL_HTTP_VERSION_1_1)
    s = StringIO(body)
    c.setopt(c.READFUNCTION, s.read)
    response = StringIO()
    c.setopt(c.WRITEFUNCTION, response.write)
    c.perform()
    c.close()
    response.seek(0)
    return json.decode(response.read().replace('\\/', '/'))

def simpleCurlGet(uri, parent_auth_token):
    c = pycurl.Curl()
    c.setopt(c.HTTPGET, 1)
    c.setopt(c.URL, uri)
    c.setopt(c.HTTPHEADER, ['X-Auth-Token: %s' % parent_auth_token])
    response = StringIO()
    c.setopt(c.WRITEFUNCTION, response.write)
    c.perform()
    c.close()
    response.seek(0)
    return json.decode(response.read().replace('\\/', '/'))

def correctBalance(account_id, move, amount):
    print "Let's Rock - %s %d" %(move, amount)
    sup_cmd = "/opt/kazoo/utils/sup/sup whistle_services_maintenance %s %s %d" %(move, account_id, amount)
    print sup_cmd
    os.system(sup_cmd)

def checkBalance(uri, account_id, dayly_limit, kazoo_auth_token):
    get_account_funds_url = uri + 'accounts/' + account_id + '/braintree/credits'
    receivedData = simpleCurlGet(get_account_funds_url, kazoo_auth_token)
    currentAmount = receivedData['data']['amount']
    print 'Current amount of funds: ', currentAmount
    if abs(dayly_limit - currentAmount) >  dayly_limit/10:
        print "Let us work"
        if (dayly_limit - currentAmount) > 0:
            print "will credit account"
            correctBalance(account_id, "credit", abs(dayly_limit - currentAmount))
        else:
            print "will debit account"
            correctBalance(account_id, "debit", abs(dayly_limit - currentAmount))

    else:
        print "Difference less than 10 % - Do not care"


''' #####################   Arguments  ######################### '''

if len(sys.argv) < 4:
    sys.exit('Usage: kazoo_set_daily_amount.py parent_api_key parent_daily_amount child_daily_amount')

Crossbar_URL = 'http://127.0.0.1:8000/v1/'
Kazoo_auth_URL = Crossbar_URL + 'api_auth'
Kazoo_parent_api_Key =  '{ "data" : {"api_key" : "' + sys.argv[1] + '"}}'
ParentDailyLimit = int(sys.argv[2])
DailyLimit = int(sys.argv[3])

''' #####################   Let's Run  ######################### '''


receivedAuth = simpleCurlPut(Kazoo_auth_URL, Kazoo_parent_api_Key)
Kazoo_parent_token = receivedAuth['auth_token']
Kazoo_parent_account_id = receivedAuth['data']['account_id']

print '''
    ##################################   
        %s
    ##################################   
    Update Parent's (Reseller) balance
    ##################################
    ''' % str(datetime.datetime.now())

checkBalance(Crossbar_URL, Kazoo_parent_account_id, ParentDailyLimit, Kazoo_parent_token)

print '''
    ##################################   
         Update Children balance
    ##################################
    '''

Get_Child_Account_url = Crossbar_URL + 'accounts/' + Kazoo_parent_account_id + '/children'
recievedChildren = simpleCurlGet(Get_Child_Account_url, Kazoo_parent_token)
childrenData = recievedChildren['data']

for i in childrenData:
    print i['realm'], ':', i['id']
    checkBalance(Crossbar_URL, i['id'], DailyLimit, Kazoo_parent_token)


print '''
    ##################################   
           That's all for now
    ##################################   
    '''
