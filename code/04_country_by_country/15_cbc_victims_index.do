********************************************************************************
* 15 - Country-by-Country: Victims Index
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Runs multinomial logit country by country using the victims index as variable of interest.
*
* Input:   ProvinceMonth database.dta
*
* Output:  Results_cbc_PolInstGDPpc_Victims.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*
Below produces results country by country in line with Bertoli & Ruyssen (2018)

There are some outliers but we cannot blame it to a smaller number of observations...
No countries are thrown out
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
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\"
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/"


//------------------------------------------------------------------------------
//                GENERATE EMPTY DATASET
//------------------------------------------------------------------------------
set obs 1
gen origin =.
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_Victims 21122020.dta", replace
 
matrix table = J(1,17,.)
matrix colnames table = o converged nobs nalt nresp ndfm CorrPred nwaves nsubwaves DOM_Victims_b DOM_Victims_se DOM_Victims_z DOM_Victims_p INT_Victims_b INT_Victims_se INT_Victims_z INT_Victims_p

//------------------------------------------------------------------------------
//                       DEFINE SUBSAMPLE 
//------------------------------------------------------------------------------
use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear
preserve
keep origin o
duplicates drop
save "Results/Clean/Countrybycountry/Temp/Originnumbers 21122020.dta", replace
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

quietly keep if o ==`j' // keep all countries in foreach case, first two countries in the forval case
local cntry = origin // Macro definition and manipulation ?
display "`j'. `cntry'" // Display strings and values of scalar expressions --> ?
capture {

******************************************
*** MULTINOMIAL ESTIMATION
******************************************
global controls_o_yFE "age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y"
mlogit migmulti VictimsIndexA $controls_o_yFE, robust diff tech(dfp nr)

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
if subinword("`e(indvars)'","Victims","",.) == "`e(indvars)'" { //?
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
matrix temp[1,1] = [#2]_b[VictimsIndexA]
matrix temp[1,2] = [#2]_se[VictimsIndexA]
matrix temp[1,3] = [#2]_b[VictimsIndexA]/[#2]_se[VictimsIndexA]
qui test [#2]VictimsIndexA 
matrix temp[1,4] = r(p)
matrix temp[1,5] = [#3]_b[VictimsIndexA]
matrix temp[1,6] = [#3]_se[VictimsIndexA]
matrix temp[1,7] = [#3]_b[VictimsIndexA]/[#3]_se[VictimsIndexA]
qui test [#3]VictimsIndexA
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
append using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_Victims 21122020.dta"
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_Victims 21122020.dta", replace
}
}

use "Results/Clean/Countrybycountry/Temp/Originnumbers 21122020.dta", clear
merge 1:1 o using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_Victims 21122020.dta", force
drop if _merge != 3
drop _merge
order origin, before(o)
drop if DOM_Victims_z ==.
drop if INT_Victims_z ==.
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc_Victims 21122020.dta", replace 


count // Total number of countries: 92

//Positive
count if DOM_Victims_b > 0 // 50--> reported in draft
count if INT_Victims_b > 0 // 51--> reported in draft

//Significant
count if DOM_Victims_p < 0.10 // 29
count if DOM_Victims_p < 0.05 // 24
count if DOM_Victims_p < 0.01 // 14

count if INT_Victims_p < 0.10 // 31
count if INT_Victims_p < 0.05 // 21
count if INT_Victims_p < 0.01 // 14

// Positive significant
count if DOM_Victims_p < 0.10 & DOM_Victims_b > 0  // 17
count if DOM_Victims_p < 0.05 & DOM_Victims_b > 0  // 14
count if DOM_Victims_p < 0.01 & DOM_Victims_b > 0  // 9

count if INT_Victims_p < 0.10 & INT_Victims_b > 0  // 20
count if INT_Victims_p < 0.05 & INT_Victims_b > 0  // 14
count if INT_Victims_p < 0.01 & INT_Victims_b > 0  // 8

// Negative significant
count if DOM_Victims_p < 0.05 & DOM_Victims_b < 0  // 10
count if INT_Victims_p < 0.05 & INT_Victims_b < 0  // 7

// Country lists
tab origin if DOM_Victims_p < 0.10
tab origin if DOM_Victims_p < 0.01 // 
tab origin if DOM_Victims_p < 0.01 & DOM_Victims_b > 0 // 
tab origin if INT_Victims_p < 0.10
tab origin if INT_Victims_p < 0.01
tab origin if INT_Victims_p < 0.01 & INT_Victims_b > 0 
