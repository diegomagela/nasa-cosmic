	PROGRAM REPLOTER
C *** LAST REVISED ON  3-AUG-1987 11:14:40.46
C *** SOURCE FILE: [DL.GRAPHICS.LONGLIB]REPLOT.FOR
C
C	CREATED: DGL 1-NOV-1984
C
C	THIS PROGRAM PERMITS REPLOTTING OF A PRINTER GRAPHICS FILE
C	PRODUCED BY THE LONGLIB GRAPHICS LIBRARY TO A SCREEN DEVICE.
C	THE USER IS PROMPTED TO DETERMINE WHICH SCREEN DEVICE TO USE.
C
C	ANY NEWPAGE COMMANDS IN PRINTER FILE WILL BE PROCESSED AS
C	A CTERM(2) COMMAND FOR THE SCREEN DEVICE.
C	OF COURSE, SINCE THE PRINTER FILE DOES NOT MAINTAIN A COPY OF
C	WHAT DATA WENT TO THE SCREENS, ANY CTERMS USED IN THE ORIGINAL
C	PROGRAM GENERATING THE FILE WILL NOT BE REPEATED BY THIS PROGRAM.
C
C	THIS PROGRAM IS FORTRAN 77 COMPATIBLE WITH THE FOLLOWING EXCEPTIONS;
C		1. TABS (^I) ARE USED TO INDENT LINES
C		2. INTEGER*2 USED FOR UNFORMATTTED FILE IN REGET.
C		   THIS CAN BE REPLACED BY INTEGER IF THIS HAS BEEN DONE
C		   IN THE MAIN LONGLIB PRINTER HISTORY ROUTINE.
C		3. VAX DEPENDENT LIBRAY ROUTINE USED TO GET FILE NAME
C		   FROM COMMAND LINE.
C
	CHARACTER*80 NAME
C
C	VAX DEPENDENT METHOD OF GETTING FILE NAME FROM COMMAND LINE
C
	IERR=LIB$GET_FOREIGN(NAME,,IFLAG)
C
C	DEFAULT FILE NAME
C
	IF (NAME.EQ.' ') NAME='FOR003.DAT'
C
C	OPEN LONGLIB WITHOUT A PRINTER HISTORY FILE
C	PROMPT FOR SCREEN TYPE
C
	CALL FRAME(-3,0,0.,0.,1.)
C
C	REPLOT PRINTER HISTORY FILE TO SCREEN
C
	CALL REPLOT(NAME)
C
C	TERMINATE PLOTTING
C
	CALL PLOT(0.,0.,3)
	CALL CTERM(2)
	CALL PLOTND
	STOP
	END
C
C
	SUBROUTINE REPLOT(NAME)
C
C	MAIN ROUTINE TO REPLOT A PRINTER GRAPHICS FILE TO A SCREEN
C	DEVICE FOR THE LONGLIB GRAPHICS LIB.
C
C	NAME	(CHARACTER)	FILE NAME
C
	CHARACTER*(*) NAME
C
C	OPEN INPUT FILE
C
	MP=999
	OPEN(UNIT=2,FILE=NAME,FORM='UNFORMATTED',STATUS='OLD',
     $		READONLY,ERR=99)
C
C	TOP OF COMMAND READ LOOP
C
1000	CALL REGET(M1,M2,M3,MP,2)
	IF (M3.EQ.11) GOTO 110
	IF (M1.EQ.0.OR.M2.EQ.0) GOTO 110
	SX=1./FLOAT(M1)
	SY=1./FLOAT(M2)
C
C	TOP OF INNER LOOP
C
  1	CONTINUE
	CALL REGET(M1,M2,M3,MP,2)
	Y1=M1*SX
	X1=M2*SY
C
C	I3 IS THE COMMAND
C
	I3=M3
	IOLD=0
	JOLD=1
C
C	CHECK FOR END OF FILE
C
	IF (M3.GT.999) GOTO 999
C
C	EXECUTE COMMAND
C
	GOTO (10,20,20,10,10,10,10,10,20,100,110) I3
10	GOTO 1
C
C	PLOT COMAND
C
20	CALL PLOT(X1,Y1,I3)
	GOTO 1
C
C	FOR NEWPAGE WE WILL PROMPT FOR SCREEN CLEARS
C
100	CALL NEWPAGE
	CALL CTERM(2)
	CALL CTERM(-1)
	CALL RTERM(2)
	CALL RTERM(-1)
	GOTO 1
999	GOTO (1000,1001,1002,1003) I3-999
2000	GOTO 1
C
C	CHANGE LINE TYPE
C
1001	CONTINUE
	IOLD=M1
	I3=JOLD*10+IOLD
	CALL NEWPEN(I3)
	GOTO 1
C
C	PEN COLOR
C
1002	CONTINUE
	IF (M2.GE.0) CALL PLOT(FLOAT(M2),0.,0)
	GOTO 1
C
C	PEN WIDTH
C
1003	CONTINUE
	JOLD=M1
	I3=JOLD*10+IOLD
	CALL NEWPEN(I3)
	GOTO 1
C
110	CLOSE(2)
 99	RETURN
	END
C
	SUBROUTINE REGET(M1,M2,M3,MP,ILU)
C
C	READ DATA FROM PRINTER DATA FILE
C	
	INTEGER*2 M(128)
	MP=MP+3
	IF (MP.GT.128) THEN
		READ (ILU,ERR=99) M
		MP=3
	ENDIF
	M3=M(MP)
	M2=M(MP-1)
	M1=M(MP-2)
	IF (M3.EQ.999) GOTO 99
	RETURN
99	M3=11
	RETURN
	END
