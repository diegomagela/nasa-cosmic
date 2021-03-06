      SUBROUTINE MATCHCH(TEXT,NTEST,CHARRAY,INDEX)
C
C THIS ROUTINE TESTS EACH ELEMENT IN AN ARRAY OF CHARACTER STRINGS
C FOR THE PRESENSE OF A SPECIFIED STRING.  IT RETURNS THE INDEX OF THE
C ARRAY ELEMENT WHERE THAT STRING WAS FOUND.
C
C FOR EXAMPLE, IT MAY SEARCH A 4-ELEMENT ARRAY OF CHARACTER*6 VARIABLES
C LOOKING FOR A MATCH TO A SPECIFIED CHARACTER*6 STRING.  IF IT IS
C LOOKING FOR THE STRING 'ABCDEF' IN THE ARRAY= '121212', 'AABBCC',
C 'ABCDEF', 'UVWXYZ', THEN IT SAYS THAT THE MATCH OCCURS AT THE THIRD
C ELEMENT OF THE ARRAY.
C
C VARIABLE DIM TYPE I/O DESCRIPTION
C -------- --- ---- --- -----------
C
C TEXT      1 CH*(*) I  THE STRING OF INTEREST.
C
C                       IF THE NUMBER OF CHARACTERS(INCLUDING LEADING,
C                       TRAILING, AND EMBEDDED BLANKS) IS DIFFERENT THAN
C                       THE NUMBER OF CHARACTERS IN THE CHARRAY
C                       ELEMENTS, NO MATCH OCCURS AND INDEX IS SET TO
C                       ZERO.
C
C NTEST     1   I*4  I  THE NUMBER OF ELEMENTS OF CHARRAY TO BE TESTED
C                       FOR A MATCH WITH TEXT.  IF ZERO OR NEGATIVE,
C                       NO TEST IS DONE AND INDEX IS SET TO ZERO.
C
C                       NTEST MUST NOT EXCEED THE DIMENSION OF CHARRAY
C                       AS DEFINED IN THE CALLER.
C
C CHARRAY   - CH*(*) I  THE ARRAY OF STRINGS TO BE TESTED. THE DIMENSION
C                       MUST BE GT/EQ NTEST.
C
C INDEX     1   I*4  O  THE INDEX NUMBER WHERE THE MATCH OCCURRED IN
C                       CH4ARRAY. IF NO MATCH OR IF NTEST WAS ZERO OR
C                       NEGATIVE, INDEX=0 IS RETURNED.
C
C                       WARNING: IF THE NUMBER OF CHARACTERS IN TEXT
C                                AND CHARRAY DIFFER, INDEX=0 IS SET.
C
C***********************************************************************
C
C BY C PETRUZZO, GSFC/742 1/86
C    MODIFIED....
C
C***********************************************************************
C
      CHARACTER*(*) TEXT,CHARRAY(1)
C
      INDEX = 0
C
C    CHECK FOR CONSISTENT LENGTHS
      IF(NTEST.GT.0) THEN
        IF( LEN(TEXT) .NE. LEN(CHARRAY(1)) ) GO TO 9999
        END IF
C
      IEL = 0
      DO WHILE (IEL.LT.NTEST .AND. INDEX.EQ.0)
        IEL = IEL + 1
        IF(CHARRAY(IEL).EQ.TEXT) INDEX = IEL
        END DO
C
 9999 CONTINUE
      RETURN
      END
