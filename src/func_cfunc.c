#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <time.h>

void c_gethostname_(char *Host,size_t size,int len)
{
	//if(gethostname(Host,size)==-1) perror("gethostname");
	if(gethostname(Host,size)==-1) Host="";
	//printf("%d\n",gethostname(Host,size));
	len=strlen(Host);
}

void c_getenv_(const char *Name,char *Var,int len)
{
	strcpy(Var,getenv(Name));
	len=strlen(Var);
}

void c_getlogin_(char User[],int len)
{
	strcpy(User,getlogin());
	len=strlen(User);
}

void c_ctime_(char *Time,int len)
{
	time_t t=time(NULL);
	if(ctime_r(&t,Time)==Time){
		len=strlen(Time);
	       	return;
	}
	perror("ctime");
}

void c_getpwd_(char *Pwd,int *Size,int len)
{
	int size=*Size;
	if(getcwd(Pwd,size)==Pwd){
		len=strlen(Pwd);
		return;
	}
	perror("getpwd");
}

off_t c_filesize_(const char *filename)
{
	struct stat buf;
	if(stat(filename,&buf)==-1){
		perror("stat");
		return -1;
	}
	return (off_t) buf.st_size;
}

int c_getpid_(void)
{
	pid_t id=getpid();
	return (int) id;
}

int c_getgid_(void)
{
	gid_t id=getgid();
	return (int) id;
}

int c_getuid_(void)
{
	uid_t id=getuid();
	return (int) id;
}


int c_stdin_readable_(void)
//returns 1 if there is an input in stdin
{
	int c;
	if (isatty(fileno(stdin))) {
		return 0;
	}
	c = fgetc(stdin);
	if (EOF == c) {
		return 0;
	}
	ungetc(c,stdin);
	return 1;
}

void c_stdin_to_file_(const char *Fname)
{
	FILE *fout=fopen(Fname,"w");
	char ch=fgetc(stdin);
	while ( EOF != ch) {
		fputc(ch,fout);
		ch=fgetc(stdin);
	}
	fclose(fout);
}

int c_stdin_isatty_(void)
{// return 1 if stdin is a tty
 // return 0 if stdin is not a tty
	int fd=fileno(stdin);
	if( isatty(fd) ){
		return 1;
	}else{
		return 0;
	}
}

int c_stdout_isatty_(void)
{// return 1 if stdout is a tty
 // return 0 if stdout is not a tty
	int fd=fileno(stdout);
	if( isatty(fd) ){
		return 1;
	}else{
		return 0;
	}
}


#include <dirent.h>
int getfilename (FILE* fp, char *filename)
/* Finds filename of an open file from the file descriptor.
 * Unix-specific and probably non-portable. */
/*
return values
 1: success
 0: fail
-1: error - cannot open directory
-2: error - fstat error
*/
{
	DIR* dir; 
	struct stat buf; 
	struct dirent *dirp;
	int success;

	dir = opendir(".");
	if (NULL == dir) return -1;

	if(0 > fstat(fileno(fp),&buf)) return -2;
	success = 0;

	while (NULL != (dirp = readdir(dir))) {
		if (dirp->d_ino == buf.st_ino) { /* non-portable */
			strcpy(filename,dirp->d_name);
			//printf("filename='%s'\n",filename);
			success = 1;
			break;
		}    
	}    
	closedir(dir);
	return success;
}

void c_getfilename_stdin_( char *Filename , int *Stat, int len)
{
	*Stat=getfilename(stdin, Filename);
//	printf("stdin='%s'\n",Filename);
	len=(int) strlen(Filename);
}

void c_getfilename_stdout_( char *Filename, int *Stat, int len)
{
	*Stat=getfilename(stdout, Filename);
//	printf("stdout='%s'\n",Filename);
	len=(int) strlen(Filename);
}

#ifndef _LARGEFILE_SOURCE
#define _LARGEFILE_SOURCE
#endif
int is_pipe(FILE* fp)
{
//	if(-1 == ftello(fp)){
	if(-1 == ftell(fp)){
		return 1; // a pipe
	}else{
		return 0; // not a pipe
	}
}

int c_stdin_isapipe_(void)
{
	return is_pipe(stdin);
}

int c_stdout_isapipe_(void)
{
	return is_pipe(stdout);
}
