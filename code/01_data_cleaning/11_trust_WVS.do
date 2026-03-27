********************************************************************************
* 11 - Trust Index (World Values Survey)
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Constructs a generalised trust index from the World Values Survey longitudinal data.
*
* Input:   WVS_Longitudinal_1981_2014_stata_v2015.dta
*
* Output:  Trust.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

*cd "D:\Dropbox\PhD Killian\Paper II\Data\"
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\"
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "Trust WVS/Clean/dta/WVS_Longitudinal_1981_2014_stata_v2015.dta", clear

keep S002 S003 A165

decode S002, gen(string_version_S002)
drop S002
rename string_version_S002 year

decode S003, gen(string_version_S003)
drop S003
rename string_version_S003 origin

decode A165, gen(string_version_A165)
replace string_version_A165="0" if string_version_A165=="Can´t be too careful"
replace string_version_A165="1" if string_version_A165=="Most people can be trusted"
replace string_version_A165="999" if string_version_A165=="Don´t know"
replace string_version_A165="999" if string_version_A165=="No answer"
replace string_version_A165="999" if string_version_A165=="Missing; Unknown"
replace string_version_A165="999" if string_version_A165=="Not asked in survey"
destring string_version_A165, gen(corrected_A165)
drop string_version_A165
des corrected_A165
summ corrected_A165
replace corrected_A165=. if corrected_A165==999
rename corrected_A165 Trust
drop A165
egen Trust_avg=mean(Trust), by(origin year)
label variable Trust_avg "Average A165 by origin wave: most people can be trusted"
drop Trust

drop if year=="1999-2004" | year=="1994-1998" | year=="1989-1993" | year=="1981-1984"
duplicates drop 

preserve
keep if year=="2005-2009"
replace year="2006"
save "Trust WVS/Clean/dta/steps/2006", replace
restore

preserve
keep if year=="2005-2009"
replace year="2007"
save "Trust WVS/Clean/dta/steps/2007", replace
restore

preserve
keep if year=="2005-2009"
replace year="2008"
save "Trust WVS/Clean/dta/steps/2008", replace
restore

preserve
keep if year=="2005-2009"
replace year="2009"
save "Trust WVS/Clean/dta/steps/2009", replace
restore

preserve
keep if year=="2010-2014"
replace year="2010"
save "Trust WVS/Clean/dta/steps/2010", replace
restore

preserve
keep if year=="2010-2014"
replace year="2011"
save "Trust WVS/Clean/dta/steps/2011", replace
restore

preserve
keep if year=="2010-2014"
replace year="2012"
save "Trust WVS/Clean/dta/steps/2012", replace
restore

preserve
keep if year=="2010-2014"
replace year="2013"
save "Trust WVS/Clean/dta/steps/2013", replace
restore

preserve
keep if year=="2010-2014"
replace year="2014"
save "Trust WVS/Clean/dta/steps/2014", replace
restore

***

clear
cls 
clear all 
set more off 
set scrollbufsize 500000 
set maxvar 10000
graph drop _all 
capture log close 
set matsize 11000

*cd "D:\Dropbox\PhD Killian\Paper II\Data\"
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\"
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "Trust WVS/Clean/dta/steps/2006.dta", clear

append using "Trust WVS/Clean/dta/steps/2007.dta"
append using "Trust WVS/Clean/dta/steps/2008.dta"
append using "Trust WVS/Clean/dta/steps/2009.dta"
append using "Trust WVS/Clean/dta/steps/2010.dta"
append using "Trust WVS/Clean/dta/steps/2011.dta"
append using "Trust WVS/Clean/dta/steps/2012.dta"
append using "Trust WVS/Clean/dta/steps/2013.dta"
append using "Trust WVS/Clean/dta/steps/2014.dta"

destring year, replace

sort year
by year: egen Trust_p10 = pctile(Trust_avg), p(10)
by year: egen Trust_p25 = pctile(Trust_avg), p(25)
by year: egen Trust_p50 = pctile(Trust_avg), p(50)
by year: egen Trust_p75 = pctile(Trust_avg), p(75)
by year: egen Trust_p90 = pctile(Trust_avg), p(90)

replace year=year+1

replace origin="United Kingdom" if origin=="Great Britain"
replace origin="Palestina" if origin=="Palestine"
replace origin="Vietnam" if origin=="Viet Nam"

merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           181
        from master                         4  (_merge==1)
        from using                        177  (_merge==2)

    matched                               528  (_merge==3)
    -----------------------------------------
*/

replace iso3="SCG" if origin=="Serbia and Montenegro"

drop if _merge==2
drop _merge origin

save "Trust WVS/Clean/dta/Trust.dta", replace
