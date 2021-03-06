      SUBROUTINE FOUR(DATA,NN,ISIGN)
C
C     THE COOLEY-TUKEY FAST FOURIER TRANSFORM IN USASI BASIC FORTRAN
C
C     TRANSFORM(K)=SUM(DATA(J)*EXP(ISIGN*2*PI*SQRT(-1)*(K-1)*(J-1)/NN)),
C     SUMMED FOR ALL J, K, BETWEEN 1 AND NN.  DATA IS A COMPLEX ARRAY OF
C     LENGTH NN.  THE REAL AND IMAGINARY PARTS ARE ADJACENT IN STORAGE
C     SUCH AS FORTRAN IV PLACES THEM.  ITS DIMENSION IS A POWER OF TWO
C     (.GE. 1).  IF NECESSARY, APPEND ZEROES TO THE DATA TO GET A POWER
C     OF TWO.   ISIGN IS +1 OR -1.  IF A -1 TRANSFORM IS FOLLOWED BY A
C     +1 (OR A +1 BY A -1) THE ORIGINAL DATA REAPPEAR, MULTIPLIED BY NN.
C     TRANSFORM VALUES ARE RETURNED IN ARRAY DATA, REPLACING THE INPUT.
C     WRITTEN BY NORMAN BRENNER FROM THE BASIC PROGRAM OF CHARLES RADER.
C     RALPH ALTER SUGGESTED THE METHOD OF BIT REVERSAL. MIT LINCOLN
C     LABORATORY, AUGUST 1967.
C     SEE-- IEEE AUDIO TRANSACTIONS (JUNE 1967), SPECIAL ISSUE ON FFT.
C
      DIMENSION DATA(1)
      DATA TWOPI /6.283185/
      NTOT=2*NN
C
      NP1=2
      N=NN
      NP2=NP1*N
      IF(N-1)700,600,100
C
C     SHUFFLE DATA BY BIT REVERSAL, SINCE N=2**K.  AS THE SHUFFLING
C     CAN BE DONE BY SIMPLE INTERCHANGE, NO WORKING ARRAY IS NEEDED
C
100   NP2HF=NP2/2
      J=1
      DO 160 I2=1,NP2,NP1
      IF(J-I2)110,130,130
110   I1MAX=I2+NP1-2
      DO 120 I1=I2,I1MAX,2
      DO 120 I3=I1,NTOT,NP2
      J3=J+I3-I2
      TEMPR=DATA(I3)
      TEMPI=DATA(I3+1)
      DATA(I3)=DATA(J3)
      DATA(I3+1)=DATA(J3+1)
      DATA(J3)=TEMPR
120   DATA(J3+1)=TEMPI
130   M=NP2HF
140   IF(J-M)160,160,150
150   J=J-M
      M=M/2
      IF(M-NP1)160,140,140
160   J=J+M
C
C     MAIN LOOP.  PERFORM FOURIER TRANSFORMS OF LENGTH FOUR, WITH ONE OF
C     LENGTH TWO IF NEEDED.  THE TWIDDLE FACTOR W=EXP(ISIGN*2*PI*
C     SQRT(-1)*M/(4*MMAX)).  CHECK FOR THE SPECIAL CASE W=ISIGN*SQRT(-1)
C     AND REPEAT FOR W=ISIGN*SQRT(-1)*CONJUGATE(W).
C
      NP1TW=NP1+NP1
      IPAR=N
310   IF(IPAR-2)350,330,320
320   IPAR=IPAR/4
      GO TO 310
330   DO 340 I1=1,NP1,2
      DO 340 K1=I1,NTOT,NP1TW
      K2=K1+NP1
      TEMPR=DATA(K2)
      TEMPI=DATA(K2+1)
      DATA(K2)=DATA(K1)-TEMPR
      DATA(K2+1)=DATA(K1+1)-TEMPI
      DATA(K1)=DATA(K1)+TEMPR
340   DATA(K1+1)=DATA(K1+1)+TEMPI
350   MMAX=NP1
360   IF(MMAX-NP2HF)370,600,600
370   LMAX=MAX0(NP1TW,MMAX/2)
      IF(MMAX-NP1)405,405,380
380   THETA=-TWOPI*FLOAT(NP1)/FLOAT(4*MMAX)
      IF(ISIGN)400,390,390
390   THETA=-THETA
400   WR=COS(THETA)
      WI=SIN(THETA)
      WSTPR=-2.*WI*WI
      WSTPI=2.*WR*WI
405   DO 570 L=NP1,LMAX,NP1TW
      M=L
      IF(MMAX-NP1)420,420,410
410   W2R=WR*WR-WI*WI
      W2I=2.*WR*WI
      W3R=W2R*WR-W2I*WI
      W3I=W2R*WI+W2I*WR
420   DO 530 I1=1,NP1,2
      KMIN=IPAR*M+I1
      IF(MMAX-NP1)430,430,440
430   KMIN=I1
440   KDIF=IPAR*MMAX
450   KSTEP=4*KDIF
      DO 520 K1=KMIN,NTOT,KSTEP
      K2=K1+KDIF
      K3=K2+KDIF
      K4=K3+KDIF
      IF(MMAX-NP1)460,460,480
460   U1R=DATA(K1)+DATA(K2)
      U1I=DATA(K1+1)+DATA(K2+1)
      U2R=DATA(K3)+DATA(K4)
      U2I=DATA(K3+1)+DATA(K4+1)
      U3R=DATA(K1)-DATA(K2)
      U3I=DATA(K1+1)-DATA(K2+1)
      IF(ISIGN)470,475,475
470   U4R=DATA(K3+1)-DATA(K4+1)
      U4I=DATA(K4)-DATA(K3)
      GO TO 510
475   U4R=DATA(K4+1)-DATA(K3+1)
      U4I=DATA(K3)-DATA(K4)
      GO TO 510
480   T2R=W2R*DATA(K2)-W2I*DATA(K2+1)
      T2I=W2R*DATA(K2+1)+W2I*DATA(K2)
      T3R=WR*DATA(K3)-WI*DATA(K3+1)
      T3I=WR*DATA(K3+1)+WI*DATA(K3)
      T4R=W3R*DATA(K4)-W3I*DATA(K4+1)
      T4I=W3R*DATA(K4+1)+W3I*DATA(K4)
      U1R=DATA(K1)+T2R
      U1I=DATA(K1+1)+T2I
      U2R=T3R+T4R
      U2I=T3I+T4I
      U3R=DATA(K1)-T2R
      U3I=DATA(K1+1)-T2I
      IF(ISIGN)490,500,500
490   U4R=T3I-T4I
      U4I=T4R-T3R
      GO TO 510
500   U4R=T4I-T3I
      U4I=T3R-T4R
510   DATA(K1)=U1R+U2R
      DATA(K1+1)=U1I+U2I
      DATA(K2)=U3R+U4R
      DATA(K2+1)=U3I+U4I
      DATA(K3)=U1R-U2R
      DATA(K3+1)=U1I-U2I
      DATA(K4)=U3R-U4R
520   DATA(K4+1)=U3I-U4I
      KMIN=4*(KMIN-I1)+I1
      KDIF=KSTEP
      IF(KDIF-NP2)450,530,530
530   CONTINUE
      M=MMAX-M
      IF(MMAX-NP1) 580,580,535
535   CONTINUE
      IF(ISIGN)540,550,550
540   TEMPR=WR
      WR=-WI
      WI=-TEMPR
      GO TO 560
550   TEMPR=WR
      WR=WI
      WI=TEMPR
560   IF(M-LMAX)565,565,410
565   TEMPR=WR
      WR=WR*WSTPR-WI*WSTPI+WR
570   WI=WI*WSTPR+TEMPR*WSTPI+WI
580   CONTINUE
      IPAR=3-IPAR
      MMAX=MMAX+MMAX
      GO TO 360
C
C     END OF LOOP OVER EACH DIMENSION
C
600   NP1=NP2
700   RETURN
      END
