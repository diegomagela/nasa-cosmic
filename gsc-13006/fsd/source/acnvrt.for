      SUBROUTINE ACNVRT(IDATE,SECOND)
      IMPLICIT REAL*8 (A-H,O-Z)
C
C     ACNVRT CONVERTS A SIX DIGIT INTEGER (YYMMDD) AND SECONDS TO
C     SECONDS FROM START OF THE YEAR
C     NO TAPES AND NO SUBROUTINES ARE REQUIRED
      DIMENSION JULDAY(12)
C
      DATA JULDAY/ 0,31,59,90,120,151,181,212,243,273,304,334/
      IY=IDATE/10000
      IM=(IDATE - IY*10000)/100
      IDAY=MOD(IDATE,100)-1
      IF(MOD(IY,4).EQ.0.AND.IM.GT.2) IDAY=IDAY + 1
      JDAY=JULDAY(IM) + IDAY
      SECOND=DFLOAT(JDAY)*8.64D4 + SECOND
      RETURN
      END
