********************************************************************************
* 09 - Armed Conflicts (UCDP/PRIO)
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Cleans the UCDP/PRIO Armed Conflict Dataset. Constructs conflict occurrence dummy (1000+ battle deaths) at the country-year level.
*
* Input:   ucdp-prio-acd-181.dta
*
* Output:  Occurrence of conflict.dta
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

*cd "D:\Dropbox\PhD Killian\Paper II\Data\" // Fix PC Killian
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\" // Laptop Killian
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "Conflicts/Clean/Dta/ucdp-prio-acd-181.dta"

drop if year < 2000
drop if year > 2015
keep location territory_name side_a side_a_2nd side_b side_b_2nd incompatibility year intensity_level cumulative_intensity type_of_conflict
rename location Origin

tostring year, replace

**************************************************************************************
*** Rearrange data on conflicts -> attribute them to the territory where it took place
**************************************************************************************

replace Origin="Myanmar" if Origin=="Myanmar (Burma)"
replace Origin="Yemen" if Origin=="Yemen (North Yemen)"
replace Origin="Democratic Republic of the Congo" if Origin=="DR Congo (Zaire)"
replace Origin="Russia" if Origin=="Russia (Soviet Union)"
replace Origin="United States" if Origin=="United States of America"
replace Origin="Sudan" if Origin=="South Sudan, Sudan"
replace Origin="Côte d'Ivoire" if Origin=="Ivory Coast"

order Origin year intensity_level
sort Origin year
rename Origin origin
// We use Dreher methodology here
gen WarOccurrence_low = 1 if intensity_level == 1
replace WarOccurrence_low = 0 if WarOccurrence_low == .
gen WarOccurrence_high = 1 if intensity_level == 2
replace WarOccurrence_high = 0 if WarOccurrence_high == .

collapse (max) WarOccurrence_low WarOccurrence_high, by(origin year)
replace WarOccurrence_low = 0 if WarOccurrence_high == 1
gen WarOccurrence = 1

* Merge with iso3 codes
merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"


/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           211
        from master                         4  (_merge==1)
        from using                        207  (_merge==2)

    matched                               269  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
expand 2 if _merge==1
sort origin year
quietly by origin year:  gen dup = cond(_N==1,0,_n)

replace iso3="KHM" if origin=="Cambodia (Kampuchea), Thailand" & dup==1
replace iso3="THA" if origin=="Cambodia (Kampuchea), Thailand" & dup==2
replace iso3="DJI" if origin=="Djibouti, Eritrea" & dup==1
replace iso3="ERI" if origin=="Djibouti, Eritrea" & dup==2
replace iso3="IND" if origin=="India, Pakistan" & dup==1
replace iso3="PAK" if origin=="India, Pakistan" & dup==2

drop origin _merge dup
sort iso3o year
order iso3o year

collapse (max) WarOccurrence_low WarOccurrence_high WarOccurrence, by(iso3o year)

destring year, replace

/////////
egen country = group(iso3o)
egen time = group(year)
order country year
sort country time
tsset country time
tsfill, full
* If we assume that there is no measurement error and all the conflicts are recorded
bysort time: carryforward year, gen(yearn)
bysort country: carryforward iso3o, gen(iso3on)
drop year iso3o
gsort country - time
bysort time: carryforward yearn, gen(yearnn)
bysort country: carryforward iso3on, gen(iso3onn)
drop yearn iso3on
sort country - time
bysort time: carryforward yearnn, gen(yearnnn)
bysort country: carryforward iso3onn, gen(iso3onnn)
drop yearnn iso3onn
gsort country - time
bysort time: carryforward yearnnn, gen(yearnnnn)
bysort country: carryforward iso3onnn, gen(iso3onnnn)
drop yearnnn iso3onnn
sort country - time
bysort time: carryforward yearnnnn, gen(yearnnnnn)
bysort country: carryforward iso3onnnn, gen(iso3onnnnn)
drop yearnnnn iso3onnnn

rename yearnnnnn year
rename iso3onnnnn iso3o

replace WarOccurrence_low=0 if WarOccurrence_low==.
replace WarOccurrence_high=0 if WarOccurrence_high==.
replace WarOccurrence=0 if WarOccurrence==.

order iso3o year
sort country time

forval i = 1/5 {  
gen WarOccurrence_low`i'=L`i'.WarOccurrence_low
gen WarOccurrence_high`i'=L`i'.WarOccurrence_high
gen WarOccurrence`i'=L`i'.WarOccurrence
}

gen WarOccurrence5y=1 if WarOccurrence1==1 | WarOccurrence2==1 | WarOccurrence3==1 | WarOccurrence4==1 | WarOccurrence5==1
replace WarOccurrence5y=0 if WarOccurrence5y==.

gen WarOccurrence_high5y=1 if WarOccurrence_high1==1 | WarOccurrence_high2==1 | WarOccurrence_high3==1 | WarOccurrence_high4==1 | WarOccurrence_high5==1
replace WarOccurrence_high5y=0 if WarOccurrence_high5y==.

gen WarOccurrence_low5y=1 if WarOccurrence_low1==1 | WarOccurrence_low2==1 | WarOccurrence_low3==1 | WarOccurrence_low4==1 | WarOccurrence_low5==1
replace WarOccurrence_low5y=0 if WarOccurrence_low5y==.

drop country time
/////////

*replace year = year+1
drop if year<2005

save "Conflicts/Clean/Dta/Occurrence of conflict", replace

drop if iso3o==""
