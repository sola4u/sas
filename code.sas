options mstored sasmstore = reporter;
options papersize = a4 orientation = landscape;
libname reporter 'E:\2017\死因监测\总结\';

%let dir = E:\2017\死因监测\总结\;
%let base = 11.csv; *大疫情死因系统导出死因数据;
%let ppl = population.xlsx; *大疫情系统基本信息系统导出人口数据;
%let icd = icd-10.xlsx;*icd-10分类表;
%let icdclass = code.xlsx;*三大类分类表;
%let table1 = table_ttl.csv;*大疫情系统导出死因报表卫统29-2报表合计及分性别;
%let table2 = table_male.csv;*;
%let table3 = table_female.csv;
%let rslt = rslt.rtf; *结果保存;

%let basefile = &dir&base; *11.csv文件路径;
%let pplfile = &dir&ppl;*人口文件路径;
%let icdfile = &dir&icd;*icd文件路径;
%let codefile = &dir&icdclass;*icd分类文件路径;
%let rsltfile = &dir&rslt;*结果保存路径;
%let table_ttl = &dir&table1;*卫统29-2合计及分男女文件路径;
%let table_male = &dir&table2;
%let table_female = &dir&table3;

*==============================================;
*-----------------生成死亡信息表----------------;
*==============================================;

proc import datafile="&basefile" out= work.base dbms=csv replace;
run;

data reporter.base;
    set work.base(keep = var6 var8 var11 var12 var14 
            var16 var18 var20 var22 var23 var32 var34
            var56 var57 var59 var61 var64 var66);
    rename var6 = name                       /*死者姓名*/
        var8 = gender                        /*性别*/
        var11 = day_of_birth                 /*出生日期*/
        var12 = age                          /*年龄*/
        var14 = race                         /*民族*/
        var16 = marriage                     /*婚姻状况*/
        var18 = occup                        /*个人身份*/
        var20 = edu                          /*文化程度*/
        var22 = location                     /*生前详细地址*/
     	var23 = locid                        /*常住地址地区编码*/
        var32 = day_of_death                 /*死亡时间*/
        var34 = location_of_death            /*死亡地点*/
        var56 = cause_of_death               /*根本死因*/
        var57 = icd10                        /*根本死因ICD编码*/
        var59 = hospital_of_diagnosis        /*最好诊断单位*/
        var61 = diagnosis                    /*最高诊断依据*/
        var64 = report_date                  /*医生填卡日期*/
        var66 = reporter;                    /*填报单位名称*/
run;

*==============================================;
*------------------生成人口表-----------------;
*==============================================;

proc import datafile = "&pplfile" out = reporter.raw_ppl dbms = excel replace;
    getnames = yes;
run;

*==============================================;
*------------------生成标化人口表---------------;
*==============================================;

data reporter.stdppl;
    input grp  std_male std_female std_ttl;
    cards;
0   1.43    1.27    1.36 
1   1.61    1.39    1.50 
5   1.24    1.03    1.14 
10  1.78    1.50    1.64 
15  1.74    1.51    1.62 
20  1.77    1.70    1.73 
25  1.72    1.47    1.59 
30  1.39    1.36    1.38 
35  1.15    1.12    1.14 
40  0.75    0.78    0.76 
45  0.47    0.50    0.48 
50  1.02    1.17    1.09 
55  0.65    0.72    0.68 
60  0.70    0.81    0.75 
65  0.89    1.02    0.95 
70  0.73    0.78    0.76 
75  0.65    0.69    0.67 
80  0.66    0.79    0.72 
85  0.82    0.90    0.87 
;
run;

*==============================================;
*-----------------生成ICD10表-------------------;
*==============================================;

proc import datafile = "&icdfile" out = reporter.icd dbms = excel replace;
    getnames = yes;
run;

*==============================================;
*-----------------生成ICD10分类表---------------;
*==============================================;

proc import datafile = "&codefile" out = reporter.icdcode dbms = excel replace;
    getnames = yes;
run;

*==============================================;
*-------------------死因统计数据处理------------;
*==============================================;

data reporter.base2;
    set reporter.base;
        *按照常住地址提取下一级行政区，本例中是乡镇级;
/*        if index(location,"镇") > 0  then*/
/*            town = substr(location, index(location, '区')+2, index(location,"镇")-index(location, '区'));*/
/*        if index(location,"乡") > 0  then*/
/*            town = substr(location, index(location, '区')+2, index(location,"乡")-index(location, '区'));*/
/*        if index(location,"镇")+index(location,"乡") = 0 then town = "不详乡镇";*/
/*        if town = "不详乡" then town = "不详乡镇";*/
/*        rename  reporter = hospital;*/
/*        drop location ;*/
    age2 = input(scan(age,1,"岁"),3.);
        if _error_ = 1 then age2 = 0;   
    *age2=intck('year',birth_of_death,birth_of_death); /*系统计算年龄与SAS函数有部分差别，使用系统计算年龄*/
    if age2 = 0 then grp1 = 0;
    	else if age2 < 15 then grp1 = 10;
        else if age2 < 20 then grp1 = 15;
        else if age2 < 25 then grp1 = 20;
        else if age2 < 30 then grp1 = 25;
        else if age2 < 35 then grp1 = 30;
        else if age2 < 40 then grp1 = 35;
        else if age2 < 45 then grp1 = 40;
        else if age2 < 50 then grp1 = 45;
        else if age2 < 55 then grp1 = 50;
        else if age2 < 60 then grp1 = 55;
        else if age2 < 65 then grp1 = 60;
        else if age2 < 70 then grp1 = 65;
        else if age2 < 75 then grp1 = 70;
        else if age2 < 80 then grp1 = 75;
        else if age2 < 85 then grp1 = 80;
        else if age2 ge 85 then grp1= 85;
    else grp1 = .;

    if age2 < 15 then grp2 =  0;
        else if age2 < 35 then grp2 = 15;
        else if age2 < 60 then grp2 = 35;
        else if age2 ge 60 then grp2 = 60;
    else grp2 = .;
run;

*==============================================;
*------------------- 乡镇编码  -----------------;
*==============================================;

data reporter.code;
	input locid town $20.;
	cards;
34100302	汤口镇
34100303	谭家桥镇
34100304	三口镇
34100305	仙源镇
34100306	新明乡
34100307	龙门乡
34100308	耿城镇
34100309	甘棠镇
34100310	焦村镇
34100315	乌石镇
34100316	太平湖镇
34100318	永丰乡
34100319	新华乡
34100320	新丰乡
34100321	黄山风景区
34100399	不详乡镇
;
run;

*==============================================;
*-----  根据乡镇编码生成病例乡镇名    -----------;
*==============================================;

proc sql noprint;
	create table reporter.basefinal as
		select a.*,b.town from reporter.base2 as a, reporter.code as b where a.locid = b.locid;
quit;

*==============================================;
*---------------------人口分组-------------------;
*==============================================;

data reporter.ppl2;
    set reporter.raw_ppl ;
        retain male2 female2;
        ttl = male + female;
        if _n_ in (1,2,6) or _n_ ge 11 then male2 = 0;  
            male2 + male;
        if _n_ in (1,2,6) or _n_ ge 11 then female2 = 0;    
            female2 + female;
        if _n_ in (1,2,6) or _n_ ge 11 then ttl2 = 0;   
            ttl2 + ttl;
        obs = _n_;
        if obs in (1,5) or obs ge 10;
        drop obs male female ttl;
        rename male2 = male female2 = female ttl2 = ttl;
        if group = 4 then group = 1;
        if group = 9 then group = 5;            
run;

data reporter.ppl;
    set reporter.ppl2;
        *low = input(compress(group,'-'),2.);
        low = group;
        if low = 0 then up = 1;
            else if low = 1 then up = 5;
            else if low = 85 then up = 155;
            else up = low + 5;
run;


data reporter.raw_ppl4grp;
    set reporter.ppl;
        retain male2 female2;
            if low in (0,15,35,60) then do;
                male2 = 0;
                female2 = 0;
            end;
            male2 + male;
            female2 + female;
    if low in (10,30,55,85);
    drop male female;
    rename male2 = male female2 = female;
    ttl = male + female;
    select(group);
        when(10) group = 0;
        when(30) group = 15;
        when(55) group = 35;
        when(85) group = 60;
        otherwise  group = '-';
    end;
run;

*==============================================;
*-------------------死因统计表整理--------------;
*==============================================;

proc sql;
    create table reporter.basefinally as
    select a.*, b.* from reporter.basefinal as a, reporter.icdcode as b
        where scan(a.icd10,1,'.') = b.icd;
quit;

*==============================================;
*------------分性别分年龄组死亡统计-------------;
*==============================================;


data work.test;
    set reporter.basefinal(keep = gender grp1 grp2);
run;
proc sort data = work.test out = work.test2;
    by gender;
run;

proc freq data = work.test2 noprint;
    by gender;
    tables grp1/ out= work.test3;   
run;

proc transpose data = work.test3 out = work.test4 prefix = grp;
    by gender;
    id grp1;
run;


data work.test5;    
    set work.test4;
        by gender;
    if first.gender;
    drop _name_ _label_;
run;

proc  transpose data = work.test5 out = work.test6;
run;
data reporter.death_count;
    set work.test6;
    grp = input(substr(_name_,4,3),2.);
    rename col1 = male_death;
    rename col2 = female_death;
    ttl_death = sum(col1,col2);
    drop _name_;
run;

/*proc datasets lib = work;*/
/*  delete test:;*/
/*quit;*/

*==============================================;
*---------------生成分年龄组死亡数表格----------;
*==============================================;

data work.test1;
    set reporter.death_count;
    *grp1 =input(compress(grp,'_'),2.);
    grp1 = grp;
run;

data work.test2;
    set reporter.ppl2;
    *grp1 = input(compress(group, '-'),2.);
    grp1 = group;
    ttl = sum(male, female);
run;
proc sort data = work.test1;
    by grp1;
run;
proc sort data = work.test2;
    by grp1;
run;

data test3;
    merge test1 test2;
    by grp1;
run;

data reporter.ex2;
    set work.test3(keep = group male female ttl male_death female_death ttl_death);
run;

/*proc datasets lib = work noprint;*/
/*  delete test1-test3;*/
/*run;*/

*========================================================;
*--------总人口（&ttl &male &female）、死亡人口(&ttl_death
&male_death &female_death)、婴儿死亡率(&infant_death_rate)
全局宏变量计算-------------------------------------------;
*========================================================;

proc sql noprint;
    select sum(ttl), sum(male), sum(female) into:ttl, :male, :female from reporter.ppl2;
    select ttl_death/ttl into: infant_death_rate from reporter.ex2;
    select sum(ttl_death), sum(male_death), sum(female_death) into:ttl_death, :male_death, 
                :female_death from reporter.death_count;
quit;

*==============================================;
*-------------------期望寿命计算宏--------------;
*==============================================;

%macro ex(dx, px)/store;
    data work.test1;
        set reporter.ex2(keep =  group &dx &px);
        *grp = input(compress(group,'-'),2.);
        grp = group;
        if &dx = . then &dx = 0;
        if &px = . then &px = 0;
    run;

    data work.test2;
        set work.test1;
        if grp=0 then n=1;
        else if grp=1 then n=4;
        else n=5;
    mx=round(&dx/&px,0.00001);
    qx=round(2*n*mx/(2+n*mx),0.000001);
    if grp=0 then do;
        mx=.;
        qx=round(&dx/&px,0.000001);
    end;
    if grp=85 then qx=1;
    retain lx 10000 ddx 0;
        lx=round(lx-ddx,1);
        ddx=round(lx*qx,1);
    run;

    proc sort data= work.test2;
        by desending grp;
    run;

    data work.test3;
        set work.test2;
        if &infant_death_rate < 0.02 then a0 = 0.09;
            else if &infant_death_rate < 0.04 then a0 = 0.15;
            else if &infant_death_rate < 0.06 then a0 = 0.23;
        else a0 = 0.30;
        retain a 0 b 0 llx tx 0 ex 0;
        if grp=85 then llx=round(lx/mx,1);
        else if grp=0 then llx=round(a+a0*ddx,1);
        else llx=round(n*(lx+a)/2,1);
        a=lx;
        tx=llx+b;
        b=tx;
        ex_&px=round(tx/lx,0.01);
    run;

    proc sort data=work.test3;
        by grp;
    run;

    data reporter.test&px;
        set work.test3(keep = group grp &dx &px ex_&px);
            rate&px = round(&dx/&&&px*100000,0.01);
    run;

/*  proc datasets lib = work noprint;*/
/*      delete test:;*/
/*  quit;*/
%mend ex;

%ex(male_death, male);
%ex(female_death, female);
%ex(ttl_death, ttl);

*合并期望寿命表格;

data reporter.exfinal;
    merge reporter.testmale reporter.testfemale reporter.testttl;
        by grp;
run;


/*proc datasets lib = reporter noprint;*/
/*  delete test:;*/
/*quit;*/

*==============================================;
*-----------------三大类标化死亡率--------------;
*==============================================;

proc sort data = reporter.basefinally out = work.test1;
    by gender grp1 grp2;
run;

proc freq data = work.test1 noprint;
    table code1*grp1/nocol norow nopercent out = work.code1;
    table code2*grp2/nocol norow nopercent out = work.code2;
    *table code3*grp2/nocol norow nopercent out = work.code3;
    table code1*grp2/nocol norow nopercent out = work.code4;
run;

proc freq data = work.test1 noprint;
    by gender;
    table code1*grp1/nocol norow nopercent out = work.gcode1;
    table code2*grp2/nocol norow nopercent out = work.gcode2;
    *table code3*grp2/nocol norow nopercent out = work.gcode3;
    table code1*grp2/nocol norow nopercent out = work.gcode4;
run;

*--------------三大类死因分男女、合计死亡表合并宏--------------;
%macro datamerge(database)/store;
    data work.ttl1;;
        set work.&database;
        length gender $6.;
        gender = 'ttl';
    run;

    data work.ttl2;
        format gender $6.;
        set work.g&database;
            if gender = '男' then gender = 'male';
            else if gender = '女' then gender = 'female';
            else gender = '';
    run;

    data work.ttl;
        set work.ttl1 work.ttl2;
    run;
%mend;

*--------------三大类死因分标化率计算宏--------------;

%datamerge(code1)

%macro tripleclass(sex)/store;

    proc sort data = work.ttl(where = (gender = "&sex")) out = work.sorted_code1;
        by code1 grp1;
    run;

    proc transpose data = work.sorted_code1(drop = percent gender) 
            out = raw_code1(drop = _name_ _label_ ) prefix = grp;
        by code1;
        id grp1;
    run;

    proc transpose data = reporter.stdppl(keep = grp std_&sex) 
            out = work.std_ppl(drop = _name_) prefix = stdppl;
        id grp;
    run;


    data work.code1_&sex._rslt;
        set work.raw_code1;
        if _n_ = 1 then set work.std_ppl;
        array grp(*) grp0 grp1 grp5 grp10 grp15 grp20 grp25 grp30 grp35 grp40 grp45 grp50 grp55
                     grp60 grp65 grp70 grp75 grp80 grp85;
        array stdppl(*) stdppl0 stdppl1 stdppl5 stdppl10 stdppl15 stdppl20 stdppl25 
                        stdppl30 stdppl35 stdppl40 stdppl45 stdppl50 stdppl55 stdppl60 
                        stdppl65 stdppl70 stdppl75 stdppl80 stdppl85;
        array rate(19) rate1-rate19;
        do i = 1 to dim(grp);
            if grp(i) = . then grp(i) = 0;
            rate(i) = grp(i)*stdppl(i)/&&&sex*100000;
        end;
        sum_&sex._death = sum(of grp:);                                              *三大类疾病死亡人数;
		sum_&sex._ratio = round(sum_&sex._death/&&&sex._death*100,0.01);            *三大类疾病死亡构成比;
        sum_&sex._rate = round(sum_&sex._death/&&&sex*100000, 0.01);                *三大类疾病死亡率;
        sum_&sex._adjrate = round(sum(of rate:),0.01);                               *三大类疾病标化死亡率;
        keep code1 sum_:;
    run;

%mend;

%tripleclass(ttl)
%tripleclass(male)
%tripleclass(female)

data reporter.triple_class;
        merge work.code1_ttl_rslt work.code1_male_rslt work.code1_female_rslt;
run;

/*proc datasets lib = work noprint;*/
/*      delete code1 code1: gcode1 raw_code1 sorted_code1 t:;*/
/*quit;*/

*--------------三大类分年龄组死亡率计算宏-------------;

%datamerge(code4)

%macro ttl(code, sex)/store;
    proc sort data = work.ttl( where =(gender = "&sex") ) out = work.sorted_code;
        by &code grp2;
    run;

    proc transpose data = work.sorted_code(drop = gender percent) out = raw_code(drop = _name_ _label_) prefix = grp&sex;
        by &code;
        id grp2;
    run;

    proc transpose data = reporter.raw_ppl4grp(keep = group &sex) out = work.ppl prefix = ppl&sex;
        id group;
    run;


    data work.rslt_&sex;
        set work.raw_code;
            if _n_ = 1 then set work.ppl;
        array grp(*) grp&sex.0  grp&sex.15 grp&sex.35 grp&sex.60;
        array ppl(*) ppl&sex.0 ppl&sex.15 ppl&sex.35 ppl&sex.60;
        array rate(*) rate&sex._0 rate&sex._15 rate&sex._35 rate&sex._60;
        do i = 1 to dim(grp);
            if grp(i) = . then grp(i) = 0;
            rate(i) = round(grp(i)/ppl(i)*100000, 0.01);
        end;
        drop ppl: i _name_;
    run;
%mend;

%ttl(code1, ttl)
%ttl(code1,male)
%ttl(code1,female)

data reporter.triple_class_group;
        merge work.rslt_:;
run;

/*proc datasets lib = work noprint;*/
/*      delete ttl: rslt: sorted_code raw_code;*/
/*quit;*/
*-------------分年龄组分类死因统计-------------;

%datamerge(code2)
%ttl(code2, ttl)
%ttl(code2,male)
%ttl(code2,female)

data reporter.shunwei_ttl;
    set work.rslt_ttl;
run;
data reporter.shunwei_male;
    set work.rslt_male;
run;
data reporter.shunwei_female;
    set work.rslt_female;
run;
/*proc datasets lib = work noprint;*/
/*      delete ttl: rslt: sorted_code raw_code;*/
/*quit;*/

*-------------死因顺位-------------;

%macro shunwei(sex);
    data work.test;
        set reporter.shunwei_&sex(keep = code2 grp:);
        ttl&sex = sum(of grp:);
        drop grp:;
    run;
    data work.testa work.testb;
        set work.test;
        if code2 = '其他疾病' then output work.testa;
        else output work.testb;
    run;

    proc sort data = work.testb out = work.test2;
        by descending ttl&sex;
    run;
    data work.testc;
        set work.test2;
        shunwei&sex = _n_;
    run;
    data work.testd;
        set work.testa;
        shunwei&sex = 17;               *手动设置===>其他疾病<====死因顺位为最大位，以保证其排序一直为最后一位，16为本次分析最大值，嫌麻烦不用代码了;
    data work.test_&sex;
        set work.testc work.testd;
    run;
%mend;

%shunwei(male)
%shunwei(female)
%shunwei(ttl)

%macro sortdata(sex);
    proc sort data = work.test_&sex out = work.shunwei_&sex;
        by code2;
    run;
%mend;

%sortdata(ttl)
%sortdata(male)
%sortdata(female)

data sum_shunwei;
    merge work.shunwei:;
        by code2;
        rate_ttl = round(ttlttl/&ttl*100000, 0.01);
        ratio_ttl = round(ttlttl/&ttl_death*100, 0.01);
        rate_male = round(ttlmale/&male*100000, 0.01);
        ratio_male = round(ttlmale/&male_death*100, 0.01);
        rate_female = round(ttlfemale/&female*100000, 0.01);
        ratio_female = round(ttlfemale/&female_death*100, 0.01);
run;

proc sort data = sum_shunwei out = reporter.shunwei;
    by shunweittl;
run;

/*proc datasets lib = work noprint;*/
/*      delete s: t:;*/
/*quit;*/

*==============================================;
*----------生成103类死因分类详细表     ---------;
*==============================================;

proc import datafile="&table_ttl" out= work.table_ttl dbms=csv replace;
run;
proc import datafile="&table_male" out= work.table_male dbms=csv replace;
run;
proc import datafile="&table_female" out= work.table_female dbms=csv replace;
run;


%macro table(ppl)/store;

    proc transpose data = reporter.stdppl(keep = grp std_&ppl) out = work.std_ppl(drop = _name_) prefix = stdppl;
        id grp;
    run;


    data work.test&ppl;
        set work.table_&ppl;
        if _n_ = 1 then set work.std_ppl;
        array grp(*) g0 g1 g5 g10 g15 g20 g25 g30 g35 g40 g45 g50 g55 g60 g65 g70 g75 g80 g85;
        array stdppl(*) stdppl0 stdppl1 stdppl5 stdppl10 stdppl15 stdppl20 stdppl25 stdppl30 stdppl35 
                        stdppl40 stdppl45 stdppl50 stdppl55 stdppl60 stdppl65 stdppl70 stdppl75 
                        stdppl80 stdppl85;
        array rate(19) rate1-rate19;
        do i = 1 to dim(grp);
            rate(i) = grp(i)*stdppl(i)/&&&ppl*100000;
        end;
        sum_death_&ppl = sum(of g:);
        sum_rate_&ppl = round(sum_death_&ppl/&&&ppl*100000, 0.01);
        sum_rate_adj_&ppl = round(sum(of rate:),0.01);
        keep disease sum_:;
    run;

%mend;

%table(ttl)
%table(male)
%table(female)

data reporter.ttl;
    merge work.testttl work.testfemale work.testmale;
run;

proc datasets lib = work noprint;
    delete t:;
run;
*==============================================;
*----------------     结果保存    --------------;
*==============================================;

*------------------ 表格看title   --------------;

ods rtf file =  "&rsltfile" style = journal ;
proc freq data = reporter.basefinal   order = freq;
    table gender race marriage occup edu location_of_death hospital_of_diagnosis diagnosis town reporter;
	table town * gender/nocol norow nopercent;
    title "三间分布";
run;


proc print data = reporter.ppl2;
    title "人口分布";
run;
proc print data = reporter.exfinal   label split = "/";
    var grp male_death ratemale ex_male female_death ratefemale ex_female ttl_death ratettl ex_ttl;
    title '简略寿命表';
    label grp = '年龄组'
          male_death= "男性/死亡人数"
          ratemale= "男性/粗死亡率"
          ex_male= "男性/期望寿命"
          female_death= "女性/死亡人数"
          ratefemale="女性/粗死亡率"
          ex_female= "女性/期望寿命"
          ttl_death= "合计/死亡人数"
          ratettl= "合计/粗死亡率"
          ex_ttl= "合计/期望寿命"; 
run; 


proc print data = reporter.triple_class label split = "/";
    var  code1 sum_male_death sum_male_rate sum_male_ratio sum_male_adjrate 
			  sum_female_death sum_female_ratio sum_female_rate sum_female_adjrate 
              sum_ttl_death sum_ttl_ratio sum_ttl_rate sum_ttl_adjrate ;
    title '三大类疾病死亡率';
    label code1 = "疾病分类"
    sum_male_death='男性/死亡人数'
	sum_male_ratio= '男性死亡/构成比'
    sum_male_rate= '男性/死亡率'
    sum_male_adjrate= '男性标化/死亡率'
    sum_female_death= '女性/死亡人数'
	sum_female_ratio= '女性死亡/构成比'
    sum_female_rate= '女性/死亡率'
    sum_female_adjrate= '女性标化/死亡率'
    sum_ttl_death='合计/死亡人数'
	sum_ttl_ratio='合计死亡/构成比'
    sum_ttl_rate='合计/死亡率'
    sum_ttl_adjrate = '合计标化/死亡率';
    sum s:;
run;


proc print data = reporter.triple_class_group label split= "/";
    var code1 grpmale0 ratemale_0 grpmale15 ratemale_15 grpmale35 ratemale_35 grpmale60 ratemale_60 
                  grpfemale0 ratefemale_0 grpfemale15 ratefemale_15 grpfemale35 ratefemale_35 grpfemale60 ratefemale_60
                  grpttl0 ratettl_0 grpttl15 ratettl_15 grpttl35 ratettl_35 grpttl60 ratettl_60;
    title '三大类疾病分年龄组死亡率';
    label code1 = '疾病分类' 
        grpmale0 = '男性0岁组/死亡数'
        ratemale_0  =  '男性0岁组/粗死亡率'
        grpmale15  =  '男性15岁组/死亡数'
        ratemale_15 =  '男性15岁组/粗死亡率'
        grpmale35 =  '男性35岁组/死亡数'
        ratemale_35  =  '男性35岁组/粗死亡率'
        grpmale60  =  '男性60岁组/死亡数'
        ratemale_60 =  '男性60岁组/粗死亡率'
        grpfemale0  =  '女性0岁组/死亡数'
        ratefemale_0 =  '女性0岁组/粗死亡率'
        grpfemale15  =  '女性15岁组/死亡数'
        ratefemale_15 =  '女性15岁组/粗死亡率'
        grpfemale35 = '女性35岁组/死亡数'
        ratefemale_35 =  '女性35岁组/粗死亡率'
        grpfemale60 =  '女性60岁组/死亡数'
        ratefemale_60 =  '女性60岁组/粗死亡率'
        grpttl0  = '合计0岁组/死亡数'
        ratettl_0  =  '合计0岁组/粗死亡率'
        grpttl15  =  '合计15岁组/死亡数'
        ratettl_15 =  '合计15岁组/粗死亡率'
        grpttl35  =  '合计35岁组/死亡数'
        ratettl_35  =  '合计35岁组/粗死亡率'
        grpttl60  =  '合计60岁组/死亡数'
        ratettl_60 =  '合计60岁组/粗死亡率';
        sum g: r:;
run;
proc print  data = reporter.shunwei label split='/';
    var code2 ttlttl ratio_ttl rate_ttl shunweittl 
                  ttlmale ratio_male rate_male shunweimale 
                  ttlfemale ratio_female rate_female shunweifemale;
    title '死因顺位';
    label code2 = '疾病名称'
        ttlttl = '合计/死亡数'
        ratio_ttl = '合计/构成比'
        rate_ttl = '合计/死亡率'
        shunweittl = '合计/顺位'
        ttlmale = '男性/死亡数'
        ratio_male = '男性/构成比'
        rate_male = '男性/死亡率'
        shunweimale = '男性/顺位'
        ttlfemale = '女性/死亡数'
        ratio_female = '女性/构成比'
        rate_female = '女性/死亡率'
        shunweifemale= '女性/顺位';
run;

%macro printshunwei(sex);
    proc print  data = reporter.shunwei_&sex label split='/';
        var code2 grp&sex.0 rate&sex._0 grp&sex.15 rate&sex._15 grp&sex.35 rate&sex._35 grp&sex.60 rate&sex._60;
        title "&sex.分年龄组死因统计";
        label code2 = '疾病名称'
          grp&sex.0  = "&sex.0岁组/死亡数"
          rate&sex._0  = "&sex.0岁组/粗死亡率"
          grp&sex.15  = "&sex.15岁组/死亡数"
          rate&sex._15  = "&sex.15岁组/粗死亡率"
          grp&sex.35  = "&sex.35岁组/死亡数"
          rate&sex._35  = "&sex.35岁组/粗死亡率"
          grp&sex.60  = "&sex.60岁组/死亡数"
          rate&sex._60 = "&sex.60岁组/粗死亡率";
        sum g: r:;
    run;
%mend;

%printshunwei(ttl)
%printshunwei(male)
%printshunwei(female)
proc report data = reporter.ttl nowindows headline headskip missing;
    columns disease sum_death_male sum_rate_male sum_rate_adj_male
            sum_death_female sum_rate_female sum_rate_adj_female
            sum_death_ttl sum_rate_ttl sum_rate_adj_ttl;
    title "103类死因总表";
    define disease /display "疾病名称";
    define sum_death_male  /display '男性/死亡人数';
    define sum_rate_male /display '男性/粗死亡率';
    define sum_rate_adj_male  /display '男性/标化死亡率';
    define sum_death_female  /display '女性/死亡人数';
    define sum_rate_female  /display'女性/粗死亡率';
    define sum_rate_adj_female  /display '女性/标化死亡率';
    define sum_death_ttl  /display '合计/死亡人数';
    define sum_rate_ttl /display '合计/粗死亡率';
    define sum_rate_adj_ttl  /display '合计/标化死亡率';
run;
ods rtf close;

*==============================================;
*-------------  清空所有生成的表格  ------------;
*==============================================;
proc datasets lib = reporter noprint;
    delete s: t: r: p: b: e: i: d: c:;
quit;
