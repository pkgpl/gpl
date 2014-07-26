module gpl_base
      implicit none
      private
      integer,parameter :: stderr=0
      public :: assign_un, un_opened
      public :: errexit,quit

contains

      subroutine assign_un(un)
      integer,intent(out):: un
      logical :: oflag
      integer :: i
      do i=99,10,-1
          inquire(unit=i,opened=oflag)
          if(.not.oflag) then
              un=i
              return
          endif
      enddo
      stop "Error: Logical unit assignment"
      end subroutine

      logical function un_opened(un) result(val)
      integer,intent(in):: un
      inquire(unit=un,opened=val)
      end function

!!! assert
!      subroutine assert_true(logic,msg)
!      logical,intent(in) :: logic
!      character(len=*),intent(in) :: msg
!      if(.not.logic) call errexit(msg)
!      end subroutine

      subroutine errexit(msg)
      character(len=*),intent(in) :: msg
      write(stderr,*), trim(msg)
      stop
      end subroutine

      subroutine quit(msg)
      character(len=*),intent(in) :: msg
      call errexit(msg)
      end subroutine

end module
