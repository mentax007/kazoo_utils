#!/usr/bin/python

##
## An attempt to get numbers into cache
##

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

def process_db(nums_db):
    curr_db = server[nums_db]
    for row in curr_db.view('_design/numbers/_view/status'):
        print "\n key: %s id: %s" % (row.key, row.id)
        pump_the_number(row.id)

def pump_the_number(number):
    sup_cmd = "/opt/kazoo/utils/sup/sup stepswitch_maintenance lookup_number %s" %(number)
    print sup_cmd
    os.system(sup_cmd)
    time.sleep(2)

if __name__ == '__main__':

    import argparse
    import couchdb
    import time
    import re
    import sys
    import os

    parser = argparse.ArgumentParser(description="Lift KAZOO numbers to the cache.")
    parser.add_argument("--pumpit", "-p", action='store_true', help="Pump the numbers into the cache")

    myargs = parser.parse_args()

    my_url = 'http://localhost:15984/'

    if myargs.pumpit:
        server = couchdb.Server(my_url)
        for db in server:
            if db.startswith("numbers/"):
                print "\n Found database %s" % db
                process_db(db)
    else:
        print "Get help with -h option"
