       SUBROUTINE AITOFF(ALAT,ALONG,AITLAT,AITLON)
C**********************************************************************
C       SUBROUTINE AITOFF CONVERTS LONGITUDE AND LATITUDE IN RADIANS TO
C       AITOFF'S PROJECTION OF THE SPHERE(ALSO IN RADIANS).
C       THE FORMULAE USED IN THIS SUBROUTINE WERE TAKEN FROM
C       COORDINATE SYSTEMS AND MAP PROJECTIONS,MALING.
C**********************************************************************
C       THIS SUBROUTINE WAS CREATED BY BARBARA H ROBERTS,1/81.
C       UPDATED.....
C*********************************************************************
C       VARIABLE DESCRIPTION
C       NAME      TYPE       I/O        DIM       DESCRIPTION
C       ALAT      R*8         I          1        LATITUDE
C       ALONG     R*8         I          1        LONGITUDE 
C       AITLAT    R*8         O          1        AITOFF LATITUDE
C       AITLON    R*8         O          1        AITOFF LONGITUDE
C*********************************************************************
C       AITOFF'S PROJECTION WAS MISTAKENLY CONFUSED
C       WITH HAMMER-AITOFF'S EQUAL AREA PROJECTION OF THE SPHERE
C       UNTIL 1952. AT THAT TIME IT WAS DISCOVERED THAT HAMMER(1892)
C       HAD INVENTED THE PROJECTION. SINCE THAT TIME THE PROJECTION
C       (EQUAL AREA) HAS BEEN CALLED HAMMER-AITOFF OR JUST HAMMER'S
C       PROJECTION.(SEE INTRODUCTION TO MAP PROJECTIONS BY PORTER
C       W. MCDONNELL,JR.P.112.)AITOFF'S PROJECTION(1889) IS NOT
C       AN EQUAL AREA PROJECTION,BUT ONE IN WHICH THERE IS EQUAL
C       DISTANCE BETWEEN PARALLELS. THIS SUBROUTINE IS THE FORTRAN
C       CODE FOR THE OLDER PROJECTION, THE EQUAL DISTANCE BETWEEN
C       PARALLELS,NOT THE EQUAL AREA PROJECTION.
C**********************************************************************
C
C  CODED BY BARBARA ROBERTS. 5/81.
C   MODIFIED.....
C
C
      IMPLICIT REAL*8(A-H,O-Z)
C
C****************************************************************
C
      REAL*8 HALFPI/ 1.570796326794897D0 /
      REAL*8 PI/ 3.141592653589793D0 /
      REAL*8 TWOPI/ 6.283185307179586D0 /
C
C FACLAT,FACLON HAVE VALUES OF + OR - 1 SO THAT FIRST QUADRANT 
C VALUES OF AITLAT AND AITLON CAN GENERATE OTHER THREE QUADRANTS
C
      REAL*8 FACLAT(4)/2*1.0D0,2*-1.0D0/,FACLON(4)/1.0D0,2*-1.0D0,1.0D0/
      DATA EPS/ 1.0D-8 /
      XLAT=ALAT
      XLONG=ALONG
C
C THE VARIABLE TEMP IS EQUIVALENT TO XLONG BUT HAS VALUE BETWEEN
C ZERO AND 360 DEGREES AND IS POSITIVE
C
      TEMP=DMOD(DABS(XLONG),TWOPI)
C
C DSIGN TRANSFERS SIGN ON XLONG TO TEMP
C
      XLONG=DSIGN(TEMP,XLONG)
      IF ((DABS(XLONG)-PI).LT.EPS) GO TO 500
      IF(DABS(XLONG).GT.PI) XLONG=XLONG-DSIGN(TWOPI,XLONG)
C
C THE FOLLOWING FOUR IF STATEMENTS USE SIGNS ON XLAT AND XLONG
C TO DETERMINE QUADRANT. THE VALUES OF IQUAD ARE THE RESULTANT
C QUADRANTS
C
500   IF((XLAT.LT.0.0).AND.(XLONG.GE.0.0))IQUAD=4
      IF((XLAT.LT.0.0).AND.(XLONG.LT.0.0))IQUAD=3
      IF((XLAT.GE.0.0).AND.(XLONG.LT.0.0))IQUAD=2
      IF((XLAT.GE.0.0).AND.(XLONG.GE.0.0))IQUAD=1
      XLAT=DABS(XLAT)
      XLONG=DABS(XLONG)
C
C THE AITOFF TRANSFORMATION FOR FIRST QUADRANT LATITUDE AND LONGITUDE
C
      TEMPZ=DCOS(XLAT)*DCOS(.5D0*XLONG)
      Z=DACOS(TEMPZ)
      ALPHA=HALFPI
      IF(XLAT.LT.EPS)GO TO 200
      ALPHA=0.0D0
      IF((HALFPI-XLAT).LT.EPS)GO TO 200
      IF((XLONG.LT.EPS).OR.(DABS(TWOPI-XLONG).LT.EPS)) GO TO 200
      CALPHA=DTAN(XLAT)*(1.0D0/DSIN(.5D0*XLONG))
      ALPHA=DATAN2(1.0D0,CALPHA)
C        
200   AITLON=2.0D0*Z*DSIN(ALPHA)
      AITLAT=Z*DCOS(ALPHA)
C
C FACTORS FACLAT AND FACLON PLACE AITLAT AND AITLON IN PROPER
C QUADRANTS
C
      AITLAT=FACLAT(IQUAD)*AITLAT
      AITLON=FACLON(IQUAD)*AITLON
      RETURN
      END
