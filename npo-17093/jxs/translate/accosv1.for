       SUBROUTINE DECODE1 
C*****THIS SUBROUTINE TRANSLATES AN ACCOS DATA FILE TO A CODEV LENS DECK
C
C** COMMON BLOCK ACCOSV DECLARATIONS
      CHARACTER*6 UNITS
      INTEGER*4 IORDER(66),IWT1,IWT2,IWT3,IWT4,IWT5
      REAL*4 WVW1,WVW2,WVW3,WVW4,WVW5,WT1,WT2,WT3,WT4,WT5,THETA(66)
      REAL*4 RN1
      REAL*8 N1(99),N2(99),N3(99),N4(99),N5(99),F2(225)
C** COMMON BLOCK BOTH DECLARATIONS
C BBC 9/20/84. ADDED THE VARIABLES NCONF(),ACVAL(),CPARM(), AND I11 TO HANDLE
C ALTERNATE CONFIGURATIONS.
      CHARACTER*4 SOLVE(40)
      CHARACTER*3 CPARM(30)
      CHARACTER*13 GLASS(0:225)
      CHARACTER*64 TITLE
      INTEGER*4 I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11,M,ISTOP,IREF,ISURF
      INTEGER*4 NAPERT(225),NDECE(100),NSOLVE(40),NUMA,MESSAGE(20)
      REAL*4 DIF(66)
      REAL*8 ADE(100),BDE(100),CDE(100),XDE(100),YDE(100),CURVEY(0:225)
      REAL*8 THICKNS(0:225),RK(66),A(66),B(66),C(66),D(66),SOLVF1(40)
      REAL*8 F1(225),REF_OBJ_HT
      LOGICAL AFO,IC(66),CUF(66)
C** COMMON BLOCK ACONLY DECLARATIONS
      CHARACTER*4 TORIC(10),COMMAND(100),PIKUP(200),SHAPE(225),CASE(10)
      CHARACTER*4 SPECSF(225)
      CHARACTER*36 SUBMES1(20)
      CHARACTER*40 SUBMES2(20)
      CHARACTER*48 SUBMES3(20)
      INTEGER*4 INDEX(20),NTORIC(10),NCASE(10),NUMBER(10),IPIKTO(200)
      INTEGER*4 IPIKFR(200),NASP(66),J10,K1,NGRT(10),NSHAPE(225)
      REAL*4 PIKA(200),DDIST(10),RNUMBER(10),RIC1(225),RIC2(225)
      REAL*4 RCUF1(225),RCUF2(225)
      REAL*8 TCVR(10),PY,PUCY,RADIUS(0:225),PIKB(200),NAO,YAN
      LOGICAL OB(225)
C** LOCAL DECLARATIONS
      CHARACTER*4 CVAR		! JPL CHANGE.
      INTEGER*4 NMODELS,CFG1,REF_SURF
      CHARACTER*110 LINE
      INTEGER*4 DUMMY(100)
      LOGICAL SAME
C
      COMMON /ACCOSV/IORDER,WVW1,WVW2,WVW3,WVW4,WVW5,WT1,WT2,WT3,WT4,
     *        WT5,IWT1,IWT2,IWT3,IWT4,IWT5,THETA,F2,RN1,UNITS,N1,
     *        N2,N3,N4,N5
      COMMON /BOTH/I1,I2,I3,I4,I5,I6,I7,I8,I9,I10,I11,GLASS,MESSAGE,M,
     *        ISTOP,IREF,ISURF,AFO,NAPERT,NDECE,F1,DIF,ADE,BDE,CDE,XDE,
     *        YDE,CURVEY,THICKNS,RK,A,B,C,D,IC,CUF,NSOLVE,SOLVF1,SOLVE,
     *        TITLE,NUMA,REF_OBJ_HT
      COMMON /ACONLY/TCVR,PY,PUCY,INDEX,NTORIC,DDIST,SUBMES1,SUBMES2,
     *        SUBMES3,TORIC,NCASE,COMMAND,NUMBER,RADIUS,PIKA,PIKB,
     *        IPIKTO,IPIKFR,PIKUP,SHAPE,CASE,NASP,OB,SPECSF,NAO,YAN,
     *        J10,K1,NGRT,RIC1,RIC2,RCUF1,RCUF2,RNUMBER,NSHAPE
C
C******************************************************************************
C*****FORMAT STATEMENTS
C HAD TO CHANGE SOME OF THE FORMATS. VAX WAS ADDING A ZERO TO THE RIGHT END OF
C SOME OF THE INTEGERS BECAUSE AN EXTRA BLANK SPACE WAS READ. BBC 9/84.
  2   FORMAT(A110)
  3   FORMAT(5X,E15.6,1X,E15.6,3X,A13,3X,E8.6)
  4   FORMAT(5X,F15.6,1X,F15.6,3X,A13)
  5   FORMAT(1X,I3)
  6   FORMAT(1X,I3,3X,F9.6,2X,F9.6,2X,F9.6,2X,F9.6,2X,F9.6)
  7   FORMAT(19X,F13.6,1X,F13.6,3X,A13,3X,F8.6)
  8   FORMAT(1X,I3,1X,F13.5,F13.5,F13.5,F13.5,F13.5)
  9   FORMAT(19X,F13.6,1X,F13.6,3X,A13)
 10   FORMAT(2X,I3,4X,A4,17X,F6.3,16X,I4)
 12   FORMAT(1X,I3,4X,A4,F14.6)
 14   FORMAT(1X,I3,1X,A4,3X,A4,6X,F10.4,4X,F8.4)
 16   FORMAT(1X,I3,3X,A4,2X,F11.5,1X,F11.5,1X,F10.4,1X,F10.4,1X,F10.4)
 18   FORMAT(1X,I3,4X,A4,2X,I4,2X,F10.6,2X,F10.6)
 20   FORMAT(1X,I3,4X,A4,28X,F10.6)
 22   FORMAT(16X,F8.5,3X,F8.5,3X,F8.5,3X,F8.5,3X,F8.5)
 24   FORMAT(22X,I3)
 26   FORMAT(16X,A6)
 28   FORMAT(20X,A4)
 30   FORMAT(7X,F12.7,30X,F12.7)
 31   FORMAT(11X,A3,7X,I2,1X,E13.6)
 32   FORMAT(E14.6,40X,I3)
C******************************************************************************
C*****INITIALIZE
C
      L=0
      I1=0
      I2=0
      I3=0
      I4=0
      I6=0
      I7=0
      I8=0
      I9=0
      I10=0
      SAME=.FALSE.
      DO 100,I=1,225
        OB(I)=.FALSE.
100   CONTINUE
      M=0
      AFO=.FALSE.
      DO 110,I=1,20
        N1(I)=0.0
        N2(I)=0.0
        N3(I)=0.0
        N4(I)=0.0
        N5(I)=0.0
110   CONTINUE
      WT1=0.0
      WT2=0.0
      WT3=0.0
      WT4=0.0
      WT5=0.0
      WVW1=0.0
      WVW2=0.0
      WVW3=0.0
      WVW4=0.0
      WVW5=0.0
      DO 120,I=1,66
        RK(I)=0.0
        A(I)=0.0
        B(I)=0.0
        C(I)=0.0
        D(I)=0.0
120   CONTINUE
      DO 130,I=1,200
        PIKA(I)=1.0
130   CONTINUE
C******************************************************************************
C*****MAIN PROGRAM
C
C*****BA:`8NSBDATA
200   READ(6,2)LINE
      IF (LINE(2:6) .NE. '     ') THEN
        TITLE=LINE(2:64)
      ELSE
        GOTO 200
      END IF
205   READ(6,2,END=206)LINE
      IF (LINE(2:6) .NE. 'BASIC') GOTO 205
      READ(6,2)LINE
      IF (LINE(13:14) .EQ. 'CV') GOTO 220
      GOTO 210
C ACCOUNT FOR HITTING END-OF-FILE. BBC 9/84.
206   PRINT *,'COULD NOT FIND KEYWORD: BASIC IN COLUMN 2. PROGRAM HALT.'
      CALL EXIT
210   READ(6,2)LINE
      IF (LINE(4:5) .EQ. '  ') GOTO 210
      IF (LINE(5:5) .NE. ' ') GOTO 215
      IF (L .EQ. 0) THEN
        READ(LINE,3)RADIUS(L),THICKNS(L),GLASS(L),RN1
      ELSE
        READ(LINE,4)RADIUS(L),THICKNS(L),GLASS(L)
      END IF
      L=L+1
      GOTO 210
215   ISURF=L-1
      GOTO 240
220   READ(6,2)LINE
      IF (LINE(4:4) .EQ. ' ') GOTO 220
      IF (LINE(5:5) .NE. ' ') GOTO 230
      IF (L .EQ. 0) THEN
        READ(LINE,7)RADIUS(L),THICKNS(L),GLASS(L),RN1
      ELSE
        READ(LINE,9)RADIUS(L),THICKNS(L),GLASS(L)
      END IF
      L=L+1
      GOTO 220
230   ISURF=L-1
C******************************************************************************
C*****DETERMINE NEXT CATEGORY
240   IF (LINE(2:11) .EQ. 'REFRACTIVE') THEN
        GOTO 250
      ELSE IF (LINE(2:16) .EQ. 'CC AND ASPHERIC') THEN
        GOTO 300
      ELSE IF (LINE(2:11) .EQ. 'ASYMMETRIC') THEN
        GOTO 350
      ELSE IF (LINE(2:10) .EQ. 'SYMMETRIC') THEN
        GOTO 400
      ELSE IF (LINE(2:11) .EQ. 'ANAMORPHIC') THEN
        GOTO 425
      ELSE IF (LINE(2:7) .EQ. 'TORICS') THEN
        GOTO 450
      ELSE IF (LINE(3:9) .EQ. 'SPECIAL') THEN
        GOTO 500
      ELSE IF (LINE(2:5) .EQ. 'TILT') THEN
        GOTO 550
      ELSE IF (LINE(2:6) .EQ. 'CLEAR') THEN
        GOTO 600
      ELSE IF (LINE(2:8) .EQ. 'PICKUPS') THEN
        GOTO 650
      ELSE IF (LINE(2:7) .EQ. 'SOLVES') THEN
        GOTO 700
C READ 'REF SURF' JUST IN CASE WE GET A 'NO APERTURE STOP'. BBC 10/84.
      ELSE IF (LINE(53:60) .EQ. 'REF SURF') THEN
        READ(6,2)LINE
        READ(LINE,32) REF_OBJ_HT,REF_SURF
        READ(6,2)LINE	! SHOULD BE A BLANK LINE.
        GOTO 245
      ELSE IF (LINE(3:3) .EQ. ' ') THEN
245     READ(6,2)LINE
        GOTO 240
      ELSE
        GOTO 750
      END IF
C******************************************************************************
C*****REFRACTIVE INDICES
250   READ(6,2)LINE  ! SKIP 2 LINES
      READ(6,2)LINE
260   READ(6,2)LINE
      SAME=.FALSE.
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I7=I7+1
      READ(LINE,6)INDEX(I7),N1(I7),N2(I7),N3(I7),N4(I7),N5(I7)
      DO 265,K=1,I7-1
C IF N1 PARAM = 1.0 THEN KEEP UNIQUE GLASS NAME FOR THE PRINTOUT. BBC 10/84.
        IF ((N1(K) .EQ. N1(I7)) .AND. (N2(K) .EQ. N2(I7)) .AND.
     *      (N3(K) .EQ. N3(I7)) .AND. (N4(K) .EQ. N4(I7)) .AND.
     *      (N5(K) .EQ. N5(I7)) .AND. (N1(K) .NE. 1.0)) THEN
           GLASS(INDEX(I7))=GLASS(INDEX(K))
           SAME = .TRUE.
	ELSE IF ((GLASS(INDEX(I7))(1:5).EQ.'MODEL').AND.
     *          (GLASS(INDEX(K)) .EQ. GLASS(INDEX(I7)))) THEN
C**THE FOLLOWING STATEMENTS ARE NECESSARY BECAUSE THE 'CHAR' FUNCTION
C DOES NOT WORK. JPL CHANGE.
	   NMODELS=INDEX(I7)
	   IF(NMODELS.EQ.0) CVAR='0   '
	   IF(NMODELS.EQ.1) CVAR='1   '
	   IF(NMODELS.EQ.2) CVAR='2   '
	   IF(NMODELS.EQ.3) CVAR='3   '
	   IF(NMODELS.EQ.4) CVAR='4   '
	   IF(NMODELS.EQ.5) CVAR='5   '
	   IF(NMODELS.EQ.6) CVAR='6   '
	   IF(NMODELS.EQ.7) CVAR='7   '
	   IF(NMODELS.EQ.8) CVAR='8   '
	   IF(NMODELS.EQ.9) CVAR='9   '
	   IF(NMODELS.EQ.10) CVAR='10   '
	   IF(NMODELS.EQ.11) CVAR='11  '
	   IF(NMODELS.EQ.12) CVAR='12  '
	   IF(NMODELS.EQ.13) CVAR='13  '
	   IF(NMODELS.EQ.14) CVAR='14  '
	   IF(NMODELS.EQ.15) CVAR='15  '
	   IF(NMODELS.EQ.16) CVAR='16  '
	   IF(NMODELS.EQ.17) CVAR='17  '
	   IF(NMODELS.EQ.18) CVAR='18  '
	   IF(NMODELS.EQ.19) CVAR='19  '
	   IF(NMODELS.EQ.20) CVAR='20  '
	   IF(NMODELS.EQ.21) CVAR='21  '
	   IF(NMODELS.EQ.22) CVAR='22  '
	   IF(NMODELS.EQ.23) CVAR='23  '
	   IF(NMODELS.EQ.24) CVAR='24  '
	   IF(NMODELS.EQ.25) CVAR='25  '
	   IF(NMODELS.EQ.26) CVAR='26  '
	   IF(NMODELS.EQ.27) CVAR='27  '
	   IF(NMODELS.EQ.28) CVAR='28  '
	   IF(NMODELS.EQ.29) CVAR='29  '
	   IF(NMODELS.EQ.30) CVAR='30  '
C     CVAR='    '
C     CVAR=CHAR(INTS(INDEX(I7)))
	   GLASS(INDEX(I7))=GLASS(INDEX(I7))(1:5)//CVAR
	END IF
C***** DROP DUPLICATE PRIVATE CATALOG ENTRIES
265   CONTINUE
      IF (SAME) I7=I7-1
      IF ((GLASS(INDEX(I7))(1:6) .EQ. 'SCHOTT') .OR.
     *    (GLASS(INDEX(I7))(1:4) .EQ. 'HOYA') .OR.
     *    (GLASS(INDEX(I7))(1:5) .EQ. 'OHARA')) I7=I7-1
      GOTO 260
C******************************************************************************
C*****CC AND ASPHERIC DATA
300   READ(6,2)LINE  ! SKIP 2 LINES
      READ(6,2)LINE
320   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I4=I4+1
      READ(LINE,8)NASP(I4),RK(I4),A(I4),B(I4),C(I4),D(I4)
      GOTO 320
C******************************************************************************
C*****ASYMMETRIC SPLINE
350   M=M+1
      MESSAGE(M)=1
      SUBMES1(M)=LINE(2:37)
      GOTO 245
C******************************************************************************
C*****SYMMETRIC SPLINE
400   M=M+1
      MESSAGE(M)=1
      SUBMES1(M)=LINE(2:37)
      GOTO 245
C******************************************************************************
C*****ANAMORPHIC ASPHERIC
425   M=M+1
      MESSAGE(M)=1
      SUBMES1(M)=LINE(2:37)
      READ(6,2)LINE !SKIP BLANK LINE
430   READ(6,2)LINE  ! SKIP ANAMORPHIC DATA
      IF (LINE(2:5) .NE. '    ') GOTO 430
      GOTO 245
C******************************************************************************
C*****TORICS
450   READ(6,2)LINE  ! SKIP A LINE
      READ(6,2)LINE  ! SKIP A LINE.	BBC. 9/18/84.
460   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '   ') GOTO 245
      I8=I8+1
      READ(LINE,12)NTORIC(I8),TORIC(I8),TCVR(I8)
      IF (TORIC(I8) .EQ. '  X ') THEN
        M=M+1
        MESSAGE(M)=2
        I8=I8-1  ! DROP X-TORIC
      END IF
      GOTO 460
C******************************************************************************
C*****SPECIAL CONDITIONS
500   READ(6,2)LINE  ! SKIP 2 LINES
      READ(6,2)LINE
520   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I3=I3+1
      READ(LINE,10)NCASE(I3),CASE(I3),DDIST(I3),NUMBER(I3)
      GOTO 520
C******************************************************************************
C*****TILT AND DECENTER DATA
550   READ(6,2)LINE  ! SKIP 2 LINES
      READ(6,2)LINE
560   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I2=I2+1
      READ(LINE,16)NDECE(I2),COMMAND(I2),YDE(I2),XDE(I2),ADE(I2),
     *  BDE(I2),CDE(I2)
      GOTO 560
C******************************************************************************
C*****CLEAR APERTURES AND OBSTRUCTIONS
600   READ(6,2)LINE
      READ(6,2)LINE
620   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I1=I1+1
      READ(LINE,14)NSHAPE(I1),FLAG1,SHAPE(I1),F2(I1),F1(I1)
      IF (FLAG1 .EQ. '(OB)') OB(I1)=.TRUE.
      GOTO 620
C******************************************************************************
C*****PICKUPS
650   READ(6,2)LINE  ! SKIP 2 LINES
      READ(6,2)LINE
660   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I10=I10+1
      READ(LINE,18)IPIKFR(I10),PIKUP(I10),IPIKTO(I10),PIKA(I10),
     *  PIKB(I10)
      IF (PIKB(I10) .NE. 0.0) THEN
        M=M+1
        MESSAGE(M)=3
        SUBMES2(M)=LINE(3:42)
        I10=I10-1  ! DROP PICKUP WITH B VALUE
      END IF
      IF ((ABS(PIKA(I10)) .NE. 1.0) .AND. (PIKA(I10) .NE. 0.0)) THEN
        M=M+1
        MESSAGE(M)=6
        SUBMES2(M)=LINE(3:42)
        I10=I10-1
      END IF  ! DROP PICKUP WITH A VALUE NOT EQUAL TO +-1.0
      IF ((PIKUP(I10) .EQ. 'CLAP') .OR. (PIKUP(I10) .EQ. 'COBS')) THEN
        M=M+1
        MESSAGE(M)=4
        SUBMES2(M)=LINE(3:42)
        I10=I10-1  ! DROP CLAP OR COBS PICKUP
      END IF
      GOTO 660
C******************************************************************************
C*****SOLVES
700   READ(6,2)LINE ! SKIP 2 LINES
      READ(6,2)LINE
710   READ(6,2)LINE
      IF (LINE(2:5) .EQ. '    ') GOTO 245
      I6=I6+1
      READ(LINE,20)NSOLVE(I6),SOLVE(I6),SOLVF1(I6)
      IF ((SOLVE(I6) .EQ. 'CAY ') .OR. (SOLVE(I6) .EQ. 'PWRY') .OR.
     *    (SOLVE(I6) .EQ. 'PWRX') .OR. (SOLVE(I6) .EQ. 'CAX ')) THEN
        M=M+1
        MESSAGE(M)=5
        SUBMES3(M)=LINE(3:50)
        I6=I6-1  ! DROP DATA LINE
      END IF
      GOTO 710
C******************************************************************************
C*****ALTERNATE CONFIGURATIONS. BBC 9/20/84.
725   I11 = 0
      READ (6,2) LINE		! READ NEXT FOUR LINES.
      WRITE (5,244) LINE(1:78)
      READ (6,2) LINE
      WRITE (5,244) LINE(1:78)
      READ (6,2) LINE
      WRITE (5,244) LINE(1:78)
727   READ (6,2) LINE
      IF (LINE(2:14) .EQ. '             ') GOTO 750
      WRITE (5,244) LINE(1:78)
C      IF (LINE(2:4) .EQ. 'CFG') THEN
C      READ (LINE,32) CFG1
C      ELSE
C        I11 = I11 + 1
C        READ (LINE,31) CPARM(I11),NCONF(I11),ACVAL(I11)
C        CFG(I11) = CFG1
C      END IF
      GOTO 727		! DECODE THE NEXT LINE
C******************************************************************************
C*****GENERAL DATA
750   READ(6,2)LINE
      IF (LINE(2:11) .EQ. 'WAVELENGTH') THEN
        READ(LINE,22)WVW1,WVW2,WVW3,WVW4,WVW5
      ELSE IF (LINE(2:9) .EQ. 'SPECTRAL') THEN
        READ(LINE,22)WT1,WT2,WT3,WT4,WT5
      ELSE IF (LINE(2:9) .EQ. 'APERTURE') THEN
        READ(LINE,24)ISTOP
C IF 'NO APERTURE STOP' LINE, THEN 'S' DEFAULTS TO 'REF SURF'. BBC 10/84.
      ELSE IF (LINE(2:17) .EQ. 'NO APERTURE STOP') THEN
        ISTOP = REF_SURF
      ELSE IF (LINE(7:11) .EQ. 'UNITS') THEN
        READ(LINE,26)UNITS
      ELSE IF (LINE(13:16) .EQ. 'MODE') THEN
        READ(LINE,28)FLAG1
        IF (FLAG1 .EQ. 'AFOC') AFO=.TRUE.
      ELSE IF (LINE(2:8) .EQ. 'CONTROL') THEN
        READ(LINE,24)IREF
      ELSE IF (LINE(2:4) .EQ. 'PXT') THEN
        GOTO 800
C BBC 9/20/84. INSERT CODE TO HANDLE 'ALTERNATE CONFIGURATIONS'.
      ELSE IF (LINE(2:10) .EQ. 'ALTERNATE') THEN
        WRITE (5,244) LINE(1:78)
244     FORMAT (' :',A78)
        GOTO 725
      ELSE
        GOTO 750
      END IF
      GOTO 750
C******************************************************************************
C*****PXTY ALL: APERTURE AND FIELD SPECIFICATION
800   READ(6,2)LINE
      IF (LINE(4:4) .NE. '1') GOTO 800
      READ(LINE,30)PY,PUCY
C*****TEST PRINT
C      PRINT*, 'ISURF=',ISURF
C      DO 850,I=0,ISURF
C        PRINT*, I,' RADIUS',RADIUS(I),'THICKNS',THICKNS(I),
C     *     'GLASS',GLASS(I)
C850   CONTINUE
C      PRINT*, 'RN1',RN1
C      PRINT*, 'REFRACTIVE INDICES'
C      DO 860,I=1,I7
C      PRINT*, INDEX(I),N1(I),N2(I),N3(I),N4(I),N5(I)
C860   CONTINUE
C      PRINT*, 'ASPHERIC'
C      DO 870,I=1,I4
C      PRINT*, NASP(I),RK(I),A(I),B(I),C(I),D(I)
C870   CONTINUE
C      PRINT*, 'TORICS'
C      DO 880,I=1,I8
C        PRINT*, NTORIC(I),TORIC(I),TCVR(I)
C880   CONTINUE
C      PRINT*, 'SPECIAL CONDITIONS'
C      DO 890,I=1,I3
C        PRINT*, NCASE(I),CASE(I),DDIST(I),NUMBER(I)
C890   CONTINUE
C      PRINT*, 'TILT AND DECENTER'
C      DO 900,I=1,I2
C        PRINT*, NDECE(I),COMMAND(I),YDE(I),XDE(I),ADE(I),BDE(I),CDE(I)
C900   CONTINUE
C      PRINT*, 'APERTURES'
C      DO 910, I=1,I1
C        PRINT*, NAPERT(I),OB(I),SHAPE(I),F2(I),F1(I)
C910   CONTINUE
C      PRINT*, 'PICKUPS'
C      DO 920,I=1,I10
C        PRINT*, IPIKFR(I),PIKUP(I),IPIKTO(I),PIKA(I),PIKB(I)
C920   CONTINUE
C      PRINT*, 'SOLVES'
C      DO 930,I=1,I6
C        PRINT*, NSOLVE(I),SOLVE(I),SOLVF1(I)
C930   CONTINUE
C      PRINT*, 'WAVELENGTHS'
C      PRINT*, WVW1,WVW2,WVW3,WVW4,WVW5
C      PRINT*, 'WEIGHTS',WT1,WT2,WT3,WT4,WT5
C      PRINT*, 'ISTOP=',ISTOP
C      PRINT*, 'UNITS=',UNITS
C      PRINT*, 'AFOCAL=',AFO
C      PRINT*, 'IREF=',IREF
C      PRINT*, 'PY=',PY,'PUCY=',PUCY
C
      RETURN
      END