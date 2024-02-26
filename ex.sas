
options validvarname=upcase;

/*creation of variables with source dra*/
data ex1;
length studyid $17 domain $2 usubjid $24;
set end.dra;
studyid="CYT001-302";
domain="EX";
usubjid=catx("-",prot,batch,pno);
run;

proc sort data=ex1 out=ex2;by usubjid;run;

data ex3;
length exseq 8 exrefid $6 exadj $28 ;
set ex2;
retain exseq 0;
by usubjid;
if first.usubjid then exseq=1;
else do exseq=exseq+1;end;
exrefid=put(pno,best6.);
exadj=da_reap1;
exstdtc=put(input(da_date,anydtdte.), yymmdd10.);
exendtc=put(input(da_end,anydtdte.),yymmdd10.);
keep studyid domain usubjid exseq exrefid exadj exstdtc exendtc;
run;

proc sort data=ex3 out=ex4;by usubjid;run;

/*creation of variables with source dem*/
data dm1;
length usubjid $24 extrt $28 exdose $3 exdosu $2 exdosfrm $9 exdosfrq $4 exroute $11;
set end.dem;
usubjid=catx("-",prot,batch,pno);
extrt=anagrpc;
exdose=scan(anagrpc,2," |");
exdosu="mg";
exdosfrm="Tablet";
exdosfrq="QD";
exroute="ORAL";
rfstdtc=put(input(starttrd,anydtdte.),yymmdd10.);
keep usubjid extrt exdose exdosu exdosfrm exdosfrq exroute rfstdtc;
run;

proc sort data=dm1 out=dm2;by usubjid;run;


/*merging the datasets and creating ex dataset*/
libname sdtm "C:\Documents\E2E assignment\SDTM created datasets";

data sdtm.ex;
length exstdy 8 exendy 8;
retain STUDYID DOMAIN USUBJID EXSEQ EXREFID EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXADJ EXSTDTC EXENDTC EXSTDY EXENDY;
merge ex4(in=a) dm2(in=b);
if a and b;
by usubjid;
if (EXSTDTC ne "" and RFSTDTC ne "") and input(EXSTDTC, yymmdd10.) >= input(RFSTDTC, yymmdd10.) then EXSTDY = input(EXSTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + 1;
else if (EXSTDTC ne "" and RFSTDTC ne "") and input(EXSTDTC, yymmdd10.) < input(RFSTDTC, yymmdd10.) then EXSTDY = input(EXSTDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.);
if (EXENDTC ne "" and RFSTDTC ne "") and input(EXENDTC, yymmdd10.) >= input(RFSTDTC, yymmdd10.) then EXENDY = input(EXENDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.) + 1;
else if (EXENDTC ne "" and RFSTDTC ne "") and input(EXENDTC, yymmdd10.) < input(RFSTDTC, yymmdd10.) then EXENDY = input(EXENDTC, yymmdd10.) - input(RFSTDTC, yymmdd10.);
keep STUDYID DOMAIN USUBJID EXSEQ EXREFID EXTRT EXDOSE EXDOSU EXDOSFRM EXDOSFRQ EXROUTE EXADJ EXSTDTC EXENDTC EXSTDY EXENDY;
run;


/*creating xpt file*/
libname xptf xport "C:\Documents\E2E assignment\xptf\ex.xpt";

data xptf.ex;
set sdtm.ex;
run;
