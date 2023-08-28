* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
***************************Synthetic control estimation*************************
*******************************************************************************/

	clear
	set more off
	
* Load data

	use data\final\final_syntheticcontrol.dta, clear
	
********************************************************************************
* Synthetic control
********************************************************************************

xtset id3 year

synth y_recyclingrate y_recyclingrate(1997(1)2001) democratvoteshare2000(2000) collegedegree2000(2000) nonwhite incomepercapita, trunit(50) trperiod(2002) keep(data\final\scdata) replace
	
synth_runner y_recyclingrate y_recyclingrate(1997(1)2001) democratvoteshare2000(2000) collegedegree2000(2000) nonwhite incomepercapita, trunit(50) trperiod(2002) mspeperiod(1998(1)2001) gen_vars

estimates save data\final\sc, replace // save estimates to use in a table constructed later

single_treatment_graphs, treated_name(NYC) trlinediff(-0.5) effects_ylabels(-.4(.1).5) do_color(gs13) raw_options(scale(1.4) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title("Synthetic control raw outcomes:") subtitle("Fraction of waste recycled")) effects_options(scale(1.6) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) xtitle(Year) ytitle("") legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control effects and placebos) subtitle("Coefficient estimates"))

effect_graphs, treated_name(NYC) trlinediff(-0.5) tc_options(scale(1.4) xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(,nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(NYC and synthetic control) subtitle(Fraction of waste recycled)) effect_options(xlabel(1997(2)2008, nogrid) xmtick(1997(1)2008) ylabel(, nogrid) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control) subtitle("Coefficient estimates") yline(0) scale(1.6))

cd output
graph export scrawoutcomes.pdf, name(raw) replace
graph export scplacebos.pdf, name(effects) replace
graph export scestimates.pdf, name(effect) replace
graph export sctreatcontrol.pdf, name(tc) replace
cd ..

/* Using only pre-trends (see paper footnote 21)

	capture drop pre_rmspe post_rmspe lead effect y_recyclingrate_synth

	synth y_recyclingrate y_recyclingrate(1997(1)2001), trunit(50) trperiod(2002) replace
		
	synth_runner y_recyclingrate y_recyclingrate(1997(1)2001), trunit(50) trperiod(2002) mspeperiod(1998(1)2001) gen_vars


	single_treatment_graphs, treated_name(NYC) trlinediff(-0.5) effects_ylabels(-.4(.1).5) do_color(gs13) raw_ytitle(Fraction of waste recycled) raw_options(scale(1.4) xlabel(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control raw outcomes)) effects_ytitle(Estimates) effects_options(scale(1.4) xlabel(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control effects and placebos))

	effect_graphs, treated_name(NYC) trlinediff(-0.5) tc_ytitle(Fraction of waste recycled) effect_ytitle(Estimates) tc_options(scale(1.4) xlabel(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control)) effect_options(xlabel(1997(1)2008) xtitle(Year) legend(pos(7) ring(0) region(style(none))) xline(2004.5) title(Synthetic control estimates) yline(0) scale(1.4))


