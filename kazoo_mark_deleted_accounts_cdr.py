#!/usr/bin/python

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

def get_accountdb_by_name(account_name):
    print " Looking for DB name for %s account .... " % account_name
    cleanaccount =  re.sub(r"[^A-Za-z0-9]","",account_name).lower()
    print "\n RegExed account %s" % (cleanaccount)
    db = server['accounts']
    for row in db.view('_design/accounts/_view/listing_by_name'):
        print "\n %s %s\t ..... \t" % (row.key, row.id),
        if row.key == cleanaccount:
            print "Huray, we've found it:\n\n Account name: %s \t Account ID: %s\n" % (cleanaccount,row.id)
            account_id = row.id
            dbname = 'account/' + account_id[:2] + '/' + account_id[2:4] + '/' + account_id[4:]
            return dbname
        else:
            print "Not the case"

def remove_cdrs(account_db_name):
    print " Cleaning %s \n" % account_db_name
    try:
        db2 = server[account_db_name]
        for row in db2.view('_design/cdrs/_view/listing_by_owner'):
            print "\nWill try to delete %s fetched by listing_by_owner view" % (row.id)
            del db2[row.id]
        for row in db2.view('_design/cdrs/_view/crossbar_listing'):
            print "\nWill try to delete %s fetched by crossbar_listing view" % (row.id)
            del db2[row.id]
    except:
        print "DB2 operations error"
    print "\n Stop machine\n"
    sys.exit(0)

if __name__ == '__main__':

    import argparse
    import couchdb
    import re
    import sys

    parser = argparse.ArgumentParser(description="KAZOO account's CDRs cleaner")
    parser.add_argument('-d', '--db', action='store', dest='dbname', help='Database name')
    parser.add_argument('-n', '--name', action='store', dest='accname', help='Account name')

    myargs = parser.parse_args()

    my_url = 'http://localhost:5984/'

    if myargs.accname:
        server = couchdb.Server(my_url)
        found_dbname = get_accountdb_by_name(myargs.accname)
        if found_dbname:
            remove_cdrs(found_dbname)
        else:
            print "\n No DB found"
    elif myargs.dbname:
        server = couchdb.Server(my_url)
        remove_cdrs(myargs.dbname)
    else:
        print "Get help with -h option"
