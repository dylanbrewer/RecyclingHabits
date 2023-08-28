* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
*******************Merges data into final datasets for analysis*****************
*******************************************************************************/

	clear

	set more off

	cd data\final // change directory to the data folder
	
	set seed 543417
	
********************************************************************************
* Muni version
********************************************************************************

* Append recycling data

	use DSNY_county_year.dta, clear
	
	append using mass_munirate.dta
	
	append using nj_countyrate.dta

* Merge on Demographics

	merge m:1 fips year using demographicsyearly.dta
	drop if _merge == 1 // drop 2021 and 2022
	drop if _merge == 2
	drop _merge

* Keep 1997-2008

	drop if year < 1997
	drop if year > 2008
	
* Unit variable

	gen unit = borough if nyc == 1
	replace unit = municipality if ma == 1
	replace unit = county if nj == 1
	
* Generate common outcome variables

	gen y_recyclingrate = recyclingrate if nyc == 0
	replace y_recyclingrate = (papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected) if nyc == 1
	
	gen y_mgprate = recyclingrate if nyc == 0
	replace y_mgprate = (mgptonscollected )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected) if nyc == 1
	
* Balanced panel

	egen balanced = count(y_recyclingrate), by(unit)
	
	drop if balanced < 12
	
	drop balanced
	
* Export data

	save final_didpanel.dta, replace
	
********************************************************************************
* SDID, borough - muni version
********************************************************************************
	
gen treated = 0
replace treated = 1 if nyc == 1 & year > 2001

keep unit year y_recyclingrate treated

drop if unit == "Manhattan"
drop if unit == "Staten Island"

order unit year y_recyclingrate treated

* Export overall

	export delimited using "final_sdid.csv", replace

* Export stacked files

	forvalues y = 2002/2008 {
		preserve
			drop if year > `y'
			drop if year <`y' & year > 2001
			export delimited using "final_sdid_`y'.csv", replace
		restore
	}

* Export placebo overall version

	drop if unit == "Bronx"
	drop if unit == "Brooklyn"
	drop if unit == "Queens"
	drop treated
		
	forvalues i = 1/500 {
		sort unit
		preserve
			tempfile tmp
			bysort unit: keep if _n == 1
			sample 3
			sort unit
			save `tmp'
		restore
		merge m:1 unit using `tmp'
		gen placebo`i' = 0
		replace placebo`i' = 1 if _merge == 3
		replace placebo`i' = 0 if year < 2002
		drop _merge 
	}
		
	export delimited using "placebo_sdid.csv", replace
	
* Pre-partialled versions for SDID

	use final_didpanel.dta, clear
	
	drop if unit == "Manhattan"
	drop if unit == "Staten Island"
	
	gen treated = 0
	replace treated = 1 if nyc == 1 & year > 2001

	* Partial out
	
		reg y_recyclingrate incomepercapita nonwhite
		
		predict residuals, r
		
		replace y_recyclingrate = residuals + _b[_cons]
	
	* Export stacked files
	
		keep unit year y_recyclingrate treated
		order unit year y_recyclingrate treated
		
		forvalues y = 2002/2008 {
		preserve
			drop if year > `y'
			drop if year <`y' & year > 2001
			export delimited using "partialed_sdid_`y'.csv", replace
		restore
	}
	
	export delimited partialed_sdid.csv, replace
		
********************************************************************************
* Whole city - Muni version
********************************************************************************

* Append recycling data

	use DSNY_county_year.dta, clear
	
	append using mass_munirate.dta
	
	append using nj_countyrate.dta

* Merge on Demographics

	merge m:1 fips year using demographicsyearly.dta
	drop if _merge == 1 // drop 2021 and 2022
	drop if _merge == 2
	drop _merge

* Keep 1997-2008

	drop if year < 1997
	drop if year > 2008

* Drop Manhattan and Staten Island

	drop if fips == 36085
	drop if fips == 36061

* Collapse to city level
	
		replace fips = 0 if nyc == 1
		gen name = borough if nyc == 1
		replace name = county if nj == 1
		replace name = municipality if ma == 1
		drop id2
		egen id2 = group(name)
		replace id2 = 0 if nyc == 1
		
		collapse (sum) papertonscollected mgptonscollected resorganicstons schoolorganictons leavesorganictons xmastreetons refusetonscollected population (mean) recyclingrate incomepercapita collegedegree2000 democratvoteshare2000 democratvoteshare2004 nonwhite (first) nj ma munipop2000 fiscal municipality id name state [fweight = population], by(id2 nyc year)
		
	* Generate common outcome variables

		gen y_recyclingrate = recyclingrate if nyc == 0
		replace y_recyclingrate = (papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected) if nyc == 1
		
		gen y_mgprate = recyclingrate if nyc == 0
		replace y_mgprate = (mgptonscollected )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected) if nyc == 1
		
	* Keep balanced panel only

		replace id2 = id if nyc == 1
		egen id3 = group(name)

		egen balanced = count(y_recyclingrate), by(id3)
		
		drop if balanced < 12

	* Export data

		save final_syntheticcontrol.dta, replace
	
		cd ..
		cd ..
	


