1. Taking your clumping results and your entire GWAS of outcome, start with ***run_analysis.sh*** to run analysis of **MR.R** with a for loop each of 37 GWAS of exposure vs outcome
2. This analysis includes:
   - Harmonization
   - Main MR analysis with IVW, MR-Egger, Weighted median
   - Pleiotropy
   - Heterogeneity
   - Leave-one-out with leave-one-out plot
   - Scatter plot
   - MR-PRESSO
4. Finally use ***FDR_correction.R*** to correct IVW p-values and then merge the results with all other results with pther methods using ***merge.sh***
   
