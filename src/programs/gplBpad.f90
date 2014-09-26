
        program gplBpad
        use gpl
        implicit none
        character(len=256) :: fin,fout
        integer n1,i,nn1,nn2
        integer :: n2=0
        integer :: pl=0,pr=0,pt=0,pb=0
        real,dimension(:,:),allocatable :: arr,arr2
        real :: value
        logical :: vflag=.false.

        call help_header('Gpl binary pad (float type)')

        call from_par('n1',n1,'# of grids in fast dimension')

        call from_par('fin',fin,'input binary file')
        call from_par('fout',fout,'output binary file')

        call from_par('l',pl,0,'0','left   pad')
        call from_par('r',pr,0,'0','right  pad')
        call from_par('t',pt,0,'0','top    pad')
        call from_par('b',pb,0,'0','bottom pad')
        call from_par('n2',n2,0,'calc','# of grids in slow dimension')

        call from_par('v',value,0.,'','the value used to pad')
        !if(param_given('v')) vflag=.true.
        if(given_par('v')) vflag=.true.

        call help_par()
        call report_par()

        call assert_true(pl>=0,'pl>=0')
        call assert_true(pr>=0,'pr>=0')
        call assert_true(pt>=0,'pt>=0')
        call assert_true(pb>=0,'pb>=0')

        if(n2==0) n2= filesize(trim(fin))/n1/4
        print*,'n2=',n2

        nn1=n1+pt+pb
        nn2=n2+pl+pr
        print*,'nn1=',nn1
        print*,'nn2=',nn2

        allocate(arr(n1,n2),arr2(nn1,nn2))
        call from_bin(trim(fin),arr,n1,n2)

        !! body
        arr2(pt+1:pt+n1,pl+1:pl+n2)=arr(:,:)
        !! top
        do i=1,pt
            if(vflag) then
                arr2(i,:)=value
            else
                arr2(i,:)=arr2(pt+1,:)
            endif
        enddo
        !! bottom
        do i=pt+n1+1,nn1
            if(vflag) then
                arr2(i,:)=value
            else
                arr2(i,:)=arr2(pt+n1,:)
            endif
        enddo
        !! left
        do i=1,pl
            if(vflag) then
                arr2(:,i)=value
            else
                arr2(:,i)=arr2(:,pl+1)
            endif
        enddo
        !! right
        do i=pl+n2+1,nn2
            if(vflag) then
                arr2(:,i)=value
            else
                arr2(:,i)=arr2(:,pl+n2)
            endif
        enddo

        call to_bin(trim(fout),arr2,nn1,nn2)
        deallocate(arr,arr2)

        end program

