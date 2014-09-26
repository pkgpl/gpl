! Author: Wansoo Ha ( wansoo.ha@gmail.com )

!gdoc
!name: String
!
!This module offers functions used to work with string.
!This contains functions for type conversion between string and other types,
!blank strip, and string matching.

!!! string manipulation
module gpl_string
  implicit none
  private
  integer, parameter :: MAX_STRING_LENGTH = 256
  integer, parameter :: MED_STRING_LENGTH = 64
  character,parameter :: TAB=char(9)
  public :: to_s, strip
  public :: to_i,to_f,to_c,to_d,to_z,to_b
!  public :: sto_i,sto_f,sto_c,sto_d,sto_z,sto_b,sto_s
  public :: start_with, end_with, has_str
  public :: strip_comment, strip_blank_eq
  
  !@interface to_s

contains

!doc
  character(len=MAX_STRING_LENGTH) function strip(value)
  ! Strip blanks (space and tab) at the start and end of a string
  character(len=*), intent(in) :: value ! input string
  integer i,j
  do i=1,len_trim(value)
    if(value(i:i)/=' ') then
    if(value(i:i)/=TAB) then
        exit
    endif
    endif
  enddo
  do j=len_trim(value),1,-1
    if(value(j:j)/=' ') then
    if(value(j:j)/=TAB) then
        exit
    endif
    endif
  enddo
  strip=trim(value(i:j))
!  strip = trim(adjustl(value))
  end function

        subroutine strip_comment(str,cmt)
        implicit none
        character(len=*),intent(inout):: str
        integer istrtcmt
        character(len=*),intent(in):: cmt
        istrtcmt=index(str,cmt)
        if(istrtcmt==0) return
        str=trim(str(1:istrtcmt-1))
        end subroutine

        subroutine strip_blank_eq(str)
        ! remove blank and tab around '='
        implicit none
        character(len=*),intent(inout):: str
        character(len=256):: tmp
        character,parameter :: tab=char(9),blnk=' '
        integer i,l,j,ieq
        tmp=''
        l=len_trim(str)
        ieq=index(str,'=')
        !! left of '='
        j=0
        do i=1,ieq
             if(str(i:i)==tab.or.str(i:i)==blnk) then
             else
                 j=j+1
                 tmp(j:j)=str(i:i)
             endif   
        enddo
        !! right of '='
        do i=ieq+1,l
             if(str(i:i)==tab.or.str(i:i)==blnk) then
             else
                 tmp=trim(tmp)//trim(str(i:l))
                 exit
             endif   
        enddo
        str=trim(tmp)
        end subroutine
!doc
  logical function start_with(str,sub)
  ! Check if a string starts with a substring
  character(len=*),intent(in):: str ! input string
  character(len=*),intent(in):: sub ! input substring
  start_with= trim(str(1:len_trim(sub)))==trim(sub)
  end function

!doc
  logical function end_with(str,sub)
  ! Check if a string ends with a substring
  character(len=*),intent(in):: str ! input string
  character(len=*),intent(in):: sub ! input substring
  integer istrt
  istrt=len_trim(str)-len_trim(sub)
  end_with= trim(str(istrt+1:))==trim(sub)
  end function

!doc
  logical function has_str(str,sub)
  ! Check if a string contains a substring
  character(len=*),intent(in):: str ! input string
  character(len=*),intent(in):: sub ! input substring
  integer idx
  idx=index(str,sub)
  if(idx==0) then
      has_str=.false.
  else
      has_str=.true.
  endif
  end function

!doc
! str to_s(val)
! Retrun string containing the value.
!
! in ifdczbs val  input value

!! to string
!@template to_s ifdczbs
  character(len=MAX_STRING_LENGTH) function to_s_<name>(value) result(str)
  <type>, intent(in) :: value
  write (str, *) value
  str = trim(adjustl(str))
  end function
!@end

!! from string to other types
!@template NONE ifdczb
!doc
  <type> function to_<name>(str)
  ! Read <type> value from a string
  character(len=*),intent(in):: str ! input string
  read(str,*,err=100) to_<name>
  return
100 stop 'parse error'
  end function
!@end

!!@template NONE ifdczbs
!  logical function sto_<name>(str,val) result(stat)
!  character(len=MAX_STRING_LENGTH),intent(in):: str
!  <type>,intent(out):: val
!  if(len_trim(str)==0) then
!      stat=.false.
!      return
!  endif
!  read(str,*,err=100,end=100) val
!  stat=.true.
!  return
!100   stat=.false.
!  return
!  end function
!!@end

end module
