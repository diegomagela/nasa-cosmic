$ SET NOVERIFY
$ !
$ ! STUB - PRODUCE PROGRAM STUBS FOR FORTRAN 77 PROGRAMS
$ !
$ IF P1 .NES. "" THEN GOTO POK
$NOP:
$ INQUIRE P1 "Filename"
$ IF P1 .EQS. "" THEN GOTO NOP
$POK:
$ ASSIGN TT: FOR005
$ ASSIGN 'P1'.FOR FOR007
$ RUN MERLIN:STUB
$ DEASSIGN/ALL
