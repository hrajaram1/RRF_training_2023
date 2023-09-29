* RRF 2023 - Cleaning data (Primary data) Template	
*-------------------------------------------------------------------------------	
* Cleaning household dataset
*------------------------------------------------------------------------------- 	
		
	* Load tidy dataset
	use  "$base/data/LWH_FUP2_households.dta", clear
	
	* Fixing data types
	ds, has(type string)
	
	destring INC_02, replace
	
	* Turn numeric variables with negative values into missings
	ds, has(type numeric)
	global numVars `r(varlist)'

	foreach numVar of global numVars {
		
		qui recode 	`numVar' 	(-66 	= .a) 	/// Declined to answer
								(-88 	= .b) // don't know
	}	
	
	* Dropping variables 
	*drop ???
	
	* Checking for outliers in income variables and making a note
	sum INC_*, det
	
	* Use iesave to save the clean data and create a report 
	iesave 	"$base/data/LWH_FUP2_household_clean.dta", ///
			idvars(ID_05)  version(15) replace ///
			report(path("$base/documentation/LWH_HH_report.csv") replace)  
			
*-------------------------------------------------------------------------------	
* Cleaning Asset/animal dataset
*------------------------------------------------------------------------------- 
	
	* Load tidy dataset
	use "$base/data/LWH_FUP2_assets.dta", clear
	
	* Turn numeric variables with negative values into missings
	ds, has(type numeric)
	global numVars `r(varlist)'

	foreach numVar of global numVars {
		
		qui recode 	`numVar' 	(-66 	= .a) 	/// Declined to answer
								(-88 	= .b) // don't know
	}	
	
	* Defining new value labels/Adding to old labels 
	*label define asset_val 	???
	*label define aa_01 		???
	
	* Adding value labels
	*label value ??? ??? 
	
	* Adding avriable labels 
	label variable asset     "Asset"
	label variable AA_01 	 "Did your hhld purchase asset?"
	label variable AA_02 	 "How many asset was purchased?"
	
	* Use iesave to save the clean data and create a report 
	iesave 	"$base\data/LWH_FUP2_assets_clean.dta", ///
			idvars(asset ID_05)  version(15) replace ///
			report(path("$base/documentation/LWH_assets_report.csv") replace) 	
			
*-------------------------------------------------------------------------------	
* Cleaning plot dataset
*------------------------------------------------------------------------------- 			
		
	* Load tidy dataset	
	use "$base/data/LWH_FUP2_plot.dta", clear
	
	// Fixing responses to A_CROP_OTHER	
	// Coffee = 80, Mandioca = 81, Onions = 25		
	replace A_CROP_OTHER = "80" if inlist(A_CROP_OTHER, "Coffee", "coffee", "coffee bean") 
	replace A_CROP_OTHER = "81" if inlist(A_CROP_OTHER, "Mandioca", "cassava")
	replace A_CROP_OTHER = "25" if inlist(A_CROP_OTHER, "Onions")
	
	
	* Fixing data stypes
	ds, has(type string)
	
	destring A_CROP_OTHER, replace
	
	// recode the non-responses to extended missing
	ds, has(type numeric)
	global numVars `r(varlist)'

	foreach numVar of global numVars {
		
		qui recode 	`numVar' 	(-66 	= .a) 	/// Declined to answer
								(-88 	= .b) // don't know
	}	
	
	// add value labels to other crops
	// add variable labels
	// create a template first, then edit the template and change the syntax to 
	// iecodebook apply
	/*iecodebook template 	using ///
							"$base/documentation/plot_codebook.xlsx", ///
							replace
	*/						
	* Once you create a template, replace with the following code:
	*
	iecodebook apply 	using ///
						"$base/documentation/plot_codebook.xlsx"	///
						, miss(.d "Don't Know" .r "Declined" .n "Not Applicable")
				
	
	* Use iesave to save the clean data and create a report 
	iesave 	"$base/data/LWH_FUP2_plot_clean.dta", ///
			idvars(plot ID_05)  version(15) replace ///
			report(path("$base/documentation/LWH_plot_report.csv") replace)  
	
	
****************************************************************************end!	
	