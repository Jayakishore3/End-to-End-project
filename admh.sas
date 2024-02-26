

libname adam "C:\Documents\E2E assignment\ADaM created datasets";

data new;
length usubjid $30;
set sdtm.mh (encoding='ISO-8859-1');
keep USUBJID MHSEQ MHTERM MHDECOD MHBODSYS MHCAT MHPRESP MHENRTPT MHSTDTC;
run;
proc sort data=new out=old;by usubjid;run;

data new2;
set adam.adsl;
keep STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N AGE AGEGR1 AGEGR1N SEX SEXN RACE RACEGR1 RACEGR1N ARM TRT01P
TRT01A SAFFL INDGR1 INDGR1N EXGR1 EXGR1N TRTSDT TRTEDT TR01SDT TR01EDT FUP01DT;
run;
proc sort data=new2 out=old2;by usubjid;run;

data adam.admh;
retain STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N AGE AGEGR1 AGEGR1N SEX SEXN RACE RACEGR1 RACEGR1N ARM TRT01P
TRT01A SAFFL INDGR1 INDGR1N EXGR1 EXGR1N TRTSDT TRTEDT TR01SDT TR01EDT FUP01DT MHSEQ MHTERM MHDECOD MHBODSYS MHCAT MHPRESP MHENRTPT MHSTDTC;
merge old(in=a) old2(in=b);
if a ;
by usubjid;
run;

libname xptf xport "C:\Documents\E2E assignment\xptf\admh.xpt";
data xptf.admh;
set adam.admh;
run;
