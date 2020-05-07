set more off

******************************************************************************************************
* Step 0: Estimation of propensity score 
foreach yesno in 0 1 {
	use "${MY_OUT_PATH}\analysis_mh2.dta", clear
	keep if female==`yesno'
	probit tu2 $xvars $pvars branch_* 
	predict ps if e(sample), p
	gen w_match=1 if tu2==1
	replace w_match=ps/(1-ps) if tu2==0
	keep persnr welle w_match ps
	save "$MY_OUT_PATH\match_`yesno'.dta", replace
}
* Combine sub-datasets				
use 	"$MY_OUT_PATH\match_0.dta", clear
append using "$MY_OUT_PATH\match_1.dta"
foreach yesno in 0 1 {
	erase "$MY_OUT_PATH\match_`yesno'.dta"
}
sort persnr welle
keep persnr welle w_match ps
rename w_match w_ps
save "$MY_OUT_PATH\matched.dta", replace
use "$MY_OUT_PATH\main_plant closure_.dta", clear
merge 1:1 persnr welle using "${MY_OUT_PATH}\matched.dta", keep(master match) nogen 

* Code up variable labels (style: LaTeX) 
label var badhlth "Poor\;health$^+$"
label var goodhlth "Good\;health$^+$"
label var medhlth "Medium\;health$^+$"
label var p_badhlth "Poor\;health$^+$"
label var p_goodhlth "Good\;health$^+$"
label var p_medhlth "Medium\;health$^+$"
label var badhlth_imput "Poor\;health$^+$"
label var goodhlth_imput "Good\;health$^+$"
label var medhlth_imput "Medium\;health$^+$"
label var badhlth_miss "No\;self-rated\;health\;info$^+$"
label var p_badhlth_imput "Poor\;health$^+$"
label var p_goodhlth_imput "Good\;health$^+$"
label var p_medhlth_imput "Medium\;health$^+$"
label var p_badhlth_miss "No\;self-rated\;health\;info$^+$"
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
label var foreign "Non-German$^+$"
label var p_foreign "Non-German$^+$"
label var expft "Years\;full-time"
label var lnexpft "Log\;years\;full-time"
label var mcs "Mental\;health"
label var p_mcs "Mental\;health"
label var pcs "Physical\;health"
label var p_pcs "Physical\;health"
label var hdepress "Often\;melancholic$^+$"
label var p_hdepress "Often\;melancholic$^+$"
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
label var overwghtobese "Overweight\;or\;obese$^+$"
label var p_overwghtobese "Overweight\;or\;obese$^+$"
label var underwght "Underweight$^+$"
label var p_underwght "Underweight$^+$"
label var smoke "Baseline\;smoker$^+$"
label var l2smoke "Lagged\;baseline\;smoker$^{+}$" 
label var p_smoke "Baseline\;smoker$^+$"
label var p_l2smoke "Lagged\;baseline\;smoker$^{+}$" 
label var heavysmkr "Heavy\;smoker$^+$"
label var p_heavysmkr "Heavy\;smoker$^+$"
label var eversmoke_imput "Ever\;smoker$^+$"
label var p_eversmoke_imput "Ever\;smoker$^+$"
label var eversmoke_miss "No\;ever\;smoker\;info$^+$"
label var p_eversmoke_miss "No\;ever\;smoker\;info$^+$"
label var cigday "No.\;of\;cigarettes/day$^a$" 
label var p_cigday "No.\;of\;cigarettes/day$^a$" 
label var lncigday "Log\;no.\;of\;cigarettes/day$^a$" 
label var l2lncigday "Lagged\;log\;no.\;of\;cigarettes/day$^{a}$" 
label var p_lncigday "Log\;no.\;of\;cigarettes/day$^a$"	 
label var p_l2lncigday "Lagged\;log\;no.\;of\;cigarettes/day$^{a}$" 
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
label var disability "Disabled$^+$"	
label var p_disability "Disabled$^+$" 
label var agegrp_1 "Aged\;under\;40$^+$"
label var agegrp_2 "Aged\;40\;to\;under\;65$^+$"
label var agegrp_3 "Aged\;65\;and\;older$^+$"
label var p_agegrp_1 "Aged\;under\;40$^+$"
label var p_agegrp_2 "Aged\;40\;to\;under\;65$^+$"
label var p_agegrp_3 "Aged\;65\;and\;older$^+$"
label var olderspouse "Spouse is older$^+$"
label var wcollar "White\;collar\;worker$^+$"
label var p_wcollar "White\;collar\;worker$^+$"
label var bcollar "Blue\;collar\;worker$^+$"
label var p_bcollar "Blue\;collar\;worker$^+$"
label var bcollar_imput "Blue\;collar\;worker$^+$"
label var p_bcollar_imput "Blue\;collar\;worker$^+$"
label var bcollar_miss "No\;bl.\;col.\;worker\;info$^+$"
label var p_bcollar_miss "No\;bl.\;col.\;worker\;info$^+$"
label var retired "Retired$^+$"
label var p_retired "Retired$^+$"
label var howner "Home\;owner$^+$"
label var socialflat "Social\;housing$^+$"
label var urban "Lives\;in\;urban\;area$^+$"
label var aprtmntbuilding "Home\;is\;appartment\;building$^+$"

cap drop allbet_6 p_psbil2_6 psbil2_6 branch_11 
recast byte p_fullt
recast byte p_partt
recast byte p_notempl
recast byte notempl
recast byte olderspouse
recast byte overwghtobese
recast byte p_overwghtobese
recast byte bcollar_miss
recast byte p_bcollar_miss
recast byte pkv_miss
recast byte p_pkv_miss
recast byte eversmoke_miss
recast byte p_eversmoke_miss
recast byte badhlth_miss
recast byte p_badhlth_miss

gen support=1 
gen weight_main = w_tu2 
* Recode variables (i.e. values) 
replace labinc=labinc/1000
replace p_labinc=p_labinc/1000


* Code up table with descriptive statistics (pstest-table) 
cap erase "$MY_FINAL_PATH\desc-stats1_${treat}.tex" 

* Part 1 (code up stats for first set of variables) 
foreach var of varlist $xvars_wobula1 {
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
	local var_a_c=r(mean)  
	local `var'_mean_a_c=r(mean) 
	local `var'_var_a_c=r(Var)
	scalar `var'_a= (``var'_mean_b_t' - ``var'_mean_a_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c'))  * 100
	qui sum `var' if tu2==0 [weight=w_ps]
	scalar `var'_mean_a_c2=r(mean) 
	local var_a_c2=r(mean)  
	local `var'_mean_a_c2=r(mean) 
	local `var'_var_a_c2=r(Var)
	scalar `var'_a2= (``var'_mean_b_t' - ``var'_mean_a_c2')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c2'))  * 100
	matrix `var'_m = [`var'_mean_t,  `var'_mean_b_c,  `var'_mean_a_c,  `var'_mean_a_c2, `var'_b, `var'_a, `var'_a2]
	matrix rownames `var'_m = `: variable label `var''
	if "`: type `var''"=="byte" {
		replace `var'=`var'/100
	}
	estout matrix(`var'_m,  fmt(1)) using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", append style(tex)  mlabels(none) collabels(none)
}
qui reg tu2 bula2_*
est sto test
estout test using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", append style(tex)  mlabels(none) collabels(none) cell(none) ///
	posthead(\addlinespace \multicolumn{8}{l}{\textbf{Indirectly affected spouse}} \\)

* Part 2 (code up stats for second set of variables) 
foreach var of varlist $xvars_wobula2 {
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
	local var_a_c=r(mean)  
	local `var'_mean_a_c=r(mean) 
	local `var'_var_a_c=r(Var)
	scalar `var'_a= (``var'_mean_b_t' - ``var'_mean_a_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c'))  * 100
	qui sum `var' if tu2==0 [weight=w_ps]
	scalar `var'_mean_a_c2=r(mean) 
	local var_a_c2=r(mean)  
	local `var'_mean_a_c2=r(mean) 
	local `var'_var_a_c2=r(Var)
	scalar `var'_a2= (``var'_mean_b_t' - ``var'_mean_a_c2')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c2'))  * 100
	matrix `var'_m = [`var'_mean_t,  `var'_mean_b_c,  `var'_mean_a_c,  `var'_mean_a_c2, `var'_b, `var'_a, `var'_a2]
	matrix rownames `var'_m = `: variable label `var''
	if "`: type `var''"=="byte" {
		replace `var'=`var'/100
	}
	estout matrix(`var'_m,  fmt(1)) using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", append style(tex)  mlabels(none) collabels(none)
}
estout test using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", append style(tex)  mlabels(none) collabels(none) cell(none) ///
	posthead(\addlinespace \multicolumn{8}{l}{\textbf{Couple information}} \\)

* Part 3 (code up stats for third set of variables) 
foreach var of varlist $xvars_wobula3 {
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
	local var_a_c=r(mean)  
	local `var'_mean_a_c=r(mean) 
	local `var'_var_a_c=r(Var)
	scalar `var'_a= (``var'_mean_b_t' - ``var'_mean_a_c')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c'))  * 100
	qui sum `var' if tu2==0 [weight=w_ps]
	scalar `var'_mean_a_c2=r(mean) 
	local var_a_c2=r(mean)  
	local `var'_mean_a_c2=r(mean) 
	local `var'_var_a_c2=r(Var)
	scalar `var'_a2= (``var'_mean_b_t' - ``var'_mean_a_c2')/sqrt(0.5*(``var'_var_b_t' + ``var'_var_a_c2'))  * 100
	matrix `var'_m = [`var'_mean_t,  `var'_mean_b_c,  `var'_mean_a_c,  `var'_mean_a_c2, `var'_b, `var'_a, `var'_a2]
	matrix rownames `var'_m = `: variable label `var''
	if "`: type `var''"=="byte" {
		replace `var'=`var'/100
	}
	estout matrix(`var'_m,  fmt(1)) using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", append style(tex)  mlabels(none) collabels(none)
}
qui count if tu2==0
local n0=r(N)
qui count if tu2==1 &  support==1 & weight_main!=. 
local n1=r(N)
estout using "$MY_FINAL_PATH\desc-stats1_${treat}.tex", cell(none) postfoot(\addlinespace \multicolumn{1}{l}{N} & \multicolumn{1}{l}{`n1'} & \multicolumn{1}{l}{`n0'} & & &&& \\) ///
	style(tex) starlevels(* 0.1 ** 0.05 *** 0.01)  collabels(none) mlabels(none) label append 
exit 
