********************************************************************************
* 06 - Region-Month GTI Construction
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Constructs the region-month Global Terrorism Index and alternative terrorism indicators (attacks, victims, bombings) from the GTD at GADM level-1 with 5-year time-decaying weights and logarithmic banding.
*
* Input:   GTD event-level data (1970-2016)
*
* Output:  GTD region-month terrorism indices
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

/* 
In GTD, 1993 wave was lost. They tried to construct it again, but that particular year is not really reliable.

Source of GTD: Media articles and electronic news archives, and to a lesser extent, existing data sets, secondary source materials such as books and journals, and legal documents.

The GTD now includes incidents of terrorism from 1970 to 2015, however a number of new variables were added to the database beginning with the post-1997 data collection effort. Wherever possible, values for these new variables were retroactively coded for the original incidents, however some of the new variables pertain to details that were not recorded in the first phase of data collection. Garder que à partir de 1998?

In order for an event to be recorded in the GTD it must be documented by at least one high-quality source. Events that are only documented by distinctly biased or unreliable sources are not included in the GTD, however the GTD does include certain information from potentially biased sources, such as perpetrator claims of responsibility or details about the motive of the attack. Note that particular scarcity of high-quality sources in certain geographic areas results in conservative documentation of attacks in those areas in the GTD. 

The first year of data collected under the new process, 2012, represents a dramatic increase in the total number of worldwide terrorist attacks over 2011. Although this increase likely reflects recent patterns of terrorism, it is also partly a result of the improved efficiency of the data collection process.

The GTD defines a terrorist attack as the threatened or actual use of illegal force and violence by a non-state actor to attain a political, economic, religious, or social goal through fear, coercion, or intimidation. In practice this means in order to consider an incident for inclusion in the GTD, all three of the following attributes must be present:
    The incident must be intentional
    The incident must entail some level of violence or immediate threat of violence
    The perpetrators of the incidents must be sub-national actors
 In addition, at least two of the following three criteria must be present for an incident to be included in the GTD:
    Criterion 1: The act must be aimed at attaining a political, economic, religious, or social goal
    Criterion 2: There must be evidence of an intention to coerce, intimidate, or convey some other message to a larger audience (or audiences) than the immediate victims
    Criterion 3: The action must be outside the context of legitimate warfare activities
*/

cls 
clear all 
set more off, permanently
set scrollbufsize 500000 
set maxvar 10000
capture log close 

*cd "D:\Dropbox\PhD Killian\Paper II\Data\" // Fix PC Killian
cd "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\" // Laptop Killian
*cd "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/"

use "GTD/Clean/dta/1970-1994_stataversion.dta", clear

append using "GTD/Clean/dta/1993_stataversion.dta", force
append using "GTD/Clean/dta/1995-2012_stataversion.dta", force
append using "GTD/Clean/dta/2013-2016_stataversion.dta", force

order iyear country_txt country imonth iday
sort iyear country_txt imonth iday

drop latitude longitude eventid approxdate location summary attacktype2 attacktype2_txt attacktype3 attacktype3_txt corp1 target1 corp2 target2 targtype3 targtype3_txt targsubtype3 targsubtype3_txt corp3 target3 natlty3 natlty3_txt gname gsubname gname2 gsubname2 gname3 gsubname3 motive guncertain1 guncertain2 guncertain3 individual nperpcap claimmode claimmode_txt claim2 claimmode2 claimmode2_txt claim3 claimmode3 claimmode3_txt compclaim weapsubtype1 weapsubtype1_txt weapsubtype2 weapsubtype2_txt weapsubtype3 weapsubtype3_txt weapsubtype4 weapsubtype4_txt weapdetail nkillter nwoundte propcomment nhostkidus nhours ndays divert kidhijcountry ransomamt ransomamtus ransompaid ransompaidus ransomnote hostkidoutcome hostkidoutcome_txt nreleased addnotes scite1 scite2 scite3 dbsource related

drop if iyear<2000

******************************************************************
*** A. Data Aggregation on Different Time and Space Dimensions ***
******************************************************************

replace nhostkid=. if nhostkid==-99
replace INT_LOG=. if INT_LOG==-9
replace INT_IDEO=. if INT_IDEO==-9
replace INT_MISC=. if INT_MISC==-9
replace INT_ANY=. if INT_ANY==-9

* Prepare propvalue to be used for GTI index

replace propvalue=0 if propvalue==-99
gen propvalue1= 1 if propextent==3
replace propvalue1=0 if propvalue1==.
gen propvalue2= 2 if propextent==2 
replace propvalue2=0 if propvalue2==.
gen propvalue3= 3 if propextent==1
replace propvalue3=0 if propvalue3==.

gen propvaluetotal=propvalue1+propvalue2+propvalue3
drop propvalue propvalue1 propvalue2 propvalue3

gen NationalTarget=1 if natlty1==country
replace NationalTarget=0 if NationalTarget==.

gen type1=1 if attacktype1==3
replace type1=0 if type1==.

gen type2=1 if targtype1==15
replace type2=0 if type2==.

gen type3=1 if targtype1==22
replace type3=0 if type3==.

gen type4=1 if weaptype1==6
replace type4=0 if type4==.

gen ID_GADM_fine=""
rename country_txt origin
rename provstate NAME_1
sort origin NAME_1

drop if NAME_1==""
drop if NAME_1=="Unknown"

* AFGHANISTAN
replace NAME_1="Hilmand" if NAME_1=="Helmand" & origin=="Afghanistan"
replace NAME_1="Hirat" if NAME_1=="Herat" & origin=="Afghanistan"
replace NAME_1="Paktika" if NAME_1=="Paktia" & origin=="Afghanistan"
replace NAME_1="Panjshir" if NAME_1=="Panjsher" & origin=="Afghanistan"
drop if NAME_1=="Unknown" & origin=="Afghanistan"
replace ID_GADM_fine="AFG1" if NAME_1=="Badakhshan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG2" if NAME_1=="Badghis" & origin=="Afghanistan"
replace ID_GADM_fine="AFG3" if NAME_1=="Baghlan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG4" if NAME_1=="Balkh" & origin=="Afghanistan"
replace ID_GADM_fine="AFG5" if NAME_1=="Bamyan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG6" if NAME_1=="Daykundi" & origin=="Afghanistan"
replace ID_GADM_fine="AFG7" if NAME_1=="Farah" & origin=="Afghanistan"
replace ID_GADM_fine="AFG8" if NAME_1=="Faryab" & origin=="Afghanistan"
replace ID_GADM_fine="AFG9" if NAME_1=="Ghazni" & origin=="Afghanistan"
replace ID_GADM_fine="AFG10" if NAME_1=="Ghor" & origin=="Afghanistan"
replace ID_GADM_fine="AFG11" if NAME_1=="Hilmand" & origin=="Afghanistan"
replace ID_GADM_fine="AFG12" if NAME_1=="Hirat" & origin=="Afghanistan"
replace ID_GADM_fine="AFG13" if NAME_1=="Jawzjan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG14" if NAME_1=="Kabul" & origin=="Afghanistan"
replace ID_GADM_fine="AFG15" if NAME_1=="Kandahar" & origin=="Afghanistan"
replace ID_GADM_fine="AFG16" if NAME_1=="Kapisa" & origin=="Afghanistan"
replace ID_GADM_fine="AFG17" if NAME_1=="Khost" & origin=="Afghanistan"
replace ID_GADM_fine="AFG18" if NAME_1=="Kunar" & origin=="Afghanistan"
replace ID_GADM_fine="AFG19" if NAME_1=="Kunduz" & origin=="Afghanistan"
replace ID_GADM_fine="AFG20" if NAME_1=="Laghman" & origin=="Afghanistan"
replace ID_GADM_fine="AFG21" if NAME_1=="Logar" & origin=="Afghanistan"
replace ID_GADM_fine="AFG22" if NAME_1=="Nangarhar" & origin=="Afghanistan"
replace ID_GADM_fine="AFG23" if NAME_1=="Nimroz" & origin=="Afghanistan"
replace ID_GADM_fine="AFG24" if NAME_1=="Nuristan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG25" if NAME_1=="Paktika" & origin=="Afghanistan"
replace ID_GADM_fine="AFG26" if NAME_1=="Paktya" & origin=="Afghanistan"
replace ID_GADM_fine="AFG27" if NAME_1=="Panjshir" & origin=="Afghanistan"
replace ID_GADM_fine="AFG28" if NAME_1=="Parwan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG29" if NAME_1=="Samangan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG30" if NAME_1=="Sari Pul" & origin=="Afghanistan"
replace ID_GADM_fine="AFG31" if NAME_1=="Takhar" & origin=="Afghanistan"
replace ID_GADM_fine="AFG32" if NAME_1=="Uruzgan" & origin=="Afghanistan"
replace ID_GADM_fine="AFG33" if NAME_1=="Wardak" & origin=="Afghanistan"
replace ID_GADM_fine="AFG34" if NAME_1=="Zabul" & origin=="Afghanistan"

* ALBANIA
replace NAME_1="Durrës" if NAME_1=="Durres" & origin=="Albania"
replace NAME_1="Gjirokastër" if NAME_1=="Gjirokaster" & origin=="Albania"
replace NAME_1="Shkodër" if NAME_1=="Shkoder" & origin=="Albania"
replace NAME_1="Tiranë" if NAME_1=="Tirana" & origin=="Albania"
replace NAME_1="Vlorë" if NAME_1=="Vlore" & origin=="Albania"
replace NAME_1="Lezhë" if NAME_1=="Lezhe (County)" & origin=="Algeria"
replace origin="Albania" if NAME_1=="Lezhë"
replace ID_GADM_fine="ALB1" if NAME_1=="Berat" & origin=="Albania"
replace ID_GADM_fine="ALB2" if NAME_1=="Dibër" & origin=="Albania"
replace ID_GADM_fine="ALB3" if NAME_1=="Durrës" & origin=="Albania"
replace ID_GADM_fine="ALB4" if NAME_1=="Elbasan" & origin=="Albania"
replace ID_GADM_fine="ALB5" if NAME_1=="Fier" & origin=="Albania"
replace ID_GADM_fine="ALB6" if NAME_1=="Gjirokastër" & origin=="Albania"
replace ID_GADM_fine="ALB7" if NAME_1=="Korçë" & origin=="Albania"
replace ID_GADM_fine="ALB8" if NAME_1=="Kukës" & origin=="Albania"
replace ID_GADM_fine="ALB9" if NAME_1=="Lezhë" & origin=="Albania"
replace ID_GADM_fine="ALB10" if NAME_1=="Shkodër" & origin=="Albania"
replace ID_GADM_fine="ALB11" if NAME_1=="Tiranë" & origin=="Albania"
replace ID_GADM_fine="ALB12" if NAME_1=="Vlorë" & origin=="Albania"

* ALGERIA
replace NAME_1="Aïn Defla" if NAME_1=="Ain Defla" & origin=="Algeria"
replace NAME_1="Aïn Defla" if NAME_1=="Ain Defla (Province)" & origin=="Algeria"
replace NAME_1="Aïn Defla" if NAME_1=="Ain Defla Province" & origin=="Algeria"
replace NAME_1="Alger" if NAME_1=="Algiers" & origin=="Algeria"
replace NAME_1="Alger" if NAME_1=="Algiers (Province)" & origin=="Algeria"
replace NAME_1="Alger" if NAME_1=="Algiers Province" & origin=="Algeria"
replace NAME_1="Tizi Ouzou" if NAME_1=="Amdjoudh Massif" & origin=="Algeria"
replace NAME_1="Annaba" if NAME_1=="Annaba (Province)" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Aomar (Province)" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Aomar (Region)" & origin=="Algeria"
replace NAME_1="Aïn Defla" if NAME_1=="Aïn Defla (Province)" & origin=="Algeria"
replace NAME_1="Batna" if NAME_1=="Batna (Province)" & origin=="Algeria"
replace NAME_1="Batna" if NAME_1=="Batna Province" & origin=="Algeria"
replace NAME_1="Béchar" if NAME_1=="Bechar" & origin=="Algeria"
replace NAME_1="Béchar" if NAME_1=="Bechar (Province)" & origin=="Algeria"
replace NAME_1="Béjaïa" if NAME_1=="Bejaia" & origin=="Algeria"
replace NAME_1="Béjaïa" if NAME_1=="Bejaia (Province)" & origin=="Algeria"
replace NAME_1="Béjaïa" if NAME_1=="Berber (Province)" & origin=="Algeria"
replace NAME_1="Sidi Bel Abbès" if NAME_1=="Bir H'mam" & origin=="Algeria"
replace NAME_1="Alger" if NAME_1=="Bir Mourad Rais (Province)" & origin=="Algeria"
replace NAME_1="Biskra" if NAME_1=="Biskra (Province)" & origin=="Algeria"
replace NAME_1="Biskra" if NAME_1=="Biskra Province" & origin=="Algeria"
replace NAME_1="Blida" if NAME_1=="Blida (Province)" & origin=="Algeria"
replace NAME_1="Blida" if NAME_1=="Blidu (Province)" & origin=="Algeria"
replace NAME_1="Bordj Bou Arréridj" if NAME_1=="Bordj Bou Arreridj" & origin=="Algeria"
replace NAME_1="Bordj Bou Arréridj" if NAME_1=="Bordj Bou Arreridj Province" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Bouira (Province)" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Bouira Province" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdes" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdes (Province)" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdes Province" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdès" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdès (Province)" & origin=="Algeria"
replace NAME_1="Boumerdès" if NAME_1=="Boumerdès Province" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Bouïra Province" & origin=="Algeria"
replace NAME_1="Béjaïa" if NAME_1=="Béjaïa (Province)" & origin=="Algeria"
replace NAME_1="Béjaïa" if NAME_1=="Béjaïa Province" & origin=="Algeria"
replace NAME_1="Chlef" if NAME_1=="Chlef  (Province)" & origin=="Algeria"
replace NAME_1="Chlef" if NAME_1=="Chlef (Province)" & origin=="Algeria"
replace NAME_1="Chlef" if NAME_1=="Chlef (Region)" & origin=="Algeria"
replace NAME_1="Constantine" if NAME_1=="Constantine Province" & origin=="Algeria"
replace NAME_1="Chlef" if NAME_1=="Dahra (Region)" & origin=="Algeria"
replace NAME_1="Djelfa" if NAME_1=="Djelfa (Province)" & origin=="Algeria"
replace NAME_1="Médéa" if NAME_1=="El Aissaoui (Municipality)" & origin=="Algeria"
replace NAME_1="Mascara" if NAME_1=="El Bordj (District)" & origin=="Algeria"
replace NAME_1="Ghardaïa" if NAME_1=="Ghardaia" & origin=="Algeria"
replace NAME_1="Illizi" if NAME_1=="Illizi (Province)" & origin=="Algeria"
replace NAME_1="Jijel" if NAME_1=="Jijel" & origin=="Algeria"
replace NAME_1="Jijel" if NAME_1=="Jijel (Province)" & origin=="Algeria"
replace NAME_1="Jijel" if NAME_1=="Jijel (Region)" & origin=="Algeria"
replace NAME_1="Jijel" if NAME_1=="Jijel Province" & origin=="Algeria"
replace NAME_1="Jijel" if NAME_1=="Jijil (Province)" & origin=="Algeria"
replace NAME_1="Khenchela" if NAME_1=="Khenchela" & origin=="Algeria"
replace NAME_1="Khenchela" if NAME_1=="Khenchela (Province)" & origin=="Algeria"
replace NAME_1="Khenchela" if NAME_1=="Khenchela Province" & origin=="Algeria"
replace NAME_1="Laghouat" if NAME_1=="Laghouat (Province)" & origin=="Algeria"
replace NAME_1="Bouira" if NAME_1=="Lakhdaria Province" & origin=="Algeria"
replace NAME_1="M'Sila" if NAME_1=="M'Sila" & origin=="Algeria"
replace NAME_1="M'Sila" if NAME_1=="M'sila" & origin=="Algeria"
replace NAME_1="M'Sila" if NAME_1=="M'sila Province" & origin=="Algeria"
replace NAME_1="Mascara" if NAME_1=="Mascara" & origin=="Algeria"
replace NAME_1="Mascara" if NAME_1=="Mascara (Province)" & origin=="Algeria"
replace NAME_1="Mascara" if NAME_1=="Mascara Province" & origin=="Algeria"
replace NAME_1="Médéa" if NAME_1=="Medea" & origin=="Algeria"
replace NAME_1="Médéa" if NAME_1=="Medea (Province)" & origin=="Algeria"
replace NAME_1="Médéa" if NAME_1=="Medea Province" & origin=="Algeria"
replace NAME_1="Mascara" if NAME_1=="Muaskar (Province)" & origin=="Algeria"
replace NAME_1="Médéa" if NAME_1=="Médéa Province" & origin=="Algeria"
replace NAME_1="Oran" if NAME_1=="Oran (Province)" & origin=="Algeria"
replace NAME_1="Oran" if NAME_1=="Oran Province" & origin=="Algeria"
replace NAME_1="Ouargla" if NAME_1=="Ouargla (Province)" & origin=="Algeria"
replace NAME_1="Oum el Bouaghi" if NAME_1=="Oum el-Bouaghi" & origin=="Algeria"
replace NAME_1="Oum el Bouaghi" if NAME_1=="Oum El Bouaghi" & origin=="Algeria"
replace NAME_1="Relizane" if NAME_1=="Relizane" & origin=="Algeria"
replace NAME_1="Relizane" if NAME_1=="Relizane (Province)" & origin=="Algeria"
replace NAME_1="Relizane" if NAME_1=="Relizane Province" & origin=="Algeria"
replace NAME_1="Alger" if NAME_1=="Rouiba (Province)" & origin=="Algeria"
replace NAME_1="Sétif" if NAME_1=="Setif (Province)" & origin=="Algeria"
replace NAME_1="Sétif" if NAME_1=="Setif (Stif)" & origin=="Algeria"
replace NAME_1="Sétif" if NAME_1=="Setif Province" & origin=="Algeria"
replace NAME_1="Sidi Bel Abbès" if NAME_1=="Sidi Bel Abbes" & origin=="Algeria"
replace NAME_1="Sidi Bel Abbès" if NAME_1=="Sidi Bel Abbes (Province)" & origin=="Algeria"
replace NAME_1="Sidi Bel Abbès" if NAME_1=="Sidi Bel Abbès Province" & origin=="Algeria"
replace NAME_1="Skikda" if NAME_1=="Skikda" & origin=="Algeria"
replace NAME_1="Skikda" if NAME_1=="Skikda (Province)" & origin=="Algeria"
replace NAME_1="Skikda" if NAME_1=="Skikda Province" & origin=="Algeria"
replace NAME_1="Skikda" if NAME_1=="Skikida (Province)" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tabaza (Province)" & origin=="Algeria"
replace NAME_1="Tamanghasset" if NAME_1=="Tamanghasset" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tbessa" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tebessa" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tebessa (Province)" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tebessa Province" & origin=="Algeria"
replace NAME_1="Tiaret" if NAME_1=="Tiaret" & origin=="Algeria"
replace NAME_1="Tiaret" if NAME_1=="Tiaret (Province)" & origin=="Algeria"
replace NAME_1="Tiaret" if NAME_1=="Tiaret (Region)" & origin=="Algeria"
replace NAME_1="Tindouf" if NAME_1=="Tindouf" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tipasa" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tipasa (Province)" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tipaza" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tipaza (Province)" & origin=="Algeria"
replace NAME_1="Tipaza" if NAME_1=="Tipaza Province" & origin=="Algeria"
replace NAME_1="Tissemsilt" if NAME_1=="Tissemselt (Province)" & origin=="Algeria"
replace NAME_1="Tissemsilt" if NAME_1=="Tissemsilt" & origin=="Algeria"
replace NAME_1="Tissemsilt" if NAME_1=="Tissemsilt (Province)" & origin=="Algeria"
replace NAME_1="Tissemsilt" if NAME_1=="Tissemsilt Province" & origin=="Algeria"
replace NAME_1="Tissemsilt" if NAME_1=="Tissmesilt" & origin=="Algeria"
replace NAME_1="Tizi Ouzou" if NAME_1=="Tizi Ouzou" & origin=="Algeria"
replace NAME_1="Tizi Ouzou" if NAME_1=="Tizi Ouzou (Province)" & origin=="Algeria"
replace NAME_1="Tizi Ouzou" if NAME_1=="Tizi Ouzou Province" & origin=="Algeria"
replace NAME_1="Tlemcen" if NAME_1=="Tlemcen" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tébessa" & origin=="Algeria"
replace NAME_1="Tébessa" if NAME_1=="Tébessa Province" & origin=="Algeria"
replace NAME_1="Djelfa" if NAME_1=="Wilaya de Djelfa" & origin=="Algeria"
replace NAME_1="Skikda" if NAME_1=="Tamalous (Region)" & origin=="Algeria"
replace ID_GADM_fine="DZA1" if NAME_1=="Adrar" & origin=="Algeria"
replace ID_GADM_fine="DZA2" if NAME_1=="Aïn Defla" & origin=="Algeria"
replace ID_GADM_fine="DZA3" if NAME_1=="Aïn Témouchent" & origin=="Algeria"
replace ID_GADM_fine="DZA4" if NAME_1=="Alger" & origin=="Algeria"
replace ID_GADM_fine="DZA5" if NAME_1=="Annaba" & origin=="Algeria"
replace ID_GADM_fine="DZA6" if NAME_1=="Batna" & origin=="Algeria"
replace ID_GADM_fine="DZA7" if NAME_1=="Béchar" & origin=="Algeria"
replace ID_GADM_fine="DZA8" if NAME_1=="Béjaïa" & origin=="Algeria"
replace ID_GADM_fine="DZA9" if NAME_1=="Biskra" & origin=="Algeria"
replace ID_GADM_fine="DZA10" if NAME_1=="Blida" & origin=="Algeria"
replace ID_GADM_fine="DZA11" if NAME_1=="Bordj Bou Arréridj" & origin=="Algeria"
replace ID_GADM_fine="DZA12" if NAME_1=="Bouira" & origin=="Algeria"
replace ID_GADM_fine="DZA13" if NAME_1=="Boumerdès" & origin=="Algeria"
replace ID_GADM_fine="DZA14" if NAME_1=="Chlef" & origin=="Algeria"
replace ID_GADM_fine="DZA15" if NAME_1=="Constantine" & origin=="Algeria"
replace ID_GADM_fine="DZA16" if NAME_1=="Djelfa" & origin=="Algeria"
replace ID_GADM_fine="DZA17" if NAME_1=="El Bayadh" & origin=="Algeria"
replace ID_GADM_fine="DZA18" if NAME_1=="El Oued" & origin=="Algeria"
replace ID_GADM_fine="DZA19" if NAME_1=="El Tarf" & origin=="Algeria"
replace ID_GADM_fine="DZA20" if NAME_1=="Ghardaïa" & origin=="Algeria"
replace ID_GADM_fine="DZA21" if NAME_1=="Guelma" & origin=="Algeria"
replace ID_GADM_fine="DZA22" if NAME_1=="Illizi" & origin=="Algeria"
replace ID_GADM_fine="DZA23" if NAME_1=="Jijel" & origin=="Algeria"
replace ID_GADM_fine="DZA24" if NAME_1=="Khenchela" & origin=="Algeria"
replace ID_GADM_fine="DZA25" if NAME_1=="Laghouat" & origin=="Algeria"
replace ID_GADM_fine="DZA26" if NAME_1=="M'Sila" & origin=="Algeria"
replace ID_GADM_fine="DZA27" if NAME_1=="Mascara" & origin=="Algeria"
replace ID_GADM_fine="DZA28" if NAME_1=="Médéa" & origin=="Algeria"
replace ID_GADM_fine="DZA29" if NAME_1=="Mila" & origin=="Algeria"
replace ID_GADM_fine="DZA30" if NAME_1=="Mostaganem" & origin=="Algeria"
replace ID_GADM_fine="DZA31" if NAME_1=="Naâma" & origin=="Algeria"
replace ID_GADM_fine="DZA32" if NAME_1=="Oran" & origin=="Algeria"
replace ID_GADM_fine="DZA33" if NAME_1=="Ouargla" & origin=="Algeria"
replace ID_GADM_fine="DZA34" if NAME_1=="Oum el Bouaghi" & origin=="Algeria"
replace ID_GADM_fine="DZA35" if NAME_1=="Relizane" & origin=="Algeria"
replace ID_GADM_fine="DZA36" if NAME_1=="Saïda" & origin=="Algeria"
replace ID_GADM_fine="DZA37" if NAME_1=="Sétif" & origin=="Algeria"
replace ID_GADM_fine="DZA38" if NAME_1=="Sidi Bel Abbès" & origin=="Algeria"
replace ID_GADM_fine="DZA39" if NAME_1=="Skikda" & origin=="Algeria"
replace ID_GADM_fine="DZA40" if NAME_1=="Souk Ahras" & origin=="Algeria"
replace ID_GADM_fine="DZA41" if NAME_1=="Tamanghasset" & origin=="Algeria"
replace ID_GADM_fine="DZA42" if NAME_1=="Tébessa" & origin=="Algeria"
replace ID_GADM_fine="DZA43" if NAME_1=="Tiaret" & origin=="Algeria"
replace ID_GADM_fine="DZA44" if NAME_1=="Tindouf" & origin=="Algeria"
replace ID_GADM_fine="DZA45" if NAME_1=="Tipaza" & origin=="Algeria"
replace ID_GADM_fine="DZA46" if NAME_1=="Tissemsilt" & origin=="Algeria"
replace ID_GADM_fine="DZA47" if NAME_1=="Tizi Ouzou" & origin=="Algeria"
replace ID_GADM_fine="DZA48" if NAME_1=="Tlemcen" & origin=="Algeria"
drop if NAME_1=="Guerrouche (Province)" & origin=="Algeria"
drop if NAME_1=="Haoudh (Region)" & origin=="Algeria"
drop if NAME_1=="Kabylie (Region)" & origin=="Algeria"
drop if NAME_1=="Kabylie Region" & origin=="Algeria"
drop if NAME_1=="Mitidja Plains (Province)" & origin=="Algeria"
drop if NAME_1=="Sahara" & origin=="Algeria"
drop if NAME_1=="Topaz (Province)" & origin=="Algeria"

* ANGOLA
replace NAME_1="Bié" if NAME_1=="Bie" & origin=="Angola"
replace NAME_1="Huíla" if NAME_1=="Huila" & origin=="Angola"
replace NAME_1="Uíge" if NAME_1=="Uige" & origin=="Angola"
replace ID_GADM_fine="AGO1" if NAME_1=="Bengo" & origin=="Angola"
replace ID_GADM_fine="AGO2" if NAME_1=="Benguela" & origin=="Angola"
replace ID_GADM_fine="AGO3" if NAME_1=="Bié" & origin=="Angola"
replace ID_GADM_fine="AGO4" if NAME_1=="Cabinda" & origin=="Angola"
replace ID_GADM_fine="AGO5" if NAME_1=="Cuando Cubango" & origin=="Angola"
replace ID_GADM_fine="AGO6" if NAME_1=="Cuanza Norte" & origin=="Angola"
replace ID_GADM_fine="AGO7" if NAME_1=="Cuanza Sul" & origin=="Angola"
replace ID_GADM_fine="AGO8" if NAME_1=="Cunene" & origin=="Angola"
replace ID_GADM_fine="AGO9" if NAME_1=="Huambo" & origin=="Angola"
replace ID_GADM_fine="AGO10" if NAME_1=="Huíla" & origin=="Angola"
replace ID_GADM_fine="AGO11" if NAME_1=="Luanda" & origin=="Angola"
replace ID_GADM_fine="AGO12" if NAME_1=="Lunda Norte" & origin=="Angola"
replace ID_GADM_fine="AGO13" if NAME_1=="Lunda Sul" & origin=="Angola"
replace ID_GADM_fine="AGO14" if NAME_1=="Malanje" & origin=="Angola"
replace ID_GADM_fine="AGO15" if NAME_1=="Moxico" & origin=="Angola"
replace ID_GADM_fine="AGO16" if NAME_1=="Namibe" & origin=="Angola"
replace ID_GADM_fine="AGO17" if NAME_1=="Uíge" & origin=="Angola"
replace ID_GADM_fine="AGO18" if NAME_1=="Zaire" & origin=="Angola"

* ARGENTINA
replace NAME_1="Buenos Aires" if NAME_1=="Ciudad de Buenos Aires" & origin=="Argentina"
replace NAME_1="Río Negro" if NAME_1=="Rio Negro" & origin=="Argentina"
replace ID_GADM_fine="ARG1" if NAME_1=="Buenos Aires" & origin=="Argentina"
replace ID_GADM_fine="ARG2" if NAME_1=="Catamarca" & origin=="Argentina"
replace ID_GADM_fine="ARG3" if NAME_1=="Chaco" & origin=="Argentina"
replace ID_GADM_fine="ARG4" if NAME_1=="Chubut" & origin=="Argentina"
replace ID_GADM_fine="ARG5" if NAME_1=="Ciudad de Buenos Aires" & origin=="Argentina"
replace ID_GADM_fine="ARG6" if NAME_1=="Córdoba" & origin=="Argentina"
replace ID_GADM_fine="ARG7" if NAME_1=="Corrientes" & origin=="Argentina"
replace ID_GADM_fine="ARG8" if NAME_1=="Entre Ríos" & origin=="Argentina"
replace ID_GADM_fine="ARG9" if NAME_1=="Formosa" & origin=="Argentina"
replace ID_GADM_fine="ARG10" if NAME_1=="Jujuy" & origin=="Argentina"
replace ID_GADM_fine="ARG11" if NAME_1=="La Pampa" & origin=="Argentina"
replace ID_GADM_fine="ARG12" if NAME_1=="La Rioja" & origin=="Argentina"
replace ID_GADM_fine="ARG13" if NAME_1=="Mendoza" & origin=="Argentina"
replace ID_GADM_fine="ARG14" if NAME_1=="Misiones" & origin=="Argentina"
replace ID_GADM_fine="ARG15" if NAME_1=="Neuquén" & origin=="Argentina"
replace ID_GADM_fine="ARG16" if NAME_1=="Río Negro" & origin=="Argentina"
replace ID_GADM_fine="ARG17" if NAME_1=="Salta" & origin=="Argentina"
replace ID_GADM_fine="ARG18" if NAME_1=="San Juan" & origin=="Argentina"
replace ID_GADM_fine="ARG19" if NAME_1=="San Luis" & origin=="Argentina"
replace ID_GADM_fine="ARG20" if NAME_1=="Santa Cruz" & origin=="Argentina"
replace ID_GADM_fine="ARG21" if NAME_1=="Santa Fe" & origin=="Argentina"
replace ID_GADM_fine="ARG22" if NAME_1=="Santiago del Estero" & origin=="Argentina"
replace ID_GADM_fine="ARG23" if NAME_1=="Tierra del Fuego" & origin=="Argentina"
replace ID_GADM_fine="ARG24" if NAME_1=="Tucumán" & origin=="Argentina"

* ARMENIA // Not in GADM --> copy GWP code
replace NAME_1="Yerevan" if NAME_1=="Yerevan (Special Administrative Region)" & origin=="Armenia"
replace ID_GADM_fine="ARM7" if NAME_1=="Lori" & origin=="Armenia"
replace ID_GADM_fine="ARM8" if NAME_1=="Shirak" & origin=="Armenia"
replace ID_GADM_fine="ARM4" if NAME_1=="Yerevan" & origin=="Armenia"

* AUSTRALIA
replace NAME_1="New South Wales" if NAME_1=="New South Wales (State)" & origin=="Australia"
replace NAME_1="Queensland" if NAME_1=="Queensland (State)" & origin=="Australia"
replace NAME_1="Victoria" if NAME_1=="Victoria (State)" & origin=="Australia"
replace ID_GADM_fine="AUS1" if NAME_1=="Ashmore and Cartier Islands" & origin=="Australia"
replace ID_GADM_fine="AUS2" if NAME_1=="Australian Capital Territory" & origin=="Australia"
replace ID_GADM_fine="AUS3" if NAME_1=="Coral Sea Islands Territory" & origin=="Australia"
replace ID_GADM_fine="AUS4" if NAME_1=="Jervis Bay Territory" & origin=="Australia"
replace ID_GADM_fine="AUS5" if NAME_1=="New South Wales" & origin=="Australia"
replace ID_GADM_fine="AUS6" if NAME_1=="Northern Territory" & origin=="Australia"
replace ID_GADM_fine="AUS7" if NAME_1=="Queensland" & origin=="Australia"
replace ID_GADM_fine="AUS8" if NAME_1=="South Australia" & origin=="Australia"
replace ID_GADM_fine="AUS9" if NAME_1=="Tasmania" & origin=="Australia"
replace ID_GADM_fine="AUS10" if NAME_1=="Victoria" & origin=="Australia"
replace ID_GADM_fine="AUS11" if NAME_1=="Western Australia" & origin=="Australia"

* AUSTRIA
replace NAME_1="Steiermark" if NAME_1=="Styria" & origin=="Austria"
replace NAME_1="Tirol" if NAME_1=="Tyrol" & origin=="Austria"
replace NAME_1="Oberösterreich" if NAME_1=="Upper Austria" & origin=="Austria"
replace NAME_1="Wien" if NAME_1=="Vienna" & origin=="Austria"
replace ID_GADM_fine="AUT1" if NAME_1=="Burgenland" & origin=="Austria"
replace ID_GADM_fine="AUT2" if NAME_1=="Kärnten" & origin=="Austria"
replace ID_GADM_fine="AUT3" if NAME_1=="Niederösterreich" & origin=="Austria"
replace ID_GADM_fine="AUT4" if NAME_1=="Oberösterreich" & origin=="Austria"
replace ID_GADM_fine="AUT5" if NAME_1=="Salzburg" & origin=="Austria"
replace ID_GADM_fine="AUT6" if NAME_1=="Steiermark" & origin=="Austria"
replace ID_GADM_fine="AUT7" if NAME_1=="Tirol" & origin=="Austria"
replace ID_GADM_fine="AUT8" if NAME_1=="Vorarlberg" & origin=="Austria"
replace ID_GADM_fine="AUT9" if NAME_1=="Wien" & origin=="Austria"

* AZERBAIJAN
replace NAME_1="Absheron" if NAME_1=="Baku" & origin=="Azerbaijan"
replace NAME_1="Absheron" if NAME_1=="Baku (City)" & origin=="Azerbaijan"
replace NAME_1="Lankaran" if NAME_1=="Jalilabad" & origin=="Azerbaijan"
replace NAME_1="Yukhari-Karabakh" if NAME_1=="Khankendi" & origin=="Azerbaijan"
replace NAME_1="Quba-Khachmaz" if NAME_1=="Quba" & origin=="Azerbaijan"
replace NAME_1="Shaki-Zaqatala" if NAME_1=="Zaqatala" & origin=="Azerbaijan"
replace NAME_1="Shaki-Zaqatala" if NAME_1=="Zaqatala (District)" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE1" if NAME_1=="Absheron" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE2" if NAME_1=="Aran" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE3" if NAME_1=="Daglig-Shirvan" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE4" if NAME_1=="Ganja-Qazakh" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE5" if NAME_1=="Kalbajar-Lachin" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE6" if NAME_1=="Lankaran" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE7" if NAME_1=="Nakhchivan" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE8" if NAME_1=="Quba-Khachmaz" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE9" if NAME_1=="Shaki-Zaqatala" & origin=="Azerbaijan"
replace ID_GADM_fine="AZE10" if NAME_1=="Yukhari-Karabakh" & origin=="Azerbaijan"

* BAHAMAS // Not in GADM --> drop
drop if origin=="Bahamas"

* BAHRAIN // Not in GADM --> copy GWP codes
replace NAME_1="South" if NAME_1=="Southern" & origin=="Bahrain"
replace ID_GADM_fine="BHR1" if NAME_1=="Capital" & origin=="Bahrain"
replace ID_GADM_fine="BHR2" if NAME_1=="Central" & origin=="Bahrain"
replace ID_GADM_fine="BHR3" if NAME_1=="Muharraq" & origin=="Bahrain"
replace ID_GADM_fine="BHR4" if NAME_1=="Northern" & origin=="Bahrain"
replace ID_GADM_fine="BHR5" if NAME_1=="Southern" & origin=="Bahrain"

* BANGLADESH
replace ID_GADM_fine="BGD1" if NAME_1=="Barisal" & origin=="Bangladesh"
replace ID_GADM_fine="BGD2" if NAME_1=="Chittagong" & origin=="Bangladesh"
replace ID_GADM_fine="BGD3" if NAME_1=="Dhaka" & origin=="Bangladesh"
replace ID_GADM_fine="BGD4" if NAME_1=="Khulna" & origin=="Bangladesh"
replace ID_GADM_fine="BGD5" if NAME_1=="Rajshahi" & origin=="Bangladesh"
replace ID_GADM_fine="BGD6" if NAME_1=="Rangpur" & origin=="Bangladesh"
replace ID_GADM_fine="BGD7" if NAME_1=="Sylhet" & origin=="Bangladesh"

* BELARUS
replace NAME_1="Homyel'" if NAME_1=="Gomel" & origin=="Belarus"
replace NAME_1="Hrodna" if NAME_1=="Grodno" & origin=="Belarus"
replace NAME_1="Minsk" if NAME_1=="Minsk (Capital City)" & origin=="Belarus"
replace NAME_1="Vitsyebsk" if NAME_1=="Vitebsk" & origin=="Belarus"
replace ID_GADM_fine="BLR1" if NAME_1=="Brest" & origin=="Belarus"
replace ID_GADM_fine="BLR2" if NAME_1=="Homyel'" & origin=="Belarus"
replace ID_GADM_fine="BLR3" if NAME_1=="Hrodna" & origin=="Belarus"
replace ID_GADM_fine="BLR4" if NAME_1=="Mahilyow" & origin=="Belarus"
replace ID_GADM_fine="BLR5" if NAME_1=="Minsk" & origin=="Belarus"
replace ID_GADM_fine="BLR6" if NAME_1=="Vitsyebsk" & origin=="Belarus"

* BELGIUM
replace NAME_1="Bruxelles" if NAME_1=="Brussels" & origin=="Belgium"
replace NAME_1="Vlaanderen" if NAME_1=="Flanders" & origin=="Belgium"
replace NAME_1="Wallonie" if NAME_1=="Wallonia" & origin=="Belgium"
replace ID_GADM_fine="BEL1" if NAME_1=="Bruxelles" & origin=="Belgium"
replace ID_GADM_fine="BEL2" if NAME_1=="Vlaanderen" & origin=="Belgium"
replace ID_GADM_fine="BEL3" if NAME_1=="Wallonie" & origin=="Belgium"

* BELIZE // Not in GADM --> drop
drop if origin=="Belize"

* BHUTAN
replace NAME_1="Chhukha" if NAME_1=="Chukha" & origin=="Bhutan"
replace NAME_1="Sarpang" if NAME_1=="Sarpang" & origin=="Bhutan"
replace ID_GADM_fine="BTN2" if NAME_1=="Chhukha" & origin=="Bhutan"
replace ID_GADM_fine="BTN13" if NAME_1=="Sarpang" & origin=="Bhutan"

* BOLIVIA
replace ID_GADM_fine="BOL1" if NAME_1=="Chuquisaca" & origin=="Bolivia"
replace ID_GADM_fine="BOL2" if NAME_1=="Cochabamba" & origin=="Bolivia"
replace ID_GADM_fine="BOL3" if NAME_1=="El Beni" & origin=="Bolivia"
replace ID_GADM_fine="BOL4" if NAME_1=="La Paz" & origin=="Bolivia"
replace ID_GADM_fine="BOL5" if NAME_1=="Oruro" & origin=="Bolivia"
replace ID_GADM_fine="BOL6" if NAME_1=="Pando" & origin=="Bolivia"
replace ID_GADM_fine="BOL7" if NAME_1=="Potosí" & origin=="Bolivia"
replace ID_GADM_fine="BOL8" if NAME_1=="Santa Cruz" & origin=="Bolivia"
replace ID_GADM_fine="BOL9" if NAME_1=="Tarija" & origin=="Bolivia"

* BOSNIA-HERZEGOVINA
replace NAME_1="Federacija Bosna i Hercegovina" if NAME_1=="Bosnia and Herzegovina (Federation)" & origin=="Bosnia-Herzegovina"
replace NAME_1="Federacija Bosna i Hercegovina" if NAME_1=="Federation of Bosnia and Herzegovina" & origin=="Bosnia-Herzegovina"
replace NAME_1="Repuplika Srpska" if NAME_1=="Republika Srpska" & origin=="Bosnia-Herzegovina"
replace origin="Bosnia and Herzegovina" if origin=="Bosnia-Herzegovina"
replace ID_GADM_fine="BIH1" if NAME_1=="Brčko" & origin=="Bosnia and Herzegovina"
replace ID_GADM_fine="BIH2" if NAME_1=="Federacija Bosna i Hercegovina" & origin=="Bosnia and Herzegovina"
replace ID_GADM_fine="BIH3" if NAME_1=="Repuplika Srpska" & origin=="Bosnia and Herzegovina"

* BRAZIL
replace NAME_1="Ceará" if NAME_1=="Ceara" & origin=="Brazil"
replace NAME_1="Distrito Federal" if NAME_1=="Federal" & origin=="Brazil"
replace NAME_1="Maranhão" if NAME_1=="Maranhao" & origin=="Brazil"
replace NAME_1="São Paulo" if NAME_1=="Sao Paulo" & origin=="Brazil"
replace ID_GADM_fine="BRA1" if NAME_1=="Acre" & origin=="Brazil"
replace ID_GADM_fine="BRA2" if NAME_1=="Alagoas" & origin=="Brazil"
replace ID_GADM_fine="BRA3" if NAME_1=="Amapá" & origin=="Brazil"
replace ID_GADM_fine="BRA4" if NAME_1=="Amazonas" & origin=="Brazil"
replace ID_GADM_fine="BRA5" if NAME_1=="Bahia" & origin=="Brazil"
replace ID_GADM_fine="BRA6" if NAME_1=="Ceará" & origin=="Brazil"
replace ID_GADM_fine="BRA7" if NAME_1=="Distrito Federal" & origin=="Brazil"
replace ID_GADM_fine="BRA8" if NAME_1=="Espírito Santo" & origin=="Brazil"
replace ID_GADM_fine="BRA9" if NAME_1=="Goiás" & origin=="Brazil"
replace ID_GADM_fine="BRA10" if NAME_1=="Maranhão" & origin=="Brazil"
replace ID_GADM_fine="BRA11" if NAME_1=="Mato Grosso do Sul" & origin=="Brazil"
replace ID_GADM_fine="BRA12" if NAME_1=="Mato Grosso" & origin=="Brazil"
replace ID_GADM_fine="BRA13" if NAME_1=="Minas Gerais" & origin=="Brazil"
replace ID_GADM_fine="BRA14" if NAME_1=="Pará" & origin=="Brazil"
replace ID_GADM_fine="BRA15" if NAME_1=="Paraíba" & origin=="Brazil"
replace ID_GADM_fine="BRA16" if NAME_1=="Paraná" & origin=="Brazil"
replace ID_GADM_fine="BRA17" if NAME_1=="Pernambuco" & origin=="Brazil"
replace ID_GADM_fine="BRA18" if NAME_1=="Piauí" & origin=="Brazil"
replace ID_GADM_fine="BRA19" if NAME_1=="Rio de Janeiro" & origin=="Brazil"
replace ID_GADM_fine="BRA20" if NAME_1=="Rio Grande do Norte" & origin=="Brazil"
replace ID_GADM_fine="BRA21" if NAME_1=="Rio Grande do Sul" & origin=="Brazil"
replace ID_GADM_fine="BRA22" if NAME_1=="Rondônia" & origin=="Brazil"
replace ID_GADM_fine="BRA23" if NAME_1=="Roraima" & origin=="Brazil"
replace ID_GADM_fine="BRA24" if NAME_1=="Santa Catarina" & origin=="Brazil"
replace ID_GADM_fine="BRA25" if NAME_1=="São Paulo" & origin=="Brazil"
replace ID_GADM_fine="BRA26" if NAME_1=="Sergipe" & origin=="Brazil"
replace ID_GADM_fine="BRA27" if NAME_1=="Tocantins" & origin=="Brazil"

* BULGARIA
replace NAME_1="Sofia" if NAME_1=="Grad Sofia" & origin=="Bulgaria"
replace NAME_1="Vratsa" if NAME_1=="Orahovo" & origin=="Bulgaria"
replace NAME_1="Sofia" if NAME_1=="Sofia City" & origin=="Bulgaria"
replace NAME_1="Sofia" if NAME_1=="Sofia City (Province)" & origin=="Bulgaria"
replace ID_GADM_fine="BGR1" if NAME_1=="Blagoevgrad" & origin=="Bulgaria"
replace ID_GADM_fine="BGR2" if NAME_1=="Burgas" & origin=="Bulgaria"
replace ID_GADM_fine="BGR21" if NAME_1=="Sofia" & origin=="Bulgaria"
replace ID_GADM_fine="BGR6" if NAME_1=="Haskovo" & origin=="Bulgaria"
replace ID_GADM_fine="BGR27" if NAME_1=="Vratsa" & origin=="Bulgaria"
replace ID_GADM_fine="BGR14" if NAME_1=="Plovdiv" & origin=="Bulgaria"
replace ID_GADM_fine="BGR24" if NAME_1=="Varna" & origin=="Bulgaria"

* BURKINA FASO
replace NAME_1="Haut-Bassins" if NAME_1=="Hauts-Bassins" & origin=="Burkina Faso"
replace NAME_1="Sahel" if NAME_1=="Sahen" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA1" if NAME_1=="Boucle du Mouhoun" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA2" if NAME_1=="Cascades" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA3" if NAME_1=="Centre-Est" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA4" if NAME_1=="Centre-Nord" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA5" if NAME_1=="Centre-Ouest" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA6" if NAME_1=="Centre-Sud" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA7" if NAME_1=="Centre" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA8" if NAME_1=="Est" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA9" if NAME_1=="Haut-Bassins" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA10" if NAME_1=="Nord" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA11" if NAME_1=="Plateau-Central" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA12" if NAME_1=="Sahel" & origin=="Burkina Faso"
replace ID_GADM_fine="BFA13" if NAME_1=="Sud-Ouest" & origin=="Burkina Faso"

* BURUNDI
replace NAME_1="Amajyepfo" if NAME_1=="Gisagara" & origin=="Burundi"
replace NAME_1="Bururi" if NAME_1=="Rumonge" & origin=="Burundi"
replace ID_GADM_fine="BDI1" if NAME_1=="Bubanza" & origin=="Burundi"
replace ID_GADM_fine="BDI2" if NAME_1=="Bujumbura Mairie" & origin=="Burundi"
replace ID_GADM_fine="BDI3" if NAME_1=="Bujumbura Rural" & origin=="Burundi"
replace ID_GADM_fine="BDI4" if NAME_1=="Bururi" & origin=="Burundi"
replace ID_GADM_fine="BDI5" if NAME_1=="Cankuzo" & origin=="Burundi"
replace ID_GADM_fine="BDI6" if NAME_1=="Cibitoke" & origin=="Burundi"
replace ID_GADM_fine="BDI7" if NAME_1=="Gitega" & origin=="Burundi"
replace ID_GADM_fine="BDI8" if NAME_1=="Karuzi" & origin=="Burundi"
replace ID_GADM_fine="BDI9" if NAME_1=="Kayanza" & origin=="Burundi"
replace ID_GADM_fine="BDI10" if NAME_1=="Kirundo" & origin=="Burundi"
replace ID_GADM_fine="BDI11" if NAME_1=="Makamba" & origin=="Burundi"
replace ID_GADM_fine="BDI12" if NAME_1=="Muramvya" & origin=="Burundi"
replace ID_GADM_fine="BDI13" if NAME_1=="Muyinga" & origin=="Burundi"
replace ID_GADM_fine="BDI14" if NAME_1=="Mwaro" & origin=="Burundi"
replace ID_GADM_fine="BDI15" if NAME_1=="Ngozi" & origin=="Burundi"
replace ID_GADM_fine="BDI16" if NAME_1=="Rutana" & origin=="Burundi"
replace ID_GADM_fine="BDI17" if NAME_1=="Ruyigi" & origin=="Burundi"

* CAMBODIA
replace NAME_1="Batdâmbâng" if NAME_1=="Battambang (Province)" & origin=="Cambodia"
replace NAME_1="Kâmpóng Cham" if NAME_1=="Kampong Cham" & origin=="Cambodia"
replace NAME_1="Kâmpôt" if NAME_1=="Kampot" & origin=="Cambodia"
replace NAME_1="Phnom Penh" if NAME_1=="Monivong" & origin=="Cambodia"
replace NAME_1="Phnom Penh" if NAME_1=="Phnom Penh" & origin=="Cambodia"
replace NAME_1="Phnom Penh" if NAME_1=="Phnom Penh (Municipality)" & origin=="Cambodia"
replace NAME_1="Pouthisat" if NAME_1=="Pursat" & origin=="Cambodia"
replace ID_GADM_fine="KHM1" if NAME_1=="Bântéay Méanchey" & origin=="Cambodia"
replace ID_GADM_fine="KHM2" if NAME_1=="Batdâmbâng" & origin=="Cambodia"
replace ID_GADM_fine="KHM3" if NAME_1=="Kâmpóng Cham" & origin=="Cambodia"
replace ID_GADM_fine="KHM4" if NAME_1=="Kâmpóng Chhnang" & origin=="Cambodia"
replace ID_GADM_fine="KHM5" if NAME_1=="Kâmpóng Spœ" & origin=="Cambodia"
replace ID_GADM_fine="KHM6" if NAME_1=="Kâmpóng Thum" & origin=="Cambodia"
replace ID_GADM_fine="KHM7" if NAME_1=="Kâmpôt" & origin=="Cambodia"
replace ID_GADM_fine="KHM8" if NAME_1=="Kândal" & origin=="Cambodia"
replace ID_GADM_fine="KHM9" if NAME_1=="Kaôh Kong" & origin=="Cambodia"
replace ID_GADM_fine="KHM10" if NAME_1=="Kep" & origin=="Cambodia"
replace ID_GADM_fine="KHM11" if NAME_1=="Krâchéh" & origin=="Cambodia"
replace ID_GADM_fine="KHM12" if NAME_1=="Krong Pailin" & origin=="Cambodia"
replace ID_GADM_fine="KHM13" if NAME_1=="Krong Preah Sihanouk" & origin=="Cambodia"
replace ID_GADM_fine="KHM14" if NAME_1=="Môndól Kiri" & origin=="Cambodia"
replace ID_GADM_fine="KHM15" if NAME_1=="Otdar Mean Chey" & origin=="Cambodia"
replace ID_GADM_fine="KHM16" if NAME_1=="Phnom Penh" & origin=="Cambodia"
replace ID_GADM_fine="KHM17" if NAME_1=="Pouthisat" & origin=="Cambodia"
replace ID_GADM_fine="KHM18" if NAME_1=="Preah Vihéar" & origin=="Cambodia"
replace ID_GADM_fine="KHM19" if NAME_1=="Prey Vêng" & origin=="Cambodia"
replace ID_GADM_fine="KHM20" if NAME_1=="Rôtânôkiri" & origin=="Cambodia"
replace ID_GADM_fine="KHM21" if NAME_1=="Siemréab" & origin=="Cambodia"
replace ID_GADM_fine="KHM22" if NAME_1=="Stœng Trêng" & origin=="Cambodia"
replace ID_GADM_fine="KHM23" if NAME_1=="Svay Rieng" & origin=="Cambodia"
replace ID_GADM_fine="KHM24" if NAME_1=="Takêv" & origin=="Cambodia"
replace ID_GADM_fine="KHM25" if NAME_1=="Tbong Khmum" & origin=="Cambodia"

* CAMEROON
replace origin="Nigeria" if NAME_1=="Adamawa"
replace NAME_1="Est" if NAME_1=="East" & origin=="Cameroon"
replace NAME_1="Extrême-Nord" if NAME_1=="Extreme-North" & origin=="Cameroon"
replace NAME_1="Nord" if NAME_1=="North" & origin=="Cameroon"
replace NAME_1="Sud-Ouest" if NAME_1=="Southwest" & origin=="Cameroon"
replace ID_GADM_fine="CMR1" if NAME_1=="Adamaoua" & origin=="Cameroon"
replace ID_GADM_fine="CMR2" if NAME_1=="Centre" & origin=="Cameroon"
replace ID_GADM_fine="CMR3" if NAME_1=="Est" & origin=="Cameroon"
replace ID_GADM_fine="CMR4" if NAME_1=="Extrême-Nord" & origin=="Cameroon"
replace ID_GADM_fine="CMR5" if NAME_1=="Littoral" & origin=="Cameroon"
replace ID_GADM_fine="CMR6" if NAME_1=="Nord-Ouest" & origin=="Cameroon"
replace ID_GADM_fine="CMR7" if NAME_1=="Nord" & origin=="Cameroon"
replace ID_GADM_fine="CMR8" if NAME_1=="Ouest" & origin=="Cameroon"
replace ID_GADM_fine="CMR9" if NAME_1=="Sud-Ouest" & origin=="Cameroon"
replace ID_GADM_fine="CMR10" if NAME_1=="Sud" & origin=="Cameroon"

* CANADA
replace NAME_1="British Columbia" if NAME_1=="British Colombia" & origin=="Canada"
replace NAME_1="British Columbia" if NAME_1=="British Colombia (Province)" & origin=="Canada"
replace NAME_1="British Columbia" if NAME_1=="British Columbia" & origin=="Canada"
replace NAME_1="New Brunswick" if NAME_1=="New Brunswick" & origin=="Canada"
replace NAME_1="Québec" if NAME_1=="Quebec" & origin=="Canada"
replace NAME_1="Québec" if NAME_1=="Quebec (Province)" & origin=="Canada"
replace ID_GADM_fine="CAN1" if NAME_1=="Alberta" & origin=="Canada"
replace ID_GADM_fine="CAN2" if NAME_1=="British Columbia" & origin=="Canada"
replace ID_GADM_fine="CAN3" if NAME_1=="Manitoba" & origin=="Canada"
replace ID_GADM_fine="CAN4" if NAME_1=="New Brunswick" & origin=="Canada"
replace ID_GADM_fine="CAN5" if NAME_1=="Newfoundland and Labrador" & origin=="Canada"
replace ID_GADM_fine="CAN6" if NAME_1=="Northwest Territories" & origin=="Canada"
replace ID_GADM_fine="CAN7" if NAME_1=="Nova Scotia" & origin=="Canada"
replace ID_GADM_fine="CAN8" if NAME_1=="Nunavut" & origin=="Canada"
replace ID_GADM_fine="CAN9" if NAME_1=="Ontario" & origin=="Canada"
replace ID_GADM_fine="CAN10" if NAME_1=="Prince Edward Island" & origin=="Canada"
replace ID_GADM_fine="CAN11" if NAME_1=="Québec" & origin=="Canada"
replace ID_GADM_fine="CAN12" if NAME_1=="Saskatchewan" & origin=="Canada"
replace ID_GADM_fine="CAN13" if NAME_1=="Yukon" & origin=="Canada"

* CENTRAL AFRICAN REPUBLIC
replace NAME_1="Kémo" if NAME_1=="Kemo" & origin=="Central African Republic"
replace NAME_1="Mambéré-Kadéï" if NAME_1=="Mambere Kadei" & origin=="Central African Republic"
replace NAME_1="Nana-Grébizi" if NAME_1=="Nana-Grebizi" & origin=="Central African Republic"
replace NAME_1="Nana-Mambéré" if NAME_1=="Nana-Mambere" & origin=="Central African Republic"
replace NAME_1="Ombella-M'Poko" if NAME_1=="Ombella-M'Poko" & origin=="Central African Republic"
replace NAME_1="Ouham-Pendé" if NAME_1=="Ouham-Pende" & origin=="Central African Republic"
replace NAME_1="Sangha-Mbaéré" if NAME_1=="Sangha-Mbaere" & origin=="Central African Republic"
replace ID_GADM_fine="CAF1" if NAME_1=="Bamingui-Bangoran" & origin=="Central African Republic"
replace ID_GADM_fine="CAF2" if NAME_1=="Bangui" & origin=="Central African Republic"
replace ID_GADM_fine="CAF3" if NAME_1=="Basse-Kotto" & origin=="Central African Republic"
replace ID_GADM_fine="CAF4" if NAME_1=="Haut-Mbomou" & origin=="Central African Republic"
replace ID_GADM_fine="CAF5" if NAME_1=="Haute-Kotto" & origin=="Central African Republic"
replace ID_GADM_fine="CAF6" if NAME_1=="Kémo" & origin=="Central African Republic"
replace ID_GADM_fine="CAF7" if NAME_1=="Lobaye" & origin=="Central African Republic"
replace ID_GADM_fine="CAF8" if NAME_1=="Mambéré-Kadéï" & origin=="Central African Republic"
replace ID_GADM_fine="CAF9" if NAME_1=="Mbomou" & origin=="Central African Republic"
replace ID_GADM_fine="CAF10" if NAME_1=="Nana-Grébizi" & origin=="Central African Republic"
replace ID_GADM_fine="CAF11" if NAME_1=="Nana-Mambéré" & origin=="Central African Republic"
replace ID_GADM_fine="CAF12" if NAME_1=="Ombella-M'Poko" & origin=="Central African Republic"
replace ID_GADM_fine="CAF13" if NAME_1=="Ouaka" & origin=="Central African Republic"
replace ID_GADM_fine="CAF14" if NAME_1=="Ouham-Pendé" & origin=="Central African Republic"
replace ID_GADM_fine="CAF15" if NAME_1=="Ouham" & origin=="Central African Republic"
replace ID_GADM_fine="CAF16" if NAME_1=="Sangha-Mbaéré" & origin=="Central African Republic"
replace ID_GADM_fine="CAF17" if NAME_1=="Vakaga" & origin=="Central African Republic"

* CHAD
replace NAME_1="Ennedi Ouest" if NAME_1=="Ennedi-Ouest" & origin=="Chad"
replace NAME_1="Guéra" if NAME_1=="Guera" & origin=="Chad"
replace NAME_1="Ville de N'Djamena" if NAME_1=="N'Djamena" & origin=="Chad"
replace NAME_1="Ouaddaï" if NAME_1=="Ouaddai" & origin=="Chad"
replace NAME_1="Tibesti" if NAME_1=="Tibesti" & origin=="Chad"
replace NAME_1="Wadi Fira" if NAME_1=="Wadi Fira" & origin=="Chad"
replace ID_GADM_fine="TCD1" if NAME_1=="Barh el Ghazel" & origin=="Chad"
replace ID_GADM_fine="TCD2" if NAME_1=="Batha" & origin=="Chad"
replace ID_GADM_fine="TCD3" if NAME_1=="Borkou" & origin=="Chad"
replace ID_GADM_fine="TCD4" if NAME_1=="Chari-Baguirmi" & origin=="Chad"
replace ID_GADM_fine="TCD5" if NAME_1=="Ennedi Est" & origin=="Chad"
replace ID_GADM_fine="TCD6" if NAME_1=="Ennedi Ouest" & origin=="Chad"
replace ID_GADM_fine="TCD7" if NAME_1=="Guéra" & origin=="Chad"
replace ID_GADM_fine="TCD8" if NAME_1=="Hadjer-Lamis" & origin=="Chad"
replace ID_GADM_fine="TCD9" if NAME_1=="Kanem" & origin=="Chad"
replace ID_GADM_fine="TCD10" if NAME_1=="Lac" & origin=="Chad"
replace ID_GADM_fine="TCD11" if NAME_1=="Logone Occidental" & origin=="Chad"
replace ID_GADM_fine="TCD12" if NAME_1=="Logone Oriental" & origin=="Chad"
replace ID_GADM_fine="TCD13" if NAME_1=="Mandoul" & origin=="Chad"
replace ID_GADM_fine="TCD14" if NAME_1=="Mayo-Kebbi Est" & origin=="Chad"
replace ID_GADM_fine="TCD15" if NAME_1=="Mayo-Kebbi Ouest" & origin=="Chad"
replace ID_GADM_fine="TCD16" if NAME_1=="Moyen-Chari" & origin=="Chad"
replace ID_GADM_fine="TCD17" if NAME_1=="Ouaddaï" & origin=="Chad"
replace ID_GADM_fine="TCD18" if NAME_1=="Salamat" & origin=="Chad"
replace ID_GADM_fine="TCD19" if NAME_1=="Sila" & origin=="Chad"
replace ID_GADM_fine="TCD20" if NAME_1=="Tandjilé" & origin=="Chad"
replace ID_GADM_fine="TCD21" if NAME_1=="Tibesti" & origin=="Chad"
replace ID_GADM_fine="TCD22" if NAME_1=="Ville de N'Djamena" & origin=="Chad"
replace ID_GADM_fine="TCD23" if NAME_1=="Wadi Fira" & origin=="Chad"

* CHILE
replace NAME_1="Araucanía" if NAME_1=="Araucania" & origin=="Chile"
replace NAME_1="Bío-Bío" if NAME_1=="Bio-Bio" & origin=="Chile"
replace NAME_1="Región Metropolitana de Santiago" if NAME_1=="Santiago Metropolitan" & origin=="Chile"
replace NAME_1="Valparaíso" if NAME_1=="Valparaiso" & origin=="Chile"
replace ID_GADM_fine="CHL1" if NAME_1=="Aisén del General Carlos Ibáñez del Campo" & origin=="Chile"
replace ID_GADM_fine="CHL2" if NAME_1=="Antofagasta" & origin=="Chile"
replace ID_GADM_fine="CHL3" if NAME_1=="Araucanía" & origin=="Chile"
replace ID_GADM_fine="CHL4" if NAME_1=="Arica y Parinacota" & origin=="Chile"
replace ID_GADM_fine="CHL5" if NAME_1=="Atacama" & origin=="Chile"
replace ID_GADM_fine="CHL6" if NAME_1=="Bío-Bío" & origin=="Chile"
replace ID_GADM_fine="CHL7" if NAME_1=="Coquimbo" & origin=="Chile"
replace ID_GADM_fine="CHL8" if NAME_1=="Libertador General Bernardo O'Higgins" & origin=="Chile"
replace ID_GADM_fine="CHL9" if NAME_1=="Los Lagos" & origin=="Chile"
replace ID_GADM_fine="CHL10" if NAME_1=="Los Ríos" & origin=="Chile"
replace ID_GADM_fine="CHL11" if NAME_1=="Magallanes y Antártica Chilena" & origin=="Chile"
replace ID_GADM_fine="CHL12" if NAME_1=="Maule" & origin=="Chile"
replace ID_GADM_fine="CHL13" if NAME_1=="Ñuble" & origin=="Chile"
replace ID_GADM_fine="CHL14" if NAME_1=="Región Metropolitana de Santiago" & origin=="Chile"
replace ID_GADM_fine="CHL15" if NAME_1=="Tarapacá" & origin=="Chile"
replace ID_GADM_fine="CHL16" if NAME_1=="Valparaíso" & origin=="Chile"

* CHINA
replace NAME_1="Beijing" if NAME_1=="Beijing (Municipality)" & origin=="China"
replace NAME_1="Fujian" if NAME_1=="Fujian (Province)" & origin=="China"
replace NAME_1="Guangdong" if NAME_1=="Guangdong" & origin=="China"
replace NAME_1="Guangdong" if NAME_1=="Guangdong (Province)" & origin=="China"
replace NAME_1="Guangxi" if NAME_1=="Guangxi" & origin=="China"
replace NAME_1="Guizhou" if NAME_1=="Guizhou" & origin=="China"
replace NAME_1="Hebei" if NAME_1=="Hebei (Province)" & origin=="China"
replace NAME_1="Heilongjiang" if NAME_1=="Heilongjiang" & origin=="China"
replace NAME_1="Henan" if NAME_1=="Henan (Province)" & origin=="China"
drop if NAME_1=="Hong Kong" & origin=="China"
drop if NAME_1=="Hong Kong Special Administrative Region (hksar)" & origin=="China"
replace NAME_1="Hubei" if NAME_1=="Hubei (Province)" & origin=="China"
replace NAME_1="Nei Mongol" if NAME_1=="Inner Mongolia" & origin=="China"
replace NAME_1="Shaanxi" if NAME_1=="Shaanxi (Province)" & origin=="China"
replace NAME_1="Shandong" if NAME_1=="Shandong (Province)" & origin=="China"
replace NAME_1="Xizang" if NAME_1=="Tibet" & origin=="China"
replace NAME_1="Xinjiang Uygur" if NAME_1=="Xinjiang" & origin=="China"
replace NAME_1="Xinjiang Uygur" if NAME_1=="Xinjiang Uyghur" & origin=="China"
replace NAME_1="Yunnan" if NAME_1=="Yunnan" & origin=="China"
replace NAME_1="Yunnan" if NAME_1=="Yunnan (Province)" & origin=="China"
replace NAME_1="Zhejiang" if NAME_1=="Zhejiang" & origin=="China"
replace ID_GADM_fine="CHN1" if NAME_1=="Anhui" & origin=="China"
replace ID_GADM_fine="CHN2" if NAME_1=="Beijing" & origin=="China"
replace ID_GADM_fine="CHN3" if NAME_1=="Chongqing" & origin=="China"
replace ID_GADM_fine="CHN4" if NAME_1=="Fujian" & origin=="China"
replace ID_GADM_fine="CHN5" if NAME_1=="Gansu" & origin=="China"
replace ID_GADM_fine="CHN6" if NAME_1=="Guangdong" & origin=="China"
replace ID_GADM_fine="CHN7" if NAME_1=="Guangxi" & origin=="China"
replace ID_GADM_fine="CHN8" if NAME_1=="Guizhou" & origin=="China"
replace ID_GADM_fine="CHN9" if NAME_1=="Hainan" & origin=="China"
replace ID_GADM_fine="CHN10" if NAME_1=="Hebei" & origin=="China"
replace ID_GADM_fine="CHN11" if NAME_1=="Heilongjiang" & origin=="China"
replace ID_GADM_fine="CHN12" if NAME_1=="Henan" & origin=="China"
replace ID_GADM_fine="CHN13" if NAME_1=="Hubei" & origin=="China"
replace ID_GADM_fine="CHN14" if NAME_1=="Hunan" & origin=="China"
replace ID_GADM_fine="CHN15" if NAME_1=="Jiangsu" & origin=="China"
replace ID_GADM_fine="CHN16" if NAME_1=="Jiangxi" & origin=="China"
replace ID_GADM_fine="CHN17" if NAME_1=="Jilin" & origin=="China"
replace ID_GADM_fine="CHN18" if NAME_1=="Liaoning" & origin=="China"
replace ID_GADM_fine="CHN19" if NAME_1=="Nei Mongol" & origin=="China"
replace ID_GADM_fine="CHN20" if NAME_1=="Ningxia Hui" & origin=="China"
replace ID_GADM_fine="CHN21" if NAME_1=="Qinghai" & origin=="China"
replace ID_GADM_fine="CHN22" if NAME_1=="Shaanxi" & origin=="China"
replace ID_GADM_fine="CHN23" if NAME_1=="Shandong" & origin=="China"
replace ID_GADM_fine="CHN24" if NAME_1=="Shanghai" & origin=="China"
replace ID_GADM_fine="CHN25" if NAME_1=="Shanxi" & origin=="China"
replace ID_GADM_fine="CHN26" if NAME_1=="Sichuan" & origin=="China"
replace ID_GADM_fine="CHN27" if NAME_1=="Tianjin" & origin=="China"
replace ID_GADM_fine="CHN28" if NAME_1=="Xinjiang Uygur" & origin=="China"
replace ID_GADM_fine="CHN29" if NAME_1=="Xizang" & origin=="China"
replace ID_GADM_fine="CHN30" if NAME_1=="Yunnan" & origin=="China"
replace ID_GADM_fine="CHN31" if NAME_1=="Zhejiang" & origin=="China"

* COLOMBIA
replace NAME_1="Atlántico" if NAME_1=="Atlantico" & origin=="Colombia"
replace NAME_1="Cundinamarca" if NAME_1=="Bogota" & origin=="Colombia"
replace NAME_1="Bolívar" if NAME_1=="Bolivar" & origin=="Colombia"
replace NAME_1="Boyacá" if NAME_1=="Boyaca" & origin=="Colombia"
replace NAME_1="Canindeyú" if NAME_1=="Canindeyu" & origin=="Colombia"
replace origin="Paraguay" if NAME_1=="Canindeyú"
replace NAME_1="Caquetá" if NAME_1=="Caqueta" & origin=="Colombia"
replace NAME_1="Chocó" if NAME_1=="Choco" & origin=="Colombia"
replace NAME_1="Córdoba" if NAME_1=="Cordoba" & origin=="Colombia"
replace NAME_1="Guainía" if NAME_1=="Guainia" & origin=="Colombia"
replace NAME_1="Nariño" if NAME_1=="Narino" & origin=="Colombia"
replace origin="Ecuador" if NAME_1=="Pichincha"
replace NAME_1="Quindío" if NAME_1=="Quindio" & origin=="Colombia"
replace NAME_1="Vaupés" if NAME_1=="Vaupes" & origin=="Colombia"
replace ID_GADM_fine="COL1" if NAME_1=="Amazonas" & origin=="Colombia"
replace ID_GADM_fine="COL2" if NAME_1=="Antioquia" & origin=="Colombia"
replace ID_GADM_fine="COL3" if NAME_1=="Arauca" & origin=="Colombia"
replace ID_GADM_fine="COL4" if NAME_1=="Atlántico" & origin=="Colombia"
replace ID_GADM_fine="COL5" if NAME_1=="Bolívar" & origin=="Colombia"
replace ID_GADM_fine="COL6" if NAME_1=="Boyacá" & origin=="Colombia"
replace ID_GADM_fine="COL7" if NAME_1=="Caldas" & origin=="Colombia"
replace ID_GADM_fine="COL8" if NAME_1=="Caquetá" & origin=="Colombia"
replace ID_GADM_fine="COL9" if NAME_1=="Casanare" & origin=="Colombia"
replace ID_GADM_fine="COL10" if NAME_1=="Cauca" & origin=="Colombia"
replace ID_GADM_fine="COL11" if NAME_1=="Cesar" & origin=="Colombia"
replace ID_GADM_fine="COL12" if NAME_1=="Chocó" & origin=="Colombia"
replace ID_GADM_fine="COL13" if NAME_1=="Córdoba" & origin=="Colombia"
replace ID_GADM_fine="COL14" if NAME_1=="Cundinamarca" & origin=="Colombia"
replace ID_GADM_fine="COL15" if NAME_1=="Guainía" & origin=="Colombia"
replace ID_GADM_fine="COL16" if NAME_1=="Guaviare" & origin=="Colombia"
replace ID_GADM_fine="COL17" if NAME_1=="Huila" & origin=="Colombia"
replace ID_GADM_fine="COL18" if NAME_1=="La Guajira" & origin=="Colombia"
replace ID_GADM_fine="COL19" if NAME_1=="Magdalena" & origin=="Colombia"
replace ID_GADM_fine="COL20" if NAME_1=="Meta" & origin=="Colombia"
replace ID_GADM_fine="COL21" if NAME_1=="Nariño" & origin=="Colombia"
replace ID_GADM_fine="COL22" if NAME_1=="Norte de Santander" & origin=="Colombia"
replace ID_GADM_fine="COL23" if NAME_1=="Putumayo" & origin=="Colombia"
replace ID_GADM_fine="COL24" if NAME_1=="Quindío" & origin=="Colombia"
replace ID_GADM_fine="COL25" if NAME_1=="Risaralda" & origin=="Colombia"
replace ID_GADM_fine="COL26" if NAME_1=="San Andrés y Providencia" & origin=="Colombia"
replace ID_GADM_fine="COL27" if NAME_1=="Santander" & origin=="Colombia"
replace ID_GADM_fine="COL28" if NAME_1=="Sucre" & origin=="Colombia"
replace ID_GADM_fine="COL29" if NAME_1=="Tolima" & origin=="Colombia"
replace ID_GADM_fine="COL30" if NAME_1=="Valle del Cauca" & origin=="Colombia"
replace ID_GADM_fine="COL31" if NAME_1=="Vaupés" & origin=="Colombia"
replace ID_GADM_fine="COL32" if NAME_1=="Vichada" & origin=="Colombia"

* COSTA RICA
replace ID_GADM_fine="CRI1" if NAME_1=="Alajuela" & origin=="Costa Rica"
replace ID_GADM_fine="CRI2" if NAME_1=="Cartago" & origin=="Costa Rica"
replace ID_GADM_fine="CRI3" if NAME_1=="Guanacaste" & origin=="Costa Rica"
replace ID_GADM_fine="CRI4" if NAME_1=="Heredia" & origin=="Costa Rica"
replace ID_GADM_fine="CRI5" if NAME_1=="Limón" & origin=="Costa Rica"
replace ID_GADM_fine="CRI6" if NAME_1=="Puntarenas" & origin=="Costa Rica"
replace ID_GADM_fine="CRI7" if NAME_1=="San José" & origin=="Costa Rica"

* CROATIA
replace NAME_1="Splitsko-Dalmatinska" if NAME_1=="Dalmatia" & origin=="Croatia"
replace NAME_1="Istarska" if NAME_1=="Istria (County)" & origin=="Croatia"
replace NAME_1="Licko-Senjska" if NAME_1=="Lika" & origin=="Croatia"
replace NAME_1="Vukovarsko-Srijemska" if NAME_1=="Vukovar-Syrmia" & origin=="Croatia"
replace NAME_1="Zadarska" if NAME_1=="Zadar (County)" & origin=="Croatia"
replace NAME_1="Zagrebačka" if NAME_1=="Zagreb" & origin=="Croatia"
replace NAME_1="Zagrebačka" if NAME_1=="Zagreb (City)" & origin=="Croatia"
replace NAME_1="Zagrebačka" if NAME_1=="Zagreb (County)" & origin=="Croatia"
replace ID_GADM_fine="HRV1" if NAME_1=="Bjelovarska-Bilogorska" & origin=="Croatia"
replace ID_GADM_fine="HRV2" if NAME_1=="Brodsko-Posavska" & origin=="Croatia"
replace ID_GADM_fine="HRV3" if NAME_1=="Dubrovacko-Neretvanska" & origin=="Croatia"
replace ID_GADM_fine="HRV4" if NAME_1=="Grad Zagreb" & origin=="Croatia"
replace ID_GADM_fine="HRV5" if NAME_1=="Istarska" & origin=="Croatia"
replace ID_GADM_fine="HRV6" if NAME_1=="Karlovacka" & origin=="Croatia"
replace ID_GADM_fine="HRV7" if NAME_1=="Koprivničko-Križevačka" & origin=="Croatia"
replace ID_GADM_fine="HRV8" if NAME_1=="Krapinsko-Zagorska" & origin=="Croatia"
replace ID_GADM_fine="HRV9" if NAME_1=="Licko-Senjska" & origin=="Croatia"
replace ID_GADM_fine="HRV10" if NAME_1=="Medimurska" & origin=="Croatia"
replace ID_GADM_fine="HRV11" if NAME_1=="Osjecko-Baranjska" & origin=="Croatia"
replace ID_GADM_fine="HRV12" if NAME_1=="Požeško-Slavonska" & origin=="Croatia"
replace ID_GADM_fine="HRV13" if NAME_1=="Primorsko-Goranska" & origin=="Croatia"
replace ID_GADM_fine="HRV14" if NAME_1=="Šibensko-Kninska" & origin=="Croatia"
replace ID_GADM_fine="HRV15" if NAME_1=="Sisacko-Moslavacka" & origin=="Croatia"
replace ID_GADM_fine="HRV16" if NAME_1=="Splitsko-Dalmatinska" & origin=="Croatia"
replace ID_GADM_fine="HRV17" if NAME_1=="Varaždinska" & origin=="Croatia"
replace ID_GADM_fine="HRV18" if NAME_1=="Viroviticko-Podravska" & origin=="Croatia"
replace ID_GADM_fine="HRV19" if NAME_1=="Vukovarsko-Srijemska" & origin=="Croatia"
replace ID_GADM_fine="HRV20" if NAME_1=="Zadarska" & origin=="Croatia"
replace ID_GADM_fine="HRV21" if NAME_1=="Zagrebačka" & origin=="Croatia"

* CUBA
replace NAME_1="Ciudad de la Habana" if NAME_1=="Havana (Province)" & origin=="Cuba"
replace ID_GADM_fine="CUB4" if NAME_1=="Ciudad de la Habana" & origin=="Cuba"

* CYPRUS // // Not in GADM --> copy GWP codes
replace NAME_1="Larnaka" if NAME_1=="Larnaca" & origin=="Cyprus"
replace NAME_1="Pafos" if NAME_1=="Paphos" & origin=="Cyprus"
replace ID_GADM_fine="CYP1" if NAME_1=="Nicosia" & origin=="Cyprus"
replace ID_GADM_fine="CYP2" if NAME_1=="Limassol" & origin=="Cyprus"
replace ID_GADM_fine="CYP3" if NAME_1=="Larnaka" & origin=="Cyprus"
replace ID_GADM_fine="CYP4" if NAME_1=="Pafos" & origin=="Cyprus"
replace ID_GADM_fine="CYP5" if NAME_1=="Famagusta" & origin=="Cyprus"

* CZECH REPUBLIC
replace NAME_1="Středočeský" if NAME_1=="Central Bohemia" & origin=="Czech Republic"
replace NAME_1="Jihomoravský" if NAME_1=="Jihomoravsky" & origin=="Czech Republic"
replace NAME_1="Liberecký" if NAME_1=="Liberec (Region)" & origin=="Czech Republic"
replace NAME_1="Moravskoslezský" if NAME_1=="North Moravia (Province)" & origin=="Czech Republic"
replace NAME_1="Prague" if NAME_1=="Prague" & origin=="Czech Republic"
replace NAME_1="Prague" if NAME_1=="Praha" & origin=="Czech Republic"
replace NAME_1="Jihočeský" if NAME_1=="South Bohemia" & origin=="Czech Republic"
replace NAME_1="Ústecký" if NAME_1=="Usti nad Labem" & origin=="Czech Republic"
replace ID_GADM_fine="CZE1" if NAME_1=="Jihočeský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE2" if NAME_1=="Jihomoravský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE3" if NAME_1=="Karlovarský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE4" if NAME_1=="Kraj Vysočina" & origin=="Czech Republic"
replace ID_GADM_fine="CZE5" if NAME_1=="Královéhradecký" & origin=="Czech Republic"
replace ID_GADM_fine="CZE6" if NAME_1=="Liberecký" & origin=="Czech Republic"
replace ID_GADM_fine="CZE7" if NAME_1=="Moravskoslezský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE8" if NAME_1=="Olomoucký" & origin=="Czech Republic"
replace ID_GADM_fine="CZE9" if NAME_1=="Pardubický" & origin=="Czech Republic"
replace ID_GADM_fine="CZE10" if NAME_1=="Plzeňský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE11" if NAME_1=="Prague" & origin=="Czech Republic"
replace ID_GADM_fine="CZE12" if NAME_1=="Středočeský" & origin=="Czech Republic"
replace ID_GADM_fine="CZE13" if NAME_1=="Ústecký" & origin=="Czech Republic"
replace ID_GADM_fine="CZE14" if NAME_1=="Zlínský" & origin=="Czech Republic"

* DEMOCRATIC REPUBLIC OF THE CONGO
replace NAME_1="Kwilu" if NAME_1=="Bandundu" & origin=="Democratic Republic of the Congo"
replace NAME_1="Kongo-Central" if NAME_1=="Bas-Congo" & origin=="Democratic Republic of the Congo"
replace NAME_1="Bas-Uélé" if NAME_1=="Bas-Uele" & origin=="Democratic Republic of the Congo"
replace NAME_1="Équateur" if NAME_1=="Equateur" & origin=="Democratic Republic of the Congo"
replace NAME_1="Équateur" if NAME_1=="Equator" & origin=="Democratic Republic of the Congo"
replace NAME_1="Tshopo" if NAME_1=="Haut Congo" & origin=="Democratic Republic of the Congo"
replace NAME_1="Haut-Katanga" if NAME_1=="Haut-Katanga" & origin=="Democratic Republic of the Congo"
replace NAME_1="Haut-Uélé" if NAME_1=="Haut-Uele" & origin=="Democratic Republic of the Congo"
replace NAME_1="Ituri" if NAME_1=="Ituri" & origin=="Democratic Republic of the Congo"
replace NAME_1="Kasaï-Central" if NAME_1=="Kasai Central" & origin=="Democratic Republic of the Congo"
replace NAME_1="Kasaï-Oriental" if NAME_1=="Kasai Oriental" & origin=="Democratic Republic of the Congo"
replace NAME_1="Kasaï-Oriental" if NAME_1=="Kasai-Oriental" & origin=="Democratic Republic of the Congo"
replace NAME_1="Haut-Katanga" if NAME_1=="Katanga" & origin=="Democratic Republic of the Congo"
replace NAME_1="Nord-Kivu" if NAME_1=="North Kivu" & origin=="Democratic Republic of the Congo"
replace NAME_1="Tshopo" if NAME_1=="Orientale" & origin=="Democratic Republic of the Congo"
replace NAME_1="Sud-Kivu" if NAME_1=="South Kivu" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD1" if NAME_1=="Bas-Uélé" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD2" if NAME_1=="Équateur" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD3" if NAME_1=="Haut-Katanga" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD4" if NAME_1=="Haut-Lomami" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD5" if NAME_1=="Haut-Uélé" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD6" if NAME_1=="Ituri" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD7" if NAME_1=="Kasaï-Central" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD8" if NAME_1=="Kasaï-Oriental" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD9" if NAME_1=="Kasaï" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD10" if NAME_1=="Kinshasa" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD11" if NAME_1=="Kongo-Central" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD12" if NAME_1=="Kwango" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD13" if NAME_1=="Kwilu" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD14" if NAME_1=="Lomami" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD15" if NAME_1=="Lualaba" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD16" if NAME_1=="Maï-Ndombe" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD17" if NAME_1=="Maniema" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD18" if NAME_1=="Mongala" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD19" if NAME_1=="Nord-Kivu" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD20" if NAME_1=="Nord-Ubangi" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD21" if NAME_1=="Sankuru" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD22" if NAME_1=="Sud-Kivu" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD23" if NAME_1=="Sud-Ubangi" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD24" if NAME_1=="Tanganyika" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD25" if NAME_1=="Tshopo" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COD26" if NAME_1=="Tshuapa" & origin=="Democratic Republic of the Congo"

* DENMARK
replace NAME_1="Hovedstaden" if NAME_1=="Capital" & origin=="Denmark"
replace NAME_1="Syddanmark" if NAME_1=="Southern" & origin=="Denmark"
replace ID_GADM_fine="DNK1" if NAME_1=="Hovedstaden" & origin=="Denmark"
replace ID_GADM_fine="DNK2" if NAME_1=="Midtjylland" & origin=="Denmark"
replace ID_GADM_fine="DNK3" if NAME_1=="Nordjylland" & origin=="Denmark"
replace ID_GADM_fine="DNK4" if NAME_1=="Sjælland" & origin=="Denmark"
replace ID_GADM_fine="DNK5" if NAME_1=="Syddanmark" & origin=="Denmark"

* DJIBOUTI
replace ID_GADM_fine="DJI1" if NAME_1=="Ali Sabieh" & origin=="Djibouti"
replace ID_GADM_fine="DJI2" if NAME_1=="Dikhil" & origin=="Djibouti"
replace ID_GADM_fine="DJI3" if NAME_1=="Djibouti" & origin=="Djibouti"
replace ID_GADM_fine="DJI4" if NAME_1=="Obock" & origin=="Djibouti"
replace ID_GADM_fine="DJI5" if NAME_1=="Tadjourah" & origin=="Djibouti"

* DOMINICAN REPUBLIC
replace ID_GADM_fine="DOM1" if NAME_1=="Azua" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM2" if NAME_1=="Bahoruco" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM3" if NAME_1=="Barahona" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM4" if NAME_1=="Dajabón" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM5" if NAME_1=="Distrito Nacional" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM6" if NAME_1=="Duarte" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM7" if NAME_1=="El Seybo" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM8" if NAME_1=="Espaillat" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM9" if NAME_1=="Hato Mayor" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM10" if NAME_1=="Independencia" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM11" if NAME_1=="La Altagracia" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM12" if NAME_1=="La Estrelleta" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM13" if NAME_1=="La Romana" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM14" if NAME_1=="La Vega" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM15" if NAME_1=="María Trinidad Sánchez" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM16" if NAME_1=="Monseñor Nouel" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM17" if NAME_1=="Monte Cristi" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM18" if NAME_1=="Monte Plata" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM19" if NAME_1=="Pedernales" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM20" if NAME_1=="Peravia" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM21" if NAME_1=="Puerto Plata" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM22" if NAME_1=="Salcedo" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM23" if NAME_1=="Samaná" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM24" if NAME_1=="San Cristóbal" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM25" if NAME_1=="San José de Ocoa" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM26" if NAME_1=="San Juan" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM27" if NAME_1=="San Pedro de Macorís" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM30" if NAME_1=="Santiago" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM29" if NAME_1=="Santiago Rodríguez" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM31" if NAME_1=="Santo Domingo" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM28" if NAME_1=="Sánchez Ramírez" & origin=="Dominican Republic"
replace ID_GADM_fine="DOM32" if NAME_1=="Valverde" & origin=="Dominican Republic"

* EAST TIMOR // Not in GWP --> drop
drop if origin=="East Timor"

* ECUADOR
replace ID_GADM_fine="ECU1" if NAME_1=="Azuay" & origin=="Ecuador"
replace ID_GADM_fine="ECU2" if NAME_1=="Bolivar" & origin=="Ecuador"
replace ID_GADM_fine="ECU3" if NAME_1=="Cañar" & origin=="Ecuador"
replace ID_GADM_fine="ECU4" if NAME_1=="Carchi" & origin=="Ecuador"
replace ID_GADM_fine="ECU5" if NAME_1=="Chimborazo" & origin=="Ecuador"
replace ID_GADM_fine="ECU6" if NAME_1=="Cotopaxi" & origin=="Ecuador"
replace ID_GADM_fine="ECU7" if NAME_1=="El Oro" & origin=="Ecuador"
replace ID_GADM_fine="ECU8" if NAME_1=="Esmeraldas" & origin=="Ecuador"
replace ID_GADM_fine="ECU9" if NAME_1=="Galápagos" & origin=="Ecuador"
replace ID_GADM_fine="ECU10" if NAME_1=="Guayas" & origin=="Ecuador"
replace ID_GADM_fine="ECU11" if NAME_1=="Imbabura" & origin=="Ecuador"
replace ID_GADM_fine="ECU12" if NAME_1=="Loja" & origin=="Ecuador"
replace ID_GADM_fine="ECU13" if NAME_1=="Los Rios" & origin=="Ecuador"
replace ID_GADM_fine="ECU14" if NAME_1=="Manabi" & origin=="Ecuador"
replace ID_GADM_fine="ECU15" if NAME_1=="Morona Santiago" & origin=="Ecuador"
replace ID_GADM_fine="ECU16" if NAME_1=="Napo" & origin=="Ecuador"
replace ID_GADM_fine="ECU17" if NAME_1=="Orellana" & origin=="Ecuador"
replace ID_GADM_fine="ECU18" if NAME_1=="Pastaza" & origin=="Ecuador"
replace ID_GADM_fine="ECU19" if NAME_1=="Pichincha" & origin=="Ecuador"
replace ID_GADM_fine="ECU20" if NAME_1=="Santa Elena" & origin=="Ecuador"
replace ID_GADM_fine="ECU21" if NAME_1=="Santo Domingo de los Tsachilas" & origin=="Ecuador"
replace ID_GADM_fine="ECU22" if NAME_1=="Sucumbios" & origin=="Ecuador"
replace ID_GADM_fine="ECU23" if NAME_1=="Tungurahua" & origin=="Ecuador"
replace ID_GADM_fine="ECU24" if NAME_1=="Zamora Chinchipe" & origin=="Ecuador"

* EGYPT
replace NAME_1="Al Iskandariyah" if NAME_1=="Al Iskandariyah (Alexandria)" & origin=="Egypt"
replace NAME_1="Al Qahirah" if NAME_1=="Al Qahirah (Cairo)" & origin=="Egypt"
replace NAME_1="Ash Sharqiyah" if NAME_1=="Al Sharqia" & origin=="Egypt"
replace NAME_1="Al Iskandariyah" if NAME_1=="Alexandria" & origin=="Egypt"
replace NAME_1="Al Iskandariyah" if NAME_1=="Alexandria (Governorate)" & origin=="Egypt"
replace NAME_1="Al Buhayrah" if NAME_1=="Beheira" & origin=="Egypt"
replace NAME_1="Bani Suwayf" if NAME_1=="Beni Suef" & origin=="Egypt"
replace NAME_1="Al Qahirah" if NAME_1=="Cairo" & origin=="Egypt"
replace NAME_1="Al Qahirah" if NAME_1=="Cairo (Governorate)" & origin=="Egypt"
replace NAME_1="Ad Daqahliyah" if NAME_1=="Dakahlia" & origin=="Egypt"
replace NAME_1="Dumyat" if NAME_1=="Damietta" & origin=="Egypt"
replace NAME_1="Al Fayyum" if NAME_1=="Faiyum" & origin=="Egypt"
replace NAME_1="Al Gharbiyah" if NAME_1=="Gharbia" & origin=="Egypt"
replace NAME_1="Al Jizah" if NAME_1=="Giza" & origin=="Egypt"
replace NAME_1="Al Isma`iliyah" if NAME_1=="Ismailia" & origin=="Egypt"
replace NAME_1="Janub Sina'" if NAME_1=="Janub Sina' (Governorate)" & origin=="Egypt"
replace NAME_1="Kafr ash Shaykh" if NAME_1=="Kafr El-Sheikh" & origin=="Egypt"
replace NAME_1="Kafr ash Shaykh" if NAME_1=="Kafr el-Sheikh" & origin=="Egypt"
replace NAME_1="Al Uqsur" if NAME_1=="Luxor" & origin=="Egypt"
replace NAME_1="Matrouh" if NAME_1=="Matruh" & origin=="Egypt"
replace NAME_1="Al Minya" if NAME_1=="Minya" & origin=="Egypt"
replace NAME_1="Al Minufiyah" if NAME_1=="Monufia" & origin=="Egypt"
replace NAME_1="Al Wadi al Jadid" if NAME_1=="New Valley" & origin=="Egypt"
replace NAME_1="Shamal Sina'" if NAME_1=="North Sinai" & origin=="Egypt"
replace NAME_1="Shamal Sina'" if NAME_1=="North Sinai Governorate" & origin=="Egypt"
replace NAME_1="Bur Sa`id" if NAME_1=="Port Said" & origin=="Egypt"
replace NAME_1="Al Qalyubiyah" if NAME_1=="Qalyubia" & origin=="Egypt"
replace NAME_1="Qina" if NAME_1=="Qena" & origin=="Egypt"
replace NAME_1="Al Bahr al Ahmar" if NAME_1=="Red Sea" & origin=="Egypt"
replace NAME_1="Shamal Sina'" if NAME_1=="Shamal Sina" & origin=="Egypt"
replace NAME_1="Shamal Sina'" if NAME_1=="Sinai" & origin=="Egypt"
replace NAME_1="Suhaj" if NAME_1=="Sohag" & origin=="Egypt"
replace NAME_1="Janub Sina'" if NAME_1=="South Sinai" & origin=="Egypt"
replace NAME_1="Janub Sina'" if NAME_1=="South Sinai (Governorate)" & origin=="Egypt"
replace NAME_1="Janub Sina'" if NAME_1=="South Sinai Governorate" & origin=="Egypt"
replace NAME_1="As Suways" if NAME_1=="Suez" & origin=="Egypt"
replace ID_GADM_fine="EGY1" if NAME_1=="Ad Daqahliyah" & origin=="Egypt"
replace ID_GADM_fine="EGY2" if NAME_1=="Al Bahr al Ahmar" & origin=="Egypt"
replace ID_GADM_fine="EGY3" if NAME_1=="Al Buhayrah" & origin=="Egypt"
replace ID_GADM_fine="EGY4" if NAME_1=="Al Fayyum" & origin=="Egypt"
replace ID_GADM_fine="EGY5" if NAME_1=="Al Gharbiyah" & origin=="Egypt"
replace ID_GADM_fine="EGY6" if NAME_1=="Al Iskandariyah" & origin=="Egypt"
replace ID_GADM_fine="EGY7" if NAME_1=="Al Isma`iliyah" & origin=="Egypt"
replace ID_GADM_fine="EGY8" if NAME_1=="Al Jizah" & origin=="Egypt"
replace ID_GADM_fine="EGY9" if NAME_1=="Al Minufiyah" & origin=="Egypt"
replace ID_GADM_fine="EGY10" if NAME_1=="Al Minya" & origin=="Egypt"
replace ID_GADM_fine="EGY11" if NAME_1=="Al Qahirah" & origin=="Egypt"
replace ID_GADM_fine="EGY12" if NAME_1=="Al Qalyubiyah" & origin=="Egypt"
replace ID_GADM_fine="EGY13" if NAME_1=="Al Uqsur" & origin=="Egypt"
replace ID_GADM_fine="EGY14" if NAME_1=="Al Wadi al Jadid" & origin=="Egypt"
replace ID_GADM_fine="EGY15" if NAME_1=="As Suways" & origin=="Egypt"
replace ID_GADM_fine="EGY16" if NAME_1=="Ash Sharqiyah" & origin=="Egypt"
replace ID_GADM_fine="EGY17" if NAME_1=="Aswan" & origin=="Egypt"
replace ID_GADM_fine="EGY18" if NAME_1=="Asyut" & origin=="Egypt"
replace ID_GADM_fine="EGY19" if NAME_1=="Bani Suwayf" & origin=="Egypt"
replace ID_GADM_fine="EGY20" if NAME_1=="Bur Sa`id" & origin=="Egypt"
replace ID_GADM_fine="EGY21" if NAME_1=="Dumyat" & origin=="Egypt"
replace ID_GADM_fine="EGY22" if NAME_1=="Janub Sina'" & origin=="Egypt"
replace ID_GADM_fine="EGY23" if NAME_1=="Kafr ash Shaykh" & origin=="Egypt"
replace ID_GADM_fine="EGY24" if NAME_1=="Matrouh" & origin=="Egypt"
replace ID_GADM_fine="EGY25" if NAME_1=="Qina" & origin=="Egypt"
replace ID_GADM_fine="EGY26" if NAME_1=="Shamal Sina'" & origin=="Egypt"
replace ID_GADM_fine="EGY27" if NAME_1=="Suhaj" & origin=="Egypt"

* EQUATORIAL GUINEA
replace ID_GADM_fine="GNQ2" if NAME_1=="Bioko Norte" & origin=="Equatorial Guinea"

* ERITREA
replace NAME_1="Debub" if NAME_1=="Southern" & origin=="Eritrea"
replace ID_GADM_fine="ERI2" if NAME_1=="Debub" & origin=="Eritrea"
replace ID_GADM_fine="ERI4" if NAME_1=="Gash Barka" & origin=="Eritrea"
replace ID_GADM_fine="ERI5" if NAME_1=="Maekel" & origin=="Eritrea"

* ESTONIA
drop if NAME_1=="Estonia" & origin=="Estonia"
replace NAME_1="Lääne-Viru" if NAME_1=="Laane-Viru" & origin=="Estonia"
replace NAME_1="Harju" if NAME_1=="Parita-Merivalja" & origin=="Estonia"
replace ID_GADM_fine="EST1" if NAME_1=="Harju" & origin=="Estonia"
replace ID_GADM_fine="EST2" if NAME_1=="Hiiu" & origin=="Estonia"
replace ID_GADM_fine="EST3" if NAME_1=="Ida-Viru" & origin=="Estonia"
replace ID_GADM_fine="EST4" if NAME_1=="Järva" & origin=="Estonia"
replace ID_GADM_fine="EST5" if NAME_1=="Jõgeva" & origin=="Estonia"
replace ID_GADM_fine="EST6" if NAME_1=="Lääne-Viru" & origin=="Estonia"
replace ID_GADM_fine="EST7" if NAME_1=="Lääne" & origin=="Estonia"
replace ID_GADM_fine="EST8" if NAME_1=="Pärnu" & origin=="Estonia"
replace ID_GADM_fine="EST9" if NAME_1=="Peipsi" & origin=="Estonia"
replace ID_GADM_fine="EST10" if NAME_1=="Põlva" & origin=="Estonia"
replace ID_GADM_fine="EST11" if NAME_1=="Rapla" & origin=="Estonia"
replace ID_GADM_fine="EST12" if NAME_1=="Saare" & origin=="Estonia"
replace ID_GADM_fine="EST13" if NAME_1=="Tartu" & origin=="Estonia"
replace ID_GADM_fine="EST14" if NAME_1=="Valga" & origin=="Estonia"
replace ID_GADM_fine="EST15" if NAME_1=="Viljandi" & origin=="Estonia"
replace ID_GADM_fine="EST16" if NAME_1=="Võru" & origin=="Estonia"

* ETHIOPIA
replace NAME_1="Addis Abeba" if NAME_1=="Addis Ababa" & origin=="Ethiopia"
replace origin="Eritrea" if NAME_1=="Asmara" & origin=="Ethiopia"
replace NAME_1="Maekel" if NAME_1=="Asmara" & origin=="Eritrea"
replace ID_GADM_fine="ERI5" if NAME_1=="Maekel" & origin=="Eritrea"
replace NAME_1="Benshangul-Gumaz" if NAME_1=="Benishangul-Gumuz" & origin=="Ethiopia"
replace NAME_1="Gambela Peoples" if NAME_1=="Gambela" & origin=="Ethiopia"
replace NAME_1="Southern Nations, Nationalities and Peoples" if NAME_1=="Southern Nations" & origin=="Ethiopia"
replace ID_GADM_fine="ETH1" if NAME_1=="Addis Abeba" & origin=="Ethiopia"
replace ID_GADM_fine="ETH2" if NAME_1=="Afar" & origin=="Ethiopia"
replace ID_GADM_fine="ETH3" if NAME_1=="Amhara" & origin=="Ethiopia"
replace ID_GADM_fine="ETH4" if NAME_1=="Benshangul-Gumaz" & origin=="Ethiopia"
replace ID_GADM_fine="ETH5" if NAME_1=="Dire Dawa" & origin=="Ethiopia"
replace ID_GADM_fine="ETH6" if NAME_1=="Gambela Peoples" & origin=="Ethiopia"
replace ID_GADM_fine="ETH7" if NAME_1=="Harari People" & origin=="Ethiopia"
replace ID_GADM_fine="ETH8" if NAME_1=="Oromia" & origin=="Ethiopia"
replace ID_GADM_fine="ETH9" if NAME_1=="Somali" & origin=="Ethiopia"
replace ID_GADM_fine="ETH10" if NAME_1=="Southern Nations, Nationalities and Peoples" & origin=="Ethiopia"
replace ID_GADM_fine="ETH11" if NAME_1=="Tigray" & origin=="Ethiopia"

* FIJI
replace NAME_1="Western" if NAME_1=="Ba (Province)" & origin=="Fiji"
replace NAME_1="Northern" if NAME_1=="Cakaudrove" & origin=="Fiji"
replace NAME_1="Central" if NAME_1=="Cental Division" & origin=="Fiji"
replace NAME_1="Central" if NAME_1=="Central Division" & origin=="Fiji"
replace NAME_1="Northern" if NAME_1=="Macuata" & origin=="Fiji"
replace ID_GADM_fine="FJI1" if NAME_1=="Central" & origin=="Fiji"
replace ID_GADM_fine="FJI2" if NAME_1=="Eastern" & origin=="Fiji"
replace ID_GADM_fine="FJI3" if NAME_1=="Northern" & origin=="Fiji"
replace ID_GADM_fine="FJI4" if NAME_1=="Rotuma" & origin=="Fiji"
replace ID_GADM_fine="FJI5" if NAME_1=="Western" & origin=="Fiji"

* FINLAND
replace NAME_1="Western Finland" if NAME_1=="Central Finland" & origin=="Finland"
replace NAME_1="Southern Finland" if NAME_1=="Kymenlaakso" & origin=="Finland"
replace NAME_1="Oulu" if NAME_1=="Northern Ostrobothnia" & origin=="Finland"
replace NAME_1="Southern Finland" if NAME_1=="Paijanne Tavastia" & origin=="Finland"
replace NAME_1="Western Finland" if NAME_1=="Pirkanmaa" & origin=="Finland"
replace NAME_1="Western Finland" if NAME_1=="Satakunta" & origin=="Finland"
replace NAME_1="Western Finland" if NAME_1=="Southwest Finland" & origin=="Finland"
replace NAME_1="Southern Finland" if NAME_1=="Uusimaa" & origin=="Finland"
replace ID_GADM_fine="FIN1" if NAME_1=="Eastern Finland" & origin=="Finland"
replace ID_GADM_fine="FIN2" if NAME_1=="Lapland" & origin=="Finland"
replace ID_GADM_fine="FIN3" if NAME_1=="Oulu" & origin=="Finland"
replace ID_GADM_fine="FIN4" if NAME_1=="Southern Finland" & origin=="Finland"
replace ID_GADM_fine="FIN5" if NAME_1=="Western Finland" & origin=="Finland"

* FRANCE
replace NAME_1="Grand Est" if NAME_1=="Alsace" & origin=="France"
replace NAME_1="Nouvelle-Aquitaine" if NAME_1=="Aquitaine" & origin=="France"
replace NAME_1="Auvergne-Rhône-Alpes" if NAME_1=="Auvergne-Rhone-Alpes" & origin=="France"
replace NAME_1="Bretagne" if NAME_1=="Brittany" & origin=="France"
replace NAME_1="Bourgogne-Franche-Comté" if NAME_1=="Burgundy" & origin=="France"
replace NAME_1="Centre-Val de Loire" if NAME_1=="Centre" & origin=="France"
replace NAME_1="Corse" if NAME_1=="Corsica" & origin=="France"
replace NAME_1="Grand Est" if NAME_1=="Grand Est" & origin=="France"
replace NAME_1="Hauts-de-France" if NAME_1=="Hauts-de-France" & origin=="France"
replace NAME_1="Île-de-France" if NAME_1=="Ile-de-France" & origin=="France"
replace NAME_1="Centre-Val de Loire" if NAME_1=="Indre-et-loire" & origin=="France"
replace NAME_1="Occitanie" if NAME_1=="Languedoc-Roussillon" & origin=="France"
replace NAME_1="Nouvelle-Aquitaine" if NAME_1=="Limousin" & origin=="France"
replace NAME_1="Normandie" if NAME_1=="Lower Normandy" & origin=="France"
replace NAME_1="Occitanie" if NAME_1=="Midi-Pyrenees" & origin=="France"
replace NAME_1="Hauts-de-France" if NAME_1=="Nord-Pas-de-Calais" & origin=="France"
replace NAME_1="Normandie" if NAME_1=="Normandy" & origin=="France"
replace NAME_1="Occitanie" if NAME_1=="Occitanie" & origin=="France"
replace NAME_1="Pays de la Loire" if NAME_1=="Pays de la Loire" & origin=="France"
replace NAME_1="Pays de la Loire" if NAME_1=="Pays-de-la-Loire" & origin=="France"
replace NAME_1="Hauts-de-France" if NAME_1=="Picardy" & origin=="France"
replace NAME_1="Nouvelle-Aquitaine" if NAME_1=="Poitou-Charentes" & origin=="France"
replace NAME_1="Provence-Alpes-Côte d'Azur" if NAME_1=="Provence-Alpes-Cote d'Azur" & origin=="France"
replace NAME_1="Auvergne-Rhône-Alpes" if NAME_1=="Rhone-Alpes" & origin=="France"
replace ID_GADM_fine="FRA1" if NAME_1=="Auvergne-Rhône-Alpes" & origin=="France"
replace ID_GADM_fine="FRA2" if NAME_1=="Bourgogne-Franche-Comté" & origin=="France"
replace ID_GADM_fine="FRA3" if NAME_1=="Bretagne" & origin=="France"
replace ID_GADM_fine="FRA4" if NAME_1=="Centre-Val de Loire" & origin=="France"
replace ID_GADM_fine="FRA5" if NAME_1=="Corse" & origin=="France"
replace ID_GADM_fine="FRA6" if NAME_1=="Grand Est" & origin=="France"
replace ID_GADM_fine="FRA7" if NAME_1=="Hauts-de-France" & origin=="France"
replace ID_GADM_fine="FRA8" if NAME_1=="Île-de-France" & origin=="France"
replace ID_GADM_fine="FRA9" if NAME_1=="Normandie" & origin=="France"
replace ID_GADM_fine="FRA10" if NAME_1=="Nouvelle-Aquitaine" & origin=="France"
replace ID_GADM_fine="FRA11" if NAME_1=="Occitanie" & origin=="France"
replace ID_GADM_fine="FRA12" if NAME_1=="Pays de la Loire" & origin=="France"
replace ID_GADM_fine="FRA13" if NAME_1=="Provence-Alpes-Côte d'Azur" & origin=="France"

* GAMBIA
replace NAME_1="Banjul" if NAME_1=="Banjul" & origin=="Gambia"
replace ID_GADM_fine="GMB1" if NAME_1=="Banjul" & origin=="Gambia"

* GEORGIA
replace NAME_1="Abkhazia" if NAME_1=="Abkhazia" & origin=="Georgia"
replace NAME_1="Abkhazia" if NAME_1=="Abkhazia (Autonomous Region)" & origin=="Georgia"
replace NAME_1="Abkhazia" if NAME_1=="Abkhazia (Autonomous Republic)" & origin=="Georgia"
replace NAME_1="Abkhazia" if NAME_1=="Abkhazia (Region)" & origin=="Georgia"
replace NAME_1="Ajaria" if NAME_1=="Ajaria (Autonomous Republic)" & origin=="Georgia"
replace NAME_1="Samegrelo-Zemo Svaneti" if NAME_1=="Chkhorotsku (District)" & origin=="Georgia"
drop if NAME_1=="Georgia" & origin=="Georgia"
replace NAME_1="Shida Kartli" if NAME_1=="Gori" & origin=="Georgia"
replace NAME_1="Imereti" if NAME_1=="Imereti" & origin=="Georgia"
replace NAME_1="Kvemo Kartli" if NAME_1=="Kartli (Province)" & origin=="Georgia"
replace NAME_1="Kvemo Kartli" if NAME_1=="Kvemo Kartli (Region)" & origin=="Georgia"
replace NAME_1="Mtskheta-Mtianeti" if NAME_1=="Mtskheta-Mtianeti" & origin=="Georgia"
replace NAME_1="Samegrelo-Zemo Svaneti" if NAME_1=="Samegrelo and Zemo Svaneti" & origin=="Georgia"
replace NAME_1="Samegrelo-Zemo Svaneti" if NAME_1=="Samegrelo-Zemo Svaneti" & origin=="Georgia"
replace NAME_1="Samtskhe-Javakheti" if NAME_1=="Samtskhe-Javakheti (Province)" & origin=="Georgia"
replace NAME_1="Shida Kartli" if NAME_1=="Shida Kartli" & origin=="Georgia"
replace NAME_1="Shida Kartli" if NAME_1=="Shida Kartli (Region)" & origin=="Georgia"
replace NAME_1="Shida Kartli" if NAME_1=="Shida Kartlie (Region)" & origin=="Georgia"
drop if NAME_1=="South Ossetia" & origin=="Georgia"
drop if NAME_1=="South Ossetia (Autonomous Province)" & origin=="Georgia"
drop if NAME_1=="South Ossetia (Region)" & origin=="Georgia"
drop if NAME_1=="South Ossetia (Republic)" & origin=="Georgia"
replace NAME_1="Tbilisi" if NAME_1=="T'bilisi" & origin=="Georgia"
replace NAME_1="Tbilisi" if NAME_1=="Tbilisi" & origin=="Georgia"
replace NAME_1="Tbilisi" if NAME_1=="Tbilisi (Capital City)" & origin=="Georgia"
replace NAME_1="Tbilisi" if NAME_1=="Tbilisi (Capital)" & origin=="Georgia"
drop if NAME_1=="Tskhinvali (Region)" & origin=="Georgia"
replace NAME_1="Samegrelo-Zemo Svaneti" if NAME_1=="Zugdidi" & origin=="Georgia"
replace ID_GADM_fine="GEO1" if NAME_1=="Abkhazia" & origin=="Georgia"
replace ID_GADM_fine="GEO2" if NAME_1=="Ajaria" & origin=="Georgia"
replace ID_GADM_fine="GEO3" if NAME_1=="Guria" & origin=="Georgia"
replace ID_GADM_fine="GEO4" if NAME_1=="Imereti" & origin=="Georgia"
replace ID_GADM_fine="GEO5" if NAME_1=="Kakheti" & origin=="Georgia"
replace ID_GADM_fine="GEO6" if NAME_1=="Kvemo Kartli" & origin=="Georgia"
replace ID_GADM_fine="GEO7" if NAME_1=="Mtskheta-Mtianeti" & origin=="Georgia"
replace ID_GADM_fine="GEO8" if NAME_1=="Racha-Lechkhumi-Kvemo Svaneti" & origin=="Georgia"
replace ID_GADM_fine="GEO9" if NAME_1=="Samegrelo-Zemo Svaneti" & origin=="Georgia"
replace ID_GADM_fine="GEO10" if NAME_1=="Samtskhe-Javakheti" & origin=="Georgia"
replace ID_GADM_fine="GEO11" if NAME_1=="Shida Kartli" & origin=="Georgia"
replace ID_GADM_fine="GEO12" if NAME_1=="Tbilisi" & origin=="Georgia"

* GERMANY
replace NAME_1="Baden-Württemberg" if NAME_1=="Baden-Wurttemberg" & origin=="Germany"
replace NAME_1="Bayern" if NAME_1=="Bavaria" & origin=="Germany"
replace NAME_1="Berlin" if NAME_1=="Berlin" & origin=="Germany"
replace NAME_1="Niedersachsen" if NAME_1=="Lower Saxony" & origin=="Germany"
replace NAME_1="Mecklenburg-Vorpommern" if NAME_1=="Mecklenburg-West Pomerania" & origin=="Germany"
replace NAME_1="Nordrhein-Westfalen" if NAME_1=="North Rhine-Westphalia" & origin=="Germany"
replace NAME_1="Rheinland-Pfalz" if NAME_1=="Rhineland-Palatinate" & origin=="Germany"
replace NAME_1="Saarland" if NAME_1=="Saarland" & origin=="Germany"
replace NAME_1="Sachsen" if NAME_1=="Saxony" & origin=="Germany"
replace NAME_1="Sachsen-Anhalt" if NAME_1=="Saxony-Anhalt" & origin=="Germany"
replace NAME_1="Thüringen" if NAME_1=="Thuringia" & origin=="Germany"
replace ID_GADM_fine="DEU1" if NAME_1=="Baden-Württemberg" & origin=="Germany"
replace ID_GADM_fine="DEU2" if NAME_1=="Bayern" & origin=="Germany"
replace ID_GADM_fine="DEU3" if NAME_1=="Berlin" & origin=="Germany"
replace ID_GADM_fine="DEU4" if NAME_1=="Brandenburg" & origin=="Germany"
replace ID_GADM_fine="DEU5" if NAME_1=="Bremen" & origin=="Germany"
replace ID_GADM_fine="DEU6" if NAME_1=="Hamburg" & origin=="Germany"
replace ID_GADM_fine="DEU7" if NAME_1=="Hessen" & origin=="Germany"
replace ID_GADM_fine="DEU8" if NAME_1=="Mecklenburg-Vorpommern" & origin=="Germany"
replace ID_GADM_fine="DEU9" if NAME_1=="Niedersachsen" & origin=="Germany"
replace ID_GADM_fine="DEU10" if NAME_1=="Nordrhein-Westfalen" & origin=="Germany"
replace ID_GADM_fine="DEU11" if NAME_1=="Rheinland-Pfalz" & origin=="Germany"
replace ID_GADM_fine="DEU12" if NAME_1=="Saarland" & origin=="Germany"
replace ID_GADM_fine="DEU13" if NAME_1=="Sachsen-Anhalt" & origin=="Germany"
replace ID_GADM_fine="DEU14" if NAME_1=="Sachsen" & origin=="Germany"
replace ID_GADM_fine="DEU15" if NAME_1=="Schleswig-Holstein" & origin=="Germany"
replace ID_GADM_fine="DEU16" if NAME_1=="Thüringen" & origin=="Germany"

* GHANA
replace ID_GADM_fine="GHA1" if NAME_1=="Ashanti" & origin=="Ghana"
replace ID_GADM_fine="GHA1" if NAME_1=="Ashanti" & origin=="Ghana"
replace ID_GADM_fine="GHA2" if NAME_1=="Brong Ahafo" & origin=="Ghana"
replace ID_GADM_fine="GHA3" if NAME_1=="Central" & origin=="Ghana"
replace ID_GADM_fine="GHA4" if NAME_1=="Eastern" & origin=="Ghana"
replace ID_GADM_fine="GHA5" if NAME_1=="Greater Accra" & origin=="Ghana"
replace ID_GADM_fine="GHA6" if NAME_1=="Northern" & origin=="Ghana"
replace ID_GADM_fine="GHA7" if NAME_1=="Upper East" & origin=="Ghana"
replace ID_GADM_fine="GHA8" if NAME_1=="Upper West" & origin=="Ghana"
replace ID_GADM_fine="GHA9" if NAME_1=="Volta" & origin=="Ghana"
replace ID_GADM_fine="GHA10" if NAME_1=="Western" & origin=="Ghana"

* GREECE
replace NAME_1="Thessaly and Central Greece" if NAME_1=="Central Greece" & origin=="Greece"
replace NAME_1="Macedonia and Thrace" if NAME_1=="Central Macedonia" & origin=="Greece"
replace NAME_1="Macedonia and Thrace" if NAME_1=="Eastern Macedonia and Thrace" & origin=="Greece"
replace NAME_1="Peloponnese, Western Greece and the Ionian Islands" if NAME_1=="Ionian Islands" & origin=="Greece"
replace NAME_1="Aegean" if NAME_1=="North Aegean" & origin=="Greece"
replace NAME_1="Peloponnese, Western Greece and the Ionian Islands" if NAME_1=="Peloponnese" & origin=="Greece"
replace NAME_1="Aegean" if NAME_1=="South Aegean" & origin=="Greece"
replace NAME_1="Thessaly and Central Greece" if NAME_1=="Thessaly" & origin=="Greece"
replace NAME_1="Peloponnese, Western Greece and the Ionian Islands" if NAME_1=="Western Greece" & origin=="Greece"
replace ID_GADM_fine="GRC1" if NAME_1=="Aegean" & origin=="Greece"
replace ID_GADM_fine="GRC2" if NAME_1=="Athos" & origin=="Greece"
replace ID_GADM_fine="GRC3" if NAME_1=="Attica" & origin=="Greece"
replace ID_GADM_fine="GRC4" if NAME_1=="Crete" & origin=="Greece"
replace ID_GADM_fine="GRC5" if NAME_1=="Epirus and Western Macedonia" & origin=="Greece"
replace ID_GADM_fine="GRC6" if NAME_1=="Macedonia and Thrace" & origin=="Greece"
replace ID_GADM_fine="GRC7" if NAME_1=="Peloponnese, Western Greece and the Ionian Islands" & origin=="Greece"
replace ID_GADM_fine="GRC8" if NAME_1=="Thessaly and Central Greece" & origin=="Greece"

* GUATEMALA
replace NAME_1="Chiquimula" if NAME_1=="Chiquimula (Department)" & origin=="Guatemala"
replace NAME_1="Escuintla" if NAME_1=="Escuintla (Department)" & origin=="Guatemala"
replace NAME_1="Guatemala" if NAME_1=="Guatemala (Department)" & origin=="Guatemala"
replace NAME_1="Guatemala" if NAME_1=="Guatemala City (Capital District)" & origin=="Guatemala"
replace NAME_1="Jutiapa" if NAME_1=="Jutiapa" & origin=="Guatemala"
replace NAME_1="Santa Rosa" if NAME_1=="Santa Rosa (Department)" & origin=="Guatemala"
replace NAME_1="Sololá" if NAME_1=="Solola" & origin=="Guatemala"
replace NAME_1="Suchitepéquez" if NAME_1=="Suchitepequez" & origin=="Guatemala"
replace NAME_1="Zacapa" if NAME_1=="Zacapa" & origin=="Guatemala"
replace ID_GADM_fine="GTM1" if NAME_1=="Alta Verapaz" & origin=="Guatemala"
replace ID_GADM_fine="GTM2" if NAME_1=="Baja Verapaz" & origin=="Guatemala"
replace ID_GADM_fine="GTM3" if NAME_1=="Chimaltenango" & origin=="Guatemala"
replace ID_GADM_fine="GTM4" if NAME_1=="Chiquimula" & origin=="Guatemala"
replace ID_GADM_fine="GTM5" if NAME_1=="El Progreso" & origin=="Guatemala"
replace ID_GADM_fine="GTM6" if NAME_1=="Escuintla" & origin=="Guatemala"
replace ID_GADM_fine="GTM7" if NAME_1=="Guatemala" & origin=="Guatemala"
replace ID_GADM_fine="GTM8" if NAME_1=="Huehuetenango" & origin=="Guatemala"
replace ID_GADM_fine="GTM9" if NAME_1=="Izabal" & origin=="Guatemala"
replace ID_GADM_fine="GTM10" if NAME_1=="Jalapa" & origin=="Guatemala"
replace ID_GADM_fine="GTM11" if NAME_1=="Jutiapa" & origin=="Guatemala"
replace ID_GADM_fine="GTM12" if NAME_1=="Petén" & origin=="Guatemala"
replace ID_GADM_fine="GTM13" if NAME_1=="Quezaltenango" & origin=="Guatemala"
replace ID_GADM_fine="GTM14" if NAME_1=="Quiché" & origin=="Guatemala"
replace ID_GADM_fine="GTM15" if NAME_1=="Retalhuleu" & origin=="Guatemala"
replace ID_GADM_fine="GTM16" if NAME_1=="Sacatepéquez" & origin=="Guatemala"
replace ID_GADM_fine="GTM17" if NAME_1=="San Marcos" & origin=="Guatemala"
replace ID_GADM_fine="GTM18" if NAME_1=="Santa Rosa" & origin=="Guatemala"
replace ID_GADM_fine="GTM19" if NAME_1=="Sololá" & origin=="Guatemala"
replace ID_GADM_fine="GTM20" if NAME_1=="Suchitepéquez" & origin=="Guatemala"
replace ID_GADM_fine="GTM21" if NAME_1=="Totonicapán" & origin=="Guatemala"
replace ID_GADM_fine="GTM22" if NAME_1=="Zacapa" & origin=="Guatemala"

* GUINEA
replace NAME_1="Conakry" if NAME_1=="Conakry" & origin=="Guinea"
replace NAME_1="Faranah" if NAME_1=="Faranah" & origin=="Guinea"
replace NAME_1="Kindia" if NAME_1=="Kindia" & origin=="Guinea"
replace NAME_1="Nzérékoré" if NAME_1=="Nzerekore" & origin=="Guinea"
replace ID_GADM_fine="GIN1" if NAME_1=="Boké" & origin=="Guinea"
replace ID_GADM_fine="GIN2" if NAME_1=="Conakry" & origin=="Guinea"
replace ID_GADM_fine="GIN3" if NAME_1=="Faranah" & origin=="Guinea"
replace ID_GADM_fine="GIN4" if NAME_1=="Kankan" & origin=="Guinea"
replace ID_GADM_fine="GIN5" if NAME_1=="Kindia" & origin=="Guinea"
replace ID_GADM_fine="GIN6" if NAME_1=="Labé" & origin=="Guinea"
replace ID_GADM_fine="GIN7" if NAME_1=="Mamou" & origin=="Guinea"
replace ID_GADM_fine="GIN8" if NAME_1=="Nzérékoré" & origin=="Guinea"

* GUINEA-BISSAU
replace ID_GADM_fine="GNB3" if NAME_1=="Bissau" & origin=="Guinea-Bissau"
replace ID_GADM_fine="GNB5" if NAME_1=="Cacheu" & origin=="Guinea-Bissau"

* GUYANA
replace ID_GADM_fine="GUY2" if NAME_1=="Cuyuni-Mazaruni" & origin=="Guyana"
replace ID_GADM_fine="GUY3" if NAME_1=="Demerara-Mahaica" & origin=="Guyana"
replace ID_GADM_fine="GUY4" if NAME_1=="East Berbice-Corentyne" & origin=="Guyana"

* HAITI
replace NAME_1="L'Artibonite" if NAME_1=="Artibonite" & origin=="Haiti"
replace NAME_1="L'Artibonite" if NAME_1=="Artibonite (Department)" & origin=="Haiti"
replace NAME_1="Centre" if NAME_1=="Centre (Department)" & origin=="Haiti"
replace NAME_1="Grand'Anse" if NAME_1=="Grand'Anse (Department)" & origin=="Haiti"
replace NAME_1="Ouest" if NAME_1=="Ouest" & origin=="Haiti"
replace NAME_1="Ouest" if NAME_1=="Ouest (Department)" & origin=="Haiti"
replace NAME_1="Ouest" if NAME_1=="Port-au-Prince (Capital City)" & origin=="Haiti"
replace NAME_1="Sud-Est" if NAME_1=="Southeast (Department)" & origin=="Haiti"
drop if NAME_1=="Wassec (Region)" & origin=="Haiti"
replace ID_GADM_fine="HTI1" if NAME_1=="Centre" & origin=="Haiti"
replace ID_GADM_fine="HTI2" if NAME_1=="Grand'Anse" & origin=="Haiti"
replace ID_GADM_fine="HTI3" if NAME_1=="L'Artibonite" & origin=="Haiti"
replace ID_GADM_fine="HTI4" if NAME_1=="Nippes" & origin=="Haiti"
replace ID_GADM_fine="HTI5" if NAME_1=="Nord-Est" & origin=="Haiti"
replace ID_GADM_fine="HTI6" if NAME_1=="Nord-Ouest" & origin=="Haiti"
replace ID_GADM_fine="HTI7" if NAME_1=="Nord" & origin=="Haiti"
replace ID_GADM_fine="HTI8" if NAME_1=="Ouest" & origin=="Haiti"
replace ID_GADM_fine="HTI9" if NAME_1=="Sud-Est" & origin=="Haiti"
replace ID_GADM_fine="HTI10" if NAME_1=="Sud" & origin=="Haiti"

* HONDURAS
replace NAME_1="Francisco Morazán" if NAME_1=="Central District" & origin=="Honduras"
replace NAME_1="Colón" if NAME_1=="Colon" & origin=="Honduras"
replace NAME_1="Cortés" if NAME_1=="Cortés" & origin=="Honduras"
replace NAME_1="Cortés" if NAME_1=="Cortés (Department)" & origin=="Honduras"
replace NAME_1="Francisco Morazán" if NAME_1=="Francisco Morazan" & origin=="Honduras"
replace ID_GADM_fine="HND1" if NAME_1=="Atlántida" & origin=="Honduras"
replace ID_GADM_fine="HND2" if NAME_1=="Choluteca" & origin=="Honduras"
replace ID_GADM_fine="HND3" if NAME_1=="Colón" & origin=="Honduras"
replace ID_GADM_fine="HND4" if NAME_1=="Comayagua" & origin=="Honduras"
replace ID_GADM_fine="HND5" if NAME_1=="Copán" & origin=="Honduras"
replace ID_GADM_fine="HND6" if NAME_1=="Cortés" & origin=="Honduras"
replace ID_GADM_fine="HND7" if NAME_1=="El Paraíso" & origin=="Honduras"
replace ID_GADM_fine="HND8" if NAME_1=="Francisco Morazán" & origin=="Honduras"
replace ID_GADM_fine="HND9" if NAME_1=="Gracias a Dios" & origin=="Honduras"
replace ID_GADM_fine="HND10" if NAME_1=="Intibucá" & origin=="Honduras"
replace ID_GADM_fine="HND11" if NAME_1=="Islas de la Bahía" & origin=="Honduras"
replace ID_GADM_fine="HND12" if NAME_1=="La Paz" & origin=="Honduras"
replace ID_GADM_fine="HND13" if NAME_1=="Lempira" & origin=="Honduras"
replace ID_GADM_fine="HND14" if NAME_1=="Ocotepeque" & origin=="Honduras"
replace ID_GADM_fine="HND15" if NAME_1=="Olancho" & origin=="Honduras"
replace ID_GADM_fine="HND16" if NAME_1=="Santa Bárbara" & origin=="Honduras"
replace ID_GADM_fine="HND17" if NAME_1=="Valle" & origin=="Honduras"
replace ID_GADM_fine="HND18" if NAME_1=="Yoro" & origin=="Honduras"

* HONG KONG // Not in GADM --> change based on GWP
replace NAME_1="Hong Kong Island" if NAME_1=="Hong Kong (Special Administrative Region)" & origin=="Hong Kong"
replace NAME_1="Hong Kong Island" if NAME_1=="Hong Kong Special Administrative Region (hksar)" & origin=="Hong Kong"
replace ID_GADM_fine="HKG2" if NAME_1=="New Territories" & origin=="Hong Kong"
replace ID_GADM_fine="HKG3" if NAME_1=="Hong Kong Island" & origin=="Hong Kong"

* HUNGARY
drop if NAME_1=="Hungary" & origin=="Hungary"
replace NAME_1="Budapest" if NAME_1=="Seventh District" & origin=="Hungary"
replace ID_GADM_fine="HUN1" if NAME_1=="Bács-Kiskun" & origin=="Hungary"
replace ID_GADM_fine="HUN2" if NAME_1=="Baranya" & origin=="Hungary"
replace ID_GADM_fine="HUN3" if NAME_1=="Békés" & origin=="Hungary"
replace ID_GADM_fine="HUN4" if NAME_1=="Borsod-Abaúj-Zemplén" & origin=="Hungary"
replace ID_GADM_fine="HUN5" if NAME_1=="Budapest" & origin=="Hungary"
replace ID_GADM_fine="HUN6" if NAME_1=="Csongrád" & origin=="Hungary"
replace ID_GADM_fine="HUN7" if NAME_1=="Fejér" & origin=="Hungary"
replace ID_GADM_fine="HUN8" if NAME_1=="Gyor-Moson-Sopron" & origin=="Hungary"
replace ID_GADM_fine="HUN9" if NAME_1=="Hajdú-Bihar" & origin=="Hungary"
replace ID_GADM_fine="HUN10" if NAME_1=="Heves" & origin=="Hungary"
replace ID_GADM_fine="HUN11" if NAME_1=="Jász-Nagykun-Szolnok" & origin=="Hungary"
replace ID_GADM_fine="HUN12" if NAME_1=="Komárom-Esztergom" & origin=="Hungary"
replace ID_GADM_fine="HUN13" if NAME_1=="Nógrád" & origin=="Hungary"
replace ID_GADM_fine="HUN14" if NAME_1=="Pest" & origin=="Hungary"
replace ID_GADM_fine="HUN15" if NAME_1=="Somogy" & origin=="Hungary"
replace ID_GADM_fine="HUN16" if NAME_1=="Szabolcs-Szatmár-Bereg" & origin=="Hungary"
replace ID_GADM_fine="HUN17" if NAME_1=="Tolna" & origin=="Hungary"
replace ID_GADM_fine="HUN18" if NAME_1=="Vas" & origin=="Hungary"
replace ID_GADM_fine="HUN19" if NAME_1=="Veszprém" & origin=="Hungary"
replace ID_GADM_fine="HUN20" if NAME_1=="Zala" & origin=="Hungary"

* ICELAND
replace NAME_1="Höfuðborgarsvæði" if NAME_1=="Hofudhborgarsvaedhi" & origin=="Iceland"
replace NAME_1="Norðurland vestra" if NAME_1=="Nordhurland Eystra" & origin=="Iceland"
replace ID_GADM_fine="ISL1" if NAME_1=="Austurland" & origin=="Iceland"
replace ID_GADM_fine="ISL2" if NAME_1=="Hálshreppur" & origin=="Iceland"
replace ID_GADM_fine="ISL3" if NAME_1=="Höfuðborgarsvæði" & origin=="Iceland"
replace ID_GADM_fine="ISL4" if NAME_1=="Norðurland vestra" & origin=="Iceland"
replace ID_GADM_fine="ISL5" if NAME_1=="Suðurland" & origin=="Iceland"
replace ID_GADM_fine="ISL6" if NAME_1=="Suðurnes" & origin=="Iceland"
replace ID_GADM_fine="ISL7" if NAME_1=="Vestfirðir" & origin=="Iceland"
replace ID_GADM_fine="ISL8" if NAME_1=="Vesturland" & origin=="Iceland"

* INDIA
replace NAME_1="Andhra Pradesh" if NAME_1=="Andhra Pradesh" & origin=="India"
replace NAME_1="Andhra Pradesh" if NAME_1=="Andhra pradesh" & origin=="India"
replace NAME_1="NCT of Delhi" if NAME_1=="Delhi" & origin=="India"
replace NAME_1="Odisha" if NAME_1=="Orissa" & origin=="India"
replace NAME_1="Uttarakhand" if NAME_1=="Uttaranchal" & origin=="India"
replace NAME_1="West Bengal" if NAME_1=="West Bengal" & origin=="India"
replace ID_GADM_fine="IND1" if NAME_1=="Andaman and Nicobar" & origin=="India"
replace ID_GADM_fine="IND2" if NAME_1=="Andhra Pradesh" & origin=="India"
replace ID_GADM_fine="IND3" if NAME_1=="Arunachal Pradesh" & origin=="India"
replace ID_GADM_fine="IND4" if NAME_1=="Assam" & origin=="India"
replace ID_GADM_fine="IND5" if NAME_1=="Bihar" & origin=="India"
replace ID_GADM_fine="IND6" if NAME_1=="Chandigarh" & origin=="India"
replace ID_GADM_fine="IND7" if NAME_1=="Chhattisgarh" & origin=="India"
replace ID_GADM_fine="IND8" if NAME_1=="Dadra and Nagar Haveli" & origin=="India"
replace ID_GADM_fine="IND9" if NAME_1=="Daman and Diu" & origin=="India"
replace ID_GADM_fine="IND10" if NAME_1=="Goa" & origin=="India"
replace ID_GADM_fine="IND11" if NAME_1=="Gujarat" & origin=="India"
replace ID_GADM_fine="IND12" if NAME_1=="Haryana" & origin=="India"
replace ID_GADM_fine="IND13" if NAME_1=="Himachal Pradesh" & origin=="India"
replace ID_GADM_fine="IND14" if NAME_1=="Jammu and Kashmir" & origin=="India"
replace ID_GADM_fine="IND15" if NAME_1=="Jharkhand" & origin=="India"
replace ID_GADM_fine="IND16" if NAME_1=="Karnataka" & origin=="India"
replace ID_GADM_fine="IND17" if NAME_1=="Kerala" & origin=="India"
replace ID_GADM_fine="IND18" if NAME_1=="Lakshadweep" & origin=="India"
replace ID_GADM_fine="IND19" if NAME_1=="Madhya Pradesh" & origin=="India"
replace ID_GADM_fine="IND20" if NAME_1=="Maharashtra" & origin=="India"
replace ID_GADM_fine="IND21" if NAME_1=="Manipur" & origin=="India"
replace ID_GADM_fine="IND22" if NAME_1=="Meghalaya" & origin=="India"
replace ID_GADM_fine="IND23" if NAME_1=="Mizoram" & origin=="India"
replace ID_GADM_fine="IND24" if NAME_1=="Nagaland" & origin=="India"
replace ID_GADM_fine="IND25" if NAME_1=="NCT of Delhi" & origin=="India"
replace ID_GADM_fine="IND26" if NAME_1=="Odisha" & origin=="India"
replace ID_GADM_fine="IND27" if NAME_1=="Puducherry" & origin=="India"
replace ID_GADM_fine="IND28" if NAME_1=="Punjab" & origin=="India"
replace ID_GADM_fine="IND29" if NAME_1=="Rajasthan" & origin=="India"
replace ID_GADM_fine="IND30" if NAME_1=="Sikkim" & origin=="India"
replace ID_GADM_fine="IND31" if NAME_1=="Tamil Nadu" & origin=="India"
replace ID_GADM_fine="IND32" if NAME_1=="Telangana" & origin=="India"
replace ID_GADM_fine="IND33" if NAME_1=="Tripura" & origin=="India"
replace ID_GADM_fine="IND34" if NAME_1=="Uttar Pradesh" & origin=="India"
replace ID_GADM_fine="IND35" if NAME_1=="Uttarakhand" & origin=="India"
replace ID_GADM_fine="IND36" if NAME_1=="West Bengal" & origin=="India"

* INDONESIA
replace NAME_1="Aceh" if NAME_1=="Aceh (Province)" & origin=="Indonesia"
replace NAME_1="Aceh" if NAME_1=="Aceh (Special Territory)" & origin=="Indonesia"
replace NAME_1="Aceh" if NAME_1=="Aceh Besar (Province)" & origin=="Indonesia"
replace NAME_1="Aceh" if NAME_1=="Aceh province" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Ambon (Province)" & origin=="Indonesia"
replace NAME_1="Bali" if NAME_1=="Bali (Province)" & origin=="Indonesia"
replace NAME_1="Banten" if NAME_1=="Banten (Province)" & origin=="Indonesia"
replace NAME_1="Jawa Tengah" if NAME_1=="Central Java" & origin=="Indonesia"
replace NAME_1="Jawa Tengah" if NAME_1=="Central Java (Province)" & origin=="Indonesia"
replace NAME_1="Kalimantan Tengah" if NAME_1=="Central Kalimantan" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Central Maluku" & origin=="Indonesia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Central Sulawesi" & origin=="Indonesia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Central Sulawesi (Province)" & origin=="Indonesia"
replace NAME_1="Aceh" if NAME_1=="East Aceh" & origin=="Indonesia"
replace NAME_1="Jawa Timur" if NAME_1=="East Java" & origin=="Indonesia"
replace NAME_1="Jawa Timur" if NAME_1=="East Java (Province)" & origin=="Indonesia"
replace NAME_1="Kalimantan Timur" if NAME_1=="East Kalimantan" & origin=="Indonesia"
replace NAME_1="Nusa Tenggara Timur" if NAME_1=="East Nusa Tenggara" & origin=="Indonesia"
replace NAME_1="Nusa Tenggara Timur" if NAME_1=="East Nusa Tenggara (Province)" & origin=="Indonesia"
replace origin="India" if NAME_1=="Guntur" & origin=="Indonesia"
replace NAME_1="Andhra Pradesh" if NAME_1=="Guntur" & origin=="India"
replace ID_GADM_fine="IND2" if NAME_1=="Andhra Pradesh" & origin=="India"
replace NAME_1="Papua" if NAME_1=="Irian Jaya (Province)" & origin=="Indonesia"
replace NAME_1="Jakarta Raya" if NAME_1=="Jakarta" & origin=="Indonesia"
replace NAME_1="Jakarta Raya" if NAME_1=="Jakarta (Capital City District)" & origin=="Indonesia"
replace NAME_1="Jakarta Raya" if NAME_1=="Jakarta (Province)" & origin=="Indonesia"
replace NAME_1="Jakarta Raya" if NAME_1=="Jakarta (Special Capital Region)" & origin=="Indonesia"
replace NAME_1="Jakarta Raya" if NAME_1=="Jakarta (Special Territory Province)" & origin=="Indonesia"
replace NAME_1="Jawa Barat" if NAME_1=="Java" & origin=="Indonesia"
replace NAME_1="Jawa Barat" if NAME_1=="Jawa Barat (West Java)" & origin=="Indonesia"
replace NAME_1="Jawa Tengah" if NAME_1=="Jawa Tengah (Central Java)" & origin=="Indonesia"
replace NAME_1="Kalimantan Timur" if NAME_1=="Kalimantan Timur" & origin=="Indonesia"
replace NAME_1="Lampung" if NAME_1=="Lampung (Province)" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Maluku (Province)" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Maluku Province" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Maluku province" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="Moluku (Province)" & origin=="Indonesia"
replace NAME_1="Aceh" if NAME_1=="North Aceh (Province)" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="North Maluku" & origin=="Indonesia"
replace NAME_1="Maluku" if NAME_1=="North Seram (Sub district)" & origin=="Indonesia"
replace NAME_1="Sulawesi Utara" if NAME_1=="North Sulawesi (Province)" & origin=="Indonesia"
replace NAME_1="Sumatera Utara" if NAME_1=="North Sumatra" & origin=="Indonesia"
replace NAME_1="Sumatera Utara" if NAME_1=="North Sumatra (Province)" & origin=="Indonesia"
replace NAME_1="Papua" if NAME_1=="Papua (Province)" & origin=="Indonesia"
replace NAME_1="Papua" if NAME_1=="Papua Province" & origin=="Indonesia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Propinsi Sulawesi Tengah" & origin=="Indonesia"
replace NAME_1="Riau" if NAME_1=="Riau (Province)" & origin=="Indonesia"
replace NAME_1="Riau" if NAME_1=="Riau Islands" & origin=="Indonesia"
drop if NAME_1=="Siah" & origin=="Indonesia"
replace NAME_1="Sulawesi Selatan" if NAME_1=="South Sulawesi" & origin=="Indonesia"
replace NAME_1="Sulawesi Selatan" if NAME_1=="South Sulawesi (Province)" & origin=="Indonesia"
replace NAME_1="Sumatera Selatan" if NAME_1=="South Sumatra" & origin=="Indonesia"
replace NAME_1="Sulawesi Utara" if NAME_1=="Sulawesi" & origin=="Indonesia"
replace NAME_1="Sulawesi Utara" if NAME_1=="Sulawesi (Island)" & origin=="Indonesia"
replace NAME_1="Sulawesi Utara" if NAME_1=="Sulawesi (Province)" & origin=="Indonesia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Sulawesi Tengah (Central Sulawesi)" & origin=="Indonesia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Sulawesi Tengah (Province)" & origin=="Indonesia"
replace NAME_1="Sumatera Utara" if NAME_1=="Sumatra (Province)" & origin=="Indonesia"
replace NAME_1="Jawa Barat" if NAME_1=="West Java" & origin=="Indonesia"
replace NAME_1="Jawa Barat" if NAME_1=="West Java (Province)" & origin=="Indonesia"
replace NAME_1="Kalimantan Barat" if NAME_1=="West Kalimantan" & origin=="Indonesia"
replace NAME_1="Nusa Tenggara Barat" if NAME_1=="West Nusa Tenggara" & origin=="Indonesia"
replace NAME_1="Sumatera Barat" if NAME_1=="West Sumatra" & origin=="Indonesia"
replace NAME_1="Yogyakarta" if NAME_1=="Yogyakarta" & origin=="Indonesia"
replace NAME_1="Yogyakarta" if NAME_1=="Yogyakarta Special Region" & origin=="Indonesia"
replace NAME_1="Sulawesi Utara" if NAME_1=="sulawesi utara" & origin=="Indonesia"
replace ID_GADM_fine="IDN1" if NAME_1=="Aceh" & origin=="Indonesia"
replace ID_GADM_fine="IDN2" if NAME_1=="Bali" & origin=="Indonesia"
replace ID_GADM_fine="IDN3" if NAME_1=="Bangka Belitung" & origin=="Indonesia"
replace ID_GADM_fine="IDN4" if NAME_1=="Banten" & origin=="Indonesia"
replace ID_GADM_fine="IDN5" if NAME_1=="Bengkulu" & origin=="Indonesia"
replace ID_GADM_fine="IDN6" if NAME_1=="Gorontalo" & origin=="Indonesia"
replace ID_GADM_fine="IDN7" if NAME_1=="Jakarta Raya" & origin=="Indonesia"
replace ID_GADM_fine="IDN8" if NAME_1=="Jambi" & origin=="Indonesia"
replace ID_GADM_fine="IDN9" if NAME_1=="Jawa Barat" & origin=="Indonesia"
replace ID_GADM_fine="IDN10" if NAME_1=="Jawa Tengah" & origin=="Indonesia"
replace ID_GADM_fine="IDN11" if NAME_1=="Jawa Timur" & origin=="Indonesia"
replace ID_GADM_fine="IDN12" if NAME_1=="Kalimantan Barat" & origin=="Indonesia"
replace ID_GADM_fine="IDN13" if NAME_1=="Kalimantan Selatan" & origin=="Indonesia"
replace ID_GADM_fine="IDN14" if NAME_1=="Kalimantan Tengah" & origin=="Indonesia"
replace ID_GADM_fine="IDN15" if NAME_1=="Kalimantan Timur" & origin=="Indonesia"
replace ID_GADM_fine="IDN16" if NAME_1=="Kepulauan Riau" & origin=="Indonesia"
replace ID_GADM_fine="IDN17" if NAME_1=="Lampung" & origin=="Indonesia"
replace ID_GADM_fine="IDN19" if NAME_1=="Maluku" & origin=="Indonesia"
replace ID_GADM_fine="IDN18" if NAME_1=="Maluku Utara" & origin=="Indonesia"
replace ID_GADM_fine="IDN20" if NAME_1=="Nusa Tenggara Barat" & origin=="Indonesia"
replace ID_GADM_fine="IDN21" if NAME_1=="Nusa Tenggara Timur" & origin=="Indonesia"
replace ID_GADM_fine="IDN23" if NAME_1=="Papua" & origin=="Indonesia"
replace ID_GADM_fine="IDN24" if NAME_1=="Riau" & origin=="Indonesia"
replace ID_GADM_fine="IDN25" if NAME_1=="Sulawesi Barat" & origin=="Indonesia"
replace ID_GADM_fine="IDN26" if NAME_1=="Sulawesi Selatan" & origin=="Indonesia"
replace ID_GADM_fine="IDN27" if NAME_1=="Sulawesi Tengah" & origin=="Indonesia"
replace ID_GADM_fine="IDN29" if NAME_1=="Sulawesi Utara" & origin=="Indonesia"
replace ID_GADM_fine="IDN30" if NAME_1=="Sumatera Barat" & origin=="Indonesia"
replace ID_GADM_fine="IDN31" if NAME_1=="Sumatera Selatan" & origin=="Indonesia"
replace ID_GADM_fine="IDN32" if NAME_1=="Sumatera Utara" & origin=="Indonesia"
replace ID_GADM_fine="IDN33" if NAME_1=="Yogyakarta" & origin=="Indonesia"

* INTERNATIONAL
drop if NAME_1=="Gulf of Aden" & origin=="International"

* IRAN
replace origin="Iraq" if NAME_1=="Babil" & origin=="Iran"
replace ID_GADM_fine="IRQ9" if NAME_1=="Babil" & origin=="Iraq"
replace origin="Iraq" if NAME_1=="Baghdad" & origin=="Iran"
replace ID_GADM_fine="IRQ10" if NAME_1=="Baghdad" & origin=="Iraq"
replace NAME_1="Sistan and Baluchestan" if NAME_1=="Sistan and Balochistan" & origin=="Iran"
replace NAME_1="Sistan and Baluchestan" if NAME_1=="Sistan and Baluchestan" & origin=="Iran"
replace NAME_1="Sistan and Baluchestan" if NAME_1=="Sistan va Baluchestan" & origin=="Iran"
replace NAME_1="West Azarbaijan" if NAME_1=="West Azerbaijan" & origin=="Iran"
replace ID_GADM_fine="IRN1" if NAME_1=="Alborz" & origin=="Iran"
replace ID_GADM_fine="IRN2" if NAME_1=="Ardebil" & origin=="Iran"
replace ID_GADM_fine="IRN3" if NAME_1=="Bushehr" & origin=="Iran"
replace ID_GADM_fine="IRN4" if NAME_1=="Chahar Mahall and Bakhtiari" & origin=="Iran"
replace ID_GADM_fine="IRN5" if NAME_1=="East Azarbaijan" & origin=="Iran"
replace ID_GADM_fine="IRN6" if NAME_1=="Esfahan" & origin=="Iran"
replace ID_GADM_fine="IRN7" if NAME_1=="Fars" & origin=="Iran"
replace ID_GADM_fine="IRN8" if NAME_1=="Gilan" & origin=="Iran"
replace ID_GADM_fine="IRN9" if NAME_1=="Golestan" & origin=="Iran"
replace ID_GADM_fine="IRN10" if NAME_1=="Hamadan" & origin=="Iran"
replace ID_GADM_fine="IRN11" if NAME_1=="Hormozgan" & origin=="Iran"
replace ID_GADM_fine="IRN12" if NAME_1=="Ilam" & origin=="Iran"
replace ID_GADM_fine="IRN13" if NAME_1=="Kerman" & origin=="Iran"
replace ID_GADM_fine="IRN14" if NAME_1=="Kermanshah" & origin=="Iran"
replace ID_GADM_fine="IRN15" if NAME_1=="Khuzestan" & origin=="Iran"
replace ID_GADM_fine="IRN16" if NAME_1=="Kohgiluyeh and Buyer Ahmad" & origin=="Iran"
replace ID_GADM_fine="IRN17" if NAME_1=="Kordestan" & origin=="Iran"
replace ID_GADM_fine="IRN18" if NAME_1=="Lorestan" & origin=="Iran"
replace ID_GADM_fine="IRN19" if NAME_1=="Markazi" & origin=="Iran"
replace ID_GADM_fine="IRN20" if NAME_1=="Mazandaran" & origin=="Iran"
replace ID_GADM_fine="IRN21" if NAME_1=="North Khorasan" & origin=="Iran"
replace ID_GADM_fine="IRN22" if NAME_1=="Qazvin" & origin=="Iran"
replace ID_GADM_fine="IRN23" if NAME_1=="Qom" & origin=="Iran"
replace ID_GADM_fine="IRN24" if NAME_1=="Razavi Khorasan" & origin=="Iran"
replace ID_GADM_fine="IRN25" if NAME_1=="Semnan" & origin=="Iran"
replace ID_GADM_fine="IRN26" if NAME_1=="Sistan and Baluchestan" & origin=="Iran"
replace ID_GADM_fine="IRN27" if NAME_1=="South Khorasan" & origin=="Iran"
replace ID_GADM_fine="IRN28" if NAME_1=="Tehran" & origin=="Iran"
replace ID_GADM_fine="IRN29" if NAME_1=="West Azarbaijan" & origin=="Iran"
replace ID_GADM_fine="IRN30" if NAME_1=="Yazd" & origin=="Iran"
replace ID_GADM_fine="IRN31" if NAME_1=="Zanjan" & origin=="Iran"

* IRAQ
replace NAME_1="Al-Anbar" if NAME_1=="Al Anbar" & origin=="Iraq"
replace NAME_1="Al-Qadisiyah" if NAME_1=="Al Qadisiyah" & origin=="Iraq"
replace NAME_1="At-Ta'mim" if NAME_1=="At Tamim" & origin=="Iraq"
replace NAME_1="Al-Basrah" if NAME_1=="Basra" & origin=="Iraq"
replace origin="Russia" if NAME_1=="Chechnya" & origin=="Iraq"
replace ID_GADM_fine="RUS10" if NAME_1=="Chechnya" & origin=="Russia"
replace NAME_1="Dhi-Qar" if NAME_1=="Dhi Qar" & origin=="Iraq"
replace NAME_1="Karbala'" if NAME_1=="Karbala" & origin=="Iraq"
replace origin="Afghanistan" if NAME_1=="Khost" & origin=="Iraq"
replace ID_GADM_fine="AFG17" if NAME_1=="Khost" & origin=="Afghanistan"
replace NAME_1="At-Ta'mim" if NAME_1=="Kirkuk" & origin=="Iraq"
replace origin="Afghanistan" if NAME_1=="Kunar" & origin=="Iraq"
replace ID_GADM_fine="AFG18" if NAME_1=="Kunar" & origin=="Afghanistan"
replace NAME_1="Al-Muthannia" if NAME_1=="Muthanna" & origin=="Iraq"
replace NAME_1="Ninawa" if NAME_1=="NIneveh" & origin=="Iraq"
replace NAME_1="An-Najaf" if NAME_1=="Najaf" & origin=="Iraq"
replace NAME_1="Ninawa" if NAME_1=="Nineveh" & origin=="Iraq"
replace NAME_1="Al-Qadisiyah" if NAME_1=="Qadisiyah" & origin=="Iraq"
replace NAME_1="Sala ad-Din" if NAME_1=="Saladin" & origin=="Iraq"
replace NAME_1="As-Sulaymaniyah" if NAME_1=="Sulaymaniyah" & origin=="Iraq"
drop if NAME_1=="unknown" & origin=="Iraq"
replace ID_GADM_fine="IRQ1" if NAME_1=="Al-Anbar" & origin=="Iraq"
replace ID_GADM_fine="IRQ2" if NAME_1=="Al-Basrah" & origin=="Iraq"
replace ID_GADM_fine="IRQ3" if NAME_1=="Al-Muthannia" & origin=="Iraq"
replace ID_GADM_fine="IRQ4" if NAME_1=="Al-Qadisiyah" & origin=="Iraq"
replace ID_GADM_fine="IRQ5" if NAME_1=="An-Najaf" & origin=="Iraq"
replace ID_GADM_fine="IRQ6" if NAME_1=="Arbil" & origin=="Iraq"
replace ID_GADM_fine="IRQ7" if NAME_1=="As-Sulaymaniyah" & origin=="Iraq"
replace ID_GADM_fine="IRQ8" if NAME_1=="At-Ta'mim" & origin=="Iraq"
replace ID_GADM_fine="IRQ9" if NAME_1=="Babil" & origin=="Iraq"
replace ID_GADM_fine="IRQ10" if NAME_1=="Baghdad" & origin=="Iraq"
replace ID_GADM_fine="IRQ11" if NAME_1=="Dhi-Qar" & origin=="Iraq"
replace ID_GADM_fine="IRQ12" if NAME_1=="Dihok" & origin=="Iraq"
replace ID_GADM_fine="IRQ13" if NAME_1=="Diyala" & origin=="Iraq"
replace ID_GADM_fine="IRQ14" if NAME_1=="Karbala'" & origin=="Iraq"
replace ID_GADM_fine="IRQ15" if NAME_1=="Maysan" & origin=="Iraq"
replace ID_GADM_fine="IRQ16" if NAME_1=="Ninawa" & origin=="Iraq"
replace ID_GADM_fine="IRQ17" if NAME_1=="Sala ad-Din" & origin=="Iraq"
replace ID_GADM_fine="IRQ18" if NAME_1=="Wasit" & origin=="Iraq"

* IRELAND
replace NAME_1="Northern Ireland" if origin=="Ireland"
replace origin="United Kingdom" if NAME_1=="Northern Ireland"
replace ID_GADM_fine="GBR2" if NAME_1=="Northern Ireland" & origin=="United Kingdom"

* ISRAEL // Not in GADM --> match with GWP
replace NAME_1="Central District" if NAME_1=="Central" & origin=="Israel"
replace origin="Palestina" if NAME_1=="Gaza Strip" & origin=="Israel"
replace NAME_1="Gaza" if NAME_1=="Gaza Strip" & origin=="Palestina"
replace ID_GADM_fine="PSE1" if NAME_1=="Gaza" & origin=="Palestina"
drop if NAME_1=="Golan Heights" & origin=="Israel"
replace NAME_1="Haifa District" if NAME_1=="Haifa" & origin=="Israel"
replace NAME_1="Jerusalem District" if NAME_1=="Jerusalem" & origin=="Israel"
replace origin="Lebanon" if NAME_1=="Mount Lebanon" & origin=="Israel"
replace ID_GADM_fine="LBN5" if NAME_1=="Mount Lebanon" & origin=="Lebanon"
replace origin="Egypt" if NAME_1=="North Sinai" & origin=="Israel"
replace NAME_1="Shamal Sina'" if NAME_1=="North Sinai" & origin=="Egypt"
replace ID_GADM_fine="EGY26" if NAME_1=="Shamal Sina'" & origin=="Egypt"
replace NAME_1="Northern District" if NAME_1=="Northern" & origin=="Israel"
replace NAME_1="Southern District" if NAME_1=="Southern" & origin=="Israel"
replace NAME_1="Tel Aviv District" if NAME_1=="Tel Aviv" & origin=="Israel"
replace origin="Palestina" if NAME_1=="West Bank" & origin=="Israel"
replace ID_GADM_fine="PSE2" if NAME_1=="West Bank" & origin=="Palestina"
replace ID_GADM_fine="ISR1" if NAME_1=="Central District" & origin=="Israel"
replace ID_GADM_fine="ISR2" if NAME_1=="Haifa District" & origin=="Israel"
replace ID_GADM_fine="ISR3" if NAME_1=="Jerusalem District" & origin=="Israel"
replace ID_GADM_fine="ISR4" if NAME_1=="Northern District" & origin=="Israel"
replace ID_GADM_fine="ISR5" if NAME_1=="Southern District" & origin=="Israel"
replace ID_GADM_fine="ISR6" if NAME_1=="Tel Aviv District" & origin=="Israel"

* ITALY
replace NAME_1="Lombardia" if NAME_1=="Lombardy" & origin=="Italy"
replace NAME_1="Piemonte" if NAME_1=="Piedmont" & origin=="Italy"
replace NAME_1="Sardegna" if NAME_1=="Sardinia" & origin=="Italy"
replace NAME_1="Trentino-Alto Adige" if NAME_1=="Trentino-South Tyrol" & origin=="Italy"
replace NAME_1="Toscana" if NAME_1=="Tuscany" & origin=="Italy"
replace ID_GADM_fine="ITA1" if NAME_1=="Abruzzo" & origin=="Italy"
replace ID_GADM_fine="ITA2" if NAME_1=="Apulia" & origin=="Italy"
replace ID_GADM_fine="ITA3" if NAME_1=="Basilicata" & origin=="Italy"
replace ID_GADM_fine="ITA4" if NAME_1=="Calabria" & origin=="Italy"
replace ID_GADM_fine="ITA5" if NAME_1=="Campania" & origin=="Italy"
replace ID_GADM_fine="ITA6" if NAME_1=="Emilia-Romagna" & origin=="Italy"
replace ID_GADM_fine="ITA7" if NAME_1=="Friuli-Venezia Giulia" & origin=="Italy"
replace ID_GADM_fine="ITA8" if NAME_1=="Lazio" & origin=="Italy"
replace ID_GADM_fine="ITA9" if NAME_1=="Liguria" & origin=="Italy"
replace ID_GADM_fine="ITA10" if NAME_1=="Lombardia" & origin=="Italy"
replace ID_GADM_fine="ITA11" if NAME_1=="Marche" & origin=="Italy"
replace ID_GADM_fine="ITA12" if NAME_1=="Molise" & origin=="Italy"
replace ID_GADM_fine="ITA13" if NAME_1=="Piemonte" & origin=="Italy"
replace ID_GADM_fine="ITA14" if NAME_1=="Sardegna" & origin=="Italy"
replace ID_GADM_fine="ITA15" if NAME_1=="Sicily" & origin=="Italy"
replace ID_GADM_fine="ITA16" if NAME_1=="Toscana" & origin=="Italy"
replace ID_GADM_fine="ITA17" if NAME_1=="Trentino-Alto Adige" & origin=="Italy"
replace ID_GADM_fine="ITA18" if NAME_1=="Umbria" & origin=="Italy"
replace ID_GADM_fine="ITA19" if NAME_1=="Valle d'Aosta" & origin=="Italy"
replace ID_GADM_fine="ITA20" if NAME_1=="Veneto" & origin=="Italy"

* IVORY COAST
replace origin="Côte d'Ivoire" if origin=="Ivory Coast"
replace NAME_1="Lagunes" if NAME_1=="Agneby" & origin=="Côte d'Ivoire"
replace NAME_1="Gôh-Djiboua" if NAME_1=="Fromager" & origin=="Côte d'Ivoire"
replace NAME_1="Sassandra-Marahoué" if NAME_1=="Haut-Sassandra" & origin=="Côte d'Ivoire"
replace NAME_1="Sassandra-Marahoué" if NAME_1=="Marahoue" & origin=="Côte d'Ivoire"
replace NAME_1="Montagnes" if NAME_1=="Moyen-Cavally" & origin=="Côte d'Ivoire"
replace NAME_1="Comoé" if NAME_1=="Moyen-Comoe" & origin=="Côte d'Ivoire"
replace NAME_1="Comoé" if NAME_1=="Sud-Comoe" & origin=="Côte d'Ivoire"
replace NAME_1="Vallée du Bandama" if NAME_1=="Vallee du Bandama" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV1" if NAME_1=="Abidjan" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV2" if NAME_1=="Bas-Sassandra" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV3" if NAME_1=="Comoé" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV4" if NAME_1=="Denguélé" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV5" if NAME_1=="Gôh-Djiboua" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV6" if NAME_1=="Lacs" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV7" if NAME_1=="Lagunes" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV8" if NAME_1=="Montagnes" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV9" if NAME_1=="Sassandra-Marahoué" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV10" if NAME_1=="Savanes" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV11" if NAME_1=="Vallée du Bandama" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV12" if NAME_1=="Woroba" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV13" if NAME_1=="Yamoussoukro" & origin=="Côte d'Ivoire"
replace ID_GADM_fine="CIV14" if NAME_1=="Zanzan" & origin=="Côte d'Ivoire"

* JAMAICA
replace NAME_1="Saint Andrew" if NAME_1=="South East St. Andrew" & origin=="Jamaica"
replace ID_GADM_fine="JAM6" if NAME_1=="Saint Andrew" & origin=="Jamaica"

* JAPAN // Not in GWP --> drop
drop if origin=="Japan"
*replace NAME_1="Aichi" if NAME_1=="Aichi (Prefecture)" & origin=="Japan"
*replace NAME_1="Chiba" if NAME_1=="Chiba (Prefecture)" & origin=="Japan"
*replace NAME_1="Fukuoka" if NAME_1=="Fukuoka" & origin=="Japan"
*replace NAME_1="Kanagawa" if NAME_1=="Kanagawa (Prefecture)" & origin=="Japan"
*replace NAME_1="Tokyo" if NAME_1=="Kanto" & origin=="Japan"
*replace NAME_1="Ibaraki" if NAME_1=="Naka District, Ibaraki" & origin=="Japan"
*replace NAME_1="Ehime" if NAME_1=="Shikoku" & origin=="Japan"
*replace NAME_1="Tokyo" if NAME_1=="Tokyo (Metropolis)" & origin=="Japan"
*replace NAME_1="Tokyo" if NAME_1=="Tokyo (Prefecture)" & origin=="Japan"

* JORDAN
replace NAME_1="Amman" if NAME_1=="Capital" & origin=="Jordan"
replace NAME_1="Ma`an" if NAME_1=="Maan" & origin=="Jordan"
replace ID_GADM_fine="JOR1" if NAME_1=="Ajlun" & origin=="Jordan"
replace ID_GADM_fine="JOR2" if NAME_1=="Amman" & origin=="Jordan"
replace ID_GADM_fine="JOR3" if NAME_1=="Aqaba" & origin=="Jordan"
replace ID_GADM_fine="JOR4" if NAME_1=="Balqa" & origin=="Jordan"
replace ID_GADM_fine="JOR5" if NAME_1=="Irbid" & origin=="Jordan"
replace ID_GADM_fine="JOR6" if NAME_1=="Jarash" & origin=="Jordan"
replace ID_GADM_fine="JOR7" if NAME_1=="Karak" & origin=="Jordan"
replace ID_GADM_fine="JOR8" if NAME_1=="Ma`an" & origin=="Jordan"
replace ID_GADM_fine="JOR9" if NAME_1=="Madaba" & origin=="Jordan"
replace ID_GADM_fine="JOR10" if NAME_1=="Mafraq" & origin=="Jordan"
replace ID_GADM_fine="JOR11" if NAME_1=="Tafilah" & origin=="Jordan"
replace ID_GADM_fine="JOR12" if NAME_1=="Zarqa" & origin=="Jordan"

* KAZAKHSTAN
replace NAME_1="Aqmola" if NAME_1=="Akmola" & origin=="Kazakhstan"
replace NAME_1="Aqtöbe" if NAME_1=="Aktobe" & origin=="Kazakhstan"
replace NAME_1="Almaty" if NAME_1=="Almaty (Municipal District)" & origin=="Kazakhstan"
replace NAME_1="Almaty" if NAME_1=="Almaty Province" & origin=="Kazakhstan"
replace NAME_1="Zhambyl" if NAME_1=="Jambyl Province" & origin=="Kazakhstan"
replace NAME_1="West Kazakhstan" if NAME_1=="West Kazakhstan" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ1" if NAME_1=="Almaty" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ2" if NAME_1=="Aqmola" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ3" if NAME_1=="Aqtöbe" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ4" if NAME_1=="Atyrau" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ5" if NAME_1=="East Kazakhstan" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ6" if NAME_1=="Mangghystau" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ7" if NAME_1=="North Kazakhstan" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ8" if NAME_1=="Pavlodar" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ9" if NAME_1=="Qaraghandy" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ10" if NAME_1=="Qostanay" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ11" if NAME_1=="Qyzylorda" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ12" if NAME_1=="South Kazakhstan" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ13" if NAME_1=="West Kazakhstan" & origin=="Kazakhstan"
replace ID_GADM_fine="KAZ14" if NAME_1=="Zhambyl" & origin=="Kazakhstan"

* KENYA // Some are changed to match GWP specifically
replace NAME_1="Central Province" if NAME_1=="Central" & origin=="Kenya"
replace NAME_1="Coast Province" if NAME_1=="Coast" & origin=="Kenya"
replace NAME_1="Eastern Province" if NAME_1=="Eastern" & origin=="Kenya"
replace NAME_1="North Eastern Province" if NAME_1=="North Eastern" & origin=="Kenya"
replace NAME_1="Nyanza Province" if NAME_1=="Nyanza" & origin=="Kenya"
replace NAME_1="Rift Valley Province" if NAME_1=="Rift Valley" & origin=="Kenya"
replace NAME_1="Western Province" if NAME_1=="Western" & origin=="Kenya"
replace NAME_1="Trans Nzoia" if NAME_1=="Trans-Nzoia" & origin=="Kenya"
replace ID_GADM_fine="KEN1" if NAME_1=="Baringo" & origin=="Kenya"
replace ID_GADM_fine="KEN2" if NAME_1=="Bomet" & origin=="Kenya"
replace ID_GADM_fine="KEN3" if NAME_1=="Bungoma" & origin=="Kenya"
replace ID_GADM_fine="KEN4" if NAME_1=="Busia" & origin=="Kenya"
replace ID_GADM_fine="KEN5" if NAME_1=="Elgeyo-Marakwet" & origin=="Kenya"
replace ID_GADM_fine="KEN6" if NAME_1=="Embu" & origin=="Kenya"
replace ID_GADM_fine="KEN7" if NAME_1=="Garissa" & origin=="Kenya"
replace ID_GADM_fine="KEN8" if NAME_1=="Homa Bay" & origin=="Kenya"
replace ID_GADM_fine="KEN9" if NAME_1=="Isiolo" & origin=="Kenya"
replace ID_GADM_fine="KEN10" if NAME_1=="Kajiado" & origin=="Kenya"
replace ID_GADM_fine="KEN11" if NAME_1=="Kakamega" & origin=="Kenya"
replace ID_GADM_fine="KEN12" if NAME_1=="Kericho" & origin=="Kenya"
replace ID_GADM_fine="KEN13" if NAME_1=="Kiambu" & origin=="Kenya"
replace ID_GADM_fine="KEN14" if NAME_1=="Kilifi" & origin=="Kenya"
replace ID_GADM_fine="KEN15" if NAME_1=="Kirinyaga" & origin=="Kenya"
replace ID_GADM_fine="KEN16" if NAME_1=="Kisii" & origin=="Kenya"
replace ID_GADM_fine="KEN17" if NAME_1=="Kisumu" & origin=="Kenya"
replace ID_GADM_fine="KEN18" if NAME_1=="Kitui" & origin=="Kenya"
replace ID_GADM_fine="KEN19" if NAME_1=="Kwale" & origin=="Kenya"
replace ID_GADM_fine="KEN20" if NAME_1=="Laikipia" & origin=="Kenya"
replace ID_GADM_fine="KEN21" if NAME_1=="Lamu" & origin=="Kenya"
replace ID_GADM_fine="KEN22" if NAME_1=="Machakos" & origin=="Kenya"
replace ID_GADM_fine="KEN23" if NAME_1=="Makueni" & origin=="Kenya"
replace ID_GADM_fine="KEN24" if NAME_1=="Mandera" & origin=="Kenya"
replace ID_GADM_fine="KEN25" if NAME_1=="Marsabit" & origin=="Kenya"
replace ID_GADM_fine="KEN26" if NAME_1=="Meru" & origin=="Kenya"
replace ID_GADM_fine="KEN27" if NAME_1=="Migori" & origin=="Kenya"
replace ID_GADM_fine="KEN28" if NAME_1=="Mombasa" & origin=="Kenya"
replace ID_GADM_fine="KEN29" if NAME_1=="Murang'a" & origin=="Kenya"
replace ID_GADM_fine="KEN30" if NAME_1=="Nairobi" & origin=="Kenya"
replace ID_GADM_fine="KEN31" if NAME_1=="Nakuru" & origin=="Kenya"
replace ID_GADM_fine="KEN32" if NAME_1=="Nandi" & origin=="Kenya"
replace ID_GADM_fine="KEN33" if NAME_1=="Narok" & origin=="Kenya"
replace ID_GADM_fine="KEN34" if NAME_1=="Nyamira" & origin=="Kenya"
replace ID_GADM_fine="KEN35" if NAME_1=="Nyandarua" & origin=="Kenya"
replace ID_GADM_fine="KEN36" if NAME_1=="Nyeri" & origin=="Kenya"
replace ID_GADM_fine="KEN37" if NAME_1=="Samburu" & origin=="Kenya"
replace ID_GADM_fine="KEN38" if NAME_1=="Siaya" & origin=="Kenya"
replace ID_GADM_fine="KEN39" if NAME_1=="Taita Taveta" & origin=="Kenya"
replace ID_GADM_fine="KEN40" if NAME_1=="Tana River" & origin=="Kenya"
replace ID_GADM_fine="KEN41" if NAME_1=="Tharaka-Nithi" & origin=="Kenya"
replace ID_GADM_fine="KEN42" if NAME_1=="Trans Nzoia" & origin=="Kenya"
replace ID_GADM_fine="KEN43" if NAME_1=="Turkana" & origin=="Kenya"
replace ID_GADM_fine="KEN44" if NAME_1=="Uasin Gishu" & origin=="Kenya"
replace ID_GADM_fine="KEN45" if NAME_1=="Vihiga" & origin=="Kenya"
replace ID_GADM_fine="KEN46" if NAME_1=="Wajir" & origin=="Kenya"
replace ID_GADM_fine="KEN47" if NAME_1=="West Pokot" & origin=="Kenya"
replace ID_GADM_fine="KEN48" if NAME_1=="Central Province" & origin=="Kenya"
replace ID_GADM_fine="KEN49" if NAME_1=="Coast Province" & origin=="Kenya"
replace ID_GADM_fine="KEN50" if NAME_1=="Eastern Province" & origin=="Kenya"
replace ID_GADM_fine="KEN51" if NAME_1=="North Eastern Province" & origin=="Kenya"
replace ID_GADM_fine="KEN52" if NAME_1=="Nyanza Province" & origin=="Kenya"
replace ID_GADM_fine="KEN53" if NAME_1=="Rift Valley Province" & origin=="Kenya"
replace ID_GADM_fine="KEN54" if NAME_1=="Western Province" & origin=="Kenya"

* KOSOVO
replace NAME_1="Đakovica" if NAME_1=="Dakovica" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="District of Kosovska Mitrovica" & origin=="Kosovo"
replace NAME_1="Đakovica" if NAME_1=="Gjakova" & origin=="Kosovo"
replace NAME_1="Gnjilane" if NAME_1=="Gjilane" & origin=="Kosovo"
replace NAME_1="Gnjilane" if NAME_1=="Gnjilane (Region)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Kosovo" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Kosovo (Province)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Kosovo (State)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Kosovo and Metojia (Autonomous Province)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Kosovo-Metohija (Province)" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Kosovska Mitrovica" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Kosovska Mitrovica (District)" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Kosovsko Mitrovica" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Leposaviq" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Mitrovice" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Mitrovice (Municipality)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Obilic (Municipality)" & origin=="Kosovo"
replace NAME_1="Prizren" if NAME_1=="Opoja (Municipality)" & origin=="Kosovo"
replace NAME_1="Pećki" if NAME_1=="Pec" & origin=="Kosovo"
replace NAME_1="Pećki" if NAME_1=="Pec (District)" & origin=="Kosovo"
replace NAME_1="Pećki" if NAME_1=="Pecki" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Prishtine (Municipality)" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Pristina" & origin=="Kosovo"
replace NAME_1="Pristina" if NAME_1=="Pristina district" & origin=="Kosovo"
replace NAME_1="Prizren" if NAME_1=="Prizren" & origin=="Kosovo"
replace NAME_1="Uroševac" if NAME_1=="Urosevac" & origin=="Kosovo"
replace NAME_1="Kosovska Mitrovica" if NAME_1=="Zubin Potok" & origin=="Kosovo"
replace ID_GADM_fine="XKO1" if NAME_1=="Đakovica" & origin=="Kosovo"
replace ID_GADM_fine="XKO2" if NAME_1=="Gnjilane" & origin=="Kosovo"
replace ID_GADM_fine="XKO3" if NAME_1=="Kosovska Mitrovica" & origin=="Kosovo"
replace ID_GADM_fine="XKO4" if NAME_1=="Pećki" & origin=="Kosovo"
replace ID_GADM_fine="XKO5" if NAME_1=="Pristina" & origin=="Kosovo"
replace ID_GADM_fine="XKO6" if NAME_1=="Prizren" & origin=="Kosovo"
replace ID_GADM_fine="XKO7" if NAME_1=="Uroševac" & origin=="Kosovo"

* KUWAIT // Not in GADM --> based on GWP
replace NAME_1="Al Ahmadi" if NAME_1=="Ahmadi" & origin=="Kuwait"
replace NAME_1="Al Juhraa" if NAME_1=="Jahra" & origin=="Kuwait"
replace NAME_1="Al Asimah" if NAME_1=="Asimah" & origin=="Kuwait"
replace ID_GADM_fine="RKS1" if NAME_1=="Al Ahmadi" & origin=="Kuwait"
replace ID_GADM_fine="RKS2" if NAME_1=="Al Juhraa" & origin=="Kuwait"
replace ID_GADM_fine="RKS3" if NAME_1=="Al Asimah" & origin=="Kuwait"

* KYRGYZSTAN
replace NAME_1="Batken" if NAME_1=="Batken (Province)" & origin=="Kyrgyzstan"
replace NAME_1="Biškek" if NAME_1=="Bishkek" & origin=="Kyrgyzstan"
replace NAME_1="Biškek" if NAME_1=="Bishkek (Capital City)" & origin=="Kyrgyzstan"
replace NAME_1="Biškek" if NAME_1=="Bishkek (Province)" & origin=="Kyrgyzstan"
replace NAME_1="Chüy" if NAME_1=="Chuy" & origin=="Kyrgyzstan"
replace NAME_1="Chüy" if NAME_1=="Chuy (Province)" & origin=="Kyrgyzstan"
replace NAME_1="Chüy" if NAME_1=="Chuy Province" & origin=="Kyrgyzstan"
replace NAME_1="Ysyk-Köl" if NAME_1=="Issyk Kul" & origin=="Kyrgyzstan"
replace NAME_1="Jalal-Abad" if NAME_1=="JalAl-Abad" & origin=="Kyrgyzstan"
replace NAME_1="Osh (city)" if NAME_1=="Osh (Oblast)" & origin=="Kyrgyzstan"
replace NAME_1="Osh (city)" if NAME_1=="Osh (Province)" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ1" if NAME_1=="Batken" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ2" if NAME_1=="Biškek" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ3" if NAME_1=="Chüy" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ4" if NAME_1=="Jalal-Abad" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ5" if NAME_1=="Naryn" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ6" if NAME_1=="Osh (city)" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ7" if NAME_1=="Osh" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ8" if NAME_1=="Talas" & origin=="Kyrgyzstan"
replace ID_GADM_fine="KGZ9" if NAME_1=="Ysyk-Köl" & origin=="Kyrgyzstan"

* LAOS
replace NAME_1="Louangphrabang" if NAME_1=="Louangphrabang (District)" & origin=="Laos"
replace NAME_1="Vientiane" if NAME_1=="Vientiane (Prefecture)" & origin=="Laos"
replace NAME_1="Xaisômboun" if NAME_1=="Xaisomboun" & origin=="Laos"
replace ID_GADM_fine="LAO1" if NAME_1=="Attapu" & origin=="Laos"
replace ID_GADM_fine="LAO2" if NAME_1=="Bokeo" & origin=="Laos"
replace ID_GADM_fine="LAO3" if NAME_1=="Bolikhamxai" & origin=="Laos"
replace ID_GADM_fine="LAO4" if NAME_1=="Champasak" & origin=="Laos"
replace ID_GADM_fine="LAO5" if NAME_1=="Houaphan" & origin=="Laos"
replace ID_GADM_fine="LAO6" if NAME_1=="Khammouan" & origin=="Laos"
replace ID_GADM_fine="LAO7" if NAME_1=="Louang Namtha" & origin=="Laos"
replace ID_GADM_fine="LAO8" if NAME_1=="Louangphrabang" & origin=="Laos"
replace ID_GADM_fine="LAO9" if NAME_1=="Oudômxai" & origin=="Laos"
replace ID_GADM_fine="LAO10" if NAME_1=="Phôngsali" & origin=="Laos"
replace ID_GADM_fine="LAO11" if NAME_1=="Saravan" & origin=="Laos"
replace ID_GADM_fine="LAO12" if NAME_1=="Savannakhét" & origin=="Laos"
replace ID_GADM_fine="LAO13" if NAME_1=="Vientiane [prefecture]" & origin=="Laos"
replace ID_GADM_fine="LAO14" if NAME_1=="Vientiane" & origin=="Laos"
replace ID_GADM_fine="LAO15" if NAME_1=="Xaignabouri" & origin=="Laos"
replace ID_GADM_fine="LAO16" if NAME_1=="Xaisômboun" & origin=="Laos"
replace ID_GADM_fine="LAO17" if NAME_1=="Xékong" & origin=="Laos"
replace ID_GADM_fine="LAO18" if NAME_1=="Xiangkhoang" & origin=="Laos"

* LATVIA
replace NAME_1="Riga" if NAME_1=="Riga" & origin=="Latvia"
replace NAME_1="Riga" if NAME_1=="Riga (City)" & origin=="Latvia"
replace ID_GADM_fine="LVA1" if NAME_1=="Kurzeme" & origin=="Latvia"
replace ID_GADM_fine="LVA2" if NAME_1=="Latgale" & origin=="Latvia"
replace ID_GADM_fine="LVA3" if NAME_1=="Riga" & origin=="Latvia"
replace ID_GADM_fine="LVA4" if NAME_1=="Vidzeme" & origin=="Latvia"
replace ID_GADM_fine="LVA5" if NAME_1=="Zemgale" & origin=="Latvia"

* LEBANON
replace NAME_1="Nabatiyeh" if NAME_1=="An Nabatiyah" & origin=="Lebanon"
replace NAME_1="Bekaa" if NAME_1=="Beqaa" & origin=="Lebanon"
replace ID_GADM_fine="LBN1" if NAME_1=="Akkar" & origin=="Lebanon"
replace ID_GADM_fine="LBN2" if NAME_1=="Baalbak - Hermel" & origin=="Lebanon"
replace ID_GADM_fine="LBN3" if NAME_1=="Beirut" & origin=="Lebanon"
replace ID_GADM_fine="LBN4" if NAME_1=="Bekaa" & origin=="Lebanon"
replace ID_GADM_fine="LBN5" if NAME_1=="Mount Lebanon" & origin=="Lebanon"
replace ID_GADM_fine="LBN6" if NAME_1=="Nabatiyeh" & origin=="Lebanon"
replace ID_GADM_fine="LBN7" if NAME_1=="North" & origin=="Lebanon"
replace ID_GADM_fine="LBN8" if NAME_1=="South" & origin=="Lebanon"

* LESOTHO // Not in GADM, use GWP as reference
replace ID_GADM_fine="LSO5" if NAME_1=="Maseru" & origin=="Lesotho"

* LIBERIA
replace NAME_1="Gbapolu" if NAME_1=="Gbarpolu" & origin=="Liberia"
replace NAME_1="GrandGedeh" if NAME_1=="Grand Gedeh" & origin=="Liberia"
replace ID_GADM_fine="LBR1" if NAME_1=="Bomi" & origin=="Liberia"
replace ID_GADM_fine="LBR2" if NAME_1=="Bong" & origin=="Liberia"
replace ID_GADM_fine="LBR3" if NAME_1=="Gbapolu" & origin=="Liberia"
replace ID_GADM_fine="LBR4" if NAME_1=="Grand Cape Mount" & origin=="Liberia"
replace ID_GADM_fine="LBR5" if NAME_1=="GrandBassa" & origin=="Liberia"
replace ID_GADM_fine="LBR6" if NAME_1=="GrandGedeh" & origin=="Liberia"
replace ID_GADM_fine="LBR7" if NAME_1=="GrandKru" & origin=="Liberia"
replace ID_GADM_fine="LBR8" if NAME_1=="Lofa" & origin=="Liberia"
replace ID_GADM_fine="LBR9" if NAME_1=="Margibi" & origin=="Liberia"
replace ID_GADM_fine="LBR10" if NAME_1=="Maryland" & origin=="Liberia"
replace ID_GADM_fine="LBR11" if NAME_1=="Montserrado" & origin=="Liberia"
replace ID_GADM_fine="LBR12" if NAME_1=="Nimba" & origin=="Liberia"
replace ID_GADM_fine="LBR13" if NAME_1=="River Cess" & origin=="Liberia"
replace ID_GADM_fine="LBR14" if NAME_1=="River Gee" & origin=="Liberia"
replace ID_GADM_fine="LBR15" if NAME_1=="Sinoe" & origin=="Liberia"

* LIBYA // Not in GADM --> use GWP as reference
replace NAME_1="Al-Butnan" if NAME_1=="Butnan" & origin=="Libya"
replace NAME_1="Darnah" if NAME_1=="Derna" & origin=="Libya"
replace NAME_1="Al-Jabal al-Akhdar" if NAME_1=="Jabal Al Akhdar" & origin=="Libya"
replace NAME_1="Al Jabal al Gharbi" if NAME_1=="Jabal Al Gharbi" & origin=="Libya"
replace NAME_1="Al-Jifarah" if NAME_1=="Jafara" & origin=="Libya"
replace NAME_1="Al Jufrah" if NAME_1=="Jufra" & origin=="Libya"
replace NAME_1="Al-Kufrah" if NAME_1=="Kufra" & origin=="Libya"
replace NAME_1="Al-Kufrah" if NAME_1=="Kufrah" & origin=="Libya"
replace NAME_1="Al-Marj" if NAME_1=="Marj" & origin=="Libya"
replace NAME_1="Misratah" if NAME_1=="Misrata" & origin=="Libya"
replace NAME_1="Al-Marqab" if NAME_1=="Murqub" & origin=="Libya"
replace NAME_1="An Nuqat al Khams" if NAME_1=="Nuqat Al Khams" & origin=="Libya"
replace NAME_1="Sabha" if NAME_1=="Sabha" & origin=="Libya"
replace NAME_1="Surt" if NAME_1=="Sirte" & origin=="Libya"
replace origin="Lebanon" if NAME_1=="Tripoli" & origin=="Libya"
replace NAME_1="North" if NAME_1=="Tripoli" & origin=="Lebanon"
replace ID_GADM_fine="LBN7" if NAME_1=="North" & origin=="Lebanon"
replace NAME_1="Wadi al Hayat" if NAME_1=="Wadi Al Hayaa" & origin=="Libya"
replace NAME_1="Wadi ash Shati" if NAME_1=="Wadi Al Shatii" & origin=="Libya"
replace NAME_1="Al-Wahah" if NAME_1=="Wahat" & origin=="Libya"
replace NAME_1="Az-Zawiyah" if NAME_1=="Zawiya" & origin=="Libya"
replace ID_GADM_fine="LBY1" if NAME_1=="Al-Butnan" & origin=="Libya"
replace ID_GADM_fine="LBY2" if NAME_1=="Al-Jabal al-Akhdar" & origin=="Libya"
replace ID_GADM_fine="LBY3" if NAME_1=="Al Jabal al Gharbi" & origin=="Libya"
replace ID_GADM_fine="LBY4" if NAME_1=="Al-Jifarah" & origin=="Libya"
replace ID_GADM_fine="LBY5" if NAME_1=="Al Jufrah" & origin=="Libya"
replace ID_GADM_fine="LBY6" if NAME_1=="Al-Kufrah" & origin=="Libya"
replace ID_GADM_fine="LBY7" if NAME_1=="Al-Marj" & origin=="Libya"
replace ID_GADM_fine="LBY8" if NAME_1=="Al-Marqab" & origin=="Libya"
replace ID_GADM_fine="LBY9" if NAME_1=="Al-Wahah" & origin=="Libya"
replace ID_GADM_fine="LBY10" if NAME_1=="An Nuqat al Khams" & origin=="Libya"
replace ID_GADM_fine="LBY11" if NAME_1=="Az-Zawiyah" & origin=="Libya"
replace ID_GADM_fine="LBY12" if NAME_1=="Benghazi" & origin=="Libya"
replace ID_GADM_fine="LBY13" if NAME_1=="Darnah" & origin=="Libya"
replace ID_GADM_fine="LBY14" if NAME_1=="Ghat" & origin=="Libya"
replace ID_GADM_fine="LBY15" if NAME_1=="Misratah" & origin=="Libya"
replace ID_GADM_fine="LBY16" if NAME_1=="Murzuq" & origin=="Libya"
replace ID_GADM_fine="LBY17" if NAME_1=="Nalut" & origin=="Libya"
replace ID_GADM_fine="LBY18" if NAME_1=="Sabha" & origin=="Libya"
replace ID_GADM_fine="LBY19" if NAME_1=="Surt" & origin=="Libya"
replace ID_GADM_fine="LBY20" if NAME_1=="Tarabulus" & origin=="Libya"
replace ID_GADM_fine="LBY21" if NAME_1=="Wadi al Hayat" & origin=="Libya"
replace ID_GADM_fine="LBY22" if NAME_1=="Wadi ash Shati" & origin=="Libya"

* MACEDONIA // Not in GADM --> Use GWP as reference
replace NAME_1="Skopje" if NAME_1=="Aracinovo (Municipality)" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Gostivar" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Gostivar (Municipality)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Greater Skopje (Administrative division)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Greater Skopje (Special Division)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Greater Skopje (Statistical Region)" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Jegunovce" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Jegunovce (Municipality)" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Kumanovo" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Kumanovo (Municipality)" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Kumanovo (Region)" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Kumanovo municipality" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Lipkovo (Municipality)" & origin=="Macedonia"
replace NAME_1="Northeastern" if NAME_1=="Lipkovo (Region)" & origin=="Macedonia"
drop if NAME_1=="Macedonia" & origin=="Macedonia"
replace NAME_1="Southeastern" if NAME_1=="Opstina Strumica (Region)" & origin=="Macedonia"
replace NAME_1="Southwestern" if NAME_1=="Oslomej (Municipality)" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Polog (Region)" & origin=="Macedonia"
replace NAME_1="Pelagonia" if NAME_1=="Prilep (Municipality)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Skopje (District)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Skopje (Municipality)" & origin=="Macedonia"
replace NAME_1="Skopje" if NAME_1=="Skopje (Region)" & origin=="Macedonia"
replace NAME_1="Southwestern" if NAME_1=="Struga municipality" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Tearce (Municipality)" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Tearce municipality" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Tetovo" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Tetovo (Municipality)" & origin=="Macedonia"
replace NAME_1="Polog" if NAME_1=="Tetovo Municipality" & origin=="Macedonia"
replace ID_GADM_fine="MKD1" if NAME_1=="Eastern" & origin=="Macedonia"
replace ID_GADM_fine="MKD2" if NAME_1=="Northeastern" & origin=="Macedonia"
replace ID_GADM_fine="MKD3" if NAME_1=="Pelagonia" & origin=="Macedonia"
replace ID_GADM_fine="MKD4" if NAME_1=="Polog" & origin=="Macedonia"
replace ID_GADM_fine="MKD5" if NAME_1=="Skopje" & origin=="Macedonia"
replace ID_GADM_fine="MKD6" if NAME_1=="Southeastern" & origin=="Macedonia"
replace ID_GADM_fine="MKD7" if NAME_1=="Southwestern" & origin=="Macedonia"
replace ID_GADM_fine="MKD8" if NAME_1=="Vardar" & origin=="Macedonia"

* MADAGASCAR
replace NAME_1="Antananarivo" if NAME_1=="Analamanga" & origin=="Madagascar"
replace ID_GADM_fine="MDG1" if NAME_1=="Antananarivo" & origin=="Madagascar"
replace ID_GADM_fine="MDG2" if NAME_1=="Antsiranana" & origin=="Madagascar"
replace ID_GADM_fine="MDG3" if NAME_1=="Fianarantsoa" & origin=="Madagascar"
replace ID_GADM_fine="MDG4" if NAME_1=="Mahajanga" & origin=="Madagascar"
replace ID_GADM_fine="MDG5" if NAME_1=="Toamasina" & origin=="Madagascar"
replace ID_GADM_fine="MDG6" if NAME_1=="Toliary" & origin=="Madagascar"

* MALAWI
replace NAME_1="Lilongwe" if NAME_1=="Central" & origin=="Malawi"
replace ID_GADM_fine="MWI11" if NAME_1=="Lilongwe" & origin=="Malawi"

* MALAYSIA
drop if NAME_1=="Federal Territory" & origin=="Malaysia"
replace NAME_1="Kedah" if NAME_1=="Kedah (State)" & origin=="Malaysia"
replace NAME_1="Kuala Lumpur" if NAME_1=="Kuala Lumpur" & origin=="Malaysia"
replace NAME_1="Pulau Pinang" if NAME_1=="Penang" & origin=="Malaysia"
replace NAME_1="Sabah" if NAME_1=="Sabah (State)" & origin=="Malaysia"
replace ID_GADM_fine="MYS1" if NAME_1=="Johor" & origin=="Malaysia"
replace ID_GADM_fine="MYS2" if NAME_1=="Kedah" & origin=="Malaysia"
replace ID_GADM_fine="MYS3" if NAME_1=="Kelantan" & origin=="Malaysia"
replace ID_GADM_fine="MYS4" if NAME_1=="Kuala Lumpur" & origin=="Malaysia"
replace ID_GADM_fine="MYS5" if NAME_1=="Labuan" & origin=="Malaysia"
replace ID_GADM_fine="MYS6" if NAME_1=="Melaka" & origin=="Malaysia"
replace ID_GADM_fine="MYS7" if NAME_1=="Negeri Sembilan" & origin=="Malaysia"
replace ID_GADM_fine="MYS8" if NAME_1=="Pahang" & origin=="Malaysia"
replace ID_GADM_fine="MYS9" if NAME_1=="Perak" & origin=="Malaysia"
replace ID_GADM_fine="MYS10" if NAME_1=="Perlis" & origin=="Malaysia"
replace ID_GADM_fine="MYS11" if NAME_1=="Pulau Pinang" & origin=="Malaysia"
replace ID_GADM_fine="MYS12" if NAME_1=="Putrajaya" & origin=="Malaysia"
replace ID_GADM_fine="MYS13" if NAME_1=="Sabah" & origin=="Malaysia"
replace ID_GADM_fine="MYS14" if NAME_1=="Sarawak" & origin=="Malaysia"
replace ID_GADM_fine="MYS15" if NAME_1=="Selangor" & origin=="Malaysia"
replace ID_GADM_fine="MYS16" if NAME_1=="Trengganu" & origin=="Malaysia"

* MALDIVES // Not in GADM, not in GWP --> drop
drop if origin=="Maldives"

* MALI
replace NAME_1="Ségou" if NAME_1=="Segou" & origin=="Mali"
replace ID_GADM_fine="MLI1" if NAME_1=="Bamako" & origin=="Mali"
replace ID_GADM_fine="MLI2" if NAME_1=="Gao" & origin=="Mali"
replace ID_GADM_fine="MLI3" if NAME_1=="Kayes" & origin=="Mali"
replace ID_GADM_fine="MLI4" if NAME_1=="Kidal" & origin=="Mali"
replace ID_GADM_fine="MLI5" if NAME_1=="Koulikoro" & origin=="Mali"
replace ID_GADM_fine="MLI6" if NAME_1=="Mopti" & origin=="Mali"
replace ID_GADM_fine="MLI7" if NAME_1=="Ségou" & origin=="Mali"
replace ID_GADM_fine="MLI8" if NAME_1=="Sikasso" & origin=="Mali"
replace ID_GADM_fine="MLI9" if NAME_1=="Timbuktu" & origin=="Mali"

* MALTA
replace NAME_1="Xlokk" if NAME_1=="South Eastern" & origin=="Malta"
replace NAME_1="Nofsinhar" if NAME_1=="Zebbug" & origin=="Malta"
replace ID_GADM_fine="MLT1" if NAME_1=="Ċentrali" & origin=="Malta"
replace ID_GADM_fine="MLT2" if NAME_1=="Għawdex" & origin=="Malta"
replace ID_GADM_fine="MLT3" if NAME_1=="Nofsinhar" & origin=="Malta"
replace ID_GADM_fine="MLT4" if NAME_1=="Tramuntana" & origin=="Malta"
replace ID_GADM_fine="MLT5" if NAME_1=="Xlokk" & origin=="Malta"

* MAURITANIA
replace NAME_1="Trarza" if NAME_1=="Traza" & origin=="Mauritania"
replace ID_GADM_fine="MRT1" if NAME_1=="Adrar" & origin=="Mauritania"
replace ID_GADM_fine="MRT2" if NAME_1=="Assaba" & origin=="Mauritania"
replace ID_GADM_fine="MRT3" if NAME_1=="Brakna" & origin=="Mauritania"
replace ID_GADM_fine="MRT4" if NAME_1=="Dakhlet Nouadhibou" & origin=="Mauritania"
replace ID_GADM_fine="MRT5" if NAME_1=="Gorgol" & origin=="Mauritania"
replace ID_GADM_fine="MRT6" if NAME_1=="Guidimaka" & origin=="Mauritania"
replace ID_GADM_fine="MRT7" if NAME_1=="Hodh ech Chargui" & origin=="Mauritania"
replace ID_GADM_fine="MRT8" if NAME_1=="Hodh el Gharbi" & origin=="Mauritania"
replace ID_GADM_fine="MRT9" if NAME_1=="Inchiri" & origin=="Mauritania"
replace ID_GADM_fine="MRT10" if NAME_1=="Nouakchott" & origin=="Mauritania"
replace ID_GADM_fine="MRT11" if NAME_1=="Tagant" & origin=="Mauritania"
replace ID_GADM_fine="MRT12" if NAME_1=="Tiris Zemmour" & origin=="Mauritania"
replace ID_GADM_fine="MRT13" if NAME_1=="Trarza" & origin=="Mauritania"

* MEXICO
replace NAME_1="Guerrero" if NAME_1=="Acapulco" & origin=="Mexico"
replace NAME_1="Distrito Federal" if NAME_1=="Federal" & origin=="Mexico"
replace NAME_1="Distrito Federal" if NAME_1=="Federal (District)" & origin=="Mexico"
replace NAME_1="Distrito Federal" if NAME_1=="Federal District" & origin=="Mexico"
replace NAME_1="Guerrero" if NAME_1=="Guerrero (State)" & origin=="Mexico"
replace NAME_1="Distrito Federal" if NAME_1=="Mexican Federal District" & origin=="Mexico"
replace NAME_1="México" if NAME_1=="Mexico" & origin=="Mexico"
replace NAME_1="México" if NAME_1=="Mexico City (Federal District)" & origin=="Mexico"
replace NAME_1="Michoacán" if NAME_1=="Michoacan" & origin=="Mexico"
replace NAME_1="Nuevo León" if NAME_1=="Nuevo Leon" & origin=="Mexico"
replace NAME_1="Nuevo León" if NAME_1=="Nuevo Leon (State)" & origin=="Mexico"
replace NAME_1="Oaxaca" if NAME_1=="Oaxaca (State)" & origin=="Mexico"
replace NAME_1="Querétaro" if NAME_1=="Queretaro (State)" & origin=="Mexico"
replace NAME_1="Quintana Roo" if NAME_1=="Quintana" & origin=="Mexico"
replace NAME_1="Tamaulipas" if NAME_1=="Tamaulipas (State)" & origin=="Mexico"
replace NAME_1="Veracruz" if NAME_1=="Veracruz (State)" & origin=="Mexico"
drop if NAME_1=="Veracruz (State) and Tlaxcala (State)" & origin=="Mexico"
replace ID_GADM_fine="MEX1" if NAME_1=="Aguascalientes" & origin=="Mexico"
replace ID_GADM_fine="MEX2" if NAME_1=="Baja California Sur" & origin=="Mexico"
replace ID_GADM_fine="MEX3" if NAME_1=="Baja California" & origin=="Mexico"
replace ID_GADM_fine="MEX4" if NAME_1=="Campeche" & origin=="Mexico"
replace ID_GADM_fine="MEX5" if NAME_1=="Chiapas" & origin=="Mexico"
replace ID_GADM_fine="MEX6" if NAME_1=="Chihuahua" & origin=="Mexico"
replace ID_GADM_fine="MEX7" if NAME_1=="Coahuila" & origin=="Mexico"
replace ID_GADM_fine="MEX8" if NAME_1=="Colima" & origin=="Mexico"
replace ID_GADM_fine="MEX9" if NAME_1=="Distrito Federal" & origin=="Mexico"
replace ID_GADM_fine="MEX10" if NAME_1=="Durango" & origin=="Mexico"
replace ID_GADM_fine="MEX11" if NAME_1=="Guanajuato" & origin=="Mexico"
replace ID_GADM_fine="MEX12" if NAME_1=="Guerrero" & origin=="Mexico"
replace ID_GADM_fine="MEX13" if NAME_1=="Hidalgo" & origin=="Mexico"
replace ID_GADM_fine="MEX14" if NAME_1=="Jalisco" & origin=="Mexico"
replace ID_GADM_fine="MEX15" if NAME_1=="México" & origin=="Mexico"
replace ID_GADM_fine="MEX16" if NAME_1=="Michoacán" & origin=="Mexico"
replace ID_GADM_fine="MEX17" if NAME_1=="Morelos" & origin=="Mexico"
replace ID_GADM_fine="MEX18" if NAME_1=="Nayarit" & origin=="Mexico"
replace ID_GADM_fine="MEX19" if NAME_1=="Nuevo León" & origin=="Mexico"
replace ID_GADM_fine="MEX20" if NAME_1=="Oaxaca" & origin=="Mexico"
replace ID_GADM_fine="MEX21" if NAME_1=="Puebla" & origin=="Mexico"
replace ID_GADM_fine="MEX22" if NAME_1=="Querétaro" & origin=="Mexico"
replace ID_GADM_fine="MEX23" if NAME_1=="Quintana Roo" & origin=="Mexico"
replace ID_GADM_fine="MEX24" if NAME_1=="San Luis Potosí" & origin=="Mexico"
replace ID_GADM_fine="MEX25" if NAME_1=="Sinaloa" & origin=="Mexico"
replace ID_GADM_fine="MEX26" if NAME_1=="Sonora" & origin=="Mexico"
replace ID_GADM_fine="MEX27" if NAME_1=="Tabasco" & origin=="Mexico"
replace ID_GADM_fine="MEX28" if NAME_1=="Tamaulipas" & origin=="Mexico"
replace ID_GADM_fine="MEX29" if NAME_1=="Tlaxcala" & origin=="Mexico"
replace ID_GADM_fine="MEX30" if NAME_1=="Veracruz" & origin=="Mexico"
replace ID_GADM_fine="MEX31" if NAME_1=="Yucatán" & origin=="Mexico"
replace ID_GADM_fine="MEX32" if NAME_1=="Zacatecas" & origin=="Mexico"

* MOLDOVA // Based on GWP
drop if NAME_1=="Bender" & origin=="Moldova"
replace NAME_1="Municipality Chisinau" if NAME_1=="Chisinau" & origin=="Moldova"
replace NAME_1="Municipality Chisinau" if NAME_1=="Chisinau (Municipality)" & origin=="Moldova"
drop if NAME_1=="Dniester (Region)" & origin=="Moldova"
replace ID_GADM_fine="MDA12" if NAME_1=="Municipality Chisinau" & origin=="Moldova"

* MONTENEGRO // Based on GWP
replace ID_GADM_fine="MNE5" if NAME_1=="Berane" & origin=="Montenegro"
replace ID_GADM_fine="MNE11" if NAME_1=="Kolasin" & origin=="Montenegro"
replace ID_GADM_fine="MNE18" if NAME_1=="Podgorica" & origin=="Montenegro"

* MOROCCO
replace NAME_1="Grand Casablanca" if NAME_1=="Greater Casablanca (Region)" & origin=="Morocco"
replace NAME_1="Marrakech - Tensift - Al Haouz" if NAME_1=="Marrakech-Tensift-El Haouz" & origin=="Morocco"
replace NAME_1="Meknès - Tafilalet" if NAME_1=="Meknes-Tafilalet (Region)" & origin=="Morocco"
replace ID_GADM_fine="MAR1" if NAME_1=="Chaouia - Ouardigha" & origin=="Morocco"
replace ID_GADM_fine="MAR2" if NAME_1=="Doukkala - Abda" & origin=="Morocco"
replace ID_GADM_fine="MAR3" if NAME_1=="Fès - Boulemane" & origin=="Morocco"
replace ID_GADM_fine="MAR4" if NAME_1=="Gharb - Chrarda - Béni Hssen" & origin=="Morocco"
replace ID_GADM_fine="MAR5" if NAME_1=="Grand Casablanca" & origin=="Morocco"
replace ID_GADM_fine="MAR6" if NAME_1=="Guelmim - Es-Semara" & origin=="Morocco"
replace ID_GADM_fine="MAR7" if NAME_1=="Laâyoune - Boujdour - Sakia El Hamra" & origin=="Morocco"
replace ID_GADM_fine="MAR8" if NAME_1=="Marrakech - Tensift - Al Haouz" & origin=="Morocco"
replace ID_GADM_fine="MAR9" if NAME_1=="Meknès - Tafilalet" & origin=="Morocco"
replace ID_GADM_fine="MAR10" if NAME_1=="Oriental" & origin=="Morocco"
replace ID_GADM_fine="MAR11" if NAME_1=="Rabat - Salé - Zemmour - Zaer" & origin=="Morocco"
replace ID_GADM_fine="MAR12" if NAME_1=="Souss - Massa - Draâ" & origin=="Morocco"
replace ID_GADM_fine="MAR13" if NAME_1=="Tadla - Azilal" & origin=="Morocco"
replace ID_GADM_fine="MAR14" if NAME_1=="Tanger - Tétouan" & origin=="Morocco"
replace ID_GADM_fine="MAR15" if NAME_1=="Taza - Al Hoceima - Taounate" & origin=="Morocco"

* MOZAMBIQUE
replace NAME_1="Nassa" if NAME_1=="Niassa" & origin=="Mozambique"
replace ID_GADM_fine="MOZ1" if NAME_1=="Cabo Delgado" & origin=="Mozambique"
replace ID_GADM_fine="MOZ2" if NAME_1=="Gaza" & origin=="Mozambique"
replace ID_GADM_fine="MOZ3" if NAME_1=="Inhambane" & origin=="Mozambique"
replace ID_GADM_fine="MOZ4" if NAME_1=="Manica" & origin=="Mozambique"
replace ID_GADM_fine="MOZ5" if NAME_1=="Maputo City" & origin=="Mozambique"
replace ID_GADM_fine="MOZ6" if NAME_1=="Maputo" & origin=="Mozambique"
replace ID_GADM_fine="MOZ7" if NAME_1=="Nampula" & origin=="Mozambique"
replace ID_GADM_fine="MOZ8" if NAME_1=="Nassa" & origin=="Mozambique"
replace ID_GADM_fine="MOZ9" if NAME_1=="Sofala" & origin=="Mozambique"
replace ID_GADM_fine="MOZ10" if NAME_1=="Tete" & origin=="Mozambique"
replace ID_GADM_fine="MOZ11" if NAME_1=="Zambezia" & origin=="Mozambique"

* MYANMAR
replace NAME_1="Bago" if NAME_1=="Bago (Division)" & origin=="Myanmar"
replace NAME_1="Bago" if NAME_1=="Bago (Pegu)" & origin=="Myanmar"
replace NAME_1="Chin" if NAME_1=="Chin (State)" & origin=="Myanmar"
replace NAME_1="Ayeyarwady" if NAME_1=="Irrawaddy Region" & origin=="Myanmar"
replace NAME_1="Kachin" if NAME_1=="Kachin (State)" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Karen" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Karen (State)" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Karen State" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Kawthulei (Karen/Kayin)" & origin=="Myanmar"
replace NAME_1="Kayah" if NAME_1=="Kayah (State)" & origin=="Myanmar"
replace NAME_1="Kayah" if NAME_1=="Kayar" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Kayin (State)" & origin=="Myanmar"
replace NAME_1="Kayin" if NAME_1=="Kayin State" & origin=="Myanmar"
replace NAME_1="Mandalay" if NAME_1=="Mandalay (Division)" & origin=="Myanmar"
replace NAME_1="Mon" if NAME_1=="Mon (State)" & origin=="Myanmar"
replace NAME_1="Bago" if NAME_1=="Pegu" & origin=="Myanmar"
replace NAME_1="Shan" if NAME_1=="Shan (State)" & origin=="Myanmar"
replace NAME_1="Shan" if NAME_1=="Shan State" & origin=="Myanmar"
replace NAME_1="Yangon" if NAME_1=="Yangon (Division)" & origin=="Myanmar"
replace NAME_1="Yangon" if NAME_1=="Yangon (Rangoon)" & origin=="Myanmar"
replace NAME_1="Yangon" if NAME_1=="Yangon (State)" & origin=="Myanmar"
replace NAME_1="Yangon" if NAME_1=="Yangon Division" & origin=="Myanmar"
replace ID_GADM_fine="MMR1" if NAME_1=="Ayeyarwady" & origin=="Myanmar"
replace ID_GADM_fine="MMR2" if NAME_1=="Bago" & origin=="Myanmar"
replace ID_GADM_fine="MMR3" if NAME_1=="Chin" & origin=="Myanmar"
replace ID_GADM_fine="MMR4" if NAME_1=="Kachin" & origin=="Myanmar"
replace ID_GADM_fine="MMR5" if NAME_1=="Kayah" & origin=="Myanmar"
replace ID_GADM_fine="MMR6" if NAME_1=="Kayin" & origin=="Myanmar"
replace ID_GADM_fine="MMR7" if NAME_1=="Magway" & origin=="Myanmar"
replace ID_GADM_fine="MMR8" if NAME_1=="Mandalay" & origin=="Myanmar"
replace ID_GADM_fine="MMR9" if NAME_1=="Mon" & origin=="Myanmar"
replace ID_GADM_fine="MMR10" if NAME_1=="Naypyitaw" & origin=="Myanmar"
replace ID_GADM_fine="MMR11" if NAME_1=="Rakhine" & origin=="Myanmar"
replace ID_GADM_fine="MMR12" if NAME_1=="Sagaing" & origin=="Myanmar"
replace ID_GADM_fine="MMR13" if NAME_1=="Shan" & origin=="Myanmar"
replace ID_GADM_fine="MMR14" if NAME_1=="Tanintharyi" & origin=="Myanmar"
replace ID_GADM_fine="MMR15" if NAME_1=="Yangon" & origin=="Myanmar"

* NAMIBIA
replace NAME_1="Zambezi" if NAME_1=="Caprivi" & origin=="Namibia"
replace ID_GADM_fine="NAM1" if NAME_1=="!Karas" & origin=="Namibia"
replace ID_GADM_fine="NAM2" if NAME_1=="Erongo" & origin=="Namibia"
replace ID_GADM_fine="NAM3" if NAME_1=="Hardap" & origin=="Namibia"
replace ID_GADM_fine="NAM4" if NAME_1=="Kavango" & origin=="Namibia"
replace ID_GADM_fine="NAM5" if NAME_1=="Khomas" & origin=="Namibia"
replace ID_GADM_fine="NAM6" if NAME_1=="Kunene" & origin=="Namibia"
replace ID_GADM_fine="NAM7" if NAME_1=="Ohangwena" & origin=="Namibia"
replace ID_GADM_fine="NAM8" if NAME_1=="Omaheke" & origin=="Namibia"
replace ID_GADM_fine="NAM9" if NAME_1=="Omusati" & origin=="Namibia"
replace ID_GADM_fine="NAM10" if NAME_1=="Oshana" & origin=="Namibia"
replace ID_GADM_fine="NAM11" if NAME_1=="Oshikoto" & origin=="Namibia"
replace ID_GADM_fine="NAM12" if NAME_1=="Otjozondjupa" & origin=="Namibia"
replace ID_GADM_fine="NAM13" if NAME_1=="Zambezi" & origin=="Namibia"

* NEPAL
replace NAME_1="East" if NAME_1=="Eastern" & origin=="Nepal"
replace NAME_1="West" if NAME_1=="Western" & origin=="Nepal"
replace ID_GADM_fine="NPL1" if NAME_1=="Central" & origin=="Nepal"
replace ID_GADM_fine="NPL2" if NAME_1=="East" & origin=="Nepal"
replace ID_GADM_fine="NPL3" if NAME_1=="Far-Western" & origin=="Nepal"
replace ID_GADM_fine="NPL4" if NAME_1=="Mid-Western" & origin=="Nepal"
replace ID_GADM_fine="NPL5" if NAME_1=="West" & origin=="Nepal"

* NETHERLANDS
replace NAME_1="Noord-Brabant" if NAME_1=="North Brabant" & origin=="Netherlands"
replace NAME_1="Noord-Holland" if NAME_1=="North Holland" & origin=="Netherlands"
replace NAME_1="Overijssel" if NAME_1=="Overijssel" & origin=="Netherlands"
replace NAME_1="Zuid-Holland" if NAME_1=="South Holland" & origin=="Netherlands"
replace ID_GADM_fine="NLD1" if NAME_1=="Drenthe" & origin=="Netherlands"
replace ID_GADM_fine="NLD2" if NAME_1=="Flevoland" & origin=="Netherlands"
replace ID_GADM_fine="NLD3" if NAME_1=="Friesland" & origin=="Netherlands"
replace ID_GADM_fine="NLD4" if NAME_1=="Gelderland" & origin=="Netherlands"
replace ID_GADM_fine="NLD5" if NAME_1=="Groningen" & origin=="Netherlands"
replace ID_GADM_fine="NLD6" if NAME_1=="IJsselmeer" & origin=="Netherlands"
replace ID_GADM_fine="NLD7" if NAME_1=="Limburg" & origin=="Netherlands"
replace ID_GADM_fine="NLD8" if NAME_1=="Noord-Brabant" & origin=="Netherlands"
replace ID_GADM_fine="NLD9" if NAME_1=="Noord-Holland" & origin=="Netherlands"
replace ID_GADM_fine="NLD10" if NAME_1=="Overijssel" & origin=="Netherlands"
replace ID_GADM_fine="NLD11" if NAME_1=="Utrecht" & origin=="Netherlands"
replace ID_GADM_fine="NLD12" if NAME_1=="Zeeland" & origin=="Netherlands"
replace ID_GADM_fine="NLD13" if NAME_1=="Zeeuwse meren" & origin=="Netherlands"
replace ID_GADM_fine="NLD14" if NAME_1=="Zuid-Holland" & origin=="Netherlands"

* NEW ZEALAND
replace NAME_1="Auckland" if NAME_1=="Auckland (Territory)" & origin=="New Zealand"
replace NAME_1="Bay of Plenty" if NAME_1=="Bay of Plenty" & origin=="New Zealand"
replace NAME_1="Wellington" if NAME_1=="Greater Wellington (Region)" & origin=="New Zealand"
replace NAME_1="Wellington" if NAME_1=="Wellington (Region)" & origin=="New Zealand"
replace ID_GADM_fine="NZL1" if NAME_1=="Auckland" & origin=="New Zealand"
replace ID_GADM_fine="NZL2" if NAME_1=="Bay of Plenty" & origin=="New Zealand"
replace ID_GADM_fine="NZL3" if NAME_1=="Canterbury" & origin=="New Zealand"
replace ID_GADM_fine="NZL4" if NAME_1=="Chatham Islands" & origin=="New Zealand"
replace ID_GADM_fine="NZL5" if NAME_1=="Gisborne" & origin=="New Zealand"
replace ID_GADM_fine="NZL6" if NAME_1=="Hawke's Bay" & origin=="New Zealand"
replace ID_GADM_fine="NZL7" if NAME_1=="Manawatu-Wanganui" & origin=="New Zealand"
replace ID_GADM_fine="NZL8" if NAME_1=="Marlborough" & origin=="New Zealand"
replace ID_GADM_fine="NZL9" if NAME_1=="Nelson" & origin=="New Zealand"
replace ID_GADM_fine="NZL10" if NAME_1=="Northern Islands" & origin=="New Zealand"
replace ID_GADM_fine="NZL11" if NAME_1=="Northland" & origin=="New Zealand"
replace ID_GADM_fine="NZL12" if NAME_1=="Otago" & origin=="New Zealand"
replace ID_GADM_fine="NZL13" if NAME_1=="Southern Islands" & origin=="New Zealand"
replace ID_GADM_fine="NZL14" if NAME_1=="Southland" & origin=="New Zealand"
replace ID_GADM_fine="NZL15" if NAME_1=="Taranaki" & origin=="New Zealand"
replace ID_GADM_fine="NZL16" if NAME_1=="Tasman" & origin=="New Zealand"
replace ID_GADM_fine="NZL17" if NAME_1=="Waikato" & origin=="New Zealand"
replace ID_GADM_fine="NZL18" if NAME_1=="Wellington" & origin=="New Zealand"
replace ID_GADM_fine="NZL19" if NAME_1=="West Coast" & origin=="New Zealand"

* NICARAGUA
replace ID_GADM_fine="NIC1" if NAME_1=="Atlántico Norte" & origin=="Nicaragua"
replace ID_GADM_fine="NIC2" if NAME_1=="Atlántico Sur" & origin=="Nicaragua"
replace ID_GADM_fine="NIC3" if NAME_1=="Boaco" & origin=="Nicaragua"
replace ID_GADM_fine="NIC4" if NAME_1=="Carazo" & origin=="Nicaragua"
replace ID_GADM_fine="NIC5" if NAME_1=="Chinandega" & origin=="Nicaragua"
replace ID_GADM_fine="NIC6" if NAME_1=="Chontales" & origin=="Nicaragua"
replace ID_GADM_fine="NIC7" if NAME_1=="Estelí" & origin=="Nicaragua"
replace ID_GADM_fine="NIC8" if NAME_1=="Granada" & origin=="Nicaragua"
replace ID_GADM_fine="NIC9" if NAME_1=="Jinotega" & origin=="Nicaragua"
replace ID_GADM_fine="NIC10" if NAME_1=="Lago Nicaragua" & origin=="Nicaragua"
replace ID_GADM_fine="NIC11" if NAME_1=="León" & origin=="Nicaragua"
replace ID_GADM_fine="NIC12" if NAME_1=="Madriz" & origin=="Nicaragua"
replace ID_GADM_fine="NIC13" if NAME_1=="Managua" & origin=="Nicaragua"
replace ID_GADM_fine="NIC14" if NAME_1=="Masaya" & origin=="Nicaragua"
replace ID_GADM_fine="NIC15" if NAME_1=="Matagalpa" & origin=="Nicaragua"
replace ID_GADM_fine="NIC16" if NAME_1=="Nueva Segovia" & origin=="Nicaragua"
replace ID_GADM_fine="NIC17" if NAME_1=="Río San Juan" & origin=="Nicaragua"
replace ID_GADM_fine="NIC18" if NAME_1=="Rivas" & origin=="Nicaragua"

* NIGER
replace NAME_1="Agadez" if NAME_1=="Agadez (Department)" & origin=="Niger"
replace NAME_1="Agadez" if NAME_1=="Agadez (Region)" & origin=="Niger"
replace NAME_1="Agadez" if NAME_1=="Agadez Department" & origin=="Niger"
replace NAME_1="Niamey" if NAME_1=="Niamey (Administrative Region)" & origin=="Niger"
replace NAME_1="Niamey" if NAME_1=="Niamey Capital District" & origin=="Niger"
replace NAME_1="Zinder" if NAME_1=="Tanout Department" & origin=="Niger"
replace NAME_1="Tillabéry" if NAME_1=="Tillaberi" & origin=="Niger"
replace NAME_1="Tillabéry" if NAME_1=="Tillabéri" & origin=="Niger"
replace NAME_1="Zinder" if NAME_1=="Zinder" & origin=="Niger"
replace ID_GADM_fine="NER1" if NAME_1=="Agadez" & origin=="Niger"
replace ID_GADM_fine="NER2" if NAME_1=="Diffa" & origin=="Niger"
replace ID_GADM_fine="NER3" if NAME_1=="Dosso" & origin=="Niger"
replace ID_GADM_fine="NER4" if NAME_1=="Maradi" & origin=="Niger"
replace ID_GADM_fine="NER5" if NAME_1=="Niamey" & origin=="Niger"
replace ID_GADM_fine="NER6" if NAME_1=="Tahoua" & origin=="Niger"
replace ID_GADM_fine="NER7" if NAME_1=="Tillabéry" & origin=="Niger"
replace ID_GADM_fine="NER8" if NAME_1=="Zinder" & origin=="Niger"

* NIGERIA
replace NAME_1="Federal Capital Territory" if NAME_1=="Abuja" & origin=="Nigeria"
replace NAME_1="Nassarawa" if NAME_1=="Nasarawa" & origin=="Nigeria"
replace ID_GADM_fine="NGA1" if NAME_1=="Abia" & origin=="Nigeria"
replace ID_GADM_fine="NGA2" if NAME_1=="Adamawa" & origin=="Nigeria"
replace ID_GADM_fine="NGA3" if NAME_1=="Akwa Ibom" & origin=="Nigeria"
replace ID_GADM_fine="NGA4" if NAME_1=="Anambra" & origin=="Nigeria"
replace ID_GADM_fine="NGA5" if NAME_1=="Bauchi" & origin=="Nigeria"
replace ID_GADM_fine="NGA6" if NAME_1=="Bayelsa" & origin=="Nigeria"
replace ID_GADM_fine="NGA7" if NAME_1=="Benue" & origin=="Nigeria"
replace ID_GADM_fine="NGA8" if NAME_1=="Borno" & origin=="Nigeria"
replace ID_GADM_fine="NGA9" if NAME_1=="Cross River" & origin=="Nigeria"
replace ID_GADM_fine="NGA10" if NAME_1=="Delta" & origin=="Nigeria"
replace ID_GADM_fine="NGA11" if NAME_1=="Ebonyi" & origin=="Nigeria"
replace ID_GADM_fine="NGA12" if NAME_1=="Edo" & origin=="Nigeria"
replace ID_GADM_fine="NGA13" if NAME_1=="Ekiti" & origin=="Nigeria"
replace ID_GADM_fine="NGA14" if NAME_1=="Enugu" & origin=="Nigeria"
replace ID_GADM_fine="NGA15" if NAME_1=="Federal Capital Territory" & origin=="Nigeria"
replace ID_GADM_fine="NGA16" if NAME_1=="Gombe" & origin=="Nigeria"
replace ID_GADM_fine="NGA17" if NAME_1=="Imo" & origin=="Nigeria"
replace ID_GADM_fine="NGA18" if NAME_1=="Jigawa" & origin=="Nigeria"
replace ID_GADM_fine="NGA19" if NAME_1=="Kaduna" & origin=="Nigeria"
replace ID_GADM_fine="NGA20" if NAME_1=="Kano" & origin=="Nigeria"
replace ID_GADM_fine="NGA21" if NAME_1=="Katsina" & origin=="Nigeria"
replace ID_GADM_fine="NGA22" if NAME_1=="Kebbi" & origin=="Nigeria"
replace ID_GADM_fine="NGA23" if NAME_1=="Kogi" & origin=="Nigeria"
replace ID_GADM_fine="NGA24" if NAME_1=="Kwara" & origin=="Nigeria"
replace ID_GADM_fine="NGA25" if NAME_1=="Lagos" & origin=="Nigeria"
replace ID_GADM_fine="NGA26" if NAME_1=="Nassarawa" & origin=="Nigeria"
replace ID_GADM_fine="NGA27" if NAME_1=="Niger" & origin=="Nigeria"
replace ID_GADM_fine="NGA28" if NAME_1=="Ogun" & origin=="Nigeria"
replace ID_GADM_fine="NGA29" if NAME_1=="Ondo" & origin=="Nigeria"
replace ID_GADM_fine="NGA30" if NAME_1=="Osun" & origin=="Nigeria"
replace ID_GADM_fine="NGA31" if NAME_1=="Oyo" & origin=="Nigeria"
replace ID_GADM_fine="NGA32" if NAME_1=="Plateau" & origin=="Nigeria"
replace ID_GADM_fine="NGA33" if NAME_1=="Rivers" & origin=="Nigeria"
replace ID_GADM_fine="NGA34" if NAME_1=="Sokoto" & origin=="Nigeria"
replace ID_GADM_fine="NGA35" if NAME_1=="Taraba" & origin=="Nigeria"
replace ID_GADM_fine="NGA36" if NAME_1=="Yobe" & origin=="Nigeria"
replace ID_GADM_fine="NGA37" if NAME_1=="Zamfara" & origin=="Nigeria"

* NORWAY
replace ID_GADM_fine="NOR1" if NAME_1=="Akershus" & origin=="Norway"
replace ID_GADM_fine="NOR2" if NAME_1=="Ãstfold" & origin=="Norway"
replace ID_GADM_fine="NOR3" if NAME_1=="Aust-Agder" & origin=="Norway"
replace ID_GADM_fine="NOR4" if NAME_1=="Buskerud" & origin=="Norway"
replace ID_GADM_fine="NOR5" if NAME_1=="Finnmark" & origin=="Norway"
replace ID_GADM_fine="NOR6" if NAME_1=="Hedmark" & origin=="Norway"
replace ID_GADM_fine="NOR7" if NAME_1=="Hordaland" & origin=="Norway"
replace ID_GADM_fine="NOR8" if NAME_1=="Møre og Romsdal" & origin=="Norway"
replace ID_GADM_fine="NOR9" if NAME_1=="Nord-Trøndelag" & origin=="Norway"
replace ID_GADM_fine="NOR10" if NAME_1=="Nordland" & origin=="Norway"
replace ID_GADM_fine="NOR11" if NAME_1=="Oppland" & origin=="Norway"
replace ID_GADM_fine="NOR12" if NAME_1=="Oslo" & origin=="Norway"
replace ID_GADM_fine="NOR13" if NAME_1=="Rogaland" & origin=="Norway"
replace ID_GADM_fine="NOR14" if NAME_1=="Sogn og Fjordane" & origin=="Norway"
replace ID_GADM_fine="NOR15" if NAME_1=="Sør-Trøndelag" & origin=="Norway"
replace ID_GADM_fine="NOR16" if NAME_1=="Telemark" & origin=="Norway"
replace ID_GADM_fine="NOR17" if NAME_1=="Troms" & origin=="Norway"
replace ID_GADM_fine="NOR18" if NAME_1=="Vest-Agder" & origin=="Norway"
replace ID_GADM_fine="NOR19" if NAME_1=="Vestfold" & origin=="Norway"

* PAKISTAN
replace NAME_1="Baluchistan" if NAME_1=="Balochistan" & origin=="Pakistan"
replace NAME_1="F.A.T.A." if NAME_1=="Federally Administered Tribal Areas" & origin=="Pakistan"
replace NAME_1="Northern Areas" if NAME_1=="Gilgit-Baltistan" & origin=="Pakistan"
replace NAME_1="F.C.T." if NAME_1=="Islamabad Capital Territory" & origin=="Pakistan"
replace NAME_1="N.W.F.P." if NAME_1=="Khyber Pakhtunkhwa" & origin=="Pakistan"
replace NAME_1="N.W.F.P." if NAME_1=="North-West Frontier Province" & origin=="Pakistan"
replace NAME_1="Punjab" if NAME_1=="Punjab" & origin=="Pakistan"
replace NAME_1="Sind" if NAME_1=="SIndh" & origin=="Pakistan"
replace NAME_1="Sind" if NAME_1=="Sindh" & origin=="Pakistan"
replace ID_GADM_fine="PAK1" if NAME_1=="Azad Kashmir" & origin=="Pakistan"
replace ID_GADM_fine="PAK2" if NAME_1=="Baluchistan" & origin=="Pakistan"
replace ID_GADM_fine="PAK3" if NAME_1=="F.A.T.A." & origin=="Pakistan"
replace ID_GADM_fine="PAK4" if NAME_1=="F.C.T." & origin=="Pakistan"
replace ID_GADM_fine="PAK5" if NAME_1=="N.W.F.P." & origin=="Pakistan"
replace ID_GADM_fine="PAK6" if NAME_1=="Northern Areas" & origin=="Pakistan"
replace ID_GADM_fine="PAK7" if NAME_1=="Punjab" & origin=="Pakistan"
replace ID_GADM_fine="PAK8" if NAME_1=="Sind" & origin=="Pakistan"

* PANAMA
replace NAME_1="Darién" if NAME_1=="Darien" & origin=="Panama"
replace NAME_1="Panamá" if NAME_1=="Panama" & origin=="Panama"
replace ID_GADM_fine="PAN1" if NAME_1=="Bocas del Toro" & origin=="Panama"
replace ID_GADM_fine="PAN2" if NAME_1=="Chiriquí" & origin=="Panama"
replace ID_GADM_fine="PAN3" if NAME_1=="Coclé" & origin=="Panama"
replace ID_GADM_fine="PAN4" if NAME_1=="Colón" & origin=="Panama"
replace ID_GADM_fine="PAN5" if NAME_1=="Darién" & origin=="Panama"
replace ID_GADM_fine="PAN6" if NAME_1=="Emberá" & origin=="Panama"
replace ID_GADM_fine="PAN7" if NAME_1=="Herrera" & origin=="Panama"
replace ID_GADM_fine="PAN8" if NAME_1=="Kuna Yala" & origin=="Panama"
replace ID_GADM_fine="PAN9" if NAME_1=="Los Santos" & origin=="Panama"
replace ID_GADM_fine="PAN10" if NAME_1=="Ngöbe Buglé" & origin=="Panama"
replace ID_GADM_fine="PAN11" if NAME_1=="Panamá Oeste" & origin=="Panama"
replace ID_GADM_fine="PAN12" if NAME_1=="Panamá" & origin=="Panama"
replace ID_GADM_fine="PAN13" if NAME_1=="Veraguas" & origin=="Panama"

* PAPUA NEW GUINEA // Not in GWP --> drop
drop if origin=="Papua New Guinea" 

* PARAGUAY
replace NAME_1="Alto Paraná" if NAME_1=="Alto Parana" & origin=="Paraguay"
replace NAME_1="Asunción" if NAME_1=="Asuncion" & origin=="Paraguay"
replace NAME_1="Caazapá" if NAME_1=="Caazapa" & origin=="Paraguay"
replace NAME_1="Canindeyú" if NAME_1=="Canindeyu" & origin=="Paraguay"
replace NAME_1="Concepción" if NAME_1=="Concepcion" & origin=="Paraguay"
replace ID_GADM_fine="PRY1" if NAME_1=="Alto Paraguay" & origin=="Paraguay"
replace ID_GADM_fine="PRY2" if NAME_1=="Alto Paraná" & origin=="Paraguay"
replace ID_GADM_fine="PRY3" if NAME_1=="Amambay" & origin=="Paraguay"
replace ID_GADM_fine="PRY4" if NAME_1=="Asunción" & origin=="Paraguay"
replace ID_GADM_fine="PRY5" if NAME_1=="Boquerón" & origin=="Paraguay"
replace ID_GADM_fine="PRY6" if NAME_1=="Caaguazú" & origin=="Paraguay"
replace ID_GADM_fine="PRY7" if NAME_1=="Caazapá" & origin=="Paraguay"
replace ID_GADM_fine="PRY8" if NAME_1=="Canindeyú" & origin=="Paraguay"
replace ID_GADM_fine="PRY9" if NAME_1=="Central" & origin=="Paraguay"
replace ID_GADM_fine="PRY10" if NAME_1=="Concepción" & origin=="Paraguay"
replace ID_GADM_fine="PRY11" if NAME_1=="Cordillera" & origin=="Paraguay"
replace ID_GADM_fine="PRY12" if NAME_1=="Guairá" & origin=="Paraguay"
replace ID_GADM_fine="PRY13" if NAME_1=="Itapúa" & origin=="Paraguay"
replace ID_GADM_fine="PRY14" if NAME_1=="Misiones" & origin=="Paraguay"
replace ID_GADM_fine="PRY15" if NAME_1=="Ñeembucú" & origin=="Paraguay"
replace ID_GADM_fine="PRY16" if NAME_1=="Paraguarí" & origin=="Paraguay"
replace ID_GADM_fine="PRY17" if NAME_1=="Presidente Hayes" & origin=="Paraguay"
replace ID_GADM_fine="PRY18" if NAME_1=="San Pedro" & origin=="Paraguay"

* PERU
replace NAME_1="Apurímac" if NAME_1=="Apurimac" & origin=="Peru"
replace NAME_1="Huánuco" if NAME_1=="Huanuco" & origin=="Peru"
replace NAME_1="Junín" if NAME_1=="Junin" & origin=="Peru"
replace NAME_1="San Martín" if NAME_1=="San Martin" & origin=="Peru"
replace ID_GADM_fine="PER1" if NAME_1=="Amazonas" & origin=="Peru"
replace ID_GADM_fine="PER2" if NAME_1=="Ancash" & origin=="Peru"
replace ID_GADM_fine="PER3" if NAME_1=="Apurímac" & origin=="Peru"
replace ID_GADM_fine="PER4" if NAME_1=="Arequipa" & origin=="Peru"
replace ID_GADM_fine="PER5" if NAME_1=="Ayacucho" & origin=="Peru"
replace ID_GADM_fine="PER6" if NAME_1=="Cajamarca" & origin=="Peru"
replace ID_GADM_fine="PER7" if NAME_1=="Callao" & origin=="Peru"
replace ID_GADM_fine="PER8" if NAME_1=="Cusco" & origin=="Peru"
replace ID_GADM_fine="PER9" if NAME_1=="Huancavelica" & origin=="Peru"
replace ID_GADM_fine="PER10" if NAME_1=="Huánuco" & origin=="Peru"
replace ID_GADM_fine="PER11" if NAME_1=="Ica" & origin=="Peru"
replace ID_GADM_fine="PER12" if NAME_1=="Junín" & origin=="Peru"
replace ID_GADM_fine="PER13" if NAME_1=="La Libertad" & origin=="Peru"
replace ID_GADM_fine="PER14" if NAME_1=="Lambayeque" & origin=="Peru"
replace ID_GADM_fine="PER15" if NAME_1=="Lima Province" & origin=="Peru"
replace ID_GADM_fine="PER16" if NAME_1=="Lima" & origin=="Peru"
replace ID_GADM_fine="PER17" if NAME_1=="Loreto" & origin=="Peru"
replace ID_GADM_fine="PER18" if NAME_1=="Madre de Dios" & origin=="Peru"
replace ID_GADM_fine="PER19" if NAME_1=="Moquegua" & origin=="Peru"
replace ID_GADM_fine="PER20" if NAME_1=="Pasco" & origin=="Peru"
replace ID_GADM_fine="PER21" if NAME_1=="Piura" & origin=="Peru"
replace ID_GADM_fine="PER22" if NAME_1=="Puno" & origin=="Peru"
replace ID_GADM_fine="PER23" if NAME_1=="San Martín" & origin=="Peru"
replace ID_GADM_fine="PER24" if NAME_1=="Tacna" & origin=="Peru"
replace ID_GADM_fine="PER25" if NAME_1=="Tumbes" & origin=="Peru"
replace ID_GADM_fine="PER26" if NAME_1=="Ucayali" & origin=="Peru"

* PHILIPPINES // Not in GWP
drop if origin=="Philippines"
drop if NAME_1=="Bicol" & origin=="Philippines" // Too large
drop if NAME_1=="Davao Region" & origin=="Philippines" // Too large
replace NAME_1="Lanao del Norte" if NAME_1=="Iligan" & origin=="Philippines"
replace NAME_1="Kalinga" if NAME_1=="Kalinga-Apayao" & origin=="Philippines"
replace NAME_1="Davao Oriental" if NAME_1=="Lupon" & origin=="Philippines"
replace NAME_1="Metropolitan Manila" if NAME_1=="Metropolitian Manila" & origin=="Philippines"
drop if NAME_1=="Mindanao Island" & origin=="Philippines" // Too large
replace NAME_1="Mountain Province" if NAME_1=="Mountain" & origin=="Philippines"
replace NAME_1="North Cotabato" if NAME_1=="North Catobato" & origin=="Philippines"
replace NAME_1="North Cotabato" if NAME_1=="North Cotabato" & origin=="Philippines"
replace NAME_1="Quezon" if NAME_1=="Quezon Province" & origin=="Philippines"
replace NAME_1="Sultan Kudarat" if NAME_1=="Sultan Kudurat" & origin=="Philippines"
replace NAME_1="Tawi-Tawi" if NAME_1=="Tawi Tawi" & origin=="Philippines"

* POLAND
replace NAME_1="Dolnośląskie" if NAME_1=="Lower Silesia" & origin=="Poland"
replace NAME_1="Mazowieckie" if NAME_1=="Masovia" & origin=="Poland"
replace NAME_1="Mazowieckie" if NAME_1=="Masovian (Province)" & origin=="Poland"
replace ID_GADM_fine="POL1" if NAME_1=="Dolnośląskie" & origin=="Poland"
replace ID_GADM_fine="POL7" if NAME_1=="Mazowieckie" & origin=="Poland"
replace ID_GADM_fine="POL1" if NAME_1=="Dolnośląskie" & origin=="Poland"
replace ID_GADM_fine="POL2" if NAME_1=="Kujawsko-Pomorskie" & origin=="Poland"
replace ID_GADM_fine="POL3" if NAME_1=="Łódzkie" & origin=="Poland"
replace ID_GADM_fine="POL4" if NAME_1=="Lubelskie" & origin=="Poland"
replace ID_GADM_fine="POL5" if NAME_1=="Lubuskie" & origin=="Poland"
replace ID_GADM_fine="POL6" if NAME_1=="Małopolskie" & origin=="Poland"
replace ID_GADM_fine="POL7" if NAME_1=="Mazowieckie" & origin=="Poland"
replace ID_GADM_fine="POL8" if NAME_1=="Opolskie" & origin=="Poland"
replace ID_GADM_fine="POL9" if NAME_1=="Podkarpackie" & origin=="Poland"
replace ID_GADM_fine="POL10" if NAME_1=="Podlaskie" & origin=="Poland"
replace ID_GADM_fine="POL11" if NAME_1=="Pomorskie" & origin=="Poland"
replace ID_GADM_fine="POL12" if NAME_1=="Śląskie" & origin=="Poland"
replace ID_GADM_fine="POL13" if NAME_1=="Świętokrzyskie" & origin=="Poland"
replace ID_GADM_fine="POL14" if NAME_1=="Warmińsko-Mazurskie" & origin=="Poland"
replace ID_GADM_fine="POL15" if NAME_1=="Wielkopolskie" & origin=="Poland"
replace ID_GADM_fine="POL16" if NAME_1=="Zachodniopomorskie" & origin=="Poland"

* PORTUGAL
replace NAME_1="Lisboa" if NAME_1=="Lisbon" & origin=="Portugal"
replace ID_GADM_fine="PRT12" if NAME_1=="Lisboa" & origin=="Portugal"
replace ID_GADM_fine="PRT1" if NAME_1=="Aveiro" & origin=="Portugal"
replace ID_GADM_fine="PRT2" if NAME_1=="Azores" & origin=="Portugal"
replace ID_GADM_fine="PRT3" if NAME_1=="Beja" & origin=="Portugal"
replace ID_GADM_fine="PRT4" if NAME_1=="Braga" & origin=="Portugal"
replace ID_GADM_fine="PRT5" if NAME_1=="Bragança" & origin=="Portugal"
replace ID_GADM_fine="PRT6" if NAME_1=="Castelo Branco" & origin=="Portugal"
replace ID_GADM_fine="PRT7" if NAME_1=="Coimbra" & origin=="Portugal"
replace ID_GADM_fine="PRT8" if NAME_1=="Évora" & origin=="Portugal"
replace ID_GADM_fine="PRT9" if NAME_1=="Faro" & origin=="Portugal"
replace ID_GADM_fine="PRT10" if NAME_1=="Guarda" & origin=="Portugal"
replace ID_GADM_fine="PRT11" if NAME_1=="Leiria" & origin=="Portugal"
replace ID_GADM_fine="PRT12" if NAME_1=="Lisboa" & origin=="Portugal"
replace ID_GADM_fine="PRT13" if NAME_1=="Madeira" & origin=="Portugal"
replace ID_GADM_fine="PRT14" if NAME_1=="Portalegre" & origin=="Portugal"
replace ID_GADM_fine="PRT15" if NAME_1=="Porto" & origin=="Portugal"
replace ID_GADM_fine="PRT16" if NAME_1=="Santarém" & origin=="Portugal"
replace ID_GADM_fine="PRT17" if NAME_1=="Setúbal" & origin=="Portugal"
replace ID_GADM_fine="PRT18" if NAME_1=="Viana do Castelo" & origin=="Portugal"
replace ID_GADM_fine="PRT19" if NAME_1=="Vila Real" & origin=="Portugal"
replace ID_GADM_fine="PRT20" if NAME_1=="Viseu" & origin=="Portugal"

* QATAR // Based on GWP
replace NAME_1="Rayyan" if NAME_1=="Ar Rayyan" & origin=="Qatar"
replace ID_GADM_fine="QAT1" if NAME_1=="Doha" & origin=="Qatar"
replace ID_GADM_fine="QAT2" if NAME_1=="Rayyan" & origin=="Qatar"

* REPUBLIC OF THE CONGO
replace origin="Republic of Congo" if origin=="Republic of the Congo"
replace NAME_1="Lékoumou" if NAME_1=="Lekoumou" & origin=="Republic of Congo"
replace NAME_1="Nord-Kivu" if NAME_1=="North-Kivu" & origin=="Republic of Congo"
replace origin="Democratic Republic of the Congo" if NAME_1=="Nord-Kivu" & origin=="Republic of Congo"
replace ID_GADM_fine="COD19" if NAME_1=="Nord-Kivu" & origin=="Democratic Republic of the Congo"
replace ID_GADM_fine="COG1" if NAME_1=="Bouenza" & origin=="Republic of Congo"
replace ID_GADM_fine="COG2" if NAME_1=="Brazzaville" & origin=="Republic of Congo"
replace ID_GADM_fine="COG3" if NAME_1=="Cuvette-Ouest" & origin=="Republic of Congo"
replace ID_GADM_fine="COG4" if NAME_1=="Cuvette" & origin=="Republic of Congo"
replace ID_GADM_fine="COG5" if NAME_1=="Kouilou" & origin=="Republic of Congo"
replace ID_GADM_fine="COG6" if NAME_1=="Lékoumou" & origin=="Republic of Congo"
replace ID_GADM_fine="COG7" if NAME_1=="Likouala" & origin=="Republic of Congo"
replace ID_GADM_fine="COG8" if NAME_1=="Niari" & origin=="Republic of Congo"
replace ID_GADM_fine="COG9" if NAME_1=="Plateaux" & origin=="Republic of Congo"
replace ID_GADM_fine="COG10" if NAME_1=="Pointe Noire" & origin=="Republic of Congo"
replace ID_GADM_fine="COG11" if NAME_1=="Pool" & origin=="Republic of Congo"
replace ID_GADM_fine="COG12" if NAME_1=="Sangha" & origin=="Republic of Congo"

* ROMANIA
replace ID_GADM_fine="ROU1" if NAME_1=="Alba" & origin=="Romania"
replace ID_GADM_fine="ROU2" if NAME_1=="Arad" & origin=="Romania"
replace ID_GADM_fine="ROU3" if NAME_1=="Argeș" & origin=="Romania"
replace ID_GADM_fine="ROU4" if NAME_1=="Bacău" & origin=="Romania"
replace ID_GADM_fine="ROU5" if NAME_1=="Bihor" & origin=="Romania"
replace ID_GADM_fine="ROU6" if NAME_1=="Bistrița-Năsăud" & origin=="Romania"
replace ID_GADM_fine="ROU7" if NAME_1=="Botoșani" & origin=="Romania"
replace ID_GADM_fine="ROU8" if NAME_1=="Brașov" & origin=="Romania"
replace ID_GADM_fine="ROU9" if NAME_1=="Brăila" & origin=="Romania"
replace ID_GADM_fine="ROU10" if NAME_1=="Bucharest" & origin=="Romania"
replace ID_GADM_fine="ROU11" if NAME_1=="Buzău" & origin=="Romania"
replace ID_GADM_fine="ROU12" if NAME_1=="Călărași" & origin=="Romania"
replace ID_GADM_fine="ROU13" if NAME_1=="Caraș-Severin" & origin=="Romania"
replace ID_GADM_fine="ROU14" if NAME_1=="Cluj" & origin=="Romania"
replace ID_GADM_fine="ROU15" if NAME_1=="Constanța" & origin=="Romania"
replace ID_GADM_fine="ROU16" if NAME_1=="Covasna" & origin=="Romania"
replace ID_GADM_fine="ROU17" if NAME_1=="Dâmbovița" & origin=="Romania"
replace ID_GADM_fine="ROU18" if NAME_1=="Dolj" & origin=="Romania"
replace ID_GADM_fine="ROU19" if NAME_1=="Galați" & origin=="Romania"
replace ID_GADM_fine="ROU20" if NAME_1=="Giurgiu" & origin=="Romania"
replace ID_GADM_fine="ROU21" if NAME_1=="Gorj" & origin=="Romania"
replace ID_GADM_fine="ROU22" if NAME_1=="Harghita" & origin=="Romania"
replace ID_GADM_fine="ROU23" if NAME_1=="Hunedoara" & origin=="Romania"
replace ID_GADM_fine="ROU24" if NAME_1=="Iași" & origin=="Romania"
replace ID_GADM_fine="ROU25" if NAME_1=="Ialomița" & origin=="Romania"
replace ID_GADM_fine="ROU26" if NAME_1=="Ilfov" & origin=="Romania"
replace ID_GADM_fine="ROU27" if NAME_1=="Maramureș" & origin=="Romania"
replace ID_GADM_fine="ROU28" if NAME_1=="Mehedinți" & origin=="Romania"
replace ID_GADM_fine="ROU29" if NAME_1=="Mureș" & origin=="Romania"
replace ID_GADM_fine="ROU30" if NAME_1=="Neamț" & origin=="Romania"
replace ID_GADM_fine="ROU31" if NAME_1=="Olt" & origin=="Romania"
replace ID_GADM_fine="ROU32" if NAME_1=="Prahova" & origin=="Romania"
replace ID_GADM_fine="ROU33" if NAME_1=="Sălaj" & origin=="Romania"
replace ID_GADM_fine="ROU34" if NAME_1=="Satu Mare" & origin=="Romania"
replace ID_GADM_fine="ROU35" if NAME_1=="Sibiu" & origin=="Romania"
replace ID_GADM_fine="ROU36" if NAME_1=="Suceava" & origin=="Romania"
replace ID_GADM_fine="ROU37" if NAME_1=="Teleorman" & origin=="Romania"
replace ID_GADM_fine="ROU38" if NAME_1=="Timiș" & origin=="Romania"
replace ID_GADM_fine="ROU39" if NAME_1=="Tulcea" & origin=="Romania"
replace ID_GADM_fine="ROU40" if NAME_1=="Vâlcea" & origin=="Romania"
replace ID_GADM_fine="ROU41" if NAME_1=="Vaslui" & origin=="Romania"
replace ID_GADM_fine="ROU42" if NAME_1=="Vrancea" & origin=="Romania"

* RUSSIA
replace NAME_1="Ingush" if NAME_1=="(Republic of) Ingushetia" & origin=="Russia"
replace NAME_1="Altay" if NAME_1=="Altai" & origin=="Russia"
replace NAME_1="Arkhangel'sk" if NAME_1=="Arkhangelsk (Oblast)" & origin=="Russia"
replace NAME_1="Astrakhan'" if NAME_1=="Astrakhan (Federal Subject)" & origin=="Russia"
replace NAME_1="Astrakhan'" if NAME_1=="Astrakhan (Oblast)" & origin=="Russia"
drop if NAME_1=="Caucasus (Region)" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Central" & origin=="Russia"
replace NAME_1="Sulawesi Tengah" if NAME_1=="Central Sulawesi" & origin=="Russia"
replace origin="Indonesia" if NAME_1=="Sulawesi Tengah" & origin=="Russia"
replace ID_GADM_fine="IDN27" if NAME_1=="Sulawesi Tengah" & origin=="Indonesia"
drop if NAME_1=="Chechen Republic" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Chechnya (Federal District)" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Chechnya (Occupied Territory)" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Chechnya (Republic)" & origin=="Russia"
replace NAME_1="Chelyabinsk" if NAME_1=="Chelyabinsk (Oblast)" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Dagestan (Oblast)" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Dagestan (Region)" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Dagestan (Republic)" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Daghestan (Republic)" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Elbrussky" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Grozny" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Inguisha" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetia" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetia (Province)" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetia (Republic)" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetia (State)" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetia Republic" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Ingushetiya (Republic)" & origin=="Russia"
replace NAME_1="Irkutsk" if NAME_1=="Irkutsk (Oblast)" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Kabarda-Balkaria" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Kabardino Balkariya" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Kabardino-Balkaria" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Kabardino-Balkariya" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Kabardino-Balkariya (Republic)" & origin=="Russia"
replace NAME_1="Kaliningrad" if NAME_1=="Kaliningrad Oblast" & origin=="Russia"
replace NAME_1="Kamchatka" if NAME_1=="Kamchatka (Oblast)" & origin=="Russia"
replace NAME_1="Karachay-Cherkess" if NAME_1=="Karachay-Cherkessia" & origin=="Russia"
replace NAME_1="Karachay-Cherkess" if NAME_1=="Karachay-Cherkessia (Autonomous Republic)" & origin=="Russia"
replace NAME_1="Karachay-Cherkess" if NAME_1=="Karachayevo Cherkesiya Republic" & origin=="Russia"
replace NAME_1="Karachay-Cherkess" if NAME_1=="Karachayevo-Cherkessia (Republic)" & origin=="Russia"
replace NAME_1="Khabarovsk" if NAME_1=="Khabarovsk (Krai)" & origin=="Russia"
replace NAME_1="Khabarovsk" if NAME_1=="Khabarovsk Krai" & origin=="Russia"
replace NAME_1="Khanty-Mansiy" if NAME_1=="Khanty-Mansi (Autonomous Okrug)" & origin=="Russia"
replace NAME_1="Krasnodar" if NAME_1=="Krasnodar (Federal Subject)" & origin=="Russia"
replace NAME_1="Krasnodar" if NAME_1=="Krasnodar Krai" & origin=="Russia"
replace NAME_1="Krasnodar" if NAME_1=="Krasnodarsky" & origin=="Russia"
replace NAME_1="Krasnoyarsk" if NAME_1=="Krasnoyarsk (Krai)" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Kurchaloyevsky" & origin=="Russia"
replace NAME_1="Leningrad" if NAME_1=="Leningrad" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Malgobeksky" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow (Federal City)" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow (Oblast)" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow (Region)" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow Federal City" & origin=="Russia"
replace NAME_1="Moscow City" if NAME_1=="Moscow Oblast" & origin=="Russia"
replace NAME_1="Ingush" if NAME_1=="Nazranovsky" & origin=="Russia"
replace NAME_1="Nizhegorod" if NAME_1=="Nizhny Novgorod" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="North Caucasian Federal District" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="North Caucasus (Region)" & origin=="Russia"
replace NAME_1="North Ossetia" if NAME_1=="North Ossetia-Alania" & origin=="Russia"
replace NAME_1="North Ossetia" if NAME_1=="North Ossetia-Alania (Republic)" & origin=="Russia"
replace NAME_1="North Ossetia" if NAME_1=="North Ossetia–Alania" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="North-Caucasian (Region)" & origin=="Russia"
replace NAME_1="Novgorod" if NAME_1=="Novgorod Oblast" & origin=="Russia"
replace NAME_1="Orel" if NAME_1=="Oryol Oblast" & origin=="Russia"
replace NAME_1="Primor'ye" if NAME_1=="Primorsky Krai" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Republic of Dagestan" & origin=="Russia"
replace NAME_1="Dagestan" if NAME_1=="Republic of Degastan" & origin=="Russia"
replace NAME_1="Rostov" if NAME_1=="Rostov (Oblast)" & origin=="Russia"
replace NAME_1="Rostov" if NAME_1=="Rostov (Rostovskaya) Oblast" & origin=="Russia"
drop if NAME_1=="Russia" & origin=="Russia"
drop if NAME_1=="Russian Republic" & origin=="Russia"
replace NAME_1="City of St. Petersburg" if NAME_1=="Saint Petersburg" & origin=="Russia"
replace NAME_1="Sakhalin" if NAME_1=="Sakhalin" & origin=="Russia"
replace NAME_1="Samara" if NAME_1=="Samara Oblast" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Shali" & origin=="Russia"
drop if NAME_1=="Siberia (Oblast)" & origin=="Russia"
drop if NAME_1=="Skra" & origin=="Russia"
replace NAME_1="Smolensk" if NAME_1=="Smolensk (Oblast)" & origin=="Russia"
replace NAME_1="Smolensk" if NAME_1=="Smolensk Oblast" & origin=="Russia"
replace NAME_1="Smolensk" if NAME_1=="Smolensk Oblast (Administrative Region)" & origin=="Russia"
replace NAME_1="City of St. Petersburg" if NAME_1=="St. Petersburg" & origin=="Russia"
replace NAME_1="City of St. Petersburg" if NAME_1=="St. Petersburg (Federal City)" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="Stavropol" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="Stavropol (Krai)" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="Stavropol Krai" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="Stavropol Krai" & origin=="Russia"
replace NAME_1="Stavropol'" if NAME_1=="Stavropolye Region" & origin=="Russia"
replace NAME_1="Sverdlovsk" if NAME_1=="Sverdlovsk (Oblast)" & origin=="Russia"
replace NAME_1="Tomsk" if NAME_1=="Tomsk Oblast" & origin=="Russia"
replace NAME_1="Tula" if NAME_1=="Tula (Oblast)" & origin=="Russia"
replace NAME_1="Tver'" if NAME_1=="Tver" & origin=="Russia"
replace NAME_1="Tyumen'" if NAME_1=="Tyumen (Oblast)" & origin=="Russia"
drop if NAME_1=="Urals (Federal  District )" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Urus-Martan (District)" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Urus-Martanovsky" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Vedeno" & origin=="Russia"
replace NAME_1="Chechnya" if NAME_1=="Vedensky" & origin=="Russia"
replace NAME_1="Volgograd" if NAME_1=="Volga (District)" & origin=="Russia"
replace NAME_1="Volgograd" if NAME_1=="Volgograd" & origin=="Russia"
replace NAME_1="Volgograd" if NAME_1=="Volgograd (Oblast)" & origin=="Russia"
replace NAME_1="Volgograd" if NAME_1=="Volgograd Oblast" & origin=="Russia"
replace NAME_1="Vologda" if NAME_1=="Vologda" & origin=="Russia"
replace NAME_1="Voronezh" if NAME_1=="Voronezh (Oblast)" & origin=="Russia"
replace NAME_1="Voronezh" if NAME_1=="Voronezh Oblast" & origin=="Russia"
replace NAME_1="Yaroslavl'" if NAME_1=="Yaroslavl Oblast" & origin=="Russia"
replace NAME_1="Zabaykal'ye" if NAME_1=="Zabaykalsky (Krai)" & origin=="Russia"
replace NAME_1="Kabardin-Balkar" if NAME_1=="Zolsky" & origin=="Russia"
replace ID_GADM_fine="RUS1" if NAME_1=="Adygey" & origin=="Russia"
replace ID_GADM_fine="RUS2" if NAME_1=="Altay" & origin=="Russia"
replace ID_GADM_fine="RUS3" if NAME_1=="Amur" & origin=="Russia"
replace ID_GADM_fine="RUS4" if NAME_1=="Arkhangel'sk" & origin=="Russia"
replace ID_GADM_fine="RUS5" if NAME_1=="Astrakhan'" & origin=="Russia"
replace ID_GADM_fine="RUS6" if NAME_1=="Bashkortostan" & origin=="Russia"
replace ID_GADM_fine="RUS7" if NAME_1=="Belgorod" & origin=="Russia"
replace ID_GADM_fine="RUS8" if NAME_1=="Bryansk" & origin=="Russia"
replace ID_GADM_fine="RUS9" if NAME_1=="Buryat" & origin=="Russia"
replace ID_GADM_fine="RUS10" if NAME_1=="Chechnya" & origin=="Russia"
replace ID_GADM_fine="RUS11" if NAME_1=="Chelyabinsk" & origin=="Russia"
replace ID_GADM_fine="RUS12" if NAME_1=="Chukot" & origin=="Russia"
replace ID_GADM_fine="RUS13" if NAME_1=="Chuvash" & origin=="Russia"
replace ID_GADM_fine="RUS14" if NAME_1=="City of St. Petersburg" & origin=="Russia"
replace ID_GADM_fine="RUS15" if NAME_1=="Dagestan" & origin=="Russia"
replace ID_GADM_fine="RUS16" if NAME_1=="Gorno-Altay" & origin=="Russia"
replace ID_GADM_fine="RUS17" if NAME_1=="Ingush" & origin=="Russia"
replace ID_GADM_fine="RUS18" if NAME_1=="Irkutsk" & origin=="Russia"
replace ID_GADM_fine="RUS19" if NAME_1=="Ivanovo" & origin=="Russia"
replace ID_GADM_fine="RUS20" if NAME_1=="Kabardin-Balkar" & origin=="Russia"
replace ID_GADM_fine="RUS21" if NAME_1=="Kaliningrad" & origin=="Russia"
replace ID_GADM_fine="RUS22" if NAME_1=="Kalmyk" & origin=="Russia"
replace ID_GADM_fine="RUS23" if NAME_1=="Kaluga" & origin=="Russia"
replace ID_GADM_fine="RUS24" if NAME_1=="Kamchatka" & origin=="Russia"
replace ID_GADM_fine="RUS25" if NAME_1=="Karachay-Cherkess" & origin=="Russia"
replace ID_GADM_fine="RUS26" if NAME_1=="Karelia" & origin=="Russia"
replace ID_GADM_fine="RUS27" if NAME_1=="Kemerovo" & origin=="Russia"
replace ID_GADM_fine="RUS28" if NAME_1=="Khabarovsk" & origin=="Russia"
replace ID_GADM_fine="RUS29" if NAME_1=="Khakass" & origin=="Russia"
replace ID_GADM_fine="RUS30" if NAME_1=="Khanty-Mansiy" & origin=="Russia"
replace ID_GADM_fine="RUS31" if NAME_1=="Kirov" & origin=="Russia"
replace ID_GADM_fine="RUS32" if NAME_1=="Komi" & origin=="Russia"
replace ID_GADM_fine="RUS33" if NAME_1=="Kostroma" & origin=="Russia"
replace ID_GADM_fine="RUS34" if NAME_1=="Krasnodar" & origin=="Russia"
replace ID_GADM_fine="RUS35" if NAME_1=="Krasnoyarsk" & origin=="Russia"
replace ID_GADM_fine="RUS36" if NAME_1=="Kurgan" & origin=="Russia"
replace ID_GADM_fine="RUS37" if NAME_1=="Kursk" & origin=="Russia"
replace ID_GADM_fine="RUS38" if NAME_1=="Leningrad" & origin=="Russia"
replace ID_GADM_fine="RUS39" if NAME_1=="Lipetsk" & origin=="Russia"
replace ID_GADM_fine="RUS40" if NAME_1=="Maga Buryatdan" & origin=="Russia"
replace ID_GADM_fine="RUS41" if NAME_1=="Mariy-El" & origin=="Russia"
replace ID_GADM_fine="RUS42" if NAME_1=="Mordovia" & origin=="Russia"
replace ID_GADM_fine="RUS43" if NAME_1=="Moscow City" & origin=="Russia"
replace ID_GADM_fine="RUS44" if NAME_1=="Moskva" & origin=="Russia"
replace ID_GADM_fine="RUS45" if NAME_1=="Murmansk" & origin=="Russia"
replace ID_GADM_fine="RUS46" if NAME_1=="Nenets" & origin=="Russia"
replace ID_GADM_fine="RUS47" if NAME_1=="Nizhegorod" & origin=="Russia"
replace ID_GADM_fine="RUS48" if NAME_1=="North Ossetia" & origin=="Russia"
replace ID_GADM_fine="RUS49" if NAME_1=="Novgorod" & origin=="Russia"
replace ID_GADM_fine="RUS50" if NAME_1=="Novosibirsk" & origin=="Russia"
replace ID_GADM_fine="RUS51" if NAME_1=="Omsk" & origin=="Russia"
replace ID_GADM_fine="RUS52" if NAME_1=="Orel" & origin=="Russia"
replace ID_GADM_fine="RUS53" if NAME_1=="Orenburg" & origin=="Russia"
replace ID_GADM_fine="RUS54" if NAME_1=="Penza" & origin=="Russia"
replace ID_GADM_fine="RUS55" if NAME_1=="Perm'" & origin=="Russia"
replace ID_GADM_fine="RUS56" if NAME_1=="Primor'ye" & origin=="Russia"
replace ID_GADM_fine="RUS57" if NAME_1=="Pskov" & origin=="Russia"
replace ID_GADM_fine="RUS58" if NAME_1=="Rostov" & origin=="Russia"
replace ID_GADM_fine="RUS59" if NAME_1=="Ryazan'" & origin=="Russia"
replace ID_GADM_fine="RUS60" if NAME_1=="Sakha" & origin=="Russia"
replace ID_GADM_fine="RUS61" if NAME_1=="Sakhalin" & origin=="Russia"
replace ID_GADM_fine="RUS62" if NAME_1=="Samara" & origin=="Russia"
replace ID_GADM_fine="RUS63" if NAME_1=="Saratov" & origin=="Russia"
replace ID_GADM_fine="RUS64" if NAME_1=="Smolensk" & origin=="Russia"
replace ID_GADM_fine="RUS65" if NAME_1=="Stavropol'" & origin=="Russia"
replace ID_GADM_fine="RUS66" if NAME_1=="Sverdlovsk" & origin=="Russia"
replace ID_GADM_fine="RUS67" if NAME_1=="Tambov" & origin=="Russia"
replace ID_GADM_fine="RUS68" if NAME_1=="Tatarstan" & origin=="Russia"
replace ID_GADM_fine="RUS69" if NAME_1=="Tomsk" & origin=="Russia"
replace ID_GADM_fine="RUS70" if NAME_1=="Tula" & origin=="Russia"
replace ID_GADM_fine="RUS71" if NAME_1=="Tuva" & origin=="Russia"
replace ID_GADM_fine="RUS72" if NAME_1=="Tver'" & origin=="Russia"
replace ID_GADM_fine="RUS73" if NAME_1=="Tyumen'" & origin=="Russia"
replace ID_GADM_fine="RUS74" if NAME_1=="Udmurt" & origin=="Russia"
replace ID_GADM_fine="RUS75" if NAME_1=="Ul'yanovsk" & origin=="Russia"
replace ID_GADM_fine="RUS76" if NAME_1=="Vladimir" & origin=="Russia"
replace ID_GADM_fine="RUS77" if NAME_1=="Volgograd" & origin=="Russia"
replace ID_GADM_fine="RUS78" if NAME_1=="Vologda" & origin=="Russia"
replace ID_GADM_fine="RUS79" if NAME_1=="Voronezh" & origin=="Russia"
replace ID_GADM_fine="RUS80" if NAME_1=="Yamal-Nenets" & origin=="Russia"
replace ID_GADM_fine="RUS81" if NAME_1=="Yaroslavl'" & origin=="Russia"
replace ID_GADM_fine="RUS82" if NAME_1=="Yevrey" & origin=="Russia"
replace ID_GADM_fine="RUS83" if NAME_1=="Zabaykal'ye" & origin=="Russia"

* RWANDA
replace NAME_1="Iburasirazuba" if NAME_1=="Eastern" & origin=="Rwanda"
replace NAME_1="Amajyepfo" if NAME_1=="Gikongoro" & origin=="Rwanda"
replace NAME_1="Iburengerazuba" if NAME_1=="Gisenyi" & origin=="Rwanda"
replace NAME_1="Amajyepfo" if NAME_1=="Gitarama" & origin=="Rwanda"
replace NAME_1="Umujyi wa Kigali" if NAME_1=="Kigali" & origin=="Rwanda"
replace NAME_1="Amajyaruguru" if NAME_1=="Northern" & origin=="Rwanda"
replace NAME_1="Amajyepfo" if NAME_1=="Southern" & origin=="Rwanda"
replace NAME_1="Iburengerazuba" if NAME_1=="Western" & origin=="Rwanda"
replace ID_GADM_fine="RWA1" if NAME_1=="Amajyaruguru" & origin=="Rwanda"
replace ID_GADM_fine="RWA2" if NAME_1=="Amajyepfo" & origin=="Rwanda"
replace ID_GADM_fine="RWA3" if NAME_1=="Iburasirazuba" & origin=="Rwanda"
replace ID_GADM_fine="RWA4" if NAME_1=="Iburengerazuba" & origin=="Rwanda"
replace ID_GADM_fine="RWA5" if NAME_1=="Umujyi wa Kigali" & origin=="Rwanda"

* SAUDI ARABIA // Not in GADM --> use GWP as reference
replace NAME_1="Eastern Province" if NAME_1=="Eastern" & origin=="Saudi Arabia"
replace NAME_1="Hael" if NAME_1=="Hail" & origin=="Saudi Arabia"
replace NAME_1="Jazan" if NAME_1=="Jizan" & origin=="Saudi Arabia"
replace NAME_1="Medina" if NAME_1=="Madinah" & origin=="Saudi Arabia"
replace NAME_1="Mecca" if NAME_1=="Makkah" & origin=="Saudi Arabia"
replace NAME_1="Najran" if NAME_1=="Najran" & origin=="Saudi Arabia"
replace NAME_1="N. Borders" if NAME_1=="Northern" & origin=="Saudi Arabia"
replace NAME_1="N. Borders" if NAME_1=="Northern Borders" & origin=="Saudi Arabia"
replace NAME_1="Qassim" if NAME_1=="Qassim" & origin=="Saudi Arabia"
replace NAME_1="Riyadh" if NAME_1=="Riyadh" & origin=="Saudi Arabia"
replace NAME_1="Tabuk" if NAME_1=="Tabuk" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU1" if NAME_1=="Riyadh" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU2" if NAME_1=="Qassim" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU3" if NAME_1=="Mecca" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU4" if NAME_1=="Medina" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU5" if NAME_1=="Eastern Province" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU6" if NAME_1=="Al Baha" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU7" if NAME_1=="Asir" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU8" if NAME_1=="Jazan" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU9" if NAME_1=="Najran" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU10" if NAME_1=="Tabuk" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU11" if NAME_1=="Hael" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU12" if NAME_1=="N. Borders" & origin=="Saudi Arabia"
replace ID_GADM_fine="SAU13" if NAME_1=="Jouf" & origin=="Saudi Arabia"

* SENEGAL
replace NAME_1="Sédhiou" if NAME_1=="Sedhiou" & origin=="Senegal"
replace ID_GADM_fine="SEN1" if NAME_1=="Dakar" & origin=="Senegal"
replace ID_GADM_fine="SEN2" if NAME_1=="Diourbel" & origin=="Senegal"
replace ID_GADM_fine="SEN3" if NAME_1=="Fatick" & origin=="Senegal"
replace ID_GADM_fine="SEN4" if NAME_1=="Kaffrine" & origin=="Senegal"
replace ID_GADM_fine="SEN5" if NAME_1=="Kaolack" & origin=="Senegal"
replace ID_GADM_fine="SEN6" if NAME_1=="Kédougou" & origin=="Senegal"
replace ID_GADM_fine="SEN7" if NAME_1=="Kolda" & origin=="Senegal"
replace ID_GADM_fine="SEN8" if NAME_1=="Louga" & origin=="Senegal"
replace ID_GADM_fine="SEN9" if NAME_1=="Matam" & origin=="Senegal"
replace ID_GADM_fine="SEN10" if NAME_1=="Saint-Louis" & origin=="Senegal"
replace ID_GADM_fine="SEN11" if NAME_1=="Sédhiou" & origin=="Senegal"
replace ID_GADM_fine="SEN12" if NAME_1=="Tambacounda" & origin=="Senegal"
replace ID_GADM_fine="SEN13" if NAME_1=="Thiès" & origin=="Senegal"
replace ID_GADM_fine="SEN14" if NAME_1=="Ziguinchor" & origin=="Senegal"

* SERBIA
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade" & origin=="Serbia"
drop if NAME_1=="Central Serbia" & origin=="Serbia" // Too large
replace NAME_1="Pčinjski" if NAME_1=="Pcinja" & origin=="Serbia"
drop if NAME_1=="Serbia" & origin=="Serbia" // Too large
drop if NAME_1=="Southern and Eastern Serbia" & origin=="Serbia" // Too large
drop if NAME_1=="Vojvodina" & origin=="Serbia"
replace ID_GADM_fine="SRB1" if NAME_1=="Borski" & origin=="Serbia"
replace ID_GADM_fine="SRB2" if NAME_1=="Braničevski" & origin=="Serbia"
replace ID_GADM_fine="SRB3" if NAME_1=="Grad Beograd" & origin=="Serbia"
replace ID_GADM_fine="SRB4" if NAME_1=="Jablanički" & origin=="Serbia"
replace ID_GADM_fine="SRB5" if NAME_1=="Južno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB6" if NAME_1=="Južno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB7" if NAME_1=="Kolubarski" & origin=="Serbia"
replace ID_GADM_fine="SRB8" if NAME_1=="Mačvanski" & origin=="Serbia"
replace ID_GADM_fine="SRB9" if NAME_1=="Moravički" & origin=="Serbia"
replace ID_GADM_fine="SRB10" if NAME_1=="Nišavski" & origin=="Serbia"
replace ID_GADM_fine="SRB11" if NAME_1=="Pčinjski" & origin=="Serbia"
replace ID_GADM_fine="SRB12" if NAME_1=="Pirotski" & origin=="Serbia"
replace ID_GADM_fine="SRB13" if NAME_1=="Podunavski" & origin=="Serbia"
replace ID_GADM_fine="SRB14" if NAME_1=="Pomoravski" & origin=="Serbia"
replace ID_GADM_fine="SRB15" if NAME_1=="Rasinski" & origin=="Serbia"
replace ID_GADM_fine="SRB16" if NAME_1=="Raški" & origin=="Serbia"
replace ID_GADM_fine="SRB17" if NAME_1=="Severno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB18" if NAME_1=="Severno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB19" if NAME_1=="Srednje-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB20" if NAME_1=="Sremski" & origin=="Serbia"
replace ID_GADM_fine="SRB21" if NAME_1=="Šumadijski" & origin=="Serbia"
replace ID_GADM_fine="SRB22" if NAME_1=="Toplički" & origin=="Serbia"
replace ID_GADM_fine="SRB23" if NAME_1=="Zaječarski" & origin=="Serbia"
replace ID_GADM_fine="SRB24" if NAME_1=="Zapadno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB25" if NAME_1=="Zlatiborski" & origin=="Serbia"

* SERBIA-MONTENEGRO
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade" & origin=="Serbia-Montenegro"
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade (Autonomous Territory)" & origin=="Serbia-Montenegro"
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade (District)" & origin=="Serbia-Montenegro"
replace NAME_1="Pčinjski" if NAME_1=="Bujanovac (Municipality)" & origin=="Serbia-Montenegro"
replace NAME_1="Jablanički" if NAME_1=="Medveda (District)" & origin=="Serbia-Montenegro"
replace NAME_1="Pčinjski" if NAME_1=="Pcinja ( District )" & origin=="Serbia-Montenegro"
replace NAME_1="Pčinjski" if NAME_1=="Pcinja (District)" & origin=="Serbia-Montenegro"
replace NAME_1="Raški" if NAME_1=="Raska ( District )" & origin=="Serbia-Montenegro"
drop if NAME_1=="Vojvodina (Province)" & origin=="Serbia-Montenegro"
replace origin="Serbia" if origin=="Serbia-Montenegro"
replace ID_GADM_fine="SRB1" if NAME_1=="Borski" & origin=="Serbia"
replace ID_GADM_fine="SRB2" if NAME_1=="Braničevski" & origin=="Serbia"
replace ID_GADM_fine="SRB3" if NAME_1=="Grad Beograd" & origin=="Serbia"
replace ID_GADM_fine="SRB4" if NAME_1=="Jablanički" & origin=="Serbia"
replace ID_GADM_fine="SRB5" if NAME_1=="Južno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB6" if NAME_1=="Južno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB7" if NAME_1=="Kolubarski" & origin=="Serbia"
replace ID_GADM_fine="SRB8" if NAME_1=="Mačvanski" & origin=="Serbia"
replace ID_GADM_fine="SRB9" if NAME_1=="Moravički" & origin=="Serbia"
replace ID_GADM_fine="SRB10" if NAME_1=="Nišavski" & origin=="Serbia"
replace ID_GADM_fine="SRB11" if NAME_1=="Pčinjski" & origin=="Serbia"
replace ID_GADM_fine="SRB12" if NAME_1=="Pirotski" & origin=="Serbia"
replace ID_GADM_fine="SRB13" if NAME_1=="Podunavski" & origin=="Serbia"
replace ID_GADM_fine="SRB14" if NAME_1=="Pomoravski" & origin=="Serbia"
replace ID_GADM_fine="SRB15" if NAME_1=="Rasinski" & origin=="Serbia"
replace ID_GADM_fine="SRB16" if NAME_1=="Raški" & origin=="Serbia"
replace ID_GADM_fine="SRB17" if NAME_1=="Severno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB18" if NAME_1=="Severno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB19" if NAME_1=="Srednje-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB20" if NAME_1=="Sremski" & origin=="Serbia"
replace ID_GADM_fine="SRB21" if NAME_1=="Šumadijski" & origin=="Serbia"
replace ID_GADM_fine="SRB22" if NAME_1=="Toplički" & origin=="Serbia"
replace ID_GADM_fine="SRB23" if NAME_1=="Zaječarski" & origin=="Serbia"
replace ID_GADM_fine="SRB24" if NAME_1=="Zapadno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB25" if NAME_1=="Zlatiborski" & origin=="Serbia"

* SIERRA LEONE
replace ID_GADM_fine="SLE1" if NAME_1=="Eastern" & origin=="Sierra Leone"
replace ID_GADM_fine="SLE2" if NAME_1=="Northern" & origin=="Sierra Leone"
replace ID_GADM_fine="SLE3" if NAME_1=="Southern" & origin=="Sierra Leone"
replace ID_GADM_fine="SLE4" if NAME_1=="Western" & origin=="Sierra Leone"

* SLOVAK REPUBLIC
replace origin="Slovakia" if origin=="Slovak Republic"
replace NAME_1="Bratislavský" if NAME_1=="Bratislava" & origin=="Slovakia"
replace NAME_1="Bratislavský" if NAME_1=="Bratislava (Region)" & origin=="Slovakia"
replace ID_GADM_fine="SVK2" if NAME_1=="Bratislavský" & origin=="Slovakia"

* SLOVENIA
replace NAME_1="Osrednjeslovenska" if NAME_1=="Ljubljana (Municipality)" & origin=="Slovenia"
replace ID_GADM_fine="SVN1" if NAME_1=="Gorenjska" & origin=="Slovenia"
replace ID_GADM_fine="SVN2" if NAME_1=="Goriška" & origin=="Slovenia"
replace ID_GADM_fine="SVN3" if NAME_1=="Jugovzhodna Slovenija" & origin=="Slovenia"
replace ID_GADM_fine="SVN4" if NAME_1=="Koroška" & origin=="Slovenia"
replace ID_GADM_fine="SVN5" if NAME_1=="Notranjsko-kraška" & origin=="Slovenia"
replace ID_GADM_fine="SVN6" if NAME_1=="Obalno-kraška" & origin=="Slovenia"
replace ID_GADM_fine="SVN7" if NAME_1=="Osrednjeslovenska" & origin=="Slovenia"
replace ID_GADM_fine="SVN8" if NAME_1=="Podravska" & origin=="Slovenia"
replace ID_GADM_fine="SVN9" if NAME_1=="Pomurska" & origin=="Slovenia"
replace ID_GADM_fine="SVN10" if NAME_1=="Savinjska" & origin=="Slovenia"
replace ID_GADM_fine="SVN11" if NAME_1=="Spodnjeposavska" & origin=="Slovenia"
replace ID_GADM_fine="SVN12" if NAME_1=="Zasavska" & origin=="Slovenia"

* SOLOMON ISLANDS
replace NAME_1="Guadalcanal" if NAME_1=="Guandacanal" & origin=="Solomon Islands"
replace NAME_1="Malaita" if NAME_1=="Malaita (Province)" & origin=="Solomon Islands"
replace ID_GADM_fine="SLB3" if NAME_1=="Guadalcanal" & origin=="Solomon Islands"
replace ID_GADM_fine="SLB7" if NAME_1=="Malaita" & origin=="Solomon Islands"

* SOMALIA
drop if NAME_1=="Jubaland" & origin=="Somalia" // Too large
replace NAME_1="Jubbada Hoose" if NAME_1=="Lower Juba" & origin=="Somalia"
replace NAME_1="Shabeellaha Hoose" if NAME_1=="Lower Shebelle" & origin=="Somalia"
replace NAME_1="Jubbada Dhexe" if NAME_1=="Middle Juba" & origin=="Somalia"
replace NAME_1="Shabeellaha Dhexe" if NAME_1=="Middle Shebelle" & origin=="Somalia"
replace ID_GADM_fine="SOM1" if NAME_1=="Awdal" & origin=="Somalia"
replace ID_GADM_fine="SOM2" if NAME_1=="Bakool" & origin=="Somalia"
replace ID_GADM_fine="SOM3" if NAME_1=="Banaadir" & origin=="Somalia"
replace ID_GADM_fine="SOM4" if NAME_1=="Bari" & origin=="Somalia"
replace ID_GADM_fine="SOM5" if NAME_1=="Bay" & origin=="Somalia"
replace ID_GADM_fine="SOM6" if NAME_1=="Galguduud" & origin=="Somalia"
replace ID_GADM_fine="SOM7" if NAME_1=="Gedo" & origin=="Somalia"
replace ID_GADM_fine="SOM8" if NAME_1=="Hiiraan" & origin=="Somalia"
replace ID_GADM_fine="SOM9" if NAME_1=="Jubbada Dhexe" & origin=="Somalia"
replace ID_GADM_fine="SOM10" if NAME_1=="Jubbada Hoose" & origin=="Somalia"
replace ID_GADM_fine="SOM11" if NAME_1=="Mudug" & origin=="Somalia"
replace ID_GADM_fine="SOM12" if NAME_1=="Nugaal" & origin=="Somalia"
replace ID_GADM_fine="SOM13" if NAME_1=="Sanaag" & origin=="Somalia"
replace ID_GADM_fine="SOM14" if NAME_1=="Shabeellaha Dhexe" & origin=="Somalia"
replace ID_GADM_fine="SOM15" if NAME_1=="Shabeellaha Hoose" & origin=="Somalia"
replace ID_GADM_fine="SOM16" if NAME_1=="Sool" & origin=="Somalia"
replace ID_GADM_fine="SOM17" if NAME_1=="Togdheer" & origin=="Somalia"
replace ID_GADM_fine="SOM18" if NAME_1=="Woqooyi Galbeed" & origin=="Somalia"

* SOUTH AFRICA // Not in GWP --> drop
drop if origin=="South Africa"

* SOUTH KOREA
replace NAME_1="Jeollabuk-do" if NAME_1=="Jeola (Province)" & origin=="South Korea"
replace NAME_1="Gyeongsangnam-do" if NAME_1=="Yeongnam" & origin=="South Korea"
replace ID_GADM_fine="KOR1" if NAME_1=="Busan" & origin=="South Korea"
replace ID_GADM_fine="KOR2" if NAME_1=="Chungcheongbuk-do" & origin=="South Korea"
replace ID_GADM_fine="KOR3" if NAME_1=="Chungcheongnam-do" & origin=="South Korea"
replace ID_GADM_fine="KOR4" if NAME_1=="Daegu" & origin=="South Korea"
replace ID_GADM_fine="KOR5" if NAME_1=="Daejeon" & origin=="South Korea"
replace ID_GADM_fine="KOR6" if NAME_1=="Gangwon-do" & origin=="South Korea"
replace ID_GADM_fine="KOR7" if NAME_1=="Gwangju" & origin=="South Korea"
replace ID_GADM_fine="KOR8" if NAME_1=="Gyeonggi-do" & origin=="South Korea"
replace ID_GADM_fine="KOR9" if NAME_1=="Gyeongsangbuk-do" & origin=="South Korea"
replace ID_GADM_fine="KOR10" if NAME_1=="Gyeongsangnam-do" & origin=="South Korea"
replace ID_GADM_fine="KOR11" if NAME_1=="Incheon" & origin=="South Korea"
replace ID_GADM_fine="KOR12" if NAME_1=="Jeju" & origin=="South Korea"
replace ID_GADM_fine="KOR13" if NAME_1=="Jeollabuk-do" & origin=="South Korea"
replace ID_GADM_fine="KOR14" if NAME_1=="Jeollanam-do" & origin=="South Korea"
replace ID_GADM_fine="KOR15" if NAME_1=="Sejong" & origin=="South Korea"
replace ID_GADM_fine="KOR16" if NAME_1=="Seoul" & origin=="South Korea"
replace ID_GADM_fine="KOR17" if NAME_1=="Ulsan" & origin=="South Korea"

* SOUTH SUDAN
replace NAME_1="West Equatoria" if NAME_1=="Amadi" & origin=="South Sudan"
replace NAME_1="West Equatoria" if NAME_1=="Gbudwe" & origin=="South Sudan"
replace NAME_1="Eastern Equatoria" if NAME_1=="Imatong" & origin=="South Sudan"
replace NAME_1="Jungoli" if NAME_1=="Jonglei" & origin=="South Sudan"
replace NAME_1="Central Equatoria" if NAME_1=="Jubek" & origin=="South Sudan"
replace NAME_1="North Bahr-al-Ghazal" if NAME_1=="Lakes" & origin=="South Sudan"
replace NAME_1="Warap" if NAME_1=="Warrap" & origin=="South Sudan"
replace NAME_1="West Bahr-al-Ghazal" if NAME_1=="Wau" & origin=="South Sudan"
replace NAME_1="West Bahr-al-Ghazal" if NAME_1=="Western Bahr el Ghazal" & origin=="South Sudan"
replace NAME_1="West Equatoria" if NAME_1=="Western Equatoria" & origin=="South Sudan"
replace NAME_1="Central Equatoria" if NAME_1=="Yei River" & origin=="South Sudan"
replace ID_GADM_fine="SSD1" if NAME_1=="Central Equatoria" & origin=="South Sudan"
replace ID_GADM_fine="SSD2" if NAME_1=="Eastern Equatoria" & origin=="South Sudan"
replace ID_GADM_fine="SSD3" if NAME_1=="Jungoli" & origin=="South Sudan"
replace ID_GADM_fine="SSD4" if NAME_1=="Lakes" & origin=="South Sudan"
replace ID_GADM_fine="SSD5" if NAME_1=="North Bahr-al-Ghazal" & origin=="South Sudan"
replace ID_GADM_fine="SSD6" if NAME_1=="Unity" & origin=="South Sudan"
replace ID_GADM_fine="SSD7" if NAME_1=="Upper Nile" & origin=="South Sudan"
replace ID_GADM_fine="SSD8" if NAME_1=="Warap" & origin=="South Sudan"
replace ID_GADM_fine="SSD9" if NAME_1=="West Bahr-al-Ghazal" & origin=="South Sudan"
replace ID_GADM_fine="SSD10" if NAME_1=="West Equatoria" & origin=="South Sudan"

* SPAIN
replace NAME_1="Andalucía" if NAME_1=="Andalusia" & origin=="Spain"
replace NAME_1="Aragón" if NAME_1=="Aragon" & origin=="Spain"
replace NAME_1="Principado de Asturias" if NAME_1=="Asturias" & origin=="Spain"
replace NAME_1="Islas Baleares" if NAME_1=="Balearic Islands" & origin=="Spain"
replace NAME_1="País Vasco" if NAME_1=="Basque Country" & origin=="Spain"
replace NAME_1="Castilla y León" if NAME_1=="Castile and Leon" & origin=="Spain"
replace NAME_1="Castilla-La Mancha" if NAME_1=="Castile-La Mancha" & origin=="Spain"
replace NAME_1="Cataluña" if NAME_1=="Catalonia" & origin=="Spain"
replace NAME_1="Galicia" if NAME_1=="Galicia" & origin=="Spain"
replace NAME_1="La Rioja" if NAME_1=="La Rioja" & origin=="Spain"
replace NAME_1="Comunidad de Madrid" if NAME_1=="Madrid" & origin=="Spain"
replace NAME_1="Comunidad Foral de Navarra" if NAME_1=="Navarre" & origin=="Spain"
replace NAME_1="Comunidad Valenciana" if NAME_1=="Valencia" & origin=="Spain"
replace ID_GADM_fine="ESP1" if NAME_1=="Andalucía" & origin=="Spain"
replace ID_GADM_fine="ESP2" if NAME_1=="Aragón" & origin=="Spain"
replace ID_GADM_fine="ESP3" if NAME_1=="Cantabria" & origin=="Spain"
replace ID_GADM_fine="ESP4" if NAME_1=="Castilla-La Mancha" & origin=="Spain"
replace ID_GADM_fine="ESP5" if NAME_1=="Castilla y León" & origin=="Spain"
replace ID_GADM_fine="ESP6" if NAME_1=="Cataluña" & origin=="Spain"
replace ID_GADM_fine="ESP7" if NAME_1=="Ceuta y Melilla" & origin=="Spain"
replace ID_GADM_fine="ESP8" if NAME_1=="Comunidad de Madrid" & origin=="Spain"
replace ID_GADM_fine="ESP9" if NAME_1=="Comunidad Foral de Navarra" & origin=="Spain"
replace ID_GADM_fine="ESP10" if NAME_1=="Comunidad Valenciana" & origin=="Spain"
replace ID_GADM_fine="ESP11" if NAME_1=="Extremadura" & origin=="Spain"
replace ID_GADM_fine="ESP12" if NAME_1=="Galicia" & origin=="Spain"
replace ID_GADM_fine="ESP13" if NAME_1=="Islas Baleares" & origin=="Spain"
replace ID_GADM_fine="ESP14" if NAME_1=="Islas Canarias" & origin=="Spain"
replace ID_GADM_fine="ESP15" if NAME_1=="La Rioja" & origin=="Spain"
replace ID_GADM_fine="ESP16" if NAME_1=="País Vasco" & origin=="Spain"
replace ID_GADM_fine="ESP17" if NAME_1=="Principado de Asturias" & origin=="Spain"
replace ID_GADM_fine="ESP18" if NAME_1=="Región de Murcia" & origin=="Spain"

* SRI LANKA
replace NAME_1="Northern" if NAME_1=="Norhtern" & origin=="Sri Lanka"
replace NAME_1="Northwest" if NAME_1=="North Western" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA1" if NAME_1=="Western" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA2" if NAME_1=="Central" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA3" if NAME_1=="Southern" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA4" if NAME_1=="Northern" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA5" if NAME_1=="Eastern" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA6" if NAME_1=="Northwest" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA7" if NAME_1=="North Central" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA8" if NAME_1=="Uva" & origin=="Sri Lanka"
replace ID_GADM_fine="LKA9" if NAME_1=="Sabaragamuwa" & origin=="Sri Lanka"

* ST. LUCIA
drop if NAME_1=="Castries Quarter" & origin=="St. Lucia"

* SUDAN
replace NAME_1="Unity" if NAME_1=="Al Wahdah" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Unity"
replace origin="South Sudan" if NAME_1=="Central Equatoria" & origin=="Sudan"
replace NAME_1="Central Darfur" if NAME_1=="Darfur" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Eastern Equatoria" & origin=="Sudan"
replace NAME_1="Al Qadarif" if NAME_1=="Gedarif" & origin=="Sudan"
replace NAME_1="Al Jazirah" if NAME_1=="Gezira" & origin=="Sudan"
replace origin="Zimbabwe" if NAME_1=="Harare" & origin=="Sudan"
replace NAME_1="Jungoli" if NAME_1=="Jonglei" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Jungoli"
drop if NAME_1=="Kurdufan" & origin=="Sudan"
replace NAME_1="North Kurdufan" if NAME_1=="North Kordofan" & origin=="Sudan"
replace NAME_1="South Kurdufan" if NAME_1=="South Kordofan" & origin=="Sudan"
replace NAME_1="South Kurdufan" if NAME_1=="South Kurdufan" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Unity" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Upper Nile" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="Warap" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="West Equatoria" & origin=="Sudan"
replace NAME_1="West Kurdufan" if NAME_1=="West Kordofan" & origin=="Sudan"
replace NAME_1="West Bahr-al-Ghazal" if NAME_1=="Western Bahr el Ghazal" & origin=="Sudan"
replace origin="South Sudan" if NAME_1=="West Bahr-al-Ghazal" & origin=="Sudan"
replace ID_GADM_fine="SSD1" if NAME_1=="Central Equatoria" & origin=="South Sudan"
replace ID_GADM_fine="SSD2" if NAME_1=="Eastern Equatoria" & origin=="South Sudan"
replace ID_GADM_fine="SSD3" if NAME_1=="Jungoli" & origin=="South Sudan"
replace ID_GADM_fine="SSD6" if NAME_1=="Unity" & origin=="South Sudan"
replace ID_GADM_fine="SSD7" if NAME_1=="Upper Nile" & origin=="South Sudan"
replace ID_GADM_fine="SSD8" if NAME_1=="Warap" & origin=="South Sudan"
replace ID_GADM_fine="SSD9" if NAME_1=="West Bahr-al-Ghazal" & origin=="South Sudan"
replace ID_GADM_fine="SSD10" if NAME_1=="West Equatoria" & origin=="South Sudan"
replace ID_GADM_fine="SDN1" if NAME_1=="Al Jazirah" & origin=="Sudan"
replace ID_GADM_fine="SDN2" if NAME_1=="Al Qadarif" & origin=="Sudan"
replace ID_GADM_fine="SDN3" if NAME_1=="Blue Nile" & origin=="Sudan"
replace ID_GADM_fine="SDN4" if NAME_1=="Central Darfur" & origin=="Sudan"
replace ID_GADM_fine="SDN5" if NAME_1=="East Darfur" & origin=="Sudan"
replace ID_GADM_fine="SDN6" if NAME_1=="Kassala" & origin=="Sudan"
replace ID_GADM_fine="SDN7" if NAME_1=="Khartoum" & origin=="Sudan"
replace ID_GADM_fine="SDN8" if NAME_1=="North Darfur" & origin=="Sudan"
replace ID_GADM_fine="SDN9" if NAME_1=="North Kurdufan" & origin=="Sudan"
replace ID_GADM_fine="SDN10" if NAME_1=="Northern" & origin=="Sudan"
replace ID_GADM_fine="SDN11" if NAME_1=="Red Sea" & origin=="Sudan"
replace ID_GADM_fine="SDN12" if NAME_1=="River Nile" & origin=="Sudan"
replace ID_GADM_fine="SDN13" if NAME_1=="Sennar" & origin=="Sudan"
replace ID_GADM_fine="SDN14" if NAME_1=="South Darfur" & origin=="Sudan"
replace ID_GADM_fine="SDN15" if NAME_1=="South Kurdufan" & origin=="Sudan"
replace ID_GADM_fine="SDN16" if NAME_1=="West Darfur" & origin=="Sudan"
replace ID_GADM_fine="SDN17" if NAME_1=="West Kurdufan" & origin=="Sudan"
replace ID_GADM_fine="SDN18" if NAME_1=="White Nile" & origin=="Sudan"

* SWAZILAND
replace ID_GADM_fine="SWZ1" if NAME_1=="Hhohho" & origin=="Swaziland"
replace ID_GADM_fine="SWZ2" if NAME_1=="Lubombo" & origin=="Swaziland"
replace ID_GADM_fine="SWZ3" if NAME_1=="Manzini" & origin=="Swaziland"
replace ID_GADM_fine="SWZ4" if NAME_1=="Shiselweni" & origin=="Swaziland"

* SWEDEN
replace NAME_1="Gävleborg" if NAME_1=="Gavleborg" & origin=="Sweden"
replace NAME_1="Jönköping" if NAME_1=="Jonkoping" & origin=="Sweden"
replace NAME_1="Skåne" if NAME_1=="Skane" & origin=="Sweden"
replace NAME_1="Södermanland" if NAME_1=="Sodermanland" & origin=="Sweden"
replace NAME_1="Västerbotten" if NAME_1=="Vasterbotten" & origin=="Sweden"
replace NAME_1="Västernorrland" if NAME_1=="Vasternorrland" & origin=="Sweden"
replace NAME_1="Västra Götaland" if NAME_1=="Vastra Gotaland" & origin=="Sweden"
replace ID_GADM_fine="SWE1" if NAME_1=="Blekinge" & origin=="Sweden"
replace ID_GADM_fine="SWE2" if NAME_1=="Dalarna" & origin=="Sweden"
replace ID_GADM_fine="SWE3" if NAME_1=="Gävleborg" & origin=="Sweden"
replace ID_GADM_fine="SWE4" if NAME_1=="Gotland" & origin=="Sweden"
replace ID_GADM_fine="SWE5" if NAME_1=="Halland" & origin=="Sweden"
replace ID_GADM_fine="SWE6" if NAME_1=="Jämtland" & origin=="Sweden"
replace ID_GADM_fine="SWE7" if NAME_1=="Jönköping" & origin=="Sweden"
replace ID_GADM_fine="SWE8" if NAME_1=="Kalmar" & origin=="Sweden"
replace ID_GADM_fine="SWE9" if NAME_1=="Kronoberg" & origin=="Sweden"
replace ID_GADM_fine="SWE10" if NAME_1=="Norrbotten" & origin=="Sweden"
replace ID_GADM_fine="SWE11" if NAME_1=="Orebro" & origin=="Sweden"
replace ID_GADM_fine="SWE12" if NAME_1=="Östergötland" & origin=="Sweden"
replace ID_GADM_fine="SWE13" if NAME_1=="Skåne" & origin=="Sweden"
replace ID_GADM_fine="SWE14" if NAME_1=="Södermanland" & origin=="Sweden"
replace ID_GADM_fine="SWE15" if NAME_1=="Stockholm" & origin=="Sweden"
replace ID_GADM_fine="SWE16" if NAME_1=="Uppsala" & origin=="Sweden"
replace ID_GADM_fine="SWE17" if NAME_1=="Värmland" & origin=="Sweden"
replace ID_GADM_fine="SWE18" if NAME_1=="Västerbotten" & origin=="Sweden"
replace ID_GADM_fine="SWE19" if NAME_1=="Västernorrland" & origin=="Sweden"
replace ID_GADM_fine="SWE20" if NAME_1=="Västmanland" & origin=="Sweden"
replace ID_GADM_fine="SWE21" if NAME_1=="Västra Götaland" & origin=="Sweden"

* SWITZERLAND
replace NAME_1="Genève" if NAME_1=="Geneva" & origin=="Switzerland"
replace NAME_1="Graubünden" if NAME_1=="Graubunden" & origin=="Switzerland"
replace NAME_1="Sankt Gallen" if NAME_1=="Saint Gallen" & origin=="Switzerland"
replace NAME_1="Solothurn" if NAME_1=="Solothurn" & origin=="Switzerland"
replace NAME_1="Zürich" if NAME_1=="Zurich" & origin=="Switzerland"
replace ID_GADM_fine="CHE1" if NAME_1=="Aargau" & origin=="Switzerland"
replace ID_GADM_fine="CHE2" if NAME_1=="Appenzell Ausserrhoden" & origin=="Switzerland"
replace ID_GADM_fine="CHE3" if NAME_1=="Appenzell Innerrhoden" & origin=="Switzerland"
replace ID_GADM_fine="CHE4" if NAME_1=="Basel-Landschaft" & origin=="Switzerland"
replace ID_GADM_fine="CHE5" if NAME_1=="Basel-Stadt" & origin=="Switzerland"
replace ID_GADM_fine="CHE6" if NAME_1=="Bern" & origin=="Switzerland"
replace ID_GADM_fine="CHE7" if NAME_1=="Fribourg" & origin=="Switzerland"
replace ID_GADM_fine="CHE8" if NAME_1=="Genève" & origin=="Switzerland"
replace ID_GADM_fine="CHE9" if NAME_1=="Glarus" & origin=="Switzerland"
replace ID_GADM_fine="CHE10" if NAME_1=="Graubünden" & origin=="Switzerland"
replace ID_GADM_fine="CHE11" if NAME_1=="Jura" & origin=="Switzerland"
replace ID_GADM_fine="CHE12" if NAME_1=="Lucerne" & origin=="Switzerland"
replace ID_GADM_fine="CHE13" if NAME_1=="Neuchâtel" & origin=="Switzerland"
replace ID_GADM_fine="CHE14" if NAME_1=="Nidwalden" & origin=="Switzerland"
replace ID_GADM_fine="CHE15" if NAME_1=="Obwalden" & origin=="Switzerland"
replace ID_GADM_fine="CHE16" if NAME_1=="Sankt Gallen" & origin=="Switzerland"
replace ID_GADM_fine="CHE17" if NAME_1=="Schaffhausen" & origin=="Switzerland"
replace ID_GADM_fine="CHE18" if NAME_1=="Schwyz" & origin=="Switzerland"
replace ID_GADM_fine="CHE19" if NAME_1=="Solothurn" & origin=="Switzerland"
replace ID_GADM_fine="CHE20" if NAME_1=="Thurgau" & origin=="Switzerland"
replace ID_GADM_fine="CHE21" if NAME_1=="Ticino" & origin=="Switzerland"
replace ID_GADM_fine="CHE22" if NAME_1=="Uri" & origin=="Switzerland"
replace ID_GADM_fine="CHE23" if NAME_1=="Valais" & origin=="Switzerland"
replace ID_GADM_fine="CHE24" if NAME_1=="Vaud" & origin=="Switzerland"
replace ID_GADM_fine="CHE25" if NAME_1=="Zug" & origin=="Switzerland"
replace ID_GADM_fine="CHE26" if NAME_1=="Zürich" & origin=="Switzerland"

* SYRIA
replace NAME_1="Al Ḥasakah" if NAME_1=="Al Hasakah" & origin=="Syria"
replace NAME_1="As Suwayda'" if NAME_1=="As Suwayda" & origin=="Syria"
replace NAME_1="Dar`a" if NAME_1=="Daraa" & origin=="Syria"
replace NAME_1="Dayr Az Zawr" if NAME_1=="Deir ez-Zor" & origin=="Syria"
replace NAME_1="Hims" if NAME_1=="Homs" & origin=="Syria"
replace NAME_1="Idlib" if NAME_1=="Idlib Region" & origin=="Syria"
replace NAME_1="Lattakia" if NAME_1=="Latakia" & origin=="Syria"
replace NAME_1="Ar Raqqah" if NAME_1=="Raqqah" & origin=="Syria"
replace ID_GADM_fine="SYR1" if NAME_1=="Al Ḥasakah" & origin=="Syria"
replace ID_GADM_fine="SYR2" if NAME_1=="Aleppo" & origin=="Syria"
replace ID_GADM_fine="SYR3" if NAME_1=="Ar Raqqah" & origin=="Syria"
replace ID_GADM_fine="SYR4" if NAME_1=="As Suwayda'" & origin=="Syria"
replace ID_GADM_fine="SYR5" if NAME_1=="Damascus" & origin=="Syria"
replace ID_GADM_fine="SYR6" if NAME_1=="Dar`a" & origin=="Syria"
replace ID_GADM_fine="SYR7" if NAME_1=="Dayr Az Zawr" & origin=="Syria"
replace ID_GADM_fine="SYR8" if NAME_1=="Hamah" & origin=="Syria"
replace ID_GADM_fine="SYR9" if NAME_1=="Hims" & origin=="Syria"
replace ID_GADM_fine="SYR10" if NAME_1=="Idlib" & origin=="Syria"
replace ID_GADM_fine="SYR11" if NAME_1=="Lattakia" & origin=="Syria"
replace ID_GADM_fine="SYR12" if NAME_1=="Quneitra" & origin=="Syria"
replace ID_GADM_fine="SYR13" if NAME_1=="Rif Dimashq" & origin=="Syria"
replace ID_GADM_fine="SYR14" if NAME_1=="Tartus" & origin=="Syria"

* TAIWAN
replace NAME_1="Taiwan" if NAME_1=="Hsinchu" & origin=="Taiwan"
replace NAME_1="Taipei" if NAME_1=="Taipei (County)" & origin=="Taiwan"
replace NAME_1="Taiwan" if NAME_1=="Taoyuan (County)" & origin=="Taiwan"
replace NAME_1="Taiwan" if NAME_1=="Yunlin (County)" & origin=="Taiwan"
replace ID_GADM_fine="TWN1" if NAME_1=="Fujian" & origin=="Taiwan"
replace ID_GADM_fine="TWN2" if NAME_1=="Kaohsiung" & origin=="Taiwan"
replace ID_GADM_fine="TWN3" if NAME_1=="New Taipei" & origin=="Taiwan"
replace ID_GADM_fine="TWN4" if NAME_1=="Taichung" & origin=="Taiwan"
replace ID_GADM_fine="TWN5" if NAME_1=="Tainan" & origin=="Taiwan"
replace ID_GADM_fine="TWN6" if NAME_1=="Taipei" & origin=="Taiwan"
replace ID_GADM_fine="TWN7" if NAME_1=="Taiwan" & origin=="Taiwan"

* TAJIKISTAN
replace NAME_1="Dushanbe" if NAME_1=="(Region) of Republican Subordination (Province)" & origin=="Tajikistan"
replace NAME_1="Dushanbe" if NAME_1=="Districts of Republican Subordination" & origin=="Tajikistan"
replace NAME_1="Dushanbe" if NAME_1=="Dushanbe (Capital City)" & origin=="Tajikistan"
replace NAME_1="Tadzhikistan Territories" if NAME_1=="Kofarnihon (District)" & origin=="Tajikistan"
replace NAME_1="Leninabad" if NAME_1=="Soghd" & origin=="Tajikistan"
replace ID_GADM_fine="TJK1" if NAME_1=="Dushanbe" & origin=="Tajikistan"
replace ID_GADM_fine="TJK2" if NAME_1=="Gorno-Badakhshan" & origin=="Tajikistan"
replace ID_GADM_fine="TJK3" if NAME_1=="Khatlon" & origin=="Tajikistan"
replace ID_GADM_fine="TJK4" if NAME_1=="Leninabad" & origin=="Tajikistan"
replace ID_GADM_fine="TJK5" if NAME_1=="Tadzhikistan Territories" & origin=="Tajikistan"

* TANZANIA
replace NAME_1="Zanzibar South and Central" if NAME_1=="Zanzibar South" & origin=="Tanzania"
replace ID_GADM_fine="TZA1" if NAME_1=="Arusha" & origin=="Tanzania"
replace ID_GADM_fine="TZA2" if NAME_1=="Dar es Salaam" & origin=="Tanzania"
replace ID_GADM_fine="TZA3" if NAME_1=="Dodoma" & origin=="Tanzania"
replace ID_GADM_fine="TZA4" if NAME_1=="Geita" & origin=="Tanzania"
replace ID_GADM_fine="TZA5" if NAME_1=="Iringa" & origin=="Tanzania"
replace ID_GADM_fine="TZA6" if NAME_1=="Kagera" & origin=="Tanzania"
replace ID_GADM_fine="TZA7" if NAME_1=="Katavi" & origin=="Tanzania"
replace ID_GADM_fine="TZA8" if NAME_1=="Kigoma" & origin=="Tanzania"
replace ID_GADM_fine="TZA9" if NAME_1=="Kilimanjaro" & origin=="Tanzania"
replace ID_GADM_fine="TZA10" if NAME_1=="Lindi" & origin=="Tanzania"
replace ID_GADM_fine="TZA11" if NAME_1=="Manyara" & origin=="Tanzania"
replace ID_GADM_fine="TZA12" if NAME_1=="Mara" & origin=="Tanzania"
replace ID_GADM_fine="TZA13" if NAME_1=="Mbeya" & origin=="Tanzania"
replace ID_GADM_fine="TZA14" if NAME_1=="Morogoro" & origin=="Tanzania"
replace ID_GADM_fine="TZA15" if NAME_1=="Mtwara" & origin=="Tanzania"
replace ID_GADM_fine="TZA16" if NAME_1=="Mwanza" & origin=="Tanzania"
replace ID_GADM_fine="TZA17" if NAME_1=="Njombe" & origin=="Tanzania"
replace ID_GADM_fine="TZA18" if NAME_1=="Pemba North" & origin=="Tanzania"
replace ID_GADM_fine="TZA19" if NAME_1=="Pemba South" & origin=="Tanzania"
replace ID_GADM_fine="TZA20" if NAME_1=="Pwani" & origin=="Tanzania"
replace ID_GADM_fine="TZA21" if NAME_1=="Rukwa" & origin=="Tanzania"
replace ID_GADM_fine="TZA22" if NAME_1=="Ruvuma" & origin=="Tanzania"
replace ID_GADM_fine="TZA23" if NAME_1=="Shinyanga" & origin=="Tanzania"
replace ID_GADM_fine="TZA24" if NAME_1=="Simiyu" & origin=="Tanzania"
replace ID_GADM_fine="TZA25" if NAME_1=="Singida" & origin=="Tanzania"
replace ID_GADM_fine="TZA26" if NAME_1=="Tabora" & origin=="Tanzania"
replace ID_GADM_fine="TZA27" if NAME_1=="Tanga" & origin=="Tanzania"
replace ID_GADM_fine="TZA28" if NAME_1=="Zanzibar North" & origin=="Tanzania"
replace ID_GADM_fine="TZA29" if NAME_1=="Zanzibar South and Central" & origin=="Tanzania"
replace ID_GADM_fine="TZA30" if NAME_1=="Zanzibar West" & origin=="Tanzania"

* THAILAND
replace NAME_1="Phra Nakhon Si Ayutthaya" if NAME_1=="Ayutthaya" & origin=="Thailand"
replace NAME_1="Bangkok Metropolis" if NAME_1=="Bangkok" & origin=="Thailand"
replace NAME_1="Bangkok Metropolis" if NAME_1=="Bangkok ( District )" & origin=="Thailand"
replace NAME_1="Bangkok Metropolis" if NAME_1=="Bangkok (District)" & origin=="Thailand"
replace NAME_1="Bangkok Metropolis" if NAME_1=="Bangkok Province" & origin=="Thailand"
replace NAME_1="Sarawak" if NAME_1=="Betong" & origin=="Thailand"
replace origin="Malaysia" if NAME_1=="Sarawak"
replace ID_GADM_fine="MYS14" if NAME_1=="Sarawak" & origin=="Malaysia"
replace NAME_1="Chiang Mai" if NAME_1=="Chaing Mai (Province)" & origin=="Thailand"
replace NAME_1="Chiang Mai" if NAME_1=="Chiang Mai" & origin=="Thailand"
replace NAME_1="Chiang Rai" if NAME_1=="Chiang Rai" & origin=="Thailand"
replace NAME_1="Kamphaeng Phet" if NAME_1=="Kamphaeng Phet (Province)" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Mayo (district), Ban Dan (village)" & origin=="Thailand"
drop if NAME_1=="Muang" & origin=="Thailand" // ambiguous
replace NAME_1="Narathiwat" if NAME_1=="Narathiwat (Provice)" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Narathiwat (Province)" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Narathiwat (province)" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Narathiwat Province" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Narathiwat province" & origin=="Thailand"
replace NAME_1="Pathum Thani" if NAME_1=="Pathum thani" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Pattani ( District )" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Pattani (Provience)" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Pattani (Province)" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Pattani (province)" & origin=="Thailand"
replace NAME_1="Pattani" if NAME_1=="Pattani Province" & origin=="Thailand"
drop if NAME_1=="Pattani and Yala Provinces" & origin=="Thailand" // ambiguous
replace NAME_1="Pattani" if NAME_1=="Pattani province" & origin=="Thailand"
drop if NAME_1=="Pattani, Narathiwat, and Yala" & origin=="Thailand" // ambiguous
drop if NAME_1=="Pattani, Narathiwat, and Yala Provinces" & origin=="Thailand" // ambiguous
replace NAME_1="Pattani" if NAME_1=="Pattini (Province)" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Ra Ngae ( District )" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Rangae" & origin=="Thailand"
replace NAME_1="Ratchaburi" if NAME_1=="Ratchaburi (Province)" & origin=="Thailand"
replace NAME_1="Rayong" if NAME_1=="Rayong (Province)" & origin=="Thailand"
replace NAME_1="Sa Kaeo" if NAME_1=="Sa Kaeo (Province)" & origin=="Thailand"
replace NAME_1="Songkhla" if NAME_1=="Songkhla (Province)" & origin=="Thailand"
replace NAME_1="Songkhla" if NAME_1=="Songkla (Province)" & origin=="Thailand"
drop if NAME_1=="South" & origin=="Thailand" // ambiguous
replace NAME_1="Narathiwat" if NAME_1=="Su-ngai Kolok  District Su-ngai Kolok" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Sungai Kolok" & origin=="Thailand"
replace NAME_1="Narathiwat" if NAME_1=="Sungai Padi ( District )" & origin=="Thailand"
replace NAME_1="Tak" if NAME_1=="Tak (Province)" & origin=="Thailand"
replace NAME_1="Tak" if NAME_1=="Tak Bai ( District )" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Than To" & origin=="Thailand"
replace NAME_1="Trat" if NAME_1=="Trat (Province)" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yaha ( District )" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala  District" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala ( District )" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala (District)" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala (Province)" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala (province)" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala Muang  District" & origin=="Thailand"
replace NAME_1="Yala" if NAME_1=="Yala Province" & origin=="Thailand"
drop if NAME_1=="Yala Province/Muang District" & origin=="Thailand" // ambiguous
drop if NAME_1=="Yala and Pattani Provinces" & origin=="Thailand" // ambiguous
replace NAME_1="Pattani" if NAME_1=="Yarang ( District )" & origin=="Thailand"
replace NAME_1="Khon Kaen" if NAME_1=="khon kaen" & origin=="Thailand"
replace NAME_1="Phayao" if NAME_1=="phayao" & origin=="Thailand"
replace NAME_1="Sakon Nakhon" if NAME_1=="sakon nakhon" & origin=="Thailand"
replace NAME_1="Samut Prakan" if NAME_1=="samut prakan" & origin=="Thailand"
replace ID_GADM_fine="THA1" if NAME_1=="Amnat Charoen" & origin=="Thailand"
replace ID_GADM_fine="THA2" if NAME_1=="Ang Thong" & origin=="Thailand"
replace ID_GADM_fine="THA3" if NAME_1=="Bangkok Metropolis" & origin=="Thailand"
replace ID_GADM_fine="THA4" if NAME_1=="Bueng Kan" & origin=="Thailand"
replace ID_GADM_fine="THA5" if NAME_1=="Buri Ram" & origin=="Thailand"
replace ID_GADM_fine="THA6" if NAME_1=="Chachoengsao" & origin=="Thailand"
replace ID_GADM_fine="THA7" if NAME_1=="Chai Nat" & origin=="Thailand"
replace ID_GADM_fine="THA8" if NAME_1=="Chaiyaphum" & origin=="Thailand"
replace ID_GADM_fine="THA9" if NAME_1=="Chanthaburi" & origin=="Thailand"
replace ID_GADM_fine="THA10" if NAME_1=="Chiang Mai" & origin=="Thailand"
replace ID_GADM_fine="THA11" if NAME_1=="Chiang Rai" & origin=="Thailand"
replace ID_GADM_fine="THA12" if NAME_1=="Chon Buri" & origin=="Thailand"
replace ID_GADM_fine="THA13" if NAME_1=="Chumphon" & origin=="Thailand"
replace ID_GADM_fine="THA14" if NAME_1=="Kalasin" & origin=="Thailand"
replace ID_GADM_fine="THA15" if NAME_1=="Kamphaeng Phet" & origin=="Thailand"
replace ID_GADM_fine="THA16" if NAME_1=="Kanchanaburi" & origin=="Thailand"
replace ID_GADM_fine="THA17" if NAME_1=="Khon Kaen" & origin=="Thailand"
replace ID_GADM_fine="THA18" if NAME_1=="Krabi" & origin=="Thailand"
replace ID_GADM_fine="THA19" if NAME_1=="Lampang" & origin=="Thailand"
replace ID_GADM_fine="THA20" if NAME_1=="Lamphun" & origin=="Thailand"
replace ID_GADM_fine="THA21" if NAME_1=="Loei" & origin=="Thailand"
replace ID_GADM_fine="THA22" if NAME_1=="Lop Buri" & origin=="Thailand"
replace ID_GADM_fine="THA23" if NAME_1=="Mae Hong Son" & origin=="Thailand"
replace ID_GADM_fine="THA24" if NAME_1=="Maha Sarakham" & origin=="Thailand"
replace ID_GADM_fine="THA25" if NAME_1=="Mukdahan" & origin=="Thailand"
replace ID_GADM_fine="THA26" if NAME_1=="Nakhon Nayok" & origin=="Thailand"
replace ID_GADM_fine="THA27" if NAME_1=="Nakhon Pathom" & origin=="Thailand"
replace ID_GADM_fine="THA28" if NAME_1=="Nakhon Phanom" & origin=="Thailand"
replace ID_GADM_fine="THA29" if NAME_1=="Nakhon Ratchasima" & origin=="Thailand"
replace ID_GADM_fine="THA30" if NAME_1=="Nakhon Sawan" & origin=="Thailand"
replace ID_GADM_fine="THA31" if NAME_1=="Nakhon Si Thammarat" & origin=="Thailand"
replace ID_GADM_fine="THA32" if NAME_1=="Nan" & origin=="Thailand"
replace ID_GADM_fine="THA33" if NAME_1=="Narathiwat" & origin=="Thailand"
replace ID_GADM_fine="THA34" if NAME_1=="Nong Bua Lam Phu" & origin=="Thailand"
replace ID_GADM_fine="THA35" if NAME_1=="Nong Khai" & origin=="Thailand"
replace ID_GADM_fine="THA36" if NAME_1=="Nonthaburi" & origin=="Thailand"
replace ID_GADM_fine="THA37" if NAME_1=="Pathum Thani" & origin=="Thailand"
replace ID_GADM_fine="THA38" if NAME_1=="Pattani" & origin=="Thailand"
replace ID_GADM_fine="THA39" if NAME_1=="Phangnga" & origin=="Thailand"
replace ID_GADM_fine="THA40" if NAME_1=="Phatthalung" & origin=="Thailand"
replace ID_GADM_fine="THA41" if NAME_1=="Phayao" & origin=="Thailand"
replace ID_GADM_fine="THA42" if NAME_1=="Phetchabun" & origin=="Thailand"
replace ID_GADM_fine="THA43" if NAME_1=="Phetchaburi" & origin=="Thailand"
replace ID_GADM_fine="THA44" if NAME_1=="Phichit" & origin=="Thailand"
replace ID_GADM_fine="THA45" if NAME_1=="Phitsanulok" & origin=="Thailand"
replace ID_GADM_fine="THA46" if NAME_1=="Phra Nakhon Si Ayutthaya" & origin=="Thailand"
replace ID_GADM_fine="THA47" if NAME_1=="Phrae" & origin=="Thailand"
replace ID_GADM_fine="THA48" if NAME_1=="Phuket" & origin=="Thailand"
replace ID_GADM_fine="THA49" if NAME_1=="Prachin Buri" & origin=="Thailand"
replace ID_GADM_fine="THA50" if NAME_1=="Prachuap Khiri Khan" & origin=="Thailand"
replace ID_GADM_fine="THA51" if NAME_1=="Ranong" & origin=="Thailand"
replace ID_GADM_fine="THA52" if NAME_1=="Ratchaburi" & origin=="Thailand"
replace ID_GADM_fine="THA53" if NAME_1=="Rayong" & origin=="Thailand"
replace ID_GADM_fine="THA54" if NAME_1=="Roi Et" & origin=="Thailand"
replace ID_GADM_fine="THA55" if NAME_1=="Sa Kaeo" & origin=="Thailand"
replace ID_GADM_fine="THA56" if NAME_1=="Sakon Nakhon" & origin=="Thailand"
replace ID_GADM_fine="THA57" if NAME_1=="Samut Prakan" & origin=="Thailand"
replace ID_GADM_fine="THA58" if NAME_1=="Samut Sakhon" & origin=="Thailand"
replace ID_GADM_fine="THA59" if NAME_1=="Samut Songkhram" & origin=="Thailand"
replace ID_GADM_fine="THA60" if NAME_1=="Saraburi" & origin=="Thailand"
replace ID_GADM_fine="THA61" if NAME_1=="Satun" & origin=="Thailand"
replace ID_GADM_fine="THA62" if NAME_1=="Si Sa Ket" & origin=="Thailand"
replace ID_GADM_fine="THA63" if NAME_1=="Sing Buri" & origin=="Thailand"
replace ID_GADM_fine="THA64" if NAME_1=="Songkhla" & origin=="Thailand"
replace ID_GADM_fine="THA65" if NAME_1=="Sukhothai" & origin=="Thailand"
replace ID_GADM_fine="THA66" if NAME_1=="Suphan Buri" & origin=="Thailand"
replace ID_GADM_fine="THA67" if NAME_1=="Surat Thani" & origin=="Thailand"
replace ID_GADM_fine="THA68" if NAME_1=="Surin" & origin=="Thailand"
replace ID_GADM_fine="THA69" if NAME_1=="Tak" & origin=="Thailand"
replace ID_GADM_fine="THA70" if NAME_1=="Trang" & origin=="Thailand"
replace ID_GADM_fine="THA71" if NAME_1=="Trat" & origin=="Thailand"
replace ID_GADM_fine="THA72" if NAME_1=="Ubon Ratchathani" & origin=="Thailand"
replace ID_GADM_fine="THA73" if NAME_1=="Udon Thani" & origin=="Thailand"
replace ID_GADM_fine="THA74" if NAME_1=="Uthai Thani" & origin=="Thailand"
replace ID_GADM_fine="THA75" if NAME_1=="Uttaradit" & origin=="Thailand"
replace ID_GADM_fine="THA76" if NAME_1=="Yala" & origin=="Thailand"
replace ID_GADM_fine="THA77" if NAME_1=="Yasothon" & origin=="Thailand"

* TOGO
replace ID_GADM_fine="TGO1" if NAME_1=="Centre" & origin=="Togo"
replace ID_GADM_fine="TGO2" if NAME_1=="Kara" & origin=="Togo"
replace ID_GADM_fine="TGO3" if NAME_1=="Maritime" & origin=="Togo"
replace ID_GADM_fine="TGO4" if NAME_1=="Plateaux" & origin=="Togo"
replace ID_GADM_fine="TGO5" if NAME_1=="Savanes" & origin=="Togo"

* TRINIDAD AND TOBAGO
replace NAME_1="Port of Spain" if NAME_1=="Port of Spain (Municipality)" & origin=="Trinidad and Tobago"
replace NAME_1="Port of Spain" if NAME_1=="Port-of-Spain City Corporation" & origin=="Trinidad and Tobago"
replace NAME_1="Sangre Grande" if NAME_1=="Sangre Grande Regional Corporation" & origin=="Trinidad and Tobago"
replace NAME_1="Sangre Grande" if NAME_1=="Sangre Grande Regional Corporation" & origin=="Trinidad and Tobago"
drop if NAME_1=="Tobago" & origin=="Trinidad and Tobago"
replace NAME_1="Tunapuna/Piarco" if NAME_1=="Tunapuna-Piarco" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO1" if NAME_1=="Arima" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO2" if NAME_1=="Chaguanas" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO3" if NAME_1=="Couva/Tabaquite/Talparo" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO4" if NAME_1=="Diego Martin" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO5" if NAME_1=="Mayaro/Rio Claro" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO6" if NAME_1=="Penal/Debe" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO7" if NAME_1=="Point Fortin" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO8" if NAME_1=="Port of Spain" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO9" if NAME_1=="Princess Town" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO10" if NAME_1=="San Fernando" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO11" if NAME_1=="San Juan/Laventille" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO12" if NAME_1=="Sangre Grande" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO13" if NAME_1=="Siparia" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO14" if NAME_1=="Tobago St. Andrew" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO15" if NAME_1=="Tobago St. David" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO16" if NAME_1=="Tobago St. Mary" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO17" if NAME_1=="Tobago St. Patrick" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO18" if NAME_1=="Tobago St. Paul" & origin=="Trinidad and Tobago"
replace ID_GADM_fine="TTO19" if NAME_1=="Tunapuna/Piarco" & origin=="Trinidad and Tobago"

* TUNISIA
replace NAME_1="Béja" if NAME_1=="Beja" & origin=="Tunisia"
replace NAME_1="Ben Arous (Tunis Sud)" if NAME_1=="Ben Arous" & origin=="Tunisia"
replace NAME_1="Bizerte" if NAME_1=="Bizerte" & origin=="Tunisia"
replace NAME_1="Médenine" if NAME_1=="Djerba" & origin=="Tunisia"
replace NAME_1="Gabès" if NAME_1=="Gabes" & origin=="Tunisia"
replace NAME_1="Kassérine" if NAME_1=="Kasserine" & origin=="Tunisia"
replace NAME_1="Le Kef" if NAME_1=="Kef" & origin=="Tunisia"
replace NAME_1="Manubah" if NAME_1=="Manouba" & origin=="Tunisia"
replace NAME_1="Médenine" if NAME_1=="Medenine" & origin=="Tunisia"
replace NAME_1="Médenine" if NAME_1=="Medenine Governorate" & origin=="Tunisia"
replace NAME_1="Médenine" if NAME_1=="Medenine Governorate" & origin=="Tunisia"
replace NAME_1="Nabeul" if NAME_1=="Nabuel (Region)" & origin=="Tunisia"
replace NAME_1="Sidi Bou Zid" if NAME_1=="Sidi Bouzid" & origin=="Tunisia"
replace NAME_1="Siliana" if NAME_1=="Siliana" & origin=="Tunisia"
replace NAME_1="Tunis" if NAME_1=="Tunis (Governorate)" & origin=="Tunisia"
replace NAME_1="Zaghouan" if NAME_1=="Zaghouan" & origin=="Tunisia"
replace ID_GADM_fine="TUN1" if NAME_1=="Ariana" & origin=="Tunisia"
replace ID_GADM_fine="TUN2" if NAME_1=="Béja" & origin=="Tunisia"
replace ID_GADM_fine="TUN3" if NAME_1=="Ben Arous (Tunis Sud)" & origin=="Tunisia"
replace ID_GADM_fine="TUN4" if NAME_1=="Bizerte" & origin=="Tunisia"
replace ID_GADM_fine="TUN5" if NAME_1=="Gabès" & origin=="Tunisia"
replace ID_GADM_fine="TUN6" if NAME_1=="Gafsa" & origin=="Tunisia"
replace ID_GADM_fine="TUN7" if NAME_1=="Jendouba" & origin=="Tunisia"
replace ID_GADM_fine="TUN8" if NAME_1=="Kairouan" & origin=="Tunisia"
replace ID_GADM_fine="TUN9" if NAME_1=="Kassérine" & origin=="Tunisia"
replace ID_GADM_fine="TUN10" if NAME_1=="Kebili" & origin=="Tunisia"
replace ID_GADM_fine="TUN11" if NAME_1=="Le Kef" & origin=="Tunisia"
replace ID_GADM_fine="TUN12" if NAME_1=="Mahdia" & origin=="Tunisia"
replace ID_GADM_fine="TUN13" if NAME_1=="Manubah" & origin=="Tunisia"
replace ID_GADM_fine="TUN14" if NAME_1=="Médenine" & origin=="Tunisia"
replace ID_GADM_fine="TUN15" if NAME_1=="Monastir" & origin=="Tunisia"
replace ID_GADM_fine="TUN16" if NAME_1=="Nabeul" & origin=="Tunisia"
replace ID_GADM_fine="TUN17" if NAME_1=="Sfax" & origin=="Tunisia"
replace ID_GADM_fine="TUN18" if NAME_1=="Sidi Bou Zid" & origin=="Tunisia"
replace ID_GADM_fine="TUN19" if NAME_1=="Siliana" & origin=="Tunisia"
replace ID_GADM_fine="TUN20" if NAME_1=="Sousse" & origin=="Tunisia"
replace ID_GADM_fine="TUN21" if NAME_1=="Tataouine" & origin=="Tunisia"
replace ID_GADM_fine="TUN22" if NAME_1=="Tozeur" & origin=="Tunisia"
replace ID_GADM_fine="TUN23" if NAME_1=="Tunis" & origin=="Tunisia"
replace ID_GADM_fine="TUN24" if NAME_1=="Zaghouan" & origin=="Tunisia"

* TURKEY
replace NAME_1="Bingöl" if NAME_1=="Bingol" & origin=="Turkey"
replace NAME_1="Elazığ" if NAME_1=="Elazig" & origin=="Turkey"
replace NAME_1="Gümüshane" if NAME_1=="Gumushane" & origin=="Turkey"
replace NAME_1="Iğdır" if NAME_1=="Igdir" & origin=="Turkey"
replace NAME_1="K. Maras" if NAME_1=="Kahramanmaras" & origin=="Turkey"
replace NAME_1="Kinkkale" if NAME_1=="Kirikkale" & origin=="Turkey"
replace ID_GADM_fine="TUR1" if NAME_1=="Adana" & origin=="Turkey"
replace ID_GADM_fine="TUR2" if NAME_1=="Adiyaman" & origin=="Turkey"
replace ID_GADM_fine="TUR3" if NAME_1=="Afyon" & origin=="Turkey"
replace ID_GADM_fine="TUR4" if NAME_1=="Agri" & origin=="Turkey"
replace ID_GADM_fine="TUR5" if NAME_1=="Aksaray" & origin=="Turkey"
replace ID_GADM_fine="TUR6" if NAME_1=="Amasya" & origin=="Turkey"
replace ID_GADM_fine="TUR7" if NAME_1=="Ankara" & origin=="Turkey"
replace ID_GADM_fine="TUR8" if NAME_1=="Antalya" & origin=="Turkey"
replace ID_GADM_fine="TUR9" if NAME_1=="Ardahan" & origin=="Turkey"
replace ID_GADM_fine="TUR10" if NAME_1=="Artvin" & origin=="Turkey"
replace ID_GADM_fine="TUR11" if NAME_1=="Aydin" & origin=="Turkey"
replace ID_GADM_fine="TUR12" if NAME_1=="Balikesir" & origin=="Turkey"
replace ID_GADM_fine="TUR13" if NAME_1=="Bartın" & origin=="Turkey"
replace ID_GADM_fine="TUR14" if NAME_1=="Batman" & origin=="Turkey"
replace ID_GADM_fine="TUR15" if NAME_1=="Bayburt" & origin=="Turkey"
replace ID_GADM_fine="TUR16" if NAME_1=="Bilecik" & origin=="Turkey"
replace ID_GADM_fine="TUR17" if NAME_1=="Bingöl" & origin=="Turkey"
replace ID_GADM_fine="TUR18" if NAME_1=="Bitlis" & origin=="Turkey"
replace ID_GADM_fine="TUR19" if NAME_1=="Bolu" & origin=="Turkey"
replace ID_GADM_fine="TUR20" if NAME_1=="Burdur" & origin=="Turkey"
replace ID_GADM_fine="TUR21" if NAME_1=="Bursa" & origin=="Turkey"
replace ID_GADM_fine="TUR22" if NAME_1=="Çanakkale" & origin=="Turkey"
replace ID_GADM_fine="TUR23" if NAME_1=="Çankiri" & origin=="Turkey"
replace ID_GADM_fine="TUR24" if NAME_1=="Çorum" & origin=="Turkey"
replace ID_GADM_fine="TUR25" if NAME_1=="Denizli" & origin=="Turkey"
replace ID_GADM_fine="TUR26" if NAME_1=="Diyarbakir" & origin=="Turkey"
replace ID_GADM_fine="TUR27" if NAME_1=="Düzce" & origin=="Turkey"
replace ID_GADM_fine="TUR28" if NAME_1=="Edirne" & origin=="Turkey"
replace ID_GADM_fine="TUR29" if NAME_1=="Elazığ" & origin=="Turkey"
replace ID_GADM_fine="TUR30" if NAME_1=="Erzincan" & origin=="Turkey"
replace ID_GADM_fine="TUR31" if NAME_1=="Erzurum" & origin=="Turkey"
replace ID_GADM_fine="TUR32" if NAME_1=="Eskisehir" & origin=="Turkey"
replace ID_GADM_fine="TUR33" if NAME_1=="Gaziantep" & origin=="Turkey"
replace ID_GADM_fine="TUR34" if NAME_1=="Giresun" & origin=="Turkey"
replace ID_GADM_fine="TUR35" if NAME_1=="Gümüshane" & origin=="Turkey"
replace ID_GADM_fine="TUR36" if NAME_1=="Hakkari" & origin=="Turkey"
replace ID_GADM_fine="TUR37" if NAME_1=="Hatay" & origin=="Turkey"
replace ID_GADM_fine="TUR38" if NAME_1=="Iğdır" & origin=="Turkey"
replace ID_GADM_fine="TUR39" if NAME_1=="Isparta" & origin=="Turkey"
replace ID_GADM_fine="TUR40" if NAME_1=="Istanbul" & origin=="Turkey"
replace ID_GADM_fine="TUR41" if NAME_1=="Izmir" & origin=="Turkey"
replace ID_GADM_fine="TUR42" if NAME_1=="K. Maras" & origin=="Turkey"
replace ID_GADM_fine="TUR43" if NAME_1=="Karabük" & origin=="Turkey"
replace ID_GADM_fine="TUR44" if NAME_1=="Karaman" & origin=="Turkey"
replace ID_GADM_fine="TUR45" if NAME_1=="Kars" & origin=="Turkey"
replace ID_GADM_fine="TUR46" if NAME_1=="Kastamonu" & origin=="Turkey"
replace ID_GADM_fine="TUR47" if NAME_1=="Kayseri" & origin=="Turkey"
replace ID_GADM_fine="TUR48" if NAME_1=="Kilis" & origin=="Turkey"
replace ID_GADM_fine="TUR49" if NAME_1=="Kinkkale" & origin=="Turkey"
replace ID_GADM_fine="TUR50" if NAME_1=="Kirklareli" & origin=="Turkey"
replace ID_GADM_fine="TUR51" if NAME_1=="Kirsehir" & origin=="Turkey"
replace ID_GADM_fine="TUR52" if NAME_1=="Kocaeli" & origin=="Turkey"
replace ID_GADM_fine="TUR53" if NAME_1=="Konya" & origin=="Turkey"
replace ID_GADM_fine="TUR54" if NAME_1=="Kütahya" & origin=="Turkey"
replace ID_GADM_fine="TUR55" if NAME_1=="Malatya" & origin=="Turkey"
replace ID_GADM_fine="TUR56" if NAME_1=="Manisa" & origin=="Turkey"
replace ID_GADM_fine="TUR57" if NAME_1=="Mardin" & origin=="Turkey"
replace ID_GADM_fine="TUR58" if NAME_1=="Mersin" & origin=="Turkey"
replace ID_GADM_fine="TUR59" if NAME_1=="Mugla" & origin=="Turkey"
replace ID_GADM_fine="TUR60" if NAME_1=="Mus" & origin=="Turkey"
replace ID_GADM_fine="TUR61" if NAME_1=="Nevsehir" & origin=="Turkey"
replace ID_GADM_fine="TUR62" if NAME_1=="Nigde" & origin=="Turkey"
replace ID_GADM_fine="TUR63" if NAME_1=="Ordu" & origin=="Turkey"
replace ID_GADM_fine="TUR64" if NAME_1=="Osmaniye" & origin=="Turkey"
replace ID_GADM_fine="TUR65" if NAME_1=="Rize" & origin=="Turkey"
replace ID_GADM_fine="TUR66" if NAME_1=="Sakarya" & origin=="Turkey"
replace ID_GADM_fine="TUR67" if NAME_1=="Samsun" & origin=="Turkey"
replace ID_GADM_fine="TUR68" if NAME_1=="Sanliurfa" & origin=="Turkey"
replace ID_GADM_fine="TUR69" if NAME_1=="Siirt" & origin=="Turkey"
replace ID_GADM_fine="TUR70" if NAME_1=="Sinop" & origin=="Turkey"
replace ID_GADM_fine="TUR71" if NAME_1=="Sirnak" & origin=="Turkey"
replace ID_GADM_fine="TUR72" if NAME_1=="Sivas" & origin=="Turkey"
replace ID_GADM_fine="TUR73" if NAME_1=="Tekirdag" & origin=="Turkey"
replace ID_GADM_fine="TUR74" if NAME_1=="Tokat" & origin=="Turkey"
replace ID_GADM_fine="TUR75" if NAME_1=="Trabzon" & origin=="Turkey"
replace ID_GADM_fine="TUR76" if NAME_1=="Tunceli" & origin=="Turkey"
replace ID_GADM_fine="TUR77" if NAME_1=="Usak" & origin=="Turkey"
replace ID_GADM_fine="TUR78" if NAME_1=="Van" & origin=="Turkey"
replace ID_GADM_fine="TUR79" if NAME_1=="Yalova" & origin=="Turkey"
replace ID_GADM_fine="TUR80" if NAME_1=="Yozgat" & origin=="Turkey"
replace ID_GADM_fine="TUR81" if NAME_1=="Zinguldak" & origin=="Turkey"

* TURKMENISTAN
replace NAME_1="Ashgabat City" if NAME_1=="Ashgabat" & origin=="Turkmenistan"
replace NAME_1="Mary Province" if NAME_1=="Mary" & origin=="Turkmenistan"
replace ID_GADM_fine="TKM1" if NAME_1=="Ashgabat City" & origin=="Turkmenistan"
replace ID_GADM_fine="TKM5" if NAME_1=="Mary Province" & origin=="Turkmenistan"

* UGANDA // Not the same classification than in GADM --> drop
drop if origin=="Uganda"

* UKRAINE
replace NAME_1="Dnipropetrovs'k" if NAME_1=="Dnipropetrovsk" & origin=="Ukraine"
replace NAME_1="Rostov" if NAME_1=="Donetsk" & origin=="Ukraine"
replace NAME_1="Rostov" if NAME_1=="Donetsk Oblast" & origin=="Ukraine"
replace origin="Russia" if NAME_1=="Rostov"
replace ID_GADM_fine="RUS58" if NAME_1=="Rostov" & origin=="Russia"
replace NAME_1="Ivano-Frankivs'k" if NAME_1=="Ivano-Frankivsk" & origin=="Ukraine"
replace NAME_1="Kiev City" if NAME_1=="Kiev City Municipality" & origin=="Ukraine"
replace NAME_1="Kharkiv" if NAME_1=="Kyivska" & origin=="Ukraine"
replace NAME_1="Luhans'k" if NAME_1=="Luhansk" & origin=="Ukraine"
replace NAME_1="Luhans'k" if NAME_1=="Luhansk Oblast" & origin=="Ukraine"
replace NAME_1="L'viv" if NAME_1=="Lviv" & origin=="Ukraine"
replace NAME_1="Odessa" if NAME_1=="Odessa (Oblast)" & origin=="Ukraine"
drop if NAME_1=="Roztochia Upland" & origin=="Ukraine"
replace NAME_1="Sevastopol'" if NAME_1=="Sevastopol" & origin=="Ukraine"
drop if NAME_1=="Ukraine" & origin=="Ukraine"
drop if NAME_1=="Zakarpattia" & origin=="Ukraine"
drop if NAME_1=="Zakarpattia (Oblast)" & origin=="Ukraine"
drop if NAME_1=="Zaporizhzhya" & origin=="Ukraine"
replace ID_GADM_fine="UKR1" if NAME_1=="Cherkasy" & origin=="Ukraine"
replace ID_GADM_fine="UKR2" if NAME_1=="Chernihiv" & origin=="Ukraine"
replace ID_GADM_fine="UKR3" if NAME_1=="Chernivtsi" & origin=="Ukraine"
replace ID_GADM_fine="UKR4" if NAME_1=="Crimea" & origin=="Ukraine"
replace ID_GADM_fine="UKR5" if NAME_1=="Dnipropetrovs'k" & origin=="Ukraine"
replace ID_GADM_fine="UKR6" if NAME_1=="Donets'k" & origin=="Ukraine"
replace ID_GADM_fine="UKR7" if NAME_1=="Ivano-Frankivs'k" & origin=="Ukraine"
replace ID_GADM_fine="UKR8" if NAME_1=="Kharkiv" & origin=="Ukraine"
replace ID_GADM_fine="UKR9" if NAME_1=="Kherson" & origin=="Ukraine"
replace ID_GADM_fine="UKR10" if NAME_1=="Khmel'nyts'kyy" & origin=="Ukraine"
replace ID_GADM_fine="UKR11" if NAME_1=="Kiev City" & origin=="Ukraine"
replace ID_GADM_fine="UKR12" if NAME_1=="Kiev" & origin=="Ukraine"
replace ID_GADM_fine="UKR13" if NAME_1=="Kirovohrad" & origin=="Ukraine"
replace ID_GADM_fine="UKR14" if NAME_1=="L'viv" & origin=="Ukraine"
replace ID_GADM_fine="UKR15" if NAME_1=="Luhans'k" & origin=="Ukraine"
replace ID_GADM_fine="UKR16" if NAME_1=="Mykolayiv" & origin=="Ukraine"
replace ID_GADM_fine="UKR17" if NAME_1=="Odessa" & origin=="Ukraine"
replace ID_GADM_fine="UKR18" if NAME_1=="Poltava" & origin=="Ukraine"
replace ID_GADM_fine="UKR19" if NAME_1=="Rivne" & origin=="Ukraine"
replace ID_GADM_fine="UKR20" if NAME_1=="Sevastopol'" & origin=="Ukraine"
replace ID_GADM_fine="UKR21" if NAME_1=="Sumy" & origin=="Ukraine"
replace ID_GADM_fine="UKR22" if NAME_1=="Ternopil'" & origin=="Ukraine"
replace ID_GADM_fine="UKR23" if NAME_1=="Transcarpathia" & origin=="Ukraine"
replace ID_GADM_fine="UKR24" if NAME_1=="Vinnytsya" & origin=="Ukraine"
replace ID_GADM_fine="UKR25" if NAME_1=="Volyn" & origin=="Ukraine"
replace ID_GADM_fine="UKR26" if NAME_1=="Zaporizhzhya" & origin=="Ukraine"
replace ID_GADM_fine="UKR27" if NAME_1=="Zhytomyr" & origin=="Ukraine"

* UNITED ARAB EMIRATES
replace ID_GADM_fine="ARE1" if NAME_1=="Abu Dhabi" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE2" if NAME_1=="Ajman" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE3" if NAME_1=="Dubai" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE4" if NAME_1=="Fujairah" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE5" if NAME_1=="Ras Al-Khaimah" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE6" if NAME_1=="Sharjah" & origin=="United Arab Emirates"
replace ID_GADM_fine="ARE7" if NAME_1=="Umm al-Qaywayn" & origin=="United Arab Emirates"

* UNITED KINGDOM
replace ID_GADM_fine="GBR1" if NAME_1=="England" & origin=="United Kingdom"
replace ID_GADM_fine="GBR2" if NAME_1=="Northern Ireland" & origin=="United Kingdom"
replace ID_GADM_fine="GBR3" if NAME_1=="Scotland" & origin=="United Kingdom"
replace ID_GADM_fine="GBR4" if NAME_1=="Wales" & origin=="United Kingdom"

* UNITED STATES
drop if NAME_1=="Puerto Rico" & origin=="United States"
replace ID_GADM_fine="USA1" if NAME_1=="Alabama" & origin=="United States"
replace ID_GADM_fine="USA2" if NAME_1=="Alaska" & origin=="United States"
replace ID_GADM_fine="USA3" if NAME_1=="Arizona" & origin=="United States"
replace ID_GADM_fine="USA4" if NAME_1=="Arkansas" & origin=="United States"
replace ID_GADM_fine="USA5" if NAME_1=="California" & origin=="United States"
replace ID_GADM_fine="USA6" if NAME_1=="Colorado" & origin=="United States"
replace ID_GADM_fine="USA7" if NAME_1=="Connecticut" & origin=="United States"
replace ID_GADM_fine="USA8" if NAME_1=="Delaware" & origin=="United States"
replace ID_GADM_fine="USA9" if NAME_1=="District of Columbia" & origin=="United States"
replace ID_GADM_fine="USA10" if NAME_1=="Florida" & origin=="United States"
replace ID_GADM_fine="USA11" if NAME_1=="Georgia" & origin=="United States"
replace ID_GADM_fine="USA12" if NAME_1=="Hawaii" & origin=="United States"
replace ID_GADM_fine="USA13" if NAME_1=="Idaho" & origin=="United States"
replace ID_GADM_fine="USA14" if NAME_1=="Illinois" & origin=="United States"
replace ID_GADM_fine="USA15" if NAME_1=="Indiana" & origin=="United States"
replace ID_GADM_fine="USA16" if NAME_1=="Iowa" & origin=="United States"
replace ID_GADM_fine="USA17" if NAME_1=="Kansas" & origin=="United States"
replace ID_GADM_fine="USA18" if NAME_1=="Kentucky" & origin=="United States"
replace ID_GADM_fine="USA19" if NAME_1=="Louisiana" & origin=="United States"
replace ID_GADM_fine="USA20" if NAME_1=="Maine" & origin=="United States"
replace ID_GADM_fine="USA21" if NAME_1=="Maryland" & origin=="United States"
replace ID_GADM_fine="USA22" if NAME_1=="Massachusetts" & origin=="United States"
replace ID_GADM_fine="USA23" if NAME_1=="Michigan" & origin=="United States"
replace ID_GADM_fine="USA24" if NAME_1=="Minnesota" & origin=="United States"
replace ID_GADM_fine="USA25" if NAME_1=="Mississippi" & origin=="United States"
replace ID_GADM_fine="USA26" if NAME_1=="Missouri" & origin=="United States"
replace ID_GADM_fine="USA27" if NAME_1=="Montana" & origin=="United States"
replace ID_GADM_fine="USA28" if NAME_1=="Nebraska" & origin=="United States"
replace ID_GADM_fine="USA29" if NAME_1=="Nevada" & origin=="United States"
replace ID_GADM_fine="USA30" if NAME_1=="New Hampshire" & origin=="United States"
replace ID_GADM_fine="USA31" if NAME_1=="New Jersey" & origin=="United States"
replace ID_GADM_fine="USA32" if NAME_1=="New Mexico" & origin=="United States"
replace ID_GADM_fine="USA33" if NAME_1=="New York" & origin=="United States"
replace ID_GADM_fine="USA34" if NAME_1=="North Carolina" & origin=="United States"
replace ID_GADM_fine="USA35" if NAME_1=="North Dakota" & origin=="United States"
replace ID_GADM_fine="USA36" if NAME_1=="Ohio" & origin=="United States"
replace ID_GADM_fine="USA37" if NAME_1=="Oklahoma" & origin=="United States"
replace ID_GADM_fine="USA38" if NAME_1=="Oregon" & origin=="United States"
replace ID_GADM_fine="USA39" if NAME_1=="Pennsylvania" & origin=="United States"
replace ID_GADM_fine="USA40" if NAME_1=="Rhode Island" & origin=="United States"
replace ID_GADM_fine="USA41" if NAME_1=="South Carolina" & origin=="United States"
replace ID_GADM_fine="USA42" if NAME_1=="South Dakota" & origin=="United States"
replace ID_GADM_fine="USA43" if NAME_1=="Tennessee" & origin=="United States"
replace ID_GADM_fine="USA44" if NAME_1=="Texas" & origin=="United States"
replace ID_GADM_fine="USA45" if NAME_1=="Utah" & origin=="United States"
replace ID_GADM_fine="USA46" if NAME_1=="Vermont" & origin=="United States"
replace ID_GADM_fine="USA47" if NAME_1=="Virginia" & origin=="United States"
replace ID_GADM_fine="USA48" if NAME_1=="Washington" & origin=="United States"
replace ID_GADM_fine="USA49" if NAME_1=="West Virginia" & origin=="United States"
replace ID_GADM_fine="USA50" if NAME_1=="Wisconsin" & origin=="United States"
replace ID_GADM_fine="USA51" if NAME_1=="Wyoming" & origin=="United States"

* URUGUAY
replace NAME_1="Paysandú" if NAME_1=="Paysandu" & origin=="Uruguay"
replace ID_GADM_fine="URY11" if NAME_1=="Paysandú" & origin=="Uruguay"

* UZBEKISTAN
replace NAME_1="Andijon" if NAME_1=="Andijon (Province)" & origin=="Uzbekistan"
replace NAME_1="Tashkent" if NAME_1=="Tashkent (Capital City)" & origin=="Uzbekistan"
replace NAME_1="Tashkent" if NAME_1=="Tashkent (Province)" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB1" if NAME_1=="Andijon" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB2" if NAME_1=="Andijon" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB3" if NAME_1=="Bukhoro" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB4" if NAME_1=="Ferghana" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB5" if NAME_1=="Jizzakh" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB6" if NAME_1=="Karakalpakstan" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB7" if NAME_1=="Kashkadarya" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB8" if NAME_1=="Khorezm" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB9" if NAME_1=="Namangan" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB10" if NAME_1=="Navoi" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB11" if NAME_1=="Samarkand" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB12" if NAME_1=="Sirdaryo" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB13" if NAME_1=="Surkhandarya" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB14" if NAME_1=="Tashkent" & origin=="Uzbekistan"
replace ID_GADM_fine="UZB15" if NAME_1=="Tashkent City" & origin=="Uzbekistan"

* VENEZUELA
replace NAME_1="Anzoátegui" if NAME_1=="Anzoategui" & origin=="Venezuela"
replace NAME_1="Carabobo" if NAME_1=="Cababobo" & origin=="Venezuela"
replace NAME_1="Distrito Capital" if NAME_1=="Capital" & origin=="Venezuela"
replace NAME_1="Distrito Capital" if NAME_1=="Caracas" & origin=="Venezuela"
replace NAME_1="Guárico" if NAME_1=="Guarico" & origin=="Venezuela"
replace NAME_1="Táchira" if NAME_1=="Tachira" & origin=="Venezuela"
replace ID_GADM_fine="VEN1" if NAME_1=="Amazonas" & origin=="Venezuela"
replace ID_GADM_fine="VEN2" if NAME_1=="Anzoátegui" & origin=="Venezuela"
replace ID_GADM_fine="VEN3" if NAME_1=="Apure" & origin=="Venezuela"
replace ID_GADM_fine="VEN4" if NAME_1=="Aragua" & origin=="Venezuela"
replace ID_GADM_fine="VEN5" if NAME_1=="Barinas" & origin=="Venezuela"
replace ID_GADM_fine="VEN6" if NAME_1=="Bolívar" & origin=="Venezuela"
replace ID_GADM_fine="VEN7" if NAME_1=="Carabobo" & origin=="Venezuela"
replace ID_GADM_fine="VEN8" if NAME_1=="Cojedes" & origin=="Venezuela"
replace ID_GADM_fine="VEN9" if NAME_1=="Delta Amacuro" & origin=="Venezuela"
replace ID_GADM_fine="VEN10" if NAME_1=="Dependencias Federales" & origin=="Venezuela"
replace ID_GADM_fine="VEN11" if NAME_1=="Distrito Capital" & origin=="Venezuela"
replace ID_GADM_fine="VEN12" if NAME_1=="Falcón" & origin=="Venezuela"
replace ID_GADM_fine="VEN13" if NAME_1=="Guárico" & origin=="Venezuela"
replace ID_GADM_fine="VEN14" if NAME_1=="Lara" & origin=="Venezuela"
replace ID_GADM_fine="VEN15" if NAME_1=="Mérida" & origin=="Venezuela"
replace ID_GADM_fine="VEN16" if NAME_1=="Miranda" & origin=="Venezuela"
replace ID_GADM_fine="VEN17" if NAME_1=="Monagas" & origin=="Venezuela"
replace ID_GADM_fine="VEN18" if NAME_1=="Nueva Esparta" & origin=="Venezuela"
replace ID_GADM_fine="VEN19" if NAME_1=="Portuguesa" & origin=="Venezuela"
replace ID_GADM_fine="VEN20" if NAME_1=="Sucre" & origin=="Venezuela"
replace ID_GADM_fine="VEN21" if NAME_1=="Táchira" & origin=="Venezuela"
replace ID_GADM_fine="VEN22" if NAME_1=="Trujillo" & origin=="Venezuela"
replace ID_GADM_fine="VEN23" if NAME_1=="Vargas" & origin=="Venezuela"
replace ID_GADM_fine="VEN24" if NAME_1=="Yaracuy" & origin=="Venezuela"
replace ID_GADM_fine="VEN25" if NAME_1=="Zulia" & origin=="Venezuela"

* VIETNAM
replace NAME_1="Đắk Lắk" if NAME_1=="Dak Lak (Province)" & origin=="Vietnam"
replace ID_GADM_fine="VNM1" if NAME_1=="An Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM2" if NAME_1=="Bạc Liêu" & origin=="Vietnam"
replace ID_GADM_fine="VNM3" if NAME_1=="Bắc Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM4" if NAME_1=="Bắc Kạn" & origin=="Vietnam"
replace ID_GADM_fine="VNM5" if NAME_1=="Bắc Ninh" & origin=="Vietnam"
replace ID_GADM_fine="VNM6" if NAME_1=="Bến Tre" & origin=="Vietnam"
replace ID_GADM_fine="VNM7" if NAME_1=="Bà Rịa - Vũng Tàu" & origin=="Vietnam"
replace ID_GADM_fine="VNM8" if NAME_1=="Bình Định" & origin=="Vietnam"
replace ID_GADM_fine="VNM9" if NAME_1=="Bình Dương" & origin=="Vietnam"
replace ID_GADM_fine="VNM10" if NAME_1=="Bình Phước" & origin=="Vietnam"
replace ID_GADM_fine="VNM11" if NAME_1=="Bình Thuận" & origin=="Vietnam"
replace ID_GADM_fine="VNM12" if NAME_1=="Cần Thơ" & origin=="Vietnam"
replace ID_GADM_fine="VNM13" if NAME_1=="Cà Mau" & origin=="Vietnam"
replace ID_GADM_fine="VNM14" if NAME_1=="Cao Bằng" & origin=="Vietnam"
replace ID_GADM_fine="VNM15" if NAME_1=="Đắk Lắk" & origin=="Vietnam"
replace ID_GADM_fine="VNM16" if NAME_1=="Đắk Nông" & origin=="Vietnam"
replace ID_GADM_fine="VNM17" if NAME_1=="Đồng Nai" & origin=="Vietnam"
replace ID_GADM_fine="VNM18" if NAME_1=="Đồng Tháp" & origin=="Vietnam"
replace ID_GADM_fine="VNM19" if NAME_1=="Đà Nẵng" & origin=="Vietnam"
replace ID_GADM_fine="VNM20" if NAME_1=="Điện Biên" & origin=="Vietnam"
replace ID_GADM_fine="VNM21" if NAME_1=="Gia Lai" & origin=="Vietnam"
replace ID_GADM_fine="VNM22" if NAME_1=="Hải Dương" & origin=="Vietnam"
replace ID_GADM_fine="VNM23" if NAME_1=="Hải Phòng" & origin=="Vietnam"
replace ID_GADM_fine="VNM24" if NAME_1=="Hậu Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM25" if NAME_1=="Hồ Chí Minh" & origin=="Vietnam"
replace ID_GADM_fine="VNM26" if NAME_1=="Hà Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM27" if NAME_1=="Hà Nội" & origin=="Vietnam"
replace ID_GADM_fine="VNM28" if NAME_1=="Hà Nam" & origin=="Vietnam"
replace ID_GADM_fine="VNM29" if NAME_1=="Hà Tĩnh" & origin=="Vietnam"
replace ID_GADM_fine="VNM30" if NAME_1=="Hoà Bình" & origin=="Vietnam"
replace ID_GADM_fine="VNM31" if NAME_1=="Hưng Yên" & origin=="Vietnam"
replace ID_GADM_fine="VNM32" if NAME_1=="Khánh Hòa" & origin=="Vietnam"
replace ID_GADM_fine="VNM33" if NAME_1=="Kiên Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM34" if NAME_1=="Kon Tum" & origin=="Vietnam"
replace ID_GADM_fine="VNM35" if NAME_1=="Lạng Sơn" & origin=="Vietnam"
replace ID_GADM_fine="VNM36" if NAME_1=="Lai Châu" & origin=="Vietnam"
replace ID_GADM_fine="VNM37" if NAME_1=="Lâm Đồng" & origin=="Vietnam"
replace ID_GADM_fine="VNM38" if NAME_1=="Lào Cai" & origin=="Vietnam"
replace ID_GADM_fine="VNM39" if NAME_1=="Long An" & origin=="Vietnam"
replace ID_GADM_fine="VNM40" if NAME_1=="Nam Định" & origin=="Vietnam"
replace ID_GADM_fine="VNM41" if NAME_1=="Nghệ An" & origin=="Vietnam"
replace ID_GADM_fine="VNM42" if NAME_1=="Ninh Bình" & origin=="Vietnam"
replace ID_GADM_fine="VNM43" if NAME_1=="Ninh Thuận" & origin=="Vietnam"
replace ID_GADM_fine="VNM44" if NAME_1=="Phú Thọ" & origin=="Vietnam"
replace ID_GADM_fine="VNM45" if NAME_1=="Phú Yên" & origin=="Vietnam"
replace ID_GADM_fine="VNM46" if NAME_1=="Quảng Bình" & origin=="Vietnam"
replace ID_GADM_fine="VNM47" if NAME_1=="Quảng Nam" & origin=="Vietnam"
replace ID_GADM_fine="VNM48" if NAME_1=="Quảng Ngãi" & origin=="Vietnam"
replace ID_GADM_fine="VNM49" if NAME_1=="Quảng Ninh" & origin=="Vietnam"
replace ID_GADM_fine="VNM50" if NAME_1=="Quảng Trị" & origin=="Vietnam"
replace ID_GADM_fine="VNM51" if NAME_1=="Sóc Trăng" & origin=="Vietnam"
replace ID_GADM_fine="VNM52" if NAME_1=="Sơn La" & origin=="Vietnam"
replace ID_GADM_fine="VNM53" if NAME_1=="Tây Ninh" & origin=="Vietnam"
replace ID_GADM_fine="VNM54" if NAME_1=="Thừa Thiên Huế" & origin=="Vietnam"
replace ID_GADM_fine="VNM55" if NAME_1=="Thái Bình" & origin=="Vietnam"
replace ID_GADM_fine="VNM56" if NAME_1=="Thái Nguyên" & origin=="Vietnam"
replace ID_GADM_fine="VNM57" if NAME_1=="Thanh Hóa" & origin=="Vietnam"
replace ID_GADM_fine="VNM58" if NAME_1=="Tiền Giang" & origin=="Vietnam"
replace ID_GADM_fine="VNM59" if NAME_1=="Trà Vinh" & origin=="Vietnam"
replace ID_GADM_fine="VNM60" if NAME_1=="Tuyên Quang" & origin=="Vietnam"
replace ID_GADM_fine="VNM61" if NAME_1=="Vĩnh Long" & origin=="Vietnam"
replace ID_GADM_fine="VNM62" if NAME_1=="Vĩnh Phúc" & origin=="Vietnam"
replace ID_GADM_fine="VNM63" if NAME_1=="Yên Bái" & origin=="Vietnam"

* WEST BANK AND GAZA STRIP
replace origin="Palestina" if origin=="West Bank and Gaza Strip"
replace NAME_1="Gaza" if NAME_1=="Gaza Strip" & origin=="Palestina"
replace NAME_1="West Bank" if NAME_1=="Jerusalem" & origin=="Palestina"
replace ID_GADM_fine="PSE1" if NAME_1=="Gaza" & origin=="Palestina"
replace ID_GADM_fine="PSE2" if NAME_1=="West Bank" & origin=="Palestina"

* WESTERN SAHARA
drop if origin=="Western Sahara"

* YEMEN
replace NAME_1="Al Dali'" if NAME_1=="Ad Dali" & origin=="Yemen"
replace NAME_1="`Adan" if NAME_1=="Adan" & origin=="Yemen"
replace NAME_1="Al Bayda'" if NAME_1=="Al Bayda" & origin=="Yemen"
replace NAME_1="Al Mahwit" if NAME_1=="Mahwit" & origin=="Yemen"
replace NAME_1="Ma'rib" if NAME_1=="Marib" & origin=="Yemen"
replace NAME_1="Sa`dah" if NAME_1=="Saada" & origin=="Yemen"
replace NAME_1="San`a'" if NAME_1=="Sanaa" & origin=="Yemen"
replace NAME_1="Ta`izz" if NAME_1=="Taizz" & origin=="Yemen"
replace ID_GADM_fine="YEM1" if NAME_1=="`Adan" & origin=="Yemen"
replace ID_GADM_fine="YEM2" if NAME_1=="Abyan" & origin=="Yemen"
replace ID_GADM_fine="YEM3" if NAME_1=="Al Bayda'" & origin=="Yemen"
replace ID_GADM_fine="YEM4" if NAME_1=="Al Dali'" & origin=="Yemen"
replace ID_GADM_fine="YEM5" if NAME_1=="Al Hudaydah" & origin=="Yemen"
replace ID_GADM_fine="YEM6" if NAME_1=="Al Jawf" & origin=="Yemen"
replace ID_GADM_fine="YEM7" if NAME_1=="Al Mahrah" & origin=="Yemen"
replace ID_GADM_fine="YEM8" if NAME_1=="Al Mahwit" & origin=="Yemen"
replace ID_GADM_fine="YEM9" if NAME_1=="Amanat Al Asimah" & origin=="Yemen"
replace ID_GADM_fine="YEM10" if NAME_1=="Amran" & origin=="Yemen"
replace ID_GADM_fine="YEM11" if NAME_1=="Dhamar" & origin=="Yemen"
replace ID_GADM_fine="YEM12" if NAME_1=="Hadramawt" & origin=="Yemen"
replace ID_GADM_fine="YEM13" if NAME_1=="Hajjah" & origin=="Yemen"
replace ID_GADM_fine="YEM14" if NAME_1=="Ibb" & origin=="Yemen"
replace ID_GADM_fine="YEM15" if NAME_1=="Lahij" & origin=="Yemen"
replace ID_GADM_fine="YEM16" if NAME_1=="Ma'rib" & origin=="Yemen"
replace ID_GADM_fine="YEM17" if NAME_1=="Raymah" & origin=="Yemen"
replace ID_GADM_fine="YEM18" if NAME_1=="Sa`dah" & origin=="Yemen"
replace ID_GADM_fine="YEM19" if NAME_1=="San`a'" & origin=="Yemen"
replace ID_GADM_fine="YEM20" if NAME_1=="Shabwah" & origin=="Yemen"
replace ID_GADM_fine="YEM21" if NAME_1=="Ta`izz" & origin=="Yemen"

* YUGOSLAVIA
replace origin="Serbia" if origin=="Yugoslavia"
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade" & origin=="Serbia"
replace NAME_1="Grad Beograd" if NAME_1=="Belgrade (District)" & origin=="Serbia"
replace NAME_1="Braničevski" if NAME_1=="Branicevo (District)" & origin=="Serbia"
replace NAME_1="Pčinjski" if NAME_1=="Bujanovac (Municipality)" & origin=="Serbia"
drop if NAME_1=="Central Serbia" & origin=="Serbia" // Too large
replace NAME_1="Jablanički" if NAME_1=="Jablanica (District)" & origin=="Serbia"
replace NAME_1="Kolubarski" if NAME_1=="Kolubara (District)" & origin=="Serbia"
drop if NAME_1=="Montenegro (Republic)" & origin=="Serbia" // Too large
replace NAME_1="Pčinjski" if NAME_1=="Pcinja" & origin=="Serbia"
replace NAME_1="Pčinjski" if NAME_1=="Pcinja (District)" & origin=="Serbia"
replace origin="Montenegro" if NAME_1=="Podgorica"
replace NAME_1="Pčinjski" if NAME_1=="Presevo (Municipality)" & origin=="Serbia"
replace NAME_1="Repuplika Srpska" if NAME_1=="Republika Srpska" & origin=="Serbia"
replace origin="Bosnia and Herzegovina" if NAME_1=="Repuplika Srpska"
drop if NAME_1=="Serbia" & origin=="Serbia" // Too large
drop if NAME_1=="Vojvodina (Province)" & origin=="Serbia" // Too large
replace NAME_1="Pčinjski" if NAME_1=="Vranje (Municipality)" & origin=="Serbia"
drop if NAME_1=="Yugoslavia" & origin=="Serbia"
replace ID_GADM_fine="SRB1" if NAME_1=="Borski" & origin=="Serbia"
replace ID_GADM_fine="SRB2" if NAME_1=="Braničevski" & origin=="Serbia"
replace ID_GADM_fine="SRB3" if NAME_1=="Grad Beograd" & origin=="Serbia"
replace ID_GADM_fine="SRB4" if NAME_1=="Jablanički" & origin=="Serbia"
replace ID_GADM_fine="SRB5" if NAME_1=="Južno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB6" if NAME_1=="Južno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB7" if NAME_1=="Kolubarski" & origin=="Serbia"
replace ID_GADM_fine="SRB8" if NAME_1=="Mačvanski" & origin=="Serbia"
replace ID_GADM_fine="SRB9" if NAME_1=="Moravički" & origin=="Serbia"
replace ID_GADM_fine="SRB10" if NAME_1=="Nišavski" & origin=="Serbia"
replace ID_GADM_fine="SRB11" if NAME_1=="Pčinjski" & origin=="Serbia"
replace ID_GADM_fine="SRB12" if NAME_1=="Pirotski" & origin=="Serbia"
replace ID_GADM_fine="SRB13" if NAME_1=="Podunavski" & origin=="Serbia"
replace ID_GADM_fine="SRB14" if NAME_1=="Pomoravski" & origin=="Serbia"
replace ID_GADM_fine="SRB15" if NAME_1=="Rasinski" & origin=="Serbia"
replace ID_GADM_fine="SRB16" if NAME_1=="Raški" & origin=="Serbia"
replace ID_GADM_fine="SRB17" if NAME_1=="Severno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB18" if NAME_1=="Severno-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB19" if NAME_1=="Srednje-Banatski" & origin=="Serbia"
replace ID_GADM_fine="SRB20" if NAME_1=="Sremski" & origin=="Serbia"
replace ID_GADM_fine="SRB21" if NAME_1=="Šumadijski" & origin=="Serbia"
replace ID_GADM_fine="SRB22" if NAME_1=="Toplički" & origin=="Serbia"
replace ID_GADM_fine="SRB23" if NAME_1=="Zaječarski" & origin=="Serbia"
replace ID_GADM_fine="SRB24" if NAME_1=="Zapadno-Bački" & origin=="Serbia"
replace ID_GADM_fine="SRB25" if NAME_1=="Zlatiborski" & origin=="Serbia"
replace ID_GADM_fine="MNE18" if NAME_1=="Podgorica" & origin=="Montenegro"
replace ID_GADM_fine="BIH3" if NAME_1=="Repuplika Srpska" & origin=="Bosnia and Herzegovina"

* ZAMBIA
replace ID_GADM_fine="ZMB1" if NAME_1=="Central" & origin=="Zambia"
replace ID_GADM_fine="ZMB2" if NAME_1=="Copperbelt" & origin=="Zambia"
replace ID_GADM_fine="ZMB3" if NAME_1=="Eastern" & origin=="Zambia"
replace ID_GADM_fine="ZMB4" if NAME_1=="Luapula" & origin=="Zambia"
replace ID_GADM_fine="ZMB5" if NAME_1=="Lusaka" & origin=="Zambia"
replace ID_GADM_fine="ZMB6" if NAME_1=="Muchinga" & origin=="Zambia"
replace ID_GADM_fine="ZMB7" if NAME_1=="North-Western" & origin=="Zambia"
replace ID_GADM_fine="ZMB8" if NAME_1=="Northern" & origin=="Zambia"
replace ID_GADM_fine="ZMB9" if NAME_1=="Southern" & origin=="Zambia"
replace ID_GADM_fine="ZMB10" if NAME_1=="Western" & origin=="Zambia"

* ZIMBABWE
replace ID_GADM_fine="ZWE1" if NAME_1=="Bulawayo" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE2" if NAME_1=="Harare" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE3" if NAME_1=="Manicaland" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE4" if NAME_1=="Mashonaland Central" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE5" if NAME_1=="Mashonaland East" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE6" if NAME_1=="Mashonaland West" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE7" if NAME_1=="Masvingo" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE8" if NAME_1=="Matabeleland North" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE9" if NAME_1=="Matabeleland South" & origin=="Zimbabwe"
replace ID_GADM_fine="ZWE10" if NAME_1=="Midlands" & origin=="Zimbabwe"

* ADDED 03/12/2020
drop if ID_GADM_fine==""

////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////

*** Construct raw variables of interest 2.0

egen BombingPPPM= sum(type1), by(iyear imonth NAME_1)
* This command gives the number of attacks type "bombing/explosion" per MONTH per PROVINCE

egen TargReligPPPM= sum(type2), by(iyear imonth NAME_1)
* This command gives the number of attacks targetting "religious figures and institutions" per MONTH per PROVINCE

egen TargViolPolPPPM= sum(type3), by(iyear imonth NAME_1)
* This command gives the number of attacks targetting "violent political parties" per MONTH per PROVINCE

egen WeapBombPPPM= sum(type4), by(iyear imonth NAME_1)
* This command gives the number of attacks with explosives/Bombs/Dynamite per MONTH per PROVINCE

egen NationalTargPPPM= sum(NationalTarget), by(iyear imonth NAME_1)
* This command gives the number of attacks targetting national people per MONTH per PROVINCE

egen VictimsPPPM= sum(nkill), by(iyear imonth NAME_1)
* This command gives the number of victims per MONTH per PROVINCE

egen WoundedPPPM= sum(nwound), by(iyear imonth NAME_1)
* This command gives the number of wounded per MONTH per PROVINCE

gen var1=1
egen AttacksPPPM= sum(var1), by(iyear imonth NAME_1)
drop var1
* This command gives the number of attacks per MONTH per PROVINCE

gen Attacks_city=1 if specificity==1 | specificity==2
replace Attacks_city=0 if specificity==3 | specificity==4 | specificity==5
* ADDED 04/12/2020
replace Attacks_city=0 if Attacks_city==.
egen Attacks_cityPPPM= sum(Attacks_city), by(iyear imonth NAME_1)
* This command gives the number of attacks in cities per MONTH per PROVINCE

egen propvaluePPPM= sum(propvaluetotal), by(iyear imonth NAME_1)
* This command gives the value of property damage per MONTH per PROVINCE

keep iyear imonth origin NAME_1 ID_GADM_fine VictimsPPPM WoundedPPPM AttacksPPPM NationalTargPPPM BombingPPPM TargViolPolPPPM propvaluePPPM TargReligPPPM Attacks_cityPPPM
rename iyear year
rename imonth month
sort origin NAME_1 year month
order origin NAME_1 year month

*** Keep unique values per year/month and country/province
duplicates drop
// (73,082 observations deleted)

*** Cumulative attacks
// First, need to create a full matrix to keep all the information when lagging variables

egen prov = group(origin NAME_1)
egen time = group(year month)

tsset prov time
tsfill, full

bysort time: carryforward year, gen(yearn)
bysort time: carryforward month, gen(monthn)
bysort prov: carryforward origin, gen(originn)
bysort prov: carryforward NAME_1, gen(provincen)
bysort prov: carryforward ID_GADM_fine, gen(IDn)
drop year month origin NAME_1 ID_GADM_fine

gsort prov - time

bysort time: carryforward yearn, gen(yfinal)
bysort time: carryforward monthn, gen(mfinal)
bysort prov: carryforward originn, gen(originfinal)
bysort prov: carryforward provincen, gen(provincefinal)
bysort prov: carryforward IDn, gen(IDfinal)
drop yearn monthn originn provincen IDn

sort prov - time

bysort time: carryforward yfinal, gen(yyfinal)
bysort time: carryforward mfinal, gen(mmfinal)
bysort prov: carryforward originfinal, gen(ooriginfinal)
bysort prov: carryforward provincefinal, gen(pprovincefinal)
bysort prov: carryforward IDfinal, gen(IIDfinal)
drop yfinal mfinal originfinal provincefinal IDfinal

gsort prov - time

bysort time: carryforward yyfinal, gen(yyyfinal)
bysort time: carryforward mmfinal, gen(mmmfinal)
bysort prov: carryforward ooriginfinal, gen(oooriginfinal)
bysort prov: carryforward pprovincefinal, gen(ppprovincefinal)
bysort prov: carryforward IIDfinal, gen(IIIDfinal)
drop yyfinal mmfinal ooriginfinal pprovincefinal IIDfinal

sort prov - time

bysort time: carryforward yyyfinal, gen(yyfinal)
bysort time: carryforward mmmfinal, gen(mmfinal)
bysort prov: carryforward oooriginfinal, gen(ooriginfinal)
bysort prov: carryforward ppprovincefinal, gen(pprovincefinal)
bysort prov: carryforward IIIDfinal, gen(IIDfinal)
drop yyyfinal mmmfinal oooriginfinal ppprovincefinal IIIDfinal

gsort prov - time

bysort time: carryforward yyfinal, gen(yyyfinal)
bysort time: carryforward mmfinal, gen(mmmfinal)
bysort prov: carryforward ooriginfinal, gen(oooriginfinal)
bysort prov: carryforward pprovincefinal, gen(ppprovincefinal)
bysort prov: carryforward IIDfinal, gen(IIIDfinal)
drop yyfinal mmfinal ooriginfinal pprovincefinal IIDfinal

rename yyyfinal year
rename mmmfinal month
rename oooriginfinal origin
rename ppprovincefinal NAME_1
rename IIIDfinal ID_GADM_fine
order origin NAME_1 ID_GADM_fine year month
sort origin NAME_1 year month

replace VictimsPPPM=0 if VictimsPPPM==.
replace WoundedPPPM=0 if WoundedPPPM==.
replace AttacksPPPM=0 if AttacksPPPM==.
replace NationalTargPPPM=0 if NationalTargPPPM==.
replace BombingPPPM=0 if BombingPPPM==.
replace TargViolPolPPPM=0 if TargViolPolPPPM==.
replace propvaluePPPM=0 if propvaluePPPM==.
replace TargReligPPPM=0 if TargReligPPPM==.
gen AttackOccurrencePPPM=1 if AttacksPPPM>0
replace AttackOccurrencePPPM=0 if AttackOccurrencePPPM==.

* Attacks_city construction
* When there is no attack, we can conclude there is no attack in cities
replace Attacks_cityPPPM=0 if Attacks_cityPPPM==. & AttacksPPPM==0
gen Attacks_city_ratePPPM= Attacks_cityPPPM/ AttacksPPPM
* Then we can create another variable with the observations for which rate=0/0 is replaced by 0 instead of missing
gen Attacks_city_ratePPPM_0= Attacks_city_ratePPPM
replace Attacks_city_ratePPPM_0=0 if Attacks_city_ratePPPM_0==. & AttacksPPPM==0

* Total GTI raw score
gen GTIPPPM=AttacksPPPM+3*VictimsPPPM+0.5*WoundedPPPM+2*propvaluePPPM
gen GTIPPPM2=AttacksPPPM+VictimsPPPM+WoundedPPPM+propvaluePPPM

* Total number of victims (fatalities + wounded)
rename VictimsPPPM FatalitiesPPPM
gen VictimsPPPM=FatalitiesPPPM+WoundedPPPM

sort prov time

gen GTI_score2= log(GTIPPPM)/log(1.6209129231911)
gen GTI_score= 0.5*GTI_score2
replace GTI_score=0 if GTI_score==.
drop GTI_score2

gen GTI_score2bis= log(GTIPPPM2)/log(1.629884633404)
gen GTI_scorebis= 0.5*GTI_score2bis
replace GTI_scorebis=0 if GTI_scorebis==.
drop GTI_score2bis

* Lag variables up to 60 months
forval i = 1/60 {  
gen GTIPPPML`i'=L`i'.GTIPPPM
gen GTIPPPM2L`i'=L`i'.GTIPPPM2
gen GTI_score_lag`i'=L`i'.GTI_score
gen GTI_scorebis_lag`i'=L`i'.GTI_scorebis
gen AttackOccurrencePPPML`i'=L`i'.AttackOccurrencePPPM
gen AttacksPPPML`i'=L`i'.AttacksPPPM
gen VictimsPPPML`i'=L`i'.VictimsPPPM
gen BombingPPPML`i'=L`i'.BombingPPPM
gen NationalTargPPPML`i'=L`i'.NationalTargPPPM
gen TargViolPolPPPML`i'=L`i'.TargViolPolPPPM
gen TargReligPPPML`i'=L`i'.TargReligPPPM
}

gen AttackOccurrence=1 if AttackOccurrencePPPM==1 | AttackOccurrencePPPML1==1 | AttackOccurrencePPPML2==1 | AttackOccurrencePPPML3==1 | AttackOccurrencePPPML4==1 | AttackOccurrencePPPML5==1 | AttackOccurrencePPPML6==1 | AttackOccurrencePPPML7==1 | AttackOccurrencePPPML8==1 | AttackOccurrencePPPML9==1 | AttackOccurrencePPPML10==1 | AttackOccurrencePPPML11==1 | AttackOccurrencePPPML12==1
replace AttackOccurrence=0 if AttackOccurrence==.

*** Time weighting of historical scores

* METHOD A
foreach k in GTIPPPM GTIPPPM2 AttacksPPPM VictimsPPPM BombingPPPM NationalTargPPPM TargViolPolPPPM TargReligPPPM {
gen `k'RawScoreA = 64*`k'L1 + 64*`k'L2 + 64*`k'L3 + /// 
32*`k'L4 + 32*`k'L5 + 32*`k'L6 + ///
16*`k'L7 + 16*`k'L8 + 16*`k'L9 + 16*`k'L10 + 16*`k'L11 + 16*`k'L12 + ///
8*`k'L13 + 8*`k'L14 + 8*`k'L15 + 8*`k'L16 + 8*`k'L17 + 8*`k'L18 + 8*`k'L19 + 8*`k'L20 + 8*`k'L21 + 8*`k'L22 + 8*`k'L23 + 8*`k'L24 + ///
4*`k'L25 + 4*`k'L26 + 4*`k'L27 + 4*`k'L28 + 4*`k'L29 + 4*`k'L30 + 4*`k'L31 + 4*`k'L32 + 4*`k'L33 + 4*`k'L34 + 4*`k'L35 + 4*`k'L36 + ///
2*`k'L37 + 2*`k'L38 + 2*`k'L39 + 2*`k'L40 + 2*`k'L41 + 2*`k'L42 + 2*`k'L43 + 2*`k'L44 + 2*`k'L45 + 2*`k'L46 + 2*`k'L47 + 2*`k'L48 + ///
`k'L49 + `k'L50 + `k'L51 + `k'L52 + `k'L53 + `k'L54 + `k'L55 + `k'L56 + `k'L57 + `k'L58 + `k'L59 + `k'L60 

*** METHOD B
gen `k'RawScoreB = 16*`k'L1+ 16*`k'L2 + 16*`k'L3 + 16*`k'L4 + 16*`k'L5 + 16*`k'L6 + 16*`k'L7 + 16*`k'L8 + 16*`k'L9 + 16*`k'L10 + 16*`k'L11 + 16*`k'L12 + ///
8*`k'L13 + 8*`k'L14 + 8*`k'L15 + 8*`k'L16 + 8*`k'L17 + 8*`k'L18 + 8*`k'L19 + 8*`k'L20 + 8*`k'L21 + 8*`k'L22 + 8*`k'L23 + 8*`k'L24 + ///
4*`k'L25 + 4*`k'L26 + 4*`k'L27 + 4*`k'L28 + 4*`k'L29 + 4*`k'L30 + 4*`k'L31 + 4*`k'L32 + 4*`k'L33 + 4*`k'L34 + 4*`k'L35 + 4*`k'L36 + ///
2*`k'L37 + 2*`k'L38 + 2*`k'L39 + 2*`k'L40 + 2*`k'L41 + 2*`k'L42 + 2*`k'L43 + 2*`k'L44 + 2*`k'L45 + 2*`k'L46 + 2*`k'L47 + 2*`k'L48 + ///
`k'L49 + `k'L50 + `k'L51 + `k'L52 + `k'L53 + `k'L54 + `k'L55 + `k'L56 + `k'L57 + `k'L58 + `k'L59 + `k'L60 
}


drop BombingPPPM-WoundedPPPM
drop propvaluePPPM
drop AttackOccurrencePPPM
drop VictimsPPPM
forval i = 1/60 {  
drop AttackOccurrencePPPML`i'-TargReligPPPML`i'
}

drop if year<2007

sum GTIPPPMRawScoreA GTIPPPMRawScoreB AttacksPPPMRawScoreA AttacksPPPMRawScoreB VictimsPPPMRawScoreA VictimsPPPMRawScoreB BombingPPPMRawScoreA BombingPPPMRawScoreB NationalTargPPPMRawScoreA NationalTargPPPMRawScoreB TargViolPolPPPMRawScoreA TargViolPolPPPMRawScoreB TargReligPPPMRawScoreA TargReligPPPMRawScoreB Attacks_city_ratePPPM Attacks_city_ratePPPM_0 Attacks_cityPPPM

/*
    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
GTIPPPMRaw~A |    155,400    2744.857    18887.15          0   667201.5
GTIPPPMRaw~B |    155,400    1699.847    11586.55          0     343453
AttacksPPP~A |    155,400    264.9455    1518.658          0      47382
AttacksPPP~B |    155,400    164.0006    942.7791          0      30454
VictimsPPP~A |    155,400    1523.917    11329.46          0     446102
-------------+---------------------------------------------------------
VictimsPPP~B |    155,400       951.7    7045.567          0     257142
BombingPPP~A |    155,400    145.8416    1057.574          0      42918
BombingPPP~B |    155,400    90.47691    650.8006          0      27654
NationalTa~A |    155,400     246.201     1473.49          0      47207
NationalTa~B |    155,400    152.2916    913.7905          0      30327
-------------+---------------------------------------------------------
TargViolPo~A |    155,400     2.97666    39.71515          0       3156
TargViolPo~B |    155,400    1.834421     24.0715          0       1464
TargReligP~A |    155,400    7.546216    51.12025          0       1881
TargReligP~B |    155,400    4.725109     31.4732          0       1096
Attack~ePPPM |     16,944    .8068234    .3314394          0          1
-------------+---------------------------------------------------------
Attacks_ci~0 |    155,400    .0879718    .2742556          0          1
Attack~yPPPM |    155,400    .4487194    3.116359          0        117
*/

/* LOGARITHMIC BANDING SCORES TO OBTAIN VARIABLES ON A SCALE OF 1-10 

1. Define the Minimum GTI Score across all countries as
having a banded score of 0.

2. Define the Maximum GTI Score across all countries as
having a banded score 10.

3. Subtract the Minimum from the Maximum GTI scores
and calculate 'r' by:
a. root = 2 X (Highest GTI Banded Score
– Lowest GTI Banded Score) = 2 X (10–0)=20
b. Range = 1 X (Highest Recorded GTI Raw Score
– Lowest Recorded GTI Raw Score)
c. r = root V range
4. The mapped band cut-off value for bin n is
calculated by r^n.

Formula to find scores cleaned: 
* Scores fine = 1/2 * [log(...RawScoreA(orB)/log(r)]
(see computation on the pictures in the Paper II file)

*** GTI

* METHOD A
root=2*(10-0)=20
range=(667201.5-0)
r=20 V 667201.5 = 1.9552975256891

* METHOD B
root=2*(10-0)=20
range=(343453-0)
r=20 V 343453 = 1.8914434688921
*/

gen GTIA1= log(GTIPPPMRawScoreA)/log(1.9552975256891)
gen GTIa= 0.5* GTIA1
replace GTIa=0 if GTIa==.
drop GTIA1 GTIPPPMRawScoreA

gen GTIB1= log(GTIPPPMRawScoreB)/log(1.8914434688921)
gen GTIb= 0.5* GTIB1
replace GTIb=0 if GTIb==.
drop GTIB1 GTIPPPMRawScoreB

/*** AttacksPPPM

* METHOD A
root=2*(10-0)=20
range=(47382-0)
r=20 V 47382 = 1.7130919307732

* METHOD B
root=2*(10-0)=20
range=(30454-0)
r=20 V 30454 = 1.675645780161
*/

gen AttacksIndexA1= log(AttacksPPPMRawScoreA)/log(1.7130919307732)
gen AttacksIndexA= 0.5* AttacksIndexA1
replace AttacksIndexA=0 if AttacksIndexA==.
drop AttacksIndexA1 AttacksPPPMRawScoreA

gen AttacksIndexB1= log(AttacksPPPMRawScoreB)/log(1.675645780161)
gen AttacksIndexB= 0.5* AttacksIndexB1
replace AttacksIndexB=0 if AttacksIndexB==.
drop AttacksIndexB1 AttacksPPPMRawScoreB

/*** VictimsPPPM

* METHOD A
root=2*(10-0)=20
range=(446102-0)
r=20 V 446102 = 1.9163362217237

* METHOD B
root=2*(10-0)=20
range=(257142-0)
r=20 V 257142 = 1.8642693129505
*/

*replace VictimsPPPMRawScoreA=1.000001 if VictimsPPPMRawScoreA==1
gen VictimsIndexA1= log(VictimsPPPMRawScoreA)/log(1.9163362217237)
gen VictimsIndexA= 0.5* VictimsIndexA1
replace VictimsIndexA=0 if VictimsIndexA==.
drop VictimsIndexA1 VictimsPPPMRawScoreA

*replace VictimsPPPMRawScoreB=1.000001 if VictimsPPPMRawScoreB==1
gen VictimsIndexB1= log(VictimsPPPMRawScoreB)/log(1.8642693129505)
gen VictimsIndexB= 0.5* VictimsIndexB1
replace VictimsIndexB=0 if VictimsIndexB==.
drop VictimsIndexB1 VictimsPPPMRawScoreB

/*** BombingPPPM

* METHOD A
root=2*(10-0)=20
range=(42918-0)
r=20 V 42918 = 1.7046372472137

* METHOD B
root=2*(10-0)=20
range=(27654-0)
r=20 V 27654 = 1.6675846849535
*/

*replace BombingPPPMRawScoreA=1.000001 if BombingPPPMRawScoreA==1
gen BombingIndexA1= log(BombingPPPMRawScoreA)/log(1.7046372472137)
gen BombingIndexA= 0.5* BombingIndexA1
replace BombingIndexA=0 if BombingIndexA==.
drop BombingIndexA1 BombingPPPMRawScoreA

*replace BombingPPPMRawScoreB=1.000001 if BombingPPPMRawScoreB==1
gen BombingIndexB1= log(BombingPPPMRawScoreB)/log(1.6675846849535)
gen BombingIndexB= 0.5* BombingIndexB1
replace BombingIndexB=0 if BombingIndexB==.
drop BombingIndexB1 BombingPPPMRawScoreB

/*** NationalTargPPPM

* METHOD A
root=2*(10-0)=20
range=(47207-0)
r=20 V 47207 = 1.7127750189767

* METHOD B
root=2*(10-0)=20
range=(30327-0)
r=20 V 30327 = 1.6752956952782
*/

*replace NationalTargPPPMRawScoreA=1.000001 if NationalTargPPPMRawScoreA==1
gen NationalTargIndexA1= log(NationalTargPPPMRawScoreA)/log(1.7127750189767)
gen NationalTargIndexA= 0.5* NationalTargIndexA1
replace NationalTargIndexA=0 if NationalTargIndexA==.
drop NationalTargIndexA1 NationalTargPPPMRawScoreA

*replace NationalTargPPPMRawScoreB=1.000001 if NationalTargPPPMRawScoreB==1
gen NationalTargIndexB1= log(NationalTargPPPMRawScoreB)/log(1.6752956952782)
gen NationalTargIndexB= 0.5* NationalTargIndexB1
replace NationalTargIndexB=0 if NationalTargIndexB==.
drop NationalTargIndexB1 NationalTargPPPMRawScoreB

/*** TargViolPolPPPM

* METHOD A
root=2*(10-0)=20
range=(3156-0)
r=20 V 3156 = 1.4960870017306

* METHOD B
root=2*(10-0)=20
range=(1464-0)
r=20 V 1464 = 1.4397167383027
*/

*replace TargViolPolPPPMRawScoreA=1.000001 if TargViolPolPPPMRawScoreA==1
gen TargViolPolIndexA1= log(TargViolPolPPPMRawScoreA)/log(1.4960870017306)
gen TargViolPolIndexA= 0.5* TargViolPolIndexA1
replace TargViolPolIndexA=0 if TargViolPolIndexA==.
drop TargViolPolIndexA1 TargViolPolPPPMRawScoreA

*replace TargViolPolPPPMRawScoreB=1.000001 if TargViolPolPPPMRawScoreB==1
gen TargViolPolIndexB1= log(TargViolPolPPPMRawScoreB)/log(1.4397167383027)
gen TargViolPolIndexB= 0.5* TargViolPolIndexB1
replace TargViolPolIndexB=0 if TargViolPolIndexB==.
drop TargViolPolIndexB1 TargViolPolPPPMRawScoreB

/*** TargReligPPPM

* METHOD A
root=2*(10-0)=20
range=(1881-0)
r=20 V 1881 = 1.4578721504928

* METHOD B
root=2*(10-0)=20
range=(1096-0)
r=20 V 1096 = 1.419026571304
*/

*replace TargReligPPPMRawScoreA=1.000001 if TargReligPPPMRawScoreA==1
gen TargReligIndexA1= log(TargReligPPPMRawScoreA)/log(1.4578721504928)
gen TargReligIndexA= 0.5* TargReligIndexA1
replace TargReligIndexA=0 if TargReligIndexA==.
drop TargReligIndexA1 TargReligPPPMRawScoreA

*replace TargReligPPPMRawScoreB=1.000001 if TargReligPPPMRawScoreB==1
gen TargReligIndexB1= log(TargReligPPPMRawScoreB)/log(1.419026571304)
gen TargReligIndexB= 0.5* TargReligIndexB1
replace TargReligIndexB=0 if TargReligIndexB==.
drop TargReligIndexB1 TargReligPPPMRawScoreB

merge m:1 origin using "iso3 codes/Clean/iso3clean.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                           106
        from master                         0  (_merge==1)
        from using                        106  (_merge==2)

    matched                           155,400  (_merge==3)
    -----------------------------------------
*/

drop if _merge==2
drop _merge

gen GTI_score1_lag1=(GTI_score_lag1+GTI_score_lag2+GTI_score_lag3+GTI_score_lag4+GTI_score_lag6+GTI_score_lag7+GTI_score_lag8+GTI_score_lag9+GTI_score_lag10+GTI_score_lag11+GTI_score_lag12)/12
gen GTI_score1_lag2=(GTI_score_lag13+GTI_score_lag14+GTI_score_lag15+GTI_score_lag16+GTI_score_lag17+GTI_score_lag18+GTI_score_lag19+GTI_score_lag20+GTI_score_lag21+GTI_score_lag22+GTI_score_lag23+GTI_score_lag24)/12
gen GTI_score1_lag3=(GTI_score_lag25+GTI_score_lag26+GTI_score_lag27+GTI_score_lag28+GTI_score_lag29+GTI_score_lag30+GTI_score_lag31+GTI_score_lag32+GTI_score_lag33+GTI_score_lag34+GTI_score_lag35+GTI_score_lag36)/12
gen GTI_score1_lag4=(GTI_score_lag37+GTI_score_lag38+GTI_score_lag39+GTI_score_lag40+GTI_score_lag41+GTI_score_lag42+GTI_score_lag43+GTI_score_lag44+GTI_score_lag45+GTI_score_lag46+GTI_score_lag47+GTI_score_lag48)/12
gen GTI_score1_lag5=(GTI_score_lag49+GTI_score_lag50+GTI_score_lag51+GTI_score_lag52+GTI_score_lag53+GTI_score_lag54+GTI_score_lag55+GTI_score_lag56+GTI_score_lag57+GTI_score_lag58+GTI_score_lag59+GTI_score_lag60)/12

gen GTI_score1bis_lag1=(GTI_scorebis_lag1+GTI_scorebis_lag2+GTI_scorebis_lag3+GTI_scorebis_lag4+GTI_scorebis_lag6+GTI_scorebis_lag7+GTI_scorebis_lag8+GTI_scorebis_lag9+GTI_scorebis_lag10+GTI_scorebis_lag11+GTI_scorebis_lag12)/12
gen GTI_score1bis_lag2=(GTI_scorebis_lag13+GTI_scorebis_lag14+GTI_scorebis_lag15+GTI_scorebis_lag16+GTI_scorebis_lag17+GTI_scorebis_lag18+GTI_scorebis_lag19+GTI_scorebis_lag20+GTI_scorebis_lag21+GTI_scorebis_lag22+GTI_scorebis_lag23+GTI_scorebis_lag24)/12
gen GTI_score1bis_lag3=(GTI_scorebis_lag25+GTI_scorebis_lag26+GTI_scorebis_lag27+GTI_scorebis_lag28+GTI_scorebis_lag29+GTI_scorebis_lag30+GTI_scorebis_lag31+GTI_scorebis_lag32+GTI_scorebis_lag33+GTI_scorebis_lag34+GTI_scorebis_lag35+GTI_scorebis_lag36)/12
gen GTI_score1bis_lag4=(GTI_scorebis_lag37+GTI_scorebis_lag38+GTI_scorebis_lag39+GTI_scorebis_lag40+GTI_scorebis_lag41+GTI_scorebis_lag42+GTI_scorebis_lag43+GTI_scorebis_lag44+GTI_scorebis_lag45+GTI_scorebis_lag46+GTI_scorebis_lag47+GTI_scorebis_lag48)/12
gen GTI_score1bis_lag5=(GTI_scorebis_lag49+GTI_scorebis_lag50+GTI_scorebis_lag51+GTI_scorebis_lag52+GTI_scorebis_lag53+GTI_scorebis_lag54+GTI_scorebis_lag55+GTI_scorebis_lag56+GTI_scorebis_lag57+GTI_scorebis_lag58+GTI_scorebis_lag59+GTI_scorebis_lag60)/12

*GTI score for last 1-3m
gen GTI_score_3m=(GTI_score_lag1+GTI_score_lag2+GTI_score_lag3)/3
gen GTI_scorebis_3m=(GTI_scorebis_lag1+GTI_scorebis_lag2+GTI_scorebis_lag3)/3

*GTI score for last 4-6m
gen GTI_score_6m=(GTI_score_lag4+GTI_score_lag5+GTI_score_lag6)/3
gen GTI_scorebis_6m=(GTI_scorebis_lag4+GTI_scorebis_lag5+GTI_scorebis_lag6)/3

*GTI score for last 7-12m
gen GTI_score_12m=(GTI_score_lag7+GTI_score_lag8+GTI_score_lag9+GTI_score_lag10+GTI_score_lag11+GTI_score_lag12)/6
gen GTI_scorebis_12m=(GTI_scorebis_lag7+GTI_scorebis_lag8+GTI_scorebis_lag9+GTI_scorebis_lag10+GTI_scorebis_lag11+GTI_scorebis_lag12)/6


drop GTIPPPML* GTIPPPM2L* GTI_score_lag* GTI_scorebis_lag*

rename GTI_score1_lag1 GTI_score_lag1
rename GTI_score1_lag2 GTI_score_lag2
rename GTI_score1_lag3 GTI_score_lag3
rename GTI_score1_lag4 GTI_score_lag4
rename GTI_score1_lag5 GTI_score_lag5
rename GTI_score1bis_lag1 GTIbis_score_lag1
rename GTI_score1bis_lag2 GTIbis_score_lag2
rename GTI_score1bis_lag3 GTIbis_score_lag3
rename GTI_score1bis_lag4 GTIbis_score_lag4
rename GTI_score1bis_lag5 GTIbis_score_lag5

drop GTIPPPM GTI_score

egen TotalAttacksPCPY= sum(AttacksPPPM), by(origin year)
egen TotalAttacks= sum(AttacksPPPM), by(origin)

bysort prov : egen avgGTIa_byprov=mean(GTI_score_lag1)
egen avgGTIa=mean(GTI_score_lag1)

gen ratioGTIa_byprov = GTI_score_lag1/avgGTIa_byprov
gen ratioGTIa = GTI_score_lag1/avgGTIa

drop GTIPPPM2RawScoreA GTIPPPM2RawScoreB GTI_scorebis GTIPPPM2


save "GTD/Clean/dta/GTD PPPM ready to be merged with GWP.dta", replace
