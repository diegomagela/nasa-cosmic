      SUBROUTINE SAPLCS
C
      IMPLICIT REAL*8(A-H,O-Z)
C
      COMMON/ADSTAT/ DER(150),DEP(150)
C
      COMMON/CONSTS/ PI,TWOPI,RADIAN
C
      COMMON/CSTVAL/ TSTART
C
      COMMON/CSAPCS/ PCSPRM(100),IPLTCS(20)
C
      COMMON/DATOUT/ IDATA,MLAST
C
      COMMON/DEBUG2/ IOUT,JOUT,KLUGE
C
      COMMON/DRPROT/ PSTAG,RMAG,UNADR(3)
C
      COMMON/SAGOUT/ AZ,AZD,B(3,3),B0(3,3),B0B(3,3),C(3,3),B0BC(3,3)
     1                                      ,YAZ(3),ZAZM(3)
C
      COMMON/HSAGIM/ HGMB(3)
C
      COMMON/ISAGIM/ IGMBL,NAZIM,NA1
C
      COMMON/IMAIN1/ IDATE,LSAVE,IDUM1(6)
C
      COMMON/INEWR / NKT(10),ICP,ICPS
C
      COMMON/IPOOL1/ IGRAV,IDAMP,IK,K1,ITIM,IAB,IAPS,IBB,IBPS
     1              ,NK(10),LK(10),LLK(10)
C
      COMMON/MOMENT/ IDUM01(3),IMGNTS,IDUM02(2)
C
      COMMON/OUTTHR/ SMAGB(3),XMB(3),RWHEEL(3)
C
      COMMON/RMAIN1/ DELTAT,FACTOR,FREQ,TSTOP,DELMIT,UPB(150),DNB(150)
C
      COMMON/RMGNTC/ SMAGI(3),DPMAG(3),SFMAG,MAGFLD
C
      COMMON/RPOOL1/ RHOK(10),TIME,SA(3,3),FM1(3,3),DUM01(96)
C
      COMMON/RPOOL5/ CKMAT(3,3,10),FM2(3,3)
C
      COMMON/VARBLS/ DEPEND(150),DERIV(150)
C
      COMMON/XIN4  / UP(150),DN(150),BNDS(22)
C
C
      DIMENSION HEDPC(5)
      DIMENSION HDPID(5),HDMOT(5)
      DIMENSION SMAGM(3),SNSWM(3)
      DIMENSION FILMAG(3),REFV(3)
      DIMENSION ANOISE(3),PNOISE(3),FNOISE(3)
      DIMENSION FREQNS(3),PHASNS(3)
      DIMENSION SNSV(3),SNSVM1(3)
      REAL*4 BUFF(450)
C
      DATA I8/',A8,'/
      DATA HEDPC/'SNGL AXI','S DESPIN',' PLATFOR','M CONTRO','L SYSTEM'/
      DATA HDPID/'SNGL AXI','S P I D ','CONTROLL','ER PARAM','ETERS   '/
      DATA HDMOT/'SNGL AXI','S GIMBLE',' DRIVE M','OTOR PAR','AMETERS '/
C
      EQUIVALENCE (IPLTCS(1),IPCONT)
      EQUIVALENCE (IPLTCS(3),IGSNSE),(IPLTCS(4),NMAGAV)
      EQUIVALENCE (UPMSN,PCSPRM(30)),(DNMSN,PCSPRM(31))
      EQUIVALENCE (SNSWM(1),PCSPRM(32))
      EQUIVALENCE (PCSPRM(35),TMAGSR),(PCSPRM(36),TCOMPD)
C
      EQUIVALENCE (PCSPRM(10),TSAMP)
      EQUIVALENCE (PCSPRM(11),AZQNT)
      EQUIVALENCE (PCSPRM(12),AZXIUP)
      EQUIVALENCE (PCSPRM(13),AZXIDN)
      EQUIVALENCE (PCSPRM(14),AZKP)
      EQUIVALENCE (PCSPRM(15),AZKI)
      EQUIVALENCE (PCSPRM(16),AZKD)
      EQUIVALENCE (PCSPRM(41),AZKA)
      EQUIVALENCE (PCSPRM(42),AZKT)
      EQUIVALENCE (PCSPRM(43),AZKB)
      EQUIVALENCE (PCSPRM(44),AZMTUP)
      EQUIVALENCE (PCSPRM(45),AZMTDN)
      EQUIVALENCE (PCSPRM(46),AZTCUL)
      EQUIVALENCE (PCSPRM(47),AZDMIN)
      EQUIVALENCE (PCSPRM(48),AZVBAS)
      EQUIVALENCE (PCSPRM(80),ANOISE(1)),(PCSPRM(83),PNOISE(1))
      EQUIVALENCE (PCSPRM(86),FNOISE(1))
      EQUIVALENCE (PCSPRM(90),FREQNS(1)),(PCSPRM(93),PHASNS(1))
C
C     CALLED FROM SAGMRD
C
      CALL SETUP(8HSACSPM  ,8,PCSPRM,100)
      CALL SETUP(8HISAPCS  ,4,IPLTCS,20)
C
      RETURN
C
C   ****************************************************************
      ENTRY NUMSAP(NUMEQS)
C   ****************************************************************
C
C     CALLED FROM NUM
C
      IF(IPCONT.EQ.0) RETURN
      IF(IGSNSE.EQ.0) RETURN
      NPLCS=NUMEQS+1
      NUMEQS=NUMEQS+3
C
      RETURN
C
C   ****************************************************************
      ENTRY ECHSAC
C   ****************************************************************
C
C     CALLED FROM ECHOGP
C
      IF(IPCONT.EQ.0) RETURN
C
      CALL HVAL(HEDPC)
C
      CALL FVAL('TSAMP   ',5,TSAMP,0,0,0)
C
      CALL HVAL(HDPID)
C
      CALL FVAL('AZIM    ',4,PCSPRM(11),6,0,1)
C
      CALL HVAL(HDMOT)
C
      CALL FVAL('AZIM    ',4,PCSPRM(41),8,0,1)
C
      RETURN
C
C   ****************************************************************
      ENTRY SACINT(FRQ)
C   ****************************************************************
C
C     CALLED FROM MAIN FOR INITIAL CONDITIONS AND INTEGRATION BOUNDS
C     CALLED AFTER CALL TO SETVAL(1)
C
      NPRFRQ=1
      ICNFRQ=0
      FRQ=FREQ
      DO 1 I=1,3
      HGMB(I)=0.0D0
      FREQNS(I)=FNOISE(I)*TWOPI
      PHASNS(I)=PNOISE(I)*RADIAN
    1 CONTINUE
C
      IF(IPCONT.EQ.0) RETURN
C
      IF(NMAGAV.EQ.0) NMAGAV=1
      TSNDLY=TCOMPD+(NMAGAV-1)*TMAGSR/2.0D0
      RATIOM=TSNDLY/TSAMP
C
      IF(IGSNSE.EQ.0) GO TO 25
C
      IDEP=NPLCS-1
      DO 23 I=1,3
      I1=IDEP+I
      UP(I1)=UPMSN
      DN(I1)=DNMSN
   23 CONTINUE
C
   25 CONTINUE
C
      NPRFRQ=FREQ/TSAMP
      IF(NPRFRQ.LT.1) NPRFRQ=1
      FRQ=TSAMP
C
      RETURN
C
C   ****************************************************************
      ENTRY SACSNR
C   ****************************************************************
C
C     CALLED FROM DEREQ TO LOAD DERIVATIVES FOR SENSOR
C
      IF(IPCONT.EQ.0) RETURN
C
      CALL MATV(2,SA,UNADR,SMAGB)
C
      DT=TIME-TSTART
      DO 27 I=1,3
      ARG=FREQNS(I)*DT+PHASNS(I)
      DIRT=ANOISE(I)*DSIN(ARG)
      SMAGM(I)=SMAGB(I)+DIRT
   27 CONTINUE
C
      IF(LSAVE.NE.1) GO TO 29
      IF(IDATA.NE.0) GO TO 29
C
C     CALCULATIONS DONE ONLY AT THE START OF A SIMULATION
C
      CALL MATV(2,B0,SMAGM,REFV)
      DEN=REFV(1)*REFV(1)+REFV(2)*REFV(2)
      VMMAG=DEN+REFV(3)*REFV(3)
      DEN=DSQRT(DEN)
      VMMAG=DSQRT(VMMAG)
      SNSAZ=DATAN2(REFV(2),REFV(1))
C
      DO 26 I=1,3
      SNSVM1(I)=SMAGM(I)
   26 CONTINUE
C
      AZM=DMOD(AZ,TWOPI)
      IF(AZM.GT.PI) AZM=AZM-TWOPI
      AZMQ=AZM-DMOD(AZM,AZQNT)
      SSAZ=DSIN(SNSAZ)
      CSAZ=DCOS(SNSAZ)
      SQAZ=DSIN(AZMQ)
      CQAZ=DCOS(AZMQ)
      DOTP=SSAZ*SQAZ+CSAZ*CQAZ
      CRSP=CSAZ*SQAZ-SSAZ*CQAZ
      CRSP=-CRSP
      ERRAZ=DATAN2(CRSP,DOTP)
      AZOUT=AZKP*ERRAZ
      AZXIM1=0.0D0
      EAZM1=ERRAZ
C
C
      IF(IGSNSE.EQ.0) GO TO 31
C
      DO 28 I=1,3
      I1=IDEP+I
      DEPEND(I1)=SMAGM(I)
   28 CONTINUE
C
   29 CONTINUE
C
      IF(IGSNSE.EQ.0) GO TO 31
C
      DO 30 I=1,3
      I1=IDEP+I
      DERIV(I1)=SNSWM(I)*(SMAGM(I)-DEPEND(I1))
      SNSV(I)=DEPEND(I1)
   30 CONTINUE
C
      RETURN
C
   31 CONTINUE
C
      DO 32 I=1,3
      SNSV(I)=SMAGM(I)
   32 CONTINUE
C
      RETURN
C
C
C   ****************************************************************
      ENTRY SAGCNT(AZCNT)
C   ****************************************************************
C
C     CALLED FROM SAGIM2
C
C     ZERO OUT CONTROL TORQUE FOR NO CONTROL CASE
C
      AZCNT=0.0D0
C
      IF(IPCONT.EQ.0) RETURN
C
C     CALCULATE MOTOR TORQUES
C
      VOPAZ=AZKA*AZOUT
C     MOTOR TORQUES
      AZMOTT=AZKT*(VOPAZ-AZKB*AZD+AZVBAS)
C     TORQUE LIMITING
      IF(AZMOTT.GT.AZMTUP) AZMOTT=AZMTUP
      IF(AZMOTT.LT.AZMTDN) AZMOTT=AZMTDN
C     COULOMB FRICTION TORQUE
      AZMOTT=AZMOTT-AZD*AZTCUL/(AZDMIN+DABS(AZD))
C     OUTPUT
      AZCNT=AZMOTT
C
C
      RETURN
C
C   ****************************************************************
      ENTRY SAPIDC(IPRFLG)
C   ****************************************************************
C
C     SIMULATION OF P I D CONTROLLER
C     CALLED FROM MAIN AFTER ADAMS RETURN
C
      IPRFLG=1
      IF(IPCONT.EQ.0) RETURN
      IPRFLG=0
      IF(MOD(ICNFRQ,NPRFRQ).EQ.0) IPRFLG=1
      ICNFRQ=ICNFRQ+1
C
      DO 35 I=1,3
      FILMAG(I)=SNSV(I)-RATIOM*(SNSV(I)-SNSVM1(I))
      SNSVM1(I)=SNSV(I)
   35 CONTINUE
C
C     PLATFORM COMMAND COMPUTATION
C
      CALL MATV(2,B0,FILMAG,REFV)
      DEN=REFV(1)*REFV(1)+REFV(2)*REFV(2)
      VMMAG=DEN+REFV(3)*REFV(3)
      DEN=DSQRT(DEN)
      VMMAG=DSQRT(VMMAG)
C
      SNSAZ=DATAN2(REFV(2),REFV(1))
   36 CONTINUE
C
C     MEASURED PLATFORM POSITION
C
      AZM=DMOD(AZ,TWOPI)
      IF(AZM.GT.PI) AZM=AZM-TWOPI
      AZMQ=AZM-DMOD(AZM,AZQNT)
C
C     CALCULATE AZIMUTH AND ELEVATION ERRORS
C
      SSAZ=DSIN(SNSAZ)
      CSAZ=DCOS(SNSAZ)
      SQAZ=DSIN(AZMQ)
      CQAZ=DCOS(AZMQ)
      DOTP=SSAZ*SQAZ+CSAZ*CQAZ
      CRSP=CSAZ*SQAZ-SSAZ*CQAZ
      CRSP=-CRSP
      ERRAZ=DATAN2(CRSP,DOTP)
      ERAZIM=ERRAZ/RADIAN
      AZXI=AZXIM1+TSAMP*ERRAZ
      AZXD=(ERRAZ-EAZM1)/TSAMP
      AZOUT=AZKP*ERRAZ+AZKI*AZXI+AZKD*AZXD
      IF(AZXI.GT.AZXIUP) AZXI=AZXIUP
      IF(AZXI.LT.AZXIDN) AZXI=AZXIDN
C
      IF(IOUT.EQ.1) GO TO 40
      WRITE(6,1000)
 1000 FORMAT('0',10X,'DEBUG OUTPUT FROM PIDCNT')
 1001 FORMAT('0',1P10E13.5)
      WRITE(6,1001) SNSAZ,AZM,AZMQ,ERRAZ,ERAZIM,AZXI,AZXD,AZOUT,AZXIM1
   40 CONTINUE
C
      AZXIM1=AZXI
      EAZM1=ERRAZ
C
      RETURN
C
C   ****************************************************************
      ENTRY SAPWRP(BUFF,INDX)
C   ****************************************************************
C
C     CALLED FROM GPPLOT TO LOAD PLOT RECORD
C
      INDEX=INDX
C
      INDX=INDX+6
C
      IF(IPCONT.EQ.0) RETURN
C
      I1=INDEX-1
C
      DO 64 I=1,3
      BUFF(I1+I)=FILMAG(I)
   64 CONTINUE
      I1=INDEX+2
      BUFF(I1+1)=ERAZIM
      BUFF(I1+2)=AZOUT
      BUFF(I1+3)=AZMOTT
C
C
      RETURN
C
C   ****************************************************************
      ENTRY SAPPRN
C   ****************************************************************
C
C     CALLED FROM GPSOUT FOR PRINTED OUTPUT
C
      IF(IPCONT.EQ.0) RETURN
      DO 74 I=1,3
   74 CALL SET('VNADIR  ',I,0,FILMAG(I),I8)
C
C
      CALL SET('AZIM ERR',0,0,ERAZIM,I8)
      CALL SET('AZIM PID',0,0,AZOUT,I8)
      CALL SET('AZIM MOT',0,0,AZMOTT,I8)
C
C
      RETURN
C
C
      END