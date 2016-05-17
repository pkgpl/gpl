#!/usr/bin/python
#
# Program :
# Date :
from gpl.py.autodoc_kernel import *
import sys

Comment='!'
Space=' '*4
DocStart={'general':'!gdoc',
	'routine':'!doc'}
DocContentsStart=[Comment,
		'subroutine',
		'function',
		'integer',
		'real',
		'complex',
		'logical',
		'character',
		'type']
DocContentsMatch={'general':[r'^\s*%s'%Comment],
		'routine':[r'^\s*%s'% i for i in DocContentsStart]}

Indent1=' '*4
Indent2=' '*8

class GeneralTextObject(BaseGeneralTextObject):

	def parse(self,list):
		ModuleName=""
		for line in list:
			mt=re.search(r'^\s*!\s*name:\s*(.+)',line)
			if mt:
				ModuleName=mt.group(1)
				idx='.. _module_%s:'%re.sub(r'\s','_',ModuleName)
				self.help.append('\n%s\n\n%s\n%s\n'%(idx,ModuleName,'='*len(ModuleName)))
				self.env['moduleName']=ModuleName
			else:
				self.help.append(strip_to_comment(line))	

	def to_sphinx(self):
		return ''.join(self.help)

def strip_comment(text):
	if re.match(r'^\s*!\s*$',text): return '\n'
	comment=r'^\s*!\s*'
	return re.sub(r'^\s*','',re.sub(comment,'',text))

def strip_to_comment(text):
	if re.match(r'^\s*!\s*$',text): return '\n'
	comment=r'^\s*!'
	return re.sub(comment,'',text)

def type_conv(type):
	if type=='integer': return 'int'
	if type=='real': return 'float'
	if type=='complex': return 'cmplx'
	if type.startswith('character'): return 'str'
	if type=='logical': return 'bool'

	if re.match(r'^\s*type',type):
		return re.search(r'^\s*type\((\w+)\)',type).group(1)

	if type=='integer(kind=2)': return 'int2'
	if type=='integer(kind=4)': return 'int4'
	if type=='integer(kind=8)': return 'int8'
	if type=='real(kind=4)' or type=='real*4' : return 'float'
	if type=='real(kind=8)' or type=='real*8' : return 'double'
	if type=='complex(kind=4)' or type=='complex*8'  : return 'cmplx'
	if type=='complex(kind=8)' or type=='complex*16' : return 'dcmplx'
	return type


class ArgumentObject(BaseArgument):

	def parse(self,string):
		if re.match(r'^\s*!\s*in',string) or re.match(r'^\s*!\s*out',string):
			self.parse_generic(string)
		else:
			self.parse_declaration(string)
		return self

	def parse_generic(self,string):
		list=strip_comment(string).split()
		self.intent=list[0]
		self.type=list[1]
		self.name=list[2]
		self.desc=' '.join(list[3:])

	def parse_declaration(self,string):
		# type
		self.type=string.split(',')[0].lstrip()
		# intent
		found=re.search(r'intent\s*\(\s*(\w+)\s*\)',string)
		if found:
			self.intent=found.group(1)
		else:
			self.intent='none'
		# variable name
		found=re.search(r'::\s*(\w+)',string)
		if found:
			self.name=found.group(1)
		else:
			self.name='none'
		# description
		if '!' in string:
			self.desc=string.split('!')[1].strip()
		else:
			self.desc=''
		if 'optional' in string:
			self.optional=True
		#print 'type=',self.type
		#print 'intent=',self.intent
		#print 'name=',self.name
		#print 'desc=',self.desc

#	def to_sphinx(self):
#		text="%s:param %s: %s\n%s:type %s: %s, %s\n"%(Space,self.name,self.desc,Space,self.name,self.intent,type_conv(self.type))
#		return text

	def to_sphinx(self):
		if self.optional :
			opt=", *optional*"
		else:
			opt=''
		decl="(*%s*, *%s*"%(type_conv(self.type),self.intent.upper())+opt+")"
		text="\n%s%s\n%s%s  %s\n"%(Indent1,self.name,Indent2,decl,self.desc)
		return text

	
class RoutineObject(BaseRoutineObject):

	def parse(self,list):
		def get_name(text):
			found=re.search(r'subroutine\s*(\w+)',text)
			if found:
				return found.group(1)
			found=re.search(r'call\s*(\w+)',text)
			if found:
				return found.group(1)
			found=re.search(r'function\s*(\w+)',text)
			if found:
				return found.group(1)
			return text.split(' ')[0]

#		def printable_prototype(text):
#			if 'subroutine' in text:
#				return re.sub('^\s*subroutine','call',text)
#			if 'call' in text:
#				return text
#			if 'function' in text:
#				list=text.split()
#				out=type_conv(list[0])+' '.join(list[1:])
#				if not out.endswith('\n'):
#					out+='\n'
#				if re.search(r'\s*result.*$',out):
#					out=re.sub(r'\s*result.*$','\n',out)
#				if out.startswith('type'):
#					return re.sub(r'type\s*\((\w+)\)\s*function',r'\1',out)
#				else:
#					return re.sub(r'\s*function','',out)
#			return text

                def printable_prototype(Text):
			Out=''
			for text in Text.split('|'):
				if 'subroutine' in text or 'call' in text:
					head="call"
				elif 'function' in text:
					if text.startswith('type'):
						head=re.search(r'type\s*\((\w+)\)',text).group(1)
					else:
						head=text.strip().split(' ')[0]
					if re.search(r'\s*result.*$',text):
						text=re.sub(r'\s*result.*$','',text)
				else:
					head=text.strip().split(' ')[0]
				list=text.split("(")
				if len(re.findall(r"\(",text))==1: # ex. logical func abs(arg)
					name=list[0].split(' ')[-1]
					args=list[1].split(',')
				else: # ex. type(ff) func abs(arg)
					name=list[1].split(' ')[-1]
					args=list[2].split(',')
				if len(args)==1:
					arg=re.sub(r"\)\s*",'',args[0]).strip()
					if len(arg.strip())==0: # no arg
						printargs=''
					else:
						printargs="*%s*"%(arg)
				else:
					printargs=''
					for arg in args[:-1]:
						printargs+="*%s*, "%arg.strip()
					printargs+="*%s*"%(re.sub(r"\)\s*",'',args[-1]).strip())
				out="\n``%s`` **%s** ( %s )\n"%(head,name,printargs)
				Out+=out
			return Out


		# doctype
		if re.match(r'^\s*!',list[0]):
			self.doctype='general' # general help text
		else:
			self.doctype='auto' # auto-extract from declaration
		self.prototype=strip_comment(list[0])
		# name
		self.name=get_name(self.prototype)
		# prototype
		self.prototype=printable_prototype(self.prototype)
		# get routine description - help
		n=1
		for line in list[1:]:
			# find blank line - separator
			if self.doctype=='general' and self.is_blank(line):
				break
			if self.doctype=='auto' and not re.match(r'^\s*!',line):
				break
			self.help.append(strip_comment(line.strip()))
			n+=1
		# arguments
		if self.doctype=='general':
			for line in list[n+1:]:
				# find blank line - separator
				if self.is_blank(line):
					break
				try:
					argname=strip_comment(line).split()[2]
					a=ArgumentObject()
					self.args[argname]=a.parse(line)
				except:
					print line
					sys.exit(1)
		else: #auto
			for line in list[n:]:
				if 'intent' in line:
					arg=ArgumentObject()
					arg=arg.parse(line)
					self.args[arg.name]=arg

	def is_blank(self,line):
		if re.match(r'^\s*!\s*$',line) or re.match(r'^\s*$',line):
			return True
		else:
			return False

#	def to_sphinx(self):
#		text=""
#		text+=".. cfunction:: %s\n"%self.prototype
#		text+="%s%s\n"%(Space,self.help[0])
#		if len(self.help)>1:
#			for help in self.help[1:]:
#				text+="%s%s"%(Space,help)
#			text+="\n"
#		for v in self.args.itervalues():
#			text+="%s"%(v.to_sphinx())
#		return text

	def to_sphinx(self):
		if self.env.has_key('moduleName'):
			text="\n----\n\n.. index::\n%spair: %s; %s\n"%(Indent1,self.env['moduleName'],self.name)
		else:
			text="\n----\n\n.. index:: %s\n"%self.name
		text+="%s\n"%self.prototype
		text+="%s%s\n"%(Indent1,self.help[0])
		for v in self.args.itervalues():
			text+="%s"%(v.to_sphinx())
		if len(self.help)>1:
			text+='\n'
			for help in self.help[1:]:
				text+="%s%s\n"%(Indent1,help)
		return text

