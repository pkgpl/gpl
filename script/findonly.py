#!/usr/bin/python
#
# Program : find words used only once in a source code - maybe a typo
# Date : 05 May 2009
# plusha@gpl.snu.ac.kr

from string import punctuation, whitespace
import re
punctuation=punctuation.replace('_','')

def delcomments(data,comment):
	"""Remove whole line comments from a list"""
	filtered=[]
	for line in data:
		if not re.match(r'^\s*'+comment,line):
			filtered.append(line)
	return filtered

def delinlinecomments(data,comment):
	"""Remove inline comments from a list"""
	filtered=[]
	for line in data:
		if re.sub(comment+r'.*','',line):
			filtered.append(re.sub(comment+r'.*','',line))
		else:
			filtered.append(line)
	return filtered

def nonce(data,reserved):
	"""Retruns words used only once in a list. 'Beginning python visualization' p.176"""
	data=''.join(data)
	d,result=dict(),[]
	for word in re.split('['+punctuation+whitespace+']',data):
		d[word.lower()]=d.get(word.lower(),0)+1
	for word, occur in d.iteritems():
		if occur==1:
			# remove numbers
			num=False
			num_regexp=[r'^\d+$',r'^\d*d\d*$',r'^\d*e\d*$',r'^\d*g\d*$']
			for regexp in num_regexp:
				if re.match(regexp,word):
					num=True
					pass
			if not num: result.append(word)
	# remove reserved words
	for item in reserved:
		try:
			result.remove(item)
		except:
			pass
	return result

###
if __name__=="__main__":
	import sys
	if len(sys.argv)==1:
		help="""
Print words used only once in a file
Usage :
	findonly.py filename

Required parameters :
	filename
"""
		print help
		sys.exit(1)
	filename=sys.argv[1]
	import os.path
	if not os.path.exists(filename):
		print 'file not exists'
		sys.exit(1)
	# reserved words for fortran source code
	if filename.endswith('.f90') or filename.endswith('.f'):
		reserved="""implicit none include mpif
		integer real logical complex character len kind
		intent in out inout
		selected_real_kind selected_integer_kind
		"""+"""
		all any true false
		gt ge lt le eq or and
		"""+"""
		case select if else elseif endif do enddo cycle exit continue stop
		interface optional present recursive type
		common goto pause equivalence
		"""+"""
		allocate deallocate allocated
		program function module subroutine contains end call
		"""+"""
		dble sngl aimag dimag abs cabs 
		sin asin cos acos tan atan exp cexp dlog cdlog
		min max minloc maxloc minval maxval lbound ubound shape reshape
		cpu_time inquire
		"""+"""
		mpi_init mpi_finalize mpi_comm_size mpi_comm_rank
		"""
	else:
		reserved=""
	reserved=reserved.split()

	data=open(filename,'rt').readlines()
	data=delcomments(data,'!')
	data=delinlinecomments(data,'!')
	data=delcomments(data,'c')
	result=nonce(data,reserved)
	result.sort()
	for item in result:
		print item
