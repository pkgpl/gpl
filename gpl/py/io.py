#!/usr/bin/python
#
# Program :
# Date :

from numpy import *

### binary file input/output
# from_stdin
# from_bin
# to_bin

def from_stdin(n1=0,dtype=float32):
	"""read an array from stdin, return a numpy array"""
	from sys import stdin
	s=stdin.read()
	arr=fromstring(s,dtype=dtype)
	try:
		arr.shape=-1,n1
	except:
		pass
	return arr

def from_bin(fin,n1=0,dtype=float32):
	"""read an array from a binary file, return a numpy array"""
	s=file(fin,'rb').read()
	arr=fromstring(s,dtype=dtype)
	try:
		arr.shape=-1,n1
	except:
		pass
	return arr

def to_bin(fout,arr):
	"""write an array to a binary file"""
	s=arr.tostring()
	file(fout,'wb').write(s)

### ascii file input/output
# from_asc
# to_asc

def from_asc(fin,sep=' '):
	"""read an array from an ascii file, return a numpy array"""
	from matplotlib.mlab import load
	return load(fin,delimiter=sep)

def to_asc(fout,arr,sep):
	"""write an array to an ascii file"""
	f=file(fout,'w')
	for row in arr:
		wrt=''
		for col in row:
			wrt+=str(col)+sep
		f.write(wrt[:-1]+'\n')

### command line input
# argdict
# from_param

def argdict():
	"""return a dictionary composed by sys.argv "pname=value"

	Usage:
		ad=argdict()
		default=0
		a=int(ad.get('a',default))
	"""
	import sys
	dict={}
	for item in sys.argv[1:]:
		pair=item.split('=')
		dict[pair[0]]=pair[1]
	return dict

def from_param(pname,default=''):
	"""read parameter named 'pname' from argv

	pname=value
	type of the return value == type(default value)"""
	ad=argdict()
	return type(default)(ad.get(pname,str(default)))

