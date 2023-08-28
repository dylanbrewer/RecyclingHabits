* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
*****************************Arellano-Bond estimation***************************
*******************************************************************************/

	clear

	set more off
	
* Monthly, nyc only

	use data\final\DSNY_Monthly_Tonnage_Data.dta, clear
	
	* Generate rates of interest
	
		gen y_recyclingrate = (papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
		gen recycling_level = papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons
		
		gen y_mgprate = (mgptonscollected )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
		
		gen y_otherrate = (papertonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
		
		gen other_level = papertonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons 
		
		gen y_trashrate = (refusetonscollected)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
	
	* Keep years of interest
		
		keep if year < 2009
		keep if year > 1996
		
	* Keep brooklyn bronx queens
	
		drop if borough == "Manhattan"
		drop if borough == "Staten Island"
	
	* Panel variables
	
		gen date2 = mofd(date)
		
		tab date2, gen(date2_)
		xtset id date2
		
		tab year, gen(year_)
		
		egen boroughyear = group(borough year)
		
		tab boroughyear, gen(boroughyear_)
	
	* AB Regressions
		
		gen outcome = .
		
		replace outcome = y_recyclingrate
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond1
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"
		
		replace outcome = recycling_level
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond11
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"
		
		replace outcome = y_mgprate
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond2
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"
		
		replace outcome = mgptonscollected
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond22
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"
		
		replace outcome = y_otherrate
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond3
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"
		
		replace outcome = other_level
		xtabond outcome date2_* if year < 2002, lags(1) vce(robust) maxld(1)
		estimates store bond33
		estadd local time "Yes"
		estadd local fd "Yes"
		estadd local ab "Yes"

		esttab bond1 bond11 bond2 bond22 bond3 bond33 using output\arellanobond.tex, tex keep(L.outcome) mtitle("\shortstack{Recycling \\ share}" "\shortstack{Recycling \\ tons}" "\shortstack{Metal, glass, \\ plastic share}" "\shortstack{Metal, glass, \\ plastic tons}" "\shortstack{Paper, organics \\ share}" "\shortstack{Paper, organics \\ tons}") se coeflabels(L.outcome "\(Y_{t-1}\)") compress nonotes stats(time fd ab N, fmt(%11.0gc) labels("\shortstack[l]{Time \\ indicators}" "\shortstack[l]{First \\ differenced}" "\shortstack[l]{Arellano \\ Bond}" "N")) replace substitute(_ _)
		
		foreach b in bond1 bond11 bond2 bond22 bond3 bond33 {
			estimates restore `b'
			estat abond
		}



