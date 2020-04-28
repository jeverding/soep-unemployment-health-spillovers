
clear
#delimit;

global MY_OUT_FILE  ${MY_OUT_PATH}\gen_ue2.dta;
global MY_LOG_FILE  ${MY_OUT_PATH}\gen_ue2.log;

cap log close;
log using "${MY_LOG_FILE}", text replace;
set more off;

/* ----------------[ automatically pull PPFAD ]----------------- */;

use    hhnr		persnr   		sex 	gebjahr  
	   phhnr 	qhhnr 			rhhnr   shhnr   thhnr	uhhnr   vhhnr   whhnr   xhhnr   yhhnr   zhhnr	bahhnr				bbhhnr		bchhnr		bdhhnr		behhnr			bfhhnr		bghhnr
       pnetto  	qnetto 			rnetto	snetto  tnetto 	unetto  vnetto  wnetto  xnetto  ynetto  znetto	banetto				bbnetto		bcnetto		bdnetto		benetto			bfnetto		bgnetto
       ppop  	qpop  			rpop	spop    tpop   	upop    vpop    wpop    xpop    ypop    zpop 	bapop  				bbpop		bcpop		bdpop		bepop			bfpop		bgpop
       migback  germborn
using  "${MY_IN_PATH}ppfad.dta";

/* --------------[ balanced / unbalanced design ]--------------- */;

keep if ( (  pnetto >= 10 &   pnetto < 20 ) | ( qnetto >= 10 &  qnetto < 20 ) | 
		  (  rnetto >= 10 &   rnetto < 20 ) | ( snetto >= 10 &  snetto < 20 ) | 
          (  tnetto >= 10 &   tnetto < 20 ) | ( unetto >= 10 &  unetto < 20 ) | 
          (  vnetto >= 10 &   vnetto < 20 ) | ( wnetto >= 10 &  wnetto < 20 ) | 
          (  xnetto >= 10 &   xnetto < 20 ) | ( ynetto >= 10 &  ynetto < 20 ) | 
          (  znetto >= 10 &   znetto < 20 ) | (banetto >= 10 & banetto < 20 ) | 
		  ( bbnetto >= 10 &  bbnetto < 20 ) | (bcnetto >= 10 & bcnetto < 20 ) | 
		  ( bdnetto >= 10 &  bdnetto < 20 ) | (bdnetto >= 10 & bdnetto < 20 ) | 
		  ( benetto >= 10 &  benetto < 20 ) | (benetto >= 10 & benetto < 20 ) | 
		  ( bfnetto >= 10 &  bfnetto < 20 ) | (bfnetto >= 10 & bfnetto < 20 ) | 
		  ( bgnetto >= 10 &  bgnetto < 20 ) | (bgnetto >= 10 & bgnetto < 20 ) 
		  );
// keep only observations with complete interviews 

/* -----------------[ private housholds only.]------------------ */;

keep if ( (  ppop == 1 |  ppop == 2 ) | ( qpop == 1 |  qpop == 2 ) |
		  (  rpop == 1 |  rpop == 2 ) | ( spop == 1 |  spop == 2 ) |
          (  tpop == 1 |  tpop == 2 ) | ( upop == 1 |  upop == 2 ) |
          (  vpop == 1 |  vpop == 2 ) | ( wpop == 1 |  wpop == 2 ) |
          (  xpop == 1 |  xpop == 2 ) | ( ypop == 1 |  ypop == 2 ) |
          (  zpop == 1 |  zpop == 2 ) | (bapop == 1 | bapop == 2 ) | 
		  ( bbpop == 1 | bbpop == 2 ) | (bbpop == 1 | bbpop == 2 ) | 
		  ( bcpop == 1 | bcpop == 2 ) | (bcpop == 1 | bcpop == 2 ) | 
		  ( bdpop == 1 | bdpop == 2 ) | (bdpop == 1 | bdpop == 2 ) | 
		  ( bepop == 1 | bepop == 2 ) | (bepop == 1 | bepop == 2 ) | 
		  ( bfpop == 1 | bfpop == 2 ) | (bfpop == 1 | bfpop == 2 ) | 
		  ( bgpop == 1 | bgpop == 2 ) | (bgpop == 1 | bgpop == 2 )
		  );

/* -----------------------[ sort ppfad ]------------------------ */;

sort persnr;

save   "${MY_TEMP_PATH}pmaster.dta", replace;
clear;

/* -------------------------( pull DESIGN for sampling design, two stage approach )------------------------- */;
use hhnr psu hsample design 
using "${MY_IN_PATH}design.dta";

sort hhnr;
save "${MY_TEMP_PATH}design.dta", replace;
clear;

/* -------------------------( pull pp: 1999 )------------------------- */;
use hhnr phhnr persnr pp05 pp10910 pp7001 pp7002 /* 
		*/ pp13313 pp13314 pp13315 pp13316 pp13317 pp13318 pp13319 pp13320 pp13321 pp13325 pp106 pp10903 pp83 pp80	/* 
		*/ pp0411 pp9701 pp0101	
using "${MY_IN_PATH}pp.dta";

sort persnr;
save "${MY_TEMP_PATH}pp.dta", replace;
clear;

/* -------------------------( pull qp: 2000 )------------------------- */;
use hhnr qhhnr persnr qp04 qp11810 qp7001 qp7002 /* 															   plant closure erst ab 2001
		*/ qp14213 qp14214 qp14215 qp14216 qp14217 qp14218 qp14219 qp14220 qp14221 qp14225 qp11803 qp83 qp80 qp9701	qp0101	/* Tod, worried ab. health, add. insur. */
using "${MY_IN_PATH}qp.dta";

sort persnr;
save "${MY_TEMP_PATH}qp.dta", replace;
clear;

/* -------------------------( pull rp: 2001 )------------------------- */;
use hhnr rhhnr persnr rp09	rp11410	rp7001	rp7002	rp72 /*  	
		*/ rp13313 rp13314 rp13315 rp13316 rp13317 rp13318 rp13319 rp13320 rp13321 rp13325 rp10301 rp10302 /* Variablen für Tod, Rauchen 
		*/ rp11403 rp83 rp80 rp9701	rp0101																			   /* worried about health, add. priv. insurance, disabled */
using "${MY_IN_PATH}rp.dta";

sort persnr;
save "${MY_TEMP_PATH}rp.dta", replace;
clear;

/* -------------------------( pull sp: 2002 )------------------------- */;
use hhnr shhnr persnr sp10	sp11310	sp7001	sp7002	sp72	sp8902 /* 
		*/ sp92 sp9301 sp9302 sp9401 sp9402 sp92 sp11303 sp10601 												/* Variablen für Rauchen, Ges. und add. priv. insurance 
		*/ sp13313 sp13314 sp13315 sp13316 sp13317 sp13318 sp13319 sp13320 sp13321 sp13326 sp103 sp9501			/* Var. für Tod 
		*/ sp0103 sp0104 sp0106 sp110 sp1108 sp11301 sp11302 sp0101 /*START HERE WITH ADDITIONAL VARIABLES: SLEEP, SATISFACTRION, RISK AVERSION, ...*/
using "${MY_IN_PATH}sp.dta";

sort persnr;
save "${MY_TEMP_PATH}sp.dta", replace;
clear;

/* -------------------------( pull tp: 2003 )------------------------- */;
use hhnr thhnr persnr tp12010	tp13	tp8801	tp8802	tp90 /*
		*/ tp14119 tp14120 tp14121 tp14122 tp14123 tp14124 tp14125 tp14126 tp14127 tp14131 tp106			/* Variablen für Tod  
		*/ tp12003 tp110 tp0901	tp9901																		/* worried about health, add. priv. insurance, Church 
		*/ tp0103 tp0104 tp0106 tp117 tp1022 tp12002 tp12001 tp0101
using "${MY_IN_PATH}tp.dta";

sort persnr;
save "${MY_TEMP_PATH}tp.dta", replace;
clear;

/* -------------------------( pull up: 2004 )------------------------- */;
use hhnr uhhnr persnr up05	up12510	up7301	up7302	up75	up8602 /*
		*/ up14419 up14420 up14421 up14422 up14423 up14424 up14425 up14426 up14427 up14431 up8901 up8902 up12503 up105 up87 up102 /* Var. für Tod, Rauchen add. insurance 
		*/ up9201 /* 
		*/ up12501 up12502 up119 up0208 up0104 up0103 up0108 up0105 up122 up0101
using "${MY_IN_PATH}up.dta";

sort persnr;
save "${MY_TEMP_PATH}up.dta", replace;
clear;

/* -------------------------( pull vp: 2005 )------------------------- */;
use hhnr vhhnr persnr vp07	vp13110	vp9401	vp9402	vp96 /*
		*/ vp15319 vp15320 vp15321 vp15322 vp15323 vp15324 vp15325 vp15326 vp15327 vp15331 vp13103 vp118 vp115 /* Var. für Tod, add. insurance 
		*/ vp10501 /*
		*/ vp128 vp0105 vp0107 vp0103 vp0104 vp0222 vp13101 vp13102 vp0101 
using "${MY_IN_PATH}vp.dta";

sort persnr;
save "${MY_TEMP_PATH}vp.dta", replace;
clear;

/* -------------------------( pull wp: 2006 )------------------------- */;
use hhnr whhnr persnr wp04	wp12110	wp8201	wp8202	wp84	wp9002 /*
		*/ wp14119 wp14120 wp14121 wp14122 wp14123 wp14124 wp14125 wp14126 wp14127 wp14131 wp9301 wp9302 wp12103 wp107 wp91 wp104 /* Var. für Tod, Rauchen add. insurance 
		*/ wp9601 /*
		*/ wp0104 wp0103 wp0107 wp0105 wp0109 wp0110 wp118 wp6208 wp123 wp12101 wp12102 wp0101 
using "${MY_IN_PATH}wp.dta";

sort persnr;
save "${MY_TEMP_PATH}wp.dta", replace;
clear;


/* -------------------------( pull xp: 2007 )------------------------- */;
use hhnr xhhnr persnr xp10	xp13010	xp8801	xp8802	xp90 /*
		*/ xp14822 xp14823 xp14824 xp14825 xp14826 xp14827 xp14828 xp14829 xp14830 xp14837 xp13003 xp112 xp109 /* Var. für Tod, add. insurance 
		*/ xp04 xp9901							/* Church 
		*/ xp127 xp0109 xp0105 xp0107 xp0103 xp0104 xp13001 xp13002 xp0222 xp0101 
using "${MY_IN_PATH}xp.dta";

sort persnr;
save "${MY_TEMP_PATH}xp.dta", replace;
clear;


/* -------------------------( pull yp: 2008 )------------------------- */;
use hhnr yhhnr persnr yp10202	yp13211	yp15	yp8901	yp8902	yp91 /*
		*/ yp15422 yp15423 yp15424 yp15425 yp15426 yp15427 yp15428 yp15429 yp15430 yp15437 yp10601 yp10602 yp13203 yp121 yp117 /* Var. für Tod, Rauchen add. insur. 
		*/ yp104 yp10301 yp10302 yp10901																						 /* Var. für sleep, diet 
		*/ yp0105 yp0104 yp0109 yp0106 yp0110 yp0102 yp129 yp10301 yp10302 yp10 yp13201 yp13202 yp1208 yp0101 
using "${MY_IN_PATH}yp.dta";

sort persnr;
save "${MY_TEMP_PATH}yp.dta", replace;
clear;


/* -------------------------( pull zp: 2009 )------------------------- */;
use hhnr zhhnr persnr zp06	zp12812	zp8501	zp8502	zp87 /* 
		*/ zp15622 zp15623 zp15624 zp15625 zp15626 zp15627 zp15628 zp15629 zp15630 zp15637 zp12804 zp10401 zp10402 zp107 /* Var. für Tod OHNE add. insurance, sleep 
		*/ zp9601 /*
		*/ zp122 zp0102 zp0109 zp0106 zp0108 zp0104 zp0105 zp0102 zp10402 zp10401 zp12801 zp12802 zp121 zp0208 zp0101 
using "${MY_IN_PATH}zp.dta";

sort persnr;
save "${MY_TEMP_PATH}zp.dta", replace;
clear;


/* -------------------------( pull bap: 2010 )------------------------- */;
use hhnr bahhnr persnr bap06 bap13012 bap7601 bap7602 bap78 bap9002 /*
		*/ bap15922 bap15924 bap15923 bap15925 bap15927 bap15926 bap15928 bap15930 bap15929 bap15940 bap9501 bap9502 bap13004 bap111 bap107 /* Var. für Tod, Rauchen add. insur. 
		*/ bap93 bap9201 bap9202 bap9801 																									 /* Var. für sleep, diet, church 
		*/ bap127 bap0102 bap0109 bap0106 bap0105 bap0104 bap0108 bap0308 bap9201 bap9202 bap0102 bap13001 bap13002 bap123 bap0101 
using "${MY_IN_PATH}bap.dta";

sort persnr;
save "${MY_TEMP_PATH}bap.dta", replace;
clear;

/* -------------------------( pull bbp: 2011 )------------------------- */;
use hhnr bbhhnr persnr bbp06 bbp13113 bbp8601 bbp8602 bbp88 /*
		*/ bbp15125 bbp15127 bbp15126 bbp15128 bbp15130 bbp15129 bbp15131 bbp15133 bbp15132 bbp15143 bbp13104 bbp113 bbp109 /* Var. für Tod, add. insur. 
		*/ bbp9801 bbp9802 bbp122 bbp10101																							 /* sleep 
		*/ bbp128 bbp0106 bbp0110 bbp0111 bbp0102 bbp0105 bbp0104 bbp0108 bbp0208 bbp9801 bbp9802 bbp0102 bbp13101 bbp13102 bbp121 bbp0101 
using "${MY_IN_PATH}bbp.dta";

sort persnr;
save "${MY_TEMP_PATH}bbp.dta", replace;
clear;

/* -------------------------( pull bcp: 2012 )------------------------- */;
use hhnr bchhnr persnr bcp08 bcp12713 bcp7401 bcp7402 bcp76 bcp9402 /* 												
		*/ bcp15025 bcp15027 bcp15026 bcp15028 bcp15030 bcp15029 bcp15031 bcp15033 bcp15032 bcp15043 bcp9701 bcp95 bcp9601 bcp9702 bcp12704 bcp116  bcp112 /* Var. für Tod, Rauchen add. ins. 
		*/ bcp98 bcp9901 bcp9902 bcp10401																													/* Var. für sleep, diet 
		*/ bcp124 bcp0106 bcp0110 bcp0102 bcp0105 bcp0104 bcp0108 bcp0408 bcp9901 bcp9902 bcp0102 bcp12701 bcp12702 bcp148 bcp0101 
using "${MY_IN_PATH}bcp.dta";

sort persnr;
save "${MY_TEMP_PATH}bcp.dta", replace;
clear;

/* -------------------------( pull bdp: 2013 )------------------------- */;
use hhnr bdhhnr persnr bdp15 bdp13314 bdp9201 bdp9202 bdp94 /* 
		*/ bdp15725 bdp15727 bdp15726 bdp15728 bdp15730 bdp15729 bdp15731 bdp15733 bdp15732 bdp15743 bdp13305 bdp127 bdp123 /* Var. für Tod, add. ins. 
		*/ bdp11101 bdp11102 bdp11401																						 /* Var. für sleep 
		*/ bdp130 bdp0106 bdp0110 bdp0102 bdp0105 bdp0104 bdp0108 bdp1009 bdp11101 bdp11102 bdp0102 bdp13301 bdp13302 bdp154 bdp0101 
using "${MY_IN_PATH}bdp.dta";

sort persnr;
save "${MY_TEMP_PATH}bdp.dta", replace;
clear;


/* -------------------------( pull bep: 2014 )------------------------- */;
use hhnr behhnr persnr bep09 bep12311 bep7901 bep7902 bep81 bep9202 /*
		*/ bep15025 bep15027 bep15026 bep15028 bep15030 bep15029 bep15031 bep15033 bep15032 bep15043 bep9401 bep9402 bep12304 bep106 /* Var. für Tod, Rauchen add. ins. 
		*/ bep110 bep95 bep9301																									  /* sleep 
		*/ bep118 bep0106 bep0110 bep0102 bep0105 bep0104 bep0108 bep0509 bep0102 bep12301 bep12302 bep04 bep0101 
using "${MY_IN_PATH}bep.dta";

sort persnr;
save "${MY_TEMP_PATH}bep.dta", replace;
clear;



/* -------------------------( pull bfp: 2015 )------------------------- */;
use hhnr bfhhnr persnr bfp15 bfp14612 bfp2701 bfp2702 bfp29 /* 
		*/ bfp17325 bfp17327 bfp17326 bfp17328 bfp17330 bfp17329 bfp17331 bfp17333 bfp17332 bfp17343 bfp14604 /*bdp127*/ bfp140 /* Var. für Tod, add. ins. 
		*/ bfp12801 bfp12802 bfp167 bfp13101																						 /* Var. für sleep 
		*/ bfp143 bfp0106 bfp0110 bfp0102 bfp0105 bfp0104 bfp0108 bfp1009 bfp12801 bfp12802 bfp0102 bfp14601 bfp14602 bfp04 bfp0101 
using "${MY_IN_PATH}bfp.dta";

sort persnr;
save "${MY_TEMP_PATH}bfp.dta", replace;
clear;

/* -------------------------( pull bgp: 2016 )------------------------- */;
use hhnr bghhnr persnr bgp13 bgp14812 bgp2601 bgp2602 bgp28 bgp10802 /*
		*/ bgp112 bgp11301 bgp14804 bgp131 /* Var. für Rauchen add. ins. 
		*/ /*bep110*/ bgp109																									  /* sleep 
		*/ bgp143 bgp0106 bgp0110 bgp0102 bgp0105 bgp0104 bgp0108 bgp0909 bgp0102 bgp14801 bgp14802 bgp05 bgp0101 
using "${MY_IN_PATH}bgp.dta";

sort persnr;
save "${MY_TEMP_PATH}bgp.dta", replace;
clear;


/* -------------------------( pull zvp: 2009 )------------------------- */;
use hhnr zhhnr persnr /*
		*/ zv1008 zv1005 zv1009 zv1011 zv17 zv0201 /* 	Variablen für Todesursache und Beziehung zu Totem 
		*/ vpersnr zv0101 zv03 zv04 /*
		*/ zvdatm
using "${MY_IN_PATH}zvp.dta";

sort persnr;
save "${MY_TEMP_PATH}zvp.dta", replace;
clear;

/* -------------------------( pull bavp: 2010 )------------------------- */;
use hhnr bahhnr persnr /*
		*/ bav1008 bav1005 bav1009 bav1011 bav17 bav0201 /* Variablen für Todesursache und Beziehung zu Totem 
		*/ vpersnr bav0101 bav03 bav04 /*
		*/ bavdatm
using "${MY_IN_PATH}bavp.dta";

sort persnr;
save "${MY_TEMP_PATH}bavp.dta", replace;
clear;

/* -------------------------( pull bbvp: 2011 )------------------------- */;
use hhnr bbhhnr persnr /*
		*/ bbvp1008 bbvp1005 bbvp1009 bbvp10 bbvp17 bbvp02 /* Variablen für Todesursache  und Beziehung zu Totem 
		*/ vpersnr bbvp0101 bbvp03 bbvp04 /*
		*/ bbvdatm
using "${MY_IN_PATH}bbvp.dta";

sort persnr;
save "${MY_TEMP_PATH}bbvp.dta", replace;
clear;

/* -------------------------( pull bcvp: 2012 )------------------------- */;
use hhnr bchhnr persnr /*
		*/ bcvp1008 bcvp1005 bcvp1009 bcvp1010 bcvp17 bcvp02 /* Variablen für Todesursache und Beziehung zu Totem 
		*/ vpersnr bcvp0101 bcvp03 bcvp04 /*
		*/ bcvdatm
using "${MY_IN_PATH}bcvp.dta";

sort persnr;
save "${MY_TEMP_PATH}bcvp.dta", replace;
clear;

/* -------------------------( pull bdvp: 2013 )------------------------- */;
use hhnr bdhhnr persnr /*
		*/ bdvp1008 bdvp1005 bdvp1009 bdvp1010 bdvp17 bdvp02 /* Variablen für Todesursache und Beziehung zu Totem 
		*/ vpersnr bdvp0101 bdvp03 bdvp04 /*
		*/ bdvdatm
using "${MY_IN_PATH}bdvp.dta";

sort persnr;
save "${MY_TEMP_PATH}bdvp.dta", replace;
clear;


/* -------------------------( pull bevp: 2014 )------------------------- */;
use hhnr behhnr persnr /*
		*/ bevp1008 bevp1005 bevp1009 bevp1010 bevp17 bevp0201 /* Variablen für Todesursache und Beziehung zu Totem 
		*/ vpersnr bevp0101 bevp03 bevp04 /*
		*/ bevdatm
using "${MY_IN_PATH}bevp.dta";

sort persnr;
save "${MY_TEMP_PATH}bevp.dta", replace;
clear;


/* -----------------------( pull $pgen )------------------------ */;
#delimit;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;
use    hhnr    `wave'hhnr   persnr  `wave'psbil expue* expft* `wave'pbbil01  `wave'pbbil02 allbet* jobch* 
       `wave'famstd stib*	month* emplst* expue* nace* *erwzeit partnr* `wave'tatzeit 
using "${MY_IN_PATH}\`wave'pgen.dta";
						//expue* ist hier doppelt abgefragt 
						// erwzeit* ist eigentlich 'wave'erwzeit
sort persnr;
save "${MY_TEMP_PATH}\`wave'pgen.dta", replace;
clear;
};

/* -----------------------( pull $hgen )------------------------ */;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;
use    hhnr `wave'hhnr  owner?? rsubs??
using "${MY_IN_PATH}\`wave'hgen.dta";

sort `wave'hhnr;
save "${MY_TEMP_PATH}\`wave'hgen.dta", replace;
clear;
};

/* ----------------------( pull $pequiv )----------------------- */;
#delimit;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;
use    hhnr    `wave'hhnr   persnr  i11110* d11107* m11126* /*
		*/ m11101* m11102* m11103* m11104* m11124* m11125* m11127* p11101* 	/* 		Freq. sport, inpatient hospital stays, disability, health satisfac., doc. visits, life satisfac.
		*/ m11105* m11106* m11107* m11108* m11109* m11110* m11111* m11112* /* 		Stroke, blood press., diabetes, cancer, psychiatr., arthritis, heart cond., asthma/breath. diff. 
		*/ m11113* m11114* m11115* m11116* m11117* m11118* m11119* m11120* m11121*/*teilweise Bestandteil von SF12 (mcs) */
using "${MY_IN_PATH}\`wave'pequiv.dta";
						// !!! Hier in m111xx* sind ggf. weitere, sehr interessante Health-Variablen enthalten (z.B. m11110xx: Arthrithis) < berücksichtigt 
						// pequiv existiert wohl nur in geraden Wellen (v30, 28, ...)

sort persnr;
save "${MY_TEMP_PATH}\`wave'pequiv.dta", replace;
clear;
};

/* ----------------------( pull $hbrutto )---------------------- */;
#delimit;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;
use    hhnr    `wave'hhnr `wave'bula `wave'wum1 `wave'regtyp
using "${MY_IN_PATH}\`wave'hbrutto.dta";

sort `wave'hhnr;
save "${MY_TEMP_PATH}\`wave'hbrutto.dta", replace;
clear;
};

/* -----------------------( pull health)------------------------ */;
#delimit;
use    persnr syear mcs pcs mh_nbs /*
		*/ bmi height weight 
using "${MY_IN_PATH}health.dta";
reshape wide mcs pcs mh_nbs bmi height weight , i(persnr) j(syear);
sort persnr;
save "${MY_TEMP_PATH}health.dta", replace;
clear;


/* -----------------( Now merge all together )------------------ */;

use   "${MY_TEMP_PATH}pmaster.dta";
erase "${MY_TEMP_PATH}pmaster.dta";

/* -----------( merge together by person: ALL Waves )----------- */;


/* ------------------------( merge $P )------------------------- */;
#delimit;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;      
sort  persnr;
merge persnr
using "${MY_TEMP_PATH}\`wave'p.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'p.dta";
};

/* ------------------------( merge $VP )------------------------- */;
#delimit;
foreach wave in z ba bb bc bd be {; 
sort  persnr;
merge persnr
using "${MY_TEMP_PATH}\`wave'vp.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'vp.dta";
};

/* -----------------------( merge $PGEN )----------------------- */;

foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;      
sort  persnr;
merge persnr
using "${MY_TEMP_PATH}\`wave'pgen.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'pgen.dta";
};

/* ----------------------( merge $PEQUIV )---------------------- */;

foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;         
sort  persnr;
merge persnr
using "${MY_TEMP_PATH}\`wave'pequiv.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'pequiv.dta";
};

/* -----------------------( merge HEALTH )----------------------- */;
          
sort  persnr;
merge persnr
using "${MY_TEMP_PATH}health.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}health.dta";


/* -----------( merge together by household)-------------------- */;

/* ---------------------( merge $HBRUTTO )---------------------- */;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;         
sort  `wave'hhnr;
merge `wave'hhnr
using "${MY_TEMP_PATH}\`wave'hbrutto.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'hbrutto.dta";
};

/* ---------------------( merge $HGEN )---------------------- */;
foreach wave in p q r s t u v w x y z ba bb bc bd be bf bg {;         
sort  `wave'hhnr;
merge `wave'hhnr
using "${MY_TEMP_PATH}\`wave'hgen.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}\`wave'hgen.dta";
};


/* ---------------------( merge DESIGN )---------------------- */;
sort  hhnr;
merge hhnr
using "${MY_TEMP_PATH}design.dta";
drop   if _merge == 2;
drop   _merge;
erase "${MY_TEMP_PATH}design.dta";
								
/* --------------------------( done! )-------------------------- */;

save  "${MY_OUT_FILE}", replace;

cap log close;
