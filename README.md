1. First I took GWAS on the gut microbiome with at least one significant association according to the dutch microbiome study (folder **GWAS_microbiome**)
2. I then deleted the rows where there were betas above 4 or below -4 (the first few rows) (folder **GWAS_new** using the files ***rm_beta.sh*** and ***RM_beta.R***) → the first 1430 rows
3. Having then observed by doing manhattan plots that there was too much space between chromosome 12 and 13, it was seen that there was an error in the position of an rsid
    
    Right: https://my.locuszoom.org/gwas/939631/
    
    Wrong: https://my.locuszoom.org/gwas/391915/
    
    [rs855274 (SNP) - Explore this variant - Homo_sapiens - GRCh37 Archive browser 111](https://grch37.ensembl.org/Homo_sapiens/Variation/Explore?db=core;r=12:47999500-48000500;v=rs855274;vdb=variation;vf=739274089)
    
4. Then via the same file I modified that line in each GWAS by putting the location 48000000 instead of 7 zeros
5. Then since there were NAs in the microbiome files I used the reference file of the 1000Genomes EUR from which I took the columns chr:position and rsid and did a merge with all GWAS for chr:pos. In this way I obtained a new rsid column. When the original column was NA, I replaced it with the new rsid. I also created a new column where 
    - 0 = rsid are equal
    - 1 = one of them is NA
    - 2 = rsids are different

These were placed in the **GWAS_merged** folder, the reference file **Final_EUR_with_labels.txt** and the codes ***ref_col.sh*** and ***merge.R***.
    
6. Finally, I created a "rsid_to_use" column with all the rsids of the microbiome when they are there and are the same as those of the reference, those of the reference when they are different or when the microbiome has NA → ***final_column.sh*** in the **GWAS_final** folder

7. Use the function "run_clumping.sh" to sun CLUMPING_micr_server.R to do clumping (in this case with $5e-6$, but usually with $5e-8$)
