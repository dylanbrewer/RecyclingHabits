* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
**********************Imports and prepares MA data for merge********************
*******************************************************************************/

	clear
	set more off
	
* Load data

	import delimited data\final\munirate_clean.csv, clear varnames(1)
	
* Clean data and prep for merges

	gen fiscal = substr(year,1,2)
	replace year = substr(year,3,4)
	replace recyclingrate = substr(recyclingrate,1,2)
	destring year recyclingrate, replace force
	
	replace recyclingrate = recyclingrate/100
	
	gen nyc = 0
	gen ma = 1
	gen nj = 0
	
	drop v1
	
	replace municipality = "GREAT BARRINGTON" if municipality == "GREAT BARRING"
	replace municipality = "NORTH BROOKFIELD" if municipality == "NORTH BROOKFI"
	replace municipality = "NEW MARLBOROUGH" if municipality == "NEW MARLBORO"
	
	tempfile munirate
	save `munirate'
	
* Munis to Counties https://www.mass.gov/info-details/massgis-data-municipalities
	
	shp2dta using data\raw\townssurvey_shp\TOWNSSURVEY_POLY.shp, database(data\final\municounties) coordinates(data\final\municountiescoords) genid(idvar) replace
	use data\final\municounties.dta, clear
	
	keep TOWN FIPS_STCO POP2000
	
	rename TOWN municipality
	rename FIPS_STCO fips
	rename POP2000 munipop2000
	
	duplicates drop
	
	merge 1:m municipality using `munirate'
	drop _merge
	
	replace fips = 25017 if municipality == "DEVENS"

* Save muni version

	egen id2 = group(municipality)

	save data\final\mass_munirate.dta, replace
