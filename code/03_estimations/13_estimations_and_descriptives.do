********************************************************************************
* 13 - Estimations and Descriptive Statistics
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Runs all multinomial logit estimations reported in the paper: benchmark (Table 1), robustness checks (Tables 2-3), heterogeneity by individual characteristics (Table 4), descriptive statistics (Tables A.1-A.2), and maps (Figures 1-2).
*
* Input:   ProvinceMonth database.dta
*
* Output:  LaTeX tables and Stata graphs
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/*
Repeat regressions with cluster(o) as additional option
Add the log of GDP pc (not GDPpc as in June) as well as war occurrence, political instability(new computation as of June2020) and polity2
*/


cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

*cd "D:\Dropbox\PhD Killian\Paper II\"
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\"
cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/"

use "Data/Merge/Clean/dta/ProvinceMonth database.dta", clear


********************************************************************************
********************************NEW  MAIN TABLES *******************************
********************************************************************************
*global controls_o_yFE "age2029 age3039 age4049 male hskill urban mabr children adults lnGDPpc_lag polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y"
global controls_o_yFE "age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y"

label variable age2029 "Aged 20 to 29"
label variable age3039 "Aged 30 to 39"
label variable age4049 "Aged 40 to 49"
label variable male "Male"
label variable urban "Urban"
label variable hskill "High skilled"
label variable children "Nr children"
label variable adults "Nr adults"
label variable lhhincpc "Ln HH inc pc" // No longer included to not blur the effect running through income
label variable mabr "Network"
label variable polity2_lag "Democracy"
label variable WarOccurrence_lag "Conflict"
label variable PolInstab3y_lag "Pol instab"
label variable lnGDPpc_lag "ln GDP pc"
label variable ln_GDPpc_cent_sq "ln GDP pc sq"
label variable GTIa "GTI"
label variable ReligiousImportant "Religion"
label variable Partnership "Partnership"
label variable Native "Native"
label variable BasicWealth "HH wealth"
label variable closesocialnetwork1 "Integration"




**************************
*** Share migrants - Total
**************************
preserve
keep ID_GADM_fine migmulti origin NAME_1
drop if migmulti==.
gen stayer=1 if migmulti==1
replace stayer=0 if migmulti==2
replace stayer=0 if migmulti==3
gen domesticmig=1 if migmulti==2
replace domesticmig=0 if migmulti==1
replace domesticmig=0 if migmulti==3
gen internationalmig=1 if migmulti==3
replace internationalmig=0 if migmulti==1
replace internationalmig=0 if migmulti==2
drop migmulti
gen n=1
egen TotalinterviewedBycountries = sum(n), by(origin)
egen TotalinterviewedByregions = sum(n), by(ID_GADM_fine)
egen Totalinterviewed = sum(n)
egen TotalStayersBycountries = sum(stayer), by(origin)
egen TotalStayersByregions = sum(stayer), by(ID_GADM_fine)
egen TotalStayers = sum(stayer)
egen TotalDomesticmigBycountries = sum(domesticmig), by(origin)
egen TotalDomesticmigByregions = sum(domesticmig), by(ID_GADM_fine)
egen TotalDomesticmig = sum(domesticmig)
egen TotalInternationalmigBycountries = sum(internationalmig), by(origin)
egen TotalInternationalmigByregions = sum(internationalmig), by(ID_GADM_fine)
egen TotalInternationalmig = sum(internationalmig)
gen ShareStayersBycountries = TotalStayersBycountries/TotalinterviewedBycountries
gen ShareStayersByregions = TotalStayersByregions/TotalinterviewedByregions
gen ShareStayers = TotalStayers/Totalinterviewed
gen ShareDomesticmigBycountries = TotalDomesticmigBycountries/TotalinterviewedBycountries
gen ShareDomesticmigByregions = TotalDomesticmigByregions/TotalinterviewedByregions
gen ShareDomesticmig = TotalDomesticmig/Totalinterviewed
gen ShareInternationalmigBycountries = TotalInternationalmigBycountries/TotalinterviewedBycountries
gen ShareInternationalmigByregions = TotalInternationalmigByregions/TotalinterviewedByregions
gen ShareInternationalmig = TotalInternationalmig/Totalinterviewed
drop stayer domesticmig internationalmig TotalInternationalmigBycountries TotalStayersBycountries TotalDomesticmigBycountries TotalStayers TotalDomesticmig TotalInternationalmig n TotalStayersByregions TotalDomesticmigByregions TotalInternationalmigByregions
sort ID_GADM_fine
duplicates drop
keep ShareStayers ShareDomesticmig ShareInternationalmig Totalinterviewed
duplicates drop
rename Totalinterviewed TotalRespondents
order ShareStayers ShareDomesticmig ShareInternationalmig TotalRespondents
format (ShareStayers) %12.2f
format (ShareDomesticmig) %12.2f
format (ShareInternationalmig) %12.2f
format (TotalRespondents) %15.0fc
export excel ShareStayers ShareDomesticmig ShareInternationalmig TotalRespondents using "Results\Clean\Results clusteredo\Share migrants general.xls", firstrow(variables) replace
restore

egen r = group (ID_GADM_fine)

tab migmulti
/*
   migmulti |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |    404,026       81.28       81.28
          2 |     82,028       16.50       97.78
          3 |     11,013        2.22      100.00
------------+-----------------------------------
      Total |    497,067      100.00
*/
gen movebinary=0 if migmulti==2
replace movebinary=1 if migmulti==3

sort origin
by origin: generate n = _N
sort n
summarize n, detail

/*
      Percentiles      Smallest
 1%          310            305
 5%          716            310
10%         1031            346       Obs                 142
25%         1932            517       Sum of Wgt.         142

50%       3234.5                      Mean           3500.472
                        Largest       Std. Dev.      2513.349
75%         4536           6837
90%         5903           9479       Variance        6316923
95%         6242          10950       Skewness       3.690309
99%        10950          23329       Kurtosis       28.87761
*/

gen n10=1 if n<=1031
replace n10=0 if n10==.
gen n50=1 if n<=3234.5
replace n50=0 if n50==.
gen n90=1 if n<=5903
replace n90=0 if n90==.

drop if age <20



********************************************************************************
********************************************************************************
******************* Tables revision IMR - APPENDIX *****************************
********************************************************************************
********************************************************************************

* APPENDIX TABLE 1: Regression with variable move as dependent variable (so this is not distinguishing between internal or international migration)
qui logit move GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tn1
logit UMIG_pl GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tn2
esttab Tn1 Tn2 using "Revision IMR/RR/dependent move.tex", eform unstack noomitted label title("Appendix 1") mtitles("move" "Umig_pl") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tn1 Tn2 using "Revision IMR/RR/dependent move.rtf", eform unstack noomitted label title("Appendix 1") mtitles("move" "Umig_pl") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 2: Countries sizes
preserve
keep if SmallestCountries==1
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tg1
restore
preserve
keep if MiddleCountries==1
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tg2
restore
preserve
keep if LargestCountries==1
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tg3
restore
esttab Tg1 Tg2 Tg3 using "Revision IMR/RR/Countries size.tex", eform unstack noomitted label title("Appendix 2") mtitles("Small countries - Internal" "Small countries - International" "Middle countries - Internal" "Middle countries - International" "Large countries - Internal" "Large countries - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tg1 Tg2 Tg3 using "Revision IMR/RR/Countries size.rtf", eform unstack noomitted label title("Appendix 2") mtitles("Small countries - Internal" "Small countries - International" "Middle countries - Internal" "Middle countries - International" "Large countries - Internal" "Large countries - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 3: RATIO GTI
* Number of attacks in a given country and year divided by the sum of attacks in the country over the entire time span
qui mlogit migmulti ratioGTIa_byprov $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tu7
qui mlogit migmulti ratioGTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tu8
esttab Tu7 Tu8 using "Revision IMR/RR/Controls and GTI ratios.tex", eform unstack noomitted label title("Appendix 3") mtitles("ratioGTI_byprov - Internal" "ratioGTI_byprov - International" "ratioGTI - Internal" "ratioGTI - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tu7 Tu8 using "Revision IMR/RR/Controls and GTI ratios.rtf", eform unstack noomitted label title("Appendix 3") mtitles("ratioGTI_byprov - Internal" "ratioGTI_byprov - International" "ratioGTI - Internal" "ratioGTI - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 4: Interaction terms
qui mlogit migmulti age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y i.Partnership##c.GTIa, robust cluster(o) diff tech(nr dfp)
est sto Tr1
qui mlogit migmulti age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y i.ReligiousImportant##c.GTIa, robust cluster(o) diff tech(nr dfp)
est sto Tr2
qui mlogit migmulti age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y i.Native##c.GTIa, robust cluster(o) diff tech(nr dfp)
est sto Tr3
qui mlogit migmulti age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y i.hskill##c.GTIa, robust cluster(o) diff tech(nr dfp)
est sto Tr4
qui mlogit migmulti age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag i.o i.y i.urban##c.GTIa, robust cluster(o) diff tech(nr dfp)
est sto Tr5
esttab Tr1 Tr2 Tr3 Tr4 Tr5 using "Revision IMR/RR/interactions.tex", eform unstack noomitted label title("Appendix 4") mtitles("Partnership - Internal" "Partnership - International" "Religion - Internal" "Religion - International" "Natives - Internal" "Natives - International" "Hskill - Internal" "Hskill - International" "Urban - Internal" "Urban - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tr1 Tr2 Tr3 Tr4 Tr5 using "Revision IMR/RR/interactions.rtf", eform unstack noomitted label title("Appendix 4") mtitles("Partnership - Internal" "Partnership - International" "Religion - Internal" "Religion - International" "Natives - Internal" "Natives - International" "Hskill - Internal" "Hskill - International" "Urban - Internal" "Urban - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 5: Alternative household income variable
qui mlogit migmulti GTIa $controls_o_yFE lhhincpc, robust cluster(o) diff tech(nr dfp)
est sto Tu1
esttab Tu1 using "Revision IMR/RR/Alternative HHinc.tex", eform unstack noomitted label title("Appendix 5") mtitles("lhhincp - Internal" "lhhincp - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tu1 using "Revision IMR/RR/Alternative HHinc.rtf", eform unstack noomitted label title("Appendix 5") mtitles("lhhincp - Internal" "lhhincp - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 6: GTI intervals
summarize GTIa, detail
preserve
*drop if GTIa >= 3.652148 // <75% pctiles
*mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
*est sto Tw1
drop if GTIa < 3.652148 // 75% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw2
drop if GTIa < 5.567518 // 90% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw3
drop if GTIa < 6.542814 // 95% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw4
*preserve
*mlogit migmulti AboveAvg $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
*est sto Tp1
*esttab Tp1 using "Revision IMR/RR/GTI thresholds.tex", eform unstack noomitted label title("Appendix 6") mtitles("GTI intensity - Internal" "GTI intensity - International")
esttab Tw2 Tw3 Tw4 using "Revision IMR/RR/GTI thresholds - subsamples.tex", eform unstack noomitted label title("Appendix 6") mtitles("Below 75 - Internal" "Below 75 - International" "75 - Internal" "75 - International" "90 - Internal" "90 - International" "95 - Internal" "95 - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tw2 Tw3 Tw4 using "Revision IMR/RR/GTI thresholds - subsamples.rtf", eform unstack noomitted label title("Appendix 6") mtitles("Below 75 - Internal" "Below 75 - International" "75 - Internal" "75 - International" "90 - Internal" "90 - International" "95 - Internal" "95 - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
restore

summarize GTIa, detail
gen intensity1=1 if GTIa<=3.652148
replace intensity1=0 if GTIa>3.652148
gen intensity2=1 if GTIa>3.652148 & GTIa<=5.567518
replace intensity2=0 if GTIa<=3.652148 | GTIa>5.567518
gen intensity3=1 if GTIa>5.567518 & GTIa<=6.542814
replace intensity3=0 if GTIa<=5.567518 | GTIa>6.542814
gen intensity4=1 if GTIa>6.542814
replace intensity4=0 if GTIa<=6.542814
*drop if intensity1==1
*drop if intensity4==1
mlogit migmulti intensity2 intensity3 intensity4 $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp1
esttab Tp1 using "Revision IMR/RR/GTI thresholds - Intensity.tex", eform unstack noomitted label title("Appendix 6") mtitles("GTI intensity - Internal" "GTI intensity - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tp1 using "Revision IMR/RR/GTI thresholds - Intensity.rtf", eform unstack noomitted label title("Appendix 6") mtitles("GTI intensity - Internal" "GTI intensity - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

* APPENDIX TABLE 7: GTI time & indicators weights variations
* GTI for last 1 to 3 months
qui mlogit migmulti GTI_score_3m $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp1
* GTI for last 1 to 3 months & last 4 to 6 months
qui mlogit migmulti GTI_score_3m GTI_score_6m $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp2
* GTI for last 1 to 3 months & last 4 to 6 months & last 7 to 12 months
qui mlogit migmulti GTI_score_3m GTI_score_6m GTI_score_12m $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp3
* GTI for last year
qui mlogit migmulti GTI_score_lag1 $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp4
* GTI for last year & year before
qui mlogit migmulti GTI_score_lag1 GTI_score_lag2 $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp5
* GTI for last 5 years
qui mlogit migmulti GTI_score_lag1 GTI_score_lag2 GTI_score_lag3 GTI_score_lag4 GTI_score_lag5 $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp6
* GTI with equal weights on indicators
rename GTIa GTIc
rename GTIb GTIa
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tp7
rename GTIa GTIb
rename GTIc GTIa
esttab Tp1 Tp2 Tp3 Tp4 Tp5 Tp6 Tp7 using "Revision IMR/RR/GTI weights.tex", eform unstack noomitted label title("Appendix 7") mtitles("GTI3m - Internal" "GTI3m - International" "GTI3m \& GTI6m - Internal" "GTI3m \& GTI6m - International" "GTI3m \& GTI6m \& GTI12m - Internal" "GTI3m \& GTI6m \& GTI12m - International" "GTI1y - Internal" "GTI1y - International" "GTI1y \& GTI2y - Internal" "GTI1y \& GTI2y - International" "GTI5y - Internal" "GTI5y - International" "GTI no weight - Internal" "GTI no weight - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tp1 Tp2 Tp3 Tp4 Tp5 Tp6 Tp7 using "Revision IMR/RR/GTI weights.rtf", eform unstack noomitted label title("Appendix 7") mtitles("GTI3m - Internal" "GTI3m - International" "GTI3m \& GTI6m - Internal" "GTI3m \& GTI6m - International" "GTI3m \& GTI6m \& GTI12m - Internal" "GTI3m \& GTI6m \& GTI12m - International" "GTI1y - Internal" "GTI1y - International" "GTI1y \& GTI2y - Internal" "GTI1y \& GTI2y - International" "GTI5y - Internal" "GTI5y - International" "GTI no weight - Internal" "GTI no weight - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")






/*
gen RatioAttacks = TotalAttacksPCPY/TotalAttacks
gen RatioAttacksBis = TotalAttacksPCPY/TotalAttacks
replace RatioAttacksBis = 0 if TotalAttacks == 0
qui mlogit migmulti RatioAttacks $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tt1
qui mlogit migmulti RatioAttacksBis $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tt2
esttab Tt1 Tt2 using "Revision IMR/RR/Ratio attacks.tex", eform unstack noomitted label title("Baseline results") mtitles("RatioAttacks - Internal" "RatioAttacks - International" "RatioAttacksBis - Internal" "RatioAttacksBis - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

*qui mlogit migmulti GTIa $controls_o_yFE married, robust cluster(o) diff tech(nr dfp)
*est sto Tu1
*qui mlogit migmulti GTIa $controls_o_yFE BasicWealth, robust cluster(o) diff tech(nr dfp)
*est sto Tu3
*qui mlogit migmulti GTIa $controls_o_yFE relig, robust cluster(o) diff tech(nr dfp)
*est sto Tu4
*qui mlogit migmulti GTIa $controls_o_yFE native, robust cluster(o) diff tech(nr dfp)
*est sto Tu5
*qui mlogit migmulti GTIa $controls_o_yFE lhhincpc, robust cluster(o) diff tech(nr dfp)
*est sto Tu6
*/


********************************************************************************
********************************************************************************
********************************************************************************






*******************************
*** Table 1 - Benchmark results
*******************************

* Column 1&3
qui mlogit migmulti $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Ta1

* Column 2&4
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Ta2
esttab Ta1 Ta2 using "Results/Clean/Results clusteredo/Table 1 21122020.tex", eform unstack noomitted label title("Baseline results") mtitles("Controls only - Internal" "Controls only - International" "GTI - Internal" "GTI - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Ta1 Ta2 using "Results/Clean/Results clusteredo/Table 1 21122020.rtf", eform unstack noomitted label title("Baseline results") mtitles("Controls only - Internal" "Controls only - International" "GTI - Internal" "GTI - International") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

preserve
keep if e(sample)
save "Data\Esample database benchmark 21122020.dta", replace
restore

tab year if e(sample) // 2007 2015
/*
YEAR_CALEND |
AR Calendar |
       Year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2007 |      3,376        0.72        0.72
       2008 |     28,985        6.17        6.88
       2009 |     39,334        8.37       15.25
       2010 |     60,413       12.85       28.10
       2011 |     78,627       16.73       44.83
       2012 |     62,540       13.30       58.13
       2013 |     60,597       12.89       71.02
       2014 |     59,362       12.63       83.65
       2015 |     76,846       16.35      100.00
------------+-----------------------------------
      Total |    470,080      100.00
*/
tab origin if e(sample) // 133 countries

************************************************
*** Number of observations per country in sample
************************************************
preserve
keep if e(sample)
egen N_destyear = count(n), by (origin)
keep origin N_destyear
duplicates drop
*mean N_destyear
restore

margins, dydx(GTIa) post vce(unconditional) 
est store ME1

/*
Average marginal effects                        Number of obs     =    470,080

dy/dx w.r.t. : GTIa
1._predict   : Pr(migmulti==1), predict(pr outcome(1))
2._predict   : Pr(migmulti==2), predict(pr outcome(2))
3._predict   : Pr(migmulti==3), predict(pr outcome(3))

                                    (Std. Err. adjusted for 133 clusters in o)
------------------------------------------------------------------------------
             |            Unconditional
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
GTIa         |
    _predict |
          1  |  -.0023909   .0011653    -2.05   0.040    -.0046748   -.0001071
          2  |    .001742   .0010834     1.61   0.108    -.0003814    .0038655
          3  |   .0006489   .0002868     2.26   0.024     .0000867    .0012111
------------------------------------------------------------------------------
*/

sum GTIa
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        GTIa |    497,281    1.747241     2.41262          0   9.773398
*/

est resto Ta2
margins, at(GTIa=(0 1 2 3 4 5 6 7 8 9 10)) atmeans post
est store ME2
/*
------------------------------------------------------------------------------
             |            Delta-method
             |     Margin   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
_predict#_at |
       1  1  |   .8544026   .0017419   490.51   0.000     .8509886    .8578166
       1  2  |    .852495   .0007472  1140.88   0.000     .8510304    .8539595
       1  3  |   .8505662   .0004785  1777.53   0.000     .8496284    .8515041
       1  4  |   .8486163   .0014794   573.63   0.000     .8457168    .8515159
       1  5  |   .8466452    .002566   329.95   0.000     .8416159    .8516744
       1  6  |   .8446526   .0036835   229.31   0.000      .837433    .8518721
       1  7  |   .8426384   .0048266   174.58   0.000     .8331784    .8520984
       1  8  |   .8406026   .0059942   140.24   0.000     .8288543    .8523509
       1  9  |    .838545   .0071857   116.70   0.000     .8244612    .8526287
       1 10  |   .8364655   .0084012    99.56   0.000     .8199994    .8529315
       1 11  |   .8343639   .0096407    86.55   0.000     .8154686    .8532593
       2  1  |   .1442854   .0017364    83.09   0.000     .1408821    .1476887
       2  2  |   .1461506   .0007473   195.57   0.000     .1446859    .1476154
       2  3  |   .1480356   .0004709   314.38   0.000     .1471127    .1489585
       2  4  |   .1499404   .0014643   102.40   0.000     .1470704    .1528104
       2  5  |    .151865   .0025436    59.71   0.000     .1468797    .1568503
       2  6  |   .1538097   .0036532    42.10   0.000     .1466494    .1609699
       2  7  |   .1557743   .0047881    32.53   0.000     .1463898    .1651589
       2  8  |   .1577592   .0059469    26.53   0.000     .1461034    .1694149
       2  9  |   .1597642   .0071293    22.41   0.000      .145791    .1737373
       2 10  |   .1617894   .0083351    19.41   0.000     .1454529     .178126
       2 11  |   .1638351   .0095644    17.13   0.000     .1450892    .1825809
       3  1  |    .001312   .0000474    27.65   0.000      .001219     .001405
       3  2  |   .0013544   .0000424    31.95   0.000     .0012713    .0014375
       3  3  |   .0013982   .0000448    31.22   0.000     .0013104    .0014859
       3  4  |   .0014433   .0000549    26.29   0.000     .0013357    .0015509
       3  5  |   .0014898   .0000705    21.12   0.000     .0013516     .001628
       3  6  |   .0015378   .0000898    17.13   0.000     .0013618    .0017137
       3  7  |   .0015872   .0001116    14.22   0.000     .0013685     .001806
       3  8  |   .0016383   .0001356    12.08   0.000     .0013724    .0019041
       3  9  |   .0016909   .0001616    10.47   0.000     .0013742    .0020075
       3 10  |   .0017451   .0001894     9.22   0.000     .0013739    .0021163
       3 11  |    .001801    .000219     8.22   0.000     .0013718    .0022303
------------------------------------------------------------------------------
*/

*margins, atmeans post
/*------------------------------------------------------------------------------
             |            Delta-method
             |     Margin   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
    _predict |
          1  |   .8510397   .0003219  2643.52   0.000     .8504087    .8516707
          2  |    .147573   .0003175   464.77   0.000     .1469506    .1481953
          3  |   .0013873   .0000434    31.94   0.000     .0013022    .0014725
------------------------------------------------------------------------------
*/

*esttab Ta1 Ta2 using "Results/Clean/Results clusteredo/Table 1_without_lnhhincpc 21122020.tex", eform unstack noomitted label title("Baseline results") mtitles("Controls only - Internal" "Controls only - International" "GTI method A included - Internal" "GTI method A included - International") ///
*nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Coefficients must be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

esttab ME1 using "Results/Clean/Results clusteredo/Table 1_margins 21122020.tex", label title("Impact of terrorist attacks and traditional controls - Marginal effects") mtitles ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) nonumbers t(2)  nogaps scalars("ll Log likelihood" "chi2 Wald Chi$^2$" "df_m Dof" "p Prob > Chi$^2$") obslast addnotes("Standard errors are robust to heteroskedasticity and clustered across origins.")
esttab ME1 using "Results/Clean/Results clusteredo/Table 1_margins 21122020.rtf", label title("Impact of terrorist attacks and traditional controls - Marginal effects") mtitles ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) nonumbers t(2)  nogaps scalars("ll Log likelihood" "chi2 Wald Chi$^2$" "df_m Dof" "p Prob > Chi$^2$") obslast addnotes("Standard errors are robust to heteroskedasticity and clustered across origins.")

*esttab ME2 using "Revision IMR/RR/Tables/Margins.rtf", label title("Impact of terrorist attacks and traditional controls - Marginal effects") mtitles("Margin" "Std. Err." "Z-score" "P-value" "95% conf int") ///
*nodepvars replace star(* 0.10 ** 0.05 *** 0.01) nonumbers t(2)  nogaps scalars("ll Log likelihood" "chi2 Wald Chi$^2$" "df_m Dof" "p Prob > Chi$^2$") obslast addnotes("Standard errors are robust to heteroskedasticity and clustered across origins.")

*** Is a one unit increase in GTIa reasonable? We should check for regions where this was the case
est restore Ta2
sum GTIa if e(sample)
/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
        GTIa |    470,080     1.71338    2.384776          0   9.773398
*/

*******************************
*** Descriptive statistics from benchmark sample
*******************************
*** Summary statistics
est restore Ta2
estpost sum migmulti GTIa age2029 age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag if e(sample)==1
esttab using "Results/Clean/Results clusteredo/DescrStats 21122020.tex", cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nomtitle nonumber replace label
esttab using "Results/Clean/Results clusteredo/DescrStats 21122020.rtf", cells("count(fmt(0)) mean(fmt(3)) sd(fmt(3)) min(fmt(0)) max(fmt(0))") nomtitle nonumber replace label

*** Pairwise correlations
est restore Ta2
estpost corr migmulti GTIa age2029 age3039 age4049 male hskill urban Native ReligiousImportant children adults Partnership BasicWealth mabr closesocialnetwork1 lnGDPpc_lag ln_GDPpc_cent_sq polity2_lag WarOccurrence_lag PolInstab3y_lag if e(sample), matrix  
esttab . using "Results/Clean/Results clusteredo/Pwcorr 21122020.tex", not unstack compress noobs replace booktabs page label b(3)
esttab . using "Results/Clean/Results clusteredo/Pwcorr 21122020.rtf", not unstack compress noobs replace booktabs page label b(3)
esttab . using "Results/Clean/Results clusteredo/Pwcorr 21122020.xls", not unstack compress noobs replace booktabs page label b(3)

***Try with regional FE
*egen regionID = group(ID_GADM_fine)
*mlogit migmulti GTIa $controls_o_yFE i.regionID, robust cluster(o) diff tech(nr dfp)

*******************************
*** Table 2 - Robustness of the data
*******************************
* Drop ambiguous data
preserve
drop if terrorunkn==1
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
* Warning: variance matrix is nonsymmetric or highly singular
est sto Tg1
restore

// ADDED BY ILSE 16/12/2020: This typically happens when there are clusters with only a few observations
tab origin if e(sample) // Check which country has very few observations --> Jamaica has only 75. We could set the treshold to 100 for instance and then this means Jamaica would get dropped
mlogit migmulti GTIa $controls_o_yFE if terrorunkn!=1 & origin!="Jamaica", robust cluster(o) diff tech(nr dfp)
est sto Tg1

* Drop if conflict at some point in the country
tab origin if WarOccurrence_lag == 1
/*

                COUNTRYNEW Country Name |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Algeria |      3,112        2.50        2.50
                             Azerbaijan |      1,008        0.81        3.31
                             Bangladesh |        868        0.70        4.00
                                Burundi |        752        0.60        4.61
                               Cambodia |        704        0.57        5.17
               Central African Republic |      1,623        1.30        6.48
                                   Chad |      3,295        2.64        9.12
                                  China |      2,174        1.74       10.86
                               Colombia |      3,705        2.97       13.84
       Democratic Republic of the Congo |      3,432        2.75       16.59
                                  Egypt |        679        0.55       17.14
                               Ethiopia |      2,426        1.95       19.09
                                Georgia |        483        0.39       19.47
                                  India |     23,329       18.73       38.20
                                   Iran |        997        0.80       39.00
                                   Iraq |      2,924        2.35       41.35
                                 Israel |      4,337        3.48       44.83
                                Lebanon |        745        0.60       45.42
                                  Libya |      1,521        1.22       46.65
                                   Mali |      4,479        3.60       50.24
                             Mauritania |      2,445        1.96       52.20
                                Myanmar |      2,541        2.04       54.24
                                  Niger |      1,515        1.22       55.46
                                Nigeria |      4,713        3.78       59.24
                               Pakistan |      5,408        4.34       63.58
                                   Peru |      1,087        0.87       64.46
                                 Russia |      9,479        7.61       72.06
                                 Rwanda |        162        0.13       72.19
                                Senegal |        802        0.64       72.84
                                Somalia |      4,622        3.71       76.55
                            South Sudan |      1,555        1.25       77.80
                              Sri Lanka |      1,969        1.58       79.38
                                  Sudan |      4,193        3.37       82.74
                                  Syria |      2,008        1.61       84.35
                             Tajikistan |      1,483        1.19       85.54
                               Thailand |      5,672        4.55       90.10
                                 Turkey |      5,247        4.21       94.31
                                Ukraine |        513        0.41       94.72
                          United States |      1,104        0.89       95.61
                                  Yemen |      5,475        4.39      100.00
----------------------------------------+-----------------------------------
                                  Total |    124,586      100.00
*/

preserve
drop if WarOccurrence_lag==1
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tg2
restore

* Add a possible non-linear effect
*gen GTIa_sq = GTIa*GTIa
*mlogit migmulti GTIa GTIa_sq $controls_o_yFE, robust cluster(o)
*est sto Tg3
// interpretation: linear relation for international mig odds ratio, non-linear for internal odds ratio. -b/2a=0.41594, means that until 0.41594 odds ratio of internal mig decreases as GTI increases. After that, increases non-linearly.
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1440566-statistically-significant-squared-term-but-insignificant-level-term
// https://www.statalist.org/forums/forum/general-stata-discussion/general/1408413-significance-level-of-quadratic-term
// https://www.statalist.org/forums/forum/general-stata-discussion/general/294061-stata-gives-error-msessage-after-nlcomb

*** Note Ilse: when adding the square term, GTIa is no longer significant (and neither is its square term). The reason is multicollinearity which is 
*** structurally introduced. Pairwise correlation between GTI and its square is 0.9474. Advise found online is to center the original variable and then
*** take the square of that centered variable which will significantly reduce their correlation. Indeed doing that (as below) preserves the significant effect
*** of GTIa while the squared term remains insignificant (good news cause then we can go on without it!)

/* ADDED BY ILSE 16/12/2020
gen GTIa_sq = GTIa*GTIa
pwcorr GTIa GTIa_sq

             |     GTIa  GTIa_sq
-------------+------------------
        GTIa |   1.0000 
     GTIa_sq |   0.9482   1.0000 
*/
// Reference: https://www.theanalysisfactor.com/centering-for-multicollinearity-between-main-effects-and-interaction-terms/

** Instead try with a centered GTI:
sum GTIa // mean is 1.747234
gen GTIaCen=GTIa- 1.747234
gen GTIaCen_sq = GTIaCen*GTIaCen
qui mlogit migmulti GTIaCen GTIaCen_sq $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tg3

*esttab Tg1 Tg2 Tg3 using "Results/Clean/Results clusteredo/Table 2 21122020.tex", unstack noomitted eform label title("Exclusion of ambiguous data, countries in conflict, and adding a non-linear effect") mtitles("Ambiguous data dropped" "Countries with conflict dropped" "Non-linear effect") ///
*nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

esttab Tg1 Tg2 Tg3 using "Results/Clean/Results clusteredo/Table 2 21122020.tex", unstack noomitted eform label title("Exclusion of ambiguous data, countries in conflict, and adding a non-linear effect") mtitles("Ambiguous data dropped" "Countries with conflict dropped" "Non-linear effect") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tg1 Tg2 Tg3 using "Results/Clean/Results clusteredo/Table 2 21122020.rtf", unstack noomitted eform label title("Exclusion of ambiguous data, countries in conflict, and adding a non-linear effect") mtitles("Ambiguous data dropped" "Countries with conflict dropped" "Non-linear effect") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")


*******************************
*** Table 3 - Redefining the variable of interest
*******************************
rename GTIa GTIaoriginal

* Terror Occurrence
rename AttackOccurrence GTIa
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tf2
rename GTIa AttackOccurrence

* Attacks index
rename AttacksIndexA GTIa
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tf3
rename GTIa AttacksIndexA

* Victims
rename VictimsIndexA GTIa
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tf4
rename GTIa VictimsIndexA

* Bombings
rename BombingIndexA GTIa
qui mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tf5
rename GTIa BombingIndexA

esttab Tf2 Tf3 Tf4 Tf5 using "Results/Clean/Results clusteredo/Table 3 21122020.tex", unstack noomitted eform label title("Redefining the variable of interest") mtitles("Occurrence of attack" "Index of attacks" "Index of victims" "Index of bombings") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tf2 Tf3 Tf4 Tf5 using "Results/Clean/Results clusteredo/Table 3 21122020.rtf", unstack noomitted eform label title("Redefining the variable of interest") mtitles("Occurrence of attack" "Index of attacks" "Index of victims" "Index of bombings") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")

rename GTIaoriginal GTIa

/*
*******************************
*** Table 4a - Interaction terms (individual/HH characteristics) --> NOT REPORTED IN THE PAPER!!!
*******************************
* Non-natives
gen Inter_nonnative = GTIa * nonnative
//Before was: qui mlogit migmulti c.GTIa##nonnative $controls_o_yFE, robust cluster(o)
 mlogit migmulti GTIa nonnative Inter_nonnative $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tb1

* High skilled individuals
gen Inter_hskill = GTIa * hskill
//Before was: qui mlogit migmulti c.GTIa##hskill $controls_o_yFE, robust cluster(o)
qui mlogit migmulti GTIa Inter_hskill $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tb2

* Urban individual
gen Inter_urban = GTIa * urban
//Before was: qui mlogit migmulti c.GTIa##urban $controls_o_yFE, robust cluster(o)
 mlogit migmulti GTIa Inter_urban $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tb3

* Number of attacks x being religious
gen Inter_relig = GTIa * relig
//Before was: qui mlogit migmulti c.GTIa##relig $controls_o_yFE, robust cluster(o)
 mlogit migmulti GTIa relig Inter_relig $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tb4

* Index on attacks against religious institutions x being religious
gen Inter_TargetRelig = TargReligIndexA * relig
//Before was: qui mlogit migmulti c.TargReligIndexA##relig $controls_o_yFE, robust cluster(o)
 mlogit migmulti GTIa relig TargReligIndexA Inter_TargetRelig $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tb5

esttab Tb1 Tb2 Tb3 Tb4 Tb5 using "Results/Clean/Results clusteredo/Table 4 (interactions).tex", unstack noomitted eform label title("Different individual & households characteristics") mtitles("Non-natives only" "High skilled only" "Urban individual only" "Number of attack when religious" "Index of attacks against religion when religious") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
*/





















*******************************
*** Table 4b - Subsamples (individual/HH characteristics)
*******************************
* Natives
qui mlogit migmulti GTIa $controls_o_yFE if nonnative==1, robust cluster(o) diff tech(dfp bfgs) iter(200) // Note: 30 observations completely determined.  Standard errors questionable.
est sto Tb1

**Note: coefficient is relatively larger and more significant so I thought this would be reflected in the ME but this is not the case (only 0.003 now instead of 0.001)
/* margins, dydx(GTIa) post vce(unconditional)
Average marginal effects                        Number of obs     =     19,688

dy/dx w.r.t. : GTIa
1._predict   : Pr(migmulti==1), predict(pr outcome(1))
2._predict   : Pr(migmulti==2), predict(pr outcome(2))
3._predict   : Pr(migmulti==3), predict(pr outcome(3))

                                    (Std. Err. adjusted for 131 clusters in o)
------------------------------------------------------------------------------
             |            Unconditional
             |      dy/dx   Std. Err.      z    P>|z|     [95% Conf. Interval]
-------------+----------------------------------------------------------------
GTIa         |
    _predict |
          1  |  -.0064389   .0028121    -2.29   0.022    -.0119506   -.0009272
          2  |   .0030046    .003087     0.97   0.330    -.0030457     .009055
          3  |   .0034343   .0010664     3.22   0.001     .0013442    .0055244
------------------------------------------------------------------------------
*/

* High skilled individuals
qui mlogit migmulti GTIa $controls_o_yFE if hskill==1 , robust cluster(o) difficult tech(nr dfp)
/*
*** Create separate dependents: either internal versus staying/international; and international versus staying/internal
gen internal = 0
replace internal = 1 if migmulti == 2
gen internat = 0
replace internat = 1 if migmulti == 3
*** Create separate dependents: either internal versus staying only; and international versus staying only
gen internalb = .
replace internalb = 0 if migmulti == 1
replace internalb = 1 if migmulti == 2
gen internatb = .
replace internatb = 0 if migmulti == 1
replace internatb = 1 if migmulti == 3

logit internal GTIa $controls_o_yFE if hskill==1 , robust cluster(o) difficult
logit internat GTIa $controls_o_yFE if hskill==1 , robust cluster(o) difficult

logit internalb GTIa $controls_o_yFE if hskill==1 , robust cluster(o) 
logit internatb GTIa $controls_o_yFE if hskill==1 , robust cluster(o) diff tech(dfp nr)
*/
est sto Tb2

* Urban individual
mlogit migmulti GTIa $controls_o_yFE if urban==1, robust cluster(o)  difficult tech(bhhh bfgs) iter(200)
est sto Tb3

* Religious people
 mlogit migmulti GTIa $controls_o_yFE if relig==1, robust cluster(o)  difficult tech(nr dfp)
est sto Tb4

* Index on attacks against religious institutions x being religious
//Before was: qui mlogit migmulti c.TargReligIndexA##relig $controls_o_yFE, robust cluster(o)
mlogit migmulti TargReligIndexA $controls_o_yFE if relig==1, robust cluster(o)  difficult tech(nr dfp)
est sto Tb5

label variable nonnative "Non-native"
label variable relig "Religious"
label variable TargReligIndexA "Attack relig"

esttab Tb1 Tb2 Tb3 Tb4 using "Results/Clean/Results clusteredo/Table 4_check 21122020.tex", unstack noomitted eform label title("Different individual & households characteristics") mtitles("Non-natives only" "High skilled only" "Urban individual only" "Number of attack when religious" "Index of attacks against religion when religious") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
esttab Tb1 Tb2 Tb3 Tb4 using "Results/Clean/Results clusteredo/Table 4_check 21122020.rtf", unstack noomitted eform label title("Different individual & households characteristics") mtitles("Non-natives only" "High skilled only" "Urban individual only" "Number of attack when religious" "Index of attacks against religion when religious") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")


/*
***
*** Table 5 - By subsamples (Development levels) --> NOT REPORTED IN THE PAPER
***

* Low income countries
qui mlogit migmulti GTIa $controls_o_yFE if (GNIpc<=LowIncome), robust cluster(o) diff tech(nr dfp)
est sto Tc1

* Lower middle income countries
qui mlogit migmulti GTIa $controls_o_yFE if (LowIncome<GNIpc & GNIpc<=LowerMiddleIncome), robust cluster(o) diff tech(nr dfp)
est sto Tc2

* Upper middle income countries
qui mlogit migmulti GTIa $controls_o_yFE if (LowerMiddleIncome<GNIpc & GNIpc<=UpperMiddleIncome), robust cluster(o) diff tech(nr dfp)
est sto Tc3

* High income countries
preserve
keep if GNIpc!=.
qui mlogit migmulti GTIa $controls_o_yFE if (GNIpc>UpperMiddleIncome), robust cluster(o)  diff tech(nr dfp)
est sto Tc4
restore

esttab Tc1 Tc2 Tc3 Tc4 using "Results/Clean/Results clusteredo/Table 5.tex", unstack noomitted eform label title("Countries levels of development") mtitles("Low income" "Low mid income" "Mid high income" "High income") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("Results can be interpreted as relative risk ratios. Countries of origin and year fixed effect. Standard errors are robust to heteroscedasticity.")
*/

********************************************************************************
*************************** BONUS GTI THRESHOLDS *******************************
********************************************************************************
/*
est restore Ta2
summarize GTIa, detail
drop if GTIa < 3.620896 // 75% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw1
drop if GTIa < 5.561309 // 90% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw2
drop if GTIa < 6.542814 // 95% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw3
drop if GTIa < 8.174761 // 99% percentiles
mlogit migmulti GTIa $controls_o_yFE, robust cluster(o) diff tech(nr dfp)
est sto Tw4

esttab Tw1 Tw2 Tw3 Tw4 using "Results/Clean/Results clusteredo/Table thresholds.tex", label title("Thresholds GTI") mtitles("75" "90" "95" "99") ///
nodepvars replace star(* 0.10 ** 0.05 *** 0.01) drop(*.o *.y) nonumbers t(2) b(3) nogaps obslast addnotes("\textit{t} statistics in parentheses. \sym{*}, \sym{**}, and \sym{***}, denote significance at the 90, 95, and 99 percent confidence level, respectively. Standard errors are robust to heteroskedasticity.") // APPENDIX

