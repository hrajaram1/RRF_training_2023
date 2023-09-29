* RRF 2023 - Tidying data (Primary data) Template	
*-------------------------------------------------------------------------------	
* Loading data
*------------------------------------------------------------------------------- 	
	use "$base/data/LWH_FUP2.dta", clear
	

*-------------------------------------------------------------------------------	
* Fixing duplicates
*------------------------------------------------------------------------------- 		
ssc install iefieldkit
	* Fix duplicates using iecduplicates
	ieduplicates 	ID_05 ///
					using  "$base/documentation/duplicates.xlsx",	 ///
					uniquevars(key) 	///
					force	
	
*-------------------------------------------------------------------------------	
* Create globals for variables by units
*------------------------------------------------------------------------------- 		
	
	* Location identifiers
	global ids ID_03 ID_05 ID_06 ID_07 ID_08 ID_09 ID_10
	
	* Unit: Household 
	global hh_vars INC_01 INC_02 INC_03 INC_04 INC_06 INC_10 INC_11 INC_12
					
	* Unit: Assets (Animals)
	global asset_vars AA_01_1 AA_01_2 AA_02_1 AA_02_2
	
	* Unit: Food
	global food_vars EXP_25_1 EXP_25_2 EXP_26_1 EXP_26_2
	
	* Unit: Plot
	global plot_vars A_CROP_P1 A_CROP_P2 A_CROP_OTHER_P1 A_CROP_OTHER_P2 CRP08QA_P1 CRP08QA_P2 CRP08UA_P1 CRP08UA_P2 CRP09QA_P1 CRP09QA_P2 CRP09UA_P1 CRP09UA_P2 CRP10A_P1 CRP10A_P2
					
*-------------------------------------------------------------------------------	
* Tidy Data: HH
*-------------------------------------------------------------------------------	

	preserve 
		
		* Keep HH vars
		keep $ids $hh_vars
		
		* Save data
		save  "$base/data/LWH_FUP2_households.dta", replace
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: Assets
*-------------------------------------------------------------------------------	
	
	preserve 
	
		keep $ids $asset_vars
		
		* Reshape to long 
		reshape long AA_01_ AA_02_, i($ids) j(asset)
		
		* Cleaning 
		label define asset 1 "Cow" 2 "Sheep"
		label val asset asset
		
		rename AA_01_ AA_01
		rename AA_02_ AA_02
		
		order asset
		isid asset ID_05
		* Save data
		save  "$base/data/LWH_FUP2_assets.dta", replace
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: Food
*-------------------------------------------------------------------------------	

	preserve 
	
		keep $ids $food_vars
		
		* Reshape to long 
		reshape long EXP_25_ EXP_26_, i($ids) j(food)
		
		* Cleaning 
		label define food 1 "Flour" 2 "Bread"
		label val food food
		
		rename EXP_25_ EXP_25
		rename EXP_26_ EXP_26
		
		order food
		isid food ID_05
		* Save data
		save  "$base/data/LWH_FUP2_food.dta", replace
		
	restore
	
*-------------------------------------------------------------------------------	
* Tidy Data: Plots
*-------------------------------------------------------------------------------	

	preserve 
	
		keep $ids $plot_vars
		
		* Reshape to long 
		reshape long A_CROP_P A_CROP_OTHER_P CRP08QA_P CRP08UA_P CRP09QA_P CRP09UA_P CRP10A_P, i($ids) j(plot)
		
		* Cleaning 
		rename (A_CROP_P A_CROP_OTHER_P CRP08QA_P CRP08UA_P CRP09QA_P CRP09UA_P CRP10A_P) ///
		(A_CROP A_CROP_OTHER CRP08QA CRP08UA CRP09QA CRP09UA CRP10A)
		
		label define plot 1 "Plot 1" 2 "Plot 2"
		label val plot plot
		
		
		order plot
		isid plot ID_05
		
		* Save data
		save  "$base/data/LWH_FUP2_plot.dta", replace
		
	restore	
	
*************************************************************************** end!	
	
	
	
		