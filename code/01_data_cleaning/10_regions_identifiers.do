********************************************************************************
* 10 - World Region Classification
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Assigns countries to world regions and subregions (Europe, SSA, Middle East, etc.) for heterogeneity analysis.
*
* Input:   Base GWP origin region.dta
*
* Output:  Regions identifiers.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

clear all
*cd "D:\Dropbox\PhD Killian\Paper II\Data\" // Fix PC Killian
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\" // Laptop Killian
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "Regions identifiers/dta/Base GWP origin region.dta", clear 

gen region="Europe" if REG_GLOBAL==1
replace region="Europe" if REG_GLOBAL==3
replace region="Sovietic" if REG_GLOBAL==4
replace region="Oceania" if REG_GLOBAL==5
replace region="South-East Asia" if REG_GLOBAL==6
replace region="South Asia" if REG_GLOBAL==7
replace region="East Asia" if REG_GLOBAL==8
replace region="Latin America" if REG_GLOBAL==9
replace region="North America" if REG_GLOBAL==10
replace region="Middle East" if REG_GLOBAL==11
replace region="Sub-Saharan Africa" if REG_GLOBAL==12
replace region="Sub-Saharan Africa" if origin=="Democratic Republic of the Congo"
replace region="Sub-Saharan Africa" if origin=="Republic of Congo"
drop if REG_GLOBAL==.

gen subregion="Caribbean" if origin=="Guyana" | origin=="Honduras" | origin=="Suriname" | origin=="Jamaica" | origin=="Cuba" | origin=="Colombia" | origin=="Venezuela" | origin=="Costa Rica" | origin=="Haiti" | origin=="Panama" | origin=="Nicaragua" | origin=="Belize" | origin=="Puerto Rico" | origin=="Guatemala" | origin=="Trinidad and Tobago" | origin=="Dominican Republic"
replace subregion="Central America" if origin=="Mexico" | origin=="Honduras" | origin=="Guatemala" | origin=="Belize" | origin=="Honduras" | origin=="El Salvador" | origin=="Nicaragua" | origin=="Costa Rica" | origin=="Panama"
replace subregion="South America" if origin=="Argentina" | origin=="Bolivia" | origin=="Brazil" | origin=="Chile" | origin=="Colombia" | origin=="Ecuador" | origin=="Guyana" | origin=="Paraguay" | origin=="Peru" | origin=="Suriname" | origin=="Uruguay" | origin=="Venezuela"

replace subregion="Eastern Africa" if origin=="Somaliland" | origin=="Sudan" | origin=="Ethiopia" | origin=="Djibouti" | origin=="Somalia" | origin=="South Sudan" | origin=="Kenya" | origin=="Tanzania" | origin=="Rwanda" | origin=="Burundi" | origin=="Comoros" | origin=="Mauritius" | origin=="Malawi"
replace subregion="Middle Africa" if origin=="Angola" | origin=="Uganda" | origin=="Cameroon" | origin=="Gabon" | origin=="Guinea" | origin=="Central African Republic" | origin=="Congo Kinshasa" | origin=="Congo Brazzaville" | origin=="Chad"
replace subregion="Nothern Africa" if origin=="Algeria" | origin=="Egypt" | origin=="Libya" | origin=="Morocco" | origin=="Tunisia"
replace subregion="Southern Africa" if origin=="Botswana" | origin=="Swaziland" | origin=="Lesotho" | origin=="Madagascar" | origin=="Mozambique" | origin=="Namibia" | origin=="South Africa" | origin=="Tanzania" | origin=="Zambia" | origin=="Zimbabwe"
replace subregion="Western Africa" if origin=="Benin" | origin=="Burkina Faso" | origin=="Ivory Coast" | origin=="Ghana" | origin=="Guinea" | origin=="Liberia" | origin=="Mali" | origin=="Mauritania" | origin=="Niger" | origin=="Nigeria" | origin=="Senegal" | origin=="Sierra Leone" | origin=="Togo"

replace subregion="Northern America" if region=="North America"

replace subregion="Central Asia" if origin=="Uzbekistan" | origin=="Kazakhstan" | origin=="Kyrgyzstan" | origin=="Tajikistan" | origin=="Turkmenistan"
replace subregion="Eastern Asia" if region=="East Asia"
replace subregion="South-Eastern Asia" if region=="South-East Asia"
replace subregion="South Asia" if region=="South Asia"
replace subregion="Western Asia" if origin=="Turkey" | origin=="Georgia" | origin=="Armenia" | origin=="Azerbaijan" | origin=="Iran" | origin=="Syria" | origin=="Lebanon" | origin=="Israel" | origin=="Palestine" | origin=="Iraq" | origin=="Saudi Arabia" | origin=="Kuwait" | origin=="Bahrain" | origin=="Qatar" | origin=="United Arab Emirates" | origin=="Oman" | origin=="Yemen" | origin=="Jordan" | origin=="Nagorno Karabakh"

replace subregion="Australia/New Zealand" if region=="Oceania"

replace subregion="Eastern Europe" if origin=="Russia" | origin=="Ukraine" | origin=="Romania" | origin=="Bulgaria"  | origin=="Hungary" | origin=="Poland" | origin=="Slovakia" | origin=="Belarus" | origin=="Moldova"
replace subregion="Nothern Europe" if origin=="Sweden" | origin=="Denmark" | origin=="Finland" | origin=="Norway" | origin=="Lithuania" | origin=="Latvia" | origin=="Estonia" | origin=="Iceland"
replace subregion="Southern Europe" if origin=="Albania" | origin=="Bosnia Herzegovina" | origin=="Croatia" | origin=="Cyprus" | origin=="Greece" | origin=="Italy" | origin=="Kosovo" | origin=="Malta" | origin=="Montenegro" | origin=="Macedonia" | origin=="Portugal" | origin=="Serbia" | origin=="Slovenia" | origin=="Spain" | origin=="Northern Cyprus"
replace subregion="Western Europe" if origin=="Germany" | origin=="Austria" | origin=="Belgium" | origin=="France" | origin=="Luxembourg" | origin=="Netherlands" | origin=="Switzerland" | origin=="Czech Republic" | origin=="Ireland" | origin=="United Kingdom"

sort REG_GLOBAL origin

keep origin subregion
rename subregion region

replace origin="Bosnia and Herzegovina" if origin=="Bosnia Herzegovina"
expand 2 if origin=="Montenegro"
sort origin
quietly by origin: gen dup = cond(_N==1,0,_n)
replace origin="Serbia and Montenegro" if dup==2
drop dup

replace origin="Republic of Congo" if origin=="Congo Brazzaville"
replace origin="Democratic Republic of the Congo" if origin=="Congo Kinshasa"
replace origin="Côte d'Ivoire" if origin=="Ivory Coast"
drop if origin=="Nagorno Karabakh"
replace origin="Palestina" if origin=="Palestine"

merge 1:1 origin using "iso3 codes/Clean/iso3clean.dta"


/*
    Result                           # of obs.
    -----------------------------------------
    not matched                            94
        from master                         2  (_merge==1)
        from using                         92  (_merge==2)

    matched                               164  (_merge==3)
    -----------------------------------------
*/

replace iso3="SCG" if origin=="Serbia and Montenegro"
replace iso3="SOM" if origin=="Somaliland"

drop if _merge==2
drop _merge origin
duplicates drop 

save "Regions identifiers/dta/Regions identifiers.dta", replace
