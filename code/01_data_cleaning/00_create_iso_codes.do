********************************************************************************
* 00 - Create ISO3 Country Codes
* Foubert, K. & Ruyssen, I. (2024) - JEMS
********************************************************************************
*
* Purpose: Extracts ISO3 country codes from the GADM shapefile (level 0).
*
* Input:   GADM shapefile (gadm36_0.shp)
*
* Output:  iso3.dta
*
* Note: These scripts were developed as part of a collaborative research workflow
* between two co-authors over several years. Internal annotations, commented-out
* file paths, and exploratory code blocks reflect this iterative process and have
* been preserved for transparency and reproducibility.
********************************************************************************

shp2dta using "D:\Dropbox\PhD Killian\Paper II\Maps (descriptives by region)\Clean\gadm36_0.shp", data("D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3.dta") coordinates("D:\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\worldcoorlvl0") genid (id) replace

*shp2dta using "C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Maps (descriptives by region)\Clean\gadm36_0.shp", data("C:\Users\kifouber\Dropbox\PhD Killian\Paper II\Data\iso3 codes\Clean\iso3.dta") coordinates(worldcoorlvl0) genid(id) replace

*shp2dta using "/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Maps (descriptives by region)/Clean/gadm36_0.shp", data("/Users/ilseruyssen/Dropbox/PhD Killian/Paper II/Data/iso3 codes/Clean/iso3.dta") coordinates(worldcoorlvl0) genid(id) replace
