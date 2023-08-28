* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
*****************************Generate scatterplots******************************
*******************************************************************************/

	clear
	set more off

* Load data

	use data\final\DSNY_Monthly_Tonnage_Data.dta, clear
	
	collapse (sum) papertonscollected mgptonscollected resorganicstons schoolorganictons leavesorganictons xmastreetons refusetonscollected (first) nyc fips, by(date borough)
	
* Generate rates of interest

	gen y_recyclingrate = (papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
	gen recycling_level = papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons
	
	gen y_mgprate = (mgptonscollected )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
	
	gen y_otherrate = (papertonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons )/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)
	
	gen other_level = papertonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons 
	
	gen y_trashrate = (refusetonscollected)/(papertonscollected + mgptonscollected + resorganicstons + schoolorganictons + leavesorganictons + xmastreetons + refusetonscollected)

* Keep years of interest

	gen year = year(date)
	
	keep if year < 2009
	keep if year > 1996
	
	gen month = month(date)
	gen date2 = date
	format date2 %12.0g
	
* Keep brooklyn bronx queens

	drop if borough == "Manhattan"
	drop if borough == "Staten Island"

* Pre mid post

	gen pre = 0 
	replace pre = 1 if date < 15522 
	
	gen post = 0 
	replace post = 1 if date > 16131

* Deseasonalize each separately

	* Overall recycling rate

		reg y_recyclingrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
		predict residuals_q, r
			
		gen residuals = residuals_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
		
		reg y_recyclingrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
		predict residuals_b, r
			
		replace residuals = residuals_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
		
		reg y_recyclingrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
		predict residuals_x, r
			
		replace residuals = residuals_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"

		twoway (line residuals date if borough == "Bronx", lwidth(medthick)) (line residuals date if borough == "Brooklyn", lwidth(medthick)) (line residuals date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3)) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(rr, replace) title("Total recycling share of waste") scale(1.6)) // every other year
		
		twoway (line y_recyclingrate date if borough == "Bronx", lwidth(medthick)) (line y_recyclingrate date if borough == "Brooklyn", lwidth(medthick)) (line y_recyclingrate date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(7) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(rr_raw, replace) title("Total recycling share of waste" "(Raw data)") scale(1.6)) 
		
		* Levels
		
			reg recycling_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
			predict residuals1b_q, r
				
			gen residuals1b = residuals1b_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
			
			reg recycling_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
			predict residuals1b_b, r
				
			replace residuals1b = residuals1b_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
			
			reg recycling_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
			predict residuals1b_x, r
				
			replace residuals1b = residuals1b_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
			twoway (line recycling_level date if borough == "Bronx", lwidth(medthick)) (line recycling_level date if borough == "Brooklyn", lwidth(medthick)) (line recycling_level date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(7) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(r_level_raw, replace) title("Tons of waste recycled") scale(1.6)) 
			
			twoway (line residuals1b date if borough == "Bronx", lwidth(medthick)) (line residuals1b date if borough == "Brooklyn", lwidth(medthick)) (line residuals1b date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(6000)24000, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(r_level, replace) title("Tons of waste recycled") scale(1.6)) 

	* MGP rate
	
		reg y_mgprate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
		predict residuals2_q, r
			
		gen residuals2 = residuals2_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
		
		reg y_mgprate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
		predict residuals2_b, r
			
		replace residuals2 = residuals2_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
		
		reg y_mgprate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
		predict residuals2_x, r
			
		replace residuals2 = residuals2_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
		twoway (line residuals2 date if borough == "Bronx", lwidth(medthick)) (line residuals2 date if borough == "Brooklyn", lwidth(medthick)) (line residuals2 date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(mgp, replace) title("Metal, glass, and plastic recycling share of waste") scale(1.6)) 
		
		twoway (line y_mgprate date if borough == "Bronx", lwidth(medthick)) (line y_mgprate date if borough == "Brooklyn", lwidth(medthick)) (line y_mgprate date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(mgp_raw, replace) title("Metal, glass, and plastic recycling share of waste" "(Raw data)") scale(1.6))
		
		* Levels
		
			reg mgptonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
			predict residuals2b_q, r
				
			gen residuals2b = residuals2b_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
			
			reg mgptonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
			predict residuals2b_b, r
				
			replace residuals2b = residuals2b_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
			
			reg mgptonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
			predict residuals2b_x, r
				
			replace residuals2b = residuals2b_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
			twoway (line mgptonscollected date if borough == "Bronx", lwidth(medthick)) (line mgptonscollected date if borough == "Brooklyn", lwidth(medthick)) (line mgptonscollected date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(mgp_level_raw, replace) title("Tons of metal, glass, and plastic recycled") scale(1.6)) 
			
			twoway (line residuals2b date if borough == "Bronx", lwidth(medthick)) (line residuals2b date if borough == "Brooklyn", lwidth(medthick)) (line residuals2b date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(3000)12000, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(mgp_level, replace) title("Tons of metal, glass, and plastic recycled") scale(1.6)) 

	
	* Other rate
	
		reg y_otherrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
		predict residuals3_q, r
			
		gen residuals3 = residuals3_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
		
		reg y_otherrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
		predict residuals3_b, r
			
		replace residuals3 = residuals3_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
		
		reg y_otherrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
		predict residuals3_x, r
			
		replace residuals3 = residuals3_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
		twoway (line residuals3 date if borough == "Bronx", lwidth(medthick)) (line residuals3 date if borough == "Brooklyn", lwidth(medthick)) (line residuals3 date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(other, replace) title("Paper and organics recycling share of waste") scale(1.6)) 
		
		twoway (line y_otherrate date if borough == "Bronx", lwidth(medthick)) (line y_otherrate date if borough == "Brooklyn", lwidth(medthick)) (line y_otherrate date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(0.05)0.35, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(other_raw, replace) title("Paper and organics recycling share of waste" "(Raw data)") scale(1.6))
		
		* Levels
		
			reg other_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
			predict residuals3b_q, r
				
			gen residuals3b = residuals3b_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
			
			reg other_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
			predict residuals3b_b, r
				
			replace residuals3b = residuals3b_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
			
			reg other_level i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
			predict residuals3b_x, r
				
			replace residuals3b = residuals3b_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
			
			twoway (line other_level date if borough == "Bronx", lwidth(medthick)) (line other_level date if borough == "Brooklyn", lwidth(medthick)) (line other_level date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(other_level_raw, replace) title("Tons of paper and organics recycled") scale(1.6))
			
			twoway (line residuals3b date if borough == "Bronx", lwidth(medthick)) (line residuals3b date if borough == "Brooklyn", lwidth(medthick)) (line residuals3b date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0(4000)16000, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(other_level, replace) title("Tons of paper and organics recycled") scale(1.6))
				
	* Trash rate

		reg y_trashrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
		predict residuals4_q, r
			
		gen residuals4 = residuals4_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
		
		reg y_trashrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
		predict residuals4_b, r
			
		replace residuals4 = residuals4_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
		
		reg y_trashrate i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
		predict residuals4_x, r
			
		replace residuals4 = residuals4_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
		twoway (line residuals4 date if borough == "Bronx", lwidth(medthick)) (line residuals4 date if borough == "Brooklyn", lwidth(medthick)) (line residuals4 date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0.6(0.05)1, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(refuse, replace) title("Landfill share of waste") scale(1.6)) 
		
		twoway (line y_trashrate date if borough == "Bronx", lwidth(medthick)) (line y_trashrate date if borough == "Brooklyn", lwidth(medthick)) (line y_trashrate date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(0.6(0.05)1, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(refuse_raw, replace) title("Landfill share of waste" "(Raw data)") scale(1.6)) 
		
		* Levels
		
			reg refusetonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Queens"
			predict residuals4b_q, r
				
			gen residuals4b = residuals4b_q + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Queens"
			
			reg refusetonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Brooklyn"
			predict residuals4b_b, r
				
			replace residuals4b = residuals4b_b + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Brooklyn"
			
			reg refusetonscollected i.month i.pre i.post i.month#i.pre i.month#i.post if borough == "Bronx"
			predict residuals4b_x, r
				
			replace residuals4b = residuals4b_x + _b[_cons] + _b[i1.pre]*pre + _b[i1.post]*post if borough == "Bronx"
		
			twoway (line refusetonscollected date if borough == "Bronx", lwidth(medthick)) (line refusetonscollected date if borough == "Brooklyn", lwidth(medthick)) (line refusetonscollected date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(30000(15000)90000, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(refuse_level_raw, replace) title("Tons of landfill waste") scale(1.6))
			
			twoway (line residuals4b date if borough == "Bronx", lwidth(medthick)) (line residuals4b date if borough == "Brooklyn", lwidth(medthick)) (line residuals4b date if borough == "Queens", lwidth(medthick) legend(ring(0) pos(11) order(1 "Bronx" 2 "Brooklyn" 3 "Queens") region(style(none)) rows(3) ) ylabels(30000(15000)90000, nogrid) xlabels( 13515 "1997" 14245 "1999" 14976 "2001" 15706 "2003" 16437 "2005" 17167 "2007" 17897 "2009", nogrid)xmtick(13880 14610  15341 16071 16802 17532) xline(15522 16131) xtitle(Date) ytitle("") name(refuse_level, replace) title("Tons of landfill waste") scale(1.6))
		
* Save images

	cd output
	graph export rrtrends.pdf, name(rr) replace
	graph export mgptrends.pdf, name(mgp) replace
	graph export othertrends.pdf, name(other) replace
	graph export refusetrends.pdf, name(refuse) replace
	
	graph export rrtrends_raw.pdf, name(rr_raw) replace
	graph export mgptrends_raw.pdf, name(mgp_raw) replace
	graph export othertrends_raw.pdf, name(other_raw) replace
	graph export refusetrends_raw.pdf, name(refuse_raw) replace
	
	graph export rr_level.pdf, name(r_level) replace
	graph export mgp_level.pdf, name(mgp_level) replace
	graph export other_level.pdf, name(other_level) replace
	graph export refuse_level.pdf, name(refuse_level) replace
	
	graph export rr_level_raw.pdf, name(r_level_raw) replace
	graph export mgp_level_raw.pdf, name(mgp_level_raw) replace
	graph export other_level_raw.pdf, name(other_level_raw) replace
	graph export refuse_level_raw.pdf, name(refuse_level_raw) replace
	cd ..
			
			