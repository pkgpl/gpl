#!/usr/bin/python
#
# Program :
# Date :

import sys, os.path
exefile=os.path.basename(sys.argv[0])

help="""
Gpl column normalizer
	normalize a column of ascii data
Usage :
	ex) %s col= sep= < fin > fout

Required parameters :
	fin	: input file
	col=1	: col. number you want to normalize

Optional parameters :
	sep=' '	: separation character between columns (\\t for tab)
	fout	: output file

Examples :
	$cat file
	1 1.0
	2 -2.0
	3 4.0

	$%s col=2 < file
	1 0.25
	2 -0.5 
	3 1.0
"""%(exefile,exefile)

if len(sys.argv) < 2:
	print help
	sys.exit(1)

def getpar(list,name,default):
	"""get a parameter value from a list by using a parameter name"""
	parname=name+'='
	L=len(parname)
	for item in list:
		if item[:L] == parname:
			val=item[L:]
			list.remove(item)
			return val
	return default

col=getpar(sys.argv,'col','1')
col=int(col)-1
sep=getpar(sys.argv,'sep',' ')
if sep == r'\t': sep='\t'

def maxabs(list):
	"""find max. abs. value in an 1-d float list"""
	import math
	mx=0.
	for item in list:
		if math.fabs(item) > mx:
			mx=math.fabs(item)
	return mx

def normal(list):
	"""normalize an 1-d float list"""
	mx=maxabs(list)
	return [k/mx for k in list]

f=sys.stdin

nv=[]
data=[]
for line in f:
	tmp=line.split()
	nv.append(float(tmp[col]))
	data.append(tmp)

n=normal(nv)
i=0
for item in data:
	item[col]=str(n[i])
	i+=1
	print sep.join(item)

