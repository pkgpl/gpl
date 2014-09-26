
        program gplTracePick
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,i1,i2,nc,irec
        integer :: n2=0
        integer first,last,esize
        integer :: step=1
        real :: d1=1.0
        character tp,otp
        integer,allocatable :: ia(:,:)
        real(kind=4),allocatable :: fa(:,:)
        real(kind=8),allocatable :: da(:,:)
        complex(kind=4),allocatable :: ca(:,:)
        complex(kind=8),allocatable :: za(:,:)
        character(len=2):: ncol
        character(len=10):: frmt

        call help_header('Gpl trace picker')

        call from_par('n1',n1,'# of grids in fast dimension')
        call from_par('fin',fin,'input binary file')
        call from_par('fout',fout,'output binary file')
        call from_par('pick',first,'(=first), first pick (1~n2)')

        call from_par('last',last,first,'first','last pick (pick~n2)')
        call from_par('step',step,1,'1','pick step')
        call from_par('d1',d1,1.0,'1.0','grid size')

        call from_par('n2',n2,0,'calc','# of grids in slow dimension')
        call from_par('type',tp,'f','f','data type [ifdcz]')
        call from_par('otype',otp,'a','a','output type [ab] (ascii/binary)')

        call help_par()
        call report_par()
        call assert_true(otp=='a'.or.otp=='b','otype=a|b')

        select case(tp)
        case('i')
            esize=4
        case('f')
            esize=4
        case('d')
            esize=8
        case('c')
            esize=8
        case('z')
            esize=16
        case default
            stop 'unknown type'
        end select

        if(n2==0) n2= filesize(trim(fin))/n1/esize
        print*,'n2=',n2

        nc=(last-first)/step+1
        write(ncol,'(i2)') nc

        select case(tp)
        case('i')
            frmt='(g,'//trim(ncol)//'i)'
            allocate(ia(n1,n2))
            call from_bin(trim(fin),ia,n1,n2)
            if(otp=='a') then
                open(11,file=trim(fout))
                do i1=1,n1
                  write(11,frmt) (i1-1)*d1,(ia(i1,i2),i2=first,last,step)
                enddo
                close(11)
            else
                open(11,file=trim(fout),access='direct',recl=esize*n1)
                irec=0
                do i2=first,last,step
                    irec=irec+1
                    write(11,rec=irec) (ia(i1,i2),i1=1,n1)
                enddo
                close(11)
            endif
            deallocate(ia)
        case('f')
            frmt='(e,'//trim(ncol)//'e)'
            allocate(fa(n1,n2))
            call from_bin(trim(fin),fa,n1,n2)
            if(otp=='a') then
                open(11,file=trim(fout))
                do i1=1,n1
                  write(11,frmt) (i1-1)*d1,(fa(i1,i2),i2=first,last,step)
                enddo
                close(11)
            else
                open(11,file=trim(fout),access='direct',recl=esize*n1)
                irec=0
                do i2=first,last,step
                    irec=irec+1
                    write(11,rec=irec) (fa(i1,i2),i1=1,n1)
                enddo
                close(11)
            endif
            deallocate(fa)
        case('d')
            frmt='(e,'//trim(ncol)//'e)'
            allocate(da(n1,n2))
            call from_bin(trim(fin),da,n1,n2)
            if(otp=='a') then
                open(11,file=trim(fout))
                do i1=1,n1
                  write(11,frmt) (i1-1)*d1,(da(i1,i2),i2=first,last,step)
                enddo
                close(11)
            else
                open(11,file=trim(fout),access='direct',recl=esize*n1)
                irec=0
                do i2=first,last,step
                    irec=irec+1
                    write(11,rec=irec) (da(i1,i2),i1=1,n1)
                enddo
                close(11)
            endif
            deallocate(da)
        case('c')
            allocate(ca(n1,n2))
            call from_bin(trim(fin),ca,n1,n2)
            if(otp=='a') then
                open(11,file=trim(fout))
                do i1=1,n1
                  !write(11,*) (i1-1)*d1,((real(ca(i1,i2)),aimag(ca(i1,i2))),i2=first,last,step)
                  write(11,*) (i1-1)*d1,(real(ca(i1,i2)),aimag(ca(i1,i2)),i2=first,last,step)
                enddo
                close(11)
            else
                open(11,file=trim(fout),access='direct',recl=esize*n1)
                irec=0
                do i2=first,last,step
                    irec=irec+1
                    write(11,rec=irec) (ca(i1,i2),i1=1,n1)
                enddo
                close(11)
            endif
            deallocate(ca)
        case('z')
            allocate(za(n1,n2))
            call from_bin(trim(fin),za,n1,n2)
            if(otp=='a') then
                open(11,file=trim(fout))
                do i1=1,n1
                  !write(11,*) (i1-1)*d1,((dreal(za(i1,i2)),dimag(za(i1,i2))),i2=first,last,step)
                  write(11,*) (i1-1)*d1,(dreal(za(i1,i2)),dimag(za(i1,i2)),i2=first,last,step)
                enddo
                close(11)
            else
                open(11,file=trim(fout),access='direct',recl=esize*n1)
                irec=0
                do i2=first,last,step
                    irec=irec+1
                    write(11,rec=irec) (za(i1,i2),i1=1,n1)
                enddo
                close(11)
            endif
            deallocate(za)
        end select

        end program
