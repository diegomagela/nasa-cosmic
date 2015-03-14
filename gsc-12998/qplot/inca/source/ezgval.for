      SUBROUTINE EZGVAL(NM,N,A,B,EPS1,ALFR,ALFI,BETA,
     *                  RWK1,RWK2,RWK3,IERR)
CSE
CPS       PURPOSE:
C
C         EISPAC DRIVER ROUTINE TO COMPUTE ALL EIGENVALUES OF A
C          GENERALIZED REAL MATRIX SYSTEM
C
C                  A*Z = LAMBDA*B*Z
C         WHERE
C                  A OR B   MAY BE NEARLY SINGULAR OR SINGULAR
C
CPE
CAS            *****  ARGUMENT LIST  *****
C
C       NM - ROW DIMENSION OF BOTH A AND B
C        N - ORDER OF EIGENPROBLEM
C        A - INPUT ARRAY OF EIGENPROBLEM, (N,N)
C        B - INPUT ARRAY OF EIGENPROBLEM, (N,N)
C     EPS1 - TOLERANCE FACTOR FOR QZIT, DEFAULT TO MACHINE PRECISION
C            IF EQUAL TO ZERO.
C     ALFR - REAL PARTS OF NUMERATOR OF EIGENVALUES, N
C     ALFI - IMAG PARTS OF NUMERATOR OF EIGENVALUES, N
C     BETA - DENOMINATOR OF EIGENVALUES, N (ALWAYS REAL NON-NEGATIVE)
C     RWK1 - REAL*8 WORK AREA FOR BALANCING, N
C     RWK2 - REAL*8 WORK AREA FOR BALANCING, N
C     RWK3 - REAL*8 WORK AREA FOR BALANCING, (N,6)
C     IERR - IF NON-ZERO AN ERROR HAS OCCURED
C
CAE
C     SUBROUTINE EZGVAL CALLS:
C                               BALGEN     QZIT
C                               QZHES      QZVAL
C
C
      IMPLICIT REAL*8 (A-H,O-Z)
      LOGICAL MATZ
      DIMENSION A(NM,N), B(NM,N), ALFR(N), ALFI(N), BETA(N)
      DIMENSION RWK1(N), RWK2(N), RWK3(N,6)
      REAL*8 MACHEP
      MATZ = .FALSE.
      IF(EPS1.NE.0.) GO TO 45
      MACHEP = 1.0D0
   35 MACHEP = MACHEP/2.0
      IF(1.0D0+MACHEP.GT.1.0D0) GO TO 35
      EPS1 = MACHEP
   45 CONTINUE
C
C      BALANCE VIA WARD'S ALGORITHM
      CALL BALGEN(N,NM,A,NM,B,LOW,IGH,RWK1,RWK2,RWK3)
C
C      REDUCE MATRICES VIA ORTHOGONAL TRANSFORMATIONS
      CALL QZHES(NM,N,A,B,LOW,IGH,MATZ,Z)
C
C      REDUCE SOME MORE
      CALL QZIT(NM,N,A,B,LOW,IGH,EPS1,MATZ,Z,IERR)
      IF(IERR.NE.0) RETURN
C
C      USE QZ METHOD TO GET EIGENVALUES
      CALL QZVAL(NM,N,A,B,ALFR,ALFI,BETA,MATZ,Z)
  999 FORMAT (//,5X,'DIAGONAL BLOCKS CANNOT BE DETERMINED IN 50 ITERATIO
     *NS IN QZIT',//)
      RETURN
      END