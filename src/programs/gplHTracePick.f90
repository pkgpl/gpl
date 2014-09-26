
        program gplHTracePick
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,i1,i2
        integer :: n2=0
        integer first,last,esize
        integer :: step=1
        real :: d2=1.0
        character tp
        integer,allocatable :: ia(:,:)
        real(kind=4),allocatable :: fa(:,:)
        real(kind=8),allocatable :: da(:,:)
        complex(kind=4),allocatable :: ca(:,:)
        complex(kind=8),allocatable :: za(:,:)

        call help_header('Gpl Horizontal trace picker')

        call from_par('n1',n1,'# of grids in fast dimension')
        call from_par('fin',fin,'input binary file')
        call from_par('fout',fout,'output binary file')
        call from_par('pick',first,'first pick (1~n2)')

        call from_par('last',last,first,'first','last pick (pick~n2)')
        call from_par('step',step,1,'1','pick step')
        call from_par('d2',d2,1.0,'1.0','grid size')

        call from_par('n2',n2,0,'calc','# of grids in slow dimension')
        call from_par('type',tp,'f','f','data type [ifdcz]')

        call help_par()
        call report_par()

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

        select case(tp)
        case('i')
            allocate(ia(n1,n2))
            call from_bin(trim(fin),ia,n1,n2)
            open(11,file=trim(fout))
            do i2=1,n2
              write(11,*) (i2-1)*d2,(ia(i1,i2),i1=first,last,step)
            enddo
            close(11)
            deallocate(ia)
        case('f')
            allocate(fa(n1,n2))
            call from_bin(trim(fin),fa,n1,n2)
            open(11,file=trim(fout))
            do i2=1,n2
              write(11,*) (i2-1)*d2,(fa(i1,i2),i1=first,last,step)
            enddo
            close(11)
            deallocate(fa)
        case('d')
            allocate(da(n1,n2))
            call from_bin(trim(fin),da,n1,n2)
            open(11,file=trim(fout))
            do i2=1,n2
              write(11,*) (i2-1)*d2,(da(i1,i2),i1=first,last,step)
            enddo
            close(11)
            deallocate(da)
        case('c')
            allocate(ca(n1,n2))
            call from_bin(trim(fin),ca,n1,n2)
            open(11,file=trim(fout))
            do i2=1,n2
              write(11,*) (i2-1)*d2,(ca(i1,i2),i1=first,last,step)
            enddo
            close(11)
            deallocate(ca)
        case('z')
            allocate(za(n1,n2))
            call from_bin(trim(fin),za,n1,n2)
            open(11,file=trim(fout))
            do i2=1,n2
              write(11,*) (i2-1)*d2,(za(i1,i2),i1=first,last,step)
            enddo
            close(11)
            deallocate(za)
        end select

        end program
