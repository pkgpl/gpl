#!/usr/bin/python
import sys
if len(sys.argv) == 1:
	print 'input grep expression'
	sys.exit(1)

import commands,os
user=os.environ['USER']
grep=sys.argv[1]

list=commands.getstatusoutput("ps -ewf |grep '%s'" % grep)[1].split('\n')
for item in list:
	username,pid = item.split()[0:2]
	if username == user:
		print username, pid, commands.getstatusoutput("kill -9 %s" % pid)

print 'grep expression=',grep
