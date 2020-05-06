clear 
clear mata
clear matrix
set more off
set maxvar 32000
set matsize 11000


******************************************************************************************************
* Code up selected lead/lagged variables and impute dummy variables 		
use "${MY_OUT_PATH}\analysis_ue2.dta", clear
* Restrict sample, part 3 
keep if partner==1 
keep if age<=63
drop if age<=15
drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1

foreach x in "" p_ {
	foreach y in pkv eversmoke bcollar wcollar goodhlth badhlth medhlth churchorrelig retired disability hdepress homemaker {
		clonevar `x'`y'_imput=`x'`y'
		replace `x'`y'_imput=0 if `x'`y'==. 
		gen `x'`y'_miss=`x'`y'==.
	} 
} 
replace medhlth_imput=1 if medhlth==.

foreach x in "" p_ {
	capture confirm variable `x'overwghtobese 
	if !_rc==0 {
		gen `x'overwghtobese=.
		replace `x'overwghtobese		=1		if `x'bmi>=25 		& `x'bmi!=.
		replace `x'overwghtobese		=0 		if `x'bmi<25 		& `x'bmi!=.
	}
}

sort persnr welle	
foreach x in "" p_ {
	foreach n in 1 2 3 4 {
		foreach v in smoke lncigday	cigday heavysmkr eversmoke_imput eversmoke_miss bmi {
			capture confirm variable `x'l`n'`v' 
				if !_rc==0 {
				gen `x'l`n'`v'=l`n'.`x'`v'
			}
			capture confirm variable `x'f`n'`v' 
				if !_rc==0 {
				gen `x'f`n'`v'=f`n'.`x'`v'
			}
		}
	}
}

foreach var in nounemp p_nounemp al kidsyes p_pkv_imput voctrain pcs expft p_fullt lnerwzeit lnlabinc jsec_1 allbet_1 p_notempl p_foreigner age al psbil2_1 {
	capture confirm variable l2`var'
		if !_rc==0 {
		gen l2`var'	=	l2.`var'
	}
}

gen 	l2p_owghtobese	= l2.p_overwghtobese 
gen 	l2bcoll_imp		= l2.bcollar_imput
gen 	l2badhlth_imp	= l2.badhlth_imput

save "${MY_OUT_PATH}\analysis_imputmeans.dta", replace
******************************************************************************************************
*                                                                                                    *
*						  PDS: two-step variable selection	(Belloni et al. 2014)                    *
*                                                                                                    *
******************************************************************************************************
use "${MY_OUT_PATH}\analysis_imputmeans.dta", clear
foreach x in "" p_ {
	rename `x'hdepress_imput 		`x'hdep_imp
	rename `x'hdepress_miss 		`x'hdep_mi
	rename `x'wcollar_imput 		`x'wcoll_imp
	rename `x'wcollar_miss 			`x'wcoll_mi
	rename `x'bcollar_imput 		`x'bcoll_imp
	rename `x'bcollar_miss 			`x'bcoll_mi
	rename `x'badhlth_imput 		`x'badhlth_imp
	rename `x'medhlth_imput 		`x'medhlth_imp
	rename `x'goodhlth_imput 		`x'goodhlth_imp
	rename `x'badhlth_miss 			`x'badhlth_mi
	rename `x'underwght				`x'uwght
	rename `x'overwghtobese			`x'owghtobese
	rename `x'heavysmkr				`x'hvysmok
	rename `x'eversmoke_imput		`x'evsmok_imp
	rename `x'eversmoke_miss		`x'evsmok_mi
	rename `x'disability_imput		`x'disab_imp
	rename `x'disability_miss		`x'disab_mi
	rename `x'cigday				`x'cigd
	rename `x'lncigday				`x'lncigd
	rename `x'd2lncigday			`x'd2lncigd
	rename `x'd4lncigday			`x'd4lncigd
	rename `x'f2l2lncigday			`x'f2l2lncigd
}

* Define macros for variables, also combine sets of variables through macros 
global pds_xvars_wobula1_unbal0 age female mig foreigner hdep_imp hdep_mi /// 
		erwzeit labinc nounemp wcoll_imp wcoll_mi bcoll_imp bcoll_mi allbet_1 allbet_2 allbet_3 allbet_4 allbet_6 jsec_1 jsec_2 jsec_3 expft /// 
		branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 /// 
		psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
		pcs mcs ///
		badhlth_imp medhlth_imp goodhlth_imp badhlth_mi ///
		height weight bmi uwght owghtobese obese /// 
		hvysmok evsmok_imp evsmok_mi ///
		pkv_imput pkv_miss disab_imp disab_mi 
global pds_xvars_wobula2_unbal0  p_age p_mig p_foreigner p_hdep_imp p_hdep_mi ///
		p_labinc p_nounemp p_wcoll_imp p_wcoll_mi p_bcoll_imp p_bcoll_mi p_notempl p_fullt p_partt /// 
		p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
		p_pcs p_mcs /// 
		p_badhlth_imp p_medhlth_imp p_goodhlth_imp p_badhlth_mi /// 
		p_height p_weight p_bmi p_uwght p_owghtobese p_obese ///
		p_hvysmok p_evsmok_imp p_evsmok_mi ///
		p_pkv_imput p_pkv_miss p_disab_imp p_disab_mi 
global pds_xvars_wobula1 $pds_xvars_wobula1_unbal0 smoke cigd 
global pds_xvars_wobula2 $pds_xvars_wobula2_unbal0 p_smoke p_cigd 
global pds_xvars_wobula3 kidsyes married howner urban al welle_1 welle_2 welle_3 welle_4 welle_5 welle_6 welle_7 welle_8 welle_9 welle_10 welle_11 welle_12 welle_13 welle_14 welle_15 welle_16 welle_17 ///
	kids 
* Full set of controls (=balanced t-2 - t+2): 
global pds_xvars $pds_xvars_wobula1 $pds_xvars_wobula3 bula2_1 bula2_2 bula2_3 bula2_4 bula2_5 bula2_6 bula2_7 bula2_8 bula2_9 bula2_10 bula2_11 bula2_12 bula2_13 bula2_14 
global pds_pvars $pds_xvars_wobula2 
global pds_xp_vars $pds_xvars $pds_pvars
save "${MY_OUT_PATH}\analysis_lasso1.dta", replace


use "${MY_OUT_PATH}\analysis_lasso1.dta", clear 
*************************************************************************
*																		*
* 					Code up additional control variables 				*
*																		*
*************************************************************************
* Code up log. specifications of control variables 
foreach oldvar in lnexpft p_lnexpft {
	capture confirm variable `oldvar'
		if !_rc==1 {
		drop `oldvar'
		}
}

foreach var in erwzeit expft al kids {
	mvdecode `var', mv(-1 -2 -3 -4 -5 -6 -7 -8 -9)
	capture confirm variable ln`var'
		if !_rc==0 {
		gen ln`var'	=	ln(`var'+1)
		}
	global pds_xp_vars $pds_xp_vars ln`var'
}
foreach x in "" p_ {
	foreach var in age labinc pcs mcs height weight bmi cigd {
		mvdecode `x'`var', mv(-1 -2 -3 -4 -5 -6 -7 -8 -9)
		capture confirm variable `x'ln`var' 
			if !_rc==0 {
			gen `x'ln`var'=ln(`x'`var'+1)
			}
		global pds_xp_vars $pds_xp_vars `x'ln`var'
	}
}

* Code up lagged specifications of dependent variables at baseline, including transformations 
rename l2cigday 		l2cigd 
rename p_l2cigday 		l2p_cigd 
rename l2lncigday 		l2lncigd
rename p_l2lncigday 	l2p_lncigd 
rename p_l2smoke 		l2p_smoke
global pds_xp_vars $pds_xp_vars l2smoke l2p_smoke l2lncigd l2p_cigd l2cigd l2p_lncigd

foreach x in age p_age labinc p_labinc pcs p_pcs mcs p_mcs height p_height weight p_weight bmi p_bmi cigd p_cigd erwzeit expft al kids /// 
		l2cigd l2p_cigd l2lncigd l2p_lncigd lnage p_lnage lnlabinc p_lnlabinc lnpcs p_lnpcs lnmcs p_lnmcs lnheight p_lnheight lnweight p_lnweight /// 
		lnbmi p_lnbmi lncigd p_lncigd lnerwzeit lnexpft lnal /*lnnkids*/ lnkids { 
	capture confirm variable `x'2
		if !_rc==0 {
		gen `x'2=`x'^2
		}
	capture confirm variable `x'3
		if !_rc==0 {
		gen `x'3=`x'^3
		}
	global pds_xp_vars $pds_xp_vars `x'2 `x'3
} 

* Restrict sample, part 4 
keep if ${baseline}smoke!=. & p_${baseline}smoke!=. & ${baseline}lncigd!=. & p_${baseline}lncigd!=.
keep if partner==1 
foreach var of varlist $pds_xp_vars {
	keep if `var'!=.
}
keep if welle>=2004
drop if psbil2_6==1 | p_psbil2_6==1 | jsec_4==1
save "${MY_OUT_PATH}\analysis_lasso2.dta", replace


* Code up interactions of control variables, and second and third order polynomials 
use "${MY_OUT_PATH}\analysis_lasso2.dta", clear 
* Code up interactions of selected factorial vars.:
global xp_man_factinterac 

foreach x in smoke hvysmok evsmok_imp female mig foreigner wcoll_imp bcoll_imp uwght owghtobese obese badhlth_imp medhlth_imp goodhlth_imp pkv_imput disab_imp /// 
	p_smoke p_hvysmok p_evsmok_imp p_mig p_foreigner p_wcoll_imp p_bcoll_imp p_uwght p_owghtobese p_obese p_badhlth_imp p_medhlth_imp p_goodhlth_imp p_pkv_imput p_disab_imp /// 
	nounemp hdep_imp allbet_1 allbet_2 allbet_3 allbet_4 allbet_6 jsec_1 jsec_2 jsec_3 psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
	p_nounemp p_hdep_imp p_notempl p_fullt p_partt p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
	kidsyes married howner urban /// 
	branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 { 
	foreach var in smoke hvysmok evsmok_imp female mig foreigner wcoll_imp bcoll_imp uwght owghtobese obese badhlth_imp medhlth_imp goodhlth_imp pkv_imput disab_imp /// 
		p_smoke p_hvysmok p_evsmok_imp p_mig p_foreigner p_wcoll_imp p_bcoll_imp p_uwght p_owghtobese p_obese p_badhlth_imp p_medhlth_imp p_goodhlth_imp p_pkv_imput p_disab_imp /// 
		nounemp hdep_imp allbet_1 allbet_2 allbet_3 allbet_4 allbet_6 jsec_1 jsec_2 jsec_3 psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
		p_nounemp p_hdep_imp p_notempl p_fullt p_partt p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
		kidsyes married howner urban /// 
		branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 { 
		if ("`x'"!="`var'") {
			capture confirm variable `var'X`x'
			if !_rc==0 {
				gen `x'X`var'=`x'*`var'
				global xp_man_factinterac $xp_man_factinterac `x'X`var' 
			} /*End: capture confirm; ensures that no dubplicate interactions are coded (i.e. generate var1Xvar2 only if var2Xvar1 does not exist)*/
		}
	}
}

di "$xp_man_factinterac"
local xp_int1 : word count $xp_man_factinterac

di"`xp_int1'"
global xp_man_somefactint : list global(pds_xp_vars) | global(xp_man_factinterac)


* Code up interactions of factorial and continuous/count variables: 
global xp_man_factcontinterac 
foreach x in age p_age labinc p_labinc pcs p_pcs mcs p_mcs height p_height weight p_weight bmi p_bmi cigd p_cigd erwzeit expft al kids { 
	foreach var in smoke hvysmok evsmok_imp female mig foreigner wcoll_imp bcoll_imp uwght owghtobese obese badhlth_imp medhlth_imp goodhlth_imp pkv_imput disab_imp /// 
		p_smoke p_hvysmok p_evsmok_imp p_mig p_foreigner p_wcoll_imp p_bcoll_imp p_uwght p_owghtobese p_obese p_badhlth_imp p_medhlth_imp p_goodhlth_imp p_pkv_imput p_disab_imp /// 
		nounemp hdep_imp allbet_1 allbet_2 allbet_3 allbet_4 allbet_6 jsec_1 jsec_2 jsec_3 psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
		p_nounemp p_hdep_imp p_notempl p_fullt p_partt p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
		kidsyes married howner urban /// 
		branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10 { 
		if ("`x'"!="`var'") {
			capture confirm variable `var'X`x'
			if !_rc==0 {
				gen `x'X`var'=`x'*`var'
				global xp_man_factcontinterac $xp_man_factcontinterac `x'X`var' 
			} /*End: capture confirm; ensures that no dubplicate interactions are coded (i.e. generate var1Xvar2 only if var2Xvar1 does not exist)*/
		}
	}
}

di "$xp_man_factcontinterac"
local xp_int1 : word count $xp_man_factcontinterac

di"`xp_int1'"
global xp_man_allint : list global(xp_man_somefactint) | global(xp_man_factcontinterac)

local xp_n3 : word count $xp_man_allint
di"`xp_n3'"

/* Total set of generated candidate control variables: 4,188 */


save "${MY_OUT_PATH}\analysis_lasso3.dta", replace
exit 
