data adsl;
set adams.adsl;
if saffl="Y" and trt01pn ne .;
run;

data adsl01;
set adsl;output;
trt01pn=4;output;
run;
proc sort data=adsl01 out=adsl1; by trt01pn;run;

proc sql noprint;
select count(distinct usubjid) into :n1 from adsl1 where trt01pn=1;
select count(distinct usubjid) into :n2 from adsl1 where trt01pn=2;
select count(distinct usubjid) into :n3 from adsl1 where trt01pn=3;
select count(distinct usubjid) into :n4 from adsl1 where trt01pn=4;
quit;

/*age stats*/

proc summary data=adsl1;
by trt01pn;
var age;
output out=age1 n=_n mean=_mean std=_std median=_median min=_mn max=_max;
run;

data age2;
set age1;
n= put(_n,3.0);
meansd=put(_mean,4.1)|| '(' ||put(_std,4.2)|| ')';
median=put(_median,4.1);
minmax=put(_mn,best4.)|| "," ||put(_max,best4.);
drop _:;
run;

proc transpose data=age2 out=age3;
id trt01pn;
var n meansd median minmax;
run;

data age4;
set age3;
length newvar $80.;
if _name_="n" then newvar="n";
if _name_="meansd" then newvar="Mean (SD)";
if _name_="median" then newvar="Median";
if _name_="minmax" then newvar="Min, Max";
drop _name_;
run;

data dummy;
length newvar $80.;
newvar= "Age(years)";
run;

data age;
set dummy age4;
ord=1;
run;
/* Age Group statistics */
/*age n*/
proc sql noprint;
create table pt as select trt01pn,count(distinct usubjid) 
as count from adsl1 group by trt01pn;quit;

data pt1;
set pt;
n=put(count,best9.);
drop count;
run;
proc transpose data=pt1 out=pt2;
id trt01pn;
var n;
run;
data pt3;
length newvar $80.;
set pt2;
if _name_="n" then newvar="n";
drop _name_;
run;
data dummy2;
length newvar $80.;
newvar="Age Group (years), n (%)";
run;
/*age grp*/
data age_group;
length age_group $20.;
    set adsl1;
    if age < 18 then age_group = "<18";
    else if 18 <= age <= 64 then age_group = "18 - 64";
    else if age >= 65 then age_group = ">= 65";
run;

proc freq data=age_group noprint;
    tables age_group*trt01pn / out=age_group_freq missing;
run;
data agefr;
set age_group_freq;
np=put(count,3.0)||"("||put(percent,4.2)||")";
run;

proc transpose data=agefr out=agegr;
id trt01pn;
var np;
by age_group;
run;

data agegr1;
length newvar $80.;
set agegr;
if age_group="18 - 64" then newvar="18 - 64";
else if age_group=">= 65" then newvar=">= 65";
drop age_group _name_;
run;

data age_n;
set dummy2 pt3 agegr1;
ord=2;
run;

/**/
/*sex*/

proc freq data=adsl1 noprint;
by trt01pn;
table sex/out=sex1;
run;

data sex2;
set sex1;
np=put(count,3.0)||"("||put(percent,4.1)||")";
run;
proc sort data=sex2;by sex;run;
proc transpose data=sex2 out=sex3;
id trt01pn;
var np;
by sex;
run;
data sex4;
length newvar $80.;
set sex3;
if sex="F" then newvar="Female";
else if sex="M" then newvar="Male";
drop _name_ sex;
run;

data dummy3;
length newvar $80.;
newvar="Sex, n (%)";
run;

data sex;
set dummy3 pt3 sex4;
ord=3;
run;

/*race*/

proc freq data=adsl1 noprint;
by trt01pn;
table race/out=race1;
run;

data race2;
set race1;
np=put(count,3.0)||"("||put(percent,4.1)||")";
run;
proc sort data=race2;by race;run;
proc transpose data=race2 out=race3;
id trt01pn;
var np;
by race;
run;
data race4;
length newvar $80.;
set race3;
if race="WHITE" then newvar="White";
else if race="ASIAN" then newvar="Asian";
else if race="BLACK OR AFRICAN AMERICAN" then newvar="Other";
drop _name_ race;
run;

data dummy4;
length newvar $80.;
newvar="Race, n (%)";
run;

data race;
set dummy4 pt3 race4;
ord=4;
run;

/*height*/
data heightvs(rename=(aval=Height));
set adams.adbl;
where param="Baseline Height (cm), P01";
keep usubjid param aval;
run;
proc sort data=heightvs;by usubjid;run;
proc sort data=adsl1;by usubjid;run;
data adslh;
merge adsl1(in=a) heightvs(in=b);
by usubjid;
if a;
run;

proc sort data=adslh;by trt01pn;run;
proc summary data=adslh;
by trt01pn;
var height;
output out=height1 n=_n mean=_mean std=_std median=_median min=_mn max=_max;
run;

data height2;
set height1;
n= put(_n,3.0);
meansd=put(_mean,4.1)|| '(' ||put(_std,4.2)|| ')';
median=put(_median,4.1);
minmax=put(_mn,best4.)|| "," ||put(_max,best4.);
drop _:;
run;

proc transpose data=height2 out=height3;
id trt01pn;
var n meansd median minmax;
run;

data height4;
set height3;
length newvar $80.;
if _name_="n" then newvar="n";
if _name_="meansd" then newvar="Mean (SD)";
if _name_="median" then newvar="Median";
if _name_="minmax" then newvar="Min, Max";
drop _name_;
run;

data dummy5;
length newvar $80.;
newvar= "Height (cm)";
run;

data height;
set dummy5 height4;
ord=5;
run;


/*weight*/
data weightvs(rename=(aval=weight));
set adams.adbl;
where param="Baseline Weight (kg/m2), P01";
keep usubjid param aval;
run;
proc sort data=weightvs;by usubjid;run;
proc sort data=adsl1;by usubjid;run;
data adslw;
merge adsl1(in=a) weightvs(in=b);
by usubjid;
if a;
run;

proc sort data=adslw;by trt01pn;run;
proc summary data=adslw;
by trt01pn;
var weight;
output out=weight1 n=_n mean=_mean std=_std median=_median min=_mn max=_max;
run;

data weight2;
set weight1;
n= put(_n,3.0);
meansd=put(_mean,4.1)|| '(' ||put(_std,4.2)|| ')';
median=put(_median,4.1);
minmax=put(_mn,best4.)|| "," ||put(_max,best4.);
drop _:;
run;

proc transpose data=weight2 out=weight3;
id trt01pn;
var n meansd median minmax;
run;

data weight4;
set weight3;
length newvar $80.;
if _name_="n" then newvar="n";
if _name_="meansd" then newvar="Mean (SD)";
if _name_="median" then newvar="Median";
if _name_="minmax" then newvar="Min, Max";
drop _name_;
run;

data dummy6;
length newvar $80.;
newvar= "Weight (kg)";
run;

data weight;
set dummy6 weight4;
ord=6;
run;

/*bmi*/
data bmis;
set adams.adsl;
bmis=input(bmi,best4.);
run;
data bmis1(rename=(bmis=bmi));
set bmis;
drop bmi;
run;

data bmis12;
set bmis1;output;
trt01pn=4;output;
run;
proc sort data=bmis12 ;by trt01pn;run;
proc summary data=bmis12;
by trt01pn;
var bmi;
output out=bmi1 n=_n mean=_mean std=_std median=_median min=_mn max=_max;
run;

data bmi2;
set bmi1;
n= put(_n,3.0);
meansd=put(_mean,4.1)|| '(' ||put(_std,4.2)|| ')';
median=put(_median,4.1);
minmax=put(_mn,best4.)|| "," ||put(_max,best4.);
drop _:;
run;

proc transpose data=bmi2 out=bmi3;
id trt01pn;
var n meansd median minmax;
run;

data bmi4;
set bmi3;
length newvar $80.;
if _name_="n" then newvar="n";
if _name_="meansd" then newvar="Mean (SD)";
if _name_="median" then newvar="Median";
if _name_="minmax" then newvar="Min, Max";
drop _name_;
run;

data dummy7;
length newvar $80.;
newvar= "BMI (kg/m2)";
run;

data bmi;
set dummy7 bmi4;
ord=7;
run;

/*creactinine clearence*/


data creatvs(rename=(aval=creat));
set adams.adbl;
where param="Baseline Creat. Clearance (ml/min), P01";
keep usubjid param aval;
run;
proc sort data=creatvs;by usubjid;run;
proc sort data=adsl1;by usubjid;run;
data adslc;
merge adsl1(in=a) creatvs(in=b);
by usubjid;
if a;
run;

proc sort data=adslc;by trt01pn;run;
proc summary data=adslc;
by trt01pn;
var creat;
output out=creat1 n=_n mean=_mean std=_std median=_median min=_mn max=_max;
run;

data creat2;
set creat1;
n= put(_n,3.0);
meansd=put(_mean,4.1)|| '(' ||put(_std,4.2)|| ')';
median=put(_median,4.1);
minmax=put(_mn,best4.)|| "," ||put(_max,best4.);
drop _:;
run;

proc transpose data=creat2 out=creat3;
id trt01pn;
var n meansd median minmax;
run;

data creat4;
set creat3;
length newvar $80.;
if _name_="n" then newvar="n";
if _name_="meansd" then newvar="Mean (SD)";
if _name_="median" then newvar="Median";
if _name_="minmax" then newvar="Min, Max";
drop _name_;
run;

data dummy8;
length newvar $80.;
newvar= "Estimated Creatinine Clearance At Baseline, n (%))";
run;

data creat;
set dummy8 creat4;
ord=8;
run;


/*final dataset*/

data final;
set age age_n sex race height weight bmi creat;
run;

data _null_;
	call symput("date",put(date(),ddmmyy10.));
	call symput("time",put(time(),tod5.));
run;
/*report generation*/
proc printto log="C:\Documents\E2E assignment\log tlf\14_1_2_1.log" new;
ods listing close;
ods rtf file="C:\Documents\E2E assignment\rtf\14_1_2_1.rtf";

options nodate nonumber nocenter ;
proc report data=final nowd headline headskip split='*'
style(report)={cellpadding=1pt cellspacing=0pt just=c frame=above asis=on rules=groups} 
style(header)={font=('Courier New',6pt,normal) just=c asis=off background=white  borderbottomwidth=1 bordertopwidth=1}
style(column)={font=('Courier New',5pt,normal)just=c asis=on}
style(lines) ={font=('Courier New',5pt,normal) asis=on};

columns ord newvar _1 _2 _3 _4;
define ord/order noprint style(column)=[cellwidth=10% just=center] ;
break after ord/skip ;
define newvar/' ' style(column)=[cellwidth=20% protectspecialchars=off just=l]
            		 style(header)=[just=left] ;
define _1/"3 mg*(N=%cmpres(&n1))" style(column)=[cellwidth=10% just=center] ;
define _2/"10 mg*(N=%cmpres(&n2))" style(column)=[cellwidth=10% just=center] ;
define _3/"Total cyt001*(N=%cmpres(&n3))" style(column)=[cellwidth=10% just=center] ;
define _4/"Placebo*(N=%cmpres(&n4))" style(column)=[cellwidth=10% just=center] ;
compute before _page_ ;
line @58 "CYT001-302";
line @55 "Table 14.1.2.1";
line @35 "Summary of Demographic and Patient Characteristics";
line @52 "Safety Population";
line ' ';
endcomp;
compute after _page_;
line @1 "Note: Denominator for percentages based on number of non-missing observations for each treatment group and total";
line '';
line @1 "PROGRAM: 14_1_2_1.SAS                                                              Executed: &date. &time.";
endcomp;
run;


ods rtf close;
ods listing;
