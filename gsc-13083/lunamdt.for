      SUBROUTINE LUNAMDT(TSEC50,RMOON,IFLAG)
      IMPLICIT REAL*8(A-H,O-Z)
C
C    CALCULATE THE POSITION OF THE MOON IN MEAN OF DATE COORDINATES.
C
C
C     VARIABLE    TYPE    I/O         DESCRIPTION
C     --------    ----    ---         -----------
C
C     TSEC50       R*8     I     INPUT TIME IN SECONDS SINCE JAN 1 1950
C                                0.0 HOURS ET. MAY BE ANY VALUE, + OR -.
C                                ACCURACY IS NOT HIGH ENOUGH TO WARRANT
C                                AN ET-UT CORRECTION, SO TIME CAN BE UT
C                                IF IT IS MORE CONVENIENT.
C
C     RMOON(3)     R*8     O     VECTOR TO THE MOON FOR THAT TIME
C
C     IFLAG        I*4     I     EQ 1, RMOON IS UNIT VECTOR
C                                NE 1, RMOONIS IN KM.
C
C
C
C     POSITIONAL ACCURACY ABOUT .0005 RADIAN OR 200 KM
C        - TERMS WITH AMPLITUDES GREATER THAN 50 KM RETAINED
C
C     FORMULAE ARE FROM ASTRONOMICAL PAPERS PREPARED FOR THE USE OF THE
C     AMERICAN EPHEMERIS AND NAUTICAL ALMANAC, VOL. XV, PART I,
C     PAGES 52 - 62.
C
C     DAVID DUNHAM, COMPUTER SCIENCES CORP., 12/30/76. 
C     MINOR MODS BY C PETRUZZO, 12/82, BUT NOT TO CONSTANTS OR FORMULAE.
C                   CJP. 7/83. COMMENT MODS. NO EXECUTABLE CODE CHANGED.
C
C
      REAL*8 INCL,SECDAY/86400.D0/
      DIMENSION RMOON(3)
      REAL*8 TWOPI/ 6.283185307179586D0 /
      REAL*8 DEGRAD/ 57.29577951308232D0 /
      DATA ISTART/0/
C
      IF(ISTART.EQ.0) THEN
        CDR=1.D0/DEGRAD
        ISTART=1
C       EPOCH= 1900 JAN. 0.5 = J.D. 2415020.0  
        EPS0=23.452294D0*CDR
        EPSD=0.35626D-06*CDR
        CSR=CDR/3600.D0
        HP0=3422.54D0*CSR
        INCL=0.089503D0
        BLO=(270.D0+26.0499D0/60.D0)*CDR
        BLDOT=(1336.D0*360.D0+307.D0+52.9886D0/60.D0)*CDR
        BLDDOT=-4.08D0*CSR
        SLO=(296.D0+6.2764D0/60.D0)*CDR
        SLDOT=(1325.D0*360.D0+198.D0+50.9465D0/60.D0)*CDR
        SLDDOT=33.09D0*CSR
        SLPO=(358.D0+28.55D0/60.D0)*CDR
        SLPDOT=(99.D0*360.D0+359.D0+2.985D0/60.D0)*CDR
        FO=(11.D0+15.0533D0/60.D0)*CDR
        FDOT=(1342.D0*360.D0+82.D0+1.509D0/60.D0)*CDR
        FDDOT=-11.56D0*CSR
        DDO=(350.D0+44.2492D0/60.D0)*CDR
        DDOT=(1236.D0*360.D0+307.D0+6.853D0/60.D0)*CDR
        DDDOT=-5.17D0*CSR
C       CONVERT RATES TO NATURAL UNITS (1/TWOPI DAY)
        D=1.D0/36525.D0
        BLR=D*BLDOT
        SLR=D*SLDOT
        SLPR=D*SLPDOT
        FR=D*FDOT
        DR=D*DDOT
        END IF
C
C
      DA1950=TSEC50/SECDAY
      T=(DA1950+18262.5D0)/36525.0D0
      OBLIQ=     EPS0-EPSD*(DA1950+18262.5D0)
      SOB=DSIN(OBLIQ)
      COB=DCOS(OBLIQ)
      BL=DMOD(BLO+T*(BLDOT+BLDDOT*T),TWOPI)
      SL=DMOD(SLO+T*(SLDOT+SLDDOT*T),TWOPI)
      SLP=DMOD(SLPO+SLPDOT*T,TWOPI)
      F=DMOD(FO+T*(FDOT+FDDOT*T),TWOPI)
      D=DMOD(DDO+T*(DDOT+DDDOT*T),TWOPI)
      SSL =DSIN(SL)
      SSLP=DSIN(SLP)
      CSL=DCOS(SL)
      CSLP=DCOS(SLP)
      SD=DSIN(D)
      SF=DSIN(F)
      CD=DCOS(D)
      CF=DCOS(F)
      S2SL=2.D0*SSL*CSL
      S2D =2.D0*SD *CD
      S2F =2.D0*SF *CF
      C2SL=CSL*CSL-SSL*SSL
      C2D =CD *CD -SD *SD
      C2F =CF *CF -SF *SF
      S4D=2.D0*S2D*C2D
      C4D=C2D*C2D-S2D*S2D
      SNLMD2=SSL*C2D-CSL*S2D
      CLM2D=CSL*C2D+SSL*S2D
      SLCF=SSL*CF
      CLSF=CSL*SF
      SSLMF=SLCF-CLSF
      X1=SNLMD2*CSLP
      X2=CLM2D*SSLP
      SLPC2D=SSLP*C2D
      CLPS2D=CSLP*S2D
      SLCLP=SSL*CSLP
      CLSLP=CSL*SSLP
      SLC2F=SSL*C2F
      CLS2F=CSL*S2F
      AL1=SF*C2D
      AL2=CF*S2D
      Z1=CSL*C2D
      Z2=SSL*S2D
      Y1=CSL*CSLP
      Y2=SSL*SSLP
      S2LCF=S2SL*CF
      C2LSF=C2SL*SF
C
      BL=BL+0.011490D0*S2D     -0.001996D0*S2F         -0.003238D0*SSLP
     1    -0.022236D0*SNLMD2     +0.109760D0*SSL     +0.003728D0*S2SL
     2-0.000607D0*SD-0.000267D0*(S2F*C2D-C2F*S2D)-0.000801D0*(SLPC2D
     3 -CLPS2D)-0.000118D0*(SLPC2D+CLPS2D)+0.000138D0*(X1-X2)+0.000716D0
     4*(SLCLP-CLSLP)+0.000192D0*(SLC2F-CLS2F)-0.000186D0*(SSL*C4D-CSL*S4
     5D)+0.000931D0*(SSL*C2D+CSL*S2D)-0.000219D0*(SLC2F+CLS2F)-0.000999D
     60*(X1+X2)-0.000532D0*(SLCLP+CLSLP)-0.000149D0*(S2SL*C4D-C2SL*S4D)
     7-0.001026D0*(S2SL*C2D-C2SL*S2D)+0.000175D0*(SSL*C2SL+CSL*S2SL)
C
      B=INCL*SF-0.003023D0*(AL1-AL2) +0.004897D0*(SLCF+CLSF)          +0
     1.004847D0*SSLMF +0.000569D0*(AL1+AL2) -0.000144D0*(SSLP*(CF*C2D+SF
     2 *S2D)+CSLP*(AL1-AL2)) -0.000807D0*(SNLMD2*CF+CLM2D*SF)+0.000161D0
     3*(SSLMF*C2D+(CSL*CF+SSL*SF)*S2D)-0.000967D0*(SNLMD2*CF-CLM2D*SF)
     4+0.000301D0*(S2LCF+C2LSF)+0.000154D0*(S2LCF-C2LSF)
C
      AL1=          0.0082488D0*C2D     +0.0100247D0*(Z1+Z2)    +0.05450
     108D0*CSL+0.0029700D0*C2SL+0.0009017D0*(Z1-Z2)+0.0005604D0*(CSLP*C2
     2D+SSLP*S2D)+0.0004219D0*(CLM2D*CSLP-SNLMD2*SSLP)+0.0003369D0*(Y1+Y
     32)-0.0002773D0*(Y1-Y2)-0.0002086D0*(CSL*C2F+SSL*S2F)
     4 +0.0001817D0*(CSL*C2SL-SSL*S2SL)
C
      BLX=SLR-2.D0*DR
      AL2=0.0545008D0*SLR*SSL +0.0059400D0*SLR*S2SL +0.0100247D0*BLX
     2       *SNLMD2+0.0164976D0*DR*S2D
C
C     FROM NOW ON, SL=SIN(BL), F=SIN(B), D=COS(B)
C     Z2=DCOS(F)*INCL*FR
      SL=DSIN(BL)
      SLP=DCOS(BL)
      F=DSIN(B)
      D=DCOS(B)
      RMOON(1)=D*SLP
      RMOON(2)=D*SL*COB-F*SOB
      RMOON(3)=D*SL*SOB+F*COB
C
C     NEXT 4 LINES FIND THE LUNAR VELOCITY UNIT VECTOR (UNITS/DAY)
C     BLX=BLR+0.109760D0*SLR*CSL-0.022236D0*BLX*CLM2D+0.022980D0*DR*C2D
C     X2=-BLX*D*SL
C     Y2=BLX*COB*D*SLP-Z2*SOB*D
C     Z2=BLX*SOB*D*SLP+Z2*COB*D
C
C     CONVERT FROM UNIT VECTOR TO POSITION VECTOR IF WANTED.
      IF(IFLAG.EQ.1) GO TO 999
      X1=384399.06D0/(1.D0+AL1)
      DO 10 I=1,3
   10 RMOON(I)=X1*RMOON(I)
C
  999 RETURN
      END
