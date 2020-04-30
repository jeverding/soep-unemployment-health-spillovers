set more off
clear
clear matrix
set mem 400m

global MY_LOG_FILE ${MY_OUT_PATH}\trans_ue2.log

cap log close
log using "${MY_LOG_FILE}", text replace

use "${MY_OUT_PATH}\gen_ue2.dta", clear

***************************************************************************************************

*				Harmonize names of $P-Variables

***************************************************************************************************

* Why job terminated
	rename rp72 	artende2001
	rename sp72 	artende2002
	rename tp90 	artende2003
	rename up75 	artende2004
	rename vp96 	artende2005
	rename wp84 	artende2006
	rename xp90 	artende2007
	rename yp91 	artende2008
	rename zp87 	artende2009
	rename bap78 	artende2010
	rename bbp88 	artende2011
	rename bcp76 	artende2012
	rename bdp94 	artende2013
	rename bep81 	artende2014
	rename bfp29 	artende2015
	rename bgp28 	artende2016

* Month, last job ended previous year
	rename pp7001 	ende1_1999
	rename qp7001 	ende1_2000
	rename rp7001 	ende1_2001
	rename sp7001 	ende1_2002
	rename tp8801 	ende1_2003
	rename up7301 	ende1_2004
	rename vp9401 	ende1_2005  
	rename wp8201 	ende1_2006
	rename xp8801 	ende1_2007
	rename yp8901 	ende1_2008
	rename zp8501 	ende1_2009
	rename bap7601 	ende1_2010
	rename bbp8601 	ende1_2011
	rename bcp7401 	ende1_2012
	rename bdp9201 	ende1_2013
	rename bep7901 	ende1_2014
	rename bfp2701 	ende1_2015
	rename bgp2601 	ende1_2016

	rename pp7002 	ende2_1999
	rename qp7002 	ende2_2000
	rename rp7002 	ende2_2001
	rename sp7002 	ende2_2002
	rename tp8802 	ende2_2003
	rename up7302 	ende2_2004
	rename vp9402 	ende2_2005  
	rename wp8202 	ende2_2006
	rename xp8802 	ende2_2007
	rename yp8902 	ende2_2008
	rename zp8502 	ende2_2009
	rename bap7602	ende2_2010
	rename bbp8602	ende2_2011
	rename bcp7402	ende2_2012
	rename bdp9202	ende2_2013
	rename bep7902	ende2_2014
	rename bfp2702	ende2_2015
	rename bgp2602	ende2_2016

* Worried about job security
	rename pp10910 	jsec1999
	rename qp11810 	jsec2000
	rename rp11410 	jsec2001
	rename sp11310 	jsec2002
	rename tp12010 	jsec2003
	rename up12510 	jsec2004
	rename vp13110 	jsec2005
	rename wp12110 	jsec2006
	rename xp13010 	jsec2007
	rename yp13211 	jsec2008
	rename zp12812 	jsec2009
	rename bap13012	jsec2010
	rename bbp13113	jsec2011
	rename bcp12713	jsec2012
	rename bdp13314	jsec2013
	rename bep12311	jsec2014
	rename bfp14612	jsec2015
	rename bgp14812	jsec2016
 
* Run-down, Melancholy last 4 weeks
	rename sp8902 		depress2002
	rename up8602 		depress2004
	rename wp9002	 	depress2006
	rename yp10202		depress2008
	rename bap9002	 	depress2010
	rename bcp9402 		depress2012
	rename bep9202 		depress2014
	rename bgp10802 	depress2016

* Registered as unemployed
	rename pp05 	ue_reg1999
	rename qp04 	ue_reg2000
	rename rp09 	ue_reg2001
	rename sp10 	ue_reg2002
	rename tp13 	ue_reg2003
	rename up05 	ue_reg2004
	rename vp07 	ue_reg2005
	rename wp04 	ue_reg2006
	rename xp10 	ue_reg2007
	rename yp15 	ue_reg2008
	rename zp06 	ue_reg2009
	rename bap06 	ue_reg2010
	rename bbp06 	ue_reg2011
	rename bcp08 	ue_reg2012
	rename bdp15 	ue_reg2013
	rename bep09 	ue_reg2014
	rename bfp15 	ue_reg2015
	rename bgp13 	ue_reg2016
			
* Current Smoking status 
	rename pp106 		smoke1999
	rename rp10301		smoke2001
	clonevar smoke2000 = smoke2001
	rename sp9401 		smoke2002
	replace smoke2002=2 if (sp92==2 | sp9302==1) & smoke2002!=.
	rename up8901 		smoke2004
	rename wp9301 		smoke2006
	rename yp10601	 	smoke2008
	rename bap9501	 	smoke2010
	rename bcp9701		smoke2012
	rename bep9401 		smoke2014
	rename bgp112 		smoke2016 
	
* Number of cigaretts per day
	rename rp10302 		cigday2001
	clonevar cigday2000 = cigday2001
	rename sp9402 		cigday2002
	rename up8902 		cigday2004
	rename wp9302 		cigday2006
	rename yp10602 		cigday2008
	rename bap9502	 	cigday2010
	rename bcp9702	 	cigday2012
	rename bep9402 		cigday2014
	rename bgp11301 	cigday2016
	
* Ever/Never smoked before
	gen eversmoke=sp92==1 if sp92!=. & sp92>=0
	label def eversmoke 0 "Neversmoker" 1 "Eversmoker", replace
	label val eversmoke eversmoke 
	drop  sp92
	
	gen eversmoke12=bcp95==1 if bcp95!=. & bcp95>=0
	label def eversmoke12 0 "Neversmoker" 1 "Eversmoker", replace
	label val eversmoke12 eversmoke12 
	drop  bcp95
	gen eversmoke12age=bcp9601 if bcp9601!=. & bcp9601>=0
	drop bcp9601
	
* Regligion 
	gen religious1999=pp0411==1 | pp0411==2 if pp0411!=. & pp0411>0
	foreach y in 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
		local z=`y'+1
		gen religious`z'=religious`y' if religious`y'!=.
	}
	
	gen church2003=tp0901==1 | tp0901==2 | tp0901==3 | tp0901==4 if tp0901!=. & tp0901>0
	foreach y in 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
		local z=`y'+1
		gen church`z'=church`y' if church`y'!=. & tp0901>0
	}
	replace church2007=xp04==1 | xp04==2 | xp04==3 | xp04==4 if xp04!=. & xp04>0
	foreach y in 2007 2008 2009 2010 2011 2012 2013 2014 2015 {
		local z=`y'+1
		replace church`z'=church`y' if xp04!=. & xp04>0
	}
	replace church2011=bbp122==1 | bbp122==2 | bbp122==3 | bbp122==4 if bbp122!=. & bbp122>0
	foreach y in 2011 2012 2013 2014 2015 {
		local z=`y'+1
		replace church`z'=church`y' if bbp122!=. & bbp122>0
	}
	replace church2015=bfp167==1 | bfp167==2 | bfp167==3 | bfp167==4 if bfp167!=. & bfp167>0
	foreach y in 2015 {
		local z=`y'+1
		replace church`z'=church`y' if bfp167!=. & bfp167>0
	}

* Follows Health Conscious Diet 
	rename up87 		diet2004
	rename wp91 		diet2006
	rename yp104 		diet2008
	rename bap93	 	diet2010
	rename bcp98	 	diet2012
	rename bep95	 	diet2014
	
* Health insurance status 
	rename pp80 		hlthinsur1999
	rename qp80 		hlthinsur2000
	rename rp80 		hlthinsur2001
	rename sp103 		hlthinsur2002
	rename tp106 		hlthinsur2003
	rename up102 		hlthinsur2004
	rename vp115 		hlthinsur2005
	rename wp104 		hlthinsur2006
	rename xp109 		hlthinsur2007
	rename yp117 		hlthinsur2008
	rename zp107 		hlthinsur2009
	rename bap107	 	hlthinsur2010
	rename bbp109	 	hlthinsur2011
	rename bcp112	 	hlthinsur2012
	rename bdp123	 	hlthinsur2013
	rename bep106	 	hlthinsur2014
	rename bfp140	 	hlthinsur2015
	rename bgp131	 	hlthinsur2016
	
* Disability status 
	rename pp9701 		disabil1999
	rename qp9701		disabil2000
	rename rp9701		disabil2001
	rename sp9501		disabil2002
	rename tp9901		disabil2003
	rename up9201		disabil2004
	rename vp10501		disabil2005
	rename wp9601		disabil2006
	rename xp9901		disabil2007
	rename yp10901		disabil2008
	rename zp9601		disabil2009
	rename bap9801	 	disabil2010
	rename bbp10101	 	disabil2011
	rename bcp10401	 	disabil2012
	rename bdp11401	 	disabil2013
	rename bep9301	 	disabil2014
	rename bfp13101	 	disabil2015
	rename bgp109	 	disabil2016 
	
* Personal willingness to take risks 
	rename up119 		willrisk2004
	rename wp123		willrisk2006
	rename yp10 		willrisk2008
	rename zp121 		willrisk2009
	rename bap123 		willrisk2010
	rename bbp121		willrisk2011
	rename bcp148		willrisk2012
	rename bdp154		willrisk2013
	rename bep04 		willrisk2014
	rename bfp04 		willrisk2015
	rename bgp05 		willrisk2016

* Satisfaction with role in HH  
	rename sp0103		satisrolehh2002
	rename tp0103		satisrolehh2003
	rename up0103		satisrolehh2004
	rename vp0103		satisrolehh2005
	rename wp0103		satisrolehh2006
	rename xp0103		satisrolehh2007
	rename yp0104		satisrolehh2008
	rename zp0104		satisrolehh2009
	rename bap0104		satisrolehh2010
	rename bbp0104		satisrolehh2011
	rename bcp0104		satisrolehh2012
	rename bdp0104		satisrolehh2013
	rename bep0104		satisrolehh2014
	rename bfp0104		satisrolehh2015
	rename bgp0104		satisrolehh2016
	
* Satisfaction with HH income 
	rename sp0104		satisinchh2002
	rename tp0104		satisinchh2003
	rename up0104		satisinchh2004
	rename vp0104		satisinchh2005
	rename wp0104		satisinchh2006
	rename xp0104		satisinchh2007
	rename yp0105		satisinchh2008
	rename zp0105		satisinchh2009
	rename bap0105		satisinchh2010
	rename bbp0105		satisinchh2011
	rename bcp0105		satisinchh2012
	rename bdp0105		satisinchh2013
	rename bep0105		satisinchh2014
	rename bfp0105		satisinchh2015
	rename bgp0105		satisinchh2016

* Satisfaction with personal income 
	rename up0105		satisincpers2004
	rename vp0105		satisincpers2005
	rename wp0105		satisincpers2006
	rename xp0105		satisincpers2007
	rename yp0106		satisincpers2008
	rename zp0106		satisincpers2009
	rename bap0106		satisincpers2010
	rename bbp0106		satisincpers2011
	rename bcp0106		satisincpers2012
	rename bdp0106		satisincpers2013
	rename bep0106		satisincpers2014
	rename bfp0106		satisincpers2015
	rename bgp0106		satisincpers2016
	
* Satisfaction with amount of leisure time  
	rename sp0106		satisleisure2002
	rename tp0106		satisleisure2003
	rename up0108		satisleisure2004
	rename vp0107		satisleisure2005
	rename wp0107		satisleisure2006
	rename xp0107		satisleisure2007
	rename yp0109		satisleisure2008
	rename zp0108		satisleisure2009
	rename bap0108		satisleisure2010
	rename bbp0108		satisleisure2011
	rename bcp0108		satisleisure2012
	rename bdp0108		satisleisure2013
	rename bep0108		satisleisure2014
	rename bfp0108		satisleisure2015
	rename bgp0108		satisleisure2016
	
* Satisfaction with family life  
	rename wp0109		satisfamily2006
	rename xp0109		satisfamily2007
	rename yp0110		satisfamily2008
	rename zp0109		satisfamily2009
	rename bap0109		satisfamily2010
	rename bbp0110		satisfamily2011
	rename bcp0110		satisfamily2012
	rename bdp0110		satisfamily2013
	rename bep0110		satisfamily2014
	rename bfp0110		satisfamily2015
	rename bgp0110		satisfamily2016
	
* Political interests 
	rename sp110		politicint2002
	rename tp117		politicint2003
	rename up122		politicint2004
	rename vp128		politicint2005
	rename wp118		politicint2006
	rename xp127		politicint2007
	rename yp129		politicint2008
	rename zp122		politicint2009
	rename bap127		politicint2010
	rename bbp128		politicint2011
	rename bcp124		politicint2012
	rename bdp130		politicint2013
	rename bep118		politicint2014
	rename bfp143		politicint2015
	rename bgp143		politicint2016
	
* Worried about economic development 
	rename sp11301		worriedecon2002
	rename tp12001		worriedecon2003
	rename up12501		worriedecon2004
	rename vp13101		worriedecon2005
	rename wp12101		worriedecon2006
	rename xp13001		worriedecon2007
	rename yp13201		worriedecon2008
	rename zp12801		worriedecon2009
	rename bap13001		worriedecon2010
	rename bbp13101		worriedecon2011
	rename bcp12701		worriedecon2012
	rename bdp13301		worriedecon2013
	rename bep12301		worriedecon2014
	rename bfp14601		worriedecon2015
	rename bgp14801		worriedecon2016
	
* Worried about economic development 
	rename sp11302		worriedfin2002
	rename tp12002		worriedfin2003
	rename up12502		worriedfin2004
	rename vp13102		worriedfin2005
	rename wp12102		worriedfin2006
	rename xp13002		worriedfin2007
	rename yp13202		worriedfin2008
	rename zp12802		worriedfin2009
	rename bap13002		worriedfin2010
	rename bbp13102		worriedfin2011
	rename bcp12702		worriedfin2012
	rename bdp13302		worriedfin2013
	rename bep12302		worriedfin2014
	rename bfp14602		worriedfin2015
	rename bgp14802		worriedfin2016
	
* Worried about own health 
	rename qp11803		worriedhlth2000
	rename rp11403		worriedhlth2001
	rename sp11303		worriedhlth2002
	rename tp12003		worriedhlth2003
	rename up12503		worriedhlth2004
	rename vp13103		worriedhlth2005
	rename wp12103		worriedhlth2006
	rename xp13003		worriedhlth2007
	rename yp13203		worriedhlth2008
	rename zp12804		worriedhlth2009
	rename bap13004		worriedhlth2010
	rename bbp13104		worriedhlth2011
	rename bcp12704		worriedhlth2012
	rename bdp13305		worriedhlth2013
	rename bep12304		worriedhlth2014
	rename bfp14604		worriedhlth2015
	rename bgp14804		worriedhlth2016
	
* Satisfaction with own health 
	rename pp0101		satishlth1999
	rename qp0101		satishlth2000
	rename rp0101		satishlth2001
	rename sp0101		satishlth2002
	rename tp0101		satishlth2003
	rename up0101		satishlth2004
	rename vp0101		satishlth2005
	rename wp0101		satishlth2006
	rename xp0101		satishlth2007
	rename yp0101		satishlth2008
	rename zp0101		satishlth2009
	rename bap0101		satishlth2010
	rename bbp0101		satishlth2011
	rename bcp0101		satishlth2012
	rename bdp0101		satishlth2013
	rename bep0101		satishlth2014
	rename bfp0101		satishlth2015
	rename bgp0101		satishlth2016
	
* Satisfaction with Sleep 
	rename yp0102		satissleep2008
	rename zp0102		satissleep2009
	rename bap0102		satissleep2010
	rename bbp0102		satissleep2011
	rename bcp0102		satissleep2012
	rename bdp0102		satissleep2013
	rename bep0102		satissleep2014
	rename bfp0102		satissleep2015
	rename bgp0102		satissleep2016

* Hours of Sleep, weekend 
	rename yp10302		sleepweekend2008
	rename zp10402		sleepweekend2009
	rename bap9202		sleepweekend2010
	rename bbp9802		sleepweekend2011
	rename bcp9902		sleepweekend2012
	rename bdp11102		sleepweekend2013
	rename bfp12802		sleepweekend2015
	
* Hours of Sleep, weekdays 
	rename yp10301		sleepweekday2008
	rename zp10401		sleepweekday2009
	rename bap9201		sleepweekday2010
	rename bbp9801		sleepweekday2011
	rename bcp9901		sleepweekday2012
	rename bdp11101		sleepweekday2013
	rename bfp12801		sleepweekday2015
	
* Harmonize variable names of the $pgen-files I
local z = 1999
foreach y in p q r s t u v w x y z ba bb bc bd be bf bg {
	foreach w in famstd psbil pbbil01 pbbil02 bula erwzeit wum1 regtyp tatzeit {
		foreach x in `y'`w' {
			rename `x' `w'`z'
		}
	}
	local z = `z' + 1
}

* harmonize variable names of the $pequiv-files
foreach y in 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 {
	rename d11107`y' 	kids`y'
	rename m11126`y' 	hlthsat`y'
	rename i11110`y' 	labinc`y'
	rename m11101`y'	hsptl_lastyr`y'
	rename m11102`y'	count_hsptl_lastyr`y'
	rename m11103`y'	workaccident`y'
	rename m11104`y'	sport`y'
	rename m11105`y'	stroke`y'
	rename m11106`y'	bloodprss`y'
	rename m11107`y'	diabetes`y'
	rename m11108`y'	cancer`y'
	rename m11109`y'	psychproblems`y'
	rename m11110`y'	arthritis`y'
	rename m11111`y'	heartcond`y'
	rename m11124`y'	disability`y'
	rename m11125`y'	subj_hlthsat`y'
	rename m11127`y'	count_doc_lastyr`y'
	rename p11101`y'	lifesatisfac`y'
}

* Harmonize variable names of the $pgen-files II
local z = 1999
foreach y in 99 00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 {
	foreach w in expue expft owner rsubs partnr nace jobch stib month emplst allbet /* 
			*/ kids hlthsat labinc hsptl_lastyr count_hsptl_lastyr workaccident sport stroke bloodprss diabetes cancer psychproblems arthritis heartcond disability subj_hlthsat count_doc_lastyr lifesatisfac {
		foreach x in `w'`y' {
			rename `x' `w'`z'
		}
	}
	local z = `z' + 1
}

drop nace2_*
keep famstd* psbil* pbbil01* pbbil02*  kids* owner* rsubs* wum1* regtyp* ue_reg* artende* depress* jsec* stib* expue* expft* month* emplst* nace* mcs* pcs* mh_nbs* bmi* height* weight* /*
 	*/ bula* partnr* hlthsat* erwzeit* jobch* allbet* labinc* ende1_* ende2_* persnr hhnr hsample design psu germborn sex gebjahr migback /*
	*/ hlthinsur* smoke* eversmoke* eversmoke12* eversmoke12age* cigday* diet* /* 
	*/ stroke* bloodprss* diabetes* cancer* psychproblems* arthritis* heartcond* religious* church* disabil* /* 
	*/ hsptl_lastyr* count_hsptl_lastyr* workaccident* sport* disability* subj_hlthsat* count_doc_lastyr* lifesatisfac* /*
	*/ willrisk* tatzeit* satisinchh* satisincpers* satisrolehh* satisleisure* satisfamily* politicint* worriedecon* worriedfin* satissleep* sleepweekday* sleepweekend* worriedhlth* satishlth*

* Drop all individuals with multiple treatments per year:
bysort persnr: drop if _N>1

* Change data format from wide to long (variables hhnr, hsample, design, psu cannot be reshaped: time-constant)
reshape long famstd@ psbil@ pbbil01@ pbbil02@ kids@ owner@ rsubs@ wum1@ regtyp@ ue_reg@ artende@ depress@ jsec@ stib@ expue@ expft@ month@ emplst@ nace@ mcs@ pcs@ mh_nbs@ bmi@ height@ weight@ /*
	*/ bula@ partnr@ hlthsat@ erwzeit@ jobch@ allbet@ labinc@ ende1_@ ende2_@ /*
	*/ hlthinsur@ smoke@ cigday@ diet@ /* 
	*/ stroke@ bloodprss@ diabetes@ cancer@ psychproblems@ arthritis@ heartcond@ religious@ church@ disabil@ /* 
	*/ hsptl_lastyr@ count_hsptl_lastyr@ workaccident@ sport@ disability@ subj_hlthsat@ count_doc_lastyr@ lifesatisfac@	/* 
	*/ willrisk@ tatzeit@ satisinchh@ satisincpers@	satisrolehh@ satisleisure@ satisfamily@	politicint@	worriedecon@ worriedfin@ satissleep@ sleepweekday@ sleepweekend@ worriedhlth@ satishlth@ /* 
	*/, i(persnr) j(welle) string
destring welle, replace
sort 	persnr welle
xtset 	persnr welle
		
save "${MY_OUT_PATH}\trans_long.dta", replace

* Pull regional UE rates (available from https://www-genesis.destatis.de/genesis/online)
insheet using "$MY_FINAL_PATH\UE_Laender_bis_2016.csv", delimiter(";") names clear
local z=1
foreach x of varlist  badenwrttemberg -thringen {
	rename `x' al`z'
	local z = `z'+1
}
reshape long al, i(jahr) j(bland)
recode bland (1=8)(2=9)(3=11)(4=12)(5=4)(6=2)(7=6)(8=13)(9=3)(10=5)(11=7)(12=10)(13=14)(14=15)(15=1)(16=16), gen(bula)
drop bland
rename jahr welle
label var al "State unemployment rate"
save "${MY_TEMP_PATH}\regionalUE.dta", replace

use "${MY_OUT_PATH}\trans_long.dta", clear
merge m:1 bula welle using "${MY_TEMP_PATH}\regionalUE.dta", keep(master match) nogen

save "${MY_OUT_PATH}\trans_long.dta", replace
	
* Pull regional GDP per capita (available from http://www.vgrdl.de/VGRdL/index.jsp?lang=de-DE)
insheet using "$MY_FINAL_PATH\Mappe3.csv", delimiter(";") names clear
local z=1
foreach x of varlist  badenwrttemberg -thringen {
	rename `x' gdp`z'
	local z = `z'+1
}
reshape long gdp, i(jahr) j(bland)
recode bland (1=8)(2=9)(3=11)(4=12)(5=4)(6=2)(7=6)(8=13)(9=3)(10=5)(11=7)(12=10)(13=14)(14=15)(15=1)(16=16), gen(bula)
drop bland
rename jahr welle
label var gdp "State GDP per capita, in 2010 prices"
save "${MY_TEMP_PATH}\regionalGDP.dta", replace

use "${MY_OUT_PATH}\trans_long.dta", clear
merge m:1 bula welle using "${MY_TEMP_PATH}\regionalGDP.dta", keep(master match) nogen

save "${MY_OUT_PATH}\trans_long.dta", replace

* Pull regional income per capita (available from http://www.vgrdl.de/VGRdL/index.jsp?lang=de-DE)
insheet using "$MY_FINAL_PATH\170919_Income pro Kopf Laender_2010 prices.csv", delimiter(";") names clear
local z=1
foreach x of varlist  badenwrttemberg -thringen {
	rename `x' regincome`z'
	local z = `z'+1
}
reshape long regincome, i(jahr) j(bland)
recode bland (1=8)(2=9)(3=11)(4=12)(5=4)(6=2)(7=6)(8=13)(9=3)(10=5)(11=7)(12=10)(13=14)(14=15)(15=1)(16=16), gen(bula)
drop bland
rename jahr welle
label var regincome "State income per capita, in 2010 prices"
save "${MY_TEMP_PATH}\regionalincome.dta", replace

use "${MY_OUT_PATH}\trans_long.dta", clear
merge m:1 bula welle using "${MY_TEMP_PATH}\regionalincome.dta", keep(master match) nogen

save "${MY_OUT_PATH}\trans_long.dta", replace

* Recode missing values
mvdecode hlthsat jsec nace ende1_ ende2_ germborn erwzeit bula pcs mcs mh_nbs bmi height weight expue month stib /* 
	*/ expue  expft psbil pbbil01 pbbil02 famstd ue_reg allbet depress jobch emplst /*
	*/ hlthinsur diet /* 
	*/ stroke bloodprss diabetes cancer psychproblems arthritis heartcond /* 
	*/ hsptl_lastyr count_hsptl_lastyr workaccident sport disability subj_hlthsat count_doc_lastyr lifesatisfac	disabil owner rsubs wum1 regtyp /*
	*/ willrisk tatzeit satisinchh satisincpers satisleisure satisfamily politicint worriedecon worriedfin satissleep sleepweekday sleepweekend worriedhlth satishlth /*
	*/, mv(-1 -2 -3 -4 -5 -6 -7 -8 -9)
mvdecode smoke satisrolehh, mv(-1 -3 -4 -5 -6 -7 -8 -9)


***************************************************************************************************

*				Generating RHS Variables

***************************************************************************************************
label def yesno 0 "[0] no" 1 "[1] yes"

* Demographics
gen 	age=welle-gebjahr
gen 	age2=age^2
gen 	lnage=ln(age) 
gen 	married=famstd==1 | famstd==2 | famstd==6
gen 	alone=famstd==3 | famstd==5 
gen 	kidsyes=kids>0 if kids!=.
	label def kidsyes 0 "Childless" 1 "Kids", replace
	label val kidsyes kidsyes
gen 	mig=migback>1 if migback!=. & migback!=-1
	label def mig 0 "Autochthonal" 1 "Migrant", replace
	label val mig mig
gen 	foreigner=germborn==2 if germborn>0 & germborn!=.
gen 	female=sex==2 if sex!=.
	label def female 0 "Male"  1 "Female", replace
	label val female female
gen 	partner=partnr>0 & partnr!=.
	label def partner 0 "Single" 1 "Partner", replace
	label val partner partner
sort persnr welle
	label def religious 0 "Not religious" 1 "Religious", replace 
	label val religious religious 
gen churchorrelig=religious==1 if religious!=.
	replace churchorrelig=1 if church==1
	replace churchorrelig=0 if church==0 & churchorrelig==.
gen 	west=bula>=0 & bula<=10 if bula!=.
	label def west 0 "East" 1 "West", replace
	label val west west
gen howner=owner==1 if owner!=.
gen socialflat=rsubs==1 | rsubs==2 if rsubs!=.
gen urban=regtyp==1 if regtyp!=.
gen aprtmntbuilding=.
	replace aprtmntbuilding=1 if wum1>=4 & wum1<=8 & wum1!=.
	replace aprtmntbuilding=0 if wum1>=1 & wum1<=3 & wum1!=.
gen 	retireage=.
	replace retireage	=1	if age>=65	& age!=.
	replace retireage	=0	if age<65	& age!=.
gen 	under50=age<50 if age!=.
	label def under50 1 "Under50" 0 "Over50", replace
	label val under50 under50
gen 	under30=age<30 if age!=.
gen 	agegrp=.
	replace agegrp	=1	if age<40				& age!=.
	replace agegrp	=2	if age<65	& age>=40	& age!=.
	replace agegrp	=3	if age>=65				& age!=.
	qui tab agegrp, gen(agegrp_)
gen 	under60 = age<60 if age!=.

	
* Labor market information 
gen 	civserv=stib>600 & stib<700 if stib!=.
gen 	selfemp=stib>400 & stib<500 if stib!=.
gen 	wcollar=(stib>500 & stib<600) | stib==130	| stib==140  if stib!=.
gen 	bcollar=(stib>200 & stib<300) | stib==15 	| stib==120  if stib!=.
gen 	wcollar2=(stib>521 & stib<600) | stib==130	| stib==140  if stib!=.
	label def bcollar 0 "Not Bluecollar" 1 "Bluecollar", replace
	label val bcollar bcollar
	label def wcollar 0 "Not Whitecollar" 1 "Whitecollar", replace
	label val wcollar wcollar
	label def wcollar2 0 "Not Whitecollar" 1 "Whitecollar", replace
	label val wcollar2 wcollar2
gen 	unempl =stib==12 if stib!=. 
gen 	retired	=stib==13 if stib!=.
	label def retired 0 "Not retired" 1 "Retired", replace
	label val retired retired
gen 	labinc2=labinc^2
gen lnlabinc=ln(labinc+1)
gen lnlabinc2=lnlabinc^2
gen labinc30k=labinc>=30000 & labinc!=. 
gen labinc26k=labinc>=26000 & labinc!=. 
gen 	nounemp=expue==0 if expue!=.
gen 	erwzeit2=erwzeit^2
gen 	lnerwzeit=ln(erwzeit+1)
gen 	expft2=expft^2
gen 	lnexpft=ln(expft+1)
replace nace=999 if nace==.
replace allbet=99 if allbet==.
qui tab allbet, gen(allbet_)
replace jsec=99 if jsec==.
gen 	notempl=emplst==5 if emplst!=.
replace jsec=99	if jsec==-6
replace jsec=99	if jsec==-5	
qui tab jsec, gen(jsec_) 
gen 	branch=.
	replace branch=1  if nace>=1   & nace<=14														/* Primary Sector */
	replace branch=2  if (nace>=15 & nace<=37) |   nace==96	 | nace==97  |    nace==100				/* Manufacturing */
	replace branch=3  if nace>=40  & nace<=41   													/* Energy & Water */
	replace branch=4  if nace==45	            													/* Construction */
	replace branch=5  if nace>=50  & nace<=52      													/* Wholesale & Retail */
	replace branch=6  if nace==55 		      														/* Hotel & restaurants */
	replace branch=7  if nace>=60  & nace<=64      													/* Transport */
	replace branch=8  if nace>=65  & nace<=67      													/* Banking & Insurance */
	replace branch=9 if nace==85		   															/* Health services */
	replace branch=10 if (nace>=70 & nace<=80) |   nace>=90  & nace<=95  |   nace==98  | nace==99  	/* Other services */
	replace branch=99 if nace==999 																	/* missing */
	qui tab branch, gen(branch_)


* Education 
gen 	voctrain=pbbil01>=1 & pbbil01!=.
gen 	uni=pbbil02>=1 & pbbil02!=.
recode 	psbil (5=2) (.=99) (6=1), gen(psbil2)
	label 	val psbil2 zpsbil
	replace psbil2=f2.psbil2 if psbil2==99 & f2.psbil2!=99 	/* Imputed; applies only to persnr. 3828602: Fetch schooling info from subsequent year */ 
	qui tab psbil2, gen(psbil2_)
		
		
* Health	
gen 	badhlth=hlthsat==4 | hlthsat==5 if hlthsat!=.
gen 	goodhlth=hlthsat==1 | hlthsat==2 if hlthsat!=.
gen 	medhlth=hlthsat==3 if hlthsat!=.
gen 	mcs2=mcs^2
gen 	pcs2=pcs^2
qui gen hdepress=inlist(depress, 1, 2, 3)
replace diet=. 		if diet==-5
gen 	diet2=diet^2
gen hlthydiet=.
	gen unhlthydiet=.
	replace hlthydiet	=diet==3 	| diet==4	if diet!=.
	replace unhlthydiet	=diet==1	| diet==2	if diet!=.

gen 	sport2=sport^2
replace smoke=2 		if smoke==3 /* Applies only in 1999 */ 
replace smoke=0 		if smoke==2 /* Applies only in 1999 */ 
replace smoke=0 		if smoke==-2 & mod(welle,2)==0	/* Applies only in 2002 */ 
replace smoke=.			if smoke==-5 
							
replace cigday=0 		if smoke==0 & cigday==-2 & mod(welle,2)==0
replace cigday=. if cigday==-5
mvdecode cigday, mv(-1 -2 -3)
gen 	cigday2=cigday^2
gen 	cigday_miss=cigday==. 
gen 	lncigday=ln(cigday+1)
gen 	lncigday2=lncigday^2
gen 	smoke_miss=smoke==. 
replace eversmoke12=. if welle<gebjahr+eversmoke12age & eversmoke12age!=. & eversmoke12age>=0 & gebjahr!=. & gebjahr>=0 
replace eversmoke12=. if welle<2012 					& (eversmoke12age==. | eversmoke12age<0 | gebjahr==. | gebjahr<0)
replace eversmoke=1 if eversmoke12==1 & eversmoke12!=. 
replace	eversmoke=1 if (smoke==1 | l2.smoke==1 | l4.smoke==1 | l6.smoke==1 | l8.smoke==1 | l10.smoke==1 | l12.smoke==1 | l14.smoke==1) 
	label 	var eversmoke "Ever-smoker"
	drop eversmoke12
gen 	heavysmkr	=.
replace	heavysmkr	=0		if cigday<=20	& cigday!=.
replace	heavysmkr	=1		if cigday>20 	& cigday!=.
gen 	bmi2=bmi^2
gen 	height2=height^2
gen 	heightmeter=height/100
gen 	heightmeter2=heightmeter^2
gen 	weight2=weight^2
gen 	count_hsptl_lastyr2=count_hsptl_lastyr^2
gen 	count_doc_lastyr2=count_doc_lastyr^2
gen 	overwght2=.
	replace overwght2	=0 		if bmi<25 		& bmi!=.
	replace overwght2	=1		if bmi>=25 		& bmi!=.
gen 	overwght3=.
	replace overwght3	=1	if bmi>=25 		& bmi<30	& bmi!=.
	replace overwght3	=0	if bmi<25 		& bmi>=30	& bmi!=.
gen 	normalwght=.
	replace normalwght	=1	if bmi>=18.5 		& bmi<25	& bmi!=.
	replace normalwght	=0	if bmi<18.5 		& bmi>=25	& bmi!=.
gen obese2=.
	replace obese2	=0 		if bmi<30 		& bmi!=.
	replace obese2	=1		if bmi>=30 		& bmi!=.
gen overwght=.
	replace overwght	=0 		if bmi<=25 		& bmi!=.
	replace overwght	=1		if bmi>25 		& bmi!=.
gen obese=.
	replace obese	=0 		if bmi<=30 		& bmi!=.
	replace obese	=1		if bmi>30 		& bmi!=.
gen underwght=.
	replace underwght	=0 		if bmi>=18.5 	& bmi!=.
	replace underwght	=1		if bmi<18.5 	& bmi!=.
gen wghtcategory=.
	replace wghtcategory	=0	if bmi<18.5 				& bmi!=.
	replace wghtcategory	=1	if bmi>=18.5 	& bmi<=25	& bmi!=.
	replace wghtcategory	=2	if bmi>25 		& bmi<=30	& bmi!=.
	replace wghtcategory	=3	if bmi>30 					& bmi!=.
	label def wghtcategory 0 "Underweight" 1 "Normal weight" 2 "Overweight" 3 "Obese", replace
	label val wghtcategory wghtcategory wghtcategory wghtcategory
gen 	f2wghtcategory=f2.wghtcategory
gen 	f4wghtcategory=f4.wghtcategory
qui tab wghtcategory, gen(wghtcategory_)
gen 	wghtcategory2=.
	replace wghtcategory2	=0	if bmi<18.5 				& bmi!=.
	replace wghtcategory2	=1	if bmi>=18.5 	& bmi<25	& bmi!=.
	replace wghtcategory2	=2	if bmi>=25 		& bmi<30	& bmi!=.
	replace wghtcategory2	=3	if bmi>=30 					& bmi!=.
	label def wghtcategory2 0 "Underweight" 1 "Normal weight" 2 "Overweight" 3 "Obese", replace
	label val wghtcategory2 wghtcategory2 wghtcategory2 wghtcategory2
gen 	f2wghtcategory2=f2.wghtcategory2
gen 	f4wghtcategory2=f4.wghtcategory2
qui tab wghtcategory2, gen(wghtcategory2_) 
gen 	pkv=. 
	replace pkv=1 if hlthinsur==2 
	replace pkv=0 if hlthinsur==1 


* Regional variables
recode 	bula (11=0) (2=1) (4=3), gen(bula2)
	label 	val bula2 babula
	qui tab bula2, gen(bula2_)
gen 	al_miss=al==.
gen 	al2=al^2 
gen 	gdp2=gdp^2
gen 	regincome2=regincome^2

***************************************************************************************************

*				Generating variable lags/leads 

***************************************************************************************************
gen 	homemaker=.
	replace homemaker=0 if satisrolehh==-2
	replace homemaker=1 if satisrolehh>=0 & satisrolehh<=10 & satisrolehh!=.
	mvdecode satisrolehh, mv(-2)
gen 	smoke_recode=.
	replace smoke_recode=0 if smoke==1
	replace smoke_recode=1 if smoke==0

sort 	persnr welle		
foreach n in 1 2 3 4 {
	foreach v in mcs smoke cigday lncigday sport diet hlthydiet count_hsptl_lastyr count_doc_lastyr bmi labinc lnlabinc /*
					 */ willrisk tatzeit satisinchh satisincpers satisrolehh satisleisure satisfamily politicint worriedecon worriedfin homemaker satissleep sleepweekday sleepweekend worriedhlth satishlth smoke_recode {
		gen d`n'`v'=f`n'.`v'-`v'
		gen f`n'`v'=f`n'.`v'
		gen l`n'`v'=l`n'.`v'
	}
}			
gen 	f2d2smoke	=f2.d2smoke 
gen 	f2d2lncigday=f2.d2lncigday 
gen 	f2l2smoke	=f2.smoke		-l2.smoke
gen 	f2l2lncigday=f2.lncigday	-l2.lncigday

***************************************************************************************************

*				Treatment Indicators

***************************************************************************************************

* Exact definition of time of treatment 
gen 	endmonth=-23796 + ende2_ + welle*12
gen 	endmonth2=-23796 + ende1_ + (welle-1)*12
count 	if endmonth!=endmonth2 & endmonth!=. & endmonth2!=.
replace endmonth = endmonth2 if endmonth==.
drop 	endmonth2 ende1_ ende2_
gen 	inmonth=-23796 + month + welle*12 
label 	var endmonth "Month job finished with previous employer" /* endmonth: Jan. 1983=1, ..., Jan. 2001=217, ... */ 
gen 	f1endmonth	=	f1.endmonth
gen 	f2endmonth	=	f2.endmonth
gen 	f2inmonth	=	f2.inmonth

* Define treatment variables
replace artende=. if artende==-2

* Plant closure (artend==1) 
gen 	t=1 if (f1.artende==1 | f2.artende==1) & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
replace	t=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2)
replace	t=. if t==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.

* Plant closure + subsequently registered as unemployed
gen 	tu=1 if ((f2.artende==1 & f2.ue_reg==1) | (f1.artende==1 & f1.ue_reg==1 & f2.ue_reg==1)) & (emplst==1 | emplst==2) 
replace	tu=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
replace	tu=. if tu==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.

* Plant closure + registered as unemployed for at least following period 
gen 	tu_ue1=1 if ((f2.artende==1 & f2.ue_reg==1) | (f1.artende==1 & f1.ue_reg==1)) & (emplst==1 | emplst==2) 
replace	tu_ue1=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
replace	tu_ue1=. if tu_ue1==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
* All unemployed	
gen 	tu_all=1 if (emplst==1 | emplst==2) & f2.ue_reg==1
replace	tu_all=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
replace	tu_all=. if tu_all==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.

* Different reasons for unemployment	
gen 	tu_reason=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2)
	replace tu_reason=1 if tu_reason==. & (emplst==1 | emplst==2) & f2.ue_reg==1 & (f2.artende==1 | (f1.artende==1 & f1.ue_reg==1)) & (f1.endmonth==. | inmonth==. | f1.endmonth>=inmonth)
	replace tu_reason=2 if tu_reason==. & (emplst==1 | emplst==2) & f2.ue_reg==1 & (f2.artende==3 | (f1.artende==3 & f1.ue_reg==1)) & (f1.endmonth==. | inmonth==. | f1.endmonth>=inmonth)
	replace tu_reason=3 if tu_reason==. & (emplst==1 | emplst==2) & f2.ue_reg==1 & (f2.artende==5 | (f1.artende==5 & f1.ue_reg==1)) & (f1.endmonth==. | inmonth==. | f1.endmonth>=inmonth)
	replace tu_reason=4 if tu_reason==. & tu_all==1
	replace tu_reason=5 if tu_reason==. & (emplst==1 | emplst==2) & f1.jobch==2 & f2.ue_reg==1 & f2.artende==1 
	replace tu_reason=6 if tu_reason==. & (emplst==1 | emplst==2) & f1.ue_reg==1 & f1.artende==1 
	label def reason 0 "not unemployed" 1 "plant closure" 2 "dismissal" 3 "temporary contract ended" 4 "other" 5 "plant closure approx. 2 years later" 6 "plant closure for ever year outcomes"
	label val tu_reason reason
	label var tu_reason "Reason for unemployment"
	
* Job loss only (subsequently, in f2, registered as re-employed) due to plant closure or layoff
gen 	tjobloss=1 if (f1.artende==1 | f2.artende==1 | f1.artende==3 | f2.artende==3) & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
	replace	tjobloss=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2)
	replace	tjobloss=. if tjobloss==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
* Job loss unconditional on subsequent employment status (due to plant closure or layoff)
gen 	tucjobloss=1 if (f1.artende==1 | f2.artende==1 | f1.artende==3 | f2.artende==3) & (emplst==1 | emplst==2) 
	replace	tucjobloss=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2)
	replace	tucjobloss=. if tucjobloss==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
* Job loss + registered as unemployed for at least following period 
gen 	tjobloss1=1 if (((f2.artende==1 | f2.artende==3) & f2.ue_reg==1) | ((f1.artende==1 | f1.artende==3) & f1.ue_reg==1)) & (emplst==1 | emplst==2) 
	replace	tjobloss1=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
	replace	tjobloss1=. if tjobloss1==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
* Job loss + registered as unemployed for following period, but re-employed afterwards
gen 	tjoblossreemp=1 if ((f1.artende==1 | f1.artende==3) & f1.ue_reg==1) & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
	replace	tjoblossreemp=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
	replace	tjoblossreemp=. if tjoblossreemp==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
* Job loss + registered as unemployed for following period, irrespective of employment status in second wave
gen 	tjoblosslongt1=1 if ((f1.artende==1 | f1.artende==3) & f1.ue_reg==1) & (emplst==1 | emplst==2) 
	replace	tjoblosslongt1=0 if f2.jobch==2 & f1.jobch==2 & (emplst==1 | emplst==2) & (f2.emplst==1 | f2.emplst==2) 
	replace	tjoblosslongt1=. if tjoblosslongt1==1 & f1.endmonth<inmonth & f1.endmonth!=. & inmonth!=.
	
compress

save "${MY_OUT_PATH}\test.dta", replace


***************************************************************************************************

*				Merge partner infos

***************************************************************************************************
set more off 
use "${MY_OUT_PATH}\test.dta", clear
* Restrict sample, part 1 
keep if inlist(welle, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016)

* Add partner infos
preserve
	global pvar mcs pcs bmi weight height diet sport mig tu t tu_reason foreigner labinc emplst age* psbil2* hdepress nounemp female ///
		badhlth medhlth goodhlth uni voctrain labinc2 mcs2 pcs2 bmi2 weight2 height2 /// 
		diet2 hlthydiet sport2 smoke cigday lncigday count_hsptl_lastyr count_doc_lastyr ///
		cigday2 overwght overwght2 obese obese2 underwght heavysmkr religious church churchorrelig ///
		retireage pkv under50 under30 disability wghtcategory wghtcategory2 count_hsptl_lastyr2 count_doc_lastyr2 under60 ///
		retired wcollar wcollar2 bcollar unempl wghtcategory_* wghtcategory2_* unhlthydiet notempl ///
		lnlabinc lnlabinc2 lncigday2 lnage lnexpft lnerwzeit erwzeit expft ///
		d2hlthydiet smoke_miss cigday_miss ///
		overwght3 normalwght eversmoke d2labinc f2labinc d2lnlabinc f2lnlabinc ///
		willrisk tatzeit satisinchh satisincpers satisrolehh satisleisure satisfamily politicint worriedecon worriedfin homemaker worriedhlth satishlth ///
		f1willrisk f1tatzeit f1satisinchh f1satisincpers f1satisrolehh f1satisleisure f1satisfamily f1politicint f1worriedecon f1worriedfin f1homemaker f1worriedhlth f1satishlth ///
		l1willrisk l1tatzeit l1satisinchh l1satisincpers l1satisrolehh l1satisleisure l1satisfamily l1politicint l1worriedecon l1worriedfin l1homemaker l1worriedhlth l1satishlth ///
		d1willrisk d1tatzeit d1satisinchh d1satisincpers d1satisrolehh d1satisleisure d1satisfamily d1politicint d1worriedecon d1worriedfin d1homemaker d1worriedhlth d1satishlth /// 
		f2willrisk f2tatzeit f2satisinchh f2satisincpers f2satisrolehh f2satisleisure f2satisfamily f2politicint f2worriedecon f2worriedfin f2homemaker f2worriedhlth f2satishlth ///
		l2willrisk l2tatzeit l2satisinchh l2satisincpers l2satisrolehh l2satisleisure l2satisfamily l2politicint l2worriedecon l2worriedfin l2homemaker l2worriedhlth l2satishlth ///
		f3willrisk f3tatzeit f3satisinchh f3satisincpers f3satisrolehh f3satisleisure f3satisfamily f3politicint f3worriedecon f3worriedfin f3homemaker f3worriedhlth f3satishlth ///
		l3willrisk l3tatzeit l3satisinchh l3satisincpers l3satisrolehh l3satisleisure l3satisfamily l3politicint l3worriedecon l3worriedfin l3homemaker l3worriedhlth l3satishlth ///
		f4willrisk f4tatzeit f4satisinchh f4satisincpers f4satisrolehh f4satisleisure f4satisfamily f4politicint f4worriedecon f4worriedfin f4homemaker f4worriedhlth f4satishlth ///
		l4willrisk l4tatzeit l4satisinchh l4satisincpers l4satisrolehh l4satisleisure l4satisfamily l4politicint l4worriedecon l4worriedfin l4homemaker l4worriedhlth l4satishlth ///
		d2willrisk d2tatzeit d2satisinchh d2satisincpers d2satisrolehh d2satisleisure d2satisfamily d2politicint d2worriedecon d2worriedfin d2homemaker d2worriedhlth d2satishlth /// 
		satissleep sleepweekday sleepweekend /// 
		d1satissleep d1sleepweekday d1sleepweekend ///
		d2satissleep d2sleepweekday d2sleepweekend /// 
		f1satissleep f1sleepweekday f1sleepweekend /// 
		l1satissleep l1sleepweekday l1sleepweekend /// 
		f2satissleep f2sleepweekday f2sleepweekend /// 
		l2satissleep l2sleepweekday l2sleepweekend /// 
		f3satissleep f3sleepweekday f3sleepweekend /// 
		l3satissleep l3sleepweekday l3sleepweekend /// 
		f4satissleep f4sleepweekday f4sleepweekend /// 
		l4satissleep l4sleepweekday l4sleepweekend /// 
		smoke_recode f2smoke_recode d2smoke_recode /// 
		d2smoke d2sport d2diet d2count_hsptl_lastyr d2count_doc_lastyr d2bmi ///
		f2smoke f2sport f2diet f2count_hsptl_lastyr f2count_doc_lastyr f2bmi /// 
		f4smoke f4sport f4diet f4count_hsptl_lastyr f4count_doc_lastyr f4bmi /// 
		l2smoke l2sport l2diet l2count_hsptl_lastyr l2count_doc_lastyr l2bmi ///
		l4smoke l4sport l4diet l4count_hsptl_lastyr l4count_doc_lastyr l4bmi /// 
		d2lncigday d2cigday d2mcs ///
		f2lncigday f2cigday f2mcs /// 
		f4lncigday f4cigday f4mcs /// 
		l2lncigday l2cigday l2mcs /// 
		l4lncigday l4cigday /// 
		d4lncigday d4smoke f2l2smoke f2l2lncigday /// 
		west labinc30k labinc26k heightmeter heightmeter2 ///
		f2d2smoke f2d2lncigday

	keep persnr welle $pvar 
	foreach x of varlist $pvar {
		rename `x' p_`x'
	}
	rename persnr partnr
	sort partnr welle
	save "${MY_TEMP_PATH}\partner.dta", replace
restore

sort partnr welle
merge partnr welle using "${MY_TEMP_PATH}\partner.dta"
drop if _merge==2
drop _merge
sort persnr welle

* Code up specific partner variables
gen 	p_fullt=p_emplst==1 if p_emplst!=.
gen 	p_partt=p_emplst!=1 & p_emplst!=5 if p_emplst!=.
gen 	olderspouse=age<p_age & age!=. & p_age!=.

save "${MY_OUT_PATH}\test2.dta", replace

* Restrict sample, part 2
drop if psbil==7
drop if selfemp==1 | civserv==1
drop if allbet==5
drop allbet_5 psbil2_5 p_psbil2_5 

count if female==p_female & tu==1
drop if female==p_female /*drop same sex couples*/ 
qui tab welle, gen(welle_)

* Exclude couples in which indirectly affected spouses experience plant closures, layoffs, or e.g. downsizing 
foreach	x of varlist t tu tu_all tu_reason tu_ue1 tjobloss tucjobloss tjobloss1 tjoblossreemp tjoblosslongt1 {
	gen 	`x'2=`x'
	replace `x'2=. if (p_t==1 | p_tu==1 | p_tu_reason==2)
}

	
foreach x of numlist 1/6 {
	gen 	tu_reason2_`x'=0 if tu_reason2==0
	replace tu_reason2_`x'=1 if tu_reason2==`x'
	gen 	f1tu_reason2_`x'=f1.tu_reason2_`x' 
	gen 	f2tu_reason2_`x'=f2.tu_reason2_`x'
	gen 	f3tu_reason2_`x'=f3.tu_reason2_`x' 
	gen 	f4tu_reason2_`x'=f4.tu_reason2_`x'
	gen 	f6tu_reason2_`x'=f6.tu_reason2_`x'
}
gen 	f2tu_all2=f2.tu_all2 
gen 	f4tu_all2=f4.tu_all2 
gen 	f6tu_all2=f6.tu_all2 

gen 	f2t2=f2.t2 
gen 	f4t2=f4.t2 
gen 	f6t2=f6.t2 

gen 	f2tu2=f2.tu2
gen 	f4tu2=f4.tu2
gen 	f6tu2=f6.tu2
gen 	f8tu2=f8.tu2
gen 	l2tu2=l2.tu2
gen 	l4tu2=l4.tu2
gen 	l6tu2=l6.tu2
gen 	l8tu2=l8.tu2

gen 	f2tu_ue1=f2.tu_ue1
gen 	f4tu_ue1=f4.tu_ue1
gen 	t3=t2 if tu!=1
gen 	tu_reason3_3=0 if tu_reason2_3==0 | tu_reason2_4==0 
replace tu_reason3_3=1 if tu_reason2_3==1 | tu_reason2_4==1

* Job loss due to plant closure or dismissal: tu_reason3_1
gen 	tu_reason3_1=0 if tu_reason2_1==0 | tu_reason2_2==0 
replace tu_reason3_1=1 if tu_reason2_1==1 | tu_reason2_2==1
gen 	f2tu_reason3_1=f2.tu_reason3_1
gen 	f4tu_reason3_1=f4.tu_reason3_1
gen 	f6tu_reason3_1=f6.tu_reason3_1

gen 	f2tjobloss2=f2.tjobloss2
gen 	f4tjobloss2=f4.tjobloss2
gen 	f6tjobloss2=f6.tjobloss2

gen 	f2tucjobloss2=f2.tucjobloss2
gen 	f4tucjobloss2=f4.tucjobloss2
gen 	f6tucjobloss2=f6.tucjobloss2

gen 	f2tjobloss12=f2.tjobloss12
gen 	f4tjobloss12=f4.tjobloss12
gen 	f6tjobloss12=f6.tjobloss12

gen 	f2tjoblossreemp=f2.tjoblossreemp
gen 	f4tjoblossreemp=f4.tjoblossreemp
gen 	f6tjoblossreemp=f6.tjoblossreemp

gen 	f2tjoblosslongt1=f2.tjoblosslongt1
gen 	f4tjoblosslongt1=f4.tjoblosslongt1
gen 	f6tjoblosslongt1=f6.tjoblosslongt1
	
* General plant closure experience
gen 	tj=tu2
replace tj=1 if t3==1
gen 	f2tj=f2.tj
gen 	f4tj=f4.tj
gen 	f6tj=f6.tj

gen 	f2t3=f2.t3
gen 	f4t3=f4.t3
gen 	f6t3=f6.t3

* Set seed 
sort persnr welle
set seed 2713
gen 	random=uniform()	

save "${MY_OUT_PATH}\analysis_ue2.dta", replace
erase "${MY_TEMP_PATH}\partner.dta"

exit
