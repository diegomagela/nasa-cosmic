$ ON CONTROL_Y THEN GOTO OUT
$ SET TERMINAL/WIDTH=132
$ ASSIGN TT: FOR005
$ ASSIGN TT: FOR006
$ RUN MERLIN:DOUBLE
$OUT:
$ SET TERMINAL/WIDTH=80