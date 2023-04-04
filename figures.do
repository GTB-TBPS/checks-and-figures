*****************************************************************************************
*Code to generate some checks and figures e.g. population pyramids and participation rate
*Author: I. Law, B. Sismanidis
*Example country shown below - please adapt variable names and categories to your survey
*****************************************************************************************

*generate age group in year 

recode age (0/4=1) (5/9=2) (10/14=3)  (15/24=4) (25/34=5)(35/44=6)(45/54=7)(55/64=8)(65/200=9), gen (agegroup)
label define agegroup_label 1 "<5" 2 "5-9" 3 "10-14" 4 "15-24" 5 "25-34" 6 "35-44" 7 "45-54" 8 "55-64" 9 "65+" 
label values agegroup agegroup_label
tab agegroup,m


*create categories for sex and residency

gen sex=1 if sex_=="Male"
replace sex=0 if sex_=="Female"

label define sex_label 1"male" 0"female"
label values sex sex_label
tab sex,m

tab agegroup sex,m

gen resident=1 if residence=="Yes"
replace resident=0 if residence=="No"
tab agegroup resident,m

*Eligible to participate - only those 15 years and above, and resident (this is irrespective of consent)

drop elig_part
gen elig_part=.
replace elig_part=1 if age>=15 & resident==1
replace elig_part=0 if elig_part!=1
tab elig_part,m

*How many participants are there who gave consent? 
drop part
gen part=.
replace part=1 if consent=="Yes" & elig_part==1
replace part=0 if part!=1
tab part,m


*how many people were interviewed?
count if part==1 &  sex_ind!=""

* how many had CXR undertaken?
tab xray_done xray_res,m
count if xray_done=="Yes" 
count if xray_done=="Yes" & part==1 


*Generate symptom eligible 

tab cough, generate(c)
drop c1 cough
rename c2 cough

tab fever, generate(f)
drop f1 fever
rename f2 fever

tab sweat, generate(s)
drop s1 sweat
rename s2 sweat

tab body_weight, generate(b)
drop b1 body_weight
rename b2 body_weight



gen elig_symp=.
replace elig_symp=1 if cough==1 & cough_dura>=14 & part==1 
replace elig_symp=1 if fever ==1 & part==1 
replace elig_symp=1 if sweat ==1 & part==1 
replace elig_symp=1 if body_weight ==1 & part==1 
replace elig_symp=0 if elig_symp!=1 & part==1

label define yes_no_label 1 "yes" 0"no"
label values elig_symp yes_no_label 

tab elig_symp,m


*Generate CXR eligible from field CXR result i.e. Abnormal, suggestive of TB.
gen elig_cxr=.

gen cxr1=.
replace cxr1=1 if xray_result=="Abnormal, lung field"
replace cxr1=0 if xray_result=="Normal"
replace cxr1=2 if xray_result=="Abnormal other abnormality"
label define cxr_label 0 "normal" 1 "Abnormal, lung field" 2"other" 
label values cxr1 cxr_label 
tab cxr1


*recode cxr2 (central CXR reading)
gen cxr2=.
replace cxr2=1 if central_result=="Abnormal; suggestive of TB"
replace cxr2=0 if central_result=="Normal"
replace cxr2=2 if xray_res=="Abnormal; not suggestive of TB"|xray_res=="Healed TB"
label define cxr_label2 0 "normal" 1 "Abnormal, suggestive of TB" 2"other" 
label values cxr2 cxr_labe2 
tab cxr2

 
replace elig_cxr=1 if cxr1==1 & part==1
replace elig_cxr=0 if (cxr1==0|cxr1==2) & part==1
tab elig_cxr

tab elig_cxr elig_symp,m

*Generate CXR exempt i.e. those who do not have a CXR result 
tab xray_done xray_res,m
gen cxr_exempt=.
replace cxr_exempt=1 if xray_done!="Yes" & part==1
replace cxr_exempt=0 if xray_done=="Yes" & part==1
tab cxr_exempt


*Generate eligible for sputum
gen elig_sputum=.
replace elig_sputum=1 if elig_symp==1 & elig_cxr!=1 & part==1
replace elig_sputum=2 if elig_symp!=1 & elig_cxr==1 & part==1
replace elig_sputum=3 if elig_symp==1 & elig_cxr==1 & part==1
replace elig_sputum=4 if cxr_exempt==1 & elig_symp!=1 & part==1
replace elig_sputum=5 if elig_symp!=1 & elig_cxr!=1 & cxr_exempt!=1 & part==1

label define elig_sput_lab ///
1 "Eligible by symptom only" ///
2 "Eligible by CXR only" ///
3 "Eligible by both" ///
4 "CXR exempted, asymp" ///
5 "Not eligible"
label values elig_sputum elig_sput_lab 

tab elig_sputum

*total number of particiants eligible to submit samples?
count if elig_sputum<5

*how many spuum 1 and 2 taken?
tab sput1 sput2 if elig_part<5

gen sput_coll=.
replace  sput_coll=1 if sput1=="Yes" | sput2=="Yes"
tab sput_coll

tab sput1 sput2 if elig_spu<5,m

gen sput_coll_both=1 if sput1=="Yes" & sput2=="Yes"


* but how many have a Xpert result? (there are some people who were tested but not eligible to do so)

tab xpert_res if elig_sputum<5
tab xpert_res if elig_sputum<5 & sput_coll==1
tab xpert_res if elig_sputum<5 & sput1=="Yes"
tab xpert_res if elig_sputum<5 & sput2=="Yes"
tab xpert_res if elig_sputum<5 & sput1=="Yes" & sput2=="No" 
tab xpert_res if elig_sputum<5 & sput1=="No" & sput2=="Yes"
tab xpert_res if elig_sputum==5 |elig_sputum==.


* but how many have a culture result?

tab culture_results if elig_sputum<5
tab culture_results if elig_sputum<5 & sput_coll==1
tab culture_results if elig_sputum<5 & sput1=="Yes" & sput2=="No"
tab culture_results if elig_sputum<5 & sput2=="No" & sput2=="Yes" 
tab culture_results if elig_sputum<5 & sput_coll!=1
tab culture_results if elig_sputum==5 |elig_sputum==. 


gen xpert_grade=.
replace xpert_grade=1 if xpert_res=="MTB Detected(High)" 
replace xpert_grade=2 if xpert_res=="MTB Detected(Medium)" 
replace xpert_grade=3 if xpert_res=="MTB Detected(Low)" 
replace xpert_grade=4 if xpert_res=="MTB Detected (Very low)" 
replace xpert_grade=5 if xpert_res=="Positive" 
replace xpert_grade=0 if xpert_res=="MTB Not Detected" 


label define xpert_grade_lab ///
0 "negative" ///
1 "high" ///
2 "medium" ///
3 "low" ///
4 "very low" ///
5 "trace" 
label values xpert_grade xpert_grade_lab

tab xpert_grade


*gen Xpert variable if Xpert positive excluding trace
gen gxp=1 if xpert_grade<5 & xpert_grade!=0 & elig_sputum<5
replace gxp=0 if xpert_grade==0 & elig_sputum<5
tab gxp


*how many lab positive that are eligible?
gen labpos=.
replace labpos=1 if culture==1 & elig_sputum<5
replace labpos=1 if xpert_grade<5 & xpert_grade!=0 & elig_sputum<5
tab labpos


*check for those that have a lab result but are NOT eligible to submit samples 
tab xpert_grade culture if elig_sputum==5|elig_sputum==.,m

tab culture_res if elig_sputum>4 
tab xpert_res if elig_sputum>4 

list pin_ind labno culture_res xpert_res elig_sputum if culture==1 & elig_sputum>4 
list pin_ind labno culture_res xpert_res elig_sputum if xpert_res =="MTB Detected(High)" & elig_sputum>4 
list pin_ind labno culture_res xpert_res elig_sputum if xpert_res =="Positive" & elig_sputum>4 


*past TB history
gen past=1 if pasttb=="Yes" & part==1
replace past=0 if pasttb=="No" & part==1
drop pasttb
rename past pasttb

gen curr=1 if currenttb=="Yes" & part==1
replace curr=0 if currenttb=="No" & part==1 
drop currenttb
rename curr currenttb

tab pasttb currenttb if part==1,m


*HIV self-reporting
tab hiv_int if part==1


*HIV testing
gen hiv_test=.
replace hiv_test=1 if hive_res=="Postive"
replace hiv_test=0 if hive_res=="Negative"

tab hiv_test if elig_sputum<5,m

*create combine HIV result

gen hivcombined=.
replace hivcombined=1 if hiv_test==1
replace hivcombined=0 if hiv_test==0
replace hivcombined=1 if hiv_test==. & hiv_int=="Yes(Positve)" 
replace hivcombined=0 if hiv_test==. & hiv_int=="Yes(Negative)"
tab hivcombined if part==1,m

***********************************
*SOME LAB CHECKS
***********************************

**check if culture results are cross-contaminated assuming the specimens are processed according to lab number order
sort labno
tab culture_results
tab xpert_res


*make lab number into numeric format

gen c1=labno
gen c1a = substr(c1,4,7)
destring c1a, replace

br cluster household_hh individual_hh pin_ind serialnumber serial_num labno c1a culture_results if culture==1

* check to see if there is any culture clustering by order of lab number i.e. next to each other.
preserve
keep if culture==1
sort cluster c1a
gen flag_culture=1 if c1a[_n]==(c1a[_n-1]+1) 
tab flag_culture
list cluster pin_ind c1a if flag_culture==1
restore

* check to see if there is any culture clustering by household number i.e. next to each other or same household
preserve
keep if culture==1
sort cluster household_hh
gen flag_culture_hh=1 if household_hh[_n]==(household_hh[_n-1]+1)
replace flag_culture_hh=2 if household_hh[_n]==(household_hh[_n-1]) 
tab flag_culture_hh
list cluster pin_ind c1a if flag_culture_hh==1|flag_culture_hh==2
restore


* check to see if there is any Xpert clustering by order of lab number i.e. next to each other.
preserve
keep if xpert_grade<6
sort cluster c1a
gen flag_xpert=1 if c1a[_n]==(c1a[_n-1]+1) 
tab flag_xpert
list cluster pin_ind c1a if flag_xpert==1
restore

* check to see if there is any Xpert clustering by household number i.e. next to each other or same household
preserve
keep if xpert_grade<6
sort cluster household_hh
gen flag_xpert_hh=1 if household_hh[_n]==(household_hh[_n-1]+1)
replace flag_xpert_hh=2 if household_hh[_n]==(household_hh[_n-1]) 
tab flag_xpert_hh
list cluster pin_ind c1a if flag_xpert_hh==1|flag_xpert_hh==2
restore

 

*******************************************************************************
*Create Population Pyramids
*******************************************************************************

use enumerated.dta, clear

count /* total enumerated = 39902*/
drop if agegroup<4 /*drops children = 12853*/
drop if agegroup==. /*drops the unknown = 0 */

keep sex agegroup part elig_part
rename part present
rename elig_part eligible
label drop _all
label define yesno 1 "Yes" 0 "No"
label values present yesno
tab present

gen male=1 if sex==1
gen female=1 if sex==0
gen elig_part_male=1 if male==1 & eligible==1
gen elig_part_female=1 if female==1 & eligible==1
gen part_male=1 if male==1 & present==1
gen part_female=1 if female==1 & present==1

collapse (sum) male female elig_part_male elig_part_female part_male part_female , by(agegr)

egen total_sex=total(male + female)
egen total_elig_part=total(elig_part_male + elig_part_female)
egen total_part=total(part_male + part_female)

gen pc_male=(-1*100*male)/total_sex
gen pc_female=(1*100*female)/total_sex

gen pc_elig_part_male=(-1*100*elig_part_male)/total_elig_part
gen pc_elig_part_female=(1*100*elig_part_female)/total_elig_part

gen pc_part_male=(-1*100*part_male)/total_part
gen pc_part_female=(1*100*part_female)/total_part



* POPULATION FROM SURVEY CENSUS COMPARED TO ELIGIBLE POPULATION TO PARTICIPATE IN THE SURVEY
twoway bar pc_male agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| /// 
bar pc_elig_part_male agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(blue)|| ///
bar pc_female agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar pc_elig_part_female agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(blue) || /// 
,xtitle("Percent") ytitle("Age group (years)") ylabel(4 "15-24" 5 "25-34" 6 "35-44" 7 "45-54" 8 "55-64" 9 "65+", angle(0)) /// 
legend(label(1 Census) label(2 Eligible)) legend(order(1 2)) plotregion(style(none)) ///
text(8 -10 "Male") text(8 10 "Female") xlabel(-20"20" -10"10" 10"10" 20"20")
*title("Census vs. Eligible population")


* ELIGIBLE POPULATION TO PARTICIPATE COMPARED TO ACTUAL PARTICIPANTS IN THE SURVEY - PERCENT
twoway bar pc_elig_part_male agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar pc_part_male agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| /// 
bar pc_elig_part_female agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar pc_part_female agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| ///  
,xtitle("Percent") ytitle("Age group (years)") ylabel(4 "15-24" 5 "25-34" 6 "35-44" 7 "45-54" 8 "55-64" 9 "65+", angle(0)) /// 
legend(label(1 Eligible) label(2 Participants)) legend(order(1 2)) plotregion(style(none)) ///
text(8 -10 "Male") text(8 10 "Female") xlabel(-20"20" -10"10" 10"10" 20"20")
*title("Eligible vs. Participant population") 


gen elig_part_male1=elig_part_male*-1
gen part_male1=part_male*-1

* ELIGIBLE POPULATION TO PARTICIPATE COMPARED TO ACTUAL PARTICIPANTS IN THE SURVEY - NUMBER
twoway bar elig_part_male1 agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar part_male1 agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| /// 
bar elig_part_female agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar part_female agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| ///  
,xtitle("Number") ytitle("Age group (years)") ylabel(4 "15-24" 5 "25-34" 6 "35-44" 7 "45-54" 8 "55-64" 9 "65+", angle(0)) /// 
legend(label(1 Eligible) label(2 Participants)) legend(order(1 2)) plotregion(style(none)) ///
text(8 -2500 "Male") text(8 2500 "Female") xlabel(-1000"1000" -2000"2000" -3000"3000" 1000"1000" 2000"600" 3000"3000")
*title("Eligible vs. Participant population") 


* COMPARE ELIGIBLE POPULATION WITH THE NATIONAL CENSUS, not from the survey but from MOH (EXAMPLE DATA SHOWN HERE)
input m_census f_census
205041	204092
182758	174330
116911	109765
68210	77036
46529	62509
44049	78517


egen total_census=total(m_census + f_census)
gen pc_census_male=(-1*100*m_census)/total_census
gen pc_census_female=(1*100*f_census)/total_census


* ELIGIBLE POPULATION TO PARTICIPATE COMPARED TO NATIONAL CENSUS 2016 - PERCENT
twoway bar pc_elig_part_male agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar pc_census_male agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| /// 
bar pc_elig_part_female agegr, horizontal xvarlab(Agegroups) fcolor(gs12) lcolor(gs12)|| ///
bar pc_census_female agegr, horizontal xvarlab(Agegroups) fcolor(none) lcolor(red)|| ///  
,xtitle("Percent") ytitle("Age group (years)") ylabel(4 "15-24" 5 "25-34" 6 "35-44" 7 "45-54" 8 "55-64" 9 "65+", angle(0)) /// 
legend(label(1 Enumerated) label(2 National Census)) legend(order(1 2)) plotregion(style(none)) ///
text(8 -10 "Male") text(8 10 "Female") xlabel(-20"20" -10"10" 10"10" 20"20")
*title("Eligible vs. Census population") 



****************************
* Participation rate figures
****************************

use enumerated.dta, clear

*Graph PR age by sex
preserve
drop if agegroup==1|agegroup==2|agegroup==3|agegroup==.
recode sex 0=2
collapse (sum) elig_part part, by (agegroup sex)
gen pr=(part*100)/elig_part
drop part elig_part
twoway (line pr agegroup if sex==1) (line pr agegroup if sex==2), ytitle(Participation rate (%)) yscale(range(50 100)) /// 
ylabel(#6) xtitle(Age groups) xlabel(#6, labels valuelabel)  ///
 legend(label(1 "Male") label(2 "Female")) plotregion(margin(vsmall))  yline(85,lcolor (green)) 
*title(Participation rate by age group and sex)
restore


*Graph participation rate by strata

preserve
drop if agegroup==1|agegroup==2|agegroup==3|agegroup==.
collapse (sum) elig_part part, by (agegroup strata)
gen pr=(part*100)/elig_part
drop part elig_part
twoway (line pr agegroup if strata==1) (line pr agegroup if strata==2) (line pr agegroup if strata==3), ytitle(Participation rate (%)) yscale(range(50 100)) /// 
ylabel(#6) xtitle(Age groups) xlabel(#6, labels valuelabel)  ///
 legend(label(1 "Urban") label(2 "Rural") label(3 "Peri-urban")) plotregion(margin(vsmall))  yline(85, lcolor(green) ) 
*title(Participation rate by age group and strata)
restore


*participation rate by chronological cluster order
preserve
sort cluster
by cluster : egen pr1=total(part)
by cluster : egen pr2=total(elig_part)
by cluster : gen pr=(pr1/pr2)*100
sort cluster start_time
bysort cluster: gen n1 = _n
keep if n1==1
drop n1
sort start_time
generate n1 = _n
twoway (bar pr n1), ytitle(Participation rate (%)) yscale(range(50 100)) /// 
ylabel(#6) xtitle(Chronological cluster order) xlabel(#11, labels valuelabel)  yline(85, lcolor (red))
restore


*participation rate by survey cluster order
preserve
sort cluster
by cluster : egen pr1=total(part)
by cluster : egen pr2=total(elig_part)
by cluster : gen pr=(pr1/pr2)*100
bysort cluster: gen n1 = _n
keep if n1==1
drop n1
generate n1 = _n
twoway (bar pr n1), ytitle(Participation rate (%)) yscale(range(50 100)) /// 
ylabel(#6) xtitle(Survey cluster order) xlabel(#11, labels valuelabel)  yline(85, lcolor (red))
restore

