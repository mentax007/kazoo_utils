#!/usr/bin/python26

##
## An attempt to get numbers into cache (but it seems it doesnt helps us :) )
##
## According to wiki: https://2600hz.atlassian.net/wiki/display/docs/Stepswitch+SUP+Commands
##
## sup stepswitch_maintenance lookup_number NUMBER - 
##
## When provided with a number Stepswitch will return the known parameters of that number. 
## These are drawn from the local cache if present or looked up and cached if not. 
## This provides insight into what account a number is associated with for inbound calls 
## as well as if outbound calls to this number will stay on-net.
##

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

def process_db(nums_db):
    curr_db = server[nums_db]
    for row in curr_db.view('_design/numbers/_view/status'):
        print "\n key: %s id: %s" % (row.key, row.id)
        ping_the_number(row.id)

def ping_the_number(number):
    sup_cmd = "/usr/bin/sipp %s -sn uac -m 1 -sf /usr/share/sipp/INVITE-BYE.xml -s %s" %(myargs.sipserver, number)
    print sup_cmd
    os.system(sup_cmd)
    time.sleep(3)
    os.system(sup_cmd)
    time.sleep(2)

if __name__ == '__main__':

    import argparse
    import couchdb
    import time
    import os

    parser = argparse.ArgumentParser(description="Keep KAZOO numbers in the cache.")
    parser.add_argument("--whappsserver", "-ws", action='store', dest='whappsserver', help="One if KAZOO WhApps servers", required=True)
    parser.add_argument("--sipserver", "-ss", action='store', dest='sipserver', help="One if KAZOO FS servers", required=True)

    myargs = parser.parse_args()

    my_url = 'http://' + myargs.whappsserver + ':15984/'

    if myargs.sipserver:
        server = couchdb.Server(my_url)
        for db in server:
            if db.startswith("numbers/"):
                print "\n %s Found database %s" % (time.asctime( time.localtime(time.time()) ), db)
                process_db(db)
    else:
        print "Get help with -h option"
