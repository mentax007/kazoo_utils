#!/usr/bin/python

import sys
import csv
import math

f = open(sys.argv[1])
csv_f = csv.reader(f)

for row in csv_f:
    print "%s,\"%s\",\"%s\",%s,%.2f,%s,%.2f" % (row[0], row[1].partition(' - ')[0], row[1], row[5], math.ceil(float(row[5])*1.5*100)/100, row[2], math.ceil(float(row[2])*2*100)/100)

f.close()
