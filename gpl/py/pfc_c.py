#!/usr/bin/python
#
# Program :
# Date :

import re
typehash={
		'i':{'name':'i', 'type':'int'},
		'f':{'name':'f', 'type':'float'},
		'd':{'name':'d', 'type':'double'},
		'c':{'name':'c', 'type':'float complex'},
		'z':{'name':'z', 'type':'double complex'},
		's':{'name':'s', 'type':'char'}
}

class Handler: # fortran handler
	def __init__(self):
		self.template_start= r'\s*//@template'
		self.template_end  = r'\s*//@end'
	
	def parse_template_line(self,line):
		return '',line.split()[1]

	def preprocess(self,line):
		return line

	def handle(self,line,generic_name,type):
		line=re.sub('<name>',typehash[type]['name'],line)
		line=re.sub('<type>',typehash[type]['type'],line)
		return line

	def postprocess(self,line):
		if re.match(self.template_start,line) or re.match(self.template_end,line):
			return '\n'
		return line
	
