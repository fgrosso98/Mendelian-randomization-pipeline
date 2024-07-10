1. Taking your clumping results and your entire GWAS of outcome, start with ***run_analysis.sh*** to run analysis of **MR.R** with a for loop each of 37 GWAS of exposure vs outcome
2. This analysis includes:
   a. Harmonization
   b. Main MR analysis with IVW, MR-Egger, Weighted median
   c. Pleiotropy
   d. Heterogeneity
   e. Leave-one-out with leave-one-out plot
   f. Scatter plot
   g. MR-PRESSO
4. Finally use ***FDR_correction.R*** to correct IVW p-values and then merge the results with all other results with pther methods using ***merge.sh***
   
