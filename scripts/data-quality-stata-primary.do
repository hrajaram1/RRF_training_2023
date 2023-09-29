* RRF 2023 - Data Quality checks (Primary data)	Solutions
*-------------------------------------------------------------------------------	
* Loading data
*------------------------------------------------------------------------------- 	
	
	use "${base}/data/LWH_FUP2.dta", clear
	
*-------------------------------------------------------------------------------	
* Cleaning data
*-------------------------------------------------------------------------------	
	
	* Turn numeric variables with negative values into missings
	ds, has(type numeric)
	global numVars `r(varlist)'

	foreach numVar of global numVars {
		
		qui recode 	`numVar' 	(-66 = .r) 	/// refused to answer
								(-88  = .d) // don't know
	}	
	
	destring _all, replace
	
*-------------------------------------------------------------------------------	
* Check for duplicates
*-------------------------------------------------------------------------------		
	
	ieduplicates 	ID_05 ///
					using  "${base}/outputs/duplicates.xlsx",	 ///
					uniquevars(key) 	///
					keepvars(submissionday ID_03 ID_09 ID_10 duration)	///
					force	
					
	
*-------------------------------------------------------------------------------	
* Summary stats for main vars
*-------------------------------------------------------------------------------		
					
	* Store variables in a global
	global sum_vars INC_01  CRP10A_P1 CRP10A_P2
	
	* Export summary stats
	sumstats	($sum_vars) ///
				using "${base}/outputs/sum_vars.xlsx", replace ///
				stats(n mean sd min max)
						
						
*-------------------------------------------------------------------------------	
* Check outliers for main vars
*-------------------------------------------------------------------------------	
					
	* Loop over each variable
	foreach ovar of global sum_vars {
		
		* Summarize and store stats in locals 
		sum 	`ovar', detail
		
		local 	mean_`ovar' = r(mean)		// mean
		local 	ll_`ovar' 	= r(p5)			//lower limit 5th percentile
		local 	ul_`ovar' 	= r(p95) 		//upper limit 95th percentile
		local 	sd_`ovar' 	= r(sd)			//standard deviation
		local 	n_`ovar' 	= r(N)			// No. of obs
				
		// For each var prepare a dataset with the summary stats when the var
		// is an outlier
		preserve
			
			// Keep if variable values are above 95th percentile or below 5th 
			//percentile and non-missing 
			keep if  `ovar' < `ll_`ovar'' | `ovar' > `ul_`ovar'' & !mi(`ovar')
			
			* Save stats as variables
			gen issue_var	= "`ovar'"			//creates a field with the outlier variable name
			gen value 		= `ovar'			// reported value
			gen mean 		= `mean_`ovar''
			gen lower_limit = `ll_`ovar''
			gen upper_limit = `ul_`ovar''
			gen sd 			= `sd_`ovar''
			gen n 			= `n_`ovar''
			
			* Keep the required variables
			keep ID_05 ID_03 issue_var value mean lower_limit upper_limit sd n 
			
			* Save tempfile to append later
			tempfile outlier_`ovar'
			save 	`outlier_`ovar''
			
		restore	

	}
	
	* Appending all the outlier files
	preserve 
	
		* Clear dataset in memory
		clear
		
		* Append all the tempfiles 
		foreach ovar of global sum_vars {
						
			append using  `outlier_`ovar''
			
			* Sort on HHID
			sort  ID_05 		
		
		}
		
		* Export to the HFC excel in the "outliers" sheet
		export excel 	using "${base}/outputs/hfc.xlsx", ///
						sheet("outliers", replace) first(var)
	
	restore
	
	
*-------------------------------------------------------------------------------	
* Enumerator level checks
*-------------------------------------------------------------------------------			
	
	* Summarize duration to access the stored values
	sum duration, detail
	
	* Flag the obs with durations below 5th percentile and above 95th percentile
	gen low_duration = duration < r(p5)
	gen high_duration = duration > r(p95)
	
	
	// Collapse to enumerator level to get average duration, 
	// number of low/high duration surveys, and 
	// total surveys
	
	preserve 
	
		collapse 	(mean) 	duration 	///
					(sum) 	low_duration high_duration 	///
					(count) n_hh = ID_05, 	///
					by(ID_03)
					
		* Export to the HFC excel in the "enum_summary" sheet
		export excel 	using "${base}/outputs/hfc.xlsx", ///
						sheet("enum_summary", replace) first(var)
					
	restore 				
				
*-------------------------------------------------------------------------------	
* Admin/geo level checks
*-------------------------------------------------------------------------------			
	
	* Graph for total surveys done by site
	gr hbar 	(count) ID_05, 							/// No. of suveys
				over(ID_10) 							/// over each site
				
		
	* Export the graph
	gr export 	"${base}/outputs/progress.png", replace			
	
*-------------------------------------------------------------------------------	
* Survey programming checks 
*-------------------------------------------------------------------------------	

	* Flag where the units used for produced crops and for sold crops are not the same
	
	* Flags obs where the units don't match for crops from plot 1 
	gen nomatch_p1 = CRP08UA_P1 !=  CRP09UA_P1 & !mi(CRP08UA_P1) & !mi(CRP09UA_P1)
	
	* Flags obs where the units don't match for crops from plot 2
	gen nomatch_p2 = CRP08UA_P2 !=  CRP09UA_P2 & !mi(CRP08UA_P2) & !mi(CRP09UA_P2)
	
	* Create an indicator variable here the units don't match in either of the plots
	egen nomatch_unit = rowmax(nomatch_*)
	
	* Keep if units don't match
	keep if nomatch_unit == 1
	
	* Generate issue
	gen issue = "Harvest unit does not match sold unit"
	
	* keep hhid, enumerator id, and issue
	keep ID_05 ID_03 issue
		
	* Export to the HFC excel in the "programming_checks" sheet
	export excel 	using "${base}/outputs/hfc.xlsx", ///
					sheet("programming_checks", replace) first(var)
			
****************************************************************************end!	
								