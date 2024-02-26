
options validvarname=upcase;
data ds1;
length studyid $17 domain $2 usubjid $24;
set end.disp;
studyid="CYT001-302";
DOMAIN="DS";
usubjid=catx("-",studyid,batch,pno);
run;

data dbsl;
length studyid $17 usubjid $24 dsterm $60 dscat $18;
set end.bsl;
studyid="CYT001-302";
usubjid=catx("-",prot,batch,pno);
dsterm="RANDOMIZED";
if dsterm="RANDOMIZED" then dsdecod="RANDOMIZED";
dscat="PROTOCOL MILESTONE";
dsstdtc=put(input(pah_dt,anydtdte.),yymmdd10.);
keep studyid usubjid dsterm dscat dsstdtc;
run;
proc sort data=dbsl;by studyid usubjid ;run;



proc sort data=ds1 out=ds2;
by studyid usubjid;
run;

data ds3;
length domain $2 dsseq 8 dsterm $60 dsdecod $25 dscat $18;
set ds2;
retain dsseq 0;
by studyid usubjid;
if first.usubjid then dsseq=1;
else do dsseq=dsseq+1;end;
dsterm=term_rea;
if term_rea="Death" then dsterm=deacau;
else if term_yn="Y" then dsterm="COMPLETED";
if term_yn="Y" then dsdecod="COMPLETED";
else if dsterm in ("DEATH", "Lost to follow-up", "Administrative reason") then dsdecod = propcase(dsterm);
else if dsterm="Withdrawal of subject’s consent" then dsdecod="WITHDRAWAL BY SUBJECT";
dscat="DISPOSITION EVENT";
dsscat="END OF STUDY";
dsstdtc=put(input(v_dt,anydtdte.), yymmdd10.);
if term_yn="N" then dsstdtc=put(input(SC_WDT,anydtdte.),yymmdd10.);
if dsdecod="death" then dsstdtc=put(input(dea_dat,anydtdte.),yymmdd10.);
run;

proc sort data=ds3;by studyid usubjid;run;

data dis;
merge dbsl (in=a) ds3(in=b);
if a ;
by usubjid;
run;
proc sort data=dis; by studyid usubjid;run;

libname sdtm "C:\Documents\E2E assignment\SDTM created datasets";
data new;
set sdtm.dm;
drop domain;
run;

proc sort data=new out=dm1 ; by studyid usubjid; run;


data sdtm.ds;
retain STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSCAT DSSTDTC DSSTDY;
label STUDYID="Study Identifier"
DOMAIN="Domain Abbreviation"
USUBJID="Unique Subject Identifier"
DSSEQ="Sequence Number"
DSTERM="Reported Term for the Disposition Event"
DSDECOD="Standardized Disposition Term"
DSCAT="Category for Disposition Event"
DSSCAT="Sub-Category for Disposition Event"
DSSTDTC="Start Date/Time of Disposition Event"
DSSTDY="Study Day of Start of Disposition Event";

merge dis(in=a) dm1(in=b);
if a;
by studyid usubjid;
if (DSSTDTC ne "" and RFSTDTC ne "") and input(DSSTDTC, yymmdd10.) >= input(RFSTDTC, yymmdd10.) then DSSTDY = input(DSSTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + 1;
else if (DSSTDTC ne "" and RFSTDTC ne "") and input(DSSTDTC, yymmdd10.) < input(RFSTDTC, yymmdd10.) then DSSTDY = input(DSSTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.);
keep STUDYID DOMAIN USUBJID DSSEQ DSTERM DSDECOD DSCAT DSSCAT DSSTDTC DSSTDY;
run;

libname xptf xport "C:\Documents\E2E assignment\xptf\ds.xpt";

data xptf.ds;
set sdtm.ds;
run;
