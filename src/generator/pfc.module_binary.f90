!! module gpl_io
!! refered seplib
!! Author : Wansoo Ha (wansoo.ha@gmail.com)
!! last modified : Mar 2007

module gpl_binary
      use gpl_base, only: assign_un
      private
      public :: from_bin,to_bin,from_bin_tr,to_bin_tr

      !! open a file, read an arr and colse the file
      !!  arg: (filename,arr,dim)
      !@interface from_bin

      !@interface from_bin_tr

      !! open a file, write an arr and colse the file
      !!  arg: (filename,arr,dim)
      !@interface to_bin

      !@interface to_bin_tr

contains
!
!@template from_bin ifdcz
      subroutine from_binary_1d_<name>(filename,arr,n)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n
      <type>,intent(out):: arr(n)
      integer :: un,i
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='read',status='old',recl=<esize>*n)
      read(un,rec=1)(arr(i),i=1,n)
      close(un)
      return
      end subroutine

      subroutine from_binary_2d_<name>(filename,arr,n1,n2)
      implicit none
      character(len=*),intent(in):: filename
      integer,intent(in) :: n1,n2
      <type>,intent(out):: arr(n1,n2)
      integer :: un,i1,i2
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='read',status='old',recl=<esize>*n1)
      do i2=1,n2
        read(un,rec=i2) (arr(i1,i2),i1=1,n1)
      enddo  
      close(un)
      return
      end subroutine

      subroutine from_binary_3d_<name>(filename,arr,n1,n2,n3)
      implicit none
      character(len=*),intent(in):: filename
      integer,intent(in) :: n1,n2,n3
      <type>,intent(out):: arr(n1,n2,n3)
      integer :: un,i1,i2,i3
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='read',status='old',recl=<esize>*n1*n2)
      do i3=1,n3
        read(un,rec=i3) ((arr(i1,i2,i3),i1=1,n1),i2=1,n2)
      enddo  
      close(un)
      return
      end subroutine
!@end

!@template from_bin_tr ifdcz
      subroutine from_binary_2d_<name>_transpose(filename,arr,nx,nz)
      implicit none
      character(len=*),intent(in):: filename
      integer,intent(in) :: nx,nz
      <type>,intent(out):: arr(nx,nz)
      integer :: un,ix,iz
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='read',status='old',recl=<esize>*nz)
      do ix=1,nx
        read(un,rec=ix) (arr(ix,iz),iz=1,nz)
      enddo  
      close(un)
      return
      end subroutine
!@end

!@template to_bin ifdcz
      subroutine to_binary_1d_<name>(filename,arr,n)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n
      <type>,intent(in) :: arr(n)
      integer:: un,i
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='write',status='replace',recl=<esize>*n)
      write(un,rec=1)(arr(i),i=1,n)
      close(un)
      return
      end subroutine

      subroutine to_binary_2d_<name>(filename,arr,n1,n2)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n1,n2
      <type>,intent(in) :: arr(n1,n2)
      integer:: un,i1,i2
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='write',status='replace',recl=<esize>*n1)
      do i2=1,n2
        write(un,rec=i2) (arr(i1,i2),i1=1,n1)
      enddo  
      close(un)
      return
      end subroutine

      subroutine to_binary_3d_<name>(filename,arr,n1,n2,n3)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n1,n2,n3
      <type>,intent(in) :: arr(n1,n2,n3)
      integer:: un,i1,i2,i3
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='write',status='replace',recl=<esize>*n1*n2)
      do i3=1,n3
        write(un,rec=i3) ((arr(i1,i2,i3),i1=1,n1),i2=1,n2)
      enddo  
      close(un)
      return
      end subroutine
!@end

!@template to_bin_tr ifdcz
      subroutine to_binary_2d_<name>_transpose(filename,arr,nx,nz)
      implicit none
      character(len=*),intent(in):: filename
      integer,intent(in) :: nx,nz
      <type>,intent(in):: arr(nx,nz)
      integer :: un,ix,iz
      call assign_un(un)
      open(un,file=trim(filename),access='direct',action='write',status='replace',recl=<esize>*nz)
      do ix=1,nx
        write(un,rec=ix) (arr(ix,iz),iz=1,nz)
      enddo  
      close(un)
      return
      end subroutine
!@end
end module
