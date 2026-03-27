********************************************************************************
* 04 - Gallup World Poll Cleaning
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Cleans the Gallup World Poll microdata. Constructs individual-level variables including migration intentions, demographics, household characteristics, network proxies, and wealth index.
*
* Input:   Gallup World Poll raw data (2007-2015)
*
* Output:  GallupCleaned.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*______________________________________________________________________________
Database created based on the Gwp 2016
----------
Notes:
----------
1/ We first compute the dummies identifying where the migration question has been 
asked and then drop respondents based on other variables (ie native, age)

2/ Note that for age we have 188 people older than 99 in the sample. These have been deleted

3/ BMIG is not entirely same as UMIG as there are people who say they want to move without
stating a preferred destination or without specifying it correctly. Use the unilateral variables when the goal is 
to calculate unilateral country shares of people willing to migrate. Use the 
bilateral variables to compute shares accounting for followup questions being answered.

4/ For those respondents who say they want to move but mention the country where 
they are interviewed as preferred destination we set their unilateral migration intention/plan to zero 
(as we don't know which answer is true in this case) and their destination answer to missing.

5/ In some country-waves, there are people who mention a destination while nobody answered the
preceeding unilateral intention to move question. For those who mention a destination we set the unilateral question to 1
and for those who did not we put it equal to 5. The latter value is then treated as a zero in umig (can be altered later on)

6/ On 21/12/2020, we adjusted the variables "children" and "hhsize" (aka adults) as earlier the variables
children and adults still took the values 97, and 96, 97, 98 and 99, respectively. These are now set to missing

Written by Ilse Ruyssen (April 2018) - Updated 21/12/2020
________________________________________________________________________________
*/

/*
To clean the ID_GADM_fine in worldata if needed from AFG1_1 for example to AFG_1
gen newvar=subinstr(ID_GADM_fine, "_1", "",.)
replace newvar = subinstr(newvar, ".", "",.)
________________________________________________________________________________
*/

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 

*cd "D:\Dropbox\PhD Killian\Paper II\Data\" // Killian fix PC
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\" // Killian Laptop
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "GWP/Clean/dta/GWP2016 ID_GADM_fine cleaned.dta"

**********************
* O/ Select DEPENDENT
**********************
*** Migration duration: tot, perm or temp
global duration perm
*** Strictness of definitions: "standard" or "strict"
global defstrict standard

// -----------------------------------------------------------------------------
// A/ Select required variables
// -----------------------------------------------------------------------------
rename WP* wp*

* I SHOULD ALSO KEEP THE INDEXES!!!

keep wpid wave wgt origin NAME_1 year wp119 wp1220 wp1219 wp3117 wp4657 EMP_2010 wp14 ///
wp1225 income_2 INCOME_4 wp2319 wp1230 wp1233 wp1223 wp12 wp9042 wp1325 wp3120 wp9498 wp9455 ///
wp9499 wp4633 wp3331 wp3333 wp3334 wp3335 wp3336 wp6880 wp10252 wp10253 wp9500 wp9501 wp9502 wp9048 ///
wp85 REGION REGION2 wp4 FIELD_DATE INDEX* wp5889 wp37 wp39 wp40 wp43 wp44 ///
wp1328 wp16 wp18 wp69 wp70 wp71 wp73 wp74 wp1418 wp10496 wp14732 wp9700 wp9701 wp17015 wp11356 ID_GADM_fine ID_GADM_coarse high_income ///
INDEX_CA INDEX_CB INDEX_GWFIN INDEX_GWSOC INDEX_GWCOM INDEX_GWPHY INDEX_LO INDEX_NI NAME_1 wp9039 wp10248 wp27

rename wp1220 age
rename wp1219 gender
rename wp1225 jobcat
rename income_2 hhinc
rename INCOME_4 hhincpc
rename wp1230 children
rename wp1233 relig
rename wp1223 maried
rename wp12 hhsize
rename wp9039 Trust

*** Clean the hhsize variable
replace hhsize = . if hhsize >95

*** Create partnership variable
gen Partnership = . 
replace Partnership = 1 if maried==2 | maried==8
replace Partnership = 0 if maried==1 | maried==3 | maried==4 | maried==5 
label variable Partnership "Married or domestic partner"

*** Clear trust variable
replace Trust = 0 if Trust==2
replace Trust = 1 if Trust==1
replace Trust = . if Trust==3 | Trust==4

*** Rescale education (distinguish between low skilled, medium skilled and high skilled)
gen educ = .
replace educ = 0 if wp3117== 1 
replace educ = 1 if wp3117== 2
replace educ = 2 if wp3117== 3
drop wp3117

*** Clean religious important
gen ReligiousImportant = .
replace ReligiousImportant = 1 if wp119==1
replace ReligiousImportant = 0 if wp119==2
drop wp119

*** Rescale rural/urban (combine "A rural area or on a farm (1)" and "A small town or village (2)" 
*** into "rural (1)" and "A large city (3)" and "A suburb of a large city (6)" into "urban (2)" 
gen urban = .
replace urban = 0 if wp14==1 | wp14==2
replace urban = 1 if wp14==3 | wp14==6
drop wp14

*** Rescale employment status (combine employed for employer and selfemployed, 
*** both part time or full time and combine unemployed and out of workforce into "0"
gen empl = .
replace empl = 1 if EMP_2010==1 | EMP_2010==2 | EMP_2010==3  | EMP_2010==5
replace empl = 0 if EMP_2010==4 | EMP_2010==6 
drop EMP_2010

*** Replace those who refused to answer (="100") and those who 99 and over (cause there's no specific age after 98, just "99+")
keep if age>=15
replace age=. if age>98

*** Replace number of children of those don't know (="98) or refused to answer (="99")
*** For now we keep those who say they have more than 97 children (79 people)
replace children=. if children==97 | children==98 | children==99 // Updated on 21/12/2020 by Ilse

*** Create dummy for those born in the country of respondence 
gen Native = 0
replace Native = 1 if wp4657 ==1
gen nonnative = 0
replace nonnative = 1 if wp4657 ==2

order nonnative educ urban empl, after(relig)

*** Generate id variables 
egen o = group(origin)               
order o, before(origin)

// -----------------------------------------------------------------------------
// B/ RECODE BILATERAL MIGRATION QUESTIONS
// -----------------------------------------------------------------------------
*** Identify destperm country names (desire to move)
decode wp3120, generate(destperm) 
*** Identify desttemp country names (desire to move)
decode wp9499, generate(desttemp) 
*** Identify destperm_pl country names (planning to move in next 12 months)
decode wp10253, generate(destperm_pl ) 
*** Identify desttemp_pl country names (planning to move in next 24 months)
decode wp9501, generate(desttemp_pl) 
*** Identify destination of HH members abroad
decode wp3331, generate(destHH) 
*** Identify destination of family or friends abroad who respondent can count on when needed
*** 1/ First
decode wp3334, generate(destFF1) 
*** 2/ Second
decode wp3335, generate(destFF2) 
*** 3/ Third
decode wp3336, generate(destFF3) 
*** Identify country of birth
decode wp9048, generate(cntrybirth) 

order cntrybirth destperm desttemp destperm_pl desttemp_pl destHH destFF1 destFF2 destFF3, after(o)

*** Set cntrybirth to missing if it mistakenly has a value
replace cntrybirth="" if cntrybirth=="(DK)" // (1,559 real changes made)
replace cntrybirth="" if Native==1 // (0 real changes made)

// -----------------------------------------------------------------------------
// C/ RECODE UNILATERAL MIGRATION QUESTIONS
// -----------------------------------------------------------------------------

*** Fill in missing responses to the unilateral migration questions when one of 
*** the followup questions (plans, preparations, or a destination has been mentioned 
*** (ie interviewer failed to indicate "yes" for these respondents)
replace wp1325 = 1 if wp1325!=1 & wp10252==1 // permanent intention no but plan yes: 0 real changes made
replace wp1325 = 1 if wp1325!=1 & wp9455==1 // permanent intention no but preparation yes: 0 real changes made
replace wp10252 = 1 if wp10252!=1 & wp9455==1 // permanent plan no but preparation yes: 176 real changes made --> note that for these we don't have a destination, though!!!

*** Identify the country-waves where some people have missing values for the question 
*** on whether they want to move abroad while they do mention a destination and replace 
*** for these country-waves the missing value for wp1325 to zero when they did not mention
*** a destination (assuming that all those received the question AND do not want/plan to move)
preserve
	gen ow_in_perm_miss = 0
	replace ow_in_perm_miss = 1 if wp1325!=1 & destperm !=""
	keep if ow_in_perm_miss ==1
	keep origin wave year ow_in_perm_miss
	duplicates drop	
	save "GWP/Clean/dta/Temp/OriginWave_int_perm.dta", replace
restore
preserve
	gen ow_in_temp_miss = 0
	replace ow_in_temp_miss = 1 if wp9498!=1 & desttemp !=""
	keep if ow_in_temp_miss ==1
	keep origin wave year ow_in_temp_miss
	capture duplicates drop
	save "GWP/Clean/dta/Temp/OriginWave_int_temp.dta", replace
restore
preserve
	gen ow_pl_perm_miss = 0
	replace ow_pl_perm_miss = 1 if wp10252!=1 & destperm_pl !=""
	keep if ow_pl_perm_miss ==1
	keep origin wave year ow_pl_perm_miss
	capture duplicates drop
	save "GWP/Clean/dta/Temp/OriginWave_pl_perm.dta", replace
restore
preserve
	gen ow_pl_temp_miss = 0
	replace ow_pl_temp_miss = 1 if wp9500!=1 & desttemp_pl !=""
	keep if ow_pl_temp_miss ==1
	keep origin wave year ow_pl_temp_miss
	capture duplicates drop
	save "GWP/Clean/dta/Temp/OriginWave_pl_temp.dta", replace
restore

merge m:1 origin wave using "GWP/Clean/dta/Temp/OriginWave_int_perm.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Clean/dta/Temp/OriginWave_int_temp.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Clean/dta/Temp/OriginWave_pl_perm.dta", keep(match master) nogen
merge m:1 origin wave using "GWP/Clean/dta/Temp/OriginWave_pl_temp.dta", keep(match master) nogen

/* // Note: changes suggested by Joel Jan2018
replace wp1325 = 0 if wp1325 ==. & destperm =="" & ow_in_perm_miss ==1
replace wp9498 = 0 if wp9498 ==. & desttemp =="" & ow_in_temp_miss ==1
replace wp10252 = 0 if wp10252 ==. & destperm_pl =="" & ow_pl_perm_miss ==1 
replace wp9500 = 0 if wp9500 ==. & desttemp_pl =="" & ow_pl_temp_miss ==1 
*/

replace wp1325 = 5 if wp1325 ==. & destperm =="" & ow_in_perm_miss ==1 // 13,849 real changes made
replace wp9498 = 5 if wp9498 ==. & desttemp =="" & ow_in_temp_miss ==1 // 0 real changes made
replace wp10252 = 5 if wp10252 ==. & destperm_pl =="" & ow_pl_perm_miss ==1 // 0 real changes made
replace wp9500 = 5 if wp9500 ==. & desttemp_pl =="" & ow_pl_temp_miss ==1 // 0 real changes made

replace wp1325 = 1 if wp1325!=1 & (destperm !="" & destperm !=origin) | (destperm_pl !="" & destperm_pl != origin) // permanent intention no but destination mentioned: 5,056 real changes made
replace wp10252 = 1 if wp10252!=1 & destperm_pl!="" // permanent plan no but destination mentioned: 0 real changes made

replace wp9498 = 1 if wp9498!=1 & wp9500==1 // temporary intention no but plan yes: 0 real changes made
replace wp9498 = 1 if wp9498!=1 & wp9502==1 // temporary intention no but preparation yes: 0 real changes made
replace wp9500 = 1 if wp9500!=1 & wp9502==1 // temporary plan no but preparation yes: 0 real changes made 
replace wp9498 = 1 if wp9498!=1 & (desttemp !="" & desttemp !=origin) | (desttemp_pl !="" & desttemp_pl != origin) // temporary intention no but destination mentioned: 0 real changes made
replace wp9500 = 1 if wp9500!=1 & desttemp_pl!="" // temporary plan no but destination mentioned: 0 real changes made

*** Set destination to missing for those respondents who didn't properly answer the destination question
foreach k in destperm destperm_pl desttemp desttemp_pl {
	replace `k'="" if `k' == "(Refused)" | `k' == "(DK)" | `k' == "HOLD" | `k' == "hold" | `k' == "(None)" | `k' == "None" ///
	| `k' == "Other Country" | `k' == "African Country" | `k' == "Arab Country" | `k' == "Island Nations (11)" | `k' == "Other Islamic Country"
}
/*
(20,368 real changes made) // NOW (03/12/2020) (20,228 real changes made)
(1,211 real changes made) // NOW (03/12/2020) (1,209 real changes made)
(5,142 real changes made)
(75 real changes made)
*/

*** Set migration intention/plan to zero and destination to missing for those respondents who say they want to move but mention the country where 
*** they are interviewed as preferred destination (as we don't know which answer is true in this case: 258 people)
replace wp1325 = 0 if (wp1325==1 & destperm==origin) // 275 real changes made
replace wp10252 = 0 if (wp10252==1 & destperm_pl==origin) // 40 real changes made
replace wp9498 = 0 if (wp9498 ==1 & desttemp==origin) // 57 real changes made
replace wp9500 = 0 if (wp9500 ==1 & desttemp_pl==origin) // 1 real changes made
foreach k in destperm destperm_pl desttemp desttemp_pl {
	replace `k'="" if `k'==origin
}
/*
(278 real changes made)
(40 real changes made)
(57 real changes made)
(1 real change made)
*/

// -----------------------------------------------------------------------------
// D/ GENERATE MIGRATION VARIABLES
// -----------------------------------------------------------------------------

************************
*** 0/ LIKELY TO MOVE QUESTION wp85 
************************
*QUESTION wp85 READS :In the next 12 months, are you likely or unlikely to move away from the city or area where you live?
gen move=.
replace move=1 if wp85==1
replace move=0 if wp85==2
label var move "likely to move away from the city or area where living in next 12m"

************************
*** 1/ PERMANENT 
************************
*** Create desire to move dummies
* UNILATERALLY desiring to move: 1 if respondent says he wants to migrate 
* permanently, 0 if he answers the question "do you want to move" with 2, 3 or 4
gen udm_perm = .
replace udm_perm = 1 if wp1325 == 1 
replace udm_perm = 0 if wp1325 == 2 | wp1325 == 3 | wp1325 == 4  | wp1325 == 5 
* BILATERALLY desiring to move to specific country: 1 if respondent says he wants to migrate 
* permanently and identifies a specific country, 0 if he does not indicate a country
gen bdm_perm = .
replace bdm_perm = 1 if destperm !="" 
replace bdm_perm = 0 if destperm =="" 

label var udm_perm "desire to migrate permanently to another country"
label var bdm_perm "desire to migrate permanently to another country and destination mentioned"

*** Create planning to move dummies
* UNILATERALLY planning to move: 1 if respondent says he is planning to migrate 
* permanently abroad in the next 12 months, 0 if he does not 
gen udmpl_perm = .
replace udmpl_perm = 1 if wp10252 == 1 
replace udmpl_perm = 0 if wp10252 == 2 | wp10252 == 3 | wp10252 == 4 | wp10252 == 5 
* BILATERALLY planning to move to a country: 1 if respondent says he wants to and is planning to migrate 
* permanently to a specific country in the next 12 months, 0 if he does not mention a country
gen bdmpl1_perm = .
replace bdmpl1_perm = 1 if destperm_pl!=""
replace bdmpl1_perm = 0 if destperm_pl=="" 
* Alternative:
* Planning to move to this country: 1 if respondent says he is planning to migrate 
* permanently to the country he desires to migrate to in the next 12 months, 0 if he says he 
* is not planning to migrate or he is planning to migrate but not to this country
gen bdmpl2_perm = .
replace bdmpl2_perm = 1 if destperm_pl!="" & destperm == destperm_pl
replace bdmpl2_perm = 0 if destperm_pl=="" | destperm != destperm_pl

label var udmpl_perm "plan to migrate permanently to another country in the next 12m "
label var bdmpl1_perm "plan to migrate permanently to another country in the next 12m and destination mentioned"
label var bdmpl2_perm "plan to migrate permanently to the country mentioned as intended destination in the next 12m "

*** Create preparing to move dummies
* UNILATERALLY preparing to move: 1 if respondent says he has made preparations to migrate 
* permanently abroad, 0 if he does not 
gen udmpr_perm = .
replace udmpr_perm = 1 if wp9455 == 1
replace udmpr_perm = 0 if wp9455 == 2 | wp9455 == 3 | wp9455 == 4 
* BILATERALLY preparing to move to a country: 1 if respondent says he has made 
* preparations for his move to the destination he is planning to move to, zero if not
gen destperm_pr=""
replace destperm_pr = destperm_pl if wp9455 == 1
gen bdmpr1_perm = .
replace bdmpr1_perm = 1 if destperm_pr!=""
replace bdmpr1_perm = 0 if destperm_pr=="" 
* Alternative:
* Preparing to move to this country: 1 if respondent says he is preparing to migrate 
* permanently to the country he desires to migrate to; zero if not
gen bdmpr2_perm = .
replace bdmpr2_perm = 1 if destperm_pr!="" & destperm == destperm_pr
replace bdmpr2_perm = 0 if destperm_pr=="" | destperm != destperm_pr

label var udmpr_perm "prepare to migrate permanently to another country in the next 12m"
label var bdmpr1_perm "prepare to migrate permanently to another country in the next 12m and destination mentioned"
label var bdmpr2_perm "prepare to migrate permanently to the country mentioned as intended destination in the next 12m"

************************
*** 2/ TEMPORARY 
************************
*** IMPORTANT NOTE: BECAUSE WE TAKE THE ROWMAX AFTER TO GET TOTAL WILLINGNESS TO MIGRATE,
*** AND BECAUSE WE ARE WORKING WITH INDIVIDUAL DATA, THERE IS NO PROBLEM OF DOUBLECOUNTING!!!!
***********************
*** Create desire to move dummies
* UNILATERALLY desiring to move: 1 if respondent says he wants to migrate 
* temporarily for work, 0 if he answers the question "do you want to move" with 2, 3 or 4
gen udm_temp = .
replace udm_temp = 1 if wp9498 == 1 
replace udm_temp = 0 if wp9498 == 2 | wp9498 == 3 | wp9498 == 4 | wp9498 == 5
* BILATERAL desire to move to specific country: 1 if respondent says he wants to migrate 
* temporarily for work to a specific country, 0 if not
gen bdm_temp = .
replace bdm_temp = 1 if desttemp !="" 
replace bdm_temp = 0 if desttemp =="" 

label var udm_temp "desire to migrate temporarily to another country "
label var bdm_temp "desire to migrate temporarily to another country and destination mentioned"

*** Create planning to move dummies
* UNILATERALLY planning to move: 1 if respondent says he is planning to migrate 
* temporarily for work in the next 24 months, 0 if he does not 
gen udmpl_temp = .
replace udmpl_temp = 1 if wp9500 == 1 
replace udmpl_temp = 0 if wp9500 == 2 | wp9500 == 3 | wp9500 == 4 | wp9500 == 5
* BILATERALLY planning to move to a country: 1 if respondent says he is planning to migrate 
* temporarily for work to a specific country in the next 24 months, 0 if not
gen bdmpl1_temp = .
replace bdmpl1_temp = 1 if desttemp_pl !=""
replace bdmpl1_temp = 0 if desttemp_pl =="" 
* Alternative:
* Planning to move to this country: 1 if respondent says he is planning to migrate 
* temporarily for work to the country he desires to migrate to in the next 24 months, 0 if not
gen bdmpl2_temp = .
replace bdmpl2_temp = 1 if desttemp_pl!="" & desttemp == desttemp_pl
replace bdmpl2_temp = 0 if desttemp_pl!="" | desttemp != desttemp_pl

label var udmpl_temp "plan to migrate temporarily to another country in the next 24m "
label var bdmpl1_temp "plan to migrate temporarily to another country in the next 24m and destination mentioned"
label var bdmpl2_temp "plan to migrate temporarily to the country mentioned as intended destination in the next 24m"

*** Create preparing to move dummies
* UNILATERALLY preparing to move: 1 if respondent says he is preparing to migrate 
* temporarily abroad, 0 if he does not 
gen udmpr_temp = .
replace udmpr_temp = 1 if wp9502 == 1
replace udmpr_temp = 0 if wp9502 == 2 | wp9502 == 3 | wp9502 == 4
* BILATERALLY preparing to move to a country: 1 if respondent says he is preparing to migrate 
* temporarily to a specific country and 0 if not
gen desttemp_pr = ""
replace desttemp_pr = desttemp_pl if wp9502 == 1
gen bdmpr1_temp = .
replace bdmpl1_temp = 1 if desttemp_pr !=""
replace bdmpl1_temp = 0 if desttemp_pr =="" 
* Preparing to move to this country: 1 if respondent says he is preparing to migrate 
* temporarily to the country he desires to migrate to; zero if not
gen bdmpr2_temp = .
replace bdmpr2_temp = 1 if desttemp_pr!="" & desttemp == desttemp_pr
replace bdmpr2_temp = 0 if desttemp_pr=="" | desttemp != desttemp_pr

label var udmpl_temp "prepare to migrate temporarily to another country in the next 24m "
label var bdmpl1_temp "prepare to migrate temporarily to another country in the next 24m and destination mentioned"
label var bdmpl2_temp "prepare to migrate temporarily to the country mentioned as intended destination in the next 24m"

************************
*** 3/ COMBINE PERMANENT AND TEMPORARY 
************************
gen desttot = desttemp
replace desttot = destperm if destperm!=""
order desttot, after(desttemp)

gen desttot_pl = desttemp_pl
replace desttot_pl = destperm_pl if destperm_pl!=""
order desttot_pl, after(desttemp_pl)

gen desttot_pr = desttemp_pr
replace desttot_pr = destperm_pr if destperm_pr!=""
order desttot_pr, after(desttemp_pr)

*** Create desire to move dummies
egen udm_tot = rowmax(udm_perm udm_temp)
egen bdm_tot = rowmax(bdm_perm bdm_temp)

*** Create planning to move dummies
egen udmpl_tot = rowmax(udmpl_perm udmpl_temp)
egen bdmpl1_tot = rowmax(bdmpl1_perm bdmpl1_temp)
egen bdmpl2_tot = rowmax(bdmpl2_perm bdmpl2_temp)

*** Create preparing to move dummies
egen udmpr_tot = rowmax(udmpr_perm udmpr_temp)
egen bdmpr1_tot = rowmax(bdmpr1_perm bdmpr1_temp)
egen bdmpr2_tot = rowmax(bdmpr2_perm bdmpr2_temp)

order udm_perm udm_temp udm_tot udmpl_perm udmpl_temp udmpl_tot udmpr_perm udmpr_temp udmpr_tot ///
bdm_perm bdm_temp bdm_tot bdmpl1_perm bdmpl1_temp bdmpl1_tot bdmpl2_perm bdmpl2_temp bdmpl2_tot ///
bdmpr1_perm bdmpr1_temp bdmpr1_tot bdmpr2_perm bdmpr2_temp bdmpr2_tot, before(empl)

************************
*** NETWORK DATA
************************
*** Create network dummies
* HH member abroad: 1 if question is answered positively 
* ... and 0 if question is answered negatively 
gen HHmabr = .
replace HHmabr = 1 if wp4633 == 1 
replace HHmabr = 0 if wp4633 == 2 | wp4633 == 3 | wp4633 == 4
* Friends or family member abroad: 1 if question is answered positively 
* ... and 0 if question is answered negatively 
gen FFmabr = .
replace FFmabr = 1 if wp3333 == 1 
replace FFmabr = 0 if wp3333 == 2 | wp3333 == 3 | wp3333 == 4

*egen mabr = rowmax(HHmabr FFmabr)
rename FFmabr mabr

** Clear wp10248 - In the city or area where you live, are you satisfied or dissatisfied with __________? The opportunities to meet people and make friends
tab wp10248 
/*     WP10248 |
Opportunitie |
   s to Make |
     Friends |      Freq.     Percent        Cum.
-------------+-----------------------------------
   Satisfied |    670,786       73.80       73.80
Dissatisfied |    202,266       22.25       96.05
        (DK) |     33,418        3.68       99.73
   (Refused) |      2,489        0.27      100.00
-------------+-----------------------------------
       Total |    908,959      100.00
*/ 
* RECODE 
gen wp10248bis = .
replace wp10248bis=1 if wp10248==1 // Satisfied 
replace wp10248bis=0 if wp10248==2 // dissatisfied 
replace wp10248bis=. if wp10248==3
replace wp10248bis=. if wp10248==4
drop wp10248
rename wp10248bis wp10248

** Clear wp27 - If you were in trouble, do you have relatives or friends you can count on to help you whenever you need them, or not?
tab wp27
/*
 WP27 Count |
 On to Help |      Freq.     Percent        Cum.
------------+-----------------------------------
        Yes |    899,867       78.81       78.81
         No |    227,194       19.90       98.71
       (DK) |     13,090        1.15       99.86
  (Refused) |      1,621        0.14      100.00
------------+-----------------------------------
      Total |  1,141,772      100.00
*/
* RECODE 
gen wp27bis = .
replace wp27bis=1 if wp27==1  // Yes
replace wp27bis=0 if wp27==2  // No 
replace wp27bis=. if wp27==3
replace wp27bis=. if wp27==4
drop wp27
rename wp27bis wp27

** Manchin and Orazbayev (2019) combine WP27 and WP10248 based on PCA as a proxy for “close local networks”
* Close social networks - Principal Component Analysis 
/*
The Close-social-networks index is the first principal component of the listed GWP survey questions (WP27 and WP10248), 
computed using polychoric principal component analysis. Sample weights are applied in the estimation. A higher 
value of an index indicates a better situation. Proportion of variance explained 
by the first component is 0.60
*/
sum wp27 wp10248 
polychoricpca wp27 wp10248 [pweight=wgt], score(pc) nscore(1)
rename pc1 closesocialnetwork

egen maxpc1=max(closesocialnetwork)
egen minpc1=min(closesocialnetwork)

* newvalue= (max'-min')/(max-min)*(value-max)+max'
gen closesocialnetwork1=1/(maxpc1-minpc1)
replace closesocialnetwork1=closesocialnetwork1*(closesocialnetwork-maxpc1)
replace closesocialnetwork1=closesocialnetwork1+1
sum closesocialnetwork1
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
closesocia~1 |    859,487    .7857944     .306103          0          1
*/

* Els tried to do this: normalized = (x-min(x))/(max(x)-min(x)) --> stil negative range 
*gen closesocialnetwork_final = (closesocialnetwork-minpc1)/(maxpc1-minpc1)

drop minpc1
drop maxpc1

********************************
*** Construction index proximity
********************************
gen prox=1 if wp14732==1 | wp9700==1 | wp9701==1 | wp17015==1
replace prox=0 if wp14732==2 | wp9700==2 | wp9701==2 | wp17015==2

************************************
*** Construction risk aversion index
************************************
gen riskaverse=1 if wp11356==2
replace riskaverse=0 if wp11356==1 

************************************
*** Construction basic wealth index
************************************

polychoricpca wp37 wp39 wp40 wp43 [pweight=wgt], score(pc) nscore(1)
rename pc1 wealth

* Normalization between 0 & 1
/* 
zi= xi - min(x) / (max(x)-min(x))
*/

*gen wealth1= (wealth-min(wealth))/(max(wealth)-min(wealth))
// Not sure why that command does not work, so I am doing it manually

egen maxwealth=max(wealth)
egen minwealth=min(wealth)
* newvalue= (max'-min')/(max-min)*(value-max)+max'
gen BasicWealth=1/(maxwealth-minwealth)
replace BasicWealth=BasicWealth*(wealth-maxwealth)
replace BasicWealth=BasicWealth+1

sum BasicWealth
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
     wealth1 |  1,061,711    .3064227    .2887417   5.96e-08          1
*/
drop minwealth
drop maxwealth

drop wp1325-wp85 wp9042-wp9501 wp9502 wp10252 wp10253

// -----------------------------------------------------------------------------
// E/ CHOOSE SETTING
// -----------------------------------------------------------------------------

*** Rename variables accordingly
* 1/ Analysis for permanent migration desire
if "$duration"== "perm" {
		rename destperm dest_in
		rename destperm_pl dest_pl
		rename destperm_pr dest_pr

		rename bdm_perm BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_perm BMIG_pl
			rename bdmpr1_perm BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_perm BMIG_pl	
			rename bdmpr2_perm BMIG_pr		
		}

		rename udm_perm UMIG_in
		rename udmpl_perm UMIG_pl
		rename udmpr_perm UMIG_pr

}
* 2/ Analysis for temporary migration desire only
else if "$duration"== "temp" {
		rename desttemp dest_in
		rename desttemp_pl dest_pl
		rename desttemp_pr dest_pr

		rename bdm_temp BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_temp BMIG_pl
			rename bdmpr1_temp BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_temp BMIG_pl	
			rename bdmpr2_temp BMIG_pr		
		}

		rename udm_temp UMIG_in
		rename udmpl_temp UMIG_pl
		rename udmpr_temp UMIG_pr

}
* 3/ Analysis for permanent and temporary migration desire combined
else if "$duration"== "tot" {
		rename desttot dest_in
		rename desttot_pl dest_pl
		rename desttot_pr dest_pr

		rename bdm_tot BMIG_in
		if "$defstrict" == "standard" {
			rename bdmpl1_tot BMIG_pl
			rename bdmpr1_tot BMIG_pr
		}
		else if "$defstrict" == "strict" {
			rename bdmpl2_tot BMIG_pl	
			rename bdmpr2_tot BMIG_pr		
		}

		rename udm_tot UMIG_in
		rename udmpl_tot UMIG_pl
		rename udmpr_tot UMIG_pr

}
capture drop *perm *perm_pl *perm_pr 
capture drop *temp *temp_pl *temp_pr
capture drop *tot *tot_pl *tot_pr 
drop bdm*

// -----------------------------------------------------------------------------
// F/ KEEP ONLY COUNTRY-WAVE PAIRS WHERE MIGRATION QUESTIONS WERE ASKED
// -----------------------------------------------------------------------------
*** Generate dummies to know where questions were asked
gen mig=0
replace mig=1 if BMIG_in==1
gen mig_pl=0
replace mig_pl=1 if BMIG_pl==1
gen mig_pr=0
replace mig_pr=1 if BMIG_pr==1
gen netw_FF=0
replace netw_FF=1 if mabr==1

preserve
collapse (mean) mig mig_pl mig_pr netw_FF, by (origin wave)
count //  1,217
count if mig==0 // 104
count if mig_pl==0 // 491
count if mig_pr==0 // 522
count if netw_FF==0 // 323
gen no_mig=0
replace no_mig=1 if mig==0
gen no_mig_pl=0
replace no_mig_pl=1 if mig_pl==0
gen no_mig_pr=0
replace no_mig_pr=1 if mig_pr==0
gen no_netw_FF=0
replace no_netw_FF=1 if netw_FF==0

keep origin wave no_mig no_mig_pl no_mig_pr no_netw_FF
label variable no_mig "Missing intentions (if 1)"
label variable no_mig_pl "Missing plans (if 1)"
label variable no_mig_pr "Missing preparations (if 1)"
label variable no_netw_FF "Missing network FF (if 1)"

save "GWP/Clean/dta/Temp/data_check_IR.dta", replace
restore

merge m:1 origin wave using "GWP/Clean/dta/Temp/data_check_IR.dta", nogen

keep if no_mig==0 // drops 125,942 observations // NOW (03/12/2020) (125,523 observations deleted)

/*Merge with iso codes for origin and destination
merge m:1 dest_in using "GWP/Old/dta/Temp/dest_in and iso_d.dta"
drop if _merge==2
drop _merge
merge m:1 origin using "GWP/Old/dta/Temp/origin names and ISO codes.dta"
drop if _merge==1
drop if _merge==2
drop _merge
*/

// Overview of the number of observations:
// ---------------------------------------
count // 1,097,681 (=original sample) // NOW (03/12/2020)  1,145,968
count if no_mig_pl==0 // 728,183 // NOW (03/12/2020) 758,541
count if no_mig_pr==0 // 700,331 // NOW (03/12/2020) 730,689
count if no_netw_FF==0 // 863,396 // NOW (03/12/2020) 902,075

save "GWP/Clean/dta/Temp/MigTerrorism_Gallup_$duration.dta", replace

// -----------------------------------------------------------------------------
// G/ ADD UNIQUE DESTINATION CODES
// -----------------------------------------------------------------------------
*** Match country names for destinations with those for origins
keep o origin
rename origin dest
rename o d
duplicates drop
save "GWP/Clean/dta/Temp/OriginCodes.dta", replace

foreach k in _in _pl _pr {

	use "GWP/Clean/dta/Temp/MigTerrorism_Gallup_$duration.dta", clear
	keep dest`k'
	rename dest`k' dest
	duplicates drop
	drop if dest==""
	*drop if dest == "African Country" // KEEP THIS!
	
	save "GWP/Clean/dta/Temp/Dest`k'Names.dta", replace
}

*** Create one big file containing all destination names ever mentioned and create a unique destination code
use "GWP/Clean/dta/Temp/OriginCodes.dta", clear
merge 1:1 dest using "GWP/Clean/dta/Temp/Dest_inNames.dta"
drop _merge
merge 1:1 dest using "GWP/Clean/dta/Temp/Dest_plNames.dta"
drop _merge
merge 1:1 dest using "GWP/Clean/dta/Temp/Dest_prNames.dta"
sort d _merge dest
replace d = d[_n-1]+1 if missing(d) 
drop _merge

save "GWP/Clean/dta/Temp/DestNames.dta", replace

*** Copy the file three times (for destinations for intentions, plans and preparations)
use "GWP/Clean/dta/Temp/DestNames.dta", clear
rename d d_in
rename dest dest_in
save "GWP/Clean/dta/Temp/Dest_inCodes.dta", replace
use "GWP/Clean/dta/Temp/DestNames.dta", clear
rename d d_pl
rename dest dest_pl

save "GWP/Clean/dta/Temp/Dest_plCodes.dta", replace
use "GWP/Clean/dta/Temp/DestNames.dta", clear
rename d d_pr
rename dest dest_pr
save "GWP/Clean/dta/Temp/Dest_prCodes.dta", replace

*** Add the unique destination codes to the Gallup data
use "GWP/Clean/dta/Temp/MigTerrorism_Gallup_$duration.dta", clear
merge m:1 dest_in using "GWP/Clean/dta/Temp/Dest_inCodes.dta"
drop _merge
merge m:1 dest_pl using "GWP/Clean/dta/Temp/Dest_plCodes.dta"
drop if _merge == 2
drop _merge
merge m:1 dest_pr using "GWP/Clean/dta/Temp/Dest_prCodes.dta"
drop if _merge == 2
drop _merge

order origin, before(o) 
order year wave wpid wgt, after(o)
order empl UMIG_in UMIG_pl UMIG_pr BMIG_in BMIG_pl BMIG_pr d_in d_pl d_pr dest_in ///
dest_pl dest_pr HHmabr mabr destHH destFF1 destFF2 destFF3 , after(urban)
order Native, before(cntrybirth)

label variable cntrybirth "Country of birth of the respondent if not native"
label variable Native "Dummy =1 if the respondent is born in the country where he is living"
label variable educ "Level of educ low skilled=0, medium skilled=1 and high skilled=2"
label variable urban "Urban dummy=1 if city, 0 otherwise"
label variable empl "Employment dummy=1 if employed (working), 0 otherwise"
label variable dest_pr "Country where prepared to move permanently"
label variable HHmabr "=1 if any members of your household live in a foreign country in the past five years"
label variable mabr "=1 if any friend or family live in a foreign country in the past five years"
*label variable mabr "rowmax of HHmabr and FFmabr, =1 if one of the two =1"
label variable mig "=1 if BMIG_in==1"
label variable mig_pl "=1 if BMIG_pl==1"
label variable mig_pr "=1 if BMIG_pr==1"
label variable netw_FF "=1 if FFmabr==1"

gen xx= INDEX_CM
drop INDEX_CM
rename xx INDEX_CM
label variable INDEX_CM "INDEX_CM Communications index"

gen xx= INDEX_CR
drop INDEX_CR
rename xx INDEX_CR
label variable INDEX_CR "INDEX_CR Corruption index"

gen xx= INDEX_DE
drop INDEX_DE
rename xx INDEX_DE
label variable INDEX_DE "INDEX_DE Daily Experience index"

gen xx= INDEX_DI
drop INDEX_DI
rename xx INDEX_DI
label variable INDEX_DI "INDEX_DI Diversity index"

gen xx= INDEX_LE
drop INDEX_LE
rename xx INDEX_LE
label variable INDEX_LE "INDEX_LE Life Evaluation index"

gen xx= INDEX_NX
drop INDEX_NX
rename xx INDEX_NX
label variable INDEX_NX "INDEX_NX Negative Experience index"

gen xx= INDEX_OT
drop INDEX_OT
rename xx INDEX_OT
label variable INDEX_OT "INDEX_OT Optimism index"

gen xx= INDEX_PH
drop INDEX_PH
rename xx INDEX_PH
label variable INDEX_PH "INDEX_PH Personal Health index"

gen xx= INDEX_PX
drop INDEX_PX
rename xx INDEX_PX
label variable INDEX_PX "INDEX_PX Positive Experience index"

gen xx= INDEX_ST
drop INDEX_ST
rename xx INDEX_ST
label variable INDEX_ST "INDEX_ST Struggling index"

gen xx= INDEX_SU
drop INDEX_SU
rename xx INDEX_SU
label variable INDEX_SU "INDEX_SU Suffering index"

gen xx= INDEX_TH
drop INDEX_TH
rename xx INDEX_TH
label variable INDEX_TH "INDEX_TH Thriving index"

gen xx= wp10496
drop wp10496
rename xx wp10496
label variable wp10496 "Muslim/west =1 can live together"
replace wp10496=0 if wp10496==2
replace wp10496= . if wp10496==3 | wp10496==4

gen xx= hhsize
drop hhsize
rename xx hhsize
label variable hhsize "Residents 15+ in household"

gen xx= gender
drop gender
rename xx gender

gen xx= age
drop age
rename xx age

gen xx= maried
drop maried
rename xx married
label variable married "WP1223 =1 married, =0 otherwise"
replace married = 1 if married==2
replace married = 0 if married==1 | married==3 | married==4 | married==5 | married==6 | married==7 | married==8

gen xx= jobcat
drop jobcat
rename xx jobcat
label variable jobcat "WP1225 type of job"

gen xx= children
drop children
rename xx children
label variable children "WP1230 Children under 15"

gen xx= relig
drop relig
rename xx relig
label variable relig "WP1233 Religion"
replace relig=-1 if relig==26
replace relig=1 if relig>=0 & relig<97
replace relig = . if relig==97 | relig==98 | relig==99
replace relig=0 if relig==-1

gen month = month(FIELD_DATE)

// ----------------------------------------
// DATA TRANSFORMATIONS
// ----------------------------------------
gen agesq = age*age
gen age1519 = 0
gen age2029 = 0
gen age3039 = 0
gen age4049 = 0
gen age5098 = 0

replace age1519 = 1 if age<20
replace age2029 = 1 if age>19 & age<30
replace age3039 = 1 if age>29 & age<40
replace age4049 = 1 if age>39 & age<50
replace age5098 = 1 if age>49 

label var agesq "square of age"
label var age1519 "aged 15 to 19"
label var age2029 "aged 20 to 29"
label var age3039 "aged 30 to 39"
label var age4049 "aged 40 to 49"
label var age5098 "aged 50 to 98"

*** Take logarithms
gen lhhincpc=ln(hhincpc)

*Create highskilled and mediumskilled dummy from educ (coded 0 or 1 instead of 1 or 2)
gen hskill = .
replace hskill = 1 if educ==2
replace hskill = 0 if educ==0 | educ==1

gen mhskill = .
replace mhskill = 1 if educ==1 | educ==2
replace mhskill = 0 if educ==0 

*** Rescale other variables
gen male = .
replace male=0 if gender==2
replace male=1 if gender==1

label var male "male"
label var lhhincpc "ln of hhincpc"
label var age "age"
label var hhsize "HH size"
label var mhskill "sec or tert educ"
label var hskill "tert educ"

drop ow_in_perm_miss ow_in_temp_miss ow_pl_perm_miss ow_pl_temp_miss d_in d_pr d_pl mig mig_pl mig_pr netw_FF
rename hhsize adults

merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         8,142
        from master                     8,033  (_merge==1)
        from using                        109  (_merge==2)

    matched                         1,141,111  (_merge==3)
    -----------------------------------------
*/

/* NOW 03/12/2020
    Result                           # of obs.
    -----------------------------------------
    not matched                           113
        from master                         5  (_merge==1)
        from using                        108  (_merge==2)

    matched                         1,145,968  (_merge==3)
    -----------------------------------------
*/

drop if origin==""
drop if _merge==2
drop _merge



save "GWP/Clean/dta/GallupCleaned.dta", replace
