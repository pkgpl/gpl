#!/usr/bin/python
#
# Program :
# Date :

import os
# command line options
from optparse import OptionParser
usage="""Usage: %s [-n NFILES]

print files with big size
"""
optParser=OptionParser(usage)
optParser.add_option('-n','--nfiles',dest='nfiles',default=10,help='number of files to print')
(opt,args)=optParser.parse_args()


nfiles=int(opt.nfiles)

f=os.popen('find .')
list=f.readlines()
f.close()
import re
list=[ re.sub('\n$','',file) for file in list]
list=[ re.sub('^./','',file) for file in list]
list.remove('.')

hash=[]
for file in list:
	hash.append((os.stat(file).st_size,file))

hash.sort()
hash.reverse()

def printsize(size):
	Giga=1024L*1024*1024
	if size> Giga:
		return "%6.1f G"%(size/float(Giga))
	Mega=1024L*1024
	if size> Mega:
		return "%6.1f M"%(size/float(Mega))
	Kilo=1024L
	if size> Kilo:
		return "%6.1f K"%(size/float(Kilo))
	return "%6.1f"%size

for i in xrange(nfiles):
	info=hash[i]
	print "%s   %s"%(printsize(info[0]),info[1])
