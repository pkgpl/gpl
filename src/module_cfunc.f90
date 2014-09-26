! Program :
! Author  : wansooha@gmail.com
! Date    :

module gpl_cfunc

    private
    integer,parameter :: MAX_LEN_ENV=512
    integer,parameter :: MAX_LEN_PATH=256
    integer,parameter :: MED_LEN_STR=64

    public:: filesize
    public:: getpwd,gethostname,getlogin
    public:: getenviron,ctime
    public:: getpid,getgid,getuid

    public:: stdin_readable,stdin_to_file
    public:: stdin_isatty,stdout_isatty
    public:: stdin_isapipe,stdout_isapipe
    public:: getfilename_stdin,getfilename_stdout

contains

    integer(kind=8) function filesize(filename)
    character(len=*),intent(in):: filename
    integer(kind=8) c_filesize
    filesize=c_filesize(trim(filename)//char(0))
    end function

    character(len=MAX_LEN_PATH) function getpwd() result(val)
    val=''
    call c_getpwd(val,MAX_LEN_PATH)
    val=val(1:len_trim(val)-1) !! remove trailing "\0"
    end function

    character(len=MED_LEN_STR) function gethostname() result(val)
    val=''
    call c_gethostname(val,MED_LEN_STR)
    val=val(1:len_trim(val)-1)
    end function

    character(len=24) function ctime()
    character(len=26):: tmp
    ctime=''
    call c_ctime(tmp)
    ctime=tmp(1:24) !! cut trailing "\n\0"
    end function

    character(len=MED_LEN_STR) function getlogin() result(val)
    val=''
    call c_getlogin(val)
    val=val(1:len_trim(val)-1)
    end function

    character(len=MAX_LEN_ENV) function getenviron(key) result(val)
    character(len=*),intent(in):: key
    val=''
    call c_getenv(key,val)
    val=val(1:len_trim(val)-1)
    end function

    integer function getpid() result(id)
    integer c_getpid
    id=c_getpid()
    end function

    integer function getgid() result(id)
    integer c_getgid
    id=c_getgid()
    end function

    integer function getuid() result(id)
    integer c_getuid
    id=c_getuid()
    end function

!! stdin/stdout from c functions
  logical function stdin_readable() result(val)
  integer c_stdin_readable
  if( c_stdin_readable() == 1) then
      val=.true.
  else
      val=.false.
  endif
  end function

  subroutine stdin_to_file(fout)
  character(len=*),intent(in):: fout
  call c_stdin_to_file(trim(fout)//char(0))
  end subroutine

!! tty check
    logical function stdin_isatty() result(val)
    integer c_stdin_isatty
    if( c_stdin_isatty() == 1) then
        val=.true.
    else
        val=.false.
    endif
    end function
  
    logical function stdout_isatty() result(val)
    integer c_stdout_isatty
    if( c_stdout_isatty() == 1) then
        val=.true.
    else
        val=.false.
    endif
    end function

!! pipe check - not working yet
!    logical function stdin_isapipe() result(val)
!    integer c_stdin_isapipe,iv
!    iv=c_stdin_isapipe
!    if( iv == 1 ) then
!        val=.true.
!    elseif( iv==0 ) then
!        val=.false.
!    else
!        val=.false.
!        print*,'stdin isapipe error'
!    endif
!    end function
!
!    logical function stdout_isapipe() result(val)
!    integer c_stdout_isapipe,iv
!    iv=c_stdout_isapipe
!    if( iv == 1 ) then
!        val=.true.
!    elseif( iv==0 ) then
!        val=.false.
!    else
!        val=.false.
!        print*,'stdout isapipe error'
!    endif
!    end function

!! pipe check - working
     logical function stdin_isapipe() result(val)
     if(.not. stdin_isatty()) then
         if( trim(getfilename_stdin())=='NONE') then
             val=.true.
             return
         endif
     endif
     val=.false.
     end function

     logical function stdout_isapipe() result(val)
     if(.not. stdout_isatty()) then
         if( trim(getfilename_stdout())=='NONE') then
             val=.true.
             return
         endif
     endif
     val=.false.
     end function


!! filename
    character(len=MAX_LEN_PATH) function getfilename_stdin() result(val)
    integer stat
    val=''
    call c_getfilename_stdin(val,stat)
    if(stat==1)then
        val=val(1:len_trim(val)-1)
    else
        val='NONE'
    endif
    end function

    character(len=MAX_LEN_PATH) function getfilename_stdout() result(val)
    integer stat
    val=''
    call c_getfilename_stdout(val,stat)
    if(stat==1)then
        val=val(1:len_trim(val)-1)
    else
        val='NONE'
    endif
    end function

end module
