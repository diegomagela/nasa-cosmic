      SUBROUTINE XYZPLH(X)
C
      IMPLICIT REAL*8 (A-H,O-Z)
      REAL*8 J2,J3,J4,J22
C
C     SUBROUTINE TO CONVERT INERTIAL XYZ COORDINATES TO LATITUDE,
C     LONGITUDE AND HEIGHT
C
      COMMON/CNBODY/ J2,J3,J4,J22,ZJ20,ZMU,WWO,FLAT,AEARTH
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON/ECNSTS/ THETA1,THETGO(12)
C
      COMMON/IDATE1/ IY,IM,JWDAY
C
      COMMON/RPOOL1/ RHOK(10),TIME,SA(3,3),FM1(3,3),ZLK(10),OMEG(3),
     .               ZLKP(10),ZLKDP(10),CMAT(3,3),GBAR(3,3),YBCM(3),
     .               ZBZK(3,10),FCM(3,3),DTO,PHID,PHI1
C
      COMMON/SUBPOS/ ALAT,ALONG,HGT
C
      DIMENSION X(3)
C
      CALL TCNVRT(YY,ZM,DAORSC,TLAST,TIME,2)
      DAY=JWDAY
      IY1=IY-67
      THGO=THETGO(IY1)*RADIAN
      THE1=THETA1*RADIAN
      THE2=THE1 + TWOPI
      THETAG=THGO+DAY*THE1+DAORSC*THE2/8.64D4
      SINTH=DSIN(THETAG)
      COSTH=DCOS(THETAG)
C                       CALCULATE EARTH FIXED COORDINATES
      XE=COSTH*X(1) + SINTH*X(2)
      YE=COSTH*X(2) - SINTH*X(1)
      ZE=X(3)
C     **** CALCULATE ECCENTRICITY OF CENTRAL BODY (USUALLY EARTH) ******
      FL=1.D0/FLAT
      ECC=2.D0*FL-FL**2
C     **** CALCULATE LATITUDE,LONGITUDE,AND HEIGHT ****
      REQ=DSQRT(XE*XE+YE*YE)
      ALONG=0.0D0
      IF(XE.NE.0.0D0.OR.YE.NE.0.0D0) ALONG=DATAN2(YE,XE)
      IF(ALONG.LT.0.0D0) ALONG=ALONG+TWOPI
   10 ESQ1=1.0D0-ECC
      ALAT=DATAN2(ZE,REQ)
      SINPHI=DSIN(ALAT)
      RSAT=DSQRT(ZE*ZE+REQ*REQ)
      DEN=DSQRT(ESQ1+SINPHI*SINPHI*ECC)
      HGT=RSAT-AEARTH*(1.0D0-FL)/DEN
      RETURN
      END
