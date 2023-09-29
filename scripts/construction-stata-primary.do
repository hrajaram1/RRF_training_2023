* RRF 2023 - Constructing data (Primary data) Template	
*-------------------------------------------------------------------------------
* Data construction - household level
*------------------------------------------------------------------------------- 	
	
	use "$base/data/LWH_FUP2_households_clean.dta", clear
	
	* List all the income vars that need to be winsorized
	local winVars INC_01 INC_02 INC_03 INC_06 INC_11 INC_12
	
	* Winsorize Income variables
	foreach winvar of local winVars {
		
		local `winvar'_lab: variable label `winvar'		// Save variable label 
		
		winsor 	`winvar', p(0.01) high gen(`winvar'_w)
		order 	`winvar'_w, after(`winvar')
		lab var `winvar'_w "``winvar'_lab' (Winsorized 0.01)"
		
	}
	
	* Total income per household
	egen 	total_income = rowtotal(INC_01_w INC_02_w INC_03_w INC_04 INC_06_w INC_10 INC_11_w INC_12_w), m
	lab var total_income 	"Total income per hhld"
	
	* Creating a tempfile to merge later
	tempfile hh
	save 	`hh'
	
*-------------------------------------------------------------------------------
* Data construction - plot level
*------------------------------------------------------------------------------- 		
	
	use "$base/data/LWH_FUP2_plot_clean.dta", clear
		
	* Defining conversion units
	local sack25kg      25
    local sack50kg      50
    local sack100kg     100
    local ton           1000
    local mironko       1.5
    local bucket2halfkg 2.5
	local bucket5kg 	5
    local basket10      10
    local basket15      15
	
	* Convert harvest and sold amounts to kg
	forvalues c = 8/9 {
		
		gen 	CRP0`c'QA_kg = .
		order 	CRP0`c'QA_kg, after(CRP0`c'QA)
		replace CRP0`c'QA_kg = CRP0`c'QA                    if CRP0`c'QA == 0	//reported zero harvest
		replace CRP0`c'QA_kg = CRP0`c'QA                    if  CRP0`c'UA == 1	//unit is kg
		replace CRP0`c'QA_kg = CRP0`c'QA * `sack25kg'       if  CRP0`c'UA == 2
		replace CRP0`c'QA_kg = CRP0`c'QA * `sack50kg'       if  CRP0`c'UA ==  3
		replace CRP0`c'QA_kg = CRP0`c'QA * `sack100kg'      if  CRP0`c'UA ==  4
		replace CRP0`c'QA_kg = CRP0`c'QA * `ton'            if  CRP0`c'UA ==  6
		replace CRP0`c'QA_kg = CRP0`c'QA * `mironko'		if  CRP0`c'UA ==  13
		replace CRP0`c'QA_kg = CRP0`c'QA * `bucket2halfkg'  if  CRP0`c'UA ==  14
		replace CRP0`c'QA_kg = CRP0`c'QA * `bucket5kg'      if  CRP0`c'UA ==  15
		replace CRP0`c'QA_kg = CRP0`c'QA * `basket10'       if  CRP0`c'UA ==  16 
		replace CRP0`c'QA_kg = CRP0`c'QA * `basket15'       if  CRP0`c'UA ==  17
		
	}
	
	* Indicator if HH grew dry beans in either plot
	gen 	drybean = A_CROP==9
	order	drybean, after(A_CROP)
	
	* Total dry bean harvest in kg
	gen 	drybean_harv_kg = CRP08QA_kg if drybean==1
	
	* Collapsing to household level
	collapse 	(max) drybean ///
				(sum) drybean_harv_kg CRP10A ///
				(mean) m_drybean_harv_kg=drybean_harv_kg m_CRP10A=CRP10A ///
				, by(ID_05)

				
	* Add labels
	lab var drybean 		"Flag: hhld grew drybeans"
	lab var drybean_harv_kg "Total dry bean harvest in kg"
	lab var CRP10A			"Total household income"
	
	* Keep variables required for analysis 
	*keep 
	
	* Creating a tempfile to merge 
	tempfile temp1
	save 	`temp1' 		
	
	
*-------------------------------------------------------------------------------
* Data construction - asset level
*------------------------------------------------------------------------------- 	
		
	use "$base/data/LWH_FUP2_assets_clean.dta", clear
	
	* Creating a dummy for households that purchased any livestock
	collapse (max) livestock=AA_01 , by(ID_05)
	
	* Adding label
	lab var livestock	"HH purchased any livestock"
	
	* Creating a tempfile to merge later
	tempfile temp2
	save 	`temp2'	
	

	
	
*-------------------------------------------------------------------------------
* Merge constructed datasets
*------------------------------------------------------------------------------- 	

	use `hh', clear
	
	merge 1:1 ID_05 using `temp1'	, nogen 
	merge 1:1 ID_05 using `temp2'	, nogen 
	
	
	* Adding value labels to binary variables 
	lab define yesno 0 "No" 1 "Yes"
	lab val drybean  yesno
	
	* Save data
	save "$base/data/LWH_FUP2_analysis.dta", replace
	
*************************************************************************** end!	
	