set more off

******************************************************************************************************
*                                                                                                    *
*						   Placebo Regression using Post-Double Selection	                         *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3_plac.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $baselinef$treat tu2

* Drop lagged variables from union of selected variables (due to sample restrictions) 
global selectedlags l2smoke l2lncigd l2lncigd2 l2p_smoke l2p_lncigd l2p_lncigd2
global altallv_plac_f2tu_reason3_1 : list global(allv_selrlasso_tu_reason3_1) - global(selectedlags)

foreach var of varlist $altallv_plac_f2tu_reason3_1 $fe {
	keep if `var'!=.
}
save "${MY_OUT_PATH}\analysis_lasso4_plac.dta", replace

* Step 1: calculate entropy balancing weights by gender
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4_plac.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4_plac.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in smoke lncigd {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $altallv_plac_f2tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $altallv_plac_f2tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m9`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $altallv_plac_f2tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $altallv_plac_f2tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg9`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 
erase "$MY_OUT_PATH\analysis_lasso4_plac.dta"


******************************************************************************************************
*                                                                                                    *
*						   				Different level of clustering 	                         	 *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $treat tu2
keep if psu!=. 
foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in smoke lncigd {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster psu)
	est store PDS_m7`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster psu)
		est store PDS_mg7`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */

******************************************************************************************************
*                                                                                                    *
*								       			PS-Weighting		                                 *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear

foreach depvar in smoke lncigd {
	* Step 0: Estimation of propensity score 
	foreach yesno in 0 1 {
		use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
		keep if female==`yesno'
		rename tu2 tu2old
		rename $treat tu2
		keep if age<=60
		drop if age<=17
		probit tu2 $wv_selrlasso_tu_reason3_1 $fe
		predict ps if e(sample), p
		gen w_tu2=1 if tu2==1
		replace w_tu2=ps/(1-ps) if tu2==0
		keep persnr welle w_tu2
		save "$MY_OUT_PATH\match_`yesno'.dta", replace
	}
	* Combine the sub-datasets				
	use 	"$MY_OUT_PATH\match_0.dta", clear
	append using "$MY_OUT_PATH\match_1.dta"
	foreach yesno in 0 1 {
		erase "$MY_OUT_PATH\match_`yesno'.dta"
	}
	sort persnr welle
	save "$MY_OUT_PATH\matched.dta", replace
	use "$MY_OUT_PATH\ps_main.dta", clear	
	merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

	* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m6`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg6`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


****************************************************************************************************
**** 						All Lasso / Post-Double-Selection Variables 						****
****************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $allv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in smoke lncigd {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m_robeb_`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg_robeb_`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


******************************************************************************************************
*                                                                                                    *
*						   				Entropy balancing not exact on gender 	                     *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights, here: not by gender 
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
sort random
ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
keep persnr welle w_tu2
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in smoke lncigd {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m_robeb2_`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg_robeb2_`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


******************************************************************************************************
*                                                                                                    *
*	         					Age restriction: stricter (22-55 years) 						     *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=55
drop if age<=21
rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in smoke lncigd {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_ma1`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mag1`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


******************************************************************************************************
*                                                                                                    *
*						   		Other outcome: cigarettes/day (no log.) 	                 		 *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in cigday {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 cigd $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_cigd $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m_rob_`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 cigd $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_cigd $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg_rob_`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


******************************************************************************************************
*                                                                                                    *
*				Other outcome: IHS transformed cigarettes/day (instead of log.) 	                 *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17
rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 $fe {
	keep if `var'!=.
}

* Code up alternative outcome: inverse hyperbolic sine transformation (IHS) of cigarettes per day 
rename cigd cigday
rename p_cigd p_cigday 
gen ihscigday 		= asinh(cigday) 
gen f2ihscigday 	= asinh(f2cigday) 
gen d2ihscigday 	= f2ihscigday - ihscigday 
gen p_ihscigday 	= asinh(p_cigday) 
gen p_f2ihscigday 	= asinh(p_f2cigday) 
gen p_d2ihscigday 	= p_f2ihscigday - p_ihscigday 

save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
* PDS Step 2.1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 $fe, gen(w_tu2) maxiter(100000) targets(2) 
	keep persnr welle w_tu2
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
foreach depvar in ihscigday {
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 `y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m_rob_`depvar'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m_1_mean]tu2 - [m_2_mean]tu2=0
	estadd scalar pval=r(p)	

	* Gender-specific analyses 
	foreach x in 0 1 {
		preserve
		keep if female==`x'
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 `y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg_rob_`depvar'`x'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
		estadd scalar pval=r(p)
		restore
	}
} /* End foreach: Define outcome */ 


******************************************************************************************************
*                                                                                                    *
*								Other treatment: Plant closures only 	                 			 *
*                                                                                                    *
******************************************************************************************************
foreach j in tu2 {
	use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
	keep if age<=60
	drop if age<=17

	foreach var of varlist ${allv_selrlasso_`j'} $fe {
		keep if `var'!=.
	}

	save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
	* PDS Step 2.1: Calculate entropy balancing weights by gender 
	foreach yesno in 0 1 {
		use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
		keep if female==`yesno' 
		sort random
		ebalance tu2 ${wv_selrlasso_`j'} $fe, gen(w_tu2) maxiter(100000) targets(1) 
		keep persnr welle w_tu2
		save "$MY_OUT_PATH\match_`yesno'.dta", replace
	}
	* Combine the sub-datasets				
	use 	"$MY_OUT_PATH\match_0.dta", clear
	append using "$MY_OUT_PATH\match_1.dta"
	foreach yesno in 0 1 {
		erase "$MY_OUT_PATH\match_`yesno'.dta"
	}
	sort persnr welle
	save "$MY_OUT_PATH\matched.dta", replace
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

	* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
	foreach depvar in smoke lncigd {
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 ${allv_selrlasso_`j'} $fe [aweight=w_tu2]
			est store m_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' ${allv_selrlasso_`j'} $fe [aweight=w_tu2] 
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			est store m_2
		}
		* Test whether direct/indirect effect are stat. different 
		suest m_1 m_2, vce(cluster persnr)
		est store PDS_m_`depvar'`j'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m_1_mean]tu2 - [m_2_mean]tu2=0
		estadd scalar pval=r(p)	

		* Gender-specific analyses 
		foreach x in 0 1 {
			preserve
			keep if female==`x'
			foreach y in `depvar' {
				qui reg $baseline`y' tu2 ${allv_selrlasso_`j'} $fe [aweight=w_tu2] if female==`x'
				est store m`x'_1
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
				qui reg p_$baseline`y' tu2 p_`y' ${allv_selrlasso_`j'} $fe [aweight=w_tu2] if female==`x'
				est store m`x'_2
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
			}
			suest m`x'_1 m`x'_2, vce(cluster persnr)
			est store PDS_mg_`depvar'`j'`x'
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
			estadd scalar pval=r(p)
			restore
		}
	} /* End foreach: Define outcome */
} /* End foreach: Define treatment */


******************************************************************************************************
*                                                                                                    *
*	       				Additional other reasons for Job Loss and Unemployment                       *
*                                                                                                    *
******************************************************************************************************
foreach j in tu_all2 tucjobloss2 {
	use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
	keep if age<=60
	drop if age<=17
	rename tu2 tu2old
	rename `j' tu2

	foreach var of varlist ${allv_selrlasso_`j'} $fe {
		keep if `var'!=.
	}

	save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
	* PDS Step 2.1: Calculate entropy balancing weights by gender 
	foreach yesno in 0 1 {
		use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
		keep if female==`yesno' 
		sort random
		ebalance tu2 ${wv_selrlasso_`j'} $fe, gen(w_tu2) maxiter(100000) targets(2) 
		keep persnr welle w_tu2
		save "$MY_OUT_PATH\match_`yesno'.dta", replace
	}
	* Combine the sub-datasets				
	use 	"$MY_OUT_PATH\match_0.dta", clear
	append using "$MY_OUT_PATH\match_1.dta"
	foreach yesno in 0 1 {
		erase "$MY_OUT_PATH\match_`yesno'.dta"
	}
	sort persnr welle
	save "$MY_OUT_PATH\matched.dta", replace
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

	* Step 3: Do calculations with PDS (EB weighted DiD using PDS union of controls) 
	foreach depvar in smoke lncigd {
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 ${allv_selrlasso_`j'} $fe [aweight=w_tu2]
			est store m_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' ${allv_selrlasso_`j'} $fe [aweight=w_tu2] 
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			est store m_2
		}
		* Test whether direct/indirect effect are stat. different 
		suest m_1 m_2, vce(cluster persnr)
		est store PDS_m_`depvar'`j'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m_1_mean]tu2 - [m_2_mean]tu2=0
		estadd scalar pval=r(p)	

		* Gender-specific analyses 
		foreach x in 0 1 {
			preserve
			keep if female==`x'
			foreach y in `depvar' {
				qui reg $baseline`y' tu2 ${allv_selrlasso_`j'} $fe [aweight=w_tu2] if female==`x'
				est store m`x'_1
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
				qui reg p_$baseline`y' tu2 p_`y' ${allv_selrlasso_`j'} $fe [aweight=w_tu2] if female==`x'
				est store m`x'_2
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
			}
			suest m`x'_1 m`x'_2, vce(cluster persnr)
			est store PDS_mg_`depvar'`j'`x'
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
			estadd scalar pval=r(p)
			restore
		}
	} /* End foreach: Define outcome */ 
} /* End foreach: Define treatment */ 


******************************************************************************************************
*                                                                                                    *
*					          				Make Table pt. 2	                                     *
*                                                                                                    *
******************************************************************************************************
cap erase "$MY_FINAL_PATH\rob-analysis-pds-tab2_$treat.tex"
estout PDS_m4smoke PDS_m9smoke PDS_m7smoke PDS_m6smoke PDS_m_robeb_smoke PDS_m_robeb2_smoke PDS_ma1smoke PDS_m_smoketu2 PDS_m_smoketu_all2 PDS_m_smoketucjobloss2 /*other outcome cigday*/ using "$MY_FINAL_PATH\rob-analysis-pds-tab2_$treat.tex", stat(pval /*obs obsall*/, fmt(3 /*0 0*/) labels("\ \ \ \textit{p-value of difference}")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{12}{l}{\textbf{Panel A: effect on smoking status}} & \\) append
estout PDS_m4lncigd PDS_m9lncigd PDS_m7lncigd PDS_m6lncigd PDS_m_robeb_lncigd PDS_m_robeb2_lncigd  PDS_ma1lncigd PDS_m_rob_cigday PDS_m_rob_ihscigday PDS_m_lncigdtu2 PDS_m_lncigdtu_all2 PDS_m_lncigdtucjobloss2 using "$MY_FINAL_PATH\rob-analysis-pds-tab2_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&&&&&&&\\ \multicolumn{12}{l}{\textbf{Panel B: effect on smoking intensity}} & \\) append

******************************************************************************************************
*                                                                                                    *
*					          Make Table pt. 2.1 (male unemployment)	                             *
*                                                                                                    *
******************************************************************************************************
cap erase "$MY_FINAL_PATH\rob-analysis-pds-tab2.1_$treat.tex"
estout PDS_mg4smoke0 PDS_mg9smoke0 PDS_mg7smoke0 PDS_mg6smoke0 PDS_mg_robeb_smoke0 PDS_mg_robeb2_smoke0 PDS_mag1smoke0 PDS_mg_smoketu20 PDS_mg_smoketu_all20 PDS_mg_smoketucjobloss20 /*other outcome cigday*/ using "$MY_FINAL_PATH\rob-analysis-pds-tab2.1_$treat.tex", stat(pval /*obs obsall*/, fmt(3 /*0 0*/) labels("\ \ \ \textit{p-value of difference}")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m0_1_mean:tu2 "\ \ \ Own unemployment" m0_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{12}{l}{\textbf{Panel A: effect on smoking status}} & \\) append
estout PDS_mg4lncigd0 PDS_mg9lncigd0 PDS_mg7lncigd0 PDS_mg6lncigd0 PDS_mg_robeb_lncigd0 PDS_mg_robeb2_lncigd0 PDS_mag1lncigd0 PDS_mg_rob_cigday0 PDS_mg_rob_ihscigday0 PDS_mg_lncigdtu20 PDS_mg_lncigdtu_all20 PDS_mg_lncigdtucjobloss20 using "$MY_FINAL_PATH\rob-analysis-pds-tab2.1_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m0_1_mean:tu2 "\ \ \ Own unemployment" m0_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&&&&&&&\\ \multicolumn{12}{l}{\textbf{Panel B: effect on smoking intensity}} & \\) append

******************************************************************************************************
*                                                                                                    *
*					          Make Table pt. 2.2 (female unemployment)	                             *
*                                                                                                    *
******************************************************************************************************
cap erase "$MY_FINAL_PATH\rob-analysis-pds-tab2.2_$treat.tex"
estout PDS_mg4smoke1 PDS_mg9smoke1 PDS_mg7smoke1 PDS_mg6smoke1 PDS_mg_robeb_smoke1 PDS_mg_robeb2_smoke1 PDS_mag1smoke1 PDS_mg_smoketu21 PDS_mg_smoketu_all21 PDS_mg_smoketucjobloss21 /*other outcome cigday*/ using "$MY_FINAL_PATH\rob-analysis-pds-tab2.2_$treat.tex", stat(pval /*obs obsall*/, fmt(3 /*0 0*/) labels("\ \ \ \textit{p-value of difference}")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m1_1_mean:tu2 "\ \ \ Own unemployment" m1_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{12}{l}{\textbf{Panel A: effect on smoking status}} & \\) append
estout PDS_mg4lncigd1 PDS_mg9lncigd1 PDS_mg7lncigd1 PDS_mg6lncigd1 PDS_mg_robeb_lncigd1 PDS_mg_robeb2_lncigd1 PDS_mag1lncigd1 PDS_mg_rob_cigday1 PDS_mg_rob_ihscigday1 PDS_mg_lncigdtu21 PDS_mg_lncigdtu_all21 PDS_mg_lncigdtucjobloss21 using "$MY_FINAL_PATH\rob-analysis-pds-tab2.2_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m1_1_mean:tu2 "\ \ \ Own unemployment" m1_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&&&&&&&\\ \multicolumn{12}{l}{\textbf{Panel B: effect on smoking intensity}} & \\) append

exit
