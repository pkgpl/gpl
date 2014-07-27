#!/usr/bin/python
# gnu_quick_plot
# python version, 04OCT2008
import sys,re,os,os.path
exefile=os.path.basename(sys.argv[0])
argv=sys.argv[1:]

def findflag(list,str):
# seek str in the list
	if list.count(str):
		list.remove(str)
		return True
	return False

def findRE(list,regexp):
# seek regext matching in the list
	for item in list:
		m=re.match(regexp,item)
		if m:
			list.remove(item)
			return m.group(1)
	return False

def PrintOrRunGnuplot(printflag,cmd):
	if printflag:
		print cmd
		return 0
	import commands
	tmpfile='tmp_qp.gnu'
	f=open(tmpfile,'w')
	f.write(cmd)
	f.close()
	commands.getstatusoutput('gnuplot -persist %s'%tmpfile)
	commands.getstatusoutput('rm -f %s'%tmpfile)
	return 0

def gnuqp(argv):
	setopt=''
	# file name only (no comma separation), print only (no plot)
	flag_c=findflag(argv,'-c')
	flag_p=findflag(argv,'-p')

	# set grid, log y
	if findflag(argv,'-g'):
		setopt=setopt+'set grid\n'
	if findflag(argv,'-l'):
		setopt=setopt+'set logscale y\n'

	# x, y range
	xrange=findRE(argv,r'-x(\[.+\])+')
	if xrange:
		setopt=setopt+'set xrange %s\n'%xrange
	yrange=findRE(argv,r'-y(\[.+\])+')
	if yrange:
		setopt=setopt+'set yrange %s\n'%yrange

	# all using
	allusing=findRE(argv,r'-u(\d+:\d+)')

	# substitute
	subst=findRE(argv,r'-#(.+)')
        #print 'sub=',subst,argv
	if subst:
		tmpargv=[]
		for item in argv:
			tmpargv.append(re.sub('#',subst,item))
		argv=tmpargv
	subst=findRE(argv,r'-@(.+)')
	if subst:
		tmpargv=[]
		for item in argv:
			tmpargv.append(re.sub('@',subst,item))
		argv=tmpargv

## case1: file name only
	if flag_c:
		cmd='plot '
		for file in argv:
			cmd=cmd+',"%s" w l'%file
		cmd=cmd[:5]+cmd[6:] ## remove the comma before the first fiilename
		PrintOrRunGnuplot(flag_p,setopt+cmd)
		return 0

## case2: plotting commands
	plot=' '.join(argv).split(',')
	cmd='plot '
	# first file
	file1=re.match('\S+',plot[0]).group()

	for line in plot:
		# get filename
		line=line.strip()
		filename=re.match('\S+',line).group()
		if os.path.exists(filename):
			cmd=cmd+',"%s"'%filename
		else:
			cmd=cmd+',"%s"'%file1
		# get column number
		if allusing:
			cmd=cmd+' u %s'%allusing
		else:
			m=re.match(r'.*u\s*(\d+:\d+)',line)
			if m:
				column=m.group(1)
				cmd=cmd+' u %s'%column
		# get line style
		m=re.match(r'.*\s+w\s*(.*)',line)
		if m:
			style=m.group(1)
			cmd=cmd+' w %s'%style
		else:
			cmd=cmd+' w l'

	cmd=cmd[:5]+cmd[6:] ## remove the comma before the first fiilename
	PrintOrRunGnuplot(flag_p,setopt+cmd)
	return 0

if __name__=="__main__":
	if len(argv)==0:
		help="""
GNU Quick Plot
Usage :
	%s filename1 [u 1:2] [w l], filename2 [u 1:2] [w l], filename3 ...

Required parameters :
	filename1
	Empty filename[2,3,...] will be replaced by the filename1

Optional parameters : 
	u 1:2   : columns you want to plot
	w [lp..]: line style- line, point, dot or impulse ..etc (default: w l)

	-p      : do not run gnuplot. just print the gnuplot command
	-c      : no comma seperation 
	          - the arguments are filenames seperated with a blank
		  - use with glob pattern

	-l      : set logscale y
	-g      : set grid

	-x[:1.2] : set xrange [:1.2]
	-y[1:5] : set yrange [1:5]

	-@01	: substitute @ -> 01
	-#02	: substitute # -> 02
	-u1:3	: all file using 1:3

Examples :
	%s -p file1, u 1:3 wp
	-> plot "file1" w l, "file1" u 1:3 w p

	%s -p -c file.00*
	-> plot "file.0010" w l,"file.0020" w l,"file.0030" w l

	%s -p -c file.00@.00# ../file.00@.00# -@02 -#10
	-> plot "file.0002.0010" w l,"../file.0002.0010" w l
"""%(exefile,exefile,exefile,exefile)
		print help
		sys.exit(1)
	gnuqp(argv)
