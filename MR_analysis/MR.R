library(dplyr)
require(TwoSampleMR)
require(ieugwasr)
require(ggplot2)
require(MRPRESSO)
library(officer)
source("/home/students/federica.grosso/nas/funzioni.R")
# Leggi il percorso del file dalla linea di comando
args <- commandArgs(trailingOnly = TRUE)
file_path_exposure <- args[1]
file_path_outcome <- args[2]

# RICAVA NOME EXPOSURE
nome_fileE <- basename(file_path_exposure)
nome_file_senza_ext <- tools::file_path_sans_ext(nome_fileE)
# Divide il nome del file basandosi sul carattere "_"
parti_nome <- strsplit(nome_file_senza_ext, "_")[[1]]
nome_exposure <- paste(parti_nome[2])

# RICAVA NOME OUTCOME
nome_fileO <- basename(file_path_outcome)
parti_outcome <- strsplit(nome_fileO, split = "_")[[1]]
nome_outcome <- parti_outcome[1]

dataE<-read.csv(file_path_exposure, header=T)
suppressWarnings({
  dataO<-read_outcome_data(file_path_outcome, 
                           snps = dataE$SNP,
                           sep="\t", 
                           phenotype_col = "Outcome",
                           snp_col = "oldID",
                           beta_col = "Effect",
                           se_col="StdErr",
                           eaf_col = "Freq1",
                           effect_allele_col = "Allele1",
                           other_allele_col = "Allele2",
                           pval="P-value")
  dataO$outcome <- "CAD"
})

# HARMONIZE
output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/Harm_data_E_", nome_exposure, "_O_", nome_outcome, ".txt")
dat <- harmonise_data(dataE, dataO, action = 2)
write.table(dat, file = output_file, sep = "\t", quote=F)

# MR RESULTS
output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/MR_E_", nome_exposure, "_O_", nome_outcome, ".csv")
mr_results <- mr(dat, method_list = c("mr_egger_regression", "mr_ivw","mr_wald_ratio","mr_weighted_median"))
write.csv(mr_results, file = output_file, quote=F, row.names = F)
# wald solo quando ho solo uno SNP, il p di significatività è 0.05

# Sensitivity analysis
# Crea un nome di file unico per il file di output (puoi modificare questa parte come preferisci)
output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/Het_E_", nome_exposure, "_O_", nome_outcome, ".txt")
het<-mr_heterogeneity(dat)
write.table(het, file = output_file, sep = "\t", quote=F)

#cat("\n\n--- Pleiotropy ---\n\n", file = output_file, append = TRUE)
output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/Ple_E_", nome_exposure, "_O_", nome_outcome, ".txt")
ple <- mr_pleiotropy_test(dat)
write.table(ple, file = output_file, sep = "\t", quote=F)

output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/SINGLESNP_E_", nome_exposure, "_O_", nome_outcome, ".txt")
res_single <- mr_singlesnp(dat)
write.table(res_single, file = output_file, sep = "\t", quote=F)

output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/LOO_E_", nome_exposure, "_O_", nome_outcome, ".txt")
res_loo <- mr_leaveoneout(dat)
write.table(res_loo, file = output_file, sep = "\t", quote=F)

# MR Steiger directionality test
# output_file <- paste0("/home/students/federica.grosso/nas/MRresults2/BMI/dir_E_", nome_proteina, "_O_", nome_outcome, ".txt")
#cat("\n\n--- Directionality ---\n\n", file = output_file, append = TRUE)
#dir <- directionality_test(dat) # non posso farlo perchè non ho sample size
#write.table(dir, file = output_file, sep = "\t", quote=F, append = TRUE)

# PLOTS

## Scatter plot
output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/plots_E_", nome_exposure, "_O_", nome_outcome, ".pdf")
pdf(output_file)

p1<-mr_scatter_plot(mr_results,dat)
#title("Scatter Plot")
print(p1)

## Forest plot

p2 <- mr_forest_plot(res_single)
#title("Forest Plot")
print(p2)

## Leave-one-out plot

p3 <- mr_leaveoneout_plot(res_loo)
#title("Leave-One-Out Plot")
print(p3)

## Funnel plot
## Asymmetry in a funnel plot is useful for gauging the reliability of a particular MR analysis

p4 <- mr_funnel_plot(res_single)
#title("Funnel Plot")
print(p4)

dev.off()

ivw_results <- subset(mr_results, method == "Inverse variance weighted")

if (length(ivw_results$pval) > 0 && !is.na(ivw_results$pval) && ivw_results$pval<0.05)
{
  output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/Significative/YES_E_", nome_exposure, "_O_", nome_outcome, ".txt")
  # Apri il file in modalità scrittura
  file_conn <- file(output_file, "w")
  # Scrivi il messaggio sul file
  cat(paste("The ", nome_exposure, " is significative with p-value of IVW of ", subset(mr_results, method == "Inverse variance weighted")$pval), file = file_conn)
  # Chiudi il file
  close(file_conn)
}


if (length(ivw_results$pval) > 0 && !is.na(ivw_results$pval) && ivw_results$pval<0.05 && !is.na(ple$pval) && ple$pval<0.05)
{
  output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/MR_PRESSO/MR_PRESSO_E_", nome_exposure, "_O_", nome_outcome, ".txt")
  mr_presso <- mr_presso(BetaOutcome="beta.outcome", 
                         BetaExposure="beta.exposure", 
                         SdOutcome="se.outcome", 
                         SdExposure="se.exposure", 
                         data=dat, 
                         OUTLIERtest = TRUE, 
                         DISTORTIONtest = TRUE, 
                         SignifThreshold = 0.05, 
                         NbDistribution = 1000, seed = 1)
  output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/MR_PRESSO/MR_PRESSO_E_", nome_exposure, "_O_", nome_outcome, ".docx")
  doc <- read_docx()
  
  # Aggiungi il contenuto del file RDS al documento
  doc <- doc %>%
    body_add_par("MR Presso results:", style = "heading 1")
  
  # Aggiungi i risultati di 'Main MR results'
  doc <- doc %>%
    body_add_par("Main MR results:", style = "heading 2") %>%
    body_add(mr_presso$`Main MR results`)
  
  # Aggiungi i risultati di 'MR-PRESSO results'
  doc <- doc %>%
    body_add_par("MR-PRESSO results:", style = "heading 2") %>%
    body_add_par("Outlier test:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Outlier Test`)
  
  # Aggiungi i risultati di 'MR-PRESSO results'
  doc <- doc %>%
    body_add_par("Global test - RSSobs:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Global Test`$RSSobs)
  
  # Aggiungi i risultati di 'MR-PRESSO results'
  doc <- doc %>%
    body_add_par("Global test - Pvalue:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Global Test`$Pvalue)
  
  # Aggiungi i risultati di 'MR-PRESSO results'
  doc <- doc %>%
    body_add_par("Distortion Test - Outlier indices:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Distortion Test`$`Outliers Indices`)
  
  doc <- doc %>%
    body_add_par("Distortion Test - Distortion Coefficient:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Distortion Test`$`Distortion Coefficient`)
  
  doc <- doc %>%
    body_add_par("Distortion Test - Pval:", style = "heading 3") %>%
    body_add(mr_presso$`MR-PRESSO results`$`Distortion Test`$Pvalue)
  # Salva il documento Word
  print(doc, target = output_file)
  
  
  outliers_removed <- mr_presso$`MR-PRESSO results`$`Distortion Test`$`Outliers Indices`
  # Aggiungi una nuova colonna a `dat` per indicare se un SNP è un outlier
  dat$outlier_status <-  ifelse(seq_along(dat$SNP) %in% outliers_removed, "Removed", "Kept")
  
  # Filtra il dataset per includere solo gli SNP mantenuti
  dat_kept <- subset(dat, outlier_status == "Kept")
  dat_removed <- subset(dat, outlier_status == "Removed")
  mr_results_kept <- mr(dat_kept, method_list = c("mr_egger_regression", "mr_ivw","mr_wald_ratio","mr_weighted_median"))
  output_file <- paste0("/home/students/federica.grosso/nas/microbiome/Results_CAD/MR_PRESSO/MR_PRESSO_E_", nome_exposure, "_O_", nome_outcome, ".pdf")
  pdf(output_file)
  p1 <- mr_scatter_plot_col(mr_results,dat,dat_kept,dat_removed)
  print(p1)
  p2 <- mr_scatter_plot_IVW(mr_results,mr_results_kept,dat,dat_kept,dat_removed)
  print(p2)
  dev.off()
}


