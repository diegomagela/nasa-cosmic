      PROGRAM QUIKVIS
      IMPLICIT REAL*8 (A-H,O-Z)
C
C THIS PROGRAM GIVES AVAILABILITY INFORMATION FOR FIXED OR MOVING
C CELESTIAL TARGETS(IE, STARS, PLANETS, SUN,....).
C
C THE PROGRAM'S CHARACTERISTICS ARE:
C
C    - ORBITS ARE ASSUMED CIRCULAR; NO DRAG OR HARMONICS
C
C    - ORBIT NIGHT CAN BE CONSIDERED
C    - EARTH LIMB AVOIDANCE ANGLE CAN BE SPECIFIED
C    - RAM VECTOR AVOIDANCE ANGLE CAN BE SPECIFIED
C    - MAX TARGET/ZENITH SEPARATION ANGLE CAN BE SPECIFIED
C
C***********************************************************************
C
C BY C PETRUZZO/GFSC/742.   2/86.
C       MODIFIED....
C
C***********************************************************************
C
C
      INCLUDE 'QUIKVIS.INC'
C
      CHARACTER*50 ENDTEXT
      LOGICAL DIDACASE/.FALSE./
C
C
      INTEGER*4 IDTARG(MAXTARGS)
C       IDTARG(I) = ID OF I'TH TARGET.  ZERO OR NEGATIVE ID'S ARE
C       IGNORED. NO RESERVED VALUES(IE, ANY ID MAY BE USED).  LOADED
C       BY QUIKVIS0A.
C
      CHARACTER*16 TARGNAMES(MAXTARGS)
C       TARGNAMES(I) = NAME OF I'TH TARGET.  MOVING CELESTIAL TARGS HAVE
C       RESERVED NAMES(SEE THE QUIKVIS USER GUIDE).  THE RESERVED NAMES
C       ARE USED BY SUBROUTINE TGLOC01.  LOADED BY QUIKVIS1.
C
      REAL*8 TARGPARM(NPARMS,MAXTARGS)
C       PARAMETERS GIVING THE TARGET LOCATION.  IF I'TH TARGET IS FIXED,
C       THE FOLLOWING HOLDS.  OTHERWISE, =ZEROS.  LOADED BY QUIKVIS1.
C         TARGPARM(1,I) = RIGHT ASCENSION
C         TARGPARM(2,I) = DECLINATION
C         TARGPARM(3,I) = X-COMPONENT OF UNIT VECTOR
C         TARGPARM(4,I) = Y-COMPONENT OF UNIT VECTOR
C         TARGPARM(5,I) = Z-COMPONENT OF UNIT VECTOR
C
      INTEGER*4 KTARGTYP(MAXTARGS)
C       IDTARG(I) = TARGET TYPE FOR I'TH TARGET(VALID VALUES: 1,3)
C       LOADED BY QUIKVIS1.
C
C
      CHARACTER*18 DATETIME,BEGINTIME,ENDTIME
C
C CODING COMMENT:
C
C      A DESIGN FEATURE OF QUIKVIS IS THAT GLOBAL PARAMETERS(THOSE
C      USED BY MORE THAN ONE ROUTINE) MAY BE MODIFIED ONLY IN THE
C      INITIALIZATION AND USER INPUT ROUTINES.  A WAY WAS NEEDED TO
C      MAKE THE GLOBAL VARIABLES AVAILABLE TO THE PROGRAM'S
C      SUBROUTINES.  PASSING GLOBAL VARIABLES VIA THE ARGUMENT
C      LISTS TO EACH LOWER LEVEL ROUTINE WOULD HAVE LED TO LONG
C      LISTS AND TO TEDIOUS MODIFICATIONS WHEN NEW QUANTITIES WERE
C      ADDED, AND WOULD HAVE PERMITTED CHANGES TO THE VALUES OF
C      GLOBAL VARIABLES ANYWHERE IN THE CODE.  HENCE, THE ARGUMENT
C      LIST APPROACH WAS REJECTED, AS WAS USING A COMMON BLOCK FOR
C      SIMILAR REASONS.  THE SOLUTION WAS TO HAVE A SUBROUTINE
C      SERVE AS A STORAGE AREA FOR THE GLOBAL VARIABLE VALUES.  THE
C      INITIALIZATION AND USER INPUT ROUTINES PLACE GLOBAL VARIABLE
C      VALUES IN THE STORAGE ROUTINE.  ALL OTHER ROUTINES ARE
C      INITIALIZED BY QUIKVIS3 BEFORE PROCESSING THE CURRENT CASE.
C      QUIKVIS3 INITIALIZES THEM BY LOADING THE GLOBAL VARIABLE VALUES
C      INTO EACH ROUTINE'S LOCAL VARIABLES.  GLOBAL VARIABLES ARE NOT
C      ADDRESSED OTHERWISE.  THE ADVANTAGE IS THAT ONE CANNOT CHANGE A
C      GLOBAL VARIABLE VALUE EXCEPT IN A HIGHLY VISIBLE WAY(IE, BY
C      CALLING THE STORAGE ROUTINE).  FOR TARGET-RELATED ARRAYS
C      IDTARG, TARGPARM, TARGNAMES, AND KTARGTYP, THIS APPROACH WAS
C      NOT USED BECAUSE THE SIZE OF THESE ARRAYS WOULD HAVE LED TO
C      EXCESSIVE IMAGE SIZE IF THEY WERE TREATED AS LOCAL VARIABLES IN
C      EACH ROUTINE.
C
C      QUIKVIS999 IS THE GLOBAL VARIABLE STORAGE ROUTINE. ARRAYS
C      R8DATA, I4DATA, AND L4DATA ARE USED IN THE CALLING
C      QUIKVIS999 BECAUSE IT SIMPLIFIES THE CALL AND ALLOWS FOR
C      EXPANSION IN THE NUMBER OF GLOBAL VARIABLES WITHOUT MODIFYING
C      THE CALL STATEMENT.  THE INCLUDE FILE, QUIKVIS.INC, SETS UP
C      EQUIVALENCES BETWEEN THE ARRAY ELEMENTS AND LOCAL VARIABLES.
C      ANY CHANGE TO QUIKVIS.INC REQUIRES A RECOMPILATION OF ALL
C      ROUTINES BEGINNING WITH 'QUIKVIS'.
C
C
C ****************
C *  INITIALIZE  *
C ****************
C
C ***** SHOW THE DATE AND TIME THIS RUN BEGINS
C
      BEGINTIME = DATETIME(0)
      WRITE(LUPRINT,1020) BEGINTIME
C
C
C ***** INITIALIZE PROGRAM PARAMETERS AND CONTROLS.  SPECIFY TARGET ID'S
C       AND OBSERVATION REQUIREMENTS.
C
      CALL QUIKVIS0(IDTARG,IERR)
      IF(IERR.NE.0) GO TO 9999
C
C
C ***** LOAD DATA ARRAYS WITH TARGET INFO.  TARGET ID'S WERE SPECIFIED
C       DURING THE INITIALIZATION CALL TO QUIKVIS0.
C
      CALL QUIKVIS1(IDTARG,TARGNAMES,KTARGTYP,TARGPARM,IERR)
      IF(IERR.NE.0) GO TO 9999
C
C
C
C ***** SET MAIN'S INTERNAL VARIABLES THAT CORRESPOND TO THE PROGRAM'S
C       LOCAL VARIABLES.
C
      CALL QUIKVIS999(-1,R8DATA,I4DATA,L4DATA)
C
      NCASE = 0
 1000 CONTINUE
C
C ************************
C *  MAJOR PROGRAM LOOP  *
C ************************
C
      NCASE = NCASE + 1
      WRITE(LUPROMPT,100) NCASE
C
C    UPDATE THE NCASE GLOBAL VARIABLE FOR RETRIEVAL BY OTHER ROUTINES
      CALL QUIKVIS999(1,R8DATA,I4DATA,L4DATA)
C
C
C ***** GET USER INPUT.
C
      CALL QUIKVIS2(IERR,IEND)
      CALL QUIKVIS999(-1,R8DATA,I4DATA,L4DATA) ! UPDATE MAIN'S VARIABLES
      IF(IEND.NE.0) GO TO 9999
      IF(IERR.NE.0) THEN
        IF(INTERACTIVE) THEN
          WRITE(LUPROMPT,4302) NCASE
          GO TO 1000
        ELSE
          GO TO 9999
          END IF
        END IF
C
C
C ***** INITIALIZE THE REMAINING ROUTINES BEFORE CALLING THEM VIA
C       QUIKVIS4, QUIKVIS5, AND THEIR LOWER LEVEL ROUTINES
C
      CALL QUIKVIS3
C
C
C ***** OUTPUT THE CURRENT PROGRAM CONTROL VALUES
C
      CALL QUIKVIS4(IDTARG,TARGNAMES,KTARGTYP,TARGPARM)
C
C
C ***** EXECUTE THIS CASE AND OUTPUT RESULTS TO THE APPROPRIATE UNITS.
C
      CALL QUIKVIS5(IDTARG,TARGNAMES,KTARGTYP,TARGPARM,IERR)
C
      WRITE(LUPROMPT,4301) NCASE,DATETIME(0)
      IF(IERR.NE.0) GO TO 9999
C
      DIDACASE = .TRUE.
      GO TO 1000    ! LOOP FOR ANOTHER CASE
C
C
C *****************
C *  END THE RUN  *
C *****************
C
 9999 CONTINUE
C
      ENDTIME=DATETIME(0)
C
      ENDTEXT = ' QUIKVIS. NORMAL END.'
      IF(IEND.NE.0 .AND. .NOT.DIDACASE) ENDTEXT =
     *   ' QUIKVIS. NORMAL END, BUT NO CASES WERE EXECUTED.'
      IF(IERR.NE.0) ENDTEXT = 'QUIKVIS. ERROR END.'
C
      WRITE(LUPRINT,1040) BEGINTIME,ENDTIME,ENDTEXT
C
      CALL CHBLANK(ENDTEXT,K1,K2)
      TYPE *, ENDTEXT(1:K2) // '   ' // ENDTIME
      STOP ' '
C
  100 FORMAT(////,' ********** START CASE',I3,' **********'////)
 1020 FORMAT(' START QUIKVIS PROGRAM     ',A)
 4301 FORMAT(/,' END PROCESSING CASE ',I2,5X,A/)
 4302 FORMAT(/,' CASE ',I2,' BYPASSED BECAUSE OF ERRORS.'/)
 1040 FORMAT(///,'1'/,
     *  ' END QUIKVIS PROGRAM.'//,
     *  '    START TIME WAS ',A/,
     *  '      END TIME WAS ',A//,
     *  A)
      END