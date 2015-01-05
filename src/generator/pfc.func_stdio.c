#include <stdio.h>
#include <stdlib.h>
#include <complex.h>

// stdin
//@template ifdcz
void c_stdin_fread_<name>_(<type> *Arr, int *Nelem, int *Nread)
{
	size_t nread;
	nread=fread(Arr,sizeof(<type>),*Nelem,stdin);
	*Nread=nread;
}
//@end

// stdout
//@template ifdcz
void c_stdout_fwrite_<name>_(<type> *Arr, int *Nelem)
{
	size_t nwrite;
	nwrite=fwrite(Arr,sizeof(<type>),*Nelem,stdout);
	if( nwrite != *Nelem)
	{
		fprintf(stderr,"nwrite=%d\n",nwrite);
		exit(1);
	}
}
//@end

