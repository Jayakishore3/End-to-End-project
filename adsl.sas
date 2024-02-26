/*creation of adsl dataset*/

data dmt(drop=studyid usubjid subjid siteid ageu sex race arm country);
length STUDYID1 $15 USUBJID1 $30 SUBJID1 $20 SITEID1 $8 AGEU1 $15 SEX1 $1 RACE1 $50 ARM1 $100 COUNTRY1 $3;
set sdtm.dm;
studyid1=studyid;usubjid1=usubjid;subjid1=subjid;siteid1=siteid;ageu1=ageu;sex1=sex;race1=race;arm1=arm;country1=country;
run;
data dms (rename=(studyid1=studyid usubjid1=usubjid subjid1=subjid siteid1=siteid ageu1=ageu sex1=sex race1=race arm1=arm country1=country));
set dmt;
run;

proc sort data=dms out=dm1;
by usubjid;
run;

data dm;
length SITEGR1  $42 SITEGR1N 3.0 BRTHDTF  $1 AGE 8. AGE1 8. AGEGR1 $7 AGEGR1N  3.0 SEXN 3.0 RACEGR1 $5 RACEGR1N 3.0
TRT01P $17 TRT01PN  3.0 TRT01A   $17 TRT01AN 3.0 SAFFL $1 INDGR1  $22 INDGR1N 3.0 EXGR1 $15 EXGR1N 3.0 EXYR1 8.;
format tr01sdt tr01edt cutoffdt trtedt trtsdt fup01dt brthdt yymmdd10.;
set dm1;
if country in ('USA','CAN') then sitegr1n=1; 
else if country in ('AUT','BEL','DEU','DNK','ESP','FRA','GBR','ISR','ITA','NLD','NOR','SWE','ZAF') then sitegr1n=2;
else if country in ('BGR','BLR','HRV','HUN','POL','ROU','RUS','SCG','SRB','SVK','SVN','TUR','UKR') then sitegr1n=3;
else if country in ('AUS','CHN','HKG','IND','MYS','PHL','SGP','THA','TWN') then sitegr1n=4;
else if country in ('ARG','CHL','COL','MEX','PER') then sitegr1n=5;

if sitegr1n=1 then sitegr1="North America (including Canada)";
else if sitegr1n=2 then sitegr1="Western Europe (inc. S. Africa and Israel)";
else if sitegr1n=3 then sitegr1="Eastern Europe (inc. Turkey)";
else if sitegr1n=4 then sitegr1="Asia (including Australia)";
else if sitegr1n=5 then sitegr1="Latin America'";

if brthdtc ne "" then do;
if length(brthdtc)=4 then do;
brthdt1=brthdtc||"06-30";
brthdtf="M";end;
else if length(brthdtc)=7 then do;
brthdt1=brthdtc||"15";
brthdtf="D";end;
else brthdt1=brthdtc;
end;
if brthdt1 ne "" then brthdt=input(brthdt1,yymmdd10.);

if rfstdtc ne "" then trtsdt=input(rfstdtc,yymmdd10.);
age1=year(trtsdt)-year(brthdt) - ( (month(trtsdt)<month(brthdt)) or (month(trtsdt)=month(brthdt) & day(trtsdt) < day(brthdt)) );

if .<age1<18 then agegr1n=1;
else if 18<=age1<=64 then agegr1n=2;
else if age1>=65 then agegr1n=3;

if agegr1n=1 then agegr1="< 18";
else if agegr1n=2 then agegr1="18 - 64";
else if agegr1n=3 then agegr1=">=65";

if sex="M" then sexn=1;
else if sex="F" then sexn=2;

if race='White' then racegr1n=1;
else if race='Asian' then racegr1n=2;
else racegr1n=3;

if racegr1n=1 then racegr1="White";
else if racegr1n=2 then racegr1="Asian";
else if racegr1n=3 then racegr1="Other";

if arm ^="NOT ASSIGNED" then trt01p=propcase(arm);

if trt01p="Cyt001 3 mg" then trt01pn=1; 
else if trt01p="Cyt001 10 mg" then trt01pn=2;
else if trt01p="Placebo" then trt01pn=3;

if rfstdtc ne "" then tr01sdt=input(rfstdtc,yymmdd10.);
if tr01sdt>. then trt01a=trt01p;
else trt01a=" ";
if tr01sdt>. then trt01an=trt01pn;
else trt01an=.;

if ARM = 'PLACEBO' or index(ARM, 'CYT001') > 0 and not missing(TRTSDT) then saffl="Y";

if studyid in ('CYT001-302','CYT001-303')  then indgr1n=1;
else if studyid='CYT001B201' then indgr1n=2;
else if studyid='CYT001-201' then indgr1n=3;
if indgr1n=1 then indgr1="PAH";
else if indgr1n=2 then indgr1="IPF";
else if indgr1n=3 then indgr1="Essential Hypertension";

if rfendtc ne "" then tr01edt=input(rfendtc,yymmdd10.);
if not missing(tr01sdt) and not missing (tr01edt) then exdur1=(TR01EDT-TR01SDT+1)/30.4375;
if 0<=exdur1<6 then exgr1n=1;
else if 6<=exdur1<12 then exgr1n=2;
else if 12<=exdur1<18 then exgr1n=3;
else if 18<=exdur1<24 then exgr1n=4;
else if 24<=exdur1<30 then exgr1n=5;
else if exdur1>=30 then exgr1n=6;
if exgr1n=1 then exgr1='0 - <6 months';
if exgr1n=2 then exgr1='6 - <12 months';
if exgr1n=3 then exgr1='12 - <18 months';
if exgr1n=4 then exgr1='18 - <24 months';
if exgr1n=5 then exgr1='24 - <30 months';
if exgr1n=6 then exgr1='>=30 months';

if not missing(tr01sdt) and not missing (tr01edt) then  EXYR1=(TR01EDT-TR01SDT+1)/365;
trtedt=tr01edt;
fup01dt=tr01edt+28;
cutoffdt='26APR2012'd;
run;
data lbt(rename=(usubjid1=usubjid));
length usubjid1 $30;
set sdtm.lb;
usubjid1=usubjid;
drop usubjid;
run;
proc sort data=lbt out=lb1(keep= usubjid lbtest lbstresn lbdtc) nodupkey;
by usubjid;
where lbtest in ("Creatinine");
run;
data lab;
merge lb1(in=a) dm1(in=b);
by usubjid;
run;
data lab1(keep= usubjid blcc);
set lab;
if lbdtc<=rfxstdtc then do blcc=lbstresn;end;
run;
proc sort data=lab1;by usubjid;run;
data dmnew;
length CCGR1 $70 CCGR1N 3.0;
merge dm(in=a) lab1(in=b);
by usubjid;
if a;
if 90<=BLCC then ccgr1n=1;
else if 60<=BLCC<90 then ccgr1n=2;
else if .<BLCC<60 then ccgr1n=3;
if ccgr1n=1 then ccgr1='No renal impairment (creatinine clearance >= 90ml/min)';
else if ccgr1n=2 then ccgr1='Mild renal impairment (creatinine clearance 60ml/min to <90ml/min)';
else if ccgr1n=3 then ccgr1='Moderate | severe  renal impairment (creatinine clearance <60ml/min)';
run;

/**/
data cet(rename=(usubjid1=usubjid));
length usubjid1 $30;
set sdtm.ce;
usubjid1=usubjid;
drop usubjid;
run;
proc sort data=cet out=ce1(keep=studyid usubjid cecat cestdtc ceoccur)nodupkey;
by usubjid;
run;
data dmce;
merge dm(in=a) ce1(in=b);
by usubjid;
run;
data cev(keep=usubjid rhfblfl);
length RHFBLFL $1;
set dmce;
if studyid = 'CYT001-302' then do;
if cecat = 'CLINICAL SIGNS AND SYMPTOMS OF RIGHT HEART FAILURE' and
ceoccur = 'Y' and (input(cestdtc,yymmdd10.) <= tr01sdt) then do;
rhfblfl = "Y";end;
else do rhfblfl="N";
end;end;
run;
proc sort data=cev;by usubjid;run;
data dm2;
merge dmnew(in=a) cev(in=b);
by usubjid;
if a;
run;

data qs1(rename=(usubjid1=usubjid studyid1=studyid));
length usubjid1 $30. studyid1 $15;
set sdtm.qs;
usubjid1=usubjid;
studyid1=studyid;
where QSCAT='WHO FUNCTIONAL CLASS';
drop usubjid studyid;
run;
proc sort data=qs1 nodupkey;by usubjid;run;
data dm3;
length WHOFCBL  $6;
merge dm2(in=a) qs1(in=b);
by usubjid;
if a;
if(not missing(tr01sdt) and not missing(qsdtc)) and tr01sdt>=input(qsdtc,yymmdd10.) then whofcbl=strip(qsstresc);
run;

data supp;
set sdtm.suppmh;
where qnam in ('MH_CVD','MH_PLS','IPAH','FPAH','MH_HIV','MH_DRU');
run;
proc sort data=supp nodupkey;by usubjid;run;
data dm4;
length PAHETI $25;
merge dm3(in=a) supp(in=b);
by usubjid;
if a;
if qnam="MH_CVD" and qval='Yes' then do PAHETI='Collagen vascular disease';end;
if qnam="MH_PLS" and qval='Yes' then do PAHETI='Congenital shunts';end;
if qnam="IPAH" and qval='Yes' or qnam="FPAH" and qval='Yes' or qnam="MH_HIV" and qval='Yes' or qnam="MH_DRU" and qval='Yes' then do PAHETI='Idiopathic/Other'; end;
run;
data dst(rename=(usubjid1=usubjid));
length usubjid1 $30;
set sdtm.ds;
usubjid1=usubjid;
drop usubjid;
run;

proc sort data=dst out=ds1 nodupkey;by usubjid;run;
data dm5;
format randdt yymmdd10.;
merge dm4(in=a) ds1(in=b);
by usubjid;
if a;
if dsdecod="RANDOMIZED" then randdt=input(dsstdtc,yymmdd10.);
run;
/**/
data aet(rename=(usubjid1=usubjid studyid1=studyid domain1=domain));
length usubjid1 $30 studyid1 $10 domain1 $2;
set sdtm.ae;
usubjid1=usubjid;
studyid1=studyid;
domain1=domain;
drop studyid usubjid domain;
run; 
data combined_data;
format deathdt yymmdd10.;
  set dst; set cet; set aet;
  if not missing(DSSTDTC) and (index(upcase(DSDECOD), 'DEATH') or index(upcase(DSTERM), 'DEATH')) then do;
    deathdt = min(input(DSSTDTC,yymmdd10.),deathdt);end;
  if not missing(CESTDTC) and CECAT = 'DISPOSITION CAUSE OF DEATH' then do;
    deathdt = min(input(CESTDTC,yymmdd10.),deathdt);end; 
  if not missing(AEENDTC) and (AEOUT = 'FATAL' or index(upcase(AETERM), 'DEATH')  or index(upcase(AEDECOD), 'DEATH')) then do;
    deathdt = min(input(AEENDTC, yymmdd10.), deathdt);end;
run;
proc sort data=combined_data out=cd nodupkey;by usubjid;run;
data dm6;
merge dm5(in=a) cd(in=b);
by usubjid;
if a;
run;
proc sort data=sdtm.ex out=ex nodupkey;by usubjid;run;
data dm7;
merge dm6(in=a) ex(in=b);
by usubjid;
if a;
if last.usubjid then etst01dt=exendtc;
run;

proc sort data=dst out=ds1;by usubjid;run;
data dm8;
length DSDECOD1 $200 DSTERM1 $200;
merge dm7(in=a) ds1(in=b);
by usubjid;
if a;
if DSCAT="DISPOSITION EVENT" and DSSCAT="END OF STUDY" then do;
DSST01DT = dsstdtc;
DSTERM1=DSTERM;
DSDECOD1=DSDECOD;end;
run;

libname adam "C:\Documents\E2E assignment\ADaM created datasets";

data adam.adsl(keep=STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N COUNTRY BRTHDT BRTHDTF AGE AGEU AGE1 AGEGR1 AGEGR1N SEX SEXN RACE RACEGR1 RACEGR1N 
ARM TRT01P TRT01PN TRT01A TRT01AN SAFFL INDGR1 INDGR1N EXGR1 EXGR1N EXYR1 CCGR1 CCGR1N RHFBLFL WHOFCBL PAHETI RANDDT TRTSDT TRTEDT TR01SDT 
TR01EDT FUP01DT DEATHDT ETST01DT DSDECOD1 DSTERM1 DSST01DT CUTOFFDT) ;
retain STUDYID USUBJID SUBJID SITEID SITEGR1 SITEGR1N COUNTRY BRTHDT BRTHDTF AGE AGEU AGE1 AGEGR1 AGEGR1N SEX SEXN RACE RACEGR1 RACEGR1N 
ARM TRT01P TRT01PN TRT01A TRT01AN SAFFL INDGR1 INDGR1N EXGR1 EXGR1N EXYR1 CCGR1 CCGR1N RHFBLFL WHOFCBL PAHETI RANDDT TRTSDT TRTEDT TR01SDT 
TR01EDT FUP01DT DEATHDT ETST01DT DSDECOD1 DSTERM1 DSST01DT CUTOFFDT;
set dm8;
length STUDYID  $15 USUBJID  $30 SUBJID   $20 SITEID   $8 SITEGR1  $42 SITEGR1N 3.0 COUNTRY  $3 BRTHDTF  $1 AGE 8. AGEU $15
AGE1 8. AGEGR1 $7 AGEGR1N  3.0 SEX $1 SEXN 3.0 RACE $50 RACEGR1 $5 RACEGR1N 3.0 ARM $100 TRT01P $17 TRT01PN  3.0 TRT01A   $17 TRT01AN  3.0
SAFFL $1 INDGR1  $22 INDGR1N 3.0 EXGR1 $15 EXGR1N 3.0 EXYR1 8. CCGR1 $70 CCGR1N 3.0 RHFBLFL $1 WHOFCBL  $6 PAHETI $25 DSDECOD1 $200 DSTERM1 $200;
label 
      STUDYID = "Study Identifier"
      USUBJID = "Unique Subject Identifier"
      SUBJID = "Subject Identifier for the Study"
      SITEID = "Study Site Identifier"
      SITEGR1 = "Site Group 1"
      SITEGR1N = "Site Group 1 (N)"
      COUNTRY = "Country"
      BRTHDT = "Date of Birth (N)"
      BRTHDTF = "Date of Birth Imput. Flag"
      AGE = "Age"
      AGEU = "Age Units"
      AGE1 = "Age (YEARS), P01"
      AGEGR1 = "Age Group 1"
      AGEGR1N = "Age Group 1 (N)"
      SEX = "Sex"
      SEXN = "Sex (N)"
      RACE = "Race"
      RACEGR1 = "Race Group 1"
      RACEGR1N = "Race Group 1 (N)"
      ARM = "Description of Planned Arm"
      TRT01P = "Planned Treatment for Period 01"
      TRT01PN = "Planned Treatment for Period 01 (N)"
      TRT01A = "Actual Treatment for Period 01"
      TRT01AN = "Actual Treatment for Period 01 (N)"
      SAFFL = "Safety Population Flag"
      INDGR1 = "Indication Groups 1"
      INDGR1N = "Indication Groups 1 (N)"
      EXGR1 = "Exposure Group 1"
      EXGR1N = "Exposure Group 1 (N)"
      EXYR1 = "Exposure (Years), P01"
      CCGR1 = "Baseline Creat. Clear. Group 1, P01"
      CCGR1N = "Baseline Creat. Clear. Group 1, P01 (N)"
      RHFBLFL = "RHF at Baseline Flag"
      WHOFCBL = "WHO FC at Baseline"
      PAHETI = "PAH etiology at baseline"
      RANDDT = "Date of Randomization"
      TRTSDT = "Date of First Exposure to Treatment"
      TRTEDT = "Date of Last Exposure to Treatment"
      TR01SDT = "Date of First Exposure in Period 01"
      TR01EDT = "Date of Last Exposure in Period 01"
      FUP01DT = "Date of Follow-up in Period 01"
	  DEATHDT = "Date of Death"
      ETST01DT = "Date of End of Treatment, P01"
      DSDECOD1 = "Standardized Disposition Term, P01"
      DSTERM1 = "Reported Term for Disposition Event, P01"
      DSST01DT = "Start Date of Disposition Event, P01"
      CUTOFFDT = "Cut-off Date";
	  run;

libname xptf xport "C:\Documents\E2E assignment\xptf\adsl.xpt";
data xptf.adsl;
set adam.adsl;
run;
