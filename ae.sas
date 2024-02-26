
/*creation of ae dataset from aes_new*/
data ae1;
length usubjid $24 STUDYID $17 DOMAIN $2;
set end.aes_new;
studyid= "CYT001-302";
domain="AE";
usubjid=catx("-",prot,batch,pno);
run;
proc sort data=ae1;
by usubjid;
run;
data ae2;
keep STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AESEV AESER AEACN AEREL AEOUT AESDTH AESHOSP AESTDTC AEENDTC;
length  AESEQ 8 AETERM $36 AEDECOD $32 AESEV $8 AESER $1 AEACN $16 AEREL $16 AEOUT $26 AESDTH $1 AESHOSP $1;
set ae1;
by usubjid;
retain aeseq 0;
if first.usubjid then aeseq=1;
else do aeseq=aeseq+1; end;
aeterm=ae_symp;
aedecod=aepref1;
aesev=ae_sev;
if serious=0 then aeser="No";
else if serious=1 then aeser="Yes";
aeacn=ae_tda;
aerel=ae_rel;
aeout=ae_out;
if aeout="death" then aesdth="Y";
else aesdth="";
if ae_hsn=0 then aeshosp="N";
else if ae_hsn=1 then aeshosp="Y";
aestdtc=put(input(ae_date,anydtdte.), yymmdd10.);
aeendtc=put(input(ae_end,anydtdte.), yymmdd10.);
run;

proc sort data=ae2 out=ae3;
by usubjid;
run;
libname sdtm "C:\Documents\E2E assignment\SDTM created datasets";
proc sort data=sdtm.dm out=dm2;
by usubjid;
run;

data sdtm.ae;
length AESTDY $8 AEENDY $8;
retain STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AESEV AESER AEACN AEREL AEOUT AESDTH AESHOSP AESTDTC AEENDTC AESTDY AEENDY;
keep STUDYID DOMAIN USUBJID AESEQ AETERM AEDECOD AESEV AESER AEACN AEREL AEOUT AESDTH AESHOSP AESTDTC AEENDTC AESTDY AEENDY;
label STUDYID=Study Identifier
DOMAIN=Domain Abbreviation
USUBJID=Unique Subject Identifier
AESEQ=Sequence Number
AETERM=Reported Term for the Adverse Event
AEDECOD=Dictionary-Derived Term
AESEV=Severity/Intensity
AESER=Serious Event
AEACN=Action Taken with Study Treatment
AEREL=Causality
AEOUT=Outcome of Adverse Event
AESDTH=Results in Death
AESHOSP=Requires or Prolongs Hospitalization
AESTDTC=Start Date/Time of Adverse Event
AEENDTC=End Date/Time of Adverse Event
AESTDY=Study Day of Start of Adverse Event
AEENDY=Study Day of End of Adverse Event;
merge ae3 (in=a) dm2(in=b);
if a and b ;
by usubjid;
If (AESTDTC < RFSTDTC) then AESTDY=input(AESTDTC,yymmdd10.)-input(RFSTDTC,yymmdd10.);
Else if (AESTDTC >= RFSTDTC) then AESTDY=input(AESTDTC,yymmdd10.)-input(RFSTDTC,yymmdd10.)+1;
If (AEENDTC < RFSTDTC) then AEENDY=input(AEENDTC,yymmdd10.)-input(RFSTDTC,yymmdd10.);
Else if (AEENDTC >= RFSTDTC) then AEENDY=input(AEENDTC,yymmdd10.)-input(RFSTDTC,yymmdd10.)+1;
run;

/*xpt file conversion*/
libname xptf xport "C:\Documents\E2E assignment\xptf\ae.xpt";
data xptf.ae;
set sdtm.ae;
run;
