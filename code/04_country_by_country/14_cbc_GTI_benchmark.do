********************************************************************************
* 14 - Country-by-Country: GTI Benchmark
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Runs multinomial logit country by country using the GTI as variable of interest (Online Appendix A.4).
*
* Input:   ProvinceMonth database.dta
*
* Output:  Results_cbc_PolInstGDPpc.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*
Below produces results country by country in line with Bertoli & Ruyssen (2018)

Update 21/12/2020 compared to 17/12/2020: we had to remove values 96-99 in the variables "children" and "adults". That means we have now estimates for 102
countries without error messages or convergence issues. For Norway too, our estimates now converge again so we keep this country in. 
There are 3 countries with very large coefficients for international migration aspirations:
-	Switzerland: number of observations is only 305 so we can motivate why we ignore it --> NO LONGER THE CASE AFTER IMR REVISION 20220403 (Ilse)
-	Turkmenistan: estimated coefficient is high at -3.88674, but number of observations is over 4000 
	and no error messages (related to variance being singular for instance or no converged reached)
-	Panama: the estimated coeff is -5.896295 but this is not even the largest in absolute terms (network 
	variable and ln GDPPc have even larger) so there doesn’t seem to be anything particularly wrong with it
So we keep Turkmenistan and Panama in but remove Switzerland.

Update 17/12/2020 compared to 04/12/2020: number of countries with pos/neg/sig coefficients code updated below to have everything we need in the draft
Norway is dropped but Switzerland is kept in at this stage (NO LONGER CASE 20220403)

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
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta", replace
 
matrix table = J(1,17,.)
matrix colnames table = o converged nobs nalt nresp ndfm CorrPred nwaves nsubwaves DOM_GTIa_b DOM_GTIa_se DOM_GTIa_z DOM_GTIa_p INT_GTIa_b INT_GTIa_se INT_GTIa_z INT_GTIa_p

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
append using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta"
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta", replace
}
}

use "Results/Clean/Countrybycountry/Temp/Originnumbers 21122020.dta", clear
merge 1:1 o using "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta", force
drop if _merge != 3 // Merge is equal to 2 for a line with missings in the using file (so not an issue)
drop _merge
order origin, before(o)
drop if DOM_GTIa_z ==.
drop if INT_GTIa_z ==.
save "Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta", replace 

*** Analysing results (updated by Ilse 20220403)
//Drop Switzerland as this country's estimated coeff for international migration is very large and the sample size is only 310
drop if origin=="Switzerland" // 

count // Total number of countries: 103

//Positive
count if DOM_GTIa_b > 0 // 49--> reported in draft
count if INT_GTIa_b > 0 // 65--> reported in draft

//Significant
count if DOM_GTIa_p < 0.10 // 34
count if DOM_GTIa_p < 0.05 // 30
count if DOM_GTIa_p < 0.01 // 18

count if INT_GTIa_p < 0.10 // 27
count if INT_GTIa_p < 0.05 // 22
count if INT_GTIa_p < 0.01 // 12

// Positive significant
count if DOM_GTIa_p < 0.10 & DOM_GTIa_b > 0  // 21
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b > 0  // 18 --> reported in draft
count if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0  // 10

count if INT_GTIa_p < 0.10 & INT_GTIa_b > 0  // 21
count if INT_GTIa_p < 0.05 & INT_GTIa_b > 0  // 16--> reported in draft
count if INT_GTIa_p < 0.01 & INT_GTIa_b > 0  // 8

// Negative significant
count if DOM_GTIa_p < 0.05 & DOM_GTIa_b < 0  // 12--> reported in draft
count if INT_GTIa_p < 0.05 & INT_GTIa_b < 0  // 6--> reported in draft

tab origin if DOM_GTIa_p < 0.10
tab origin if DOM_GTIa_p < 0.01 // 
/*

                COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Bahrain |          1        5.56        5.56
                                Belarus |          1        5.56       11.11
                               Cambodia |          1        5.56       16.67
                                  Chile |          1        5.56       22.22
                                  China |          1        5.56       27.78
                                 Cyprus |          1        5.56       33.33
       Democratic Republic of the Congo |          1        5.56       38.89
                               Ethiopia |          1        5.56       44.44
                                  Ghana |          1        5.56       50.00
                                  India |          1        5.56       55.56
                              Indonesia |          1        5.56       61.11
                                   Iran |          1        5.56       66.67
                                Nigeria |          1        5.56       72.22
                                 Russia |          1        5.56       77.78
                                 Serbia |          1        5.56       83.33
                                Somalia |          1        5.56       88.89
                                Ukraine |          1        5.56       94.44
                         United Kingdom |          1        5.56      100.00
----------------------------------------+-----------------------------------
                                  Total |         18      100.00

*/

tab origin if DOM_GTIa_p < 0.01 & DOM_GTIa_b > 0 // 
/*   
                COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Belarus |          1       10.00       10.00
                               Cambodia |          1       10.00       20.00
                                  Chile |          1       10.00       30.00
       Democratic Republic of the Congo |          1       10.00       40.00
                                  Ghana |          1       10.00       50.00
                                  India |          1       10.00       60.00
                              Indonesia |          1       10.00       70.00
                                   Iran |          1       10.00       80.00
                                Somalia |          1       10.00       90.00
                                Ukraine |          1       10.00      100.00
----------------------------------------+-----------------------------------
                                  Total |         10      100.00
*/

tab origin if INT_GTIa_p < 0.10
tab origin if INT_GTIa_p < 0.01
/*
                COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Bahrain |          1        8.33        8.33
                                   Chad |          1        8.33       16.67
       Democratic Republic of the Congo |          1        8.33       25.00
                                  Egypt |          1        8.33       33.33
                                  Ghana |          1        8.33       41.67
                                   Iran |          1        8.33       50.00
                                Liberia |          1        8.33       58.33
                             Mauritania |          1        8.33       66.67
                                Morocco |          1        8.33       75.00
                                Senegal |          1        8.33       83.33
                    Trinidad and Tobago |          1        8.33       91.67
                           Turkmenistan |          1        8.33      100.00
----------------------------------------+-----------------------------------
                                  Total |         12      100.00
*/

tab origin if INT_GTIa_p < 0.01 & INT_GTIa_b > 0 
/*
                COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Bahrain |          1       12.50       12.50
                                   Chad |          1       12.50       25.00
       Democratic Republic of the Congo |          1       12.50       37.50
                                  Ghana |          1       12.50       50.00
                                   Iran |          1       12.50       62.50
                                Liberia |          1       12.50       75.00
                             Mauritania |          1       12.50       87.50
                                Senegal |          1       12.50      100.00
----------------------------------------+-----------------------------------
                                  Total |          8      100.00
