!! module gpl binary stream io
!! Author : Wansoo Ha (wansoo.ha@gmail.com)
!! last modified : Aug 2009

module gpl_stream
      use gpl_base, only: assign_un
      private
      public :: open_stream,close_stream
      public :: from_stream,to_stream

!@interface open_stream

      !!  read an arr
      !!  arg: (un,arr,dim12)
!@interface from_stream

      !!  write an arr
      !!  arg: (un,arr,dim12)
!@interface to_stream

contains

!@add_interface open_stream open_stream_f
      integer function open_stream_f(filename,mode) result(un)
      character(len=*),intent(in) :: filename
      character(len=*),intent(in),optional :: mode
      character(len=10) :: act,stat
      call assign_un(un)
      if(present(mode)) then
          act=get_act(mode)
          stat=get_stat(mode)
      else
          act='read'
          stat='old'
      endif
      open(un,file=trim(filename),access='stream',action=trim(act),status=trim(stat))
      end function

!@add_interface open_stream open_stream_s
      subroutine open_stream_s(un,filename,mode)
      integer,intent(in):: un
      character(len=*),intent(in) :: filename
      character(len=*),intent(in),optional :: mode
      character(len=10) :: act,stat
      if(present(mode)) then
          act=get_act(mode)
          stat=get_stat(mode)
      else
          act='read'
          stat='old'
      endif
      open(un,file=trim(filename),access='stream',action=trim(act),status=trim(stat))
      end subroutine

      character(len=10) function get_act(mode) result(act)
      character(len=*),intent(in):: mode
      select case (trim(mode))
      case ('r','R')  ; act='read'
      case ('w','W')  ; act='write'
      case ('rw','RW'); act='readwrite'
      case default
          act=trim(mode)
      end select
      end function

      character(len=10) function get_stat(mode) result(stat)
      character(len=*),intent(in):: mode
      select case (trim(mode))
      case ('r','R')  ; stat='old'
      case ('w','W')  ; stat='replace'
      case ('rw','RW'); stat='old'
      case default
          stat='old'
      end select
      end function

      subroutine close_stream(un)
      integer,intent(in):: un
      close(un)
      end subroutine

!@template from_stream ifdcz
      subroutine from_stream_1e_<name>(un,var)
      implicit none
      integer,intent(in) :: un
      <type>,intent(out):: var
      read(un,err=100) var
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_1d_<name>(un,arr,n)
      implicit none
      integer,intent(in) :: un,n
      <type>,intent(out):: arr(n)
      integer :: i
      read(un,err=100)(arr(i),i=1,n)
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_2d_<name>(un,arr,n1,n2)
      implicit none
      integer,intent(in) :: un,n1,n2
      <type>,intent(out):: arr(n1,n2)
      integer :: i1,i2
      do i2=1,n2
        read(un,err=100) (arr(i1,i2),i1=1,n1)
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_3d_<name>(un,arr,n1,n2,n3)
      implicit none
      integer,intent(in) :: un,n1,n2,n3
      <type>,intent(out):: arr(n1,n2,n3)
      integer :: i1,i2,i3
      do i3=1,n3
      do i2=1,n2
        read(un,err=100) (arr(i1,i2,i3),i1=1,n1)
      enddo  
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_1d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(out):: arr(:)
      integer :: i,n
      n=size(arr)
      read(un,err=100)(arr(i),i=1,n)
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_2d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(out):: arr(:,:)
      integer :: i1,i2,n1,n2
      n1=size(arr,1)
      n2=size(arr,2)
      do i2=1,n2
        read(un,err=100) (arr(i1,i2),i1=1,n1)
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine from_stream_3d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(out):: arr(:,:,:)
      integer :: i1,i2,i3,n1,n2,n3
      n1=size(arr,1)
      n2=size(arr,2)
      n3=size(arr,3)
      do i3=1,n3
      do i2=1,n2
        read(un,err=100) (arr(i1,i2,i3),i1=1,n1)
      enddo  
      enddo  
      return
100   stop 'file reading error'
      end subroutine
!@end

!@template to_stream ifdcz
      subroutine to_stream_1e_<name>(un,var)
      implicit none
      integer,intent(in) :: un
      <type>,intent(in) :: var
      write(un,err=100) var
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_1d_<name>(un,arr,n)
      implicit none
      integer,intent(in) :: un,n
      <type>,intent(in) :: arr(n)
      integer:: i
      write(un,err=100)(arr(i),i=1,n)
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_2d_<name>(un,arr,n1,n2)
      implicit none
      integer,intent(in) :: un,n1,n2
      <type>,intent(in) :: arr(n1,n2)
      integer:: i1,i2
      do i2=1,n2
        write(un,err=100) (arr(i1,i2),i1=1,n1)
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_3d_<name>(un,arr,n1,n2,n3)
      implicit none
      integer,intent(in) :: un,n1,n2,n3
      <type>,intent(in) :: arr(n1,n2,n3)
      integer:: i1,i2,i3
      do i3=1,n3
      do i2=1,n2
        write(un,err=100) (arr(i1,i2,i3),i1=1,n1)
      enddo
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_1d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(in) :: arr(:)
      integer:: i,n
      n=size(arr)
      write(un,err=100)(arr(i),i=1,n)
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_2d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(in) :: arr(:,:)
      integer:: i1,i2,n1,n2
      n1=size(arr,1)
      n2=size(arr,2)
      do i2=1,n2
        write(un,err=100) (arr(i1,i2),i1=1,n1)
      enddo  
      return
100   stop 'file reading error'
      end subroutine

      subroutine to_stream_3d_size_<name>(un,arr)
      implicit none
      integer,intent(in) :: un
      <type>,intent(in) :: arr(:,:,:)
      integer:: i1,i2,i3,n1,n2,n3
      n1=size(arr,1)
      n2=size(arr,2)
      n3=size(arr,3)
      do i3=1,n3
      do i2=1,n2
        write(un,err=100) (arr(i1,i2,i3),i1=1,n1)
      enddo
      enddo  
      return
100   stop 'file reading error'
      end subroutine
!@end
end module
