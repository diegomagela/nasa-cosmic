      SUBROUTINE  BARODE (FKL   ,FLC4  ,HGT   ,RHOZ  ,TX    ,TZ    ,
     *                    T0    ,VCDI  ,XCDI  ,ZJ0   ,RHO   )
      IMPLICIT REAL*8    (A-H,O-Z)
      DIMENSION           AC(7) ,AD(6) ,B(6)  ,BD(6)
C
C.......................................................................
C
C   VERSION OF APRIL 8, 1976
C
C   PURPOSE
C     SUBROUTINE BARODE IS CALLED BY LOWALT TO COMPUTE THE ATMOSPHERIC
C     DENSITY BETWEEN 90 AND 100 KM.
C
C   INTERFACES
C
C     VARIABLE   COM/ARGLIST   I/O   DESCRIPTION
C     --------   -----------   ---   -----------------------------------
C     FKL        ARG. LIST      I    FACTOR INVOLVED IN RHO COMPUTATION
C     FLC4       ARG. LIST      I    MODIFYING FACTOR
C     HGT        ARG. LIST      I    SPACECRAFT HEIGHT (KM)
C     RCM        /ORDRAG/       I    AVERAGE EARTH RADIUS (KM)
C     RHO        ARG. LIST      O    ATMOSPHERIC DENSITY
C     RHOZ       ARG. LIST      I    DENSITY AT ZJ0
C     RL1        /ORDRAG/       I    ROOT OF POLYNOMIAL IN INTEGRAND
C     RL2        /ORDRAG/       I    ROOT OF POLYNOMIAL IN INTEGRAND
C     TX         ARG. LIST      I    INFLECTION POINT TEMPERATURE
C     TZ         ARG. LIST      I    TEMPERATURE AT HGT
C     T0         ARG. LIST      I    TEMPERATURE AT ZJ0
C     UC(2)      /ORDRAG/       I    FUNCTIONAL VALUES AT RL1 AND RL2
C     VCDI       ARG. LIST      I    FACTOR INCLUDED IN RHO COMPUTATION
C     WC(2)      /ORDRAG/       I    FUNCTIONAL VALUES AT RL1 AND RL2
C     XCDI       ARG. LIST      I    FACTOR INCLUDED IN RHO COMPUTATION
C     XLPS       /ORDRAG/       I    ROOT OF POLYNOMIAL IN INTEGRAND
C     YLPS       /ORDRAG/       I    ROOT OF POLYNOMIAL IN INTEGRAND
C     ZJ0        ARG. LIST      I    MINIMUM HEIGHT (KM)
C
C     SUBROUTINES AND FUNCTIONS REQUIRED
C       NONE
C
C     COMMON BLOCKS REQUIRED
C       /ORDRAG/
C
C     SUBROUTNE BARODE IS CALLED FROM SUBROUTINE LOWALT
C
C.......................................................................
C
      COMMON/ORDRAG/ ADT(6),CM(6),GL0,RC,RCM,RL1,RL1MAG,
     *               RL2,RL2MAG,XLPS,YLPS,UC(2),WC(2)
C
C
C  SET MOLECULAR POWER SERIES COEFFICIENTS
C
      DATA   AC / -.435093363387D6,
     *             .282755646391D5,
     *            -.765334661080D3,
     *             .110433875450D2,
     *            -.8958790995D-1,
     *             .38737586D-3,
     *            -.697444D-6/
C
C  SET CONSTANT COEFFICIENTS FOR B(N) SERIES
C
      DATA   AD /  .3144902516672729D10,
     *            -.1237748854832917D9,
     *             .1816141096520398D7,
     *            -.1140331079489267D5,
     *             .2436498612105595D2,
     *             .8957502869707995D-2/
C
C  SET LINEAR COEFFICIENTS FOR THE B(N) SERIES
C
      DATA   BD / -.5286448217910969D8,
     *            -.1663250847336828D5,
     *            -.1308252378125D1,
     *           3*0.D0/
C
C   THE B(N) SERIES
C
      D1 = TX/(TX-T0)
C
      DO 10 I=1,6
          B(I) = AD(I) + BD(I)*D1
   10 CONTINUE
C
C   THE S(Z) SERIES
C
      P2 = 0.D0
      P3 = 0.D0
      P5 = 0.D0
      D1 = 1.D0
      D2 = 1.D0
      D3 = 1.D0
C
      DO 20 I=1,6
        P2 = P2 + B(I)* D1
        P3 = P3 + B(I)* D2
        P5 = P5 + B(I)* D3
        D1 = D1 * RL1
        D2 = D2 * RL2
        D3 = D3 *(-RCM)
   20 CONTINUE
C
C   COMPUTE THE P FACTORS
C
      D1 = XLPS**2 + YLPS**2
      D2 = RCM**2
      D3 =   2.D0*XLPS +RL1 + RL2 -RCM
      D4 = RL1 * RL2
      P2 = P2/UC(1)
      P3 =-P3/UC(2)
      P5 = P5/  VCDI
      P4 = WC(1)*P2 + WC(2)*P3
      P4 = P4 + (D4*((D2-D1)*P5-D2*(B(5)+D3*B(6))))
      P4 = P4 + (B(1) - D4*RCM*D1*B(6))
      P4 = P4 /XCDI
      P6 = 2.D0*(XLPS+RCM)*P4 + (RL2+RCM)*P3 + (RL1+RCM)*P2
      P6 = B(5) + D3*B(6)-P5 - P6
      P1 = 2.D0*P4 + P3 + P2
      P1 = B(6)-P1
C
C   COMPUTE MOLECULAR MASS
C                                              
      EM = AC(7)
C
      DO 30 I=1,6
         EM = EM*HGT + AC(7-I)
   30 CONTINUE
C
C   COMPUTE F FACTORS
C
      D5 = ZJ0 + RCM
      D6 = HGT - ZJ0
      D7 = HGT + RCM
      F1 = 0.D0
      F2 = (HGT**2-2.D0*HGT*XLPS+D1)/(ZJ0**2-2.D0*ZJ0*XLPS+D1)
      F1 = F1 + DLOG  (F2)*P4
      F2 = (HGT-RL2)/(ZJ0-RL2)
      F1 = F1 + DLOG  (F2)*P3
      F2 = (HGT-RL1)/(ZJ0-RL1)
      F1 = F1 + DLOG  (F2)*P2
      F2 = D7/D5
      F1 = F1 + DLOG  (F2)*P1
      F2 = YLPS*D6/(YLPS**2 + (HGT-XLPS)*(ZJ0-XLPS))
      F2 = D6*(AC(7) + P5/(D7*D5)) + P6*DATAN(F2)/YLPS
C
C   COMPUTE DENSITY
C
      F3= FKL*FLC4*(F1 + F2)
      RHO = RHOZ*T0*EM/(28.826779D0*TZ)
      F3 = DEXP (F3 )
      RHO = F3*RHO
C
      RETURN
      END
