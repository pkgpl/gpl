! Program :
! Author  : wansooha@gmail.com
! Date    :

module gpl_stdio
  implicit none

!@interface from_stdin
!@interface to_stdout

  private
  public :: from_stdin, to_stdout

contains

!! read

!@template from_stdin ifdcz
  logical function stdin_1e_<name>(val) result(readone)
  <type>,intent(out):: val
  integer nread
  call c_stdin_fread_<name>(val,1,nread)
  select case(nread)
  case(1) ; readone=.true.
  case(0) ; readone=.false.
  case default ; stop 'stdin read error'
  end select
  end function

  integer function stdin_1d_<name>(arr,n) result(tread)
  integer,intent(in):: n
  <type>,intent(out):: arr(n)
  call c_stdin_fread_<name>(arr,n,tread)
  end function

  integer function stdin_2d_<name>(arr,n,m) result(tread)
  integer,intent(in):: n,m
  <type>,intent(out):: arr(n,m)
  integer nread,i
  tread=0
  do i=1,m
    call c_stdin_fread_<name>(arr(:,i),n,nread)
    if(nread==0) return
    tread=tread+nread
  enddo
  end function
!@end

!!! write
!@template to_stdout ifdcz
  subroutine stdout_1e_<name>(val)
  <type>,intent(in):: val
  call c_stdout_fwrite_<name>(val,1)
  end subroutine

  subroutine stdout_1d_<name>(arr,n)
  integer,intent(in):: n
  <type>,intent(in):: arr(n)
  call c_stdout_fwrite_<name>(arr,n)
  end subroutine

  subroutine stdout_2d_<name>(arr,n,m)
  integer,intent(in):: n,m
  <type>,intent(in):: arr(n,m)
  integer i
  do i=1,m
    call c_stdout_fwrite_<name>(arr(:,i),n)
  enddo
  end subroutine
!@end

end module
