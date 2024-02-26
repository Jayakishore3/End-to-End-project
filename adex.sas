libname adam "C:\Documents\E2E assignment\ADaM created datasets";
data adam.adex;
retain STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N AGE RACE SEX SEXN RACEGR1 RACEGR1N AGEGR1 AGEGR1N CCGR1 CCGR1N INDGR1 INDGR1N
TRTP TRTPN TRTA TRTAN ASTDT AENDT PARAMCD PARAM EXDURDY EXDURMN EXDURWK EXDURYR AVALCAT1;
keep STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N AGE RACE SEX SEXN RACEGR1 RACEGR1N AGEGR1 AGEGR1N CCGR1 CCGR1N INDGR1 INDGR1N
TRTP TRTPN TRTA TRTAN ASTDT AENDT PARAMCD PARAM EXDURDY EXDURMN EXDURWK EXDURYR AVALCAT1;
label TRTP="Planned Treatment"
TRTPN="Planned Treatment (N)"
TRTA="Actual Treatment"
TRTAN="Actual Treatment (N)"
ASTDT="Analysis Start Date"
AENDT="Analysis End Date"
PARAMCD="Parameter Code"
PARAM="Parameter"
EXDURDY="Analysis Value"
EXDURWK="Analysis Value"
EXDURMN="Analysis Value"
EXDURYR="Analysis Value"
AVALCAT1="Analysis Category 1";
set adam.adsl;
trtp = trt01p;
trtpn = trt01pn;
trta = trt01a;
trtan = trt01an;
astdt=tr01sdt;
aendt=tr01edt;
if missing(AENDT) then EXDURDY = 1;
else EXDURDY = AENDT - ASTDT + 1;
exdurmn = round(exdurdy/30.4275,0.1);
exdurwk = round(exdurdy/7,0.1);
exduryr = round(exdurdy/365.25,0.1);
paramcd=catx(",",exdurdy,exdurwk,exdurmn,exduryr);
param=catx(",","Exposure Duration (Days)","Exposure Duration (Months)","Exposure Duration (Weeks)","Exposure Duration (Years)");
if 0<=exdurmn<6 then avalcat1='0 - <6 months';
else if 6<=exdurmn<12 then avalcat1='6 - <12 months';
else if 12<=exdurmn<18 then avalcat1='12 - <18 months';
else if 18<=exdurmn<24 then avalcat1='18 - <24 months';
else if 24<=exdurmn<30 then avalcat1='24 - <30 months';
else if exdurmn>=30 then avalcat1='>=30 months';
run;

libname xptf xport "C:\Documents\E2E assignment\xptf\adex.xpt";

data xptf.adex;
set adam.adex;
run;
