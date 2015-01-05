#!/usr/bin/python
#
# Program :
# Date :

### machine specific compiler/libraries
import os
home=os.environ["HOME"]

# fortran compiler
f90='ifort'
fflags='-O2 -assume byterecl -warn all -m64'
#f90='gfortran-mp-4.8'
#fflags='-O2 -Wall'

fc=f90

# mpi fortran compiler
#mpif90='mpif90-mp'
mpif90='mpif90'

# c compiler
#cc='gcc'
#cxx='g++'
#cc='icc'
#cxx='icpc'
cflags='-O2'

cc='gcc-mp-4.8'
cxx='g++-mp-4.8'

### libraries
