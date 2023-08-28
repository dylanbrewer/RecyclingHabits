* Authors: Dylan Brewer and Samantha Cameron
* Title: Habit and skill retention in recycling
* Version: August 2023
/******************************************************************************* 
**********************Cleans data from DSNY*************************************
*******************************************************************************/

	clear
	set more off
			
	* Load DSNY data

		import delimited "data\raw\DSNY_Monthly_Tonnage_Data.csv", clear
	
	* Clean data
		
		* Translate the date into Stata date format
		
			gen date = date(month,"YM")
			format date %td // formats the Stata date so it is understandable
			
			gen year = year(date) // extracts year
			drop month
			gen month = month(date) // extracts month
			
		* Community district id and string
		
			replace communitydistrict = "07" if communitydistrict == "7A" // I assume this is a subdistrict of 7?
			destring communitydistrict, replace
			collapse (sum) refusetonscollected papertonscollected mgptonscollected resorganicstons schoolorganictons leavesorganictons xmastreetons, by(communitydistrict month year date borough) // to fold 7A in to 7
			
			egen id = group(borough communitydistrict)
			
			gen cdname = borough +" "+ string(communitydistrict)
		
		* replace missing values w 0 	
		
			replace mgptonscollected = 0 if missing(mgptonscollected)
			
		* Generate PUMA variable for matching
		
			gen puma = .
			replace puma = 3710 if cdname == "Bronx 1" | cdname == "Bronx 2"
			replace puma = 3705 if cdname == "Bronx 3" | cdname == "Bronx 6"
			replace puma = 3708 if cdname == "Bronx 4"
			replace puma = 3707 if cdname == "Bronx 5"
			replace puma = 3706 if cdname == "Bronx 7"
			replace puma = 3701 if cdname == "Bronx 8"
			replace puma = 3709 if cdname == "Bronx 9"
			replace puma = 3703 if cdname == "Bronx 10"
			replace puma = 3704 if cdname == "Bronx 11"
			replace puma = 3702 if cdname == "Bronx 12"

			replace puma = 4001 if cdname == "Brooklyn 1"
			replace puma = 4004 if cdname == "Brooklyn 2"
			replace puma = 4003 if cdname == "Brooklyn 3"
			replace puma = 4002 if cdname == "Brooklyn 4"
			replace puma = 4008 if cdname == "Brooklyn 5"
			replace puma = 4005 if cdname == "Brooklyn 6"
			replace puma = 4012 if cdname == "Brooklyn 7"
			replace puma = 4006 if cdname == "Brooklyn 8"
			replace puma = 4011 if cdname == "Brooklyn 9"
			replace puma = 4013 if cdname == "Brooklyn 10"
			replace puma = 4017 if cdname == "Brooklyn 11"
			replace puma = 4014 if cdname == "Brooklyn 12"
			replace puma = 4018 if cdname == "Brooklyn 13"
			replace puma = 4015 if cdname == "Brooklyn 14"
			replace puma = 4016 if cdname == "Brooklyn 15"
			replace puma = 4007 if cdname == "Brooklyn 16"
			replace puma = 4010 if cdname == "Brooklyn 17"
			replace puma = 4009 if cdname == "Brooklyn 18"

			replace puma = 3810 if cdname == "Manhattan 1" | cdname == "Manhattan 2"
			replace puma = 3809 if cdname == "Manhattan 3"
			replace puma = 3807 if cdname == "Manhattan 4" | cdname == "Manhattan 5"
			replace puma = 3808 if cdname == "Manhattan 6"
			replace puma = 3806 if cdname == "Manhattan 7"
			replace puma = 3805 if cdname == "Manhattan 8"
			replace puma = 3802 if cdname == "Manhattan 9"
			replace puma = 3803 if cdname == "Manhattan 10"
			replace puma = 3804 if cdname == "Manhattan 11"
			replace puma = 3801 if cdname == "Manhattan 12"

			replace puma = 4101 if cdname == "Queens 1"
			replace puma = 4109 if cdname == "Queens 2"
			replace puma = 4102 if cdname == "Queens 3"
			replace puma = 4107 if cdname == "Queens 4"
			replace puma = 4110 if cdname == "Queens 5"
			replace puma = 4108 if cdname == "Queens 6"
			replace puma = 4103 if cdname == "Queens 7"
			replace puma = 4106 if cdname == "Queens 8"
			replace puma = 4111 if cdname == "Queens 9"
			replace puma = 4113 if cdname == "Queens 10"
			replace puma = 4104 if cdname == "Queens 11"
			replace puma = 4112 if cdname == "Queens 12"
			replace puma = 4105 if cdname == "Queens 13"
			replace puma = 4114 if cdname == "Queens 14"

			replace puma = 3903 if cdname == "Staten Island 1"
			replace puma = 3902 if cdname == "Staten Island 2"
			replace puma = 3901 if cdname == "Staten Island 3"
			
	* NYC variable
	
		gen nyc = 1
		gen ma = 0
		gen nj = 0
		
	* County FIPS codes
	
		gen fips = .
		replace fips = 36047 if borough == "Brooklyn"
		replace fips = 36061 if borough == "Manhattan"
		replace fips = 36081 if borough == "Queens"
		replace fips = 36085 if borough == "Staten Island"
		replace fips = 36005 if borough == "Bronx"
			
	* Save monthly cd level data

		save data\final\DSNY_Monthly_Tonnage_Data.dta, replace
		
	* To county + yearly
	
		collapse (sum) papertonscollected mgptonscollected resorganicstons schoolorganictons leavesorganictons xmastreetons refusetonscollected (first) nyc nj ma fips, by(year borough)
		
		save data\final\DSNY_county_year.dta, replace
		

