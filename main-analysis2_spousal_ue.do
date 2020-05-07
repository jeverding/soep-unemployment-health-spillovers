set more off
clear

****************************************************************************************************
****																							****
**** 							Run: Lasso / Post-Double-Selection 								****
****																							****
****************************************************************************************************
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear

keep if age<=60
drop if age<=17

rename tu2 tu2old
rename $treat tu2

foreach var of varlist $allv_selrlasso_tu_reason3_1 {
	keep if `var'!=.
}

* Minor extension 1: Check if same couple appears more than once in treatment or control group 
by tu2 hhnr, sort: gen nvals = _n == 1 
by tu2: replace nvals = sum(nvals)
by tu2: replace nvals = nvals[_N]
tab nvals tu2 
by tu2 persnr, sort: gen nvals2 = _n == 1 
by tu2: replace nvals2 = sum(nvals2)
by tu2: replace nvals2 = nvals2[_N]
tab nvals2 tu2 

bysort tu2 hhnr: gen idnval = _N
bysort tu2 persnr: gen idnval2 = _N
gen multtreat=idnval>1 & tu2==1 & idnval!=.
gen multtreat2=idnval2>1 & tu2==1 & idnval2!=.

* Minor extension 2: Check timing of unemployment experiences 
gen tpostunemp=.
replace tpostunemp=f2inmonth-f2endmonth	if f2endmonth!=.
replace tpostunemp=f2inmonth-f1endmonth	if f2endmonth==. & f1endmonth!=.
egen meanttpostunemp=mean(tpostunemp) 
sum meanttpostunemp 
* (Mean observed unemployment duration: 12.78 months) 


* PDS Step 2.1: Calculate entropy balancing weights by gender 
save "${MY_OUT_PATH}\analysis_lasso4.dta", replace
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\analysis_lasso4.dta", clear	
	keep if female==`yesno' 
	sort random
	ebalance tu2 $wv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_*, gen(w_tu2) maxiter(100000) targets(2) 
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
		* Regression with entropy balancing weight for directly affected spouse 
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2]
		est store m_1
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		* Regression with entropy balancing weight for indirectly affected spouse
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2] 
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		est store m_2
		* Compute information criteria 
		qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2], vce(cluster persnr /*psu*/)
		local adjrsq_1 =e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		return list
		matrix temp_1=r(S)
		local aic_1 = temp_1[1,5]
		local bic_1 = temp_1[1,6]
		
		qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2], vce(cluster persnr /*psu*/)
		
		local adjrsq_2 =e(r2_a)
		qui count if tu2==1 & e(sample)
		local obs2 =2*r(N)
		estat ic
		return list
		matrix temp_2=r(S)
		local aic_2 = temp_2[1,5]
		local bic_2 = temp_2[1,6]
	}
	* Test whether direct/indirect effect are stat. different 
	suest m_1 m_2, vce(cluster persnr)
	est store PDS_m4`depvar'
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
		foreach y in `depvar' {
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2] if female==`x'
			est store m`x'_1
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2] if female==`x'
			est store m`x'_2
			qui count if tu2==1 & e(sample)
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample)
				estadd scalar obsall =r(N)
			* Compute information criteria 
			qui reg $baseline`y' tu2 $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2] if female==`x', vce(cluster persnr /*psu*/)
			
			local adjrsq_`x'_1 = e(r2_a)
			qui count if tu2==1 & e(sample)
			local obs2 =2*r(N)
			estat ic
			return list
			matrix temp_`x'_1=r(S)
			local aic_`x'_1 = temp_`x'_1[1,5]
			local bic_`x'_1 = temp_`x'_1[1,6]
			
			qui reg p_$baseline`y' tu2 p_`y' $allv_selrlasso_tu_reason3_1 branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_* [aweight=w_tu2] if female==`x', vce(cluster persnr /*psu*/)
			
			local adjrsq_`x'_2 = e(r2_a)
			qui count if tu2==1 & e(sample)
			local obs2 =2*r(N)
			estat ic
			matrix temp_`x'_2=r(S)
			local aic_`x'_2 = temp_`x'_2[1,5]
			local bic_`x'_2 = temp_`x'_2[1,6]
		}
		suest m`x'_1 m`x'_2, vce(cluster persnr)
		est store PDS_mg4`depvar'`x'
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

save "$MY_OUT_PATH\PDS_main_plant closure_.dta", replace

* Make Table 
cap erase "$MY_FINAL_PATH\main-analysis-tab2_spousal_ue.tex"
estout m2smoke m4smoke PDS_m4smoke m2lncigday m4lncigday PDS_m4lncigd using "$MY_FINAL_PATH\main-analysis-tab2_spousal_ue.tex", stat(pval obs obsall bic_1 bic_2 adjrsq_1 adjrsq_2, fmt(3 0 0 2 2 2) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N" "\ \ \ BIC\$_{Own unemployment}$" "\ \ \ BIC\$_{Spousal unemployment}$" "\ \ \ adj. R$^{2}_{Own unemployment}$" "\ \ \ adj. R$^{2}_{Spousal unemployment}$")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{6}{l}{\textbf{Panel A: unemployment of all couples}} & \\) append
estout mg2smoke0 mg4smoke0 PDS_mg4smoke0 mg2lncigday0 mg4lncigday0 PDS_mg4lncigd0 using "$MY_FINAL_PATH\main-analysis-tab2_spousal_ue.tex", stat(pval obs obsall bic_0_1 bic_0_2 adjrsq_0_1 adjrsq_0_2, fmt(3 0 0 2 2 2) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N" "\ \ \ BIC\$_{Own unemployment}$" "\ \ \ BIC\$_{Spousal unemployment}$" "\ \ \ adj. R$^{2}_{Own unemployment}$" "\ \ \ adj. R$^{2}_{Spousal unemployment}$")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m0_1_mean:tu2 "\ \ \ Own unemployment" m0_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&\\ \multicolumn{6}{l}{\textbf{Panel B: unemployment of males}} & \\) append
estout mg2smoke1 mg4smoke1 PDS_mg4smoke1 mg2lncigday1 mg4lncigday1 PDS_mg4lncigd1 using "$MY_FINAL_PATH\main-analysis-tab2_spousal_ue.tex", stat(pval obs obsall bic_1_1 bic_1_2 adjrsq_1_1 adjrsq_1_2, fmt(3 0 0 2 2 2) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N" "\ \ \ BIC\$_{Own unemployment}$" "\ \ \ BIC\$_{Spousal unemployment}$" "\ \ \ adj. R$^{2}_{Own unemployment}$" "\ \ \ adj. R$^{2}_{Spousal unemployment}$")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m1_1_mean:tu2 "\ \ \ Own unemployment" m1_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\addlinespace &&&&&&\\ \multicolumn{6}{l}{\textbf{Panel C: unemployment of females}} & \\) append	
exit
