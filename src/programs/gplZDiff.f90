
        program gplZDiff
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,esize,i1
        integer :: n2=0
        real,dimension(:,:),allocatable :: fa1,fa2

        call help_header('Gpl Zdiff (float type)')

        call from_par('n1',n1,'# of grids in fast dimension')
        call from_par('fin',fin,'input binary file')

        call from_par('n2',n2,0,'calc','# of grids in slow dimension')
        call from_par('fout',fout,'NULL','fin.dz','output binary file')
        if(trim(fout)=='NULL') fout=trim(fin)//'.dz'

        call help_par()
        call report_par()

        esize=4
        if(n2==0) n2=filesize(trim(fin))/n1/esize
        print*,'n2=',n2

        allocate(fa1(n1,n2),fa2(n1,n2))
        call from_bin(trim(fin),fa1,n1,n2)

        do i1=1,n1-1
          fa2(i1,:)=fa1(i1+1,:)-fa1(i1,:)
        enddo
        fa2(n1,:)=fa2(n1-1,:)

        call to_bin(trim(fout),fa2,n1,n2)
        deallocate(fa1,fa2)

        end program

