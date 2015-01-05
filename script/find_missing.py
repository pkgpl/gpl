#!/usr/bin/python

import sys


def help():
	print 'find missing numbered files'
	print 'Options:'
	print '  find_missing base=(file base name) first= last= step=1 len=4 suffix=""'
	sys.exit(1)

def from_param(pname,default=False):
	for item in sys.argv[1:]:
		if item.startswith(pname+'='):
			return item[len(pname)+1:]
	return default

if len(sys.argv)==1:
	help()

basename='file.'
first=1
last=10
step=1

basename=from_param('base')
suffix=from_param('suffix',"")
first=int(from_param('first'))
last=int(from_param('last'))
step=int(from_param('step'))
numlen=int(from_param('len',4))

if not basename: help()
if not first: help()
if not last: help()
if not step: step=1

form="%0"+str(numlen)+"d"
import os
for i in xrange(first,last+1,step):
	filename=basename+form%i+suffix
	if not os.path.exists(filename):
		print "%s is missing!"%filename
