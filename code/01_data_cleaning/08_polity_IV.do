********************************************************************************
* 08 - Political Instability (Polity IV)
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Cleans the Polity IV dataset. Constructs a political instability dummy (3+ point change in Polity2 over preceding 3 years) and democracy level indicator.
*
* Input:   p4v2017.xls (Polity IV Project)
*
* Output:  Polity4 GWP.dta
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

import excel "Polity IV/Clean/Dta/p4v2017.xls", sheet("p4v2017") firstrow
keep country year polity polity2
sort year country

destring year, replace
sort country year
rename country origin
order year origin polity2 polity

br if origin =="Sudan-North"

replace origin="Republic of Congo" if origin=="Congo Brazzaville"
replace origin="Democratic Republic of the Congo" if origin=="Congo Kinshasa"
replace origin="Côte d'Ivoire" if origin=="Ivory Coast"
replace origin="North Korea" if origin=="Korea North"
replace origin="South Korea" if origin=="Korea South"
replace origin="Myanmar" if origin=="Myanmar (Burma)"
replace origin="Vietnam" if origin=="Vietnam"
replace origin="United Arab Emirates" if origin=="UAE"
replace origin="Bosnia and Herzegovina" if origin=="Bosnia"
replace origin="Timor-Leste" if origin=="East Timor"
replace origin="Sudan" if origin=="Sudan-North" // This creates a duplicate value for Sudan in the year 2011
replace origin="Slovakia" if origin=="Slovak Republic"
replace origin="Côte d'Ivoire" if origin=="Cote D'Ivoire"
replace origin="Timor-Leste" if origin=="Timor Leste"

duplicates list origin year
/*
Duplicates in terms of origin year
  +------------------------------------+
  | group:    obs:       origin   year |
  |------------------------------------|
  |      1    5175     Ethiopia   1993 |
  |      1    5176     Ethiopia   1993 |
  |      2   14429        Sudan   2011 |
  |      2   14430        Sudan   2011 |
  |      3   17281   Yugoslavia   1991 |
  |      3   17282   Yugoslavia   1991 |
  +------------------------------------+
*/
drop in 17281
drop in 14429
drop in 5176

gen PolInstability=0
replace PolInstability=1 if polity==-66
gen polity2_sq = polity2^2

egen o = group(origin)
xtset o year
gen polityL1 = L1.polity2
gen polityL2 = L2.polity2
gen polityL3 = L3.polity2
* ADDED 03/12/2020
gen politybisL1 = L1.polity
gen politybisL2 = L2.polity
gen politybisL3 = L3.polity
*
gen PolInstab3y = 0
*** Set Polinstab to 1 if in the past 3 years there was a change of at least 3 values in the polity2
bysort o year: replace PolInstab3y = 1 if  abs(polityL3 - polityL1) > 2 | abs(polityL2 - polityL1) > 2 | abs(polityL3 - polityL2) > 2 // Coded as a 3 or greater change in the polity2 score in the previous 3 years before the year of the interview OR if case of foreign “interruption” in the last 3y before the survey (ie replace if =-66)
replace PolInstab3y = . if polityL1==. | polityL2==. | polityL3==. // This is ok as the timeseries goes back far enough in time (we don't lose observations)

drop if year<2006
replace year = year+1 // Note KF 07/05/2021: I'm pretty sure we don't need to +1 here, since PolInstab is alread lagged by construction. However we need to keep PolityL1 instead of Polity2, and PolitybisL1 instead of Polity
drop if year>2016

*** THere were missing values in 3 countries (which would reduce the sample size in the estimations
tab origin  year if PolInstab3y==. // The table below is actually made on the basis of the estimation sample while in the sample here we still keep more values
/*
   COUNTRYNEW Country |         YEAR_CALENDAR Calendar Year
                 Name |      2011       2013       2014       2015 |     Total
----------------------+--------------------------------------------+----------
                 Iraq |     1,403        761          0          0 |     2,164 
              Somalia |         0          0        568        757 |     1,325 
          South Sudan |         0          0        488          0 |       488 
----------------------+--------------------------------------------+----------
                Total |     1,403        761      1,056        757 |     3,977 
*/

/* NOW (03/12/2020)
                      |               year
              country |      2007       2008       2009 |     Total
----------------------+---------------------------------+----------
          Afghanistan |         1          1          1 |        10 
Bosnia and Herzegov.. |         1          1          1 |        10 
                 Iraq |         1          1          1 |         7 
               Kosovo |         0          0          1 |         3 
              Lebanon |         1          1          0 |         2 
           Montenegro |         1          1          1 |         3 
               Serbia |         1          1          1 |         3 
      Solomon Islands |         1          0          0 |         1 
              Somalia |         0          0          0 |         3 
          South Sudan |         0          0          0 |         3 
----------------------+---------------------------------+----------
                Total |         7          6          6 |        45 


                      |               year
              country |      2010       2011       2012 |     Total
----------------------+---------------------------------+----------
          Afghanistan |         1          1          1 |        10 
Bosnia and Herzegov.. |         1          1          1 |        10 
                 Iraq |         1          1          1 |         7 
               Kosovo |         1          1          0 |         3 
              Lebanon |         0          0          0 |         2 
           Montenegro |         0          0          0 |         3 
               Serbia |         0          0          0 |         3 
      Solomon Islands |         0          0          0 |         1 
              Somalia |         0          0          0 |         3 
          South Sudan |         0          0          1 |         3 
----------------------+---------------------------------+----------
                Total |         4          4          4 |        45 


                      |               year
              country |      2013       2014       2015 |     Total
----------------------+---------------------------------+----------
          Afghanistan |         1          1          1 |        10 
Bosnia and Herzegov.. |         1          1          1 |        10 
                 Iraq |         1          0          0 |         7 
               Kosovo |         0          0          0 |         3 
              Lebanon |         0          0          0 |         2 
           Montenegro |         0          0          0 |         3 
               Serbia |         0          0          0 |         3 
      Solomon Islands |         0          0          0 |         1 
              Somalia |         1          1          1 |         3 
          South Sudan |         1          1          0 |         3 
----------------------+---------------------------------+----------
                Total |         5          4          3 |        45 


                      |    year
              country |      2016 |     Total
----------------------+-----------+----------
          Afghanistan |         1 |        10 
Bosnia and Herzegov.. |         1 |        10 
                 Iraq |         0 |         7 
               Kosovo |         0 |         3 
              Lebanon |         0 |         2 
           Montenegro |         0 |         3 
               Serbia |         0 |         3 
      Solomon Islands |         0 |         1 
              Somalia |         0 |         3 
          South Sudan |         0 |         3 
----------------------+-----------+----------
                Total |         2 |        45 
*/

* ADDED 03/12/2020
br if origin=="Afghanistan"
replace PolInstab3y = 1 if origin =="Afghanistan" & polity==-66 // To overcome some missings for Afghanistan, set this variable also to 1 if there was the code -66 (as we did originally)
replace PolInstab3y = 1 if origin =="Afghanistan" & (politybisL1==-66 | politybisL2==-66 | politybisL3==-66)
br if origin=="Bosnia and Herzegovina"
replace PolInstab3y = 1 if origin =="Bosnia and Herzegovina" & polity==-66 // To overcome some missings for Bosnia and Herzegovina, set this variable also to 1 if there was the code -66 (as we did originally)
*
br if origin=="Iraq"
replace PolInstab3y = 1 if origin =="Iraq" & polity==-66 // To overcome some missings for Iraq, set this variable also to 1 if there was the code -66 (as we did originally)
*replace PolInstab3y = 1 if origin == "Iraq" & (year==2011 | year== 2012 | year == 2013) // Cause the lags are still missing (-66 is in the past 3 years so set to 1 here)
* ADDED 03/12/2020
replace PolInstab3y = 1 if origin =="Iraq" & (politybisL1==-66 | politybisL2==-66 | politybisL3==-66) // It is exactly the same than the line above but by doing that we always use the same method
br if origin=="Kosovo"
* No changes because no information before 2008
br if origin=="Lebanon"
replace PolInstab3y = 1 if origin =="Lebanon" & (politybisL1==-66 | politybisL2==-66 | politybisL3==-66)
br if origin=="Montenegro"
* No changes because no information before 2006
br if origin=="Serbia"
* No changes because no information before 2006
br if origin=="Solomon Islands"
replace PolInstab3y = 1 if origin =="Solomon Islands" & (politybisL1==-66 | politybisL2==-66 | politybisL3==-66)
*
br if origin=="Somalia"
*replace PolInstab3y = 1 if origin == "Somalia" & (year==2013 | year== 2014 | year == 2015) // Cause the lags are still missing (-66 is in the past 3 years so set to 1 here)
* ADDED 03/12/2020
replace PolInstab3y = 1 if origin =="Somalia" & (politybisL1==-66 | politybisL2==-66 | politybisL3==-66) // It is exactly the same than the line above but by doing that we always use the same method
*
br if origin=="South Sudan"
replace PolInstab3y = 0 if origin == "South Sudan" & year==2014 // For South Sudan, the time series didn't go back far enough in time but the value was 0 always anyway so no change to report
drop o

***************************************
*** Merging with iso3o & last cleaning
***************************************

merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           107
        from master                        17  (_merge==1)
        from using                         90  (_merge==2)

    matched                             1,982  (_merge==3)
    -----------------------------------------
*/

/*   NOW IN 03/12/2020
   Result                           # of obs.
    -----------------------------------------
    not matched                            90
        from master                         1  (_merge==1)
        from using                         89  (_merge==2)

    matched                             1,663  (_merge==3)
    -----------------------------------------
*/

replace iso3="SCG" if origin=="Serbia and Montenegro"
drop if _merge==2
drop _merge origin polity polityL1-politybisL3


save "Polity IV/Clean/Dta/Polity4 GWP.dta", replace
