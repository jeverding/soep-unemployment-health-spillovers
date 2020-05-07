clear 
clear mata
clear matrix
set more off
set maxvar 32000
set matsize 11000

****************************************************************************************************
****																							****
**** 				Select variables: Lasso / Post-Double-Selection for mechanisms 				****
****																							****
****************************************************************************************************
* Note: Due to our empirical approach (DiD), need to control for dependent variables at baseline. Thus, partial them out in lasso selection steps 

* Load data for main sample 
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17

* Step 1: Lasso Y on X. Control variable selection of controls correlated with outcomes from the analysis of mechanisms (address omitted var. bias) 
* Perform Step 1 eight times for the eight mechanism-outcomes 
foreach x in "" p_ {
	foreach depvar in satisinchh satisleisure homemaker worriedfin { 
		rlasso `x'${baseline}`depvar' $xp_man_allint `x'`depvar', partial(`x'`depvar' branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_*) maxiter(1000000)
		di "p=" e(p)
		di "niter=" e(niter)
		global yv_selrlasso_`x'`depvar' `e(selected)' `x'`depvar' 
	}
}

* Save unions of selected variables 
foreach j in tu_reason3_1 {
	foreach k in satisinchh satisleisure homemaker worriedfin {
		global allv_x_`k'_`j' : list global(yv_selrlasso_`k') | global(wv_selrlasso_`j')
		global allv_p_`k'_`j' : list global(yv_selrlasso_p_`k') | global(wv_selrlasso_`j')
		global allv_`k'_`j' : list global(allv_x_`k'_`j') | global(allv_p_`k'_`j')
		
		local allv_n : word count ${allv_`k'_`j'} 
		di "`allv_n'"
	}
}

exit 
