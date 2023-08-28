* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
*****************************Generate plots and tables**************************
*******************************************************************************/

	clear

	set more off
	
* Stacked DID wrapper puts estimates into ereturn output for Stata table creation

	* Load estimates
	
		import delimited "data\final\sdidestimates.csv", clear 
		
		gen labels = "Treat \times "+string(year)
		
		capture program drop sdidcollector
		program define sdidcollector, eclass
			tempname b V
			local labels = "treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008"
			
			mkmat estimates, matrix(`b')
			matrix `b' = `b''
			matrix colnames `b' = `labels'
			
			mkmat var, matrix(`V')
			mat `V' = diag(`V')
			matrix colnames `V' = `labels'
			matrix rownames `V' = `labels'
			
			local obs = 2520
			
			eret post `b' `V' , obs(`obs') prop(`labels')
			eret local treat = 3
			eret local control1 = 207
			eret local control2 = 203
			eret local time = 12
			eret local cmd "SDID collector"
		end
		
		sdidcollector
		estimates store sdid
		
* Unstacked SDID wrapper for appendix

	import delimited "data\final\unstackedestimates.csv", clear 
		
		gen labels = "Treat \times "+string(year)
		
		capture program drop unstackedcollector
		program define unstackedcollector, eclass
			tempname b V
			local labels = "treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008"
			
			mkmat unstacked, matrix(`b')
			matrix `b' = `b''
			matrix colnames `b' = `labels'
			
			mkmat varplacebo, matrix(`V')
			mat `V' = diag(`V')
			matrix colnames `V' = `labels'
			matrix rownames `V' = `labels'
			
			local obs = 2520
			
			eret post `b' `V' , obs(`obs') prop(`labels')
			eret local treat = 3
			eret local control1 = 207
			eret local control2 = 201
			eret local time = 12
			eret local cmd "SDID collector"
		end
		
		unstackedcollector
		estimates store unstacked
		
* Partialed out SDID wrapper for appendix

	import delimited "data\final\partialedestimates.csv", clear 
		
		gen labels = "Treat \times "+string(year)
		
		capture program drop partialedcollector
		program define partialedcollector, eclass
			tempname b V
			local labels = "treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008"
			
			mkmat estimates, matrix(`b')
			matrix `b' = `b''
			matrix colnames `b' = `labels'
			
			mkmat var, matrix(`V')
			mat `V' = diag(`V')
			matrix colnames `V' = `labels'
			matrix rownames `V' = `labels'
			
			local obs = 2520
			
			eret post `b' `V' , obs(`obs') prop(`labels')
			eret local treat = 3
			eret local control1 = 207
			eret local control2 = 202
			eret local time = 12
			eret local cmd "SDID collector"
		end
		
		partialedcollector
		estimates store partialed
		
* Synthetic control 

	estimates use data\final\sc // Load estimates
	
	* Wrapper program to invert p-values into Vcov matrix
	
		capture program drop sccollector
		program define sccollector, eclass
			estimates use data\final\sc
			tempname V p b
			local labels = "treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008"
			mat `V' = I(7)
			mat `p' = e(pvals_std)
			mat `b' = e(b)
			matrix colnames `b' = `labels'
			
			forvalues i = 1/7 {
				mat `V'[`i',`i'] = (`b'[1,`i']/invnormal(`p'[1,`i']/2))^2
			}
			matrix colnames `V' = `labels'
			matrix rownames `V' = `labels'
			
			local obs = 2496
			
			eret post `b' `V', obs(`obs') prop(`labels')
			eret local treat = 1
			eret local control1 = 207
			eret local control2 = 2
			eret local time = 12
			eret local cmd "SC collector"
		end
		sccollector
		estimates store sc
		
* Load did estimates

	estimates use data\final\did
	estadd scalar treat = 3
	estadd scalar control1 = 207
	estadd scalar control2 = 207
	estadd scalar time = 12
	estimates store did
	
* Load fractional regression estimates

	estimates use data\final\fracresponse
	estadd scalar treat = 3
	estadd scalar control1 = 207
	estadd scalar control2 = 207
	estadd scalar time = 12
	estimates store fracresponse
		
* Plot coefficients
		
	coefplot (did) (sdid), vertical keep(treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008) yline(0) title(Estimates) ytitle("", ) xtitle(Year) legend(ring(0) pos(11) region(style(none)) order(2 "DID" 4 "SDID")) coeflabels(treat2002 = "2002" treat2003 = "2003" treat2004 = "2004" treat2005 = "2005" treat2006 = "2006" treat2007 = "2007" treat2008 = "2008") scale(1.4) msize(5pt)
	
	graph export output\estimates.pdf, replace
	
* Table of estimates

	esttab did sdid using output\estimatestable.tex, tex keep(treat*) mtitle("DID" "SDID") p coeflabels(treat1998 "1998 X Treated" treat1999 "1999 X Treated" treat2000 "2000 X Treated" treat2002 "2002 X Treated" treat2003 "2003 X Treated" treat2004 "2004 X Treated" treat2005 "2005 X Treated" treat2006 "2006 X Treated" treat2007 "2007 X Treated" treat2008 "2008 X Treated") compress nonotes sca("treat Treated units" "control1 Control units" "control2 Controls selected") replace

* Trends plots

	* Load weights/merge
	
		tempfile oweights oweights2002 oweights2003 oweights2004 oweights2005 oweights2006 oweights2007 oweights2008 lweights lweights2002 lweights2003 lweights2004 lweights2005 lweights2006 lweights2007 lweights2008
		
		import delimited "data\final\lweights.csv", clear
		rename estimate1 lweights_pooled
		rename v1 year
		save `lweights'
		
		import delimited "data\final\oweights.csv", clear
		rename estimate1 oweights_pooled
		rename v1 unit
		save `oweights'
		
		forvalues y = 2002/2008 {
			import delimited "data\final\lweights`y'.csv", clear
			rename estimate1 lweights_`y'
			rename v1 year
			save `lweights`y''
			import delimited "data\final\oweights`y'.csv", clear
			rename estimate1 oweights_`y'
			
			rename v1 unit
			save `oweights`y''
		}
		
		import delimited "data\final\final_sdid.csv", clear
		
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
		
	* Plot weights

		twoway (scatter lweights_2002 year if year < 2002, msize(6pt)) (scatter lweights_2003 year if year < 2002, msize(6pt)) (scatter lweights_2004 year if year < 2002, msize(6pt)) (scatter lweights_2005 year if year < 2002, msize(6pt)) (scatter lweights_2006 year if year < 2002, msize(6pt)) (scatter lweights_2007 year if year < 2002, msize(6pt)) (scatter lweights_2008 year if year < 2002, msize(6pt)) (scatter lweights_pooled year if year < 2002, mcolor(black) mlcolor(black) msize(8pt) msymbol(Dh) xtitle(Pre-treatment year) ytitle("") ylabel(,nogrid) xlabel(,nogrid) title(Stacked vs joint SDID time weights) legend(order(1 "2002" 2 "2003" 3 "2004" 4 "2005" 5 "2006" 6 "2007" 7 "2008" 8 "Joint (Unstacked)" ) region(style(none)) ring(0) pos(11) col(2)) scale(1.6))
		
		graph export output\timeweights.pdf, replace
	
		gen nyc = 0
		replace nyc = 1 if unit == "Bronx" | unit == "Queens" | unit == "Brooklyn"
		
		twoway scatter oweights_pooled oweights_2002 if nyc == 0, ytitle("Joint" "weight", orientation(horizontal)) xtitle(Stacked weight) title("Joint vs stacked SDID unit weights") scale(1.6) msize(6pt) ylabel(,nogrid) xlabel(,nogrid)
		
		graph export output\regionweights.pdf, replace
		
	* Plot mean SDID
	
		gen pre = 0
		replace pre = 1 if year < 2002
			
		gen weighted = oweights_average*y_recyclingrate
		
		collapse (sum) weighted (mean) lweights_average y_recyclingrate, by(year nyc)
		
		gen relativelweights = lweights_average/8
		
		twoway (scatter weighted year if nyc == 1, connect(l)) (scatter weighted year if nyc == 0, xline(2001.5 2004.5) connect(l) legend(pos(11) ring(0) order (1 "NYC" 2 "SDID" 3 "Year weights ({&lambda})") region(style(none)) ) ytitle(Fraction of waste recycled) xtitle(Year) ylabel(0(.05).45) xlabel(1996(1)2008)) (area relativelweights year if nyc == 0& year < 2002, color(gs13))
	
	* Plot DID and SDID on same plot
	
		* Load SC data
		
			tempfile sc
			preserve
				use data\final\scdata.dta, clear
				keep _time _Y_synthetic
				rename _time year
				gen nyc = 0
				drop if missing(_Y_synthetic)
				save `sc'
			restore
			
			merge 1:1 year nyc using `sc'
			
		* Plot altogether
		
			twoway (scatter weighted year if nyc == 1, connect(l) msize(6pt)) (scatter weighted year if nyc == 0, connect(l) lpattern(dash) msize(6pt)) (scatter y_recyclingrate year if nyc == 0, xline(2001.5 2004.5) connect(l) legend(pos(7) ring(0) cols(2) order (1 "NYC" 3 "DID" 2 "SDID") region(style(none))) title("Fraction of waste recycled") ytitle("") xtitle(Year) ylabel(0.05(.05).4, nogrid) xlabel(1997(2)2008, nogrid) xmtick(1998(2)2008) scale(1.6) msize(6pt))
			
			graph export output\comparison.pdf, replace
			
		* Recenter DID and SDID
		
			su y_recyclingrate if nyc == 1 & year < 2002
			local nycmean = `r(mean)'
			su y_recyclingrate if nyc == 0 & year < 2002
			local mamean = `r(mean)'
			
			gen didrc = y_recyclingrate + `nycmean' - `mamean'
			gen sdidrc = weighted + `nycmean' - `mamean'
		
			twoway (scatter weighted year if nyc == 1, connect(l) msize(6pt)) (scatter sdidrc year if nyc == 0, connect(l) lpattern(dash) msize(6pt)) (scatter didrc year if nyc == 0, xline(2001.5 2004.5) connect(l) legend(pos(7) ring(0) cols(2) order (1 "NYC" 3 "DID" 2 "SDID") region(style(none)) ) title("Fraction of waste recycled, same pretreatment mean") ytitle("") xtitle(Year) ylabel(0.05(.05).25, nogrid) xlabel(1997(2)2008, nogrid) xmtick(1998(2)2008) scale(1.6) msize(6pt))
		
			graph export output\comparisonrecentered.pdf, replace
			
* Table of robustness checks

	esttab partialed unstacked fracresponse sc using output\robustnesstable.tex, tex keep(treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008) order(treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008) mtitle("\shortstack{SDID\\Partialed}" "\shortstack{SDID\\Unstacked}" "\shortstack{Fractional\\DID}" "\shortstack{Synthetic\\Control}") p coeflabels(treat1998 "1998 X Treated" treat1999 "1999 X Treated" treat2000 "2000 X Treated" treat2002 "2002 X Treated" treat2003 "2003 X Treated" treat2004 "2004 X Treated" treat2005 "2005 X Treated" treat2006 "2006 X Treated" treat2007 "2007 X Treated" treat2008 "2008 X Treated") compress nonotes sca("treat Treated units" "control1 Control units" "control2 Controls selected") replace eqlabels(none)



	
	
	