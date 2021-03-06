      SUBROUTINE RDCAT3(LUCATLG,
     *   NTARGS,KTARGID,TARGNAMES,KTARGTYP,MAXPARM,TARGPARM,
     *   NFOUND,LUERR,IERR2,IERR4,IERRX)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS ROUTINE IS A SUB-DRIVER FOR THE TARGET CATALOGUE READER. IT
C READS CATALOGUE RECORDS, DETERMINING FOR EACH RECORD WHETHER ITS
C TARGET ID IS ONE OF THOSE FOR WHICH DATA IS WANTED. IF SO, IT
C CALLS OTHER ROUTINES TO DO THE LOADING.
C
C***********************************************************************
C
C BY C PETRUZZO, GSFC/742, 8/85
C    MODIFIED.....
C
C***********************************************************************
C
      INCLUDE 'RDCAT.INC'  ! SUPPLIES MAXDATA PARAMETER VALUE
C
      PARAMETER MAXDATA1 = MAXDATA+1
      REAL*8    TARGDATA(MAXDATA1)
C
      REAL*8    TARGPARM(MAXPARM,1) ! ACTUAL= TARGPARM(MAXPARM,NTARGS)
      INTEGER*4 KTARGID(1)          ! ACTUAL= KTARGID(NTARGS)
      INTEGER*4 KTARGTYP(1)         ! ACTUAL= KTARGTYP(NTARGS)
      CHARACTER*16 TARGNAMES(1)     ! ACTUAL= TARGNAMES(NTARGS)
C
      CHARACTER*16 NAME
      LOGICAL HAVREC,WANTIT
C
      IBUG = 0
      LUBUG = 19
C
      IF(IBUG.NE.0) WRITE(LUBUG,1020) LUCATLG,NTARGS,MAXPARM,
     *        (KTARGID(I),I=1,NTARGS)
 1020 FORMAT(/,' DEBUG AT ENTRY TO RDCAT3.',
     *     '  LUCATLG,NTARGS,MAXPARM=',3I7/,'  KTARGID=',(5X,10I6))
C
C INITIALIZE
C
      IERR2 = 0 ! ERROR RETURN FLAG FOR MISSING DATA
      IERR4 = 0 ! ERROR RETURN FLAG FOR MAXPARMS TOO SMALL
      IERRX = 0 ! ERROR RETURN FLAG FOR MISCELLANEOUS ERROR
      NFOUND = 0
C
      NSKIP = 0       ! TOTAL NUMBER OF ID'S TO IGNORE IN KTARGID.
      DO I=1,NTARGS
        IF(KTARGID(I).LE.0) NSKIP= NSKIP + 1
        END DO
C
C
C LOOP TO READ THE TARGET CATALOGUE. FOR EACH CATALOGUE RECORD READ,
C SEE IF IT IS IN THE CALLER'S KTARGID LIST. IF SO, LOAD THE OUTPUT
C ARRAYS. IF NOT, READ THE NEXT CATALOGUE RECORD.
C
      REWIND LUCATLG
C
  100 CONTINUE
C
C
C READ ONE CATALOGUE RECORD. CONTINUE READING UNTIL WE READ ONE
C THAT HAS POSITIVE TARGET ID AND POSITIVE TARGET TYPE.
C
      HAVREC = .FALSE.
      DO WHILE (.NOT.HAVREC)
C
C      INITIALIZE TARGDATA FOR SUBSEQUENT CHECKS AGAINST THE PRESENCE
C      OF TARGDATA(I)=DEFALT
        DO I = 1,MAXDATA1
          TARGDATA(I) = DEFALT
          END DO
C
C      READ A RECORD
        READ(LUCATLG,*,END=9999) KID,NAME,KTYPE,TARGDATA
        IF(IBUG.NE.0) WRITE(LUBUG,1025) KID,KTYPE,NAME
 1025   FORMAT(/,' RDCAT3 DEBUG 1025.  KID,KTYPE=',2I5,'   NAME=',A/)
C
C      POSITIVE ID AND POSITIVE TYPE ??  IF SO, EXIT THE DO-WHILE LOOP.
        HAVREC = KID.GT.0 .AND. KTYPE.GT.0
        END DO
C
C
C DO WE WANT THIS RECORD ? (IE, IS ITS TARGET ID ONE THAT WE WANT?)
C IF SO, STORE THE DATA IN OUTPUT ARRAYS. WE CHECK ALL KTARGID
C ELEMENTS IN CASE A TARGET IS REPEATED THERE.
C
      DO ITARG=1,NTARGS
        WANTIT = KID.EQ.KTARGID(ITARG)
        IF(WANTIT) THEN
          NFOUND = NFOUND+1
          TARGNAMES(ITARG) = NAME
          KTARGTYP(ITARG) =  KTYPE
          CALL RDCAT3A(TARGDATA,MAXPARM,TARGPARM(1,ITARG),
     *           KTARGID(ITARG),TARGNAMES(ITARG),KTARGTYP(ITARG),
     *           LUERR,IER1)
          IF(IER1.NE.0) THEN
C          HAVE HAD AN ERROR WHEN TRYING TO LOAD TARGPARM ARRAY.
C          SET OUTPUT ARRAY CONTENTS AS DEFINED IN THE PROLOGUE TO
C          RDCAT.
            CALL MTXSETR8(TARGPARM(1,ITARG),0.D0,MAXPARM,1) ! PARM=0'S
            IF(IER1.EQ.KERRFLG1) THEN
C            DATA IS MISSING FROM THE RECORD
              TARGNAMES(ITARG) = 'RDCAT ERROR 2'
              KTARGTYP(ITARG) = -2
              IERR2 = 2
            ELSE IF(IER1.EQ.KERRFLG2) THEN
C            MAXPARMS IS TOO SMALL
              TARGNAMES(ITARG) = 'RDCAT ERROR 4'
              KTARGTYP(ITARG) = -4
              IERR4 = 4
            ELSE
C            A MISCELLANEOUS ERROR.
              TARGNAMES(ITARG) = 'RDCAT ERROR 4096'
              KTARGTYP(ITARG) = -4096
              IERRX = 4096
              END IF  ! END SPECIFIC ERROR CHECK BLOCK
            END IF    ! END GENERAL ERROR CHECK BLOCK
          END IF      ! END DO-WE-WANT-THIS-TARGET BLOCK
        END DO
C
C
C ****************
C *  FINISHED ?  *
C ****************
C
      IF( (NSKIP+NFOUND).EQ.NTARGS) THEN
        GO TO 9999     ! HAVE FOUND ALL TARGETS
      ELSE
        GO TO 100      ! STILL LOOKING
        END IF
C
 9999 CONTINUE
      RETURN
      END
