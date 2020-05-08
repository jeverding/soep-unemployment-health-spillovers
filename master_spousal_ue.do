******************************************************************************************************
******************************************************************************************************
*
* Authors: Jakob Everding, Jan Marcus 
* Title: The effect of unemployment on the smoking behavior of couples 
* Date: 11.07.2019 
*
* This replication script defines all relevant macros, the folder structure, and executes all do-
* files used to pre-process the SOEP data (version 33) and subsequently run the analyses from 
* Everding and Marcus (2020, Health Economics) 
*
*
******************************************************************************************************
******************************************************************************************************


******************************************************************************************************
*                                                                                                    *
*	         									Setup  										 		 *
*                                                                                                    *
******************************************************************************************************
clear all
set more off
set mem 400m

* Adjust path options
* Set local path 
global MY_PATH "C:\Users\...\spousal_ue\" 
* This is were the original SOEP data are; SOEP v.33 was used in the original paper 
global MY_IN_PATH  "${MY_PATH}01_Data\SOEP\v33\SOEP-CORE_v33_stata_bilingual\" 
* Folder for generated data sets
global MY_OUT_PATH  "${MY_PATH}03_Stata\01_Datasets\" 
* Folder for temporarily generated data sets
global MY_TEMP_PATH "${MY_PATH}03_Stata\02_Temp Datasets\" 
* Folder for tables etc.
global MY_FINAL_PATH "${MY_PATH}03_Stata\03_Ergebnisse-Graphs Tables etc\" 
* Folder for do-files
cd "${MY_PATH}03_Stata\04_Do Files\" 

/* 
* Note: Definition of different treatments 
tj: 			Plant closure regardless of subsequent unemployment status 
tu2: 			job loss due to plant closure (between t and t+2), subsequently unemployed 
t2: 			job loss due to plant closure (between t and t+2), subsequently employed again 
tu_reason2_2: 	job loss and unemployment due to dismissal 
tu_reason3_1: 	job loss and unemployment due to plant closure or dismissal 
tu_reason2_5: 	job loss and unemployment due to plant closure, not in year after baseline (thus, between t+1 and t+2) 
tu_all2: 		all reasons of job loss  with subsequent unemployment
tu_ue1: 		Plant closure with at least following period unemployed 
*/


******************************************************************************************************
*                                                                                                    *
*	         					Pull do-files, part 1 (pre-processing)						 		 *
*                                                                                                    *
******************************************************************************************************
* Pulls the data 
do "gen_spousal_ue.do"
* Transforms the data and generates the relevant variables
do "trans_spousal_ue.do" 
* Constructs and adds leads, lags, transformed variables (polynomials and log. trans.) and imputation flags 
do "candidatevar_spousal_ue.do"
* Fit Lasso regressions (PDS) on candidate variables 
do "pds_spousal_ue.do" 
* Fit Lasso regressions and select controls for analysis of mechanisms (i.e. alternative outcomes) 
do "pdsmech_spousal_ue.do" 


******************************************************************************************************
*                                                                                                    *
*	         					Define macros used in subsequent analyses  							 *
*                                                                                                    *
******************************************************************************************************
* Define dependent variable 
global dep_var smoke 

global xvars_wobula1_unbal0 age female mig foreigner /// 
		erwzeit lnlabinc nounemp bcollar_imput bcollar_miss allbet_* jsec_1 jsec_2 jsec_3 expft /// 
		/*Only excluded in summary stats due to space restrictions: branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10*/ ///
		psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
		pcs mcs ///
		badhlth_imput medhlth_imput goodhlth_imput ///
		height bmi underwght overwghtobese /// 
		heavysmkr eversmoke_imput eversmoke_miss 
global xvars_wobula2_unbal0  p_age p_mig p_foreigner ///
		p_lnlabinc p_nounemp p_bcollar_imput p_bcollar_miss p_notempl p_fullt p_partt /// 
		p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
		p_pcs p_mcs /// 
		p_badhlth_imput p_medhlth_imput p_goodhlth_imput /// 
		p_height p_bmi p_underwght p_overwghtobese ///
		p_heavysmkr p_eversmoke_imput p_eversmoke_miss 

global xvars_wobula1_unbal	$xvars_wobula1_unbal0 smoke lncigday
global xvars_wobula2_unbal	$xvars_wobula2_unbal0 p_smoke p_lncigday

global xvars_wobula1_unbal_t2	$xvars_wobula1_unbal0 l2smoke l2lncigday
global xvars_wobula2_unbal_t2	$xvars_wobula2_unbal0 p_l2smoke p_l2lncigday

global xvars_wobula1 $xvars_wobula1_unbal l2smoke l2lncigday 
global xvars_wobula2 $xvars_wobula2_unbal p_l2smoke p_l2lncigday
global xvars_wobula3 kidsyes married howner urban al welle_* 

* Full set of controls (=balanced t-2 - t+2) 
global xvars $xvars_wobula1 $xvars_wobula3 bula2_*  
global pvars $xvars_wobula2 
global exact welle_* female

* Set of controls pre-treatment dependant variables in t0 (at baseline) 
global xvars_unbal $xvars_wobula1_unbal $xvars_wobula3 bula2_* 
global pvars_unbal $xvars_wobula2_unbal 

* Set of controls pre-treatment dependant variables in t-2 
global xvars_unbal_t2 $xvars_wobula1_unbal_t2 $xvars_wobula3 bula2_* 
global pvars_unbal_t2 $xvars_wobula2_unbal_t2 

* Set of controls without any pre-treatment dependant variables 
global xvars_unbal_0 $xvars_wobula1_unbal0 $xvars_wobula3 bula2_* 
global pvars_unbal_0 $xvars_wobula2_unbal0 


* Define baseline and treatment 
global baseline d2 
global baselinef f2
global treat tu_reason3_1 

* Code up macro for fixed effect dummies 
global fe bula2_* welle_* branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10


* Code up additional macros for controls using renamed variables (for double-Lasso set of controls)
global ccdl_xvars_wobula1_unbal0 age female mig foreigner /// 
		erwzeit lnlabinc nounemp bcoll_imp bcoll_mi allbet_1 allbet_2 allbet_3 allbet_4 jsec_1 jsec_2 jsec_3 expft /// 
		/*Only excluded in summary stats due to space restrictions: branch_1 branch_2 branch_3 branch_4 branch_5 branch_6 branch_7 branch_8 branch_9 branch_10*/ ///
		psbil2_1 psbil2_2 psbil2_3 psbil2_4 uni voctrain ///
		pcs mcs ///
		badhlth_imp medhlth_imp goodhlth_imp ///
		height bmi uwght owghtobese /// 
		hvysmok evsmok_imp evsmok_mi 
global ccdl_xvars_wobula2_unbal0  p_age p_mig p_foreigner ///
		p_lnlabinc p_nounemp p_bcoll_imp p_bcoll_mi p_notempl p_fullt p_partt /// 
		p_psbil2_1 p_psbil2_2 p_psbil2_3 p_psbil2_4 p_uni p_voctrain  ///
		p_pcs p_mcs /// 
		p_badhlth_imp p_medhlth_imp p_goodhlth_imp /// 
		p_height p_bmi p_uwght p_owghtobese ///
		p_hvysmok p_evsmok_imp p_evsmok_mi 

global ccdl_xvars_wobula1_unbal	$ccdl_xvars_wobula1_unbal0 smoke lncigd
global ccdl_xvars_wobula2_unbal	$ccdl_xvars_wobula2_unbal0 p_smoke p_lncigd

global ccdl_xvars_wobula1_unbal_t2	$ccdl_xvars_wobula1_unbal0 l2smoke l2lncigd
global ccdl_xvars_wobula2_unbal_t2	$ccdl_xvars_wobula2_unbal0 l2p_smoke l2p_lncigd

global ccdl_xvars_wobula1 $ccdl_xvars_wobula1_unbal l2smoke l2lncigd 
global ccdl_xvars_wobula2 $ccdl_xvars_wobula2_unbal l2p_smoke l2p_lncigd
global ccdl_xvars_wobula3 kidsyes married howner urban al welle_* 

* Full set of controls (=balanced t-2 - t+2) 
global ccdl_xvars $ccdl_xvars_wobula1 $ccdl_xvars_wobula3 bula2_*  
global ccdl_pvars $ccdl_xvars_wobula2 
global ccdl_exact welle_* female


******************************************************************************************************
*                                                                                                    *
*	         					Pull do-files, part 2 (analyses) 								 	 *
*                                                                                                    *
******************************************************************************************************
* Performs the main analysis, without PDS (creates first part of Table 2) 
do "main-analysis1_spousal_ue.do" 
* Table for descriptive stats and matching quality, part 1 
do "desc-stats1_spousal_ue.do"
* Performs the main analysis, only PDS (creates second part of Table 2, generates Table 2) 
do "main-analysis2_spousal_ue.do" 
* Performs all PDS robustness analyses (generates Tables 5, A.2, A.3)
do "rob-analysis-pds_spousal_ue.do" 
* Investigates treatment effect heterogeneity by smoking status at baseline, part 1 (generates Table 4) 
do "het-analysis1_spousal_ue.do" 
* Investigates treatment effect heterogeneity by smoking status at baseline, part 2 (generates Table 3) 
do "het-analysis2_spousal_ue.do" 
* Analysis of mechanisms (generates table using PDS controls) 
do "mech_spousal_ue.do"
* Analysis of mechanisms (generates table using conventional set of controls, i.e. w/out PDS) 
do "mech2_spousal_ue.do" 
* Table for descriptive stats and matching quality, part 2 
do "desc-stats2_spousal_ue.do"
