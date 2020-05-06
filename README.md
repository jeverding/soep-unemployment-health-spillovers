# soep-unemployment-health-spillovers
Replication code for Everding and Marcus (2020, Health Economics). 

[`gen_spousal_ue.do`](./gen_spousal_ue.do) pulls the data. 

[`trans_spousal_ue.do`](./trans_spousal_ue.do) transforms the data and generates the relevant variables. 

[`candidatevar_spousal_ue.do`](./candidatevar_spousal_ue.do) constructs and adds leads, lags, transformed variables (polynomials and log. trans.) and imputation flags. 

[`lassodoubleselection_spousal_ue.do`](./lassodoubleselection_spousal_ue.do) fits Lasso regressions (post-double-selection method, see Belloni et al. 2014) on candidate variables 

[`ebal-plantcl-clustse_spousal_ue.do`](./ebal-plantcl-clustse_spousal_ue.do) runs main analysis, part 1 (without post-double selection) 



# Data 
The main data source is the German Socio-Economic Panel (SOEP, version 33). 

See https://www.diw.de/soep for detailed information on data access options. 

# References 
Belloni, A., V. Chernozhukov, and C. Hansen. 2014. [Inference on treatment effects after selection among high-dimensional controls.](https://doi.org/10.1093/restud/rdt044) *The Review of Economic Studies*, 81(2), 608-650.

Everding, J. and J. Marcus. 2020. [The effect of unemployment on the smoking behavior of couples.](https://onlinelibrary.wiley.com/doi/full/10.1002/hec.3961) *Health Economics*, 29(2), 154-170.
