********************************************************************************
* 05 - Migration Intentions Construction
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Constructs the dependent variable distinguishing between intentions to stay, migrate internally, and migrate internationally within the next 12 months, following Bekaert, Ruyssen & Salomone (2021).
*
* Input:   GWP cleaned data
*
* Output:  Migration intention variables (intmig_12, domesticmig)
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************



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

*DOMESTIC MIGRANTS:

gen domesticmig=.
replace domesticmig=1 if (move==1 & UMIG_in==1 & UMIG_pl==0) | (move==1 & UMIG_in==0) 
replace domesticmig=0 if move==0 | (move==1 & UMIG_in==1 & UMIG_pl==1)
label var domesticmig "domestic migrants"
/* NOTES:
Here we need information on "move" to identify domestic migrants so we cannot consider cases where move==.
domesticmig=1 if "YES YES NO" or "YES NO . "
domesticmig=0 if move==0 which covers the following cases:
NO  NO  .   --> stayer
NO  YES NO  --> international migrant >12m
NO  YES YES --> inconsistent
or if YES YES YES --> international migrant in 12m
*/


*STAYERS WITHIN 12 MONTHS:

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


*INCONSISTENT:

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

