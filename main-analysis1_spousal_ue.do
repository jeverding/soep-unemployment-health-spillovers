set more off

******************************************************************************************************
*                                                                                                    *
*						          		main specification	                          	             *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_imputmeans.dta", clear
rename tu2 tu2old
rename $treat tu2
* Restrict sample, part 3 
keep if ${baseline}smoke!=. & p_${baseline}smoke!=. & ${baseline}lncigday!=. & p_${baseline}lncigday!=.
keep if partner==1 
keep if age<=60
drop if age<=17

foreach var of varlist $xvars $pvars {
	keep if `var'!=.
}
keep if welle>=2004
drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1
save "${MY_OUT_PATH}\analysis_mh2.dta", replace


* Step 1: Calculate entropy balancing weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_mh2.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $xvars $pvars branch_* welle_* , gen(w_tu2) maxiter(100000) targets(2) 
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
use "$MY_OUT_PATH\analysis_mh2.dta", clear	
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 


* Step 2: Do calculations
foreach dep_var_2 in smoke lncigday {

* Pooled (Main specification) 
foreach y in `dep_var_2'  {
	* Regression with entropy balancing weight for directly affected spouse
	qui reg $baseline`y' tu2 $xvars $pvars branch_* [weight=w_tu2]
	est store m_1
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	* Regression with entropy balancing weight for indirectly affected spouse
	qui reg p_$baseline`y' tu2 p_`y' $pvars $xvars branch_* [weight=w_tu2] 
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	est store m_2
	* Compute information criteria 
	qui reg $baseline`y' tu2 $xvars $pvars branch_* [weight=w_tu2], vce(cluster persnr)
	local adjrsq_1 =e(r2_a)
	qui count if tu2==1 & e(sample)
	local obs2 =2*r(N)
	estat ic
	matrix temp_1=r(S)
	local aic_1 = temp_1[1,5]
	local bic_1 = temp_1[1,6]

	qui reg p_$baseline`y' tu2 p_`y' $pvars $xvars branch_* [weight=w_tu2], vce(cluster persnr)
	
	local adjrsq_2 =e(r2_a)
	qui count if tu2==1 & e(sample)
	local obs2 =2*r(N)
	estat ic
	matrix temp_2=r(S)
	local aic_2 = temp_2[1,5]
	local bic_2 = temp_2[1,6]
}
* Test whether direct/indirect effect are stat. different 
suest m_1 m_2, vce(cluster persnr)
est store m4`dep_var_2'
qui count if tu2==1 & e(sample)
estadd scalar obs =r(N)
	qui count if tu2!=. & e(sample)
	estadd scalar obsall =r(N)
test [m_1_mean]tu2 - [m_2_mean]tu2=0
estadd scalar pval=r(p)
estadd scalar aic_1 = `aic_1' 
estadd scalar bic_1 = `bic_1' 
estadd scalar aic_2 = `aic_2' 
estadd scalar bic_2 = `bic_2' 
estadd scalar adjrsq_1 = `adjrsq_1'
estadd scalar adjrsq_2 = `adjrsq_2'

* Gender-specific analyses
foreach x in 0 1 {
	preserve
	keep if female==`x'
	foreach y in `dep_var_2' {
		qui reg $baseline`y' tu2 $xvars $pvars branch_* [weight=w_tu2] if female==`x'
		est store m`x'_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' $pvars $xvars branch_* [weight=w_tu2] if female==`x'
		est store m`x'_2
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		* Compute information criteria 
		qui reg $baseline`y' tu2 $xvars $pvars branch_* [weight=w_tu2] if female==`x', vce(cluster persnr)
		
		local adjrsq_`x'_1 = e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		matrix temp_`x'_1=r(S)
		local aic_`x'_1 = temp_`x'_1[1,5]
		local bic_`x'_1 = temp_`x'_1[1,6]
		
		qui reg p_$baseline`y' tu2 p_`y' $pvars $xvars branch_* [weight=w_tu2] if female==`x', vce(cluster persnr)
		
		local adjrsq_`x'_2 = e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		matrix temp_`x'_2=r(S)
		local aic_`x'_2 = temp_`x'_2[1,5]
		local bic_`x'_2 = temp_`x'_2[1,6]
	}
	suest m`x'_1 m`x'_2, vce(cluster persnr)
	est store mg4`dep_var_2'`x'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
	estadd scalar pval=r(p)
	estadd scalar aic_`x'_1 = `aic_`x'_1' 
	estadd scalar bic_`x'_1 = `bic_`x'_1' 
	estadd scalar aic_`x'_2 = `aic_`x'_2' 
	estadd scalar bic_`x'_2 = `bic_`x'_2' 
	estadd scalar adjrsq_`x'_1 = `adjrsq_`x'_1'
	estadd scalar adjrsq_`x'_2 = `adjrsq_`x'_2'
	restore
}
	

* Simple DiD (without matching) 
foreach y in `dep_var_2' {
	qui reg $baseline`y' tu2 `y'
	est store m_1
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	qui reg p_$baseline`y' tu2 p_`y'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	est store m_2
	* Compute information criteria 
	qui reg $baseline`y' tu2 `y', vce(cluster persnr)
	
	local adjrsq_1 =e(r2_a)
	qui count if tu2==1 & e(sample)
	local obs2 =2*r(N)
	estat ic
	matrix temp_1=r(S)
	local aic_1 = temp_1[1,5]
	local bic_1 = temp_1[1,6]
	
	qui reg p_$baseline`y' tu2 p_`y', vce(cluster persnr)
	
	local adjrsq_2 =e(r2_a)
	qui count if tu2==1 & e(sample)
	local obs2 =2*r(N)
	estat ic
	matrix temp_2=r(S)
	local aic_2 = temp_2[1,5]
	local bic_2 = temp_2[1,6]
}
suest m_1 m_2, vce(cluster persnr)
est store m2`dep_var_2'
qui count if tu2==1 & e(sample)
estadd scalar obs =r(N)
	qui count if tu2!=. & e(sample)
	estadd scalar obsall =r(N)
test [m_1_mean]tu2 - [m_2_mean]tu2=0
estadd scalar pval=r(p)
estadd scalar aic_1 = `aic_1' 
estadd scalar bic_1 = `bic_1' 
estadd scalar aic_2 = `aic_2' 
estadd scalar bic_2 = `bic_2' 
estadd scalar adjrsq_1 = `adjrsq_1'
estadd scalar adjrsq_2 = `adjrsq_2'

* Gender-specific analyses 
foreach x in 0 1 {
	preserve
	keep if female==`x'
	foreach y in `dep_var_2' {
		qui reg $baseline`y' tu2 `y' if female==`x'
		est store m`x'_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		qui reg p_$baseline`y' tu2 p_`y' if female==`x'
		est store m`x'_2
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		* Compute information criteria 
		qui reg $baseline`y' tu2 `y' if female==`x', vce(cluster persnr)
		
		local adjrsq_`x'_1 = e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		matrix temp_`x'_1=r(S)
		local aic_`x'_1 = temp_`x'_1[1,5]
		local bic_`x'_1 = temp_`x'_1[1,6]
		
		qui reg p_$baseline`y' tu2 p_`y' if female==`x', vce(cluster persnr)
		
		local adjrsq_`x'_2 = e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		matrix temp_`x'_2=r(S)
		local aic_`x'_2 = temp_`x'_2[1,5]
		local bic_`x'_2 = temp_`x'_2[1,6]
	}
	suest m`x'_1 m`x'_2, vce(cluster persnr)
	est store mg2`dep_var_2'`x'
	qui count if tu2==1 & e(sample)
	estadd scalar obs =r(N)
		qui count if tu2!=. & e(sample)
		estadd scalar obsall =r(N)
	test [m`x'_1_mean]tu2 - [m`x'_2_mean]tu2=0
	estadd scalar pval=r(p)
	estadd scalar aic_`x'_1 = `aic_`x'_1' 
	estadd scalar bic_`x'_1 = `bic_`x'_1' 
	estadd scalar aic_`x'_2 = `aic_`x'_2' 
	estadd scalar bic_`x'_2 = `bic_`x'_2' 
	estadd scalar adjrsq_`x'_1 = `adjrsq_`x'_1'
	estadd scalar adjrsq_`x'_2 = `adjrsq_`x'_2'
	restore
}

} /* End foreach: Define outcome */
save "$MY_OUT_PATH\main_plant closure_.dta", replace

exit	
