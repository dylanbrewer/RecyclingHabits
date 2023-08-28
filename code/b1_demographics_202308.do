* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
**********************Cleans and merges demographics****************************
*******************************************************************************/

	clear
	set more off
	
* Prep vote share data https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/VOQCHQ accessed 03/06/22

	import delimited data\raw\countypres_2000-2020.csv, clear
	
	* Keep 2000, 2004 Democrat share
	
		drop if year > 2004
		keep if party == "DEMOCRAT"
		replace candidatevotes = "." if candidatevotes == "NA"
		destring candidatevotes totalvotes, replace
		gen democratvoteshare = candidatevotes/totalvotes
		
	* Keep MA, NYC, NJ
	
		keep if inlist(state,"NEW YORK","NEW JERSEY","MASSACHUSETTS")
		
		rename county_fips fips
		gen nyc = 1 if fips == "36005" |fips == "36081"|fips == "36061"|fips == "36047"|fips == "36085"
		
		drop if substr(fips,1,2) == "36" & nyc != 1
		
	* Prep for merge
	
		destring fips, replace
		
		keep year fips democratvoteshare
		
		reshape wide democratvoteshare, i(fips) j(year)
		
		tempfile voteshare
		save `voteshare'

* Prep race/ethnicity data https://repository.duke.edu/catalog/38e88069-9789-4731-980e-9e69534f0761
* Based on https://www.census.gov/data/tables/time-series/demo/popest/2010s-counties-detail.html

	import excel data\raw\POP1990.xlsx, firstrow clear
	
	tempfile race
	save `race'
	
	import excel data\raw\POP2000.xlsx, firstrow clear
	
	append using `race'
	
	gen nonwhite = 1 - (nhwa_male + nhwa_female)/tot_pop
	
	keep fips year nonwhite
	
	keep if substr(fips,1,2) == "36" | substr(fips,1,2) == "25" | substr(fips,1,2) == "34"
	
	gen nyc = 1 if fips == "36005" |fips == "36081"|fips == "36061"|fips == "36047"|fips == "36085"
		
	drop if substr(fips,1,2) == "36" & nyc != 1
	
	destring fips, replace
	
	duplicates drop
	
	save `race', replace
	
* Prep education data https://data.ers.usda.gov/reports.aspx?ID=17829

	import excel "data\raw\Education.xls", sheet("Education 1970 to 2019") cellrange(A5:AU3288) firstrow clear
	
	rename AM collegedegree2000
	
	replace collegedegree2000 = collegedegree2000/100
	
	keep FIPSCode State Areaname collegedegree2000
	
	rename FIPSCode fips
	rename State state
	rename Areaname areaname
	
	tempfile education
	save `education'

* Prep CAINC1 data on population and income 
	
	import delimited data\raw\CAINC1__ALL_AREAS_1969_2020.csv, clear
	
	keep if linecode > 1
	
	drop unit tablename region
	
	egen id = group(geofips)
	
	replace geofips = strtrim(subinstr(geofips,`"""',"",.))
	gen fips = geofips
	drop geofips
	
	tempfile population
	preserve 
		keep if linecode == 2 
		
		reshape long v, i(id) j(year)
		rename v population
		replace year = year + 1960
		save `population'
	restore
	
	tempfile income
	
	keep if linecode == 3 
	
	reshape long v, i(id) j(year)
	rename v incomepercapita
	replace year = year + 1960
	
	merge 1:1 fips year using `population'
	drop _merge
	
	* Keep relevant counties
	
		keep if substr(fips,1,2) == "36" | substr(fips,1,2) == "25" | substr(fips,1,2) == "34"
	
		gen nyc = 1 if fips == "36005" |fips == "36081"|fips == "36061"|fips == "36047"|fips == "36085"
		
		drop if substr(fips,1,2) == "36" & nyc != 1
		
	* Final cleanup
	
		drop linecode industryclassification description
		destring incomepercapita population, replace
		
		drop if fips == "25000" // whole state not needed
		drop if fips == "34000" // whole state not needed
		
		drop if year < 1990
	
* Merge on education data

	merge m:1 fips using `education'
	drop if _merge == 2
	drop _merge
	
	destring fips, replace
	
* Merge on vote share

	merge m:1 fips using `voteshare'
	drop if _merge == 2
	drop _merge
	
* Merge on race

	merge 1:1 fips year using `race'
	drop _merge // no data for 2010-2019 collected yet
	
* Save data

	save "data\final\demographicsyearly.dta", replace
	