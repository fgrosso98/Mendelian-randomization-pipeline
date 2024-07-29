- I deleted the rows where there were betas above 4 or below -4 (the first few rows) (folder **GWAS_new** using the file ***rm_beta.sh*** to run ***RM_beta.R***) → the first 1430 rows, via the same file I modified that line in each GWAS by putting the location 48000000 instead of 7 zeros
- Then since there were NAs in the microbiome files I used the reference file of the 1000Genomes EUR from which I took the columns chr:position and rsid and did a merge with all GWAS for chr:pos. In this way I obtained a new rsid column. When the original column was NA, I replaced it with the new rsid. I also created a new column where 
    - 0 = rsid are equal
    - 1 = one of them is NA
    - 2 = rsids are different

This is done running ***merge.R*** using ***ref_col.sh*** file.
    
- Finally, I created a "rsid_to_use" column with all the rsids of the microbiome when they are there and are the same as those of the reference, those of the reference when they are different or when the microbiome has NA → ***final_column.sh*** in the **GWAS_final** folder

- Use the function "***run_clumping.sh***" to run ***CLUMPING_micr_server.R*** to do clumping (in this case with $5e-6$, but usually with $5e-8$)
