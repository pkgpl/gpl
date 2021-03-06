#!/usr/bin/python
#
# Program : polymorphic fortran & c
# Date :

import sys,re

class Block: # template block
	def __init__(self,generic_name,types,handler):
		self.generic_name=generic_name
		self.types=types
		self.body=[]
		self.handler=handler
	
	def append(self,line):
		self.body.append(line)
	
	def expand(self):
		output=[]
		for type in self.types:
			for line in self.body:
				output.append(self.handler.handle(line,self.generic_name,type))
			output.append('')
		return output

class Processor:
	def __init__(self,text,handler):
		self.body=text
		self.in_block=False
		self.handler=handler

		self.pre_text=[]
		self.pro_text=[]
		self.post_text=[]
	
	def preprocess(self):
		for line in self.body:
			self.pre_text.append(self.handler.preprocess(line))
	
	def process(self):
		for line in self.pre_text:
			if re.match(self.handler.template_start,line):
				self.in_block=True
				generic_name,types=self.handler.parse_template_line(line)
				block=Block(generic_name,types,self.handler)
			if re.match(self.handler.template_end,line):
				self.in_block=False
				for bline in block.expand():
					self.pro_text.append(bline)
			if self.in_block:
				block.append(line)
			else:
				self.pro_text.append(line)

	def postprocess(self):
		for line in self.pro_text:
			self.post_text.append(self.handler.postprocess(line))

	def run(self):
		self.preprocess()
		self.process()
		self.postprocess()

# main
if len(sys.argv)==1:
	print """Polymorphic fortran & c

input polyf fortran or c file

*Fortran
!@interface abc

!@template abc ifdczbs
    subroutine abc_<name>(def)
    <type> :: def
    ...
    end subroutine
!@end

*C
//@template ifdczbs
void abc_<name>(<type> def)
{
	...
}
//@end

*name: fortran type 	/ c type 	/ fotran kind	/ esize

    i: integer 		/ int 		/ (kind=4)	/ 4
    f: real		/ float		/ (kind=4)	/ 4
    d: real(kind=8)	/ double	/ (kind=8)	/ 8
    c: complex		/ float complex	/ (kind=4)	/ 8
    z: complex(kind=8)	/ double complex/ (kind=8)	/ 16
    b: logical		/		/ (kind=4)	/ 4
    s: character(len=*)	/ char 		/ (len=*)	/ 1
"""
	sys.exit(1)

fin=sys.argv[1]
# import handler
if fin.endswith('.f90') or fin.endswith('.f'):
	from gpl.py.pfc_fortran import Handler
	comment='!'
elif fin.endswith('.c'):
	from gpl.py.pfc_c import Handler
	comment='//'
else:
	print 'unknown format!'
	sys.exit(1)

# read source code
f=open(fin)
text=f.readlines()
f.close()

# process
handler=Handler()
processor=Processor(text,handler)
processor.run()

# output
import time
info="""
%s This file was generated from %s by Polyfc at %s.
%s Do not edit this file directly.
"""%(comment, fin, time.asctime(), comment)

print info
for line in processor.post_text:
	print line,
