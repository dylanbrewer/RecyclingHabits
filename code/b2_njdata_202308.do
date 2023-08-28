* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
**********************Imports and cleans NJ data********************************
*******************************************************************************/
	
	clear
	set more off
	
* Load data
	
	forvalues y = 1995/2018 {
		tempfile nj_`y'
		import delimited "data\raw\\`y'.csv", clear varnames(nonames)
		drop v1
		unab varlist : v*
		foreach v of local varlist {
			replace `v' = subinstr(strlower(`v'),"%","pct",.) if _n == 1
			replace `v' = subinstr(strlower(`v'),"%","",.) if _n != 1
			replace `v' = subinstr(strlower(`v'),",","",.) if _n != 1
			replace `v' = subinstr(strlower(`v')," ","",.) if _n != 1
			replace `v' = strlower(strtoname(`v')) if _n == 1
			local a = `v'[1]
			rename `v' `a'
		}
		drop if _n == 1
		gen year = `y'
		save `nj_`y''
	}
	
* Merges

	clear
	forvalues y = 1995/2018 {
		append using `nj_`y'', force
	}
	
* Clean

	destring, replace
	
	replace county = "cape may" if county == "capemay"
	
	gen fips = .
	
	replace fips = 34001	if county == "atlantic"
	replace fips = 34003	if county == "bergen"
	replace fips = 34005	if county == "burlington"
	replace fips = 34007	if county == "camden"
	replace fips = 34009	if county == "cape may"
	replace fips = 34011	if county == "cumberland"
	replace fips = 34013	if county == "essex"
	replace fips = 34015	if county == "gloucester"
	replace fips = 34017	if county == "hudson"
	replace fips = 34019	if county == "hunterdon"
	replace fips = 34021	if county == "mercer"
	replace fips = 34023	if county == "middlesex"
	replace fips = 34025	if county == "monmouth"
	replace fips = 34027	if county == "morris"
	replace fips = 34029	if county == "ocean"
	replace fips = 34031	if county == "passaic"
	replace fips = 34033	if county == "salem"
	replace fips = 34035	if county == "somerset"
	replace fips = 34037	if county == "sussex"
	replace fips = 34039	if county == "union"
	replace fips = 34041	if county == "warren"
	
	rename  msw_pct_recycled recyclingrate
	replace recyclingrate = recyclingrate/100
	
	gen nj = 1
	gen nyc = 0
	gen ma = 0
	
	drop population
	
* Export 
	
	save data\final\nj_countyrate.dta, replace