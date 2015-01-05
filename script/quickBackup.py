#!/usr/bin/python
#
# Program : gnu Quick backup
# Date : 02 Jan 2008
# plusha@gpl.snu.ac.kr

bakdirname='./bak'
logfile=bakdirname+'/quickBackup.log'

import sys,os.path
import commands
exefile=os.path.basename(sys.argv[0])
argv=sys.argv[1:]

def findflag(list,str):
# seek str in the list
	if list.count(str):
		list.remove(str)
		return True
	return False

def mkdir(dirname):
# make directory if not exists
	if not os.path.exists(dirname):
		commands.getstatusoutput('mkdir %s'%dirname)

def get_new_filename(filename,TYPE,iter):
	basename,extension=os.path.splitext(filename)
	number='bak%02d'%iter
	if TYPE == 'h': newfilename=number+'.'+basename+extension
	if TYPE == 'b': newfilename=basename+'.'+number+extension
	if TYPE == 't': newfilename=basename+extension+'.'+number
	return newfilename

def get_versioned_filename(filename,TYPE,bakdirname):
# get filename not exist
	for iter in range(1,100):
		newfilename=bakdirname+'/'+get_new_filename(filename,TYPE,iter)
		latest=bakdirname+'/'+get_new_filename(filename,TYPE,iter-1)
		if not os.path.exists(newfilename):
			return newfilename,latest
	print '** CANNOT make backup file'
	print '** if you want to make more than 100 backup files, change this script'
	print '** line # 29 : 02->03'
	print '** line # 37 : 100->1000'
	sys.exit(1)

def addlog(orgfile,backupfile,logfile,flag_comment,comment):
	import time
	text="from %s \tto %s \tat %s\n"%(orgfile,backupfile,time.asctime())
	if flag_comment:
		lines=comment.split('\n')
		for line in lines:
			text+='\t'+line+'\n'
	if os.path.exists(logfile):
		# read
		flog=open(logfile,'r')
		logs=flog.read()
		flog.close()
		# append
		logs+=text
		# write
		flog=open(logfile,'w')
		flog.write(logs)
		flog.close()
	else:
		# write
		flog=open(logfile,'w')
		flog.write(text)
		flog.close()

def checkdifference(orgfile,latest):
	return commands.getstatusoutput('diff %s %s'%(orgfile,latest))[0]

def quickbak(argv):
	TYPE='b'
	flag_comment=False
	if findflag(argv,'-h') : TYPE='h'
	if findflag(argv,'-b') : TYPE='b'
	if findflag(argv,'-t') : TYPE='t'
	if findflag(argv,'-c') : flag_comment=True
	mkdir(bakdirname)
	for orgfile in argv:
		if os.path.exists(orgfile):
			# check difference
			backupfile,latest=get_versioned_filename(orgfile,TYPE,bakdirname)
			if not checkdifference(orgfile,latest):
				print '  no change from the latest backup file, %s'%latest
				continue
			# get comment
			comment=''
			if flag_comment:
				print ' Please input comment (end: CR & Ctrl+D)'
				comment=sys.stdin.read()
			# backup
			print '  original file: %s'%orgfile
			commands.getstatusoutput('cp %s %s'%(orgfile,backupfile))
			print '    backup file: %s'%backupfile
			addlog(orgfile,backupfile,logfile,flag_comment,comment)
		else:
			print '** CANNOT find '+orgfile
	return

###
if __name__=="__main__":
	if len(argv)==0:
		help="""
Gpl Quick Backup
    make '%s' directory and backup files
Usage :
	%s [-h/-b/-t] filename.extension

Required parameters :
	filename

Optional parameters : 
	-h   : place backup number at head
	       ( bak01.filename.extension )
	-b   : place backup number between filename and extension
	       ( filename.bak01.extension )
	-t   : place backup number at tail
	       ( filename.extension.bak01 )
	** default : -b
	-c   : add comment to the log file ( ./bak/quickBackup.log )

Examples :
	%s file1.f90 file2.f
	(edit file1.f90)
	%s file1.f90
	ls ./bak
	-> file1.bak01.f90  file1.bak02.f90  file2.bak01.f  quickBackup.log
"""%(bakdirname,exefile,exefile,exefile)
		print help
		sys.exit(1)
	quickbak(argv)
