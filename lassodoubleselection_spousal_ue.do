clear 
clear mata
clear matrix
set more off
set maxvar 32000
set matsize 11000

****************************************************************************************************
****																							****
**** 						Select variables: Lasso / Post-Double-Selection 					****
****																							****
****************************************************************************************************
* Note: Due to our empirical approach (DiD), need to control for dependent variables at baseline. Thus, partial them out in lasso selection steps 

* Load data for main sample 
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
keep if age<=60
drop if age<=17

* Step 1: Lasso Y on X. Control variable selection of controls correlated with outcome (address omitted var. bias) 
* Perform Step 1 four times for the four outcomes 
foreach x in "" p_ { 
	foreach depvar in smoke lncigd { 
		rlasso `x'${baseline}`depvar' $xp_man_allint, partial(`x'`depvar' branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_*) maxiter(1000000) 
		di "p=" e(p) 
		di "niter=" e(niter) 
		global yv_selrlasso_`x'`depvar' `e(selected)' `x'`depvar' 
	}
}

* Step 2: Lasso W on X. Control variable selection of controls predicting treatment 
foreach j in $treat {
	rlasso `j' $xp_man_allint, partial(branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 bula2_* welle_*) maxiter(1000000)
	di "p=" e(p)
	di "niter=" e(niter)
	global wv_selrlasso_`j' `e(selected)'
}


* Save unions of selected variables 
global ally_x_selrlasso : list global(yv_selrlasso_smoke) | global(yv_selrlasso_lncigd)
global ally_p_selrlasso : list global(yv_selrlasso_p_smoke) | global(yv_selrlasso_p_lncigd)
global ally_selrlasso : list global(ally_x_selrlasso) | global(ally_p_selrlasso)
foreach j in tu_reason3_1 {
	global allv_x_selrlasso_`j' : list global(ally_x_selrlasso) | global(wv_selrlasso_`j')
	global allv_p_selrlasso_`j' : list global(ally_p_selrlasso) | global(wv_selrlasso_`j')
	global allv_selrlasso_`j' : list global(ally_selrlasso) | global(wv_selrlasso_`j')
	local allv_n_`j' : word count $allv_selrlasso_`j' 
}

exit 
