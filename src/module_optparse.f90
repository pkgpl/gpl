! Program :
! Author  : wansooha@gmail.com
! Date    : 22 Mar 2010

        module gpl_optparse
        implicit none
        private
        integer,parameter :: MXNPAR=200
        integer,parameter :: MXLPAR=128
        type parcontainer
            integer:: n=0
            character(len=MXLPAR):: arr(MXNPAR)
        end type
        type(parcontainer),save:: parfromfile,parfromcmd,parmerged,parfromstdin
        type(parcontainer),save:: helpmsg,helpmsgopt,helpheader,helpfooter
        logical,save:: initialized=.false.
        logical,save:: parse_error=.false.
        integer,parameter :: stderr=0
        integer,parameter :: stdin =5
        integer,parameter :: stdout=6
!! User Interface
        public:: from_par,from_parfile,help_par,set_parfile
        public:: help_header,help_footer,report_par
        public:: given_par,force_help
!!help
!! call from_parfile(fin)
!! call help_header(msg)
!! call from_par(key,val,msg)
!! call from_par(key,val,def,defmsg,msg)
!! call help_footer(msg)
!! call help_par()
!! call report_par()
!! call given_par(key)
!!help
        interface from_par
            module procedure from_param_i
            module procedure from_param_r
            module procedure from_param_d
            module procedure from_param_b
            module procedure from_param_s
            module procedure from_param_iarr
            module procedure from_param_rarr
            module procedure from_param_darr
            module procedure from_param_barr
            module procedure from_param_sarr
            module procedure from_param_opt_i
            module procedure from_param_opt_r
            module procedure from_param_opt_d
            module procedure from_param_opt_b
            module procedure from_param_opt_s
        end interface

        contains

!! parameter reader
        subroutine init()
        implicit none
        integer i
        call readparfromcmd()
        do i=1,parfromcmd%n
            if(parfromcmd%arr(i)(1:4)=='par=') then
                !print*,'from file'
                call readparfromfile(trim(parfromcmd%arr(i)(5:)))
                exit
            endif
        enddo
        call mergepar()
        initialized=.true.
        end subroutine

        subroutine from_parfile(fin)
        implicit none
        character(len=*),intent(in):: fin
        call readparfromfile(trim(fin))
        if(.not.initialized) call init()
        end subroutine
        
        subroutine set_parfile(fin)
        implicit none
        character(len=*),intent(in):: fin
        call par_clear(parfromfile)
        call readparfromfile(trim(fin))
        call mergepar()
        end subroutine

        subroutine par_clear(par)
        implicit none
        type(parcontainer),intent(out):: par
        integer i
        do i=1,par%n
            par%arr(i)=''
        enddo
        par%n=0
        end subroutine

        subroutine readparfromcmd()
        implicit none
        integer narg,iarg
        character(len=MXLPAR):: str
        narg=command_argument_count()
        do iarg=1,narg
            call get_command_argument(iarg,str)
            call addpar(trim(str),parfromcmd)
        enddo
        end subroutine readparfromcmd
       
        subroutine readparfromfile(fin)
        implicit none
        character(len=*),intent(in):: fin
        character(len=MXLPAR) str,tokens(MXNPAR)
        logical exists
        integer un,itok,ntok
        un=assign_un()
        inquire(file=trim(fin),exist=exists)
        if(.not.exists) call errexit('file not exists:'//trim(fin))

        open(un,file=trim(fin))
        do
            read(un,'(a)',end=100) str
            call strip_comment_(str,'#')
            if(len_trim(str).ne.0) then
                call strip_blank_eq_(str)
                call tokenizer(str,.false.,tokens,ntok)
                do itok=1,ntok
                    call addpar(adjustl(trim(tokens(itok))),parfromfile)
                enddo
            endif
        enddo
100     close(un)
        end subroutine readparfromfile

        subroutine readparfromstdin()
        implicit none
        character(len=MXLPAR) str,tokens(MXNPAR)
        integer itok,ntok
        do
            read(stdin,'(a)',end=100) str
            call tokenizer(str,.false.,tokens,ntok)
            do itok=1,ntok
                call addpar(adjustl(trim(tokens(itok))),parfromstdin)
            enddo
        enddo
100     return
        end subroutine readparfromstdin


        subroutine mergepar()
        implicit none
        integer i
        do i=1,parfromfile%n
            call addpar(trim(parfromfile%arr(i)),parmerged)
        enddo
        do i=1,parfromcmd%n
            call addpar(trim(parfromcmd%arr(i)),parmerged)
        enddo
        end subroutine mergepar

        subroutine addpar(str,container)
        implicit none
        character(len=*),intent(in):: str
        type(parcontainer),intent(inout):: container
        integer i,ieq
        if(str(1:1)=='#') return
        ieq=index(str,'=')
        if(ieq==0) return

        do i=1,container%n
            if(str(1:ieq)==container%arr(i)(1:ieq)) then
                container%arr(i)=trim(str)
!                print*,'sub:',trim(str)
                return
            endif
        enddo
        container%n=container%n+1
        container%arr(container%n)=trim(str)
!        print*,'add:',trim(str)
        end subroutine addpar

        logical function given_par(key) result(val)
        implicit none
        character(len=*),intent(in):: key
        val=given_par_in(trim(key),parmerged)
        end function

        logical function given_par_in(key,container) result(val)
        implicit none
        character(len=*),intent(in):: key
        type(parcontainer),intent(in):: container
        integer lenkey,i
        lenkey=len_trim(trim(key)//'=')
        do i=1,container%n
            if(trim(key)//'='==container%arr(i)(1:lenkey)) then
                val=.true.
                return
            endif
        enddo
        val=.false.
        end function

        subroutine addmsg(msg,container)
        implicit none
        character(len=*),intent(in):: msg
        type(parcontainer),intent(inout):: container
        container%n=container%n+1
        container%arr(container%n)=trim(msg)
        end subroutine

        subroutine tokenizer(str,removequote,tokens,ntok)
        implicit none
        character(len=*),intent(in):: str
        character(len=MXLPAR),intent(out):: tokens(MXNPAR)
        logical,intent(in):: removequote
        integer,intent(out):: ntok
        integer i,lens,il
        logical inq,isq
        character cha
        character,parameter :: tab=char(9),blnk=' '
        character(len=MXLPAR) :: string
        lens=len_trim(str)
        !! initialize
        inq=.false.
        ntok=0
        string=''
        il=0

        do i=1,lens
            isq=.false.
            cha=str(i:i)
            if(cha=="'" .or. cha=='"') then
                inq=(.not.inq)
                isq=.true.
            endif
            if(.not.inq .and. (cha==blnk .or. cha==tab .or. i==lens) ) then
                if(i==lens) call addstring(string,il,cha,removequote,isq)
                ntok=ntok+1
                tokens(ntok)=trim(string)
                string=''
                il=0
            else
                call addstring(string,il,cha,removequote,isq)
            endif
        enddo
        contains

            subroutine addstring(string,il,cha,removequote,isq)
            implicit none
            integer,intent(inout):: il
            character,intent(in):: cha
            character(len=*),intent(inout):: string
            logical,intent(in):: removequote,isq
            if(removequote) then
                if(.not.isq) then
                    string=string(1:il)//cha
                    il=il+1
                endif
            else
                string=string(1:il)//cha
                il=il+1
            endif
            end subroutine

        end subroutine
        

!        subroutine printparfromfile()
!        call printpar(parfromfile)
!        end subroutine
!
!        subroutine printparfromcmd()
!        call printpar(parfromcmd)
!        end subroutine
!
!        subroutine printparmerged()
!        call printpar(parmerged)
!        end subroutine

        subroutine report_par()
        call printpar(parmerged)
        end subroutine

        subroutine help_header(msg)
        implicit none
        character(len=*),intent(in):: msg
        call addmsg(trim(msg),helpheader)
        end subroutine help_header

        subroutine help_footer(msg)
        implicit none
        character(len=*),intent(in):: msg
        call addmsg(trim(msg),helpfooter)
        end subroutine help_footer

        subroutine force_help()
        parse_error=.true.
        end subroutine

        subroutine help_par()
        if(parse_error) then
            call printmsg(helpheader)
            write(stderr,*) "Required parameters:"
            call printpar(helpmsg)
            write(stderr,*) "Optional parameters:"
            call printpar(helpmsgopt)
            call printmsg(helpfooter)
            stop
        endif
        end subroutine

        subroutine printmsg(container)
        implicit none
        type(parcontainer),intent(in):: container
        integer i
        do i=1,container%n
            write(stderr,*) trim(container%arr(i))
        enddo
        end subroutine printmsg

        subroutine printpar(container)
        implicit none
        type(parcontainer),intent(in):: container
        integer i
        if(container%n==0) then
            write(stderr,*) '    None'
            return
        endif
        do i=1,container%n
            write(stderr,*) '    '//trim(container%arr(i))
        enddo
        end subroutine printpar


        character(len=MXLPAR) function valstr(key) result(str)
        character(len=*),intent(in):: key
        integer i,lkey
        if(.not.initialized) call init()
        lkey=len_trim(key)
        do i=1,parmerged%n
            if(trim(key)//'='==parmerged%arr(i)(1:lkey+1)) then
                str=trim(parmerged%arr(i)(lkey+2:))
                return
            endif
        enddo
        str=''
        end function

        subroutine helper(key,tp,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        character,intent(in):: tp
        character(len=80):: str
        write(str,100) '['//tp//']',trim(key),trim(msg)
        call addpar(trim(str),helpmsg)
        return
100     format(a3,1x,a,'=',T20,': ',a)
        end subroutine helper

        subroutine helper_opt(key,tp,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        character,intent(in):: tp
        character(len=80):: str
        write(str,100) '['//tp//']',trim(key),trim(defmsg),trim(msg)
        call addpar(trim(str),helpmsgopt)
        return
100     format(a3,1x,a,'=',a,T20,': ',a)
        end subroutine helper_opt


!! required parameters

        subroutine from_param_i(key,val,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        integer,intent(out):: val
        character(len=MXLPAR):: str
        call helper(key,'i',msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     parse_error=.true.
        end subroutine

        subroutine from_param_r(key,val,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        real,intent(out):: val
        character(len=MXLPAR):: str
        call helper(key,'r',msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     parse_error=.true.
        end subroutine

        subroutine from_param_d(key,val,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        real(kind=8),intent(out):: val
        character(len=MXLPAR):: str
        call helper(key,'d',msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     parse_error=.true.
        end subroutine

        subroutine from_param_b(key,val,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        logical,intent(out):: val
        character(len=MXLPAR):: str
        call helper(key,'b',msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     parse_error=.true.
        end subroutine

        subroutine from_param_s(key,val,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        character(len=*),intent(out):: val
        character(len=MXLPAR):: str
        call helper(key,'s',msg)
        str=trim(valstr(trim(key)))
        if(len_trim(str)==0) then
            parse_error=.true.
            return
        endif
        !val=trim(str)
        if(str(1:1)=='"' .or. str(1:1)=="'") then
            read(str,*) val
        else
            read(str,'(a)') val
        endif
        return
        end subroutine

!! array reading

        subroutine from_param_iarr(key,arr,n,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        integer,intent(out):: arr(:)
        integer,intent(out):: n
        character(len=MXLPAR):: str
        integer i,icomma
        call helper(key,'i',msg)
        str=trim(valstr(trim(key)))
        do i=1,size(arr)
            icomma=index(str,',')
            if(icomma==0) then
                read(str,*,err=100,end=100) arr(i)
                n=i
                return
            endif
            read(str(1:icomma-1),*,err=100,end=100) arr(i)
            str=trim(str(icomma+1:))
        enddo
100     parse_error=.true.
        end subroutine

        subroutine from_param_rarr(key,arr,n,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        real,intent(out):: arr(:)
        integer,intent(out):: n
        character(len=MXLPAR):: str
        integer i,icomma
        call helper(key,'r',msg)
        str=trim(valstr(trim(key)))
        do i=1,size(arr)
            icomma=index(str,',')
            if(icomma==0) then
                read(str,*,err=100,end=100) arr(i)
                n=i
                return
            endif
            read(str(1:icomma-1),*,err=100,end=100) arr(i)
            str=trim(str(icomma+1:))
        enddo
100     parse_error=.true.
        end subroutine

        subroutine from_param_darr(key,arr,n,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        real(kind=8),intent(out):: arr(:)
        integer,intent(out):: n
        character(len=MXLPAR):: str
        integer i,icomma
        call helper(key,'d',msg)
        str=trim(valstr(trim(key)))
        do i=1,size(arr)
            icomma=index(str,',')
            if(icomma==0) then
                read(str,*,err=100,end=100) arr(i)
                n=i
                return
            endif
            read(str(1:icomma-1),*,err=100,end=100) arr(i)
            str=trim(str(icomma+1:))
        enddo
100     parse_error=.true.
        end subroutine

        subroutine from_param_barr(key,arr,n,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        logical,intent(out):: arr(:)
        integer,intent(out):: n
        character(len=MXLPAR):: str
        integer i,icomma
        call helper(key,'b',msg)
        str=trim(valstr(trim(key)))
        do i=1,size(arr)
            icomma=index(str,',')
            if(icomma==0) then
                read(str,*,err=100,end=100) arr(i)
                n=i
                return
            endif
            read(str(1:icomma-1),*,err=100,end=100) arr(i)
            str=trim(str(icomma+1:))
        enddo
100     parse_error=.true.
        end subroutine

        subroutine from_param_sarr(key,arr,n,msg)
        implicit none
        character(len=*),intent(in):: key,msg
        character(len=*),intent(out):: arr(:)
        integer,intent(out):: n
        character(len=MXLPAR):: str
        integer i,icomma
        call helper(key,'s',msg)
        str=trim(valstr(trim(key)))
        do i=1,size(arr)
            icomma=index(str,',')
            if(icomma==0) then
                !read(str,*,err=100,end=100) arr(i)
                if(str(1:1)=='"' .or. str(1:1)=="'") then
                    read(str,*,err=100,end=100) arr(i)
                else
                    read(str,'(a)',err=100,end=100) arr(i)
                endif
                n=i
                return
            endif
            !read(str,*,err=100,end=100) arr(i)
            if(str(1:1)=='"' .or. str(1:1)=="'") then
                read(str(1:icomma-1),*,err=100,end=100) arr(i)
            else
                read(str(1:icomma-1),'(a)',err=100,end=100) arr(i)
            endif
            str=trim(str(icomma+1:))
        enddo
100     parse_error=.true.
        end subroutine


!! optional parameters

        subroutine from_param_opt_i(key,val,def,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        integer,intent(out):: val
        integer,intent(in):: def
        character(len=MXLPAR):: str
        call helper_opt(key,'i',defmsg,msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     val=def
        end subroutine

        subroutine from_param_opt_r(key,val,def,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        real,intent(out):: val
        real,intent(in):: def
        character(len=MXLPAR):: str
        call helper_opt(key,'r',defmsg,msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     val=def
        end subroutine

        subroutine from_param_opt_d(key,val,def,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        real(kind=8),intent(out):: val
        real(kind=8),intent(in):: def
        character(len=MXLPAR):: str
        call helper_opt(key,'d',defmsg,msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     val=def
        end subroutine

        subroutine from_param_opt_b(key,val,def,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        logical,intent(out):: val
        logical,intent(in):: def
        character(len=MXLPAR):: str
        call helper_opt(key,'b',defmsg,msg)
        str=trim(valstr(trim(key)))
        read(str,*,err=100,end=100) val
        return
100     val=def
        end subroutine

        subroutine from_param_opt_s(key,val,def,defmsg,msg)
        implicit none
        character(len=*),intent(in):: key,defmsg,msg
        character(len=*),intent(out):: val
        character(len=*),intent(in):: def
        character(len=MXLPAR):: str
        call helper_opt(key,'s',defmsg,msg)
        str=trim(valstr(trim(key)))
        if(len_trim(str)==0) then
            val=trim(def)
            return
        endif
        if(str(1:1)=='"') then
            read(str,*) val
        else
            read(str,'(a)') val
        endif
        return
        end subroutine

!! utils
        subroutine strip_blank_eq_(str)
        ! remove blank and tab around '='
        implicit none
        character(len=*),intent(inout):: str
        character(len=256):: tmp
        character,parameter :: tab=char(9),blnk=' '
        integer i,l,j,ieq
        tmp=''
        l=len_trim(str)
        ieq=index(str,'=')
        !! left of '='
        j=0
        do i=1,ieq
             if(str(i:i)==tab.or.str(i:i)==blnk) then
             else
                 j=j+1
                 tmp(j:j)=str(i:i)
             endif   
        enddo
        !! right of '='
        do i=ieq+1,l
             if(str(i:i)==tab.or.str(i:i)==blnk) then
             else
                 tmp=trim(tmp)//trim(str(i:l))
                 exit
             endif   
        enddo
        str=trim(tmp)
        end subroutine

        subroutine strip_comment_(str,cmt)
        implicit none
        character(len=*),intent(inout):: str
        integer istrtcmt
        character(len=*),intent(in):: cmt
        istrtcmt=index(str,cmt)
        if(istrtcmt==0) return
        str=trim(str(1:istrtcmt-1))
        end subroutine

        integer function assign_un() result(un)
        logical :: oflag
        integer :: i 
        do i=99,7,-1
            inquire(unit=i,opened=oflag)
            if(.not.oflag) then 
                un=i 
                return
            endif
        enddo
        un=4
        end function

        subroutine errexit(msg)
        implicit none
        character(len=*),intent(in):: msg
        write(stderr,*) trim(msg)
        stop
        end subroutine errexit
!! utils//
        end module gpl_optparse


!        program programName
!        use optparse
!        implicit none
!        integer n1,n2,n3,n4
!        real d1,d2,d3,d4
!        real*8 db1,db2
!        logical b1,b2
!        integer iarr(10),n,i,m,l,k
!        real rarr(10)
!        logical barr(10)
!        character(len=128) sarr(10)
!        character(len=128) s1,s2
!
!        !call readparfromfile('par.dat')
!        !call readparfromcmd()
!!        call init()
!        !call printparfromfile()
!        !call printparfromcmd()
!        !call printparmerged()
!        call from_parfile('par.dat')
!       ! call from_par('n1',n1,'msg n1')
!        call from_par('n2',n2,'msg n2')
!        !call from_par('d1',d1,'msg d1')
!        call from_par('d2',d2,'msg d2')
!        call from_par('label1',s1,'l0','l0','msg l1')
!!
!!        call from_par('n3',n3,10,'10','msg n1')
!!        call from_par('n4',n4,n2,'n2','msg n2')
!!        call from_par('d3',d3,0.1,'0.1','msg d1')
!!        call from_par('d4',d4,d2,'d2','msg d2')
!!
!!        call from_par('b1',b1,'msg b1')
!!        call from_par('db1',db1,'msg db1')
!!        call from_par('s1',s1,'msg s1')
!!
!!        call from_par('b2',b2,.true.,'T','msg b1')
!!        call from_par('db2',db2,0.1d0,'0.1','msg db2')
!!        call from_par('s2',s2,'d/d','d/d','msg s1')
!        call from_par('in',s2,'d/d','d/d','msg s2')
!
!        call help_header('Option Parser')
!!        call from_par('iarr',iarr,n,'msg iarr')
!!        call from_par('rarr',rarr,m,'msg rarr')
!        call from_par('n1',iarr,n,'msg iarr')
!        call from_par('d1',rarr,m,'msg rarr')
!        call from_par('bb',barr,l,'msg barr')
!        call from_par('ss',sarr,k,'msg sarr')
!        call help_footer('Examples:')
!        call help_footer('    test example')
!
!        call help_par()
!!        print*,n1,n2
!!        print*,d1,d2
!        print*,n2,d2
!!        print*,b1,db1
!        print*,trim(s1)
!!        print*,n3,n4
!!        print*,d3,d4
!!        print*,b2,db2
!        print*,trim(s2)
!        do i=1,n
!            print*,iarr(i)
!        enddo
!        do i=1,m
!            print*,rarr(i)
!        enddo
!        do i=1,l
!            print*,barr(i)
!        enddo
!        do i=1,k
!            print*,trim(sarr(i))
!        enddo
!        end
!
