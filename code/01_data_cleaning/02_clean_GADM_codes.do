********************************************************************************
* 02 - Clean GADM Region Codes
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Cleans GADM level-1 administrative region codes and harmonises country names for merging with GWP and GTD data.
*
* Input:   GADM base codes raw.dta
*
* Output:  GADM cleaned region codes
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

cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\"
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"
use "GADM\GADM\GADM base codes raw.dta"

keep NAME_1 ISO ID_1 NAME_0
rename NAME_0 Origin
merge m:1 Origin using "iso3 codes/country code.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                        11,768
        from master                    11,705  (_merge==1)
        from using                         63  (_merge==2)

    matched                           243,567  (_merge==3)
    -----------------------------------------
*/

replace iso3="AIA" if Origin=="Anguilla"
replace iso3="ATA" if Origin=="Antarctica"
replace iso3="BES" if Origin=="Bonaire, Sint Eustatius and Saba"
replace iso3="BVT" if Origin=="Bouvet Island"
replace iso3="IOT" if Origin=="British Indian Ocean Territory"
replace iso3="BRN" if Origin=="Brunei"
replace iso3="CXR" if Origin=="Christmas Island"
replace iso3="CPT" if Origin=="Clipperton Island"
replace iso3="CCK" if Origin=="Cocos Islands"
replace iso3="COK" if Origin=="Cook Islands"
replace iso3="CUW" if Origin=="Curaçao"
replace iso3="FLK" if Origin=="Falkland Islands"
replace iso3="GUF" if Origin=="French Guiana"
replace iso3="GLP" if Origin=="Guadeloupe"
replace iso3="GGY" if Origin=="Guernsey"
replace iso3="HKG" if Origin=="Hong Kong"
replace iso3="JEY" if Origin=="Jersey"
replace iso3="MAC" if Origin=="Macao"
replace iso3="MTQ" if Origin=="Martinique"
replace iso3="MYT" if Origin=="Mayotte"
replace iso3="MSR" if Origin=="Montserrat"
replace iso3="NIU" if Origin=="Niue"
replace iso3="NFK" if Origin=="Norfolk Island"
replace iso3="PRK" if Origin=="North Korea"
replace iso3="PSE" if Origin=="Palestina"
replace iso3="PCN" if Origin=="Pitcairn Islands"
replace iso3="COG" if Origin=="Republic of Congo"
replace iso3="REU" if Origin=="Reunion"
replace iso3="KNA" if Origin=="Saint Kitts and Nevis"
replace iso3="SPM" if Origin=="Saint Pierre and Miquelon"
replace iso3="BLM" if Origin=="Saint-Barthélemy"
replace iso3="MAF" if Origin=="Saint-Martin"
replace iso3="SXM" if Origin=="Sint Maarten"
replace iso3="SVK" if Origin=="Slovakia"
replace iso3="SGS" if Origin=="South Georgia and the South Sandwich Islands"
replace iso3="KOR" if Origin=="South Korea"
replace iso3="SJM" if Origin=="Svalbard and Jan Mayen"
replace iso3="STP" if Origin=="São Tomé and Príncipe"
replace iso3="TKL" if Origin=="Tokelau"
replace iso3="UMI" if Origin=="United States Minor Outlying Islands"
replace iso3="VAT" if Origin=="Vatican City"
replace iso3="VNM" if Origin=="Vietnam"
replace iso3="VIR" if Origin=="Virgin Islands, U.S."
replace iso3="WLF" if Origin=="Wallis and Futuna"
replace iso3="ESH" if Origin=="Western Sahara"
replace iso3="ALA" if Origin=="Åland"

drop if _merge==1 & iso3==""
drop if _merge==2
drop _merge 

drop ISO
rename NAME_1 provstate
sort iso3 provstate
duplicates drop

save "GADM\GADM\GADM ready to be merged with GTD-GWP", replace
