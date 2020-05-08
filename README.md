# soep-unemployment-health-spillovers
Replication code for Everding and Marcus (2020, Health Economics). 

## Main do-file 
[`master_spousal_ue.do`](./master_spousal_ue.do) defines all relevant macros, the folder structure, and executes all files sequentially 

## Additional do-files 
The actual steps of data pre-processing and analyses are divided into several additional do-files ("script" files in Stata), as described in the following: 

[`gen_spousal_ue.do`](./gen_spousal_ue.do) pulls the data 

[`trans_spousal_ue.do`](./trans_spousal_ue.do) transforms the data and generates the relevant variables 

[`candidatevar_spousal_ue.do`](./candidatevar_spousal_ue.do) constructs and adds leads, lags, transformed variables (polynomials and log. trans.) and imputation flags 

[`pds_spousal_ue.do`](./pds_spousal_ue.do) fits Lasso regressions (post-double-selection method, PDS, see Belloni et al. 2014) on candidate variables 

[`pdsmech_spousal_ue.do`](./pdsmech_spousal_ue.do) fits Lasso regressions and selects controls for analysis of mechanisms (i.e. alternative outcomes) 

[`main-analysis1_spousal_ue.do`](./main-analysis1_spousal_ue.do) runs main analysis (with entropy balancing weights, EB, see Hainmueller 2012), part 1 (without post-double selection) 

[`main-analysis2_spousal_ue.do`](./main-analysis2_spousal_ue.do) runs main analysis (with EB), part 2 (only post-double selection) 

[`desc-stats1_spousal_ue.do`](./desc-stats1_spousal_ue.do) generates table for descriptive statistics and matching quality, part 1 

[`het-analysis1_spousal_ue.do`](./het-analysis1_spousal_ue.do) investigates treatment effect heterogeneity by smoking status at baseline, part 1

[`het-analysis2_spousal_ue.do`](./het-analysis2_spousal_ue.do) investigates treatment effect heterogeneity by smoking status at baseline, part 2

[`mech_spousal_ue.do`](./mech_spousal_ue.do) runs analysis of mechanisms (with PDS), part 1

[`mech2_spousal_ue.do`](./mech2_spousal_ue.do) runs analysis of mechanisms (without PDS), part 2

[`desc-stats2_spousal_ue.do`](./desc-stats2_spousal_ue.do) generates table for descriptive statistics and matching quality, part 2 

# Data 
The main data source is the German Socio-Economic Panel (SOEP, version 33). 

See https://www.diw.de/soep for detailed information on data access options. 

# References 
Belloni, A., V. Chernozhukov, and C. Hansen. 2014. [Inference on treatment effects after selection among high-dimensional controls.](https://doi.org/10.1093/restud/rdt044) *The Review of Economic Studies*, 81(2), 608-650.

Everding, J. and J. Marcus. 2020. [The effect of unemployment on the smoking behavior of couples.](https://onlinelibrary.wiley.com/doi/full/10.1002/hec.3961) *Health Economics*, 29(2), 154-170.

Hainmueller, J. 2012. [Entropy balancing for causal effects: A multivariate reweighting method to produce balanced samples in observational studies.](https://doi.org/10.1093/pan/mpr025) *Political Analysis*, 20(1), 25-46.
