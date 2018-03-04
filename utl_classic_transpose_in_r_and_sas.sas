Classic transpose problem in R and SAS

  Two Solutions

     1. WPS/PROC R / SAS/IML/R
     2. Base WPS/SAS Proc transpose

  If final cell values are numeric (consider)

     want<-xtabs(CT~WN1 + WN2, have);

slight variation of
https://stackoverflow.com/questions/49083512/r-lookup-chart-from-data-frame

INPUT
=====

SD1.HAVE total obs=16

 WN1    WN2    CT

  A      1     72
  A      2     82
  A      3     87
  A      4     11

  B      1     74
  B      2     01
  B      3     86
  B      4     79

  C      1     57
  C      2     No
  C      3     03
  C      4     61

  D      1     83
  D      2     67
  D      3     48
  D      4     41

 EXAMPLE WANT

 WORK.WANT total obs=4

  WN1    _1    _2    _3    _4

   A     72    82    87    11
   B     74    01    86    79
   C     57    No    03    61
   D     83    67    48    41


 1. WPS/PROC R (Working code)

    have %>% spread(WN2, CT) -> want;

 2. WPS/SAS Proc transpose

    proc transpose data=sd1.have out=want;
     by wn1;
       var ct;
       id wn2;
    run;quit;

OUTPUT
======

WORK.WANTtotal obs=4

   WN1    _1    _2    _3    _4

    A     72    82    87    11
    B     74    01    86    79
    C     57    No    03    61
    D     83    67    48    41

*                _               _       _
 _ __ ___   __ _| | _____     __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \   / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/  | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|   \__,_|\__,_|\__\__,_|

;
options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
 input wn1$ wn2$ ct$;
cards4;
A 1 72
A 2 82
A 3 87
A 4 11
B 1 74
B 2 01
B 3 86
B 4 79
C 1 57
C 2 No
C 3 03
C 4 61
D 1 83
D 2 67
D 3 48
D 4 41
;;;;
run;quit;
*          _       _   _
 ___  ___ | |_   _| |_(_) ___  _ __  ___
/ __|/ _ \| | | | | __| |/ _ \| '_ \/ __|
\__ \ (_) | | |_| | |_| | (_) | | | \__ \
|___/\___/|_|\__,_|\__|_|\___/|_| |_|___/

;

* BASE SAS/WPS;
proc transpose data=sd1.have out=want;
 by wn1;
   var ct;
   id wn2;
run;quit;

%utl_submit_wps64('
libname wrk "%sysfunc(pathname(work))";
libname sd1 "d:/sd1";
proc transpose data=sd1.have out=wrk.wantwps;
 by wn1;
   var ct;
   id wn2;
run;quit;
');

* WPS/PROC R;


%utl_submit_wps64('
libname sd1 "d:/sd1";
options set=R_HOME "C:/Program Files/R/R-3.3.2";
libname wrk "%sysfunc(pathname(work))";
proc r;
submit;
source("C:/Program Files/R/R-3.3.2/etc/Rprofile.site", echo=T);
library(haven);
library(tidyverse);
have<-read_sas("d:/sd1/have.sas7bdat");
have %>% spread(WN2, CT) -> want;
endsubmit;
import r=want  data=wrk.want;
run;quit;
');

