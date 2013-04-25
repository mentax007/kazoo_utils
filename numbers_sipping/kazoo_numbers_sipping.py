#!/usr/bin/env python26

##
## Another attempt to keep numbers in cache - just generate a call and immediately cancel it.
##
## For crontab do not forget to export TERM for sipp:
## 20 */4 * * *  export TERM=xterm; /usr/bin/python26 /usr/local/bin/kazoo_numbers_sipping.py -ws whapps_server -ss fs_server
##

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

def process_db(nums_db):
    curr_db = server[nums_db]
    for doc in curr_db.view('_design/numbers/_view/status'):
        print "\n Number: %s Status: %s" % (doc.id, doc.key[0])
        if ( doc.key[0] == 'in_service' ):
            print " Ping it..."
            ping_the_number(doc.id)

def ping_the_number(number):
    sup_cmd = "/usr/bin/sipp %s -sn uac -trace_err -m 1 -sf /usr/share/sipp/INVITE-BYE.xml -s %s" %(myargs.sipserver, number)
    print sup_cmd
    os.system(sup_cmd)
    time.sleep(9)
    os.system(sup_cmd)
    time.sleep(7)

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
