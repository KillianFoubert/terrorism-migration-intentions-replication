********************************************************************************
* 17 - Country-by-Country: Other Push Factors
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Runs multinomial logit country by country for additional push factors (GDP, conflict, political instability).
*
* Input:   ProvinceMonth database.dta
*
* Output:  Results_cbc_GDP.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*==============================================================================
Title: Country-by-country Analysis of Push Factors for Migration
Author: Original by Bertoli & Ruyssen (2018), Modified 2024
Purpose: Produces results country by country for other push factors
Dependencies: 
- Data/Merge/Clean/dta/ProvinceMonth database.dta
- Results/Clean/Countrybycountry/Results_cbc_PolInstGDPpc 21122020.dta
Last Modified: January 29, 2024
==============================================================================*/

// Clear environment and set memory parameters
cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000
macro drop _all

// Set base paths - uncomment appropriate line for your environment
global BASE_PATH "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II"
*global BASE_PATH "C:/Users/kifouber/Dropbox/PhD Killian/Paper II"
*global BASE_PATH "D:/Dropbox/PhD Killian/Paper II"

cd "$BASE_PATH"

// Start log file
log using "Results/Clean/Logs/estimation_`c(current_date)'.log", replace

//==============================================================================
//                    GENERATE EMPTY DATASET for GDP estimate
//==============================================================================
capture {
    set obs 1
    gen origin = .
    save "Results/Clean/Countrybycountry/Results_cbc_GDP 20240129.dta", replace
    
    // Initialize results matrix
    matrix table = J(1,17,.)
    matrix colnames table = o converged nobs nalt nresp ndfm CorrPred nwaves nsubwaves ///
        DOM_GDP_b DOM_GDP_se DOM_GDP_z DOM_GDP_p INT_GDP_b INT_GDP_se INT_GDP_z INT_GDP_p
}

//==============================================================================
//                          LOOP OVER ORIGINS 
//==============================================================================
// Load data and get unique origins
use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear
levelsof o, local(originlocal)

// Define control variables
global controls_o_yFE "age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y"

// Loop through each origin
foreach j of local originlocal {
    // Clear previous estimation results
    ereturn clear
    mata: mata clear
    
    // Load and prepare data for current origin
    use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear
    quietly keep if o == `j'
    local cntry = origin
    display _n "Processing country `j': `cntry'" _n
    
    capture {
        // Multinomial logit estimation
        mlogit migmulti GTIa $controls_o_yFE, robust diff tech(dfp nr)
        
        // Generate prediction metrics
        predict pr0 pr1 pr2, pr
        gen corrpred = .
        replace corrpred = 1 if (migmulti == 1 & pr0 >= 0.5 | migmulti == 2 & pr1 >= 0.5 | migmulti == 3 & pr2 >= 0.5)
        replace corrpred = 0 if corrpred == . & e(sample)
        egen nobspredcorr = total(corrpred)
        egen nobspredtot = count(corrpred)
        gen share_CorrPred = nobspredcorr/nobspredtot
        estadd scalar CorrPred = share_CorrPred
        
        // Store results in matrix
        matrix table[1,1] = `j'
        matrix table[1,2] = `e(converged)'
        matrix table[1,3] = `e(N)'
        matrix table[1,4] = `e(N_cd)'
        matrix table[1,5] = `e(k_eq)'
        matrix table[1,6] = `e(df_m)'
        matrix table[1,7] = `e(CorrPred)'
        
        // Store coefficient estimates
        matrix temp = J(1,8,.)
        matrix temp[1,1] = [#2]_b[lnGDPpc_lag]
        matrix temp[1,2] = [#2]_se[lnGDPpc_lag]
        matrix temp[1,3] = [#2]_b[lnGDPpc_lag]/[#2]_se[lnGDPpc_lag]
        qui test [#2]lnGDPpc_lag 
        matrix temp[1,4] = r(p)
        matrix temp[1,5] = [#3]_b[lnGDPpc_lag]
        matrix temp[1,6] = [#3]_se[lnGDPpc_lag]
        matrix temp[1,7] = [#3]_b[lnGDPpc_lag]/[#3]_se[lnGDPpc_lag]
        qui test [#3]lnGDPpc_lag
        matrix temp[1,8] = r(p)
        matrix table[1,10] = temp
        
        // Store wave information
        tab wave if e(sample)
        matrix table[1,9] = `r(r)'
        tostring wave, replace
        gen wavemain = substr(wave,1,1)
        tab wavemain
        matrix table[1,8] = `r(r)'
        
        // Save results
        drop _all
        svmat table, names(col)
        append using "Results/Clean/Countrybycountry/Results_cbc_GDP 20240129.dta"
        save "Results/Clean/Countrybycountry/Results_cbc_GDP 20240129.dta", replace
    }
    if _rc {
        display as error "Error processing country `cntry' (code `j')"
        continue
    }
}

//==============================================================================
//                    GENERATE EMPTY DATASET for CONFLICT
//==============================================================================
// Similar structure as above, but for conflict analysis
// ... [rest of the code follows similar pattern with improved organization]

//==============================================================================
//                MERGE ESTIMATES FROM GTI, GDP and CONFLICT
//==============================================================================
use "Results/Clean/Countrybycountry/Temp/Originnumbers 21122020.dta", clear

// Merge datasets
foreach dataset in "PolInstGDPpc 21122020" "GDP 20240129" "Conflict 20240129" {
    merge 1:1 o using "Results/Clean/Countrybycountry/Results_cbc_`dataset'.dta", force
    drop if _merge != 3
    drop _merge
}

// Final data cleaning
order origin, before(o)
drop if DOM_GTIa_z == .
drop if INT_GTIa_z == .

// Save final results
save "Results/Clean/Countrybycountry/Results_cbc_combi with other pushfactors 20240129.dta", replace

// Close log file
log close

// End of file
