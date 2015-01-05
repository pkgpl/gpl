! Program :
! Author  : wansooha@gmail.com
! Date    :

        program gplBprint
        use gpl
        implicit none
        character tp
        integer is1,is2,nelem,j,un
        integer :: esize=4
        integer,        allocatable:: ia(:)
        real,           allocatable:: fa(:)
        real(kind=8),   allocatable:: da(:)
        complex,        allocatable:: ca(:)
        complex(kind=8),allocatable:: za(:)
        logical,        allocatable:: ba(:)
        character(len=256):: fin

        call help_header('Gpl binary print')

        call from_par('type',tp,'input binary type [ifdczb]')
        call from_par('fin',fin,'input binary file')

        call from_par('start',is1,1,'1','the 1st element to print')
        call from_par('end',is2,100,'100','the last element to print')

        call help_par()
        call report_par()

        select case (tp)
        case('i')
            esize=4
            allocate(ia(is2))
        case('f')
            esize=4
            allocate(fa(is2))
        case('d')
            esize=8
            allocate(da(is2))
        case('c')
            esize=8
            allocate(ca(is2))
        case('z')
            esize=16
            allocate(za(is2))
        case('b')
            esize=1
            allocate(ba(is2))
        case default
            stop 'unknown type'
        end select

        nelem= filesize(trim(fin))/esize
        if(is2>nelem) then
            print*,'is2,nelem=',is2,nelem
            stop
        endif

        call assign_un(un)
        open(un,file=trim(fin),access='stream')
        select case (tp)
        case('i')
            read(un) (ia(j),j=1,is2)
            do j=is1,is2
                print*,j,ia(j)
            enddo
            deallocate(ia)
        case('f')
            read(un) (fa(j),j=1,is2)
            do j=is1,is2
                print*,j,fa(j)
            enddo
            deallocate(fa)
        case('d')
            read(un) (da(j),j=1,is2)
            do j=is1,is2
                print*,j,da(j)
            enddo
            deallocate(da)
        case('c')
            read(un) (ca(j),j=1,is2)
            do j=is1,is2
                print*,j,real(ca(j)),aimag(ca(j))
            enddo
            deallocate(ca)
        case('z')
            read(un) (za(j),j=1,is2)
            do j=is1,is2
                print*,j,dreal(za(j)),dimag(za(j))
            enddo
            deallocate(za)
        case('b')
            read(un) (ba(j),j=1,is2)
            do j=is1,is2
                print*,j,ba(j)
            enddo
            deallocate(ba)
        end select
        close(un)

        end program

