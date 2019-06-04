#:include 'scalapackfx.fypp'
#:set TYPES = NUMERIC_TYPES
#:set RANKS = [2, 1, 0]

!> Contains wrapper for the BLACS library
module blacsfx_module
  use scalapackfx_common_module
  use blacsgrid_module
  use blacs_module
  implicit none
  private

  ! Public names.
  public :: DLEN_, DT_, CTXT_, M_, N_, MB_, NB_, RSRC_, CSRC_, LLD_
  public :: blacsfx_gebs


  interface blacsfx_gebs
    #:for RANK in RANKS
      #:for TYPE in TYPES
        #:set TYPEABBREV = TYPE_ABBREVS[TYPE]
        module procedure blacsfx_gebs_${TYPEABBREV}$${RANK}$
      #:endfor
    #:endfor
  end interface blacsfx_gebs

  interface blacsfx_gebr
    #:for RANK in RANKS
      #:for TYPE in TYPES
        #:set TYPEABBREV = TYPE_ABBREVS[TYPE]
        module procedure blacsfx_gebr_${TYPEABBREV}$${RANK}$
      #:endfor
    #:endfor
  end interface blacsfx_gebr

  interface blacsfx_gesd
    #:for RANK in RANKS
      #:for TYPE in TYPES
        #:set TYPEABBREV = TYPE_ABBREVS[TYPE]
        module procedure blacsfx_gesd_${TYPEABBREV}$${RANK}$
      #:endfor
    #:endfor
  end interface blacsfx_gesd

  interface blacsfx_gerv
    #:for RANK in RANKS
      #:for TYPE in TYPES
        #:set TYPEABBREV = TYPE_ABBREVS[TYPE]
        module procedure blacsfx_gerv_${TYPEABBREV}$${RANK}$
      #:endfor
    #:endfor
  end interface blacsfx_gerv

  interface blacsfx_gsum
    #:for RANK in RANKS
      #:for TYPE in TYPES
        #:set TYPEABBREV = TYPE_ABBREVS[TYPE]
        module procedure blacsfx_gsum_${TYPEABBREV}$${RANK}$
      #:endfor
    #:endfor
  end interface blacsfx_gsum


contains

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! GEBS
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#:def blacsfx_gebs_dr0_template(SUFFIX, TYPE)

  !> Starts broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to broadcast.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default " ").
  !! \see BLACS documentation (routine ?gebs2d).
  subroutine blacsfx_gebs_${SUFFIX}$(mygrid, aa, scope, top)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in), target :: aa
    character, intent(in), optional :: scope, top

    ${TYPE}$ :: buffer(1,1)

    buffer(1,1) = aa
    call blacsfx_gebs(mygrid, buffer, scope, top)

  end subroutine blacsfx_gebs_${SUFFIX}$

#:enddef blacsfx_gebs_dr0_template


#:def blacsfx_gebs_dr1_template(SUFFIX, TYPE)
  !> Starts broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to broadcast.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default " ").
  !! \see BLACS documentation (routine ?gebs2d).
  subroutine blacsfx_gebs_${SUFFIX}$(mygrid, aa, scope, top)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in), target :: aa(:)
    character, intent(in), optional :: scope, top

    ${TYPE}$, pointer :: buffer(:,:)

    buffer(1:size(aa),1:1) => aa(1:size(aa))
    call blacsfx_gebs(mygrid, buffer, scope, top)

  end subroutine blacsfx_gebs_${SUFFIX}$

#:enddef blacsfx_gebs_dr1_template


#:def blacsfx_gebs_dr2_template(SUFFIX, TYPE)
  !> Starts broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to broadcast.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default " ").
  !! \see BLACS documentation (routine ?gebs2d).


  subroutine blacsfx_gebs_${SUFFIX}$(mygrid, aa, scope, top)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in) :: aa(:,:)
    character, intent(in), optional :: scope, top

    character :: scope0, top0

    @:inoptflags(scope0, scope, 'A')
    @:inoptflags(top0, top, " ")

    call gebs2d(mygrid%ctxt, scope0, top0, size(aa, dim=1), size(aa, dim=2),&
        & aa, size(aa, dim=1))

  end subroutine blacsfx_gebs_${SUFFIX}$

#:enddef blacsfx_gebs_dr2_template

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! GEBR
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

#:def blacsfx_gebr_dr2_template(SUFFIX, TYPE)

  !> Receives broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to receive.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rsrc  Row of the source (default: row of master process).
  !! \param csrc  Column of the source (default: column of master process).
  !! \see BLACS documentation (routine ?gebr2d).
  subroutine blacsfx_gebr_${SUFFIX}$(mygrid, aa, scope, top, rsrc, csrc)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out) :: aa(:,:)
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rsrc, csrc

    character :: scope0, top0
    integer :: rsrc0, csrc0

    @:inoptflags(scope0,scope,"A")
    @:inoptflags(top0,top," ")
    @:inoptflags(rsrc0,rsrc, mygrid%masterrow)
    @:inoptflags(csrc0,csrc, mygrid%mastercol)

    call gebr2d(mygrid%ctxt, scope0, top0, size(aa, dim=1), size(aa, dim=2),&
      & aa, size(aa, dim=1), rsrc0, csrc0)

  end subroutine blacsfx_gebr_${SUFFIX}$

#:enddef blacsfx_gebr_dr2_template


#:def blacsfx_gebr_dr1_template(SUFFIX, TYPE)

  !> Receives broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to receive.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rsrc  Row of the source (default: row of master process).
  !! \param csrc  Column of the source (default: column of master process).
  !! \see BLACS documentation (routine ?gebr2d).
  subroutine blacsfx_gebr_${SUFFIX}$(mygrid, aa, scope, top, rsrc, csrc)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out), target :: aa(:)
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rsrc, csrc

    ${TYPE}$, pointer :: buffer(:,:)

    buffer(1:size(aa), 1:1) => aa(1:size(aa))
    call blacsfx_gebr(mygrid, buffer, scope, top, rsrc, csrc)

  end subroutine blacsfx_gebr_${SUFFIX}$

#:enddef blacsfx_gebr_dr1_template


#:def blacsfx_gebr_dr0_template(SUFFIX, TYPE)

  !> Receives broadcast (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to receive.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rsrc  Row of the source (default: row of master process).
  !! \param csrc  Column of the source (default: column of master process).
  !! \see BLACS documentation (routine ?gebr2d).
  subroutine blacsfx_gebr_${SUFFIX}$(mygrid, aa, scope, top, rsrc, csrc)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out), target :: aa
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rsrc, csrc

    ${TYPE}$ :: buffer(1,1)

    aa=buffer(1,1)
    call blacsfx_gebr(mygrid, buffer, scope, top, rsrc, csrc)

  end subroutine blacsfx_gebr_${SUFFIX}$

#:enddef blacsfx_gebr_dr0_template



#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! GESD
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#:def blacsfx_gesd_dr2_template(SUFFIX, TYPE)

  !> Sends general rectangular matrix to destination process
  !! (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Object to send.
  !! \param rdest  Row of the destination process.
  !! \param cdest  Column of the destination proces.
  !! \see BLACS documentation (routine ?gesd2d).
  subroutine blacsfx_gesd_${SUFFIX}$(mygrid, aa, rdest, cdest)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in) :: aa(:,:)
    integer, intent(in) :: rdest, cdest

    call gesd2d(mygrid%ctxt, size(aa, dim=1), size(aa, dim=2), aa,&
      & size(aa, dim=1), rdest, cdest)

  end subroutine blacsfx_gesd_${SUFFIX}$

#:enddef blacsfx_gesd_dr2_template


#:def blacsfx_gesd_dr1_template(SUFFIX, TYPE)

  !> Sends general rectangular matrix to destination process
  !! (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Object to send.
  !! \param rdest  Row of the destination process.
  !! \param cdest  Column of the destination proces.
  !! \see BLACS documentation (routine ?gesd2d).
  subroutine blacsfx_gesd_${SUFFIX}$(mygrid, aa, rdest, cdest)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in), target :: aa(:)
    integer, intent(in) :: rdest, cdest

    ${TYPE}$, pointer :: buffer(:,:)

    buffer(1:size(aa),1:1) => aa(1:size(aa))
    call blacsfx_gsed(mygrid, buffer, rdest, cdest)

  end subroutine blacsfx_gesd_${SUFFIX}$

#:enddef blacsfx_gesd_dr1_template


#:def blacsfx_gesd_dr0_template(SUFFIX, TYPE)

  !> Sends general rectangular matrix to destination process
  !! (${TYPE}$, rank ${RANK}$).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Object to send.
  !! \param rdest  Row of the destination process.
  !! \param cdest  Column of the destination proces.
  !! \see BLACS documentation (routine ?gesd2d).
  subroutine blacsfx_gesd_${SUFFIX}$(mygrid, aa, rdest, cdest)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(in), target :: aa
    integer, intent(in) :: rdest, cdest

    ${TYPE}$ :: buffer(1,1)

    buffer(1,1) = aa
    call blacsfx_gsed(mygrid, buffer, rdest, cdest)

  end subroutine blacsfx_gesd_${SUFFIX}$

#:enddef blacsfx_gesd_dr0_template



#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! GERV
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#:def blacsfx_gerv_dr2_template(SUFFIX, TYPE)

  !> Receives general rectangular matrix from source process (${TYPE}$, rank 2).
  !! \param mygrid  BLACS descriptor
  !! \param aa  Object to receive.
  !! \param rdest  Row of the destination process (default: master row).
  !! \param cdest  Column of the destination proces (default: master col).
  !! \see BLACS documentation (routine ?gerv2d).
  subroutine blacsfx_gerv_${SUFFIX}$(mygrid, aa, rsrc, csrc)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out) :: aa(:,:)
    integer, intent(in), optional :: rsrc, csrc

    integer :: rsrc0, csrc0

    @:inoptflags(rsrc0,rsrc,mygrid%masterrow)
    @:inoptflags(csrc0,csrc,mygrid%mastercol)
    call gerv2d(mygrid%ctxt, size(aa, dim=1), size(aa, dim=2), aa, &
      & size(aa, dim=1), rsrc0, csrc0)

  end subroutine blacsfx_gerv_${SUFFIX}$

#:enddef blacsfx_gerv_dr2_template


#:def blacsfx_gerv_dr1_template(SUFFIX, TYPE)

  !> Receives general rectangular matrix from source process (${TYPE}$, rank 2).
  !! \param mygrid  BLACS descriptor
  !! \param aa  Object to receive.
  !! \param rdest  Row of the destination process (default: master row).
  !! \param cdest  Column of the destination proces (default: master col).
  !! \see BLACS documentation (routine ?gerv2d).
  subroutine blacsfx_gerv_${SUFFIX}$(mygrid, aa, rsrc, csrc)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out),target :: aa(:)
    integer, intent(in), optional :: rsrc, csrc

    ${TYPE}$, pointer :: buffer(:,:)

    buffer(1:size(aa), 1:1) => aa(1:size(aa))
    call blacsfx_gerv(mygrid, aa, rsrc, csrc)

  end subroutine blacsfx_gerv_${SUFFIX}$

#:enddef blacsfx_gerv_dr1_template


#:def blacsfx_gerv_dr0_template(SUFFIX, TYPE)

  !> Receives general rectangular matrix from source process (${TYPE}$, rank 2).
  !! \param mygrid  BLACS descriptor
  !! \param aa  Object to receive.
  !! \param rdest  Row of the destination process (default: master row).
  !! \param cdest  Column of the destination proces (default: master col).
  !! \see BLACS documentation (routine ?gerv2d).
  subroutine blacsfx_gerv_${SUFFIX}$(mygrid, aa, rsrc, csrc)
    type(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(out),target :: aa
    integer, intent(in), optional :: rsrc, csrc

    ${TYPE}$ :: buffer(1,1)

    buffer(1,1) = aa
    call blacsfx_gerv(mygrid, aa, rsrc, csrc)

  end subroutine blacsfx_gerv_${SUFFIX}$

#:enddef blacsfx_gerv_dr0_template



#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#!!! GSUM
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


#:def blacsfx_gsum_dr2_template(SUFFIX, TYPE)

  !> Performs element-wise summation(${SUFFIX}$, rank 2).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Matrix to sum up.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rdest  Row of the destination (default: row of master process).
  !! \param rcol  Column of the destination (default: column of master process).
  !! \see BLACS documentation (routine ?gsum2d).
  subroutine blacsfx_gsum_${SUFFIX}$(mygrid, aa, scope, top, rdest, cdest)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(inout) :: aa(:,:)
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rdest, cdest

    character :: scope0, top0
    integer :: rdest0, cdest0

    @:inoptflags(scope0, scope, "A")
    @:inoptflags(top0, top, " ")
    @:inoptflags(rdest0, rdest, mygrid%masterrow)
    @:inoptflags(cdest0, cdest, mygrid%mastercol)
    call gsum2d(mygrid%ctxt, scope0, top0, size(aa, dim=1), size(aa, dim=2),&
      & aa, size(aa, dim=1), rdest0, cdest0)

  end subroutine blacsfx_gsum_${SUFFIX}$

#:enddef blacsfx_gsum_dr2_template


#:def blacsfx_gsum_dr1_template(SUFFIX, TYPE)

  !> Performs element-wise summation(${SUFFIX}$, rank 1).
  !! \param mygrid  BLACS descriptor.
  !! \param aa  Vector to sum up.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rdest  Row of the destination (default: row of master process).
  !! \param rcol  Column of the destination (default: column of master process).
  !! \see BLACS documentation (routine ?gsum2d).
  subroutine blacsfx_gsum_${SUFFIX}$(mygrid, aa, scope, top, rdest, cdest)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(inout), target :: aa(:)
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rdest, cdest

    ${TYPE}$, pointer :: buffer(:,:)

    buffer(1:size(aa), 1:1) => aa(1:size(aa))
    call blacsfx_gsum(mygrid, buffer, scope, top, rdest, cdest)

  end subroutine blacsfx_gsum_${SUFFIX}$

#:enddef blacsfx_gsum_dr1_template


#:def blacsfx_gsum_dr0_template(SUFFIX, TYPE)

  !> Performs element-wise summation(${TYPE}$, rank 0).
  !! \param mygrid  BLACS descriptor
  !! \param aa  Scalar to sum up.
  !! \param scope  Scope of the broadcast (default: "A").
  !! \param top  Topology of the broadcast (default: " ").
  !! \param rdest  Row of the destination (default: row of master process).
  !! \param rcol  Column of the destination (default: column of master process).
  !! \see BLACS documentation (routine ?gsum2d).
  subroutine blacsfx_gsum_${SUFFIX}$(mygrid, aa, scope, top, rdest, cdest)
    class(blacsgrid), intent(in) :: mygrid
    ${TYPE}$, intent(inout) :: aa
    character, intent(in), optional :: scope, top
    integer, intent(in), optional :: rdest, cdest

    ${TYPE}$ :: buffer(1,1)

    buffer(1,1) = aa
    call blacsfx_gsum(mygrid, buffer, scope, top, rdest, cdest)

  end subroutine blacsfx_gsum_${SUFFIX}$

#:enddef blacsfx_gsum_dr0_template


#:for RANK in RANKS
  #:for TYPE in TYPES
    #:set FTYPE = FORTRAN_TYPES[TYPE]
    #:set SUFFIX = TYPE_ABBREVS[TYPE] + str(RANK)
    #:if RANK == 0
      $:blacsfx_gebs_dr0_template(SUFFIX, FTYPE)
      $:blacsfx_gebr_dr0_template(SUFFIX, FTYPE)
      $:blacsfx_gesd_dr0_template(SUFFIX, FTYPE)
      $:blacsfx_gerv_dr0_template(SUFFIX, FTYPE)
      $:blacsfx_gsum_dr0_template(SUFFIX, FTYPE)
    #:elif RANK == 1
      $:blacsfx_gebs_dr1_template(SUFFIX, FTYPE)
      $:blacsfx_gebr_dr1_template(SUFFIX, FTYPE)
      $:blacsfx_gesd_dr1_template(SUFFIX, FTYPE)
      $:blacsfx_gerv_dr1_template(SUFFIX, FTYPE)
      $:blacsfx_gsum_dr1_template(SUFFIX, FTYPE)
    #:elif RANK == 2
      $:blacsfx_gebs_dr2_template(SUFFIX, FTYPE)
      $:blacsfx_gebr_dr2_template(SUFFIX, FTYPE)
      $:blacsfx_gesd_dr2_template(SUFFIX, FTYPE)
      $:blacsfx_gerv_dr2_template(SUFFIX, FTYPE)
      $:blacsfx_gsum_dr2_template(SUFFIX, FTYPE)
    #:endif
  #:endfor
#:endfor

!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!!! Barrier
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  !> Holds up execution of all processes within given scope.
  !!
  !! \param self  BLACS group descriptor
  !! \param scope  Scope of the barrier (default: "A")
  !!
  subroutine blacsfx_barrier(mygrid, scope)
    type(blacsgrid), intent(in) :: mygrid
    character, intent(in), optional :: scope

    character :: scope0

    @:inoptflags(scope0, scope, "A")
    call blacs_barrier(mygrid%ctxt, scope0)

  end subroutine blacsfx_barrier


  !> Delivers process information.
  !!
  !! \param iproc  Id of the process (0 <= iproc < nproc)
  !! \param nproc  Nr. of processes.
  !!
  subroutine blacsfx_pinfo(iproc, nproc)
    integer, intent(out) :: iproc, nproc

    call blacs_pinfo(iproc, nproc)

  end subroutine blacsfx_pinfo


  !> Delivers row and column of a given process in a grid.
  !!
  !! \param mygrid  BLACS grid.
  !! \param iproc  Process of which position should be determined.
  !! \param prow  Row of the process.
  !! \param pcol  Column of the process.
  !!
  subroutine blacsfx_pcoord(mygrid, iproc, prow, pcol)
    type(blacsgrid), intent(in) :: mygrid
    integer, intent(in) :: iproc
    integer, intent(out) :: prow, pcol

    call blacs_pcoord(mygrid%ctxt, iproc, prow, pcol)

  end subroutine blacsfx_pcoord


  !> Delivers process number for a given process in the grid.
  !!
  !! \param mygrid BLACS grid.
  !! \param prow  Row of the process.
  !! \param pcol  Column of the process.
  !! \return  Process number (id) of the process with the given coordinates.
  !!
  function blacsfx_pnum(mygrid, prow, pcol) result(pnum)
    type(blacsgrid), intent(in) :: mygrid
    integer, intent(in) :: prow, pcol
    integer :: pnum

    pnum = blacs_pnum(mygrid%ctxt, prow, pcol)

  end function blacsfx_pnum


  !> Stops BLACS communication.
  !!
  !! \param keepmpi If set to yes, the MPI framework will kept alive after
  !!     BLACS is switched off (default: .false.)
  !!
  subroutine blacsfx_exit(keepmpi)
    logical, intent(in), optional :: keepmpi

    logical :: keepmpi0

    @:inoptflags(keepmpi0, keepmpi, .false.)
    if (keepmpi0) then
      call blacs_exit(1)
    else
      call blacs_exit(0)
    end if

  end subroutine blacsfx_exit



end module blacsfx_module