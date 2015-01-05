#!/usr/bin/python
import os,sys,commands

USER=commands.getstatusoutput('whoami')[1]

list=commands.getstatusoutput('ps -ewf | grep %s'%USER)[1]

for line in list.split('\n'):
	data=line.split()
	user,pid,ppid,prog=data[0],data[1],data[2],data[7]
	if user==USER and ppid=='1':
		print pid,prog
		os.system('kill -9 %s'%pid)
os.system('ps -ewf |grep %s'%USER)
