#!/usr/bin/python
#
# Program : su launcher, parse rsf file and pass parameters to an su program
# Date : 31 Jul 2009

import sys,re,os

class rsf_par: # rsf 2 su
	def __init__(self,rsf_file):
		self.text=rsf_file
		self.parse()

	def from_par_(self,key,match):
		mt=re.findall(key+'='+match,self.text)
		if mt:
			return mt[-1]

	def from_par(self,key,match):
		val=self.from_par_(key,match)
		if val:
			return key+'='+val
		else:
			return ''

	def from_par_in(self,match):
		val=self.from_par_('in',match)
		if val:
			if val.startswith('"') or val.startswith("'"):
				val=val[1:-1]
			if not os.path.exists(val):
				print 'file %s not exists!'%(val)
				sys.exit(1)
			return '< '+val
		else:
			print 'cannot find "in="'
			sys.exit(1)

	def parse(self):
		match_int=r'(\S+)'
		match_float=r'(\S+)'
		match_string=r'(\S+)'

		n1=self.from_par('n1',match_int)
		n2=self.from_par('n2',match_int)
		d1=self.from_par('d1',match_float)
		d2=self.from_par('d2',match_float)
		f1=self.from_par('o1',match_float)
		f2=self.from_par('o2',match_float)
		label1=self.from_par('label1',match_string)
		label2=self.from_par('label2',match_string)

		self.esize=self.from_par('esize',match_int)
		self.data_format=self.from_par('data_format',match_int)

		self.n1,    self.n2    =n1,    n2
		self.d1,    self.d2    =d1,    d2
		self.f1,    self.f2    =f1,    f2
		self.label1,self.label2=label1,label2
		self.parlist=[n1,n2,d1,d2,f1,f2,label1,label2]

		self.file=self.from_par_in(match_string)



class su_par: # su 2 rsf
	def __init__(self,par_file):
		self.text=par_file
		self.parse()

	def from_par_(self,key,match):
		mt=re.findall(key+'='+match,self.text)
		if mt:
			return mt[-1]

	def from_par(self,key,match):
		val=self.from_par_(key,match)
		if val:
			if key[0:1]=='f': key[0:1]='o'
			return key+'='+val
		else:
			return ''

	def parse(self):
		match_int=r'(\S+)'
		match_float=r'(\S+)'
		match_string=r'(\S+)'

		n1=self.from_par('n1',match_int)
		n2=self.from_par('n2',match_int)
		n3=self.from_par('n3',match_int)

		d1=self.from_par('d1',match_float)
		d2=self.from_par('d2',match_float)
		d3=self.from_par('d3',match_float)

		o1=self.from_par('f1',match_float)
		o2=self.from_par('f2',match_float)
		o3=self.from_par('f3',match_float)

		label1=self.from_par('label1',match_string)
		label2=self.from_par('label2',match_string)
		label3=self.from_par('label3',match_string)

		self.n1,    self.n2,    self.n3    =n1,    n2,    n3
		self.d1,    self.d2,    self.d3    =d1,    d2,    d3
		self.o1,    self.o2,    self.o3    =o1,    o2,    o3
		self.label1,self.label2,self.label3=label1,label2,label3
		self.parlist=[n1,n2,n3,d1,d2,d3,o1,o2,o3,label1,label2,label3]

