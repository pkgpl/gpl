#!/usr/bin/python
#
# Program : print abs path for scp
# Date :

import sys,commands,os.path

if len(sys.argv) < 2:
	print 'input file names'
	sys.exit(1)

cmd=commands.getstatusoutput
user=cmd('echo $USER')[1]
host=cmd('echo $HOSTNAME')[1]
if host=='master02':   host='gplhpc'
if host=='laplace001': host='laplace'
if host=='node01':  host='gop604'
if host=='cudamaster01':   host='newcuda'
if host=='cuda01':   host='cuda'

list=sys.argv[1:]
for item in list:
	path=os.path.abspath(item)
	print "%s@%s:%s"%(user,host,path)
