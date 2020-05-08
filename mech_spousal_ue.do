set more off

******************************************************************************************************
*                                                                                                    *
*	         					Mechanism: Spouse not full-time working 					 		 *
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
keep if p_fullt==0
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
		est store m_2
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
	}
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_mfullt`depvar'0
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
			qui reg $baseline`y' tu2 `y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mgfullt`depvar'0_`x'
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
*	         					Mechanism: Spouse full-time working 						 		 *
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
keep if p_fullt==1
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
		est store m_2
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
	}
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_mfullt`depvar'1
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
			qui reg $baseline`y' tu2 `y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mgfullt`depvar'1_`x'
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
*	         				Mechanism: Time, satisfied with leisure time 				 			 *
*	         				Mechanism: Stress as measured by financial worries  					 *
*                                                                                                    *
******************************************************************************************************
foreach depvar in satisleisure worriedfin {
	use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
	keep if age<=60
	drop if age<=17
	rename tu2 tu2old
	rename $treat tu2

	recode worriedfin 1=3 3=1 
	recode p_worriedfin 1=3 3=1 
	recode f2worriedfin 1=3 3=1 
	recode p_f2worriedfin 1=3 3=1 
	label def worried 1 "No worries" 2 "Some worries" 3 "Big worries"
		label val worriedfin worried
		label val f2worriedfin worried
		label val p_worriedfin worried
		label val p_f2worriedfin worried
	drop d2worriedfin p_d2worriedfin
	gen d2worriedfin = f2worriedfin-worriedfin
	gen p_d2worriedfin = p_f2worriedfin-p_worriedfin

	foreach var of varlist $baseline`depvar' p_$baseline`depvar' $allv_selrlasso_tu_reason3_1 $fe {
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
	foreach y in `depvar' {
		qui reg $baseline`y' tu2 `y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_minc2`depvar'
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
			qui reg $baseline`y' tu2 `y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' ${allv_`y'_tu_reason3_1} $fe [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mginc2`depvar'`x'
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
*	         				Mechanism part 2: Income, satisfied with HH income  					 *
*	         				Mechanism: Time, satisfied with leisure time 			 				 *
*	         				Mechanism: Stress as measured by financial worries  					 *
*                                                                                                    *
******************************************************************************************************
foreach mechvar in worriedfin satisleisure satisinchh {
	use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
	keep if age<=60
	drop if age<=17
	rename tu2 tu2old
	rename $treat tu2

	recode worriedfin 1=3 3=1 
	recode p_worriedfin 1=3 3=1 
	recode f2worriedfin 1=3 3=1 
	recode p_f2worriedfin 1=3 3=1 
	label def worried 1 "No worries" 2 "Some worries" 3 "Big worries"
		label val worriedfin worried
		label val f2worriedfin worried
		label val p_worriedfin worried
		label val p_f2worriedfin worried
	drop d2worriedfin p_d2worriedfin
	gen d2worriedfin = f2worriedfin-worriedfin
	gen p_d2worriedfin = p_f2worriedfin-p_worriedfin

	foreach var of varlist $allv_selrlasso_tu_reason3_1 $baseline`mechvar' p_$baseline`mechvar' $fe {
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
			qui reg $baseline`y' tu2 `y' $allv_selrlasso_tu_reason3_1 $fe $baseline`mechvar' [aweight=w_tu2]
			est store m_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe p_$baseline`mechvar' [aweight=w_tu2] 
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			est store m_2
		}
		* Test whether direct/indirect effect are stat. different 
		suest m_1 m_2, vce(cluster persnr)
		est store mincpt2`depvar'`mechvar'
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
				qui reg $baseline`y' tu2 `y' $allv_selrlasso_tu_reason3_1 $fe $baseline`mechvar'  [aweight=w_tu2] if female==`x'
				est store m`x'_1
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
				qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 $fe p_$baseline`mechvar' [aweight=w_tu2] if female==`x'
				est store m`x'_2
				qui count if tu2==1 & e(sample)
				estadd scalar obs =r(N)
					qui count if tu2!=. & e(sample)
					estadd scalar obsall =r(N)
			}
			suest m`x'_1 m`x'_2, vce(cluster persnr)
			est store mgincpt2`depvar'`mechvar'`x'
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
			estadd scalar pval=r(p)
			restore
		}
	} /* End foreach: depvar */ 
} /* End foreach: mechvar */ 


* Make Table 
cap erase "$MY_FINAL_PATH\mech_spousal_ue_$treat.tex"
estout PDS_minc2satisleisure PDS_minc2worriedfin PDS_mfulltsmoke1 PDS_mfulltsmoke0 PDS_mfulltlncigd1 PDS_mfulltlncigd0 using "$MY_FINAL_PATH\mech_spousal_ue_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{6}{l}{\textbf{Panel A: pooled sample}} & \\) append
estout PDS_mginc2satisleisure0 PDS_mginc2worriedfin0 PDS_mgfulltsmoke1_0 PDS_mgfulltsmoke0_0 PDS_mgfulltlncigd1_0 PDS_mgfulltlncigd0_0 using "$MY_FINAL_PATH\mech_spousal_ue_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m0_1_mean:tu2 "\ \ \ Own unemployment" m0_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&\\ \multicolumn{6}{l}{\textbf{Panel B: unemployment of males}} & \\) append
estout PDS_mginc2satisleisure1 PDS_mginc2worriedfin1 PDS_mgfulltsmoke1_1 PDS_mgfulltsmoke0_1 PDS_mgfulltlncigd1_1 PDS_mgfulltlncigd0_1 using "$MY_FINAL_PATH\mech_spousal_ue_$treat.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m1_1_mean:tu2 "\ \ \ Own unemployment" m1_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&\\ \multicolumn{6}{l}{\textbf{Panel C: unemployment of females}} & \\) append
exit
