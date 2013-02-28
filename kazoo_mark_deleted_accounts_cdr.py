#!/usr/bin/python

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

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

    if myargs.accname:
        cleanaccount =  re.sub(r"[^a-z0-9]","",myargs.accname)
        print "\nLooking for %s" % (cleanaccount)
        server = couchdb.Server('http://localhost:5984/')
        db = server['accounts']
	for row in db.view('_design/accounts/_view/listing_by_name'):
            print "\n %s %s\t ..... \t" % (row.key, row.id),
            if row.key == cleanaccount:
                print "Huray, we've found it:\n\n Account name: %s \t Account ID: %s\n" % (cleanaccount,row.id)
                account_id = row.id
                dbname = 'account/' + account_id[:2] + '/' + account_id[2:4] + '/' + account_id[4:]
                remove_cdrs(dbname)
            else:
                print "Not the case"
    elif myargs.dbname:
        remove_cdrs(myargs.dbname)
    else:
        print "Get help with -h option"
