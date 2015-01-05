!! module gpl_io
!! refered seplib
!! Author : Wansoo Ha (wansoo.ha@gmail.com)
!! last modified : Mar 2007

module gpl_hbinary
      use gpl_base, only: assign_un
      use gpl_binary
      use gpl_string, only: to_s
      private
      public :: to_hbin

      !! open a file, write an arr and colse the file
      !!  arg: (filename,arr,dim)
      !@interface to_hbin

      interface parse
          module procedure parse_f
          module procedure parse_s
      end interface

contains
 
      real function parse_f(lgiven,par,deflt) result(val)
      logical,intent(in):: lgiven
      real,intent(in) :: par,deflt
      if(lgiven) then
          val=par
      else
          val=deflt
      endif
      end function

      character(len=80) function parse_s(lgiven,par,deflt) result(val)
      logical,intent(in):: lgiven
      character(len=*),intent(in) :: par,deflt
      if(lgiven) then
          val=trim(adjustl(par))
      else
          val=trim(adjustl(deflt))
      endif
      end function
!
!@template to_hbin ifdcz
      subroutine to_hbinary_1d_<name>(filename,arr,n1,d1,o1,label1)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n1
      real,intent(in),optional:: d1,o1
      character(len=*),intent(in),optional:: label1
      real d1w,o1w
      character(len=80) l1w
      <type>,intent(in) :: arr(n1)
      integer:: un
      call to_bin(trim(filename),arr,n1)
      d1w=parse(present(d1),d1,1.)
      o1w=parse(present(o1),o1,0.)
      l1w=trim(parse(present(label1),trim(label1),'Z'))
      call assign_un(un)
      open(un,file=trim(filename)//'.H')
      write(un,*) 'in="'//trim(filename)//'"'
      write(un,*) 'n1='//trim(to_s(n1))
      write(un,*) 'd1='//trim(to_s(d1w))
      write(un,*) 'o1='//trim(to_s(o1w))
      write(un,*) 'label1="'//trim(adjustl(l1w))//'"'
      write(un,*) 'esize='//trim(to_s(<esize>))
      write(un,*) 'data_format="native_float"'
      close(un)
      return
      end subroutine

      subroutine to_hbinary_2d_<name>(filename,arr,n1,n2,d1,d2,o1,o2,label1,label2)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n1,n2
      <type>,intent(in) :: arr(n1,n2)
      real,intent(in),optional:: d1,d2,o1,o2
      character(len=*),intent(in),optional:: label1,label2
      real d1w,d2w,o1w,o2w
      character(len=80) l1w,l2w
      integer:: un
      call to_bin(trim(filename),arr,n1,n2)
      d1w=parse(present(d1),d1,1.)
      d2w=parse(present(d2),d2,1.)
      o1w=parse(present(o1),o1,0.)
      o2w=parse(present(o2),o2,0.)
      l1w=trim(parse(present(label1),trim(label1),'Z'))
      l2w=trim(parse(present(label2),trim(label2),'X'))
      call assign_un(un)
      open(un,file=trim(filename)//'.H')
      write(un,*) 'in="'//trim(filename)//'"'
      write(un,*) 'n1='//trim(to_s(n1))
      write(un,*) 'n2='//trim(to_s(n2))
      write(un,*) 'd1='//trim(to_s(d1w))
      write(un,*) 'd2='//trim(to_s(d2w))
      write(un,*) 'o1='//trim(to_s(o1w))
      write(un,*) 'o2='//trim(to_s(o2w))
      write(un,*) 'label1="'//trim(adjustl(l1w))//'"'
      write(un,*) 'label2="'//trim(adjustl(l2w))//'"'
      write(un,*) 'esize='//trim(to_s(<esize>))
      write(un,*) 'data_format="native_float"'
      close(un)
      return
      end subroutine

      subroutine to_hbinary_3d_<name>(filename,arr,n1,n2,n3,d1,d2,d3,o1,o2,o3,label1,label2,label3)
      implicit none
      character(len=*),intent(in) :: filename
      integer,intent(in) :: n1,n2,n3
      <type>,intent(in) :: arr(n1,n2,n3)
      real,optional:: d1,d2,d3,o1,o2,o3
      character(len=*),optional:: label1,label2,label3
      real d1w,d2w,d3w,o1w,o2w,o3w
      character(len=80) l1w,l2w,l3w
      integer:: un
      call to_bin(trim(filename),arr,n1,n2,n3)
      d1w=parse(present(d1),d1,1.)
      d2w=parse(present(d2),d2,1.)
      d3w=parse(present(d3),d3,1.)
      o1w=parse(present(o1),o1,0.)
      o2w=parse(present(o2),o2,0.)
      o3w=parse(present(o3),o3,0.)
      l1w=trim(parse(present(label1),trim(label1),'Z'))
      l2w=trim(parse(present(label2),trim(label2),'Y'))
      l3w=trim(parse(present(label3),trim(label3),'X'))
      call assign_un(un)
      open(un,file=trim(filename)//'.H')
      write(un,*) 'in="'//trim(filename)//'"'
      write(un,*) 'n1='//trim(to_s(n1))
      write(un,*) 'n2='//trim(to_s(n2))
      write(un,*) 'n3='//trim(to_s(n3))
      write(un,*) 'd1='//trim(to_s(d1w))
      write(un,*) 'd2='//trim(to_s(d2w))
      write(un,*) 'd3='//trim(to_s(d3w))
      write(un,*) 'o1='//trim(to_s(o1w))
      write(un,*) 'o2='//trim(to_s(o2w))
      write(un,*) 'o3='//trim(to_s(o3w))
      write(un,*) 'label1="'//trim(adjustl(l1w))//'"'
      write(un,*) 'label2="'//trim(adjustl(l2w))//'"'
      write(un,*) 'label3="'//trim(adjustl(l3w))//'"'
      write(un,*) 'esize='//trim(to_s(<esize>))
      write(un,*) 'data_format="native_float"'
      close(un)
      return
      end subroutine
!@end

end module
