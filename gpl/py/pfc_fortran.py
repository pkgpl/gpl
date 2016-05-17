#!/usr/bin/python
#
# Program :
# Date :

import re
typehash={
		'i':{'name':'i', 'esize':'4',  'type':'integer',	'ctype':'int',	'kind':'(kind=4)'},
		'f':{'name':'f', 'esize':'4',  'type':'real',		'ctype':'float','kind':'(kind=4)'},
		'd':{'name':'d', 'esize':'8',  'type':'real(kind=8)',	'ctype':'double','kind':'(kind=8)'},
		'c':{'name':'c', 'esize':'8',  'type':'complex',	'ctype':'cmplx','kind':'(kind=4)'},
		'z':{'name':'z', 'esize':'16', 'type':'complex(kind=8)','ctype':'dcmplx', 'kind':'(kind=8)'},
		'b':{'name':'b', 'esize':'4',  'type':'logical',	'ctype':'boolean','kind':'(kind=4)'},
		's':{'name':'s', 'esize':'1',  'type':'character(len=*)','ctype':'string',	'kind':'(len=*)'}
}

class Handler: # fortran handler
	def __init__(self):
		self.template_start = r'\s*!@template'
		self.template_end   = r'\s*!@end'
		self.interface_start= r'\s*!@interface'
		self.interface_add  = r'\s*!@add_interface'
		self.interface={}
		self.space1=' '*4
		self.space2=' '*8
	
	def add_to_interface(self,generic_name,funcname):
		if self.interface.has_key(generic_name):
			self.interface[generic_name].append(funcname)
		else:
			self.interface[generic_name]=[funcname]
	
	def parse_template_line(self,line):
		return line.split()[1:3]

	def preprocess(self,line):
		if re.match(self.interface_add,line):
			generic_name,funcname=line.split()[1:3]
			self.add_to_interface(generic_name,funcname)
			return '\n'
		return line

	def handle(self,line,generic_name,type):
		# substitution
		for key in typehash[type].keys():
			id=r'<%s>'%key
			val=typehash[type][key]
			line=re.sub(id,val,line)

		# for post process - interface
		routine=re.search('function\s+(\w+)',line)
		if not routine: routine=re.match('^\s*subroutine\s+(\w+)',line)
		if routine:
			funcname=routine.group(1)
			self.add_to_interface(generic_name,funcname)
		return line

	def postprocess(self,line):
		if re.match(self.interface_start,line):
			name=line.split()[1]
			output=[]
			output.append(self.space1+'interface '+name)
			for funcname in self.interface[name]:
				output.append(self.space2+'module procedure '+funcname)
			output.append(self.space1+'end interface '+name+'\n\n')
			line='\n'.join(output)
		if re.match(self.template_start,line) or re.match(self.template_end,line):
			return '\n'
		return line
	
