C
C********************** START RDREQMT.INC ****************************
C
C THIS IS THE INCLUDE FILE USED BY THE RDREQMT SUBROUTINE SET.  IF ANY
C OF THE PARAMETER VALUES OR INITIALIZED VARIABLE VALUES ARE CHANGED,
C YOU MUST RECOMPILE ALL ROUTINES BEGINNING WITH THE NAME RDREQMT.
C
C
C MAX NUMBER OF EXPERIMENTS THAT MAY BE PRESENT ON THE REQUIREMENTS
C FILE, REGARDLESS OF THE NUMBER THAT THE CALLING PROGRAM MAY USE.
C
      PARAMETER MAXEXPMTS=50
C
C MAX NUMBER OF PARAMETERS PACKAGE CAN HANDLE IN THE KEYWORD RECORD AND
C TARGET RECORDS.
C
      PARAMETER MAXPARMS=20
C
C KEYWORDS ASSOCIATED WITH OBSERVATION REQUIREMENTS
C
      PARAMETER MAXKEYS=11
      CHARACTER*15 KEYWORD(MAXKEYS)/
     *  'TDRS',       'DAYNIGHT',   'SAA',         'BODYBLOCK',
     *  'SUNAVOID',   'MOONAVOID',  'BRIGHTERT',   'DARKERT',
     *  'VELAVOID',   'ZENITH',  
     *  'ENDREQ' /   ! ENDREQ MUST BE LAST(RDREQMT5A EXPECTS IT LAST).
C
C
C********************** END OF RDREQMT.INC ***************************
C
