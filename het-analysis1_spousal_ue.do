set more off 

******************************************************************************************************
*                                                                                                    *
*					Heterogenerous treatment effect analysis, pt. 1	                          	     *
*                                                                                                    *
******************************************************************************************************
foreach noyes in 0 1 {
	foreach noyes2 in 0 1 {
		foreach dep_var_2 in smoke lncigday {

		use "${MY_OUT_PATH}\analysis_imputmeans.dta", clear
		* Restrict sample, part 3 
		keep if ${baseline}smoke!=. & p_${baseline}smoke!=. & ${baseline}lncigday!=. & p_${baseline}lncigday!=.
		keep if partner==1 
		keep if age<=60
		drop if age<=17
		keep if smoke==`noyes' & p_smoke==`noyes2'

		foreach var of varlist $xvars $pvars {
			keep if `var'!=.
		}
		keep if welle>=2004
		drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1
		save "${MY_OUT_PATH}\analysis_mh2.dta", replace

		rename tu2 tu2old
		rename $treat tu2

		* Step 2: Do calculations

		* Pooled (main specification) 
		foreach y in `dep_var_2'  {
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
		}
		* Test whether direct/indirect effect are stat. different 
		suest m_1 m_2, vce(cluster persnr)
		est store m4`dep_var_2'smoking`noyes'`noyes2'
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m_1_mean]tu2 - [m_2_mean]tu2=0
		estadd scalar pval=r(p)
		} /*end: foreach dep_var_2 */
	} /*end: foreach noyes */
} /*end: foreach noyes2 */


******************************************************************************************************
*                                                                                                    *
*					heterogenerous treatment effect analysis, pt. 1	                          	     *
* 								no-non smoker subsasmple 											 * 
*                                                                                                    *
******************************************************************************************************
foreach noyes in 0 1 {
	foreach noyes2 in 0 1 {
		foreach dep_var_2 in smoke lncigday {

		use "${MY_OUT_PATH}\analysis_imputmeans.dta", clear
		* Restrict sample, part 3 
		keep if ${baseline}smoke!=. & p_${baseline}smoke!=. & ${baseline}lncigday!=. & p_${baseline}lncigday!=.
		keep if partner==1 
		keep if age<=60
		drop if age<=17
		keep if smoke==`noyes' & p_smoke==`noyes2'
		gen neversmoke=eversmoke_imput==0 & smoke==0
		gen p_neversmoke=p_eversmoke_imput==0 & p_smoke==0
		drop if neversmoke==1 | p_neversmoke==1 

		foreach var of varlist $xvars $pvars {
			keep if `var'!=.
		}
		keep if welle>=2004
		drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1
		save "${MY_OUT_PATH}\analysis_mh2.dta", replace

		rename tu2 tu2old
		rename $treat tu2

		* Step 2: Do calculations

		* Pooled (main specification) 
		foreach y in `dep_var_2'  {
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
		}
		* Test whether direct/indirect effect are stat. different 
		suest m_1 m_2, vce(cluster persnr)
		est store m4`dep_var_2'smoking`noyes'`noyes2'nonon
		qui count if tu2==1 & e(sample)
		estadd scalar obs =r(N)
			qui count if tu2!=. & e(sample)
			estadd scalar obsall =r(N)
		test [m_1_mean]tu2 - [m_2_mean]tu2=0
		estadd scalar pval=r(p)
		} /*end: foreach dep_var_2 */
	} /*end: foreach noyes */
} /*end: foreach noyes2 */


* Make table, for part 1
cap erase "$MY_FINAL_PATH\het1_spousal_ue.tex"
estout m4smokesmoking00 m4smokesmoking01 m4smokesmoking10 m4smokesmoking11 m4smokesmoking00nonon m4smokesmoking01nonon m4smokesmoking10nonon using "$MY_FINAL_PATH\het1_spousal_ue.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{7}{l}{\textbf{Panel A: effect on smoking status}} & \\) append
estout m4lncigdaysmoking00 m4lncigdaysmoking01 m4lncigdaysmoking10 m4lncigdaysmoking11 m4lncigdaysmoking00nonon m4lncigdaysmoking01nonon m4lncigdaysmoking10nonon using "$MY_FINAL_PATH\het1_spousal_ue.tex", stat(pval obs obsall, fmt(3 0 0) labels("\ \ \ \textit{p-value of difference}" "\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(m_1_mean:tu2 "\ \ \ Own unemployment" m_2_mean:tu2 "\ \ \ Spousal unemployment" ) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{7}{l}{\textbf{Panel B: effect on smoking intensity}} & \\) append
exit	
