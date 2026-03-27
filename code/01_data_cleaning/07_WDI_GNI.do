********************************************************************************
* 07 - World Development Indicators (GNI)
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Downloads GNI per capita from the World Bank API and constructs time-varying income group thresholds for country classification.
*
* Input:   World Bank API (wbopendata)
*
* Output:  GNIpc.dta, WDI.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

* GNI per capita, Atlas method (current US$)
clear
wbopendata, indicator(NY.GNP.PCAP.CD) long nometadata clear

drop if year<2006
drop if year>2015

drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
rename countryname origin
rename countrycode iso3o
tostring year, replace
rename ny_gnp_pcap_cd GNIpcOr
label variable GNIpc "GNI per capita, Atlas method (current US$) NY.GNP.PCAP.CD"

*save "D:\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GNIpc.dta", replace
*save "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GNIpc.dta", replace
save "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/WDI/Clean/Dta/GNIpc.dta", replace

* Source http://databank.worldbank.org/data/download/site-content/OGHIST.xls --> I AM NOT SURE ABOUT WHAT US$ THEY USE TO CLASSIFY THE COUNTRIES (current? 2017 constant?)
gen LowIncome_zzzzz= 905 if year=="2006"
replace LowIncome_zzzzz= 935 if year=="2007"
replace LowIncome_zzzzz= 975 if year=="2008"
replace LowIncome_zzzzz= 995 if year=="2009"
replace LowIncome_zzzzz= 1005 if year=="2010"
replace LowIncome_zzzzz= 1025 if year=="2011"
replace LowIncome_zzzzz= 1035 if year=="2012"
replace LowIncome_zzzzz= 1045 if year=="2013"
replace LowIncome_zzzzz= 1045 if year=="2014"
replace LowIncome_zzzzz= 1025 if year=="2015"

gen LowerMiddleIncome_zzzzz= 3595 if year=="2006"
replace LowerMiddleIncome_zzzzz= 3705 if year=="2007"
replace LowerMiddleIncome_zzzzz= 3855 if year=="2008"
replace LowerMiddleIncome_zzzzz= 3945 if year=="2009"
replace LowerMiddleIncome_zzzzz= 3975 if year=="2010"
replace LowerMiddleIncome_zzzzz= 4035 if year=="2011"
replace LowerMiddleIncome_zzzzz= 4085 if year=="2012"
replace LowerMiddleIncome_zzzzz= 4125 if year=="2013"
replace LowerMiddleIncome_zzzzz= 4125 if year=="2014"
replace LowerMiddleIncome_zzzzz= 4035 if year=="2015"

gen UpperMiddleIncome_zzzzz= 11115 if year=="2006"
replace UpperMiddleIncome_zzzzz= 11455 if year=="2007"
replace UpperMiddleIncome_zzzzz= 11905 if year=="2008"
replace UpperMiddleIncome_zzzzz= 12195 if year=="2009"
replace UpperMiddleIncome_zzzzz= 12275 if year=="2010"
replace UpperMiddleIncome_zzzzz= 12475 if year=="2011"
replace UpperMiddleIncome_zzzzz= 12615 if year=="2012"
replace UpperMiddleIncome_zzzzz= 12745 if year=="2013"
replace UpperMiddleIncome_zzzzz= 12735 if year=="2014"
replace UpperMiddleIncome_zzzzz= 12475 if year=="2015"

* For high income it has to be strictly superior to the previous limit
gen HighIncome_zzzzz= 11115 if year=="2006"
replace HighIncome_zzzzz= 11455 if year=="2007"
replace HighIncome_zzzzz= 11905 if year=="2008"
replace HighIncome_zzzzz= 12195 if year=="2009"
replace HighIncome_zzzzz= 12275 if year=="2010"
replace HighIncome_zzzzz= 12475 if year=="2011"
replace HighIncome_zzzzz= 12615 if year=="2012"
replace HighIncome_zzzzz= 12745 if year=="2013"
replace HighIncome_zzzzz= 12735 if year=="2014"
replace HighIncome_zzzzz= 12475 if year=="2015"

destring year, replace
replace year=year+1
tostring year, replace

*rename GDPpercapitaPPPconstant GDPpc_zzzzz
*rename PopulationTotal PopTotal_zzzzz
*rename PopulationFemales PopulationFemales_zzzzz
*rename PopulationMales PopulationMales_zzzzz
*rename TotalImmigrants TotalImmigrants_zzzzz
rename GNIpcOr GNIpc_zzzzz

replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem. Rep."
replace origin="Republic of Congo" if origin=="Congo, Rep."
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep."
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep."
replace origin="North Korea" if origin=="Korea, Dem. People’s Rep."
replace origin="South Korea" if origin=="Korea, Rep."
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed. Sts."
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Saint Kitts and Nevis" if origin=="St. Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St. Lucia"
replace origin="Saint Vincent and the Grenadines" if origin=="St. Vincent and the Grenadines"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Yemen" if origin=="Yemen, Rep."

drop iso3o
*merge m:1 origin using "D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
merge m:1 origin using "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           731
        from master                       600  (_merge==1)
        from using                        131  (_merge==2)

    matched                             3,754  (_merge==3)
    -----------------------------------------
*/

/* NOW IN 03/12/2020
    Result                           # of obs.
    -----------------------------------------
    not matched                           696
        from master                       640  (_merge==1)
        from using                         56  (_merge==2)

    matched                             2,000  (_merge==3)
    -----------------------------------------
*/

replace iso3o="COD" if origin=="Congo, Dem Rep" & _merge==1
replace iso3o="COG" if origin=="Republic of Congo" & _merge==1
replace iso3o="EGY" if origin=="Egypt, Arab Rep" & _merge==1
replace iso3o="IRN" if origin=="Iran, Islamic Rep" & _merge==1
replace iso3o="PRK" if origin=="Korea, Dem People’s Rep" & _merge==1
replace iso3o="KOR" if origin=="Korea, Rep" & _merge==1
replace iso3o="SXM" if origin=="Sint Maarten (Dutch part)" & _merge==1
replace iso3o="KNA" if origin=="St Kitts and Nevis" & _merge==1
replace iso3o="LCA" if origin=="St Lucia" & _merge==1
replace iso3o="MAF" if origin=="St Martin (French part)" & _merge==1
replace iso3o="VCT" if origin=="St Vincent and the Grenadines" & _merge==1
replace iso3o="VIR" if origin=="Virgin Islands (US)" & _merge==1
replace iso3o="YEM" if origin=="Yemen, Rep" & _merge==1

drop if _merge!=3 & iso3o==""
* (520 observations deleted)
drop _merge

destring year, replace
keep year GNIpc_zzzzz LowIncome_zzzzz LowerMiddleIncome_zzzzz UpperMiddleIncome_zzzzz HighIncome_zzzzz iso3o
duplicates drop 
rename *_zzzzz *

*save "D:\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GNIpc.dta", replace
*save "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GNIpc.dta", replace
save "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/WDI/Clean/Dta/GNIpc.dta", replace

************************************
**** GDP per capita, PPP (constant 2017 US$) // Changed by ilse (was current US$)
************************************
clear
*wbopendata, indicator(NY.GDP.PCAP.CD) long nometadata clear
* CHANGED BY KILLIAN 03/12/2020, what you imported is still the current US one! Need to change the WDI code to use the 2017 US constant PPP
wbopendata, indicator(NY.GDP.PCAP.PP.KD) long nometadata clear

drop if year<2006
drop if year>2015

drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
rename countryname origin
rename countrycode iso3o
rename ny_gdp_pcap_pp_kd GDPpc
label variable GDPpc "GDP per capita, (constant 2017 US$) NY.GDP.PCAP.PP.KD"

replace year=year+1
tostring year, replace

*** !!! I am doing this because the iso3 in this database do not match with the ones we use in iso3clean
replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem. Rep."
replace origin="Republic of Congo" if origin=="Congo, Rep."
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep."
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep."
replace origin="North Korea" if origin=="Korea, Dem. People’s Rep."
replace origin="South Korea" if origin=="Korea, Rep."
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed. Sts."
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Saint Kitts and Nevis" if origin=="St. Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St. Lucia"
replace origin="Saint Vincent and the Grenadines" if origin=="St. Vincent and the Grenadines"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Yemen" if origin=="Yemen, Rep."

drop iso3o
*merge m:1 origin using "D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
merge m:1 origin using "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/iso3 codes/Clean/iso3clean.dta"

/* FROM KILLIAN 
    Result                           # of obs.
    -----------------------------------------
    not matched                           696
        from master                       640  (_merge==1)
        from using                         56  (_merge==2)

    matched                             2,000  (_merge==3)
    -----------------------------------------
*/

replace iso3o="COD" if origin=="Congo, Dem Rep" & _merge==1
replace iso3o="COG" if origin=="Republic of Congo" & _merge==1
replace iso3o="EGY" if origin=="Egypt, Arab Rep" & _merge==1
replace iso3o="IRN" if origin=="Iran, Islamic Rep" & _merge==1
replace iso3o="PRK" if origin=="Korea, Dem People’s Rep" & _merge==1
replace iso3o="KOR" if origin=="Korea, Rep" & _merge==1
replace iso3o="SXM" if origin=="Sint Maarten (Dutch part)" & _merge==1
replace iso3o="KNA" if origin=="St Kitts and Nevis" & _merge==1
replace iso3o="LCA" if origin=="St Lucia" & _merge==1
replace iso3o="MAF" if origin=="St Martin (French part)" & _merge==1
replace iso3o="VCT" if origin=="St Vincent and the Grenadines" & _merge==1
replace iso3o="VIR" if origin=="Virgin Islands (US)" & _merge==1
replace iso3o="YEM" if origin=="Yemen, Rep" & _merge==1

drop if _merge!=3 & iso3o=="" // (520 observations deleted)
drop _merge
destring year, replace

*save "D:\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GDPpc.dta", replace
*save "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GDPpc.dta", replace
save "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/WDI/Clean/Dta/GDPpc.dta", replace


************************************
**** GDP, PPP (constant 2017 US$)
************************************
clear
*wbopendata, indicator(NY.GDP.MKTP.PP.KD) long nometadata clear
* CHANGED BY KILLIAN 03/12/2020, what you imported is still the current US one! Need to change the WDI code to use the 2017 US constant PPP
wbopendata, indicator(NY.GDP.MKTP.PP.KD) long nometadata clear

drop if year<2006
drop if year>2015

drop lendingtypename lendingtype incomelevelname incomelevel adminregionname adminregion regionname region
rename countryname origin
rename countrycode iso3o
rename ny_gdp_mktp_pp_kd GDP
label variable GDP "GDP, (constant 2011 International$) NY.GDP.MKTP.PP.KD"

replace year=year+1
tostring year, replace

*** !!! I am doing this because the iso3 in this database do not match with the ones we use in iso3clean
replace origin="Bahamas" if origin=="Bahamas, The"
replace origin="Brunei" if origin=="Brunei Darussalam"
replace origin="Cape Verde" if origin=="Cabo Verde"
replace origin="Democratic Republic of the Congo" if origin=="Congo, Dem. Rep."
replace origin="Republic of Congo" if origin=="Congo, Rep."
replace origin="Côte d'Ivoire" if origin=="Cote d'Ivoire"
replace origin="Curaçao" if origin=="Curacao"
replace origin="Egypt" if origin=="Egypt, Arab Rep."
replace origin="Gambia" if origin=="Gambia, The"
replace origin="Hong Kong" if origin=="Hong Kong SAR, China"
replace origin="Iran" if origin=="Iran, Islamic Rep."
replace origin="North Korea" if origin=="Korea, Dem. People’s Rep."
replace origin="South Korea" if origin=="Korea, Rep."
replace origin="Kyrgyzstan" if origin=="Kyrgyz Republic"
replace origin="Laos" if origin=="Lao PDR"
replace origin="Macao" if origin=="Macao SAR, China"
replace origin="Micronesia" if origin=="Micronesia, Fed. Sts."
replace origin="Macedonia" if origin=="North Macedonia"
replace origin="Russia" if origin=="Russian Federation"
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Saint Kitts and Nevis" if origin=="St. Kitts and Nevis"
replace origin="Saint Lucia" if origin=="St. Lucia"
replace origin="Saint Vincent and the Grenadines" if origin=="St. Vincent and the Grenadines"
replace origin="Syria" if origin=="Syrian Arab Republic"
replace origin="Venezuela" if origin=="Venezuela, RB"
replace origin="Palestina" if origin=="West Bank and Gaza"
replace origin="Yemen" if origin=="Yemen, Rep."

drop iso3o
*merge m:1 origin using "D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
*merge m:1 origin using "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3clean.dta"
merge m:1 origin using "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/iso3 codes/Clean/iso3clean.dta"

/* 
*/

replace iso3o="COD" if origin=="Congo, Dem Rep" & _merge==1
replace iso3o="COG" if origin=="Republic of Congo" & _merge==1
replace iso3o="EGY" if origin=="Egypt, Arab Rep" & _merge==1
replace iso3o="IRN" if origin=="Iran, Islamic Rep" & _merge==1
replace iso3o="PRK" if origin=="Korea, Dem People’s Rep" & _merge==1
replace iso3o="KOR" if origin=="Korea, Rep" & _merge==1
replace iso3o="SXM" if origin=="Sint Maarten (Dutch part)" & _merge==1
replace iso3o="KNA" if origin=="St Kitts and Nevis" & _merge==1
replace iso3o="LCA" if origin=="St Lucia" & _merge==1
replace iso3o="MAF" if origin=="St Martin (French part)" & _merge==1
replace iso3o="VCT" if origin=="St Vincent and the Grenadines" & _merge==1
replace iso3o="VIR" if origin=="Virgin Islands (US)" & _merge==1
replace iso3o="YEM" if origin=="Yemen, Rep" & _merge==1

drop if _merge!=3 & iso3o=="" // (520 observations deleted)
drop _merge
destring year, replace

*save "D:\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GDP.dta", replace
*save "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\WDI\Clean\Dta\GDP.dta", replace
save "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/WDI/Clean/Dta/GDP.dta", replace

