
        program gplLinVel
        use gpl
        implicit none
        character(len=256) :: fout,fswd
        integer n1,n2,i1,swdep,i2,idum,iswd
        real vmin,vmax,vwater
        real,allocatable :: arr(:,:)

        call help_header('Gpl Linear Velocity Generator')

        call from_par('n1',n1,'# of grids in fast dimension')
        call from_par('n2',n2,'# of grids in slow dimension')

        call from_par('vmin',vmin,'min. velocity at the top')
        call from_par('vmax',vmax,'max. velocity at the bottom')

        call from_par('fout',fout,'output binary file')

        call from_par('swdep',swdep,0,'0','see water depth')
        call from_par('vwater',vwater,1.5,'1.5','velocity of water')

        call from_par('fswd',fswd,'none','none','swd file (index, iswd), ignore 1st line')
        call help_par()
        call report_par()

        allocate(arr(n1,n2))

        if(swdep>0) then
            do i1=1,swdep
                arr(i1,:)=vwater
            enddo
            do i1=swdep+1,n1
                arr(i1,:)=vmin+(vmax-vmin)*float(i1-swdep-1)/float(n1-swdep-1)
            enddo
        else
            do i1=1,n1
                arr(i1,:)=vmin+(vmax-vmin)*float(i1-1)/float(n1-1)
            enddo
        endif
        if(trim(fswd)=='none') then
        else
            open(11,file=trim(fswd))
            do i2=1,n2
                read(11,*) idum,iswd
                arr(1:iswd,i2)=vwater
            enddo
        endif

        !call to_bin(trim(fout),arr,n1,n2)
        call to_hbin(trim(fout),arr,n1,n2)
        deallocate(arr)

        end program
