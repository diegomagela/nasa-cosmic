      SUBROUTINE ECHOSB
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      COMMON/ACFILT/ACPARM(20),IACFLT(20)
C
      COMMON/CSECBD/SECM,SECI(3,3),ZBAR2(3),YI02(3)
C
      COMMON/ISECBD/I2BDY,NDOF2,IRAST,NDEP2,IARST(3),IRSCY(3)
C
      COMMON/SECICS/GAM20,ALP20,BET20,B0(3,3),GAM2I,ALP2I,BET2I
     1             ,OM2I(3),SBUP(2),SBDN(2)
C
C
      DIMENSION HED1(5),HED2(5),HED3(5),HED4(5)
C
      DATA HED1/'SECONDAR','Y BODY P','ROPERTIE','S       ','        '/
      DATA HED2/'SECONDAR','Y BODY I','NITIAL C','ONDITION','S       '/
      DATA HED3/'RASTERIN','G OPTION',' SPECIFI','ED      ','        '/
      DATA HED4/'SENSOR C','ONTROL O','F ACTUAT','OR      ','      '/
C
C
      IF(I2BDY.EQ.0) GO TO 10
      CALL HVAL(HED1)
      CALL FVAL('SBMOI   ',5,SECI,3,3,2)
      CALL FVAL('SBMASS  ',6,SECM,0,0,0)
      CALL FVAL('YPIVOT  ',6,YI02,3,0,1)
      CALL FVAL('SBCG    ',4,ZBAR2,3,0,1)
C
      IF(NDOF2.EQ.0) GO TO 5
      CALL HVAL(HED2)
      CALL IVAL('NDOFSB  ',6,NDOF2,0,0,0)
      CALL FVAL('GAM2I   ',5,GAM2I,0,0,0)
      CALL FVAL('ALP2I   ',5,ALP2I,0,0,0)
      CALL FVAL('BET2I   ',5,BET2I,0,0,0)
      CALL FVAL('OMEG2I  ',6,OM2I,3,0,1)
C
      GO TO 10
C
    5 CONTINUE
C
      IF(IRAST.EQ.0) GO TO 10
      CALL HVAL(HED3)
      CALL IVAL('IRAST   ',5,IRAST,0,0,0)
      CALL IVAL('IARAST  ',6,IARST,3,0,1)
C
   10 CONTINUE
C
      IF(IACFLT(1).EQ.0) RETURN
C
      CALL HVAL(HED4)
      CALL FVAL('GAIN    ',4,ACPARM(1),0,0,0)
      CALL FVAL('TAU     ',3,ACPARM(2),0,0,0)
C
C
      RETURN
C
      END
