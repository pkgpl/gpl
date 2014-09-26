#!/usr/bin/python
#
# Program :
# Date :

def Gnuplot(fname,cmd,deleteFile=0):
	"""gnuplot"""
	fp=open(fname,'w')
	fp.write(cmd)
	fp.close()
	import commands
	commands.getstatusoutput('gnuplot -persist %s'%fname)
	from os import remove
	if deleteFile: remove(fname)

def Glob(pattern):
	"""glob.glob(pattern)"""
	import glob
	return glob.glob(pattern)

def Cmd(command):
	"""commands.getstatusoutput(command)"""
	import commands
	return commands.getstatusoutput(command)

def Quit(message):
	print message
	import sys
	sys.exit(1)


## utils
def Ext(filename,newext):
	"""change extension in a filename"""
	import os.path
	return os.path.splitext(filename)[0]+newext

def Extlist(list,newext):
	"""change extensions in a filename list"""
	extlst=[newext for i in range(len(list))]
	return map(Ext,list,extlst)

def PrintReturnWhenTrue(logic,message,value):
	if logic:
		print message
		return value

def cmd(command):
	import commands
	return commands.getstatusoutput(command)

def str2file(fout,string):
	"""save string to a file"""

	f=open(fout,'w')
	f.write(string)
	f.close()

def TracePick(n1,fin,pick,step=1,last=None,d1=1,type='f'):
	# parse parameters
	if not last: last=pick
	#
	tmp=fin+'_tmp_%s'%pick
	if type=='f': exe='gplTracePick'
	if type=='d': exe='gplTracePickDble'
	if type=='c': exe='gplTracePickCmplx'
	if type=='z': exe='gplTracePickDCmplx'

	command=exe+' n1=%s pick=%s step=%s last=%s d1=%s fin=%s fout=%s'%(n1,pick,step,last,d1,fin,tmp)
	cmd(command)
	from pylab import load
	data=load(tmp)
	from os import remove
	remove(tmp)
	return data

def TracePickCmplx(n1,fin,pick,step=1,last=None,d1=1):
	return TracePick(n1,fin,pick,step,last,d1,type='c')

def TracePickDCmplx(n1,fin,pick,step=1,last=None,d1=1):
	return TracePick(n1,fin,pick,step,last,d1,type='z')


def guess_n1(fin,esize=4,min=50,max=None):
	from os.path import getsize
	nelem=getsize(fin)/esize
	if not max: max=nelem/min
	print min,max

	factors=primefactors(nelem)
	guess=[]
	for n in range(1,len(factors)+1):
		for comb in xuniqueCombinations(factors,n):
			n1=1
			for k in comb:
				n1*=k
			guess.append(n1)
	from sets import Set
	st=Set(guess)
	guess=[]
	for i in st:
		guess.append(i)
	guess.sort()
	print guess

	listn1=[]
	for n1 in guess:
		n2=nelem/n1
		st=Set([n1,n2])
		if min<=n1 and n1<=max and min<=n2 and n2<=max:
			listn1.append(n1-1)
	print listn1
	from numpy import fromfile,float32
	from numpy.fft.fftpack import fft
	arr=fromfile(fin)
	ft=fft(arr[:32768]) # 2**15
	guess=[]
	for n1,val in zip(listn1,ft[listn1]):
		guess.append((abs(val),n1+1))
	guess.sort()
	guess.reverse()
	for i in guess:
		print i[1]


def xuniqueCombinations(items, n):
	if n==0: yield []
	else:
		for i in xrange(len(items)-n+1):
			for cc in xuniqueCombinations(items[i+1:],n-1):
				yield [items[i]]+cc


def primefactors(x):
	"""find prime factors of a number"""
	factorlist=[]
	loop=2
	while loop<=x:
		if x%loop==0:
			x/=loop
			factorlist.append(loop)
		else:
			loop+=1
	return factorlist
