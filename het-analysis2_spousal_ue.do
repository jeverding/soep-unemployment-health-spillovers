set more off

******************************************************************************************************
*                                                                                                    *
*					Heterogenerous treatment effect analysis, part 2	                             *
*                                                                                                    *
******************************************************************************************************
foreach noyes in neversmoke formersmoke smoke { 
	foreach dep_var_2 in smoke lncigday {
		use "${MY_OUT_PATH}\analysis_imputmeans.dta", clear 

		* Restrict sample, part 3 
		keep if ${baseline}smoke!=. & p_${baseline}smoke!=. & ${baseline}lncigday!=. & p_${baseline}lncigday!=.
		keep if partner==1 
		keep if age<=60
		drop if age<=17
		gen neversmoke=eversmoke_imput==0 & smoke==0
		gen p_neversmoke=p_eversmoke_imput==0 & p_smoke==0
		gen formersmoke=eversmoke_imput==1 & smoke==0
		gen p_formersmoke=p_eversmoke_imput==1 & p_smoke==0

		foreach var of varlist $xvars $pvars {
			keep if `var'!=.
		}
		keep if welle>=2004
		drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1
		save "${MY_OUT_PATH}\analysis_mh2.dta", replace 

		rename tu2 tu2old
		rename $treat tu2

		* Step 2: Do calculations 
		foreach y in `dep_var_2'  {
			reg $baseline`y' tu2 `y' if `noyes'==1, vce(cluster persnr)
			count if tu2==1 & e(sample) & `noyes'==1
			est store m_1`dep_var_2'_`noyes'
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample) & `noyes'==1
				estadd scalar obsall =r(N)
			reg p_$baseline`y' tu2 p_`y' if p_`noyes'==1, vce(cluster persnr)
			count if tu2==1 & e(sample) & p_`noyes'==1
			estadd scalar obs =r(N)
				qui count if tu2!=. & e(sample) & p_`noyes'==1
				estadd scalar obsall =r(N)
			est store m_2`dep_var_2'_p_`noyes'
		}
	} /*end: foreach dep_var_2 ... */
} /*end: foreach noyes ... */


* Make table 
cap erase "$MY_FINAL_PATH\het1_spousal_ue_$treat.tex"
estout m_1smoke_neversmoke m_1smoke_formersmoke m_1smoke_smoke using "$MY_FINAL_PATH\het1_spousal_ue_$treat.tex", stat(obs obsall, fmt(0 0) labels("\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(tu2 "\ \ \ Own unemployment") ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{3}{l}{\textbf{Panel A: effect on smoking status}} & \\) append
estout m_2smoke_p_neversmoke m_2smoke_p_formersmoke m_2smoke_p_smoke using "$MY_FINAL_PATH\het1_spousal_ue_$treat.tex", stat(obs obsall, fmt(0 0) labels("\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(tu2 "\ \ \ Spousal unemployment") ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) append
estout m_1lncigday_neversmoke m_1lncigday_formersmoke m_1lncigday_smoke using "$MY_FINAL_PATH\het1_spousal_ue_$treat.tex", stat(obs obsall, fmt(0 0) labels("\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(tu2 "\ \ \ Own unemployment") ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) posthead(\multicolumn{3}{l}{\textbf{Panel B: effect on smoking intensity}} & \\) append
estout m_2lncigday_p_neversmoke m_2lncigday_p_formersmoke m_2lncigday_p_smoke using "$MY_FINAL_PATH\het1_spousal_ue_$treat.tex", stat(obs obsall, fmt(0 0) labels("\ \ \ N\$_{Treated}$" "\ \ \ N")) cell(b(star fmt(3)) se(par fmt(3))) ///
	keep(tu2) collabels(none) mlabels(none) eqlabels(none) varlabels(tu2 "\ \ \ Spousal unemployment") ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01) append
exit	
