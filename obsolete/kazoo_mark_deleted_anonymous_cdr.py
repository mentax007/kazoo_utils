#!/usr/bin/python

## yum install python-pip
## pip-python install couchdb
## pip-python install argparse

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

def remove_cdrs():
    try:
        db2 = server["anonymous_cdrs"]
        for row in couchdb_pager(db2,'_design/cdr/_view/listing_by_id'):
            print "\nWill try to delete %s" % (row)
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

    my_url = 'http://localhost:15984/'

    server = couchdb.Server(my_url)
    remove_cdrs()
