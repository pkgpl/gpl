## don't touch below unless you know what you are doing

from gpl.compiler import *
from SCons.Script import *
from gpl.utils import Quit
import os

## important!! set GPLROOT environment variable
def get_env(name):
	try:
		val=os.environ[name]
	except KeyError:
		Quit("please set %s environment variable first"%name)
	if not os.path.exists(val):
		Quit("please set %s environment variable properly, current one: "%name + val)
	return val, os.path.join(val,'include'), os.path.join(val,'lib')

gplroot,gplincdir,gpllibdir=get_env("GPLROOT")

## utility function
def Run(name,command,help=''):
        Help("\t%s:\t%s\n"%(name,help))
        if name in COMMAND_LINE_TARGETS and command:
                Exit(Execute(command))

## Environments
DefaultEnvironment(ENV=os.environ,
		F90=f90,F90FLAGS=fflags,LINK=f90,
		F77=f90,F77FLAGS=fflags,
		FORTRAN=f90,FORTRANFLAGS=fflags,
		CC=cc,CXX=cxx,
		CFLAGS="-D_FILE_OFFSET_BITS=64")

basicEnv=Environment(ENV=os.environ,
		F90=f90,F90FLAGS=fflags,LINK=f90,
		F77=f90,F77FLAGS=fflags,
		FORTRAN=f90,FORTRANFLAGS=fflags,
		CC=cc,CXX=cxx,
		CFLAGS="-D_FILE_OFFSET_BITS=64")

gpl=basicEnv.Clone(F90PATH=gplincdir,F77PATH=gplincdir,LIBPATH=gpllibdir)

# Libraries
libgpl      =gpllibdir+'/libgpl.a'

## gpl programs
# polyfc
bld=Builder(action='python %s $SOURCE > $TARGET'%(os.path.join(gplroot,'script','polyfc.py')))
gpl.Append(BUILDERS={'Polyfc':bld})

#gplBpad
bld=Builder(action='gplBpad n1=$n1 n2=$n2 l=$l r=$r t=$t b=$b fin=$SOURCE fout=$TARGET')
gpl.Append(BUILDERS={'Bpad':bld})

#gplBcut
bld=Builder(action='gplBcut n1=$n1 n2=$n2 type=$type l=$l r=$r t=$t b=$b fin=$SOURCE fout=$TARGET')
gpl.Append(BUILDERS={'Bcut':bld})

#gplTracePick
bld=Builder(action='gplTracePick n1=$n1 n2=$n2 d1=$d1 type=$type pick=$pick last=$last step=$step fin=$SOURCE fout=$TARGET')
gpl.Append(BUILDERS={'TracePick':bld})

#gplHTracePick
bld=Builder(action='gplHTracePick n1=$n1 n2=$n2 d2=$d2 type=$type pick=$pick last=$last step=$step fin=$SOURCE fout=$TARGET')
gpl.Append(BUILDERS={'HTracePick':bld})

