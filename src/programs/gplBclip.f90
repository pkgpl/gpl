
        program gplBcut
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer:: n1=0,esize=4
        character tp
        real cmin,cmax
        integer,dimension(:),allocatable :: ia1
        real,dimension(:),allocatable :: fa1
        real(kind=8),dimension(:),allocatable :: da1

        call help_header('Gpl binary cut')

        call from_par('fin',fin,'input binary file')
        call from_par('fout',fout,'output binary file')

        call from_par('min',cmin,0.,'minval','min')
        call from_par('max',cmax,0.,'maxval','max')

        call from_par('ne',n1,0,'calc','# of elements')
        call from_par('type',tp,'f','f','data type [ifd]')

        call help_par()
        call report_par()

        select case(tp)
        case('i')
            esize=4
        case('f')
            esize=4
        case('d')
            esize=8
        case default
            stop 'unknown type'
        end select

        if(n1==0) n1=filesize(trim(fin))/esize
        print*,'ne=',n1

        select case(tp)
        case('i')
            allocate(ia1(n1))
            call from_bin(trim(fin),ia1,n1)
            if(.not.given_par('min')) cmin=minval(ia1)
            if(.not.given_par('max')) cmax=maxval(ia1)
            where(ia1<cmin) ia1=nint(cmin)
            where(ia1>cmax) ia1=nint(cmax)
            call to_bin(trim(fout),ia1,n1)
            deallocate(ia1)
        case('f')
            allocate(fa1(n1))
            call from_bin(trim(fin),fa1,n1)
            if(.not.given_par('min')) cmin=minval(fa1)
            if(.not.given_par('max')) cmax=maxval(fa1)
            where(fa1<cmin) fa1=cmin
            where(fa1>cmax) fa1=cmax
            call to_bin(trim(fout),fa1,n1)
            deallocate(fa1)
        case('d')
            allocate(da1(n1))
            call from_bin(trim(fin),da1,n1)
            if(.not.given_par('min')) cmin=minval(da1)
            if(.not.given_par('max')) cmax=maxval(da1)
            where(da1<cmin) da1=dble(cmin)
            where(da1>cmax) da1=dble(cmax)
            call to_bin(trim(fout),da1,n1)
            deallocate(da1)
        end select
        write(*,*) 'min=',cmin
        write(*,*) 'max=',cmax

        end program

