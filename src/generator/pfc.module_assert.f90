!
! Author: Wansoo Ha ( wansoo.ha@gmail.com )


!!! assertions
module gpl_assert
  use gpl_string
  private
  integer :: stderr=0
  public :: assert_true
  public :: assert_false
  public :: assert_equal
  public :: assert_between !! inclusive
  public :: assert_among

  !@interface assert_equal

  !@interface assert_between

  !@interface assert_among

contains

    subroutine assert_true (var, message)
    logical, intent (in) :: var
    character(len=*), intent (in), optional :: message
    if(.not.var) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    endif
    end subroutine

    subroutine assert_false (var, message)
    logical, intent (in) :: var
    character(len=*), intent (in), optional :: message
    if(var) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    endif
    end subroutine

! assert_equal

!@template assert_equal fdcz
    subroutine assert_equal_<name>(var1, var2, delta, message)
    <type>, intent (in) :: var1, var2
    real<kind>, intent (in) :: delta
    character(len=*), intent(in), optional :: message
    if ( abs( var1 - var2) > delta) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    end if
    end subroutine
!@end

!@add_interface assert_equal assert_equal_i
    subroutine assert_equal_i (var1, var2, message)
    integer, intent(in) :: var1, var2
    character(len=*), intent(in), optional :: message
    if ( var1 /= var2 ) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    end if
    end subroutine

!@add_interface assert_equal assert_equal_b
    subroutine assert_equal_b (var1, var2, message)
    logical, intent (in)  :: var1, var2
    character(len=*), intent (in), optional :: message
    if ( var1 .neqv. var2 ) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    end if
    end subroutine

!@add_interface assert_equal assert_equal_s
    subroutine assert_equal_s (var1, var2, message)
    character(len=*), intent (in)  :: var1, var2
    character(len=*), intent (in), optional :: message
    if ( trim(strip(var1)) /= trim(strip(var2))) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    end if
    end subroutine

!@template assert_between ifd
    subroutine assert_between_<name>(var, mn, mx, message)
    <type>, intent (in) :: var,mn,mx !! min,max
    character(len=*), intent(in), optional :: message
    if ( var < mn .or. mx < var) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    end if
    end subroutine
!@end

!@template assert_among ifdcz
    subroutine assert_among_<name>(var, arr, message)
    <type>, intent (in) :: var, arr(:)
    character(len=*), intent(in), optional :: message
    integer i
    logical found
    found=.false.
    do i=1, size(arr)
        if ( var == arr(i) ) found=.true.
    enddo
    if(.not. found) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    endif
    end subroutine
!@end

!@add_interface assert_among assert_among_s
    subroutine assert_among_s(var, arr, message)
    character(len=*), intent(in) :: var, arr(:)
    character(len=*), intent(in), optional :: message
    integer i
    logical found
    found=.false.
    do i=1, size(arr)
        if ( trim(strip(var)) == trim(strip(arr(i))) ) found=.true.
    enddo
    if(.not. found) then
        if(present(message)) write(stderr,'(a)') trim(message)
        stop
    endif
    end subroutine

end module gpl_assert
