* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
***************Sets up Stata version, installs packages, runs scripts***********
*******************************************************************************/

version 17.0
clear all
set more off

* Declare locals and change directory
	cd "C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits" // change directory to the project folder

	local install = 0 // set to 1 if you want to install packages for Stata and set the scheme // Computation time: ~20s
	local clean = 0 // set to 1 if you want to clean and reassemble the data // Computation time: ~25s
	local analysis = 1 // set to 1 if you want to run the analysis // Computation time: ~33m

	local rpath = "C:\Program Files\R\R-4.1.3\bin\R.exe" // change to your R path
	
* Setup ado files, change scheme, and install packages
	if `install' == 1 {
		* Set up ado files in new folder for this project (specify which directory)

			capture sysdir set PLUS "C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits\code\ado" // specify which directory

		* Install packages

			ssc install estout, replace // estout
			ssc install coefplot, replace // coefplot
			ssc install blindschemes, replace
			ssc install synth, replace // synth
			net install synth_runner, from(https://raw.github.com/bquistorff/synth_runner/master/) replace // synth_runner
			net install ftools, from("https://raw.githubusercontent.com/sergiocorreia/ftools/master/src/") replace // ftools
			net install reghdfe, from("https://raw.githubusercontent.com/sergiocorreia/reghdfe/master/src/") replace // reghdfe
			ssc install shp2dta, replace // shp2dta

		* Set scheme

			set scheme plotplainblind, permanently
	}

* Clean and reassemble data
	if `clean' == 1 {
		
		* To replicate scraping Massachusetts recycling data from the pdf (computation time ~1m):
		* 1. Install Python via the Anaconda distribution: https://www.anaconda.com/
		* 2. Open the Anaconda Prompt and run the following commands (changing your file paths as necessary):
		* 3. conda create -n "recyclinghabits" python=3.8.17 tabula-py pandas pathlib
		* 4. conda activate recyclinghabits
		* 4. python C:\Users\brewe\Dropbox\PaperIdeas\RecyclingHabits\code\a1_masspdfscrape_202308.py

		do "code\b1_demographics_202308.do" // Computation time ~ 18s
		do "code\b2_njdata_202308.do" // Computation time < 1s
		do "code\b3_massdata_202308.do" // Computation time < 1s
		do "code\b4_dsnycleaning_202308.do" // Computation time < 1s

		do "code\b5_merges_202308.do" // Computation time ~ 5s
	}

* Run analysis
	if `analysis' == 1 {
		do "code\c1_scatterplots_202308.do" // Computation time ~ 8s
		do "code\c2_did_202308.do" // Computation time ~ 1s
		do "code\c3_sc_202308.do" // Computation time ~ 2.25m

		* To replicate the R code, you will need to install packages 'devtools', 'Rtools', 'synth-inference/synthdid', and 'ggplot2'.  See code to install these packages commented in the top of each .R script.
			shell "`rpath'" CMD BATCH --vanilla --slave "code\c4_SDID_stacked_202308.R"  // Computation time ~ 16.15m
			shell "`rpath'" CMD BATCH --vanilla --slave "code\c5_SDID_partialed_202308.R" // Computation time ~ 14.19m
			capture rm "code\c4_SDID_stacked_202308.Rout" 
			capture rm "code\c5_SDID_partialed_202308.Rout"

		do "code\c6_sdidplotstables_202308.do"  // Computation time ~ 4s
		do "code\c7_cohens_202308.do"  // Computation time ~ 1s
		do "code\c8_arellanobond_202308.do"  // Computation time ~ 1s
	}