clear 
clear mata
clear matrix
set more off
set maxvar 32000
set matsize 11000

******************************************************************************************************
* Step 1: Estimation of propensity score 
use "${MY_OUT_PATH}\analysis_lasso3.dta", clear
rename tu2 tu2old
rename $treat tu2
probit tu2 $wv_selrlasso_tu_reason3_1
predict ps if e(sample), xb
save "$MY_OUT_PATH\ps_main.dta", replace

* Calculate weights by gender 
foreach yesno in 0 1 {
	use "$MY_OUT_PATH\ps_main.dta", clear	
	keep if female==`yesno' 
	sort random
	qui psmatch2 tu2, outcome(${baseline}lncigd) kernel  kerneltype(normal) bw(0.06) ps(ps) 
	gen w_kern=_weight
	keep persnr welle w_kern _* ps
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine the sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
keep persnr welle w_kern ps
rename w_kern w_ps
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\PDS_main_plant closure_$imput.dta", clear
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Code up variable labels (style: LaTeX) 
label var badhlth "Poor\;health$^+$"
label var goodhlth "Good\;health$^+$"
label var medhlth "Medium\;health$^+$"
label var p_badhlth "Poor\;health$^+$"
label var p_goodhlth "Good\;health$^+$"
label var p_medhlth "Medium\;health$^+$"
label var mig "Migrant$^+$"
label var p_mig "Migrant$^+$"
label var age "Age"
label var p_age "Age"
label var erwzeit "Tenure"
label var married "Married$^+$"
label var kidsyes "Children$^+$"
label var allbet_1 "Small\;company$^+$"
label var allbet_2 "Small\;to\;medium\;company$^+$"
label var allbet_3 "Medium\;company$^+$"
label var allbet_4 "Large\;company$^+$"
label var allbet_6 "No\;company\;info$^+$"
label var jsec_1 "Major\;job\;worries$^+$"
label var jsec_2 "Some\;job\;worries$^+$"
label var jsec_3 "No\;job\;worries$^+$"
label var jsec_4 "No\;info$^+$"
label var psbil2_1 "Basic\;schooling$^+$"
label var psbil2_2 "Intermediate\;schooling$^+$"
label var psbil2_3 "Technical\;college$^+$"
label var psbil2_4 "Highest\;secondary$^+$"
label var p_psbil2_1 "Basic\;schooling$^+$"
label var p_psbil2_2 "Intermediate\;schooling$^+$"
label var p_psbil2_3 "Technical\;college$^+$"
label var p_psbil2_4 "Highest\;secondary$^+$"
label var uni "University$^+$"
label var voctrain "Vocational\;training$^+$"
label var p_uni "University$^+$"
label var p_voctrain "Vocational\;training$^+$"
label var labinc "Labor\;earnings"
label var p_labinc "Labor\;earnings"
label var lnlabinc "Log\;labor\;earnings"
label var p_lnlabinc "Log\;labor\;earnings"
label var nounemp "Never\;unemployed$^+$"
label var p_nounemp "Never\;unemployed$^+$"
label var female "Female$^+$"
label var welle "Survey\;year"
label var foreigner "Non-German$^+$"
label var p_foreigner "Non-German$^+$"
label var expft "Years\;full-time"
label var lnexpft "Log\;years\;full-time"
label var mcs "Mental\;health"
label var p_mcs "Mental\;health"
label var pcs "Physical\;health"
label var p_pcs "Physical\;health"
label var al "Regional\;unemployment"
label var p_fullt "Works\;full-time$^+$"
label var p_partt "Works\;part-time$^+$"
label var notempl "Not\;working$^+$"
label var p_notempl "Not\;working$^+$"
	drop welle_*
	qui tab welle, gen(welle_)
label var welle_1 "Year\;2004$^+$"
label var welle_2 "Year\;2006$^+$"
label var welle_3 "Year\;2008$^+$"
label var welle_4 "Year\;2010$^+$"
label var welle_5 "Year\;2012$^+$"
label var welle_6 "Year\;2014$^+$"
label var branch_1 "Primary\;sector$^+$"
label var branch_2 "Manufacturing$^+$"
label var branch_3 "Energy\;and\;water$^+$"
label var branch_4 "Construction$^+$"
label var branch_5 "Wholesale\;and\;retail$^+$"
label var branch_6 "Hotel\;and\;restaurants$^+$"
label var branch_7 "Transport$^+$"
label var branch_8 "Banking\;and\;insurance$^+$"
label var branch_9 "Health\;services$^+$"
label var branch_10 "Other\;services$^+$"
label var ps "Propensity\;score"

replace diet=diet/100
replace p_diet=p_diet/100
label var diet "Unhealthy\;diet" 
label var p_diet "Unhealthy\;diet" 
label var hlthydiet "Healthy\;diet$^+$"
label var p_hlthydiet "Healthy\;diet$^+$"
label var unhlthydiet "Unhealthy\;diet$^+$"
label var p_unhlthydiet "Unhealthy\;diet$^+$"
label var bmi "Body\;mass\;index"
label var p_bmi "Body\;mass\;index"
label var height "Height\;in\;centimeters"
label var p_height "Height\;in\;centimeters"
label var heightmeter "Height\;in\;meters"
label var p_heightmeter "Height\;in\;meters"
label var weight "Weight\;in\;kilograms"
label var p_weight "Weight\;in\;kilograms"
label var obese2 "Obese$^+$"
label var p_obese2 "Obese$^+$"
label var smoke "Baseline\;smoker$^+$"
label var l2smoke "Lagged\;baseline\;smoker$^+$"
label var p_smoke "Spouse\;baseline\;smoker$^+$"
label var pkv "Private\;health\;insurance$^+$"
label var p_pkv "Private\;health\;insurance$^+$"
label var pkv_imput "Private\;health\;insurance$^+$"
label var p_pkv_imput "Private\;health\;insurance$^+$"
label var pkv_miss "No\;health\;insurance\;info$^+$"
label var p_pkv_miss "No\;health\;insurance\;info$^+$"
label var churchorrelig "Religious$^+$"
label var p_churchorrelig "Religious$^+$"
label var under50 "Aged\;under\;50\;years$^+$"
label var p_under50 "Aged\;under\;50\;years$^+$"
label var agegrp_1 "Aged\;under\;40$^+$"
label var agegrp_2 "Aged\;40\;to\;under\;65$^+$"
label var agegrp_3 "Aged\;65\;and\;older$^+$"
label var p_agegrp_1 "Aged\;under\;40$^+$"
label var p_agegrp_2 "Aged\;40\;to\;under\;65$^+$"
label var p_agegrp_3 "Aged\;65\;and\;older$^+$"
label var olderspouse "Spouse\;is\;older$^+$"
label var retired "Retired$^+$"
label var p_retired "Retired$^+$"
label var howner "Home\;owner$^+$"
label var socialflat "Social\;housing$^+$"
label var urban "Lives\;in\;urban\;area$^+$"
label var aprtmntbuilding "Home\;is\;appartment\;building$^+$"

* New variable names (PDS)
label var hdep_imp "Often\;melancholic$^+$"
label var p_hdep_imp "Spouse\;often\;melancholic$^+$"
label var hdep_mi "No/;often\;melancholic/;info$^+$"
label var p_hdep_mi "Spouse\;no/;often\;melancholic/;info$^+$"
label var wcoll_imp "White\;collar\;worker$^+$"
label var p_wcoll_imp "Spouse\;wh.\;collar\;worker$^+$"
label var wcoll_mi "No\;wh.\;col.\;worker\;info$^+$"
label var p_wcoll_mi "Spouse\;no\;wh.\;col.\;worker\;info$^+$"
label var bcoll_imp "Blue\;collar\;worker$^+$"
label var p_bcoll_imp "Spouse\;blue\;collar\;worker$^+$"
label var p_bcoll_mi "Spouse\;no\;bl.\;col.\;worker\;info$^+$"
label var badhlth_imp "Bad\;health$^+$"
label var p_badhlth_imp "Spouse\;bad\;health$^+$"
label var goodhlth_imp "Good\;health$^+$"
label var p_goodhlth_imp "Spouse\;good\;health$^+$"
label var medhlth_imp "Medium\;health$^+$"
label var p_medhlth_imp "Spouse\;medium\;health$^+$"
label var badhlth_mi "No\;self-rated\;health\;info$^+$"
label var p_badhlth_mi "Spouse\;no\;self-rated\;health\;info$^+$"
label var uwght "Underweight$^+$"
label var p_uwght "Spouse\;underweight$^+$"
label var owghtobese "Overweight\;or\;obese$^+$"
label var p_owghtobese "Spouse\;overweight\;or\;obese$^+$"
label var hvysmok "Heavy\;smoker$^+$"
label var p_hvysmok "Spouse\;heavy\;smoker$^+$"
label var evsmok_imp "Ever\;smoker$^+$"
label var p_evsmok_imp "Spouse\;ever\;smoker$^+$"
label var evsmok_mi "No\;ever\;smoker\;info$^+$"
label var p_evsmok_mi "Spouse\;no\;ever\;smoker\;info$^+$"
label var disab_imp "Disabled$^+$"
label var p_disab_imp "Spouse\;disabled$^+$"
label var disab_mi "No/;disabled/;info$^+$"
label var p_disab_mi "Spouse\;no/;disabled/;info$^+$"
label var cigd "No.\;of\;cigarettes/day$^a$" 
label var p_cigd "Spouse\;no.\;of\;cigarettes/day$^a$" 
label var lncigd "Log\;no.\;of\;cigarettes/day$^a$" 
label var l2lncigd "L2\;log\;no.\;of\;cigs/day$^a$" 
label var l2lncigd2 "L2\;sqrd.\;log\;no.\;of\;cigas/day$^a$" 
label var p_lncigd "Spouse\;log\;no.\;of\;cigs/day$^a$" 
label var l2p_lncigd "Spouse\;l2\;log\;no.\;of\;cigs/day$^a$" 
label var l2p_lncigd2 "Spouse\;l2\;sqrd.\;log\;no.\;of\;cigs/day$^a$" 
label var l2smoke "L2\;baseline\;smoker$^+$"
label var l2p_smoke "Spouse\;l2\;baseline\;smoker$^+$"
label var lnerwzeit "Log\;tenure" 

* Predictors for treatment tu_reason3_1 (including also lnerwzeit, lnlabinc) 
label var evsmok_impXjsec_1 "evsmok_impXjsec_1"
label var bcoll_impXallbet_1 "bcoll_impXallbet_1"
label var bcoll_impXjsec_1 "bcoll_impXjsec_1"
label var bcoll_impXp_notempl "bcoll_impXp_notempl"
	rename badhlth_impXp_foreigner bhlth_iXp_foreigner 
label var bhlth_iXp_foreigner "badhlth_impXp_foreigner"
label var p_owghtobeseXp_notempl "p_owghtobeseXp_notempl"
label var allbet_1Xjsec_1 "allbet_1Xjsec_1"
label var allbet_1Xp_notempl "allbet_1Xp_notempl"
label var jsec_1Xpsbil2_1 "jsec_1Xpsbil2_1"
label var ageXjsec_1 "ageXjsec_1"
label var alXpsbil2_1 "alXpsbil2_1"
global pred_treat lnerwzeit lnlabinc ageXjsec_1 alXpsbil2_1 jsec_1Xpsbil2_1 evsmok_impXjsec_1 bcoll_impXallbet_1 bcoll_impXjsec_1 bhlth_iXp_foreigner p_owghtobeseXp_notempl allbet_1Xjsec_1 allbet_1Xp_notempl 

* Predictors for outcomes (union of outcome-predictors; including also evsmok_imp lncigd l2smoke l2lncigd smoke l2lncigd2 p_lncigd l2p_smoke l2p_lncigd p_smoke p_evsmok_imp l2p_lncigd2) 
label var smokeXnounemp "smokeXnounemp"
	rename evsmok_impXp_evsmok_imp esmok_iXp_esmok_i
label var esmok_iXp_esmok_i "evsmok_impXp_evsmok_imp"
label var evsmok_impXbcoll_imp "evsmok_impXbcoll_imp"
label var evsmok_impXkidsyes "evsmok_impXkidsyes"
label var p_cigdXevsmok_imp "p_cigdXevsmok_imp"
label var bcoll_impXp_evsmok_imp "bcoll_impXp_evsmok_imp"
label var p_smokeXp_pkv_imput "p_smokeXp_pkv_imput"
label var p_smokeXp_nounemp "p_smokeXp_nounemp"
label var p_evsmok_impXvoctrain "p_evsmok_impXvoctrain"
label var p_evsmok_impXkidsyes "p_evsmok_impXkidsyes"
label var pcsXp_evsmok_imp "pcsXp_evsmok_imp"
label var expftXp_smoke "expftXp_smoke"
label var p_smokeXp_fullt "p_smokeXp_fullt"
global pred_outcomes smoke l2smoke evsmok_imp lncigd l2lncigd l2lncigd2 p_smoke l2p_smoke p_evsmok_imp p_lncigd l2p_lncigd l2p_lncigd2 /// 
	expftXp_smoke bcoll_impXp_evsmok_imp p_evsmok_impXvoctrain pcsXp_evsmok_imp smokeXnounemp evsmok_impXbcoll_imp evsmok_impXkidsyes p_cigdXevsmok_imp esmok_iXp_esmok_i p_smokeXp_fullt p_smokeXp_pkv_imput p_smokeXp_nounemp p_evsmok_impXkidsyes 


cap drop allbet_6 p_psbil2_6 psbil2_6 branch_11 
recast byte p_fullt
recast byte p_partt
recast byte p_notempl
recast byte notempl
recast byte olderspouse
recast byte owghtobese
recast byte p_owghtobese
recast byte bcoll_mi
recast byte p_bcoll_mi
recast byte pkv_miss
recast byte p_pkv_miss
recast byte evsmok_mi
recast byte p_evsmok_mi
recast byte badhlth_mi
recast byte p_badhlth_mi
recast byte alXpsbil2_1 
recast byte evsmok_impXjsec_1  
recast byte bcoll_impXallbet_1  
recast byte bcoll_impXjsec_1  
recast byte bcoll_impXp_notempl  
recast byte bhlth_iXp_foreigner  
recast byte p_owghtobeseXp_notempl  
recast byte allbet_1Xjsec_1  
recast byte allbet_1Xp_notempl 
recast byte bcoll_impXp_evsmok_imp  
recast byte p_evsmok_impXvoctrain  
recast byte smokeXnounemp  
recast byte evsmok_impXbcoll_imp  
recast byte evsmok_impXkidsyes  
recast byte esmok_iXp_esmok_i  
recast byte p_smokeXp_fullt  
recast byte p_smokeXp_pkv_imput  
recast byte p_smokeXp_nounemp  
recast byte p_evsmok_impXkidsyes  

gen support=1
gen weight_main = w_tu2 
* Recode variables 
replace labinc=labinc/1000
replace p_labinc=p_labinc/1000

global xvars_short1 age female foreigner erwzeit nounemp lnlabinc jsec_1 jsec_3 uni bmi hvysmok smoke evsmok_imp lncigd 
global xvars_short2 p_age p_mig p_foreigner p_lnlabinc p_notempl p_fullt p_bmi p_hvysmok p_smoke p_evsmok_imp p_lncigd 

* Code up table with descriptive statistics 
cap erase "$MY_FINAL_PATH\desc-stats2_${treat}.tex"

* Part 1 (code up stats for treatment predictor variables) 
foreach var of varlist $pred_treat {
	if "`: type `var''"=="byte" {
		replace `var'=`var'*100
	}
	qui sum `var' if tu2==1 &  support==1 & weight_main!=.
	scalar `var'_mean_t=r(mean) 
	local `var'_mean_b_t=r(mean) 
	local `var'_var_b_t=r(Var)
	qui sum `var' if tu2==0
	scalar `var'_mean_b_c=r(mean)
	local `var'_mean_b_c=r(mean) 
	local `var'_var_b_c=r(Var)
	scalar `var'_b= (``var'_mean_b_t' - ``var'_mean_b_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_b_c')) * 100
	qui sum `var' if tu2==0 [weight=weight_main]
	scalar `var'_mean_a_c=r(mean)
	local `var'_mean_a_c=r(mean) 
	local `var'_var_a_c=r(Var)
	scalar `var'_a= (``var'_mean_b_t' - ``var'_mean_a_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c'))  * 100
	matrix `var'_m_short = [`var'_mean_t,  `var'_mean_b_c,  `var'_mean_a_c, `var'_b, `var'_a]
	matrix rownames `var'_m_short = `: variable label `var''
	if "`: type `var''"=="byte" {
		replace `var'=`var'/100
	}
	estout matrix(`var'_m_short,  fmt(1 1 1 1 1)) using "$MY_FINAL_PATH\desc-stats2_${treat}.tex", append style(tex)  mlabels(none) collabels(none)
}
estout using "$MY_FINAL_PATH\desc-stats2_${treat}.tex", cell(none) posthead(\addlinespace \multicolumn{6}{l}{\textbf{Predictor variables: outcomes}} \\) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01)  collabels(none) mlabels(none) label append 

* Part 1 (code up stats for outcome predictor variables) 
foreach var of varlist $pred_outcomes {
	if "`: type `var''"=="byte" {
		replace `var'=`var'*100
	}
	qui sum `var' if tu2==1 &  support==1 & weight_main!=.
	scalar `var'_mean_t=r(mean) 
	local `var'_mean_b_t=r(mean) 
	local `var'_var_b_t=r(Var)
	qui sum `var' if tu2==0
	scalar `var'_mean_b_c=r(mean)
	local `var'_mean_b_c=r(mean) 
	local `var'_var_b_c=r(Var)
	scalar `var'_b= (``var'_mean_b_t' - ``var'_mean_b_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_b_c')) * 100
	qui sum `var' if tu2==0 [weight=weight_main]
	scalar `var'_mean_a_c=r(mean)
	local `var'_mean_a_c=r(mean) 
	local `var'_var_a_c=r(Var)
	scalar `var'_a= (``var'_mean_b_t' - ``var'_mean_a_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c'))  * 100
	matrix `var'_m_short = [`var'_mean_t,  `var'_mean_b_c,  `var'_mean_a_c, `var'_b, `var'_a]
	matrix rownames `var'_m_short = `: variable label `var''
	if "`: type `var''"=="byte" {
		replace `var'=`var'/100
	}
	estout matrix(`var'_m_short,  fmt(1 1 1 1 1)) using "$MY_FINAL_PATH\desc-stats2_${treat}.tex", append style(tex)  mlabels(none) collabels(none)
}
qui count if tu2==0 
local n0_short=r(N)
qui count if tu2==1 &  support==1 & weight_main!=. 
local n1_short=r(N)
estout using "$MY_FINAL_PATH\desc-stats2_${treat}.tex", cell(none) postfoot(\addlinespace \multicolumn{1}{l}{N} & \multicolumn{1}{l}{`n1_short'} & \multicolumn{1}{l}{`n0_short'} & \multicolumn{1}{l}{`n1_short'} && \\) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01)  collabels(none) mlabels(none) label append 
exit 
