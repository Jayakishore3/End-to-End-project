data admh01;
set adams.admh(encoding='ISO-8859-1');
where saffl="Y";
run;
data adsl01;
set adams.adsl;
where saffl="Y";
run;

/*trt column */
data admh02;
set admh01;
treatment=trt01an;
output;
treatment=4;
output;
run;

data adsl02;
set adsl01;
treatment=trt01an;
output;
treatment=4;
output;
run;

/*Total value*/

proc sql;
create table actual_pre as select treatment,
count(distinct usubjid) as trttotal from adsl02
group by treatment;
quit;

/*dummy total*/

data dummy_pre;
do treatment=1 to 4;
output;end;
run;

/*merge*/

data trttotal;
merge dummy_pre(in=a) actual_pre(in=b);
by treatment;
if trttotal=. then trttotal=0;
run;

/*for percent N count*/

proc sql noprint;
select count(distinct usubjid) into :n1 from adsl02 where treatment=1;
select count(distinct usubjid) into :n2 from adsl02 where treatment=2;
select count(distinct usubjid) into :n3 from adsl02 where treatment=3;
select count(distinct usubjid) into :n4 from adsl02 where treatment=4;
quit;

/*no of patients*/

proc sql ;
create table sub_count as select "Number of patients with concomitant medications" as label length=200,
treatment,
count(distinct usubjid) as COUNT from admh02
group by treatment;
quit;

/*soc*/

proc sql noprint;
create table soc_count as 
select mhbodsys, treatment,
count(distinct usubjid) as COUNT 
from admh02
group by mhbodsys,treatment;
quit;

/*pt*/

proc sql noprint;
create table pt_count as 
select mhbodsys,mhdecod,treatment,
count(distinct usubjid) as count
from admh02
group by mhbodsys,mhdecod,treatment;
quit;

data counts1;
set sub_count soc_count pt_count;
run;
/*nodup*/

proc sort data=counts1 out=dummy01(keep=mhbodsys mhdecod label)nodupkey;
by mhbodsys mhdecod label;
run;

data dummy02;
set dummy01;
do treatment = 1 to 4;
output;
end;
run;

proc sort data=dummy02;
by mhbodsys mhdecod label treatment;
run;

/*merge original actual and original data values*/

proc sort data=counts1;
by mhbodsys mhdecod label treatment;
run;

data counts02;
merge dummy02(in=a) counts1(in=b);
by mhbodsys mhdecod label treatment ;
if count=. then count=0;
run;

/*merge dummy and actual*/

proc sort data=counts02;
by treatment;
run;

proc sort data=trttotal;
by treatment;
run;

data counts03;
merge counts02(in=a) trttotal(in=b);
by treatment;
if a;
run;
/*percentage*/

data counts04;
set counts03;
length cp $30;
cp=put(count,3.)||"("||put(count/trttotal*100,5.1)||")";
run;

*create label;
data counts05;
   set counts04;
   if missing(mhbodsys) and missing(mhdecod) then label=label;
   else if not missing(mhbodsys) and missing(mhdecod) then label=strip(mhbodsys);
   else if not missing(mhbodsys) and not missing(mhdecod) then label="		"||strip(mhdecod);
run;

/*transpose row values into variables*/
proc sort data=counts05;
   by mhbodsys mhdecod label ;
run;
 
proc transpose data=counts05 out=trans01 prefix=trt;
   by mhbodsys mhdecod label;
   var cp;
   id treatment;
run;
*report generation;
data _null_;
	call symput("date",put(date(),ddmmyy10.));
	call symput("time",put(time(),tod5.));
run;
ods rtf file="C:\Documents\E2E assignment\rtf\14_1_2_2.rtf";

proc report data=trans01 nowd  headline headskip missing 
	style(report)={cellpadding=1pt cellspacing=0pt just=c frame=above asis=on rules=groups}
	style(header)={font=('Courier New',8pt,normal) just=c asis=off background=white fontweight=bold borderbottomwidth=2 bordertopwidth=2}
	style(column)={font=('Courier New',8pt,normal) asis=on}
	style(lines) ={font=('Courier New',8pt,normal) asis=on} ;

   	columns mhbodsys mhdecod label  trt1 trt2 trt4 trt3;

   	define mhbodsys/ order noprint;
   	define mhdecod/order noprint;
   	define label /order " " style(column)=[cellwidth=49% protectspecialchars=off]
            		 style(header)=[just=left] ;
   	define trt1/"3 mg" "(N=%cmpres(&n1))" " n(%)" style(column)=[cellwidth=10% just=center] ;
   	define trt2/"10 mg" "(N=%cmpres(&n2))" " n(%)" style(column)=[cellwidth=10% just=center]   ;
   	define trt4/"Total cyt001" "(N=%cmpres(&n4))" " n(%)"  style(column)=[cellwidth=10% just=center]   ;
    define trt3/"Placebo" "(N=%cmpres(&n3))" " n(%)"  style(column)=[cellwidth=10% just=center]   ;

	compute after _page_ / left;
		line @1 "Note: For each SOC and preferred term, a patient is counted once if the patient reported one or more events in that category.";
		line @1 "Denominators for percentages are based on number of patients in Safety Population for each treatment group. SOC and PT are sorted in descending";
		line @1 "order of the Total Macitentan frequency count.";
		line @1 " ";
		line @1 "PROGRAM: T_14_1_2_2.sas 																								Executed: &date. &time.";
	endcomp;

   	compute before mhbodsys;
        line @1 "";
   	endcomp;

	title font='Courier New'  height=8pt "CYT001-302";
	title2 font='Courier New'  height=8pt "Table 14.1.2.2";
	title3 font='Courier New'  height=8pt "Summary of Medical History by SOC and PT";
	title4 font='Courier New'  height=8pt "Safety Population";
run;
 
ods rtf close;
