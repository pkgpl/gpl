
        program gplBcut
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,nn1,nn2,esize
        integer :: n2=0
        integer :: pl=0,pr=0,pt=0,pb=0
        character tp
        integer,dimension(:,:),allocatable :: ia1,ia2
        real,dimension(:,:),allocatable :: fa1,fa2
        real(kind=8),dimension(:,:),allocatable :: da1,da2
        complex,dimension(:,:),allocatable :: ca1,ca2
        complex(kind=8),dimension(:,:),allocatable :: za1,za2

        call help_header('Gpl binary cut')

        call from_par('n1',n1,'# of grids in fast dimension')

        call from_par('fin',fin,'input binary file')
        call from_par('fout',fout,'output binary file')

        call from_par('l',pl,0,'0','left   cut')
        call from_par('r',pr,0,'0','right  cut')
        call from_par('t',pt,0,'0','top    cut')
        call from_par('b',pb,0,'0','bottom cut')
        call from_par('n2',n2,0,'calc','# of grids in slow dimension')
        call from_par('type',tp,'f','f','data type [ifdcz]')

        call help_par()
        call report_par()

        call assert_true(pl>=0,'pl>=0')
        call assert_true(pr>=0,'pr>=0')
        call assert_true(pt>=0,'pt>=0')
        call assert_true(pb>=0,'pb>=0')

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

        !if(n2==0) n2=get_n2(trim(fin),n1,esize)
        if(n2==0) n2=filesize(trim(fin))/n1/esize
        print*,'n2=',n2

        nn1=n1-pt-pb
        nn2=n2-pl-pr
        print*,'nn1=',nn1
        print*,'nn2=',nn2

        select case(tp)
        case('i')
            allocate(ia1(n1,n2),ia2(nn1,nn2))
            call from_bin(trim(fin),ia1,n1,n2)
            ia2(1:nn1,1:nn2)=ia1(pt+1:n1-pb,pl+1:n2-pr)
            call to_bin(trim(fout),ia2,nn1,nn2)
            deallocate(ia1,ia2)
        case('f')
            allocate(fa1(n1,n2),fa2(nn1,nn2))
            call from_bin(trim(fin),fa1,n1,n2)
            fa2(1:nn1,1:nn2)=fa1(pt+1:n1-pb,pl+1:n2-pr)
            call to_bin(trim(fout),fa2,nn1,nn2)
            deallocate(fa1,fa2)
        case('d')
            allocate(da1(n1,n2),da2(nn1,nn2))
            call from_bin(trim(fin),da1,n1,n2)
            da2(1:nn1,1:nn2)=da1(pt+1:n1-pb,pl+1:n2-pr)
            call to_bin(trim(fout),da2,nn1,nn2)
            deallocate(da1,da2)
        case('c')
            allocate(ca1(n1,n2),ca2(nn1,nn2))
            call from_bin(trim(fin),ca1,n1,n2)
            ca2(1:nn1,1:nn2)=ca1(pt+1:n1-pb,pl+1:n2-pr)
            call to_bin(trim(fout),ca2,nn1,nn2)
            deallocate(ca1,ca2)
        case('z')
            allocate(za1(n1,n2),za2(nn1,nn2))
            call from_bin(trim(fin),za1,n1,n2)
            za2(1:nn1,1:nn2)=za1(pt+1:n1-pb,pl+1:n2-pr)
            call to_bin(trim(fout),za2,nn1,nn2)
            deallocate(za1,za2)
        end select

        end program

