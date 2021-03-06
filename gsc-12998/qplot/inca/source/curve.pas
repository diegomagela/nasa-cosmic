[ IDENT       ('INCA'),
  INHERIT     ('QLIBHOME:STARLETQ',
               'QLIBHOME:STANDARD',
               'QLIBHOME:GENERAL',
               'QLIBHOME:DIRECTORY',
               'QLIBHOME:MATH',
               'QLIBHOME:COMPLEX',
               'QLIBHOME:STRING',
               'QLIBHOME:IO',
               'QLIBHOME:FIG',
               'FCN','FCNIO'),
  ENVIRONMENT ('CURVE')]
MODULE curve;
{=============================================================================}
{ CURVE DEFINITION }
CONST
   CURVELIM        = 20;
TYPE
   curveclass_type = (C_EMP,C_LOC,C_FRE,C_TIR);
{------------------------------}
{-- LOCUS CURVE DEFINITION ----}
{------------------------------}
CONST
   LOCBRASIZE      = 300;
   LOCARRSIZE      = 20000;
TYPE
   locend_type     = (ok,breakpoint, zero_found, outside_reg, no_loci,
                      near_boundary, storage_full, numeric_prob, gain_decrease,
                      sharp_bend, near_root, deriv_gain);

   ltype_type      = (EVA,RCO);

   locuscalc_type  = RECORD
                     plane           : char;
                     lim             : plotlimits;
                     CASE ltype : ltype_type OF
                        EVA:   (locfcn          : fcn;
                                phaseangle      : real;
                                dr              : real;
                                thbend          : real;
                                window          : real);
                        RCO:   (project         : logicalname;
                                expression      : anystring;
                                independent     : logicalname;
                                indmin          : real;
                                indmax          : real;
                                ds              : real);
                     END;

   locdat_type     = RECORD          { STORAGE FOR CALCULATED LOCUS POINTS }
                     pt              : complex;       { X-Y COORDINATES }
                     CASE ltype_type OF
                        EVA:  (lg    : real;          { LOG10 OF GAIN   }
                               dg    : real;          { dg/ds           }
                               th    : real);         { ANGLE OF LOCUS  }
                        RCO:  (ind   : real);         { LOG10 OF GAIN   }
                     END;

   locbranch_type  = RECORD
                     locmin,locmax   : integer;     { INIDICES INTO LOC ARRAY }
                     locend          : locend_type; { COMPLETION STATUS }
                     END;

   loccurve_type   = RECORD
                     l               : locuscalc_type;

                     brmax           : integer;
                     branch          : ARRAY [1..LOCBRASIZE] OF locbranch_type;
                     dat             : ARRAY [1..LOCARRSIZE] OF locdat_type;
                     END;
{------------------------------}
{-- FREQR CURVE DEFINITION ----}
{------------------------------}
CONST
   FREARRSIZE      = 10000;
TYPE
   ftype_type      = (SFR,NRA,DES,MNY);

   freqrcalc_type  = RECORD
                     dbdif         : real;
                     phdif         : real;
                     nyqdif        : real;
                     CASE ftype : ftype_type OF
                        SFR:   (wmin          : real;
                                wmax          : real;
                                bodsfcn       : fcn;
                                bodzfcn       : fcn;
                                tau           : real;
                                level         : integer;
                                zoh           : boolean;
                                star          : boolean;
                                compdelay     : real);
                        NRA:   ();
                        DES:   (amin          : real;
                                amax          : real;
                                dftype        : logicalname;
                                count         : integer;
                                p             : ARRAY [1..20] OF real;
 				ispwpf	      : boolean;
 				pwpf_omega    : real);
			MNY:   (numname       : integer;
      				pwpftype      : logicalname);
                     END;

   fredat_type     = RECORD
                     db            : real;
                     phase         : real;
                     CASE ftype_type OF
                        SFR,
                        NRA:   (omega         : real);
                        DES:   (amp           : real);
                     END;

   frecurve_type   = RECORD
                     f             : freqrcalc_type;

                     steps         : integer;
                     dat           : ARRAY [1..FREARRSIZE] OF fredat_type;
                     END;
{------------------------------}
{-- TIMER CURVE DEFINITION ----}
{------------------------------}
CONST
   TIRARRLIM       = 10;
   TIRARRSIZE      = 3000;
TYPE
   tirdat_type     = RECORD
                     time          : real;
                     value         : ARRAY [1..TIRARRLIM] OF real;
                     END;

   tircurve_type   = RECORD
                     tmin          : real;
                     tmax          : real;

                     blocktype     : char;
                     workplane     : char;
                     continuous    : boolean;
                     plantfcn      : fcn;
                     feedbackfcn   : fcn;
                     samplerfcn    : fcn;
                     inputfcn      : fcn;
                     compgain      : ARRAY [1..TIRARRLIM] OF real;
                     compdelay     : real;
                     zoh           : boolean;
                     tau           : real;
                     dt            : real;
                     substeps      : integer;
                     count         : integer;

                     steps         : integer;
                     dat           : ARRAY [1..TIRARRSIZE] OF tirdat_type;
                     END;
{------------------------------}
{-- CURVE DEFINITION ----------}
{------------------------------}
TYPE
   curve_item_type = RECORD
                     name            : logicalname;
                     lable           : anystring;
                     CASE curveclass : curveclass_type OF
                        C_EMP:  (emptr : $POINTER);
                        C_LOC:  (lcptr : ^loccurve_type);
                        C_FRE:  (fcptr : ^frecurve_type);
                        C_TIR:  (tcptr : ^tircurve_type);
                     END;
VAR
   curve           : RECORD
                     count     : integer;
                     data      : ARRAY [1..CURVELIM] OF curve_item_type;
                     END;
{=============================================================================}
{-- CURVE LIST PROCEDURES ----------------------------------------------------}
{=============================================================================}
FUNCTION getcurveindex (name : logicalname) : integer;
VAR
   i,j     : integer;
BEGIN
j := 0;
FOR i := 1 TO curve.count DO
   IF curve.data[i].name = name THEN j := i;
getcurveindex := j;
END;
{-----------------------------------------------------------------------------}
FUNCTION curveexist (name : logicalname) : boolean;
BEGIN
curveexist := getcurveindex (name) <> 0;
END;
{-----------------------------------------------------------------------------}
PROCEDURE deletecurve (name : logicalname);
VAR
   i,j     : integer;
BEGIN
j := getcurveindex (name);
IF j <> 0
 THEN
  BEGIN
  CASE curve.data[j].curveclass OF
     C_LOC:  dispose (curve.data[j].lcptr);
     C_FRE:  dispose (curve.data[j].fcptr);
     C_TIR:  dispose (curve.data[j].tcptr);
     END;
  FOR i := j+1 TO curve.count DO
     curve.data[i-1] := curve.data[i];
  curve.count := curve.count - 1;
  END;
END;
{-----------------------------------------------------------------------------}
FUNCTION createcurve (curveclass : curveclass_type;  name : logicalname;
   lable : anystring) : integer;
VAR
   i,j     : integer;
BEGIN
IF curveexist (name) THEN deletecurve (name);
IF curve.count = CURVELIM THEN raise ('Curve limit exceeded');
j := 1;
FOR i := 1 TO curve.count DO
   IF name > curve.data[i].name THEN j := i + 1;
FOR i := curve.count DOWNTO j DO
   curve.data[i+1] := curve.data[i];
curve.data[j].name         := name;
curve.data[j].curveclass   := curveclass;
curve.data[j].lable        := lable;
CASE curveclass OF
   C_LOC:  new (curve.data[j].lcptr);
   C_FRE:  new (curve.data[j].fcptr);
   C_TIR:  new (curve.data[j].tcptr);
   END;
curve.count := curve.count + 1;
createcurve := j;
END;
{-----------------------------------------------------------------------------}
PROCEDURE selectcurve (VAR sel : command_type;  allispossible : boolean;
   manyispossible : boolean);
VAR
   i : integer;
BEGIN
IF curve.count = 0
 THEN
  BEGIN
  sel := '';
  writeline (out,'No curves currently exist');
  pause;
  END
 ELSE
  BEGIN
  startcommand ('Curve Selection',false);
  IF allispossible THEN setcommand ('All');
  IF manyispossible THEN setcommand ('Many');
  FOR i := 1 TO curve.count DO
     setcommand (curve.data[i].name);
  readcommand (sel,ESC,false,'');
  END;
END;
{=============================================================================}
{-- CURVE FILE INPUT / OUTPUT PROCEDURES -------------------------------------}
{=============================================================================}
PROCEDURE loadcurve (filename : anystring;  verno : real);
VAR
   j              : integer;
   ch             : char;
   string,line,st : anystring;
   p              : parse_type;
   goodcurve      : boolean;
{------------------------------}
PROCEDURE loadlocus (VAR lc : loccurve_type);
{--------------------}
PROCEDURE loadlocusbranch;
BEGIN
lc.brmax := lc.brmax + 1;
WITH lc,l,branch[brmax] DO
   BEGIN
   IF lc.brmax = 1
    THEN locmin := 1
    ELSE locmin := branch[brmax-1].locmax+1;
   locmax := locmin - 1;
   readv (substr(string,8,length(string)-7),locend);
   WHILE NOT eof(textfile) AND ((index(string,'BRANCH')<>1)
                                                       OR (locmin>locmax)) DO
      BEGIN
      readln (textfile,string);
      IF index(string,'BRANCH') <> 1
       THEN
        BEGIN
        locmax := locmax + 1;
        readv (string,dat[locmax].lg,dat[locmax].pt.re,dat[locmax].pt.im);
        END;
      END;
   END;
END;
{--------------------}
BEGIN
WITH lc,l DO
   BEGIN
   locfcn := onefcn;
   locfcn.name := 'LOCUS_FUNCTION';
   readln (textfile,string);
   CASE string[1] OF
      'S':  BEGIN
            ltype := EVA;
            readln (textfile,string);  phaseangle := rofstr (string);
            readln (textfile,string);  dr         := rofstr (string);
            readln (textfile,string);  thbend     := rofstr (string);
            readln (textfile,string);  window     := rofstr (string);
            readfcn (textfile,locfcn);
            END;
      'C':  BEGIN
            ltype := RCO;
            readln (textfile,project);
            readln (textfile,expression);
            readln (textfile,independent);
            readln (textfile,string);  indmin := rofstr (string);
            readln (textfile,string);  indmax := rofstr (string);
            readln (textfile,string);  ds     := rofstr (string);
            END;
      END;
   readln (textfile,string);
   readln (textfile,string);  plane := string[1];
   readln (textfile,string);  lim.min.x  := rofstr(string);
   readln (textfile,string);  lim.min.y  := rofstr(string);
   readln (textfile,string);  lim.max.x  := rofstr(string);
   readln (textfile,string);  lim.max.y  := rofstr(string);

   brmax := 0;
   readln (textfile,string);
   WHILE NOT eof(textfile) DO loadlocusbranch;
   END;
END;
{------------------------------}
PROCEDURE loadfreqr (VAR fc : frecurve_type);
VAR
   i : integer;
BEGIN
WITH fc,f DO
   BEGIN
   ftype := SFR;
   bodsfcn := onefcn;
   bodzfcn := onefcn;
   steps := 0;
   level := 0;
   zoh   := false;
   compdelay := 0;
   tau   := UNDEFINED_REAL;
   readln (textfile,string);
   WHILE NOT eof(textfile) DO
      IF index (string,'S FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,bodsfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'Z FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,bodzfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'COMP DATA') = 1
       THEN
        BEGIN
        ftype := SFR;
        readln (textfile,string);  wmin      := rofstr (string);
        readln (textfile,string);  wmax      := rofstr (string);
        readln (textfile,string);  tau       := rofstr (string);
        readln (textfile,string);  level     := iofstr (string);
        readln (textfile,string);  zoh := string[1] = 'Z';
        readln (textfile,string);  compdelay := rofstr (string);
        readln (textfile,string);  star := string[1] = 'S';
        readln (textfile,string);
        END
      ELSE IF index (string,'DESCRIBING FUNCTION DATA') = 1
       THEN
        BEGIN
        ftype := DES;
        readln (textfile,string);  amin      := rofstr (string);
        readln (textfile,string);  amax      := rofstr (string);
        readln (textfile,dftype);
        readln (textfile,string);  count     := iofstr (string);
        FOR i := 1 TO count DO
           BEGIN  readln (textfile,string);  p[i] := rofstr (string);  END;
        readln (textfile,string);
       END
      ELSE
        WHILE NOT eof(textfile) DO
           BEGIN
           readln (textfile,string);
           steps := steps + 1;
           readv(string,dat[steps].omega,dat[steps].db,dat[steps].phase);
           END;
   END;
END;
{------------------------------}
PROCEDURE loadtimer (VAR tc : tircurve_type);
VAR
   k      : integer;
   p      : parse_type;
BEGIN
WITH tc DO
   BEGIN
   plantfcn := onefcn;
   samplerfcn := onefcn;
   feedbackfcn := onefcn;
   inputfcn := onefcn;
   steps := 0;
   readln (textfile,string);
   WHILE NOT eof(textfile) DO
      IF index (string,'INPUT FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,inputfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'PLANT FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,plantfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'FEEDBACK FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,feedbackfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'SAMPLER FUNCTION') = 1
       THEN
        BEGIN
        readfcn (textfile,samplerfcn);
        readln (textfile,string);
        END
      ELSE IF index (string,'COMP DATA') = 1
       THEN
        BEGIN
        readln (textfile,string);  tau       := rofstr (string);
        readln (textfile,string);  dt        := rofstr (string);
        readln (textfile,string);  substeps  := iofstr (string);
        readln (textfile,string);  blocktype := string[1];
        readln (textfile,string);  workplane := string[1];
        readln (textfile,string);  continuous:= string[1] = 'C';
        readln (textfile,string);  compdelay := rofstr (string);
        readln (textfile,string);  zoh := string[1] = 'Z';
        readln (textfile,string);
        END
      ELSE IF index (string,'COMP GAIN') = 1
       THEN
        BEGIN
        readln (textfile,string);  count     := iofstr (string);
        FOR k := 1 TO count DO
           BEGIN
           readln (textfile,string);  compgain[k] := rofstr (string);
           END;
        readln (textfile,string);
        END
      ELSE IF index (string,'DATA') = 1
       THEN
        WHILE NOT eof(textfile) DO
           BEGIN
           steps := steps + 1;
           readln (textfile,string);
           startparse (p,string);
           dat[steps].time := rofstr (parse (p,' ,'));
           FOR k := 1 TO count DO
              dat[steps].value[k] := rofstr (parse (p,' ,'));
           END;
   END;
END;
{------------------------------}
BEGIN
IF exist (filename)
 THEN
  BEGIN
  close (textfile,ERROR:=CONTINUE);
  open (textfile,filename,old,ERROR:=CONTINUE);
  IF status (textfile) <> 0 THEN raise ('Curve file not found');
  reset (textfile);
  readln (textfile,string);
  IF string = '' THEN ch := ' ' ELSE ch := string[1];
  startparse (p,string);
  goodcurve := false;
  REPEAT
     st := parse (p,' ');
     IF st = 'INCA'
      THEN
       BEGIN
       st := parse (p,' ');
       IF rofstr (st) >= 3.00 THEN goodcurve := true;
       END;
     UNTIL st = '';
  IF NOT goodcurve
   THEN writeline (out,'Curve file is possibly not compatible with INCA '
                       + strofr2 (verno,4,2));
  readln (textfile,string);
  deletecurve (string);
  CASE ch OF
     'F':  BEGIN
           j := createcurve (C_FRE,string,'File=' + filename);
           loadfreqr (curve.data[j].fcptr^);
           END;
     'R':  BEGIN
           j := createcurve (C_LOC,string,'File=' + filename);
           loadlocus (curve.data[j].lcptr^);
           END;
     'T':  BEGIN
           j := createcurve (C_TIR,string,'File=' + filename);
           loadtimer (curve.data[j].tcptr^);
           END;
     END;
  close (textfile);
  END
 ELSE
  BEGIN
  writeline (out,'Curve ' + filename + ' not found');
  pause;
  END;
END;
{-----------------------------------------------------------------------------}
PROCEDURE writecurve (sel : command_type;  filename : anystring;  verno : real);
VAR
   j        : integer;
   string   : anystring;
{------------------------------}
PROCEDURE transfer;
BEGIN
reset (tempfile);
WHILE NOT eof(tempfile) DO
   BEGIN
   readln (tempfile,string);
   writeln (textfile,string);
   END;
END;
{------------------------------}
PROCEDURE writelocus (VAR lc : loccurve_type);
VAR
   i,br   : integer;
BEGIN
WITH lc,l DO
   BEGIN
   CASE ltype OF
      EVA:  BEGIN
            writeln (textfile,'STANDARD LOCUS');
            writeln (textfile,strofr(phaseangle,0));
            writeln (textfile,strofr(dr,0));
            writeln (textfile,strofr(thbend,0));
            writeln (textfile,strofr(window,0));
            rewrite (tempfile);  writefcn (temp,locfcn,'R');  transfer;
            END;
      RCO:  BEGIN
            writeln (textfile,'CONTOUR LOCUS');
            writeln (textfile,project);
            writeln (textfile,expression);
            writeln (textfile,independent);
            writeln (textfile,strofr(indmin,0));
            writeln (textfile,strofr(indmax,0));
            writeln (textfile,strofr(ds,0));
            END;
      END;
   writeln (textfile,'PLANE AND LIMITS');
   writeln (textfile,plane);
   writeln (textfile,strofr(lim.min.x,0));
   writeln (textfile,strofr(lim.min.y,0));
   writeln (textfile,strofr(lim.max.x,0));
   writeln (textfile,strofr(lim.max.y,0));
   FOR br := 1 TO brmax DO WITH branch[br] DO
      BEGIN
      writev (string,locend);
      writeln (textfile,'BRANCH  ' + stripblank(string));
      FOR i := locmin TO locmax DO
         writeln (textfile,dat[i].lg,' ',dat[i].pt.re,' ',dat[i].pt.im);
      END;
   END;
END;
{------------------------------}
PROCEDURE writefreqr (VAR fc : frecurve_type);
VAR
   i      : integer;
BEGIN
WITH fc,f DO
   BEGIN
   CASE ftype OF
      SFR:  BEGIN
            writeln (textfile,'S FUNCTION');
            rewrite (tempfile);  writefcn (temp,bodsfcn,'R');  transfer;
            writeln (textfile,'Z FUNCTION');
            rewrite (tempfile);  writefcn (temp,bodzfcn,'R');  transfer;
            writeln (textfile,'COMP DATA');
            writeln (textfile,strofr(wmin,0));
            writeln (textfile,strofr(wmax,0));
            writeln (textfile,strofr(tau,0));
            writeln (textfile,strofi(level,6));
            IF zoh
             THEN writeln (textfile,'ZOH')
             ELSE writeln (textfile,'NO ZOH');
            writeln (textfile,strofr(compdelay,0));
            IF star
             THEN writeln (textfile,'STAR')
             ELSE writeln (textfile,'NO STAR');
            END;
      NRA:  ;
      DES:  BEGIN
            writeln (textfile,'DESCRIBING FUNCTION DATA');
            writeln (textfile,strofr(amin,0));
            writeln (textfile,strofr(amax,0));
            writeln (textfile,dftype);
            writeln (textfile,strofi(count,6));
            FOR i := 1 TO count DO
               writeln (textfile,strofr(p[i],0));
            END;
      MNY:  ;
      END;

   writeln (textfile,'DATA');
   FOR i := 1 TO steps DO
      writeln (textfile,dat[i].omega,' ',dat[i].db,' ',dat[i].phase);
   END;
END;
{------------------------------}
PROCEDURE writetimer (VAR tc : tircurve_type);
VAR
   i,k    : integer;
   string : anystring;
BEGIN
WITH tc DO
   BEGIN
   writeln (textfile,'PLANT FUNCTION');
   rewrite (tempfile);  writefcn (temp,plantfcn,'R');  transfer;
   writeln (textfile,'FEEDBACK FUNCTION');
   rewrite (tempfile);  writefcn (temp,feedbackfcn,'R');  transfer;
   writeln (textfile,'SAMPLER FUNCTION');
   rewrite (tempfile);  writefcn (temp,samplerfcn,'R');  transfer;
   writeln (textfile,'INPUT FUNCTION');
   rewrite (tempfile);  writefcn (temp,inputfcn,'R');  transfer;
   writeln (textfile,'COMP DATA');
   writeln (textfile,strofr(tau,20));
   writeln (textfile,strofr(dt,20));
   writeln (textfile,strofi(substeps,6));
   writeln (textfile,blocktype);
   writeln (textfile,workplane);
   IF continuous
    THEN writeln (textfile,'CONTINUOUS')
    ELSE writeln (textfile,'NOT CONTINUOUS');
   writeln (textfile,strofr(compdelay,20));
   IF zoh
    THEN writeln (textfile,'ZOH')
    ELSE writeln (textfile,'NO ZOH');
   writeln (textfile,'COMP GAIN');
   writeln (textfile,count);
   FOR k := 1 TO count DO
      writeln (textfile,strofr(compgain[k],20));
   writeln (textfile,'DATA');
   FOR i := 1 TO steps DO
      BEGIN
      write (textfile,dat[i].time);
      FOR k := 1 TO count DO
         write (textfile,' ',dat[i].value[k]);
      writeln (textfile);
      END;
   END;
END;
{------------------------------}
BEGIN
IF curveexist (sel)
 THEN
  BEGIN
  j := getcurveindex (sel);
  close (textfile,ERROR:=CONTINUE);
  CASE curve.data[j].curveclass OF
     C_LOC:  BEGIN
             open (textfile,filename + '.RL',NEW,1023);
             rewrite (textfile);
             writeln (textfile,'ROOT LOCUS CURVE, INCA '
                               + strofr2 (verno,4,2));
             writeln (textfile,sel);
             writelocus (curve.data[j].lcptr^);
             close (textfile);
             END;
     C_FRE:  BEGIN
             open (textfile,filename + '.FR',NEW,1023);
             rewrite (textfile);
             writeln (textfile,'FREQUENCY RESPONSE CURVE, INCA '
                               + strofr2 (verno,4,2));
             writeln (textfile,sel);
             writefreqr (curve.data[j].fcptr^);
             close (textfile);
             END;
     C_TIR:  BEGIN
             open (textfile,filename + '.TR',NEW,1023);
             rewrite (textfile);
             writeln (textfile,'TIME RESPONSE CURVE, INCA '
                               + strofr2 (verno,4,2));
             writeln (textfile,sel);
             writetimer (curve.data[j].tcptr^);
             close (textfile);
             END;
     END;
  END;
END;
{-----------------------------------------------------------------------------}
PROCEDURE showcurvetable (dest : destination);
VAR
   j    : integer;
   sel  : command_type;
{------------------------------}
PROCEDURE showlocustable (VAR lc : loccurve_type);
VAR
   k,j,jmax,i,br : integer;
   head,line,str : anystring;
   sdata         : ARRAY [1..3] OF anystring;
BEGIN
WITH lc,l DO
   BEGIN
   CASE ltype OF
      EVA:  head := ' GAIN (k)      REAL part     IMAG part ';
      RCO:  head := ' INDEPENDENT   REAL part     IMAG part ';
      END;
   line := '-----------   -----------   -----------';
   FOR br := 1 TO brmax DO
      WITH branch[br] DO
         BEGIN
         writeline (dest,'');
         writeline (dest,'');
         writev (str,locend);
         writeline (dest,'BRANCH NUMBER '
                            + strofi(br,3) + ' CONTAINS POINTS FROM '
                            + strofi(locmin,4) + ' TO ' + strofi(locmax,4)
                            + ', AND ENDED BECAUSE OF ' + stripblank (str));
         writeline (dest,'');
         writeline (dest,head + '  ||  ' + head + '  ||  ' + head);
         writeline (dest,line + '  ||  ' + line + '  ||  ' + line);
         jmax := (locmax-locmin+3) DIV 3;
         FOR j := 1 TO jmax DO
            BEGIN
            FOR k := 1 TO 3 DO
               BEGIN
               i := (locmin-1) + (jmax*(k-1)+j);
               IF i > locmax
                THEN sdata[k] := ''
                ELSE
                 CASE ltype OF
                    EVA:  sdata[k] := strofr(exp10(dat[i].lg),11)
                            + '   ' + strofr(dat[i].pt.re,11)
                            + '   ' + strofr(dat[i].pt.im,11);
                    RCO:  sdata[k] := strofr(dat[i].ind,11)
                            + '   ' + strofr(dat[i].pt.re,11)
                            + '   ' + strofr(dat[i].pt.im,11);
                    END;
               END;
            writeline (dest,sdata[1] + '  ||  ' + sdata[2] + '  ||  ' + sdata[3]);
            END;
         writeline (dest,line + '  ||  ' + line + '  ||  ' + line);
         END;
   END;
END;
{------------------------------}
PROCEDURE showfreqrtable (VAR fc : frecurve_type);
VAR
   i     : integer;
   chnat : VARYING [3] OF char;
BEGIN{showfreqrtable}
WITH fc,f DO
   CASE ftype of
      NRA: ;
      SFR: BEGIN
           writeline (dest,'') ;
           writeline (dest,'FREQ: rad/s   Nat    Hertz            '
                        +  ' REAL part   IMAG part          '
                        +  ' amplitude   decibels           '
                        +  ' ARG: rads   ARG: deg  ');
           writeline (dest,'------------- --- -----------         '
                        +  '----------- -----------         '
                        +  '----------- -----------         '
                        +  '----------- -----------');
           FOR i := 1 TO steps DO WITH dat[i] DO
              BEGIN
              IF abs(db) > 10 * LOGINFINITY
               THEN chnat := '***'
               ELSE chnat := '   ';
              writeline (dest,     strofr (omega,13)
                + ' '         + chnat
                + ' '         + strofr (omega/2d0/PI,11)
                + '         ' + strofr (exp10(db/20d0) * cos(phase*PI/180d0),11)
                + ' '         + strofr (exp10(db/20d0) * sin(phase*PI/180d0),11)
                + '         ' + strofr (exp10(db/20d0),11)
                + ' '         + strofr (db,11)
                + '         ' + strofr (phase * PI/180d0,11)
                + ' '         + strofr (phase,11));
              END;
           writeline (dest,'------------- --- -----------         '
                        +  '----------- -----------         '
                        +  '----------- -----------         '
                        +  '----------- -----------');
           writeline (dest,'');
           END;{SFR}
      DES: BEGIN
           writeline (dest,'') ;
           writeline (dest,'amplitude            '
                        +  ' REAL part   IMAG part          '
                        +  ' range   decibels           '
                        +  ' ARG: rads   ARG: deg  ');
           writeline (dest,'-------------         '
                        +  '----------- -----------         '
                        +  '------- --------           '
                        +  '----------- -----------');
           FOR i := 1 TO steps DO WITH dat[i] DO
              BEGIN
              IF abs(db) > 10 * LOGINFINITY
               THEN chnat := '***'
               ELSE chnat := '   ';
              writeline (dest,     strofr (amp,13)
                + ' '         + chnat
                + '         ' + strofr (exp10(db/20d0) * cos(phase*PI/180d0),11)
                + ' '         + strofr (exp10(db/20d0) * sin(phase*PI/180d0),11)
                + '         ' + strofr (exp10(db/20d0),11)
                + ' '         + strofr (db,11)
                + '         ' + strofr (phase * PI/180d0,11)
                + ' '         + strofr (phase,11));
              END;
           writeline (dest,'-------------         '
                        +  '----------- -----------         '
                        +  '------- --------           '
                        +  '----------- -----------');
           writeline (dest,'');
           END;
   END;
END;
{------------------------------}
PROCEDURE showtimertable (VAR tc : tircurve_type);
VAR
   i,j,k,l,jmax : integer;
BEGIN
WITH tc DO
   FOR k := 1 TO count DO
      BEGIN
      writeline (dest,'');
      writeline (dest,'COMPENSATION GAIN : ' + strofr (compgain[k],14));
      writeline (dest,'');
      FOR l := 1 TO 4 DO writestring (dest,'     TIME        VALUE          ');
      writeline (dest,'');
      writeline (dest,'');
      jmax := (steps+3) DIV 4;
      FOR j := 1 TO jmax DO
         BEGIN
         FOR l := 1 TO 4 DO
            BEGIN
            i := jmax * (l-1) + j;
            IF i <= steps
             THEN writestring (dest,strofr (dat[i].time,13)
                                  + strofr (dat[i].value[k],13));
            IF l <> 4 THEN writestring (dest,'  ||  ');
            END;
         writeline (dest,'')
         END;
      writeline (dest,'');
      END;
END;
{------------------------------}
BEGIN
selectcurve (sel,false,false);
IF curveexist (sel)
 THEN
  BEGIN
  j := getcurveindex (sel);
  CASE curve.data[j].curveclass OF
     C_LOC:  showlocustable (curve.data[j].lcptr^);
     C_FRE:  showfreqrtable (curve.data[j].fcptr^);
     C_TIR:  showtimertable (curve.data[j].tcptr^);
     END;
  END;
END;
{-----------------------------------------------------------------------------}
PROCEDURE wormcurvestotext;
VAR
   j    : integer;
   sel  : command_type;
{------------------------------}
PROCEDURE wormcurvestimer (VAR tc : tircurve_type);
VAR
   i,j,k,l,jmax : integer;
   v            : RECORD
                  CASE integer OF
                     1:   (dummy1  : char;
                           dummy2  : char;
                           r       : ARRAY [0..TIRARRLIM] OF real);
                     2:   (st      : VARYING [8 * (TIRARRLIM+1)] OF char);
                  END;
BEGIN
WITH tc DO
   FOR i := 1 TO steps DO
      BEGIN
      v.st.length := 8 * (1 + count);
      v.r[0] := dat[i].time;
      FOR k := 1 TO count DO
         v.r[k] := dat[i].value[k];
      writeln (textfile,v.st);
      END;
END;
{------------------------------}
BEGIN
selectcurve (sel,false,false);
IF curveexist (sel)
 THEN
  BEGIN
  j := getcurveindex (sel);
  CASE curve.data[j].curveclass OF
     C_LOC:  ;
     C_FRE:  ;
     C_TIR:  wormcurvestimer (curve.data[j].tcptr^);
     END;
  END;
END;
{-----------------------------------------------------------------------------}
PROCEDURE listcurves (dest : destination);
VAR
   i,j : integer;
BEGIN
writeline (dest,'  #  Name      Label               Steps Type');
writeline (dest,'---  -----     ---------------     ----- ---------------');
FOR i := 1 TO curve.count DO
   WITH curve.data[i] DO
      BEGIN
      writestring (dest,strofi(i,3) + '  ' + strfix (name,10)
                      + strfix (lable,20));
      CASE curveclass OF
         C_EMP:  writeline (dest,'      Null curve type, internal error');
         C_LOC:  WITH lcptr^,l DO
                    BEGIN
                    writestring (dest,strofi(branch[brmax].locmax,5) + ' ');
                    CASE ltype OF
                       EVA:  writeline (dest,'Evans Locus of ' + locfcn.name);
                       RCO:  writeline (dest,'Contour Locus of ' + expression);
                       END;
                    END;
         C_FRE:  WITH fcptr^,f DO
                    BEGIN
                    writestring (dest,strofi(steps,5) + ' ');
                    CASE ftype OF
                       SFR:  IF star
                              THEN writeline (dest,'GH* frequency response')
                              ELSE writeline
                                        (dest,'Standard frequency response');
                       NRA:  ;
                       DES:  writeline(dest,'Describing Funct., Type '+dftype);
 		       MNY:  writeline(dest,'Describing Funct., Type '+pwpftype);
                       END;
                    END;
         C_TIR:  WITH tcptr^ DO
                    BEGIN
                    writestring (dest,strofi(steps,5) + ' ');
                    CASE blocktype OF
                       'S':  writeline (dest,'Simple Time Response');
                       'C':  writeline (dest,'Closed Loop Time Response');
                       'P':  writeline (dest,'Plant Sampler Time Response');
                       'F':  writeline (dest,'Feedback Sampler Time Response');
                       END;
                    END;
         END;
      END;
writeline (dest,'---  -----     ---------------     ----- ---------------');
END;
{=============================================================================}
END.
