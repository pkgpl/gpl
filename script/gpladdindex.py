#!/usr/bin/python
#
# Program :
# Date :
import sys,os.path
exefile=os.path.basename(sys.argv[0])

help="""
Gpl add index
	add index to an ascii file
Usage :
	ex) %s fs= ds= < fin > fout

Required parameters :
	fin	: input file

Optional parameters :
	fs=0.0	: first index
	ds=1.0	: sampling interval
	sep=' '	: separation character between index and body (\\t for tab)
	** at least one parameter need to be given
	fout	: output file

Examples :
	$cat file
	abc
	bcd
	cde

	$%s fs=1.0 ds=2.0 < file
	1.0 abc
	3.0 bcd
	5.0 cde
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

ds=getpar(sys.argv,'ds','1')
fs=getpar(sys.argv,'fs','0')
ds=float(ds)
fs=float(fs)
sep=getpar(sys.argv,'sep',' ')

f=sys.stdin
i=0
for line in f:
	i+=1
	if sep == '\\t':
		print "%s\t%s"%(fs+(i-1)*ds,line[:-1])
	else:
		print "%s%s%s"%(fs+(i-1)*ds,sep,line[:-1])
