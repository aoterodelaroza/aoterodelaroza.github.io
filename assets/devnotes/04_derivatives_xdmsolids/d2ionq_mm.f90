!
! Copyright (C) 2016 Quantum ESPRESSO Foundation
! This file is distributed under the terms of the
! GNU General Public License. See the file `License'
! in the root directory of the present distribution,
! or http://www.gnu.org/copyleft/gpl.txt .
!
! Calculation of Grimme D2 contribution to the dyamical matrix
! See module "london_module" in Modules/mm_dispersion.f90
! Written by Fabrizio Masullo for his M.Sc. in Mathematic at UniUD
! under the supervision of Paolo Giannozzi
!------------------------------------------------------------------------------
!
!
SUBROUTINE d2ionq_mm ( alat , nat , ityp , at , bg , tau, q, deriv2_london )
  !
  USE kinds ,       ONLY : DP
  USE io_global, ONLY: ionode, ionode_id
  USE io_files, ONLY : prefix
  USE constants,    ONLY : tpi, eps8
  USE mp_images,    ONLY : me_image , nproc_image , intra_image_comm
  USE mp,           ONLY : mp_sum, mp_bcast, mp_barrier
  !
  IMPLICIT NONE
  !
  INTEGER , INTENT ( in ) :: nat , ityp ( nat )
  ! input:
  ! nat  : number of atoms
  ! ityp : type of each atom
  !
  REAL ( DP ) , INTENT ( in ) :: alat, tau(3, nat),  at(3 , 3), bg(3 , 3), q(3)
  ! input:
  ! alat : the cell parameter
  ! tau  : atomic positions in alat units
  ! at   : direct lattice vectors
  ! bg   : reciprocal lattice vectors
  ! q    : wave-vector (in 2pi/alat units)
  !
  COMPLEX ( DP ), INTENT(OUT) :: deriv2_london ( 3, nat, 3, nat )
  !
  INTEGER :: ata , atb , nrm , nr , ipol, jpol
  ! locals :
  ! ata , atb : atom counters
  ! nrm       : actual number of vectors computed by rgen
  ! nr        : counter on neighbours shells
  ! ipol, jpol: counters on coords
  !
  INTEGER :: first , last , resto, divid
  ! locals :
  ! first  : lower bound on processor
  ! last   : upper
  !
  REAL ( DP ) :: dist , f_damp , dtau ( 3 ) , &
       exparg , expval, par , par2, fac , facF, add, addF, auxr, auxr2
  COMPLEX ( DP ) :: eiqr
  ! locals :
  ! dist         : distance R_ij between the current pair of atoms
  ! f_damp       :  damping function
  ! dtau         :  \vec R_ij
  ! ... and many other temporary variables, plus some buffers:
  !
  REAL ( DP ) ::    aux (3, 3, nat), g, gp, h, hp
  COMPLEX ( DP ) :: aux2(3, 3, nat)

  INTEGER :: i, j
  INTEGER :: iunxdm, ierr, iver
  LOGICAL :: lexist
  INTEGER :: nenv, nvec, nat0
  REAL(DP), ALLOCATABLE :: xenv(:,:)
  INTEGER, ALLOCATABLE :: ienv(:), lvec(:,:)
  REAL(DP), ALLOCATABLE :: cx(:,:,:), rvdw(:,:)
  REAL(DP) :: r(3), d2, ene

  INTEGER, EXTERNAL :: find_free_unit

  ! read the XDM environment, coefficients, and Rvdw
  IF (ionode) THEN
     iunxdm = find_free_unit ()
     ! CALL seqopn(iunxdm,postfix(2:6)//'xdm.dat','UNFORMATTED',lexist)
     ! CALL seqopn(iunxdm,'xdm','UNFORMATTED',lexist)
     ! IF (.NOT.lexist) CALL errore('d2ionq_xdm','could not open xdm data file',1)
     OPEN(unit=iunxdm,file=TRIM(prefix)//".xdm",form='unformatted')
     READ (iunxdm,iostat=ierr) iver
     IF (ierr /= 0) CALL errore('d2ionq_xdm','reading xdm.dat',1)
     READ (iunxdm,iostat=ierr) nenv, nvec, nat0
  END IF
  CALL mp_bcast(nenv, ionode_id, intra_image_comm)
  CALL mp_bcast(nvec, ionode_id, intra_image_comm)
  CALL mp_bcast(nat0, ionode_id, intra_image_comm)
  if (nat /= nat0) CALL errore('d2ionq_xdm','inconsistent number of atoms in .xdm file, nat /= nat0',1)

  ALLOCATE(ienv(nenv),xenv(3,nenv),lvec(3,nvec),cx(nat0,nat0,2:4),rvdw(nat0,nat0))
  IF (ionode) THEN
     IF (ierr /= 0) CALL errore('d2ionq_xdm','reading xdm.dat',1)
     READ (iunxdm,iostat=ierr) ienv, xenv, lvec
     IF (ierr /= 0) CALL errore('d2ionq_xdm','reading xdm.dat',1)
     READ (iunxdm,iostat=ierr) cx, rvdw
     IF (ierr /= 0) CALL errore('d2ionq_xdm','reading xdm.dat',1)
     CLOSE (UNIT=iunxdm, STATUS='KEEP')
  ENDIF
  CALL mp_bcast(ienv(1:nenv), ionode_id, intra_image_comm)
  CALL mp_bcast(xenv, ionode_id, intra_image_comm)
  CALL mp_bcast(lvec, ionode_id, intra_image_comm)
  CALL mp_bcast(cx, ionode_id, intra_image_comm)
  CALL mp_bcast(rvdw, ionode_id, intra_image_comm)

  ene = 0d0
  deriv2_london ( : , : , : , :) = 0.d0
  !
#if defined __MPI
  !
  ! parallelization: divide atoms across processors of this image
  ! (different images have different atomic positions)
  !
  resto = mod ( nat , nproc_image )
  divid = nat / nproc_image
  !
  IF ( me_image + 1 <= resto ) THEN
     !
     first = ( divid  + 1 ) * me_image + 1
     last  = ( divid  + 1 ) * ( me_image + 1 )
     !
  ELSE
     !
     first = ( ( divid + 1 ) * resto ) + ( divid ) * ( me_image-resto ) + 1
     last  = ( divid  + 1 ) * resto + ( divid ) * ( me_image - resto + 1 )
     !
  ENDIF
  !
#else
  !
  first = 1
  last  = nat
#endif
  !
  DO ata = first , last
     !
     aux(:,:,:) = 0.d0
     aux2(:,:,:) = 0.d0
     !
     DO atb = 1 , nat
        !
        dtau ( : ) = tau ( : , ata ) - tau ( : , atb )

#if defined(__INTEL_COMPILER) && (__INTEL_COMPILER < 1600)
!$omp parallel do private(dist,g,gp,h,hp,eiqr,auxr,r,d2) default(shared), reduction(+:aux), reduction(+:aux2)
#endif
        DO nr = 1, nvec
           r = lvec(1,nr) * at(:,1) + lvec(2,nr) * at(:,2) + lvec(3,nr) * at(:,3) - dtau
           d2 = r(1)*r(1) + r(2)*r(2) + r(3)*r(3)
           dist  = alat * sqrt(d2)

           IF ( dist > eps8 ) THEN
              call calcgh_mm(ityp(ata),ityp(atb),dist,g,gp,h,hp)
              ene = ene - 0.5d0 * g

              eiqr = exp ((0_dp,1_dp)*(q(1)*(r(1)+dtau(1))+&
                                       q(2)*(r(2)+dtau(2))+&
                                       q(3)*(r(3)+dtau(3)) ) * tpi )

              DO ipol = 1 , 3
                 DO jpol = 1 , 3
                    IF (ipol /= jpol) THEN
                       auxr = hp * r(ipol) * alat * r(jpol) * alat / dist
                    ELSE
                       auxr = hp * r(ipol) * alat * r(jpol) * alat / dist + h
                    ENDIF
                    !
                    aux (ipol,jpol,atb) = aux (ipol,jpol,atb) + auxr
                    aux2(ipol,jpol,atb) = aux2(ipol,jpol,atb) + auxr*eiqr
                    !
                 ENDDO ! jpol
                 !
              ENDDO ! ipol
              !
           ENDIF
           !
        ENDDO ! nr
#if defined(__INTEL_COMPILER) && (__INTEL_COMPILER < 1600)
!$omp end parallel do
#endif
        DO ipol =1,3
           DO jpol = 1,3
              deriv2_london (ipol, ata, jpol, atb) = aux2(ipol,jpol,atb)
           ENDDO
        ENDDO
     ENDDO
     !
     DO atb = 1, nat
        DO ipol =1,3
           DO jpol = 1,3
              deriv2_london (ipol, ata, jpol, ata) = &
                   deriv2_london (ipol, ata, jpol, ata) - aux(ipol,jpol,atb)
           ENDDO
        ENDDO
     ENDDO
     !
  ENDDO ! ata
  
  CALL mp_sum ( ene , intra_image_comm )
  CALL mp_sum ( deriv2_london , intra_image_comm )
  
  ! IF (ionode) THEN
  !    write (*,*) "finished1"
  !    write (*,'("ene = ",F20.12)') ene
  !    write (*,*) "nat = ", nat
  !    do ipol = 1, 3
  !       do ata = 1, nat
  !          do jpol = 1, 3
  !             do atb = 1, nat
  !                write (*,'(4(I2,X),F20.12,X,F20.12)') ipol, ata, jpol, atb, deriv2_london(ipol,ata,jpol,atb)
  !             end do
  !          end do
  !       end do
  !    end do
  !    write (*,*) "finished2"
  ! ENDIF

  ! call mp_barrier(intra_image_comm)
  ! stop 1

  RETURN
  !
END SUBROUTINE d2ionq_mm

SUBROUTINE calcgh_mm(i,j,d,g,gp,h,hp)
  USE london_module
  implicit none
  integer, intent(in) :: i, j
  real(dp), intent(in) :: d
  real(dp), intent(out) :: g, gp, h, hp
  
  real(dp) :: ed, fij, d6, d7, d2

  d2 = d * d
  d6 = d**6
  d7 = d6 * d
  ed = exp(-beta * (d / R_sum(i,j) - 1._dp))
  fij = 1._dp / (1._dp + ed)
  g = C6_ij(i,j) * scal6 / d6 * fij
  gp = C6_ij(i,j) * scal6 / d6 / (1._dp + ed) * (beta * ed / R_sum(i,j) / (1._dp + ed) - 6._dp / d)
  h = gp / d
  hp = C6_ij(i,j) * scal6 / d7 / (1._dp + ed) * (48._dp / d2 - &
     13._dp * beta * ed / R_sum(i,j) / d / (1._dp + ed) - &
     beta**2 * ed / R_sum(i,j)**2 / (1._dp + ed)**2 * (1._dp - ed))

END SUBROUTINE calcgh_mm
