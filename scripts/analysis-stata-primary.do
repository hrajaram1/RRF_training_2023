* RRF 2023 - Data Analysis (Primary data) Solutions	
*-------------------------------------------------------------------------------	
* Loading Constructed data
*------------------------------------------------------------------------------- 
	
	use "${base}/data/LWH_FUP2_analysis.dta", clear
	
*-------------------------------------------------------------------------------	
* Summary stats
*------------------------------------------------------------------------------- 


	* Summary statistics by site 
	sumstats 	(INC_*w) ///
				(INC_*w if ID_09 == 1) ///
				(INC_*w if ID_09 == 2)  ///
				using "${base}/outputs/summary-statistics-1.xlsx", ///
				stats(mean p50 sd min max n) replace 
				
				
				
	tabstat 	INC_*w ///
				, save stats(N mean median sd min max)
		
	mat 		results = r(StatTotal) // Reformat results matrix
	
	putexcel 	set  "${base}/outputs/summary-statistics-2.xlsx" , replace
	putexcel 	A1 = mat(results), names
	

*-------------------------------------------------------------------------------	
* Balance tables
*------------------------------------------------------------------------------- 	
	
	* Balance (if they purchased cows or not)
	iebaltab 	INC_*w, ///
				grpvar(livestock) ///
				rowvarlabels	///
				format(%12.3f)	///
				savexlsx("${base}/outputs/balance-1") ///
				replace 
		
	* Balance across sites with site 6 as control
	iebaltab 	INC_*w, ///
				grpvar(ID_10) ///
				control(1)		///
				rowvarlabels	///
				format(%12.3f)	///
				savexlsx("${base}/outputs/balance-2") ///
				replace 		
				
*-------------------------------------------------------------------------------	
								* Regressions
*-------------------------------------------------------------------------------	

	
	* Regression 1: Total earnings on drybean
	reg CRP10A drybean
	est sto reg1
	
	* Regression 2: controlling for livestock
	reg CRP10A drybean livestock
	est sto reg2
	
	* Regression 2: controlling for livestock + clustering by site
	reg CRP10A drybean livestock, vce(cl ID_10)
	est sto reg3
	
	* exporting regression
	esttab 	reg1 reg2 reg3			///
			using "${base}/outputs/regression-1.csv", ///
			label ///
			replace					
				
				
*-------------------------------------------------------------------------------			
								* Graphs 
*-------------------------------------------------------------------------------	

	* Total earnings over site
	gr hbar	CRP10A, 	///
			over(ID_10)
	
	* Adding options
	gr hbar CRP10A, 						///
			over(ID_10) 					///
			ytitle("Average earnings")		///
			graphregion(color(white)) bgcolor(white)
			
	* Median earnings over site 
	gr hbar (median) 	CRP10A, 					///
						over(ID_10) 				///
						ytitle("Median earnings")	///
						graphregion(color(white)) bgcolor(white)
						
	* Median earnings over site and by livestock 
	gr hbar (median) 	CRP10A, 						///
						over(ID_10) 					///
						by(	livestock, 					///
							graphregion(color(white)) 	///
							bgcolor(white)				///
							)							///
						ytitle("Median earnings")		///
						ylabel(,labs(vsmall))
						
	*  Median & mean earnings over site and by livestock 
	gr hbar (median) 	CRP10A							///
			(mean)		CRP10A, 						///
						over(ID_10) 					///
						by(	livestock, 					///
							graphregion(color(white)) 	///
							bgcolor(white)				///
							)							///
						ytitle("Earnings")				///
						ylabel(,labs(vsmall))
		
	* Adding lagend labels
	gr hbar (median) 	CRP10A							///
			(mean)		CRP10A, 						///
						over(ID_10) 					///
						by(	livestock, 					///
							graphregion(color(white)) 	///
							bgcolor(white)				///
							)							///
						legend(order(	1 "Median"		///
										2 "Mean"		///
									)					///
								)						///
						ytitle("Earnings")				///
						ylabel(,labs(vsmall))			///
						name(g1, replace)
						
	* saving graph 					
	graph save g1  "${base}/outputs/graph-1.gpg", replace	
	
	* twoway scatter
	twoway scatter INC_01_w INC_12_w
	
	* twoway scatter with fittet lines by site
	twoway 	(scatter 	INC_01_w  INC_12_w if ID_09 == 2) 	///
			(scatter 	INC_01_w  INC_12_w if ID_09 == 1) 	///
			(lfit 		INC_01_w  INC_12_w if ID_09 == 2) 	///
			(lfit 		INC_01_w  INC_12_w if ID_09 == 1)	
			
	* adding other options
	twoway 	(scatter 	INC_01_w  INC_12_w if ID_09 == 2	, mc(ltblue) msize(vsmall)) 		///
			(scatter 	INC_01_w  INC_12_w if ID_09 == 1	, mc(navy) 	msize(vsmall)) 			///
			(lfit 		INC_01_w  INC_12_w if ID_09 == 2	, lc(orange)) 						///
			(lfit 		INC_01_w  INC_12_w if ID_09 == 1	, lc(maroon)),	 					///
			legend(	lab(1 "On-farm enterprise (RWF): Rwamagana")  								///
					lab(2 "On-farm enterprise (RWF): Kayonza")									///
					order(1 3 2 4)																///
					) 																			///
			graphregion(color(white)) bgcolor(white)											///
			name(g2, replace)
			
	* saving		
	graph save g2  "${base}/outputs/graph-2.gpg", replace	
	
	* Combining and adjusting display
	gr combine g1 g2, name(g3, replace)
	
	gr display g3, ysize(10) xsize(20) 
			
*************************************************************************** end!			
				