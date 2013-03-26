#!/usr/bin/python

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

## function couchdb_pager for better big views handling 
## http://blog.marcus-brinkmann.de/2011/09/17/a-better-iterator-for-python-couchdb/

def couchdb_pager(db, view_name='_all_docs',
                  startkey=None, startkey_docid=None,
                  endkey=None, endkey_docid=None, bulk=500):
    # Request one extra row to resume the listing there later.
    options = {'limit': bulk + 1}
    if startkey:
        options['startkey'] = startkey
        if startkey_docid:
            options['startkey_docid'] = startkey_docid
    if endkey:
        options['endkey'] = endkey
        if endkey_docid:
            options['endkey_docid'] = endkey_docid
    done = False
    while not done:
        view = db.view(view_name, **options)
        rows = []
        # If we got a short result (< limit + 1), we know we are done.
        if len(view) <= bulk:
            done = True
            rows = view.rows
        else:
            # Otherwise, continue at the new start position.
            rows = view.rows[:-1]
            last = view.rows[-1]
            options['startkey'] = last.key
            options['startkey_docid'] = last.id

        for row in rows:
            yield row.id

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
        for row in couchdb_pager(db2,'_design/cdrs/_view/crossbar_listing'):
            print "\nWill try to delete %s fetched by crossbar_listing view" % (row)
            del db2[row]
        for row in couchdb_pager(db2,'_design/cdrs/_view/listing_by_owner'):
            print "\nWill try to delete %s fetched by listing_by_owner view" % (row.id)
            del db2[row]
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

    my_url = 'http://localhost:15984/'

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
