      SUBROUTINE IGCAL(INOPT,YYSO,XICO,ZMS,SA,S,IG)
C
C     'IGCAL' CALCULATES THE TOTAL MOMENT OF INERTIA OF THE SATELLITE
C     IN INERTIAL SPACE ABOUT THE CENTER OF MASS OF THE SATELLITE.
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 IG(3,3)
C
      COMMON/DEBUG3/ ISWTCH
C
C
      DIMENSION YYSO(3,3),XICO(3),SUSE(3,3),SUSET(3,3),SA(3,3),S(3,3),
     .          DUM(3,3),D(3),XXSO(3,3)
C
C
      DO 10 I=1,3
      DO 10 J=1,3
   10 SUSE(I,J)=SA(I,J)
C
      CALL MATRAN(SUSE,SUSET,3,3)
      IF(ISWTCH.NE.0) GO TO 40
      WRITE(6,10000) INOPT
      WRITE(6,10002) ((SUSE(I,J),J=1,3),I=1,3)
      WRITE(6,10003)
      WRITE(6,10002) ((SUSET(I,J),J=1,3),I=1,3)
   40 CALL MULTM(SUSE,XICO,D,3,1,3)
      IF(ISWTCH.EQ.0) WRITE(6,10004) (D(I),I=1,3)
      CALL MULTM(SUSE,YYSO,DUM,3,3,3)
      IF(ISWTCH.EQ.0) WRITE(6,10005) ((DUM(I,J),J=1,3),I=1,3)
      CALL MULTM(DUM,SUSET,XXSO,3,3,3)
      IF(ISWTCH.EQ.0) WRITE(6,10006) ((XXSO(I,J),J=1,3),I=1,3)
C
      DO 50 I=1,3
      DO 50 J=1,3
   50 DUM(I,J)=D(I)*D(J)
      IF(ISWTCH.EQ.0) WRITE(6,10005) ((DUM(I,J),J=1,3),I=1,3)
      DO 60 I=1,3
      DO 60 J=1,3
   60 IG(I,J)=XXSO(I,J) - ZMS*DUM(I,J)
C
      RETURN
C
C
10000 FORMAT('0',2X,'INOPT ',I2)
C
10001 FORMAT('0',2X,'SUSE')
C
10002 FORMAT('0',2X,3(G20.13,2X)/3X,3(G20.13,2X)/3X,3(G20.13,2X))
C
10003 FORMAT('0',2X,'SUSE TRANSPOSE')
C
10004 FORMAT('0',2X,'D ',3(G20.13,2X))
C
10005 FORMAT('0',2X,'DUM ',3(G20.13,2X)/3X,3(G20.13,2X)/3X,3(G20.13,2X))
C
10006 FORMAT('0',2X,'XXSO',3(G20.13,2X)/3X,3(G20.13,2X)/3X,3(G20.13,2X))
C
      END
