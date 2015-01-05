
        program gplLaplacian
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,esize,i,j
        integer :: n2=0
        real,dimension(:,:),allocatable :: fa1,fa2

        call help_header('Gpl Laplacian (float type, 3x3 kernel)')

        call from_par('n1',n1,'# of grids in fast dimension')
        call from_par('fin',fin,'input binary file')

        call from_par('n2',n2,0,'calc','# of grids in slow dimension')
        call from_par('fout',fout,'NULL','fin.lap','output binary file')
        if(trim(fout)=='NULL') fout=trim(fin)//'.lap'

        call help_par()
        call report_par()

        esize=4
        if(n2==0) n2=filesize(trim(fin))/n1/esize
        print*,'n2=',n2

        allocate(fa1(n1,n2),fa2(n1,n2))
        call from_bin(trim(fin),fa1,n1,n2)

        !! laplacian filter
        do i=2,n2-1
        do j=2,n1-1
            fa2(j,i)=4.*fa1(j,i)-fa1(j-1,i)-fa1(j+1,i)-fa1(j,i-1)-fa1(j,i+1)
        enddo
        enddo
        !! padding
        fa2(:,1)=fa2(:,2)
        fa2(:,n2)=fa2(:,n2-1)
        fa2(1,:)=fa2(2,:)
        fa2(n1,:)=fa2(n1-1,:)

        call to_bin(trim(fout),fa2,n1,n2)
        deallocate(fa1,fa2)

        end program

