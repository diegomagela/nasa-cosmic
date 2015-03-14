      SUBROUTINE INFDCK (*,NEWDEN,OLDDEN)
      DIMENSION TABLON(200), XTAB(200), YTAB(200), ZTAB(200)
      DOUBLE PRECISION F(3), SLONG
      REAL NEWDEN
      SAVE TOPLON,BOTLON,XTAB,YTAB,ZTAB,TABLON
      RAT=NEWDEN/OLDDEN
      N = 0
      OLDLON = 999.0
   10 READ (5, 20) W, X, Y, Z
   20 FORMAT (26X, 4E13.7)
      M = N + 1
      WRITE (6, 25) M, W, X, Y, Z
   25 FORMAT (I4, 4E13.7)
      IF (W .LT. -1000.0) GO TO 70
      IF (W .LT. OLDLON) GO TO 40
      WRITE (6, 30) N, OLDLON, W
   30 FORMAT (29H1ERROR IN ORBSIM FORCES TABLE/ 19H0LONGITUDES NOT IN ,
     1 24HDESCENDING ORDER.  CARD , I3, 18H HAS LONGITUDE OF , E13.7,
     2 37H, AND THE NEXT CARD HAD LONGITUDE OF , E13.7)
      RETURN 1
   40 IF (N .LT. 200) GO TO 60
      WRITE (6, 50)
   50 FORMAT (29H1ERROR IN ORBSIM FORCES TABLE/ 15H0MORE THAN 200 ,
     1 15HCARDS IN TABLE.)
      RETURN 1
   60 N = N + 1
      OLDLON = W
      TABLON(N) = W
      XTAB(N) = X*RAT
      YTAB(N) = Y*RAT
      ZTAB(N) = Z*RAT
      GO TO 10
   70 IF (N .GT. 0) GO TO 80
      TOPLON = 0.0
      BOTLON = 10.0
      GO TO 90
   80 TOPLON = TABLON(1)
      BOTLON = TABLON(N)
   90 RETURN
      ENTRY FCALC (*, SLONG, F)
      TLONG = SNGL (SLONG)
      IF (TLONG .GT. TOPLON) GO TO 130
      IF (TLONG .LT. BOTLON) GO TO 130
      DO 100 I = 2, N
      IF (TLONG .GE. TABLON(I)) GO TO 120
  100 CONTINUE
      WRITE (6, 110) N, BOTLON, TLONG, TABLON(N)
  110 FORMAT (29H1ERROR IN ORBSIM FORCES TABLE/ 17H0INPUT LONGITUDE ,
     1 24HDOESN'T COMPARE PROPERLY/ I4, 3E14.7)
      RETURN 1
  120 RATIO = (TLONG - TABLON(I))/(TABLON(I-1) - TABLON(I))
      F(1) = DBLE ((XTAB(I-1) - XTAB(I))*RATIO + XTAB(I))
      F(2) = DBLE ((YTAB(I-1) - YTAB(I))*RATIO + YTAB(I))
      F(3) = DBLE ((ZTAB(I-1) - ZTAB(I))*RATIO + ZTAB(I))
  130 RETURN
      END