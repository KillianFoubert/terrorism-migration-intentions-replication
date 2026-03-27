********************************************************************************
* 16 - Country-by-Country: By Skill Level
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Runs multinomial logit country by country separately for high-skilled and low-skilled respondents.
*
* Input:   ProvinceMonth database.dta
*
* Output:  Results_cbc_PolInstGDPpc_highskilled.dta, Results_cbc_PolInstGDPpc_lowskilled.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*
Below produces results country by country in line with Bertoli & Ruyssen (2018)

Notes 21/12/2020: we have large estimated coefficients for several countries, but don't throw them out
as this is not necessarily for the countries with the smallest sample

For high skilled, the number of observations is now on average 655 ranging from 68 to 3313
For low skilled, the number of observations is now on average 3049 ranging from 180 to 20580
*/

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

macro drop _all // THIS ONE IS ADDED!!!

*cd "D:\Dropbox\PhD Killian\Paper II\"
*cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\"
cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/"

//------------------------------------------------------------------------------
//                LOOP OVER SKILL LEVELS
//------------------------------------------------------------------------------
foreach k in hs ls { // Added by Ilse 11 May to do the subsample stuff

//------------------------------------------------------------------------------
//                GENERATE EMPTY DATASET
//------------------------------------------------------------------------------
clear all
set obs 1
gen origin =.
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_`k' 21122020.dta", replace


matrix table = J(1,17,.)
matrix colnames table = o converged nobs nalt nresp ndfm CorrPred nwaves nsubwaves DOM_GTIa_b DOM_GTIa_se DOM_GTIa_z DOM_GTIa_p INT_GTIa_b INT_GTIa_se INT_GTIa_z INT_GTIa_p

//------------------------------------------------------------------------------
//                       DEFINE SUBSAMPLE 
//------------------------------------------------------------------------------
use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear

gen hlskill = ""  // Added by Ilse 11 May to do the subsample stuff
replace hlskill = "hs" if hskill == 1 // Added by Ilse 11 May to do the subsample stuff
replace hlskill = "ls" if hskill == 0 // Added by Ilse 11 May to do the subsample stuff

keep if hlskill == "`k'" // Added by Ilse 11 May to do the subsample stuff

preserve
keep origin o
duplicates drop
save "Results/Clean/Countrybycountry/Temp/Originnumbers_`k' 21122020.dta", replace
restore

//------------------------------------------------------------------------------
//                          LOOP OVER ORIGINS 
//------------------------------------------------------------------------------
levelsof o, local(originlocal) // ?

***Choose one of the two below (either foreach to do regression for all countries, or forval to select one or a few countries)
foreach j of local originlocal {
*forval j = 1/2 { // To test for limited number of countries
ereturn clear // Clear e() stored results
mata: mata clear // Clear mata results

******************************************
*** PREPARE DATA
******************************************
use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear

qui gen hlskill = ""  // Added by Ilse 11 May to do the subsample stuff
qui replace hlskill = "hs" if hskill == 1 // Added by Ilse 11 May to do the subsample stuff
qui replace hlskill = "ls" if hskill == 0 // Added by Ilse 11 May to do the subsample stuff

qui keep if hlskill == "`k'" // Added by Ilse 11 May to do the subsample stuff

quietly keep if o ==`j' // keep all countries in foreach case, first two countries in the forval case
local cntry = origin // Macro definition and manipulation ?
display "`j'. `cntry'" // Display strings and values of scalar expressions --> ?
capture {

******************************************
*** MULTINOMIAL ESTIMATION
******************************************
global controls_o_yFE "age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y"
mlogit migmulti GTIa $controls_o_yFE, robust diff tech(dfp nr)

predict  pr0 pr1 pr2, pr
gen corrpred = .
replace corrpred = 1 if (migmulti == 1 & pr0 >= 0.5 | migmulti == 2 & pr1 >= 0.5 | migmulti == 3 & pr2 >= 0.5 )
replace corrpred = 0 if corrpred == . & e(sample)
egen nobspredcorr= total(corrpred) 
egen nobspredtot = count(corrpred) 
gen share_CorrPred = nobspredcorr/nobspredtot
estadd scalar CorrPred = share_CorrPred

******************************************
*** CHECK FOR OMITTED VARIABLES
******************************************
//	Make sure GTI variable is part of varlist
/*
local terrordropped 0 //?
if subinword("`e(indvars)'","GTIa","",.) == "`e(indvars)'" { //?
	di as err "Terror variable is dropped" //?
	local terrordropped 1		 //?
}
*/

******************************************
*** OUTPUT
******************************************
matrix table[1,1] = `j' // Country number
matrix table[1,2] = `e(converged)' // 1 if converged, 0 otherwise
matrix table[1,3] = `e(N)' // Number of observations
matrix table[1,4] = `e(N_cd)' // nalt -> Number of completely determined observations
matrix table[1,5] = `e(k_eq)' // nresp -> Number of equations in e(b)
matrix table[1,6] = `e(df_m)' // ndfm -> Model degrees of freedom (version until 26 May 2020)
*matrix table[1,7] = `e(k)' // npar -> Number of parameters (version until 26 May 2020)
matrix table[1,7] = `e(CorrPred)' // npar -> Number of parameters (version after 26 May 2020)
matrix temp = J(1,8,.)
*if "`terrordropped'" == "0"  {
*	matrix temp[1,1] = results[1..4,20]
*	matrix temp[5,1] = results[1..4,39]
matrix temp[1,1] = [#2]_b[GTIa]
matrix temp[1,2] = [#2]_se[GTIa]
matrix temp[1,3] = [#2]_b[GTIa]/[#2]_se[GTIa]
qui test [#2]GTIa 
matrix temp[1,4] = r(p)
matrix temp[1,5] = [#3]_b[GTIa]
matrix temp[1,6] = [#3]_se[GTIa]
matrix temp[1,7] = [#3]_b[GTIa]/[#3]_se[GTIa]
qui test [#3]GTIa
matrix temp[1,8] = r(p)

matrix table[1,10] = temp
/*}
else if "`terrordropped'" == "1" {

	matrix table[1,10] = J(1,8,.)
}
*/

tab wave if e(sample) //?
matrix table[1,9] = `r(r)' // nsubwaves
tostring wave, replace
gen wavemain = substr(wave,1,1) //?
tab wavemain
matrix table[1,8] = `r(r)' // nwaves

drop _all
svmat table, names(col) //?
append using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_`k' 21122020.dta"
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_`k' 21122020.dta", replace
}
}

use "Results/Clean/Countrybycountry/Temp/Originnumbers_`k' 21122020.dta", clear
merge 1:1 o using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_`k' 21122020.dta", force
drop if _merge != 3
drop _merge
order origin, before(o)
drop if DOM_GTIa_z ==.
drop if INT_GTIa_z ==.
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_`k' 21122020.dta", replace 

}



*** Analysing results high skilled
use "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_hs 21122020.dta", clear

sum nobs
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        nobs |         76    443.5921     410.548         32       2514
*/

count // Total number of countries: 71
count if DOM_GTIa_p < 0.10 // 20
count if DOM_GTIa_p < 0.05 // 14 --> reported in draft
count if DOM_GTIa_p < 0.01 // 8

count if INT_GTIa_p < 0.10 // 40
count if INT_GTIa_p < 0.05 // 35 --> reported in draft
count if INT_GTIa_p < 0.01 // 30

count if DOM_GTIa_b > 0  // 37 

count if DOM_GTIa_p < 0.10 & DOM_GTIa_b > 0  // 10
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b > 0  // 5 --> reported in draft
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b < 0  // 9
count if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0  // 4

count if INT_GTIa_b > 0  // 43

count if INT_GTIa_p < 0.10 & INT_GTIa_b > 0  // 20
count if INT_GTIa_p < 0.05 & INT_GTIa_b > 0  // 17 --> reported in draft
count if INT_GTIa_p < 0.05 & INT_GTIa_b < 0  // 18
count if INT_GTIa_p < 0.01 & INT_GTIa_b > 0  // 16

tab origin if DOM_GTIa_p < 0.10
tab origin if DOM_GTIa_p < 0.01 // 

tab origin if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0 // 

tab origin if INT_GTIa_p < 0.10
tab origin if INT_GTIa_p < 0.01

tab origin if INT_GTIa_p < 0.01 & INT_GTIa_b > 0 



*** Analysing results low skilled
use "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_ls 21122020.dta", clear

sum nobs
/*    
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        nobs |        103    2282.049    1891.625         78      16201
*/

count // Total number of countries: 103
count if DOM_GTIa_p < 0.10 // 30
count if DOM_GTIa_p < 0.05 // 23
count if DOM_GTIa_p < 0.01 // 14

count if INT_GTIa_p < 0.10 // 34
count if INT_GTIa_p < 0.05 // 30
count if INT_GTIa_p < 0.01 // 18

count if DOM_GTIa_b > 0  // 49 --> reported in draft

count if DOM_GTIa_p < 0.10 & DOM_GTIa_b > 0  // 18
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b > 0  // 15 --> reported in draft
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b < 0  // 8
count if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0  // 7

count if INT_GTIa_b > 0  // 51

count if INT_GTIa_p < 0.10 & INT_GTIa_b > 0  // 18
count if INT_GTIa_p < 0.05 & INT_GTIa_b > 0  // 17 --> reported in draft
count if INT_GTIa_p < 0.05 & INT_GTIa_b < 0  // 13
count if INT_GTIa_p < 0.01 & INT_GTIa_b > 0  // 7

tab origin if DOM_GTIa_p < 0.10
tab origin if DOM_GTIa_p < 0.01 // 

tab origin if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0 // 

tab origin if INT_GTIa_p < 0.10
tab origin if INT_GTIa_p < 0.01

tab origin if INT_GTIa_p < 0.01 & INT_GTIa_b > 0 

