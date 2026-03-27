********************************************************************************
* 12 - Final Merge
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Merges all cleaned datasets (GWP, GTD, WDI, Polity IV, UCDP, regions, trust) into the final individual-level panel. Constructs remaining variables and fixed effects.
*
* Input:   All cleaned datasets from scripts 00-11
*
* Output:  ProvinceMonth database.dta (287,483 individuals, 142 countries, 2007-2015)
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/* 
----------
Notes:
----------
- These countries are not present in GTD: Botswana Comoros Costa Rica Gabon Lithuania Luxembourg Mongolia Mauritius Malawi Namibia Puerto Rico Singapore El Salvador Suriname Slovenia Togo Zambia -> I dropped them by precaution
- Only inner mongolia in GTD, not mongolia itself -> not clear if GWP consider inner mongolia as mongolia -> drop mongolia to avoid mismatch
- Puerto Rico included in colombia in GTD, independant country in GWP
- Variable capturing the proximity to attacks on an individual level. Would measure if the interviewee came into close contact with attack(s). In the master thesis she uses the following questions "Has someone from this household lost their life as a result of the ongoing violence?" "Within the paste 12 months have you had a relative or close friend kidnapped" "Within the 12 past months have you had a relative or close friend murdered" "Please tell me if you have experienced any of the following as a result of the recent conflict in this country. Was your house damaged or destroyed by bombing during the recent conflict in this country?" -> Papers suggesting that proximity to conflict is an important factor: Melander Oberg (2007) The threat of violence and forced migration Geographical scope trumps intensity of fighting. Bohra-Mishra & Massey (2011) Individual decisions to migrate during civil conflict
- Shortcomings with GWP
   - When the data for the GWP is collected, this is done for entire countries "except in areas where the safety of the interviewing staff is threatened" (Gallup 2012). Threshold defining the safety of areas is not defined. 
   - Being asked questions about migration can incite the interviewee to start thinking more about it than they did before and thus bias the answer (Ruyssen 2017). 
   - Not all questions cover every country or cover a large time period
   - Translation issues -> done by three separate translators. The first translates the questions into the target language, the second translates the answers back to the source language and a third one, whom is independent, reviews these two translations and adds improvements where needed.
   - Coverage error possible -> A certain part of the population has 0 probability of being selected for the survey.
   - Possible errors due to the presence of authoritarian governments with the selected countries, then the respondents are less forthcoming about their true opinion.
  
Note Ilse: in the bottom the data for which lnhhincpc was missing were thrown out but this is no longer needed if we
		   exclude this variable from the benchmark regression (which means we gain observations).
   
Written by Killian Foubert (May 2018)
Updated by Ilse (July 2020)
________________________________________________________________________________
*/

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 

*cd "D:\Dropbox\PhD Killian\Paper II\Data\"
*cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\"
cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "GWP/Clean/dta/GallupCleaned.dta"

drop if year < 2007

********************************************************************************
********************************************************************************
********************************************************************************

drop if ID_GADM_fine==""
* I have to drop observations with no info on region code, won't be used in the estimation anyway. Any way to keep some of the regions?
*(10,562 observations deleted)

merge m:1 year month ID_GADM_fine using "GTD/Clean/dta/GTD PPPM ready to be merged with GWP.dta"

/*
Result                           # of obs.
    -----------------------------------------
    not matched                       511,534
        from master                   363,883  (_merge==1)
        from using                    147,651  (_merge==2)

    matched                           771,523  (_merge==3)
    -----------------------------------------

*/

foreach k in AttackOccurrence GTIa GTIb GTI_score_lag1 GTI_score_lag2 GTI_score_lag3 GTI_score_lag4 GTI_score_lag5 GTIbis_score_lag1 GTIbis_score_lag2 GTIbis_score_lag3 GTIbis_score_lag4 GTIbis_score_lag5 AttacksIndexA AttacksIndexB VictimsIndexA VictimsIndexB BombingIndexA BombingIndexB NationalTargIndexA NationalTargIndexB TargViolPolIndexA TargViolPolIndexB TargReligIndexA TargReligIndexB Attacks_cityPPPM Attacks_city_ratePPPM Attacks_city_ratePPPM_0 avgGTIa_byprov ratioGTIa_byprov ratioGTIa{
replace `k'=0 if _merge==1
}

gen terrorunkn=1 if _merge==1
drop _merge

merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            98
        from master                         0  (_merge==1)
        from using                         98  (_merge==2)

    matched                         1,283,057  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge

*** 
*** Merge with UCDP/PRIO
***

merge m:1 year iso3o using "Conflicts/Clean/Dta/Occurrence of conflict.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       972,875
        from master                   972,856  (_merge==1)
        from using                         19  (_merge==2)

    matched                           310,201  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
replace WarOccurrence_low=0 if _merge==1
replace WarOccurrence_high=0 if _merge==1
replace WarOccurrence=0 if _merge==1

replace WarOccurrence_low5y=0 if _merge==1
replace WarOccurrence_high5y=0 if _merge==1
replace WarOccurrence5y=0 if _merge==1

drop _merge

***
*** Merge with Polity IV
***

merge m:1 year iso3o using "Polity IV/Clean/Dta/Polity4 GWP.dta" // Added by Ilse 05/06/2020 Should be m:1!!!!!

/*    
    Result                           # of obs.
    -----------------------------------------
    not matched                        22,956
        from master                    22,791  (_merge==1)
        from using                        165  (_merge==2)

    matched                         1,260,266  (_merge==3)
    -----------------------------------------
*/

rename polity2 polity2_lag // lagged manually in the polity4 do file (added year+1)
rename PolInstability PolInstability_lag // lagged manually (added year+1)
rename PolInstab3y PolInstab3y_lag // Added by Ilse 05 June 2020

drop if _merge==2
drop _merge

gen autocr=1 if polity2_lag<0
replace autocr=0 if polity2_lag>0
gen democr=1 if polity2_lag>0
replace democr=0 if polity2_lag<0

***
*** Add region identifiers
***

merge m:1 iso3o using "Regions identifiers/dta/Regions identifiers.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                         1,453
        from master                     1,440  (_merge==1)
        from using                         13  (_merge==2)

    matched                         1,281,617  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge

***
*** Add region levels of development
***

merge m:1 iso3o year using "WDI/Clean/Dta/GNIpc.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        13,937
        from master                    13,277  (_merge==1)
        from using                        660  (_merge==2)

    matched                         1,269,780  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge 

***
*** Countries size
***

merge m:1 iso3o using "Country sizes/cleaned.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        14,450
        from master                    14,391  (_merge==1)
        from using                         59  (_merge==2)

    matched                         1,268,666  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge

***
*** Add GDP pc
***

merge m:1 iso3o year using "WDI/Clean/Dta/GDPpc.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        13,937
        from master                    13,277  (_merge==1)
        from using                        660  (_merge==2)

    matched                         1,269,780  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge 

***
*** Add GDP
***

merge m:1 iso3o year using "WDI/Clean/Dta/GDP.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        13,937
        from master                    13,277  (_merge==1)
        from using                        660  (_merge==2)

    matched                         1,269,780  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge


***
*** Distinguishing internal and international migration
***

// International migrants in the next 12m
gen intmig_12=.
replace intmig_12= 1 if (move==1 & UMIG_in==1 & UMIG_pl==1) | (move==. & UMIG_in==1 & UMIG_pl==1)
replace intmig_12= 0 if UMIG_pl==0 |  (move==0 & UMIG_in==1 & UMIG_pl==1)
label var intmig_12 "international permanent migrant in the next 12 months"
/* NOTES:
Intmig_12=1 if "YES YES YES" or ". YES YES"
Intmig_12=0 if UMIG_pl! which covers the following cases:
YES YES NO --> domestic migrant
YES NO  NO --> domestic migrant
NO  YES NO --> international migrant >12m
NO  NO  NO --> stayer
.   YES NO --> we don't know anything except that there are no plans to move internationally in next 12m
.   NO  NO --> no plans to move internationally in next 12m
or if NO YES YES --> inconsistent
*/

// Internal migrants in the next 12m
gen domesticmig=.
replace domesticmig=1 if (move==1 & UMIG_in==1 & UMIG_pl==0) | (move==1 & UMIG_in==0) 
replace domesticmig=0 if move==0 | (move==1 & UMIG_in==1 & UMIG_pl==1)
label var domesticmig "domestic migrants in the next 12m"
/* NOTES:
Here we need information on "move" to identify domestic migrants so we cannot consider cases where move==.
domesticmig=1 if "YES YES NO" or "YES NO . "
domesticmig=0 if move==0 which covers the following cases:
NO  NO  .   --> stayer
NO  YES NO  --> international migrant >12m
NO  YES YES --> inconsistent
or if YES YES YES --> international migrant in 12m
*/

// Stayers in the next 12m
gen stayer12=.
*Old code: replace stayer12=1 if (move==0 & UMIG_in==0) | (move==0 & UMIG_in==1 & UMIG_pl==0) 
replace stayer12=1 if move==0 
replace stayer12=0 if move==1 | (move==0 & UMIG_in==1 & UMIG_pl==1) 
label var stayer12 "people who move neither internally nor internationally in the next 12 months"
/* NOTES:
Here we need information on "move" to identify the category inconsistent so we cannot consider cases where move==.
stayer12=1 if "NO NO ." or if "NO YES NO" 
stayer12=0 if move==1 which covers the following cases:
YES YES YES --> international migrant in 12m
YES YES NO  --> domestic migrant
YES NO  .   --> domestic migrant
or if "NO YES YES" (inconsistent) 
*/

// Inconsistent
gen inconsistent=.
replace inconsistent=1 if (move==0 & UMIG_in==1 & UMIG_pl==1) 
replace inconsistent=0 if move==1 | (move==0 & UMIG_in==1 & UMIG_pl==0) | (move==0 & UMIG_in==0) 
label var inconsistent "unlikely to move but planning to move permanently"
/* NOTES:
Here we need information on "move" to identify the category inconsistent so we cannot consider cases where move==.
inconsistent=1 if "NO YES YES"
inconsistent=0 if move==1 which covers the following cases:
YES YES YES --> international migrant in 12m
YES YES NO  --> domestic migrant
YES NO  .   --> domestic migrant
or if "NO YES NO" (international migrant >12m) or "NO NO ." (stayer)
*/

gen migmulti=.
replace migmulti=1 if stayer12==1
replace migmulti=2 if domesticmig==1
replace migmulti=3 if intmig_12==1

gen UMIG_pl2=UMIG_pl
replace UMIG_pl2=0 if UMIG_in==0
drop UMIG_pl
rename UMIG_pl2 UMIG_pl

***
*** Merge with trust index WVS
***

merge m:1 iso3o year using "Trust WVS/Clean/dta/Trust.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       768,418
        from master                   768,382  (_merge==1)
        from using                         36  (_merge==2)

    matched                           514,675  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge

label var age2029 "Aged 20 to 29"
label var age3039 "Aged 30 to 39"
label var age4049 "Aged 40 to 49"
label var age5098 "Aged 50 to 98"
label var male "Male"
label var hskill "High skill"
label var urban "Urban"
label var children "Number 15- in HH"
label var adults "Number 15+ in HH"
label var lhhincpc "Log HH income pc"
label var mabr "Network"
label var PolInstability_lag "Political instability"
label var polity2_lag "Polity score"
label var WarOccurrence_low "Conflict low intensity"
label var WarOccurrence_high "Conflict high intensity"
label var WarOccurrence "Conflict"
label var GTIa "GTI index method A"
label var GTIb "GTI index method B"
label var TargReligIndexA "Attacks against religious targets"
label var AttackOccurrence "Occurrence of at least 1 attack"
label var AttacksIndexA "Index number of attacks"
label var VictimsIndexA "Index number of victims"
label var BombingIndexA "Index number of bombings"

drop o

drop if age5098==1 // Lose 352,477 observations
drop age5098

gen touse = 1
*global indcontrols "age2029 age3039 age4049 male hskill urban children adults lhhincpc mabr polity2_lag WarOccurrence"
global indcontrols "age2029 age3039 age4049 male hskill urban children adults  mabr polity2_lag WarOccurrence WarOccurrence5y" // Adjusted by Ilse 15/07/2020

foreach k in migmulti GTIa $indcontrols {
	replace touse = 0 if `k'==.
}
keep if touse == 1
*tab origin if touse==1 // Keep only countries for which all the controls have nonmissing values here, as well as in the loop. Afghanistan is not there so it needs to be removed also in the loop

egen o = group (origin)
egen y = group (year)

rename GDPpc GDPpc_lag
gen lnGDPpc_lag = ln(GDPpc_lag)
rename WarOccurrence WarOccurrence_lag
rename WarOccurrence5y WarOccurrence5y_lag


sum GDPpc_lag // mean  14314.87
gen GDPpc_cent=GDPpc_lag - 14314.87
gen GDPpc_cent_sq=GDPpc_cent^2
gen ln_GDPpc_cent_sq = ln(GDPpc_cent_sq)

save "Merge/Clean/dta/ProvinceMonth database", replace

