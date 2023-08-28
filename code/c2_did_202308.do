* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
*****************************OLS estimation*************************************
*******************************************************************************/

	clear
	set more off

* Load data

	use data\final\final_didpanel.dta, clear
	
* Drop Manhattan and Staten Island

	drop if fips == 36085
	drop if fips == 36061
	
* Keep balanced panel only

	replace id2 = id if nyc == 1
	egen id3 = group(unit)

	egen balanced = count(y_recyclingrate), by(id3)
	
	drop if balanced < 12
	
	
* Difference in means

	gen y_1997 = .
	replace y_1997 = y_recyclingrate if year < 2002
	la var y_1997 "Recycling rate, 1997-2001"
	
	gen y_2002 = .
	replace y_2002 = y_recyclingrate if year > 2002 & year < 2005
	la var y_2002 "Recycling rate, 2002-2004"
	
	gen y_2005 = .
	replace y_2005 = y_recyclingrate if year > 2004
	la var y_2005 "Recycling rate, 2005-2008"
	
	la var collegedegree2000 "Fraction with college degree, 2000"
	la var democratvoteshare2000 "Democratic presidential vote share, 2000"
	la var nonwhite "Fraction nonwhite"
	la var incomepercapita "Income per capita"
	
	gen populationk = population/1000
	la var populationk "Population, thousands"

	local summarylist = "populationk incomepercapita nonwhite collegedegree2000 democratvoteshare2000"
	eststo nyc: quietly estpost summarize `summarylist' if nyc == 1
	estadd scalar Regions = 3
	eststo controls: quietly estpost summarize `summarylist' if nyc == 0
	estadd scalar Regions = 207
	eststo diff: quietly estpost ttest `summarylist', by(nyc) unequal
	estadd scalar Regions = 210
	
	cd "`outputpath'"
	
	esttab nyc controls diff using output\differencemeans.tex, tex cells("mean(pattern(1 1 0) fmt(%9.2fc) label(Mean))  b(star pattern(0 0 1) fmt(%9.2fc) label(Diff.))" "sd(pattern(1 1 0) par label(SD)) t(pattern(0 0 1) par fmt(%9.2fc) label(t-stat))") stats(N Regions, fmt(%9.0fc)) mtitles(NYC Controls Difference) label replace prehead({\def\sym#1{\ifmmode^{#1}\else\(^{#1}\)\fi} \begin{tabular}{l*{3}{cc}} \hline) prefoot( & & & \\) nonotes
	
* Scatters for parallel trends?

	preserve
		gen weight = munipop2000 if nyc == 0
		replace weight = round(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected) if nyc == 1
		collapse (mean) y_recyclingrate y_mgprate [fw=weight], by(nyc year)
		twoway (scatter y_recyclingrate year if nyc == 1, connect(l) msize(5pt)) (scatter y_recyclingrate year if nyc == 0, xline(2001.5 2004.5) connect(l) lpattern(dash) legend(pos(11) ring(0) order (1 "NYC" 2 "Controls") region(style(none)) ) ytitle("") xtitle(Year) title("Fraction of waste recycled") ylabel(0(.05).4, nogrid) xlabel(1997(1)2008, nogrid) scale(1.4) msize(5pt)  )
		graph export output\rawparalleltrends.pdf, replace
	restore
	
* Event study
	
	forvalues y = 1997/2008 {
		gen treat`y' = 0
		replace treat`y' = 1 if year == `y' & nyc == 1
	}
	
	xtset id3 year
	xtreg y_recyclingrate treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite, fe vce(cluster id3) 
	
	estimates save data\final\did, replace
		
	* Robustness checks

		* Only drop one pre-period (see footnote 9)
		
			xtreg y_recyclingrate treat1997 treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite, fe vce(cluster id3) 
			coefplot, keep(treat*) vertical yline(0) rename(treat1998 = "1998" treat1999 = "1999" treat2000 = "2000" treat2002 = "2002" treat2003 = "2003" treat2004 = "2004" treat2005 = "2005" treat2006 = "2006" treat2007 = "2007" treat2008 = "2008") title(DID event-study estimates) xline(3.5 6.5)
			
		* Semi-dynamic specification (see footnote 9)
			
			xtreg y_recyclingrate treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite, fe vce(cluster id3) 
			coefplot, keep(treat*) vertical yline(0) rename(treat1998 = "1998" treat1999 = "1999" treat2000 = "2000" treat2002 = "2002" treat2003 = "2003" treat2004 = "2004" treat2005 = "2005" treat2006 = "2006" treat2007 = "2007" treat2008 = "2008") title(DID event-study estimates) xline(3.5 6.5)
	
		* Fractional regression
		
			local xlist "treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 incomepercapita nonwhite"
			
			foreach v of local xlist {
				egen bar`v' = mean(`v'), by(id3)
			}
			
			fracreg probit y_recyclingrate treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008 i.year incomepercapita nonwhite bartreat1998 barincomepercapita barnonwhite, vce(cluster id3)
			
			margins, dydx(treat1998 treat1999 treat2000 treat2002 treat2003 treat2004 treat2005 treat2006 treat2007 treat2008) post
			estimates save data\final\fracresponse, replace
			