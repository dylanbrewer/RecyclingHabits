/******************************************************************************* 
**************************Calculate Cohen's D for each method*******************
*******************************************************************************/

	clear

	set more off

	cd data\final
	
* Load data

	use final_didpanel.dta, clear
	
* Drop Manhattan and Staten Island

	drop if fips == 36085
	drop if fips == 36061
	
* Keep balanced panel only

	replace id2 = id if nyc == 1
	egen id3 = group(unit)

	egen balanced = count(y_recyclingrate), by(id3)
	
	drop if balanced < 12

* DID Regression

	forvalues y = 1997/2008 {
		gen treat`y' = 0
		replace treat`y' = 1 if year == `y' & nyc == 1
	}

	xtset id3 year
	xtreg y_recyclingrate treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite, fe vce(cluster id3) 
	
	predict yhatdid, xbu
		
	* Cohen's d
		
		bysort id3: egen sdcohen = sd(y_recyclingrate) if year < 2002 & nyc == 1
				
		gen cohen_did = abs((y_recyclingrate - yhatdid)/sdcohen) if nyc == 1
		
		mean cohen_did
		
		mat cohen_did = e(b)
	
* Fractional regression
		
	local xlist "treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 incomepercapita nonwhite"
	
	foreach v of local xlist {
		egen bar`v' = mean(`v'), by(id3)
	}
	
	fracreg probit y_recyclingrate treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite bartreat1998 barincomepercapita barnonwhite, vce(cluster id3)
	
	predict yhatfracreg, cm
	
	* Cohen's d
	
		gen cohen_fracreg = abs((y_recyclingrate - yhatfracreg)/sdcohen) if nyc == 1
	
		mean cohen_fracreg
		
		mat cohen_fracreg = e(b)
		
* SDID - partialed

	* Load weights/merge
	
		tempfile partialed_oweights partialed_oweights2002 partialed_oweights2003 partialed_oweights2004 partialed_oweights2005 partialed_oweights2006 partialed_oweights2007 partialed_oweights2008 partialed_lweights partialed_lweights2002 partialed_lweights2003 partialed_lweights2004 partialed_lweights2005 partialed_lweights2006 partialed_lweights2007 partialed_lweights2008
		
		forvalues y = 2002/2008 {
			import delimited "partialed_lweights`y'.csv", clear
			rename estimate1 lweights_`y'
			rename v1 year
			save `partialed_lweights`y''
			import delimited "partialed_oweights`y'.csv", clear
			rename estimate1 oweights_`y'
			
			rename v1 unit
			save `partialed_oweights`y''
		}
		
		import delimited "partialed_sdid.csv", clear
		
		
		
		forvalues y = 2002/2008 {
			merge m:1 year using `partialed_lweights`y''
			replace lweights_`y' = 1/7 if year > 2001
			drop _merge
			merge m:1 unit using `partialed_oweights`y''
			drop _merge
			replace oweights_`y' = 1/3 if unit == "Brooklyn" | unit == "Bronx" | unit == "Queens"
		}
		
	* Average weights
	
		egen oweights_average = rowmean(oweights_2002 oweights_2003 oweights_2004 oweights_2005 oweights_2006 oweights_2007 oweights_2008)
		egen lweights_average = rowmean(lweights_2002 lweights_2003 lweights_2004 lweights_2005 lweights_2006 lweights_2007 lweights_2008)
		
		
	* Estimation
	
		gen nyc = 0
		replace nyc = 1 if inlist(unit,"Queens","Brooklyn","Bronx")
	
		forvalues y = 1997/2008 {
			gen treat`y' = 0
			replace treat`y' = 1 if year == `y' & nyc == 1
		}

		egen id3 = group(unit)
		
		xtset id3 year
		
		gen weight = oweights_average * lweights_average
		reghdfe y_recyclingrate  treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year [pweight = weight], absorb(id3) vce(cluster id3) residuals(resid) 
		
		predict yhatpartialed, xbd
		
	* Cohen's d
	
		bysort id3: egen sdcohen = sd(y_recyclingrate) if year < 2002 & nyc == 1
				
		gen cohen_partialed = abs((y_recyclingrate - yhatpartialed)/sdcohen) if nyc == 1
		
		mean cohen_partialed [pweight = weight]
		
		mat cohen_partialed = e(b)

* SDID

	* Load weights/merge
	
		tempfile oweights oweights2002 oweights2003 oweights2004 oweights2005 oweights2006 oweights2007 oweights2008 lweights lweights2002 lweights2003 lweights2004 lweights2005 lweights2006 lweights2007 lweights2008
		
		import delimited "lweights.csv", clear
		rename estimate1 lweights_pooled
		rename v1 year
		save `lweights'
		
		import delimited "oweights.csv", clear
		rename estimate1 oweights_pooled
		rename v1 unit
		save `oweights'
		
		forvalues y = 2002/2008 {
			import delimited "lweights`y'.csv", clear
			rename estimate1 lweights_`y'
			rename v1 year
			save `lweights`y''
			import delimited "oweights`y'.csv", clear
			rename estimate1 oweights_`y'
			
			rename v1 unit
			save `oweights`y''
		}
		
		import delimited "final_sdid.csv", clear
		
		merge m:1 year using `lweights'
		drop _merge
		replace lweights_pooled = 1/7 if year > 2001
		
		merge m:1 unit using `oweights'
		drop _merge
		replace oweights_pooled = 1/3 if unit == "Brooklyn" | unit == "Bronx" | unit == "Queens"
		
		forvalues y = 2002/2008 {
			merge m:1 year using `lweights`y''
			replace lweights_`y' = 1/7 if year > 2001
			drop _merge
			merge m:1 unit using `oweights`y''
			drop _merge
			replace oweights_`y' = 1/3 if unit == "Brooklyn" | unit == "Bronx" | unit == "Queens"
		}
		
	* Average weights
	
		egen oweights_average = rowmean(oweights_2002 oweights_2003 oweights_2004 oweights_2005 oweights_2006 oweights_2007 oweights_2008)
		egen lweights_average = rowmean(lweights_2002 lweights_2003 lweights_2004 lweights_2005 lweights_2006 lweights_2007 lweights_2008)
		
		
	* Estimation
	
		gen nyc = 0
		replace nyc = 1 if inlist(unit,"Queens","Brooklyn","Bronx")
	
		forvalues y = 1997/2008 {
			gen treat`y' = 0
			replace treat`y' = 1 if year == `y' & nyc == 1
		}

		egen id3 = group(unit)
		
		xtset id3 year
		
		gen weight = oweights_average * lweights_average
		reghdfe y_recyclingrate  treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year [pweight = weight], absorb(id3) vce(cluster id3) residuals(resid)
		
		predict yhatsdid, xbd
		
	* Cohen's d
	
		bysort id3: egen sdcohen = sd(y_recyclingrate) if year < 2002 & nyc == 1
				
		gen cohen_sdid = abs((y_recyclingrate - yhatsdid)/sdcohen) if nyc == 1
		
		mean cohen_sdid [pweight = weight]
		
		mat cohen_sdid = e(b)
		
* Synthetic control

	collapse (mean) y_recyclingrate, by(year nyc)
	
	drop if nyc == 0
		
	tempfile sc
	preserve
		use scdata.dta, clear
		keep _time _Y_synthetic
		rename _time year
		gen nyc = 1
		drop if missing(_Y_synthetic)
		save `sc'
	restore
			
	merge 1:1 year nyc using `sc'
	
	egen sdcohen = sd(y_recyclingrate) if year < 2002
	gen cohen_sc = abs((y_recyclingrate - _Y_synthetic)/sdcohen)
	
	mean cohen_sc
	mat cohen_sc = e(b)
	
* Display all Cohen's d:

	mat list cohen_did

	mat list cohen_fracreg

	mat list cohen_sc

	mat list cohen_sdid
	
	mat list cohen_partialed

	cd ..
	cd ..
	
	