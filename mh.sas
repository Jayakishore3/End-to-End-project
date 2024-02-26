
options validvarname=upcase;

data mh1;
set end.odi;
studyid="CYT001-302";
domain="MH";
usubjid=catx("-",prot,batch,pno);
run;

proc sort data=mh1 out=mh2;
by usubjid;
run;

data mh3;
set mh2;
retain mhseq 0;
by usubjid;
if first.usubjid then mhseq=1;
else do mhseq=mhseq+1;end;
mhterm=od_diag;
mhcat="General Medical History";
if od_type="CURRENT" then mhenrtpt="ONGOING";
keep studyid domain usubjid mhseq mhterm mhcat mhenrtpt;
run;
proc sort data=mh3 out=mh4; by usubjid;run;

data bsl;
set end.bsl;
usubjid=catx("-",prot,batch,pno);
mhterm="Pulmonary Arterial Hypertension";
if mhterm="Pulmonary Arterial Hypertension" then mhoccur="Y";
if mhterm="Pulmonary Arterial Hypertension" then mhstdtc=put(input(pah_dt,anydtdte.),yymmdd10.);
keep usubjid mhterm mhoccur mhstdtc;
run;

proc sort data=bsl out=bsl1; by usubjid;run;

libname sdtm "C:\Documents\E2E assignment\SDTM created datasets";
data sdtm.mh;
length STUDYID $17 DOMAIN $2 USUBJID $24 MHSEQ 8 MHTERM $69 MHCAT MHOCCUR $8 MHENRTPT $8;
retain STUDYID DOMAIN USUBJID MHSEQ MHTERM MHCAT MHOCCUR MHSTDTC MHENRTPT;
label STUDYID="Study Identifier"
DOMAIN="Domain Abbreviation"
USUBJID="Unique Subject Identifier"
MHSEQ="Sequence Number"
MHTERM="Reported Term for the Medical History"
MHCAT="Medical History Category"
MHPRESP="Medical History Event Pre-Specified"
MHOCCUR="Medical History Occurence"
MHSTDTC="Start Date/Time of Medical History Event"
MHENRTPT="End Relative to Reference Time Point";
merge mh4(in=a) bsl1(in=b);
if a and b;
by usubjid;
keep STUDYID DOMAIN USUBJID MHSEQ MHTERM MHCAT MHOCCUR MHSTDTC MHENRTPT;
run;

libname xptf xport "C:\Documents\E2E assignment\xptf\mh.xpt";

data xptf.mh;
set sdtm.mh;
run;
