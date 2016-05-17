#!/usr/bin/python
#
# Program :
# Date :
import re

class BaseArgument:
# argument object - variable declaration
	name=""
	intent=""
	type=""
	desc=""
	optional=False
	env={}

	def __init__(self,Env={}):
		self.name=""
		self.intent=""
		self.type=""
		self.desc=""
		self.optional=False
		self.env=Env

	def parse(self,string):
	# parse a string and save name, intent, type, one-line description
		pass
	def to_sphinx(self):
	# return sphinx reST
		pass

class BaseRoutineObject:
# routine object - function or subroutine
	name=""
	doctype=""
	prototype=""
	help=[]
	args={}
	env={}

	def __init__(self,Env={}):
		self.name=""
		self.doctype=""
		self.prototype=""
		self.help=[]
		self.args={}
		self.env=Env

	def parse(self,list):
	# parse a list of strings and save doctype, prototype, help, arguments
		pass
	def to_sphinx(self):
	# return sphinx reST
		pass

class BaseGeneralTextObject:
# general help
	help=[]
	env={}

	def __init__(self,Env={}):
		self.help=[]
		self.env=Env

	def parse(self,list):
		pass

	def to_sphinx(self):
		pass
