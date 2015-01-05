! Program :
! Author  : wansooha@gmail.com
! Date    :

        program gplBReduce
        use gpl
        implicit none
        character tp,lc
        integer i,is1,is2,iskip,ne
        integer :: esize=4
        integer,        allocatable:: ia(:),tia(:)
        real,           allocatable:: fa(:),tfa(:)
        real(kind=8),   allocatable:: da(:),tda(:)
        complex,        allocatable:: ca(:),tca(:)
        complex(kind=8),allocatable:: za(:),tza(:)
        integer lnum
        logical verbose,flag,normalsum,normalize
        character(len=6):: frmt,num
        character(len=256):: fin,fname,fout

        call help_header('Gpl Binary Reduce')

        call from_par('fin',fin,'basename of input binary file')
        call from_par('fout',fout,'output - reduced file name')
        call from_par('end',is2,'the last file number')

        call from_par('type',tp,'f','f','input binary type [ifdcz]')
        call from_par('start',is1,1,'1','the 1st file number')
        call from_par('skip',iskip,1,'1','file number skip')
        call from_par('verbose',verbose,.false.,'F','verbose?')
        call from_par('normalsum',normalsum,.false.,'F','normalize before sum?')
        call from_par('normalize',normalize,.false.,'F','normalize result?')

        call from_par('len',lnum,4,'4','length of numeric part')
        if(lnum<1 .or. lnum>9) then
            stop '0 < len < 10'
        endif

        call from_par('ne',ne,0,'calc','number of elements')
        call help_par()
        call report_par()

        do i=is1,is2,iskip
            lc=to_s(lnum)
            frmt='(i'//lc//'.'//lc//')'
            write(num,frmt) i
            fname=trim(fin)//adjustl(trim(num))
            inquire(file=trim(fname),exist=flag)
            if(.not.flag) then
                write(0,*) 'file not exists: '//trim(fname)
                stop
            endif

            if(i==is1) then
                select case (tp)
                case('i') ; esize=4 
                case('f') ; esize=4 
                case('d') ; esize=8 
                case('c') ; esize=8 
                case('z') ; esize=16
                case default ; stop 'unknown type'
                end select
                ne=filesize(trim(fname))/esize
                if(verbose) then
                    print*,'type=',tp
                    print*,'ne=',ne
                    print*,'num type=',frmt
                endif
                !! initialization
                select case (tp)
                case('i') ; allocate(ia(ne),tia(ne)) ; tia=0
                case('f') ; allocate(fa(ne),tfa(ne)) ; tfa=0.
                case('d') ; allocate(da(ne),tda(ne)) ; tda=0.d0
                case('c') ; allocate(ca(ne),tca(ne)) ; tca=cmplx(0.,0.)
                case('z') ; allocate(za(ne),tza(ne)) ; tza=dcmplx(0.d0,0.d0)
                end select
            endif !! i==is1
            if(verbose) print*, trim(fname)

            select case (tp)
            case('i') ; call from_bin(trim(fname),ia,ne) ; if(normalsum) ia=ia/maxval(abs(ia))   ; tia=tia+ia
            case('f') ; call from_bin(trim(fname),fa,ne) ; if(normalsum) fa=fa/maxval(abs(fa))   ; tfa=tfa+fa
            case('d') ; call from_bin(trim(fname),da,ne) ; if(normalsum) da=da/maxval(dabs(da))  ; tda=tda+da
            case('c') ; call from_bin(trim(fname),ca,ne) ; if(normalsum) ca=ca/maxval(cabs(ca))  ; tca=tca+ca
            case('z') ; call from_bin(trim(fname),za,ne) ; if(normalsum) za=za/maxval(cdabs(za)) ; tza=tza+za
            end select
        enddo

        select case (tp)
        case('i') ; if(normalize) tia=tia/maxval(abs(tia))   ; call to_bin(trim(fout),tia,ne) ; deallocate(ia,tia)
        case('f') ; if(normalize) tfa=tfa/maxval(abs(tfa))   ; call to_bin(trim(fout),tfa,ne) ; deallocate(fa,tfa)
        case('d') ; if(normalize) tda=tda/maxval(dabs(tda))  ; call to_bin(trim(fout),tda,ne) ; deallocate(da,tda)
        case('c') ; if(normalize) tca=tca/maxval(cabs(tca))  ; call to_bin(trim(fout),tca,ne) ; deallocate(ca,tca)
        case('z') ; if(normalize) tza=tza/maxval(cdabs(tza)) ; call to_bin(trim(fout),tza,ne) ; deallocate(za,tza)
        end select

        end program

