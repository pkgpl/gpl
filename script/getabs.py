#!/usr/bin/python
#
# Program :
# Date :

import sys,math,os.path

if len(sys.argv) == 1:
	print 'return absolute value'
	print 'input file name and column number'
	sys.exit(1)

filename=sys.argv[1]
if not os.path.exists(filename):
	print 'file not exists'
	sys.exit(1)
try:
	cn=int(sys.argv[2])-1
except:
	print 'wrong column number'
	sys.exit(1)

f=open(filename,'r')
lines=f.readlines()
f.close()

for item in lines:
	list=item.split()
	list[cn]=str(math.fabs(float(list[cn])))
	print ' '.join(list)
