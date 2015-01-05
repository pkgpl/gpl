#!/usr/bin/python
#
# Program : Fix BoundingBox of an eps file
# Author : plusha@gpl.snu.ac.kr
# Date : 8 May 2008
import sys,re
def cmd(command):
	import commands
	return commands.getstatusoutput(command)

if len(sys.argv) < 3:
	print 'Usage: %s <input eps file> <output eps file>'%(sys.argv[0])
	sys.exit(1)

fname=sys.argv[1]
newfname=sys.argv[2]

result=cmd('gs -sDEVICE=bbox -dNOPAUSE -dBATCH %s'%(fname,))[1]
pattern='%%BoundingBox:\s(\-*\d+)\s(\-*\d+)\s(\-*\d+)\s(\-*\d+)'
for line in result.split('\n'):
	m=re.match(pattern,line)
	if m:
		llx,lly,urx,ury = int(m.group(1)),int(m.group(2)),int(m.group(3)),int(m.group(4))

lp=2; rp=lp; bp=3; tp=bp  # left, right, bottom, top padding

print cmd('psbbox llx=%s lly=%s urx=%s ury=%s < %s > %s '%(llx-lp,lly-bp,urx+rp,ury+tp,fname,newfname))[1]
