! Program :
! Author  : wansooha@gmail.com
! Date    :

module gpl_os

use gpl_base, only: assign_un
use gpl_string
use gpl_cfunc

implicit none
private
  integer,parameter :: MAX_STRING_LENGTH=256
  integer,parameter :: ENV_STRING_LENGTH=512
  integer,parameter :: MED_STRING_LENGTH=32
  character,parameter :: TAB=char(9)
  character,parameter :: PATHSEP='/'

  integer,parameter :: MAX_TMP_FILE=99999
  character,parameter :: DOT='.'


  public :: program_name, get_command_output
  public :: environ, datapath, program_info

  public :: file_exists,tmp_filename
  public :: basename,ext,basename_ext,join_path,lastndir

  public :: mkdir,rmdir,remove,remove_rf
  public :: copy,copy_r,move,touch
  public :: cat,cat_to,cat_append

contains

    ! get program name
    ! ex) ./a.out n1=10   =>   "a.out"
    character(len=MAX_STRING_LENGTH) function program_name()
    implicit none
    character(len=MAX_STRING_LENGTH):: str
    integer istrt,iend
    call get_command(str)
    iend=index(str,' ')
    if(iend==0) iend=len_trim(str)
    istrt=index(str(1:iend-1),'/',back=.true.)
    if(istrt==0) then
        program_name=trim(str(1:iend-1))
    else
        program_name=trim(str(istrt+1:iend-1))
    endif
    end function

    character(len=MAX_STRING_LENGTH) function get_command_output(cmd) result(val)
    character(len=*),intent(in):: cmd
    character(len=MAX_STRING_LENGTH) :: tmpfile
    integer un
    tmpfile=trim(tmp_filename('gco.'))
    call system(cmd//" > "//trim(tmpfile))
    call assign_un(un)
    open(un,file=tmpfile)
    read(un,'(a256)') val
    close(un)
    call system("rm "//trim(tmpfile))
    val=trim(adjustl(val))
    end function

    character(len=ENV_STRING_LENGTH) function environ(vname) result(val)
    character(len=*),intent(in):: vname
    integer length,stat
    call get_environment_variable(trim(vname),val,length,stat,trim_name=.true.)
    select case(stat)
    case(-1) ; write(*,*) 'variable length too short!'
    case( 1) ; write(*,*) 'the environment variable does not exist'
    case( 2) ; write(*,*) 'your system does not support environment variable'
    end select
    end function

    character(len=MAX_STRING_LENGTH) function datapath() result(val)
    val=environ('DATAPATH')
    end function

    character(len=MAX_STRING_LENGTH) function program_info() result(val)
    val=trim(program_name())//TAB//trim(lastndir(trim(getpwd()),3))//':'//TAB &
            //trim(getlogin())//'@'//trim(gethostname())//TAB//trim(ctime())
    end function


!! path manipulation
  logical function file_exists(fname) !! file only
  character(len=*),intent(in):: fname
  inquire(file=trim(fname),exist=file_exists)
  end function

  character(len=MAX_STRING_LENGTH) function tmp_filename(base)
  character(len=*),intent(in):: base
  integer i
  character(len=5):: num
  character(len=MED_STRING_LENGTH):: pid
  write(pid,'(i10)') getpid() !! use pid for mpi thread safe
  pid=trim(adjustl(pid))
  i=0
  do
    write(num,'(i5.5)') i
    tmp_filename=trim(base)//trim(pid)//'.'//num
    if(.not. file_exists(trim(tmp_filename)) ) return
    i=i+1
  enddo
  end function

  character(len=MAX_STRING_LENGTH) function basename(path)
  character(len=*),intent(in):: path
  character(len=MAX_STRING_LENGTH):: base
  integer idot
  base=trim(basename_ext(path))
  idot=index(trim(base),DOT,back=.true.)
  if (idot==0) idot=len_trim(base)+1
  basename=trim(base(:idot-1))
  end function

  character(len=MAX_STRING_LENGTH) function ext(path)
  character(len=*),intent(in):: path
  character(len=MAX_STRING_LENGTH):: base
  integer idot
  base=trim(basename_ext(path))
  idot=index(trim(base),DOT,back=.true.)
  if(idot==0) idot=1 !! no dot in path
  ext=trim(base(idot:))
  end function

  character(len=MAX_STRING_LENGTH) function basename_ext(path)
  character(len=*),intent(in):: path
  integer isep
  isep=index(trim(path),PATHSEP,back=.true.)
  basename_ext=trim(path(isep+1:))
  end function

  character(len=MAX_STRING_LENGTH) function join_path(path,fname)
  character(len=*),intent(in):: path,fname
  if(end_with(trim(path),PATHSEP)) then
      join_path=trim(path)//trim(fname)
  else
      join_path=trim(path)//PATHSEP//trim(fname)
  endif
  end function

  character(len=MAX_STRING_LENGTH) function lastndir(path,n) result(val)
  character(len=*),intent(in):: path
  integer,intent(in):: n
  integer nsep,pos(30),i
  nsep=0
  do i=1,len_trim(path)-1
      if(PATHSEP==path(i:i))then
          nsep=nsep+1
          pos(nsep)=i
      endif
  enddo
  if(nsep<n+1) then
      val=trim(path)
      return
  endif
  i=pos(nsep-n+1)
  val=trim(path(i+1:))
  end function


!! file management
  subroutine mkdir(dir)
  character(len=*),intent(in):: dir
  call system('mkdir -p '//trim(dir))
  end subroutine

  subroutine rmdir(dir)
  character(len=*),intent(in):: dir
  call system('rmdir '//trim(dir))
  end subroutine

  subroutine remove(fname)
  character(len=*),intent(in):: fname
  call system('rm '//trim(fname))
  end subroutine

  subroutine remove_rf(fname)
  character(len=*),intent(in):: fname
  call system('rm -rf '//trim(fname))
  end subroutine

  subroutine copy(fin,fout)
  character(len=*),intent(in):: fin,fout
  call system('cp '//trim(fin)//' '//trim(fout))
  end subroutine

  subroutine copy_r(dirin,dirout)
  character(len=*),intent(in):: dirin,dirout
  call system('cp -r '//trim(dirin)//' '//trim(dirout))
  end subroutine

  subroutine move(fin,fout)
  character(len=*),intent(in):: fin,fout
  call system('mv '//trim(fin)//' '//trim(fout))
  end subroutine

  subroutine touch(fname)
  character(len=*),intent(in):: fname
  call system('touch '//trim(fname))
  end subroutine

  subroutine cat(fname)
  character(len=*),intent(in):: fname
  call system('cat '//trim(fname))
  end subroutine

  subroutine cat_to(fin,fout)
  character(len=*),intent(in):: fin,fout
  call system('cat '//trim(fin)//' > '//trim(fout))
  end subroutine

  subroutine cat_append(fin,fout)
  character(len=*),intent(in):: fin,fout
  call system('cat '//trim(fin)//' >> '//trim(fout))
  end subroutine

end module
