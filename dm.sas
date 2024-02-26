
/*creation of dm from dem dataset*/
data dm1 (rename=(aget=age));
keep STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGET AGEU SEX
RACE ARMCD ARM ACTARMCD ACTARM ARMNRS ACTARMUD DMDTC;
length STUDYID $17 DOMAIN $2 USUBJID $24 SUBJID $6 DTHFL $1 SITEID $4 AGET 8 AGEU $5
SEX $1 RACE $25 ARMCD $1 ARM $20 ACTARMCD $1 ACTARM $20 ARMNRS $7 ACTARMUD $1;
set end.dem;
studyid="CYT001-302";
domain="DM";
usubjid=catx("-",prot,batch,pno);
subjid=put(pno,best6.);
rfstdtc=put(input(starttrd,date9.), yymmdd10.);
rfendtc=put(input(endtrd,date9.), yymmdd10.);
rfxstdtc=rfstdtc;
rfxendtc=rfendtc;
rficdtc=put(input(scr_dt,date9.), yymmdd10.);
rfpendtc=put(input(lvis_dt,date9.), yymmdd10.);
if deacau ne "" then dthdtc=put(input(dea_dd,date9.), yymmdd10.);
if not missing (dthdtc) then dthfl="y";
siteid=put(batch,best4.);
aget=input(age,best.);
if not missing (age) then ageu="years";
if sex="1" then sex="Male";
else if sex="2" then sex="Female";
if racetxt="01Caucasian/white" then race="Caucasian/White";
else if racetxt="02Black" then race="Black";
else if racetxt="03Asian" then race="Asian";
else if racetxt="04Hispanic" then race="Hispanic";
armcd=put(anagrp,best1.);
if anagrp=1 then arm="PLACEBO";
else if anagrp=2 then arm="CYT001 3 mg";
else if anagrp=3 then arm="CYT001 10 mg";
if not missing(rfstdtc) then actarmcd=put(anagrp,best1.);
if not missing (rfstdtc) then do;
if actarmcd="1" then actarm="PLACEBO";
else if actarmcd="2" then actarm="CYT001 3 mg";
else if actarmcd="3" then actarm="CYT001 10 mg";end;
if missing (rfstdtc) and arm ne "" then armnrs="ASSIGNED, NOT TREATED";
actarmud=" ";
if scr_dt ne "" then dmdtc=put(input(scr_dt,date9.),yymmdd10.);
run;

proc sort data=dm1 out=dm2;
by siteid;
run;

data cntry;
set end.crt;
siteid=put(batch,best4.);
drop batch;
run;
proc sort data=cntry out=cntry2;
by siteid;
run;

/*sdtm library for storing dm dataset*/
libname sdtm "C:\Documents\E2E assignment\SDTM created datasets";

/*merging with crt for country data*/
data sdtm.dm;
retain STUDYID DOMAIN USUBJID SUBJID RFSTDTC RFENDTC RFXSTDTC RFXENDTC RFICDTC RFPENDTC DTHDTC DTHFL SITEID AGE AGEU SEX
RACE ARMCD ARM ACTARMCD ACTARM ARMNRS ACTARMUD DMDTC COUNTRY;
label STUDYID=Study Identifier
DOMAIN=Domain Abbreviation
USUBJID=Unique Subject Identifier
SUBJID=Subject Identifier for the Study
RFSTDTC=Subject Reference Start Date/Time
RFENDTC=Subject Reference End Date/Time
RFXSTDTC=Date/Time of First Study Treatment
RFXENDTC=Date/Time of Last Study Treatment
RFICDTC=Date/Time of Informed Consent
RFPENDTC=Date/Time of End of Participation
DTHDTC=Date/Time of Death
DTHFL=Subject Death Flag
SITEID=Study Site Identifier
AGE=Age
AGEU=Age Units
SEX=Sex
RACE=Race
ARMCD=Planned Arm Code
ARM=Description of Planned Arm
ACTARMCD=Actual Arm Code
ACTARM=Description of Actual Arm
ARMNRS= Reason Arm and/or Actual Arm is Null	
ACTARMUD=Description of Unplanned Actual Arm
COUNTRY=Country
DMDTC=Date/Time of Collection;
merge dm2(in=a) cntry2(in=ab);
if a;
by siteid;
drop prot;
run;

/*xpt file conversion*/
libname xptf xport "C:\Documents\E2E assignment\xptf\dm.xpt";
data xptf.dm;
set sdtm.dm;
run;

