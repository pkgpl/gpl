#!/usr/bin/python
# tobelight@gmail.com
# python version, 18APR2009
import sys,commands,os.path
exefile=os.path.basename(sys.argv[0])

help="""
Gpl Multi-command runner
	run a command iteratively
Usage :
	ex) %s first,last,step command

Required parameters :
	first,last	: integer
	command 	: command string (including python format string)

Optional parameters :
	,step=1	: step size
	-v	: print command

Examples :
	%s 1,5,2 echo %%03d
	001
	003
	005
"""%(exefile,exefile)

if len(sys.argv) < 3:
	print help
	sys.exit(1)

def findflag(list,str):
	"""seek str in the list"""
	if list.count(str):
		list.remove(str)
		return True
	return False
verbose=findflag(sys.argv,'-v')

try:
	first,last,step=sys.argv[1].split(',')
except ValueError:
	first,last=sys.argv[1].split(',')
	step='1'

first=int(first)
last=int(last)
step=int(step)

string=' '.join(sys.argv[2:])

mxsubst=string.count('%')
for i in range(first,last+1,step):
	for j in xrange(mxsubst):
		subst=tuple([i for k in xrange(j+1)])
		try: # substitution
			cmd=string%subst
			break
		except TypeError:
			cmd=string
	if verbose: print cmd
	status,output=commands.getstatusoutput(cmd)
	if status: print 'status=%s'%status
	if output: print output
