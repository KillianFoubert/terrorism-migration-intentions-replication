********************************************************************************
* 01 - Clean ISO3 Country Codes
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Harmonises ISO3 codes for use as merge keys across datasets.
*
* Input:   iso3.dta
*
* Output:  iso3clean.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

cd "D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\" // Fix PC Killian
*cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\" // Laptop Killian
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/iso3 codes/Clean/"

use "iso3.dta", clear
drop id
rename NAME_0 origin
rename GID_0 iso3o
save "iso3clean.dta", replace
