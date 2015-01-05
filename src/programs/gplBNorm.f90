! Program :
! Author  : wansooha@gmail.com
! Date    :

        program gplBReduce
        use gpl
        implicit none
        character tp
        integer :: ne, esize=4
        integer,        allocatable:: ia(:),tia(:)
        real,           allocatable:: fa(:),tfa(:)
        real(kind=8),   allocatable:: da(:),tda(:)
        complex,        allocatable:: ca(:),tca(:)
        complex(kind=8),allocatable:: za(:),tza(:)
        logical denom
        real perc
        character(len=8):: nul='__NULL__'
        character(len=256):: fn,fd,fout

        call help_header('Gpl Binary Normalize')

        call from_par('fin',fn,'numerator file')
        call from_par('fd',fd,nul,nul,'denominator file/default: normalize by max. abs. val')
        call from_par('fout',fout,'output - normalized file name')

        call from_par('type',tp,'f','f','input binary type [ifdcz]')
        call from_par('perc',perc,0.,'0.','white noise percent')

        call from_par('ne',ne,0,'calc','number of elements')
        call help_par()
        call report_par()

        call assert_file_exists(trim(fn))
        if(trim(fd)==nul) then
            denom=.false.
        else
            denom=.true.
            call assert_file_exists(trim(fd))
            call assert_equal(int(filesize(trim(fn))),int(filesize(trim(fd))),"file sizes don't match")
        endif

        select case (tp)
        case('i')
            esize=4 
            ne=filesize(trim(fn))/esize
            print*,'ne=',ne
            allocate(ia(ne))
            call from_bin(trim(fn),ia,ne)

            if(denom) then
                allocate(tia(ne))
                call from_bin(trim(fd),tia,ne)
                if(minval(abs(tia))==0) stop 'Zero division error - use perc'
                ia=ia/tia
                deallocate(tia)
            else
                ia=ia/maxval(abs(ia))
            endif
            call to_bin(trim(fout),ia,ne)
            deallocate(ia)
        case('f')
            esize=4 
            ne=filesize(trim(fn))/esize
            print*,'ne=',ne
            allocate(fa(ne))
            call from_bin(trim(fn),fa,ne)

            if(denom) then
                allocate(tfa(ne))
                call from_bin(trim(fd),tfa,ne)
                if(perc>0.) then
                    tfa=tfa+perc*maxval(abs(tfa))
                else
                    if(minval(abs(tfa))==0.) stop 'Zero division error - use perc'
                endif
                fa=fa/tfa
                deallocate(tfa)
            else
                fa=fa/maxval(abs(fa))
            endif
            call to_bin(trim(fout),fa,ne)
            deallocate(fa)
        case('d')
            esize=8
            ne=filesize(trim(fn))/esize
            print*,'ne=',ne
            allocate(da(ne))
            call from_bin(trim(fn),da,ne)

            if(denom) then
                allocate(tda(ne))
                call from_bin(trim(fd),tda,ne)
                if(perc>0.) then
                    tda=tda+perc*maxval(dabs(tda))
                else
                    if(minval(dabs(tda))==0.d0) stop 'Zero division error - use perc'
                endif
                da=da/tda
                deallocate(tda)
            else
                da=da/maxval(abs(da))
            endif
            call to_bin(trim(fout),da,ne)
            deallocate(da)
        case('c')
            esize=8
            ne=filesize(trim(fn))/esize
            print*,'ne=',ne
            allocate(ca(ne))
            call from_bin(trim(fn),ca,ne)

            if(denom) then
                allocate(tca(ne))
                call from_bin(trim(fd),tca,ne)
                if(perc>0.) then
                    tca=tca+perc*maxval(cabs(tca))
                else
                    if(minval(cabs(tca))==0.) stop 'Zero division error - use perc'
                endif
                ca=ca/tca
                deallocate(tca)
            else
                ca=ca/maxval(cabs(ca))
            endif
            call to_bin(trim(fout),ca,ne)
            deallocate(ca)
        case('z')
            esize=16
            ne=filesize(trim(fn))/esize
            print*,'ne=',ne
            allocate(za(ne))
            call from_bin(trim(fn),za,ne)

            if(denom) then
                allocate(tza(ne))
                call from_bin(trim(fd),tza,ne)
                if(perc>0.) then
                    tza=tza+perc*maxval(cdabs(tza))
                else
                    if(minval(cdabs(tza))==0.d0) stop 'Zero division error - use perc'
                endif
                za=za/tza
                deallocate(tza)
            else
                za=za/maxval(cdabs(za))
            endif
            call to_bin(trim(fout),za,ne)
            deallocate(za)
        case default ; stop 'unknown type'
        end select

        end program

        subroutine assert_file_exists(fn)
        implicit none
        character(len=*),intent(in):: fn
        logical flag
        inquire(file=trim(fn),exist=flag)
        if(.not.flag) then
            write(0,*) 'file not exists: '//trim(fn)
            stop
        endif
        end subroutine
