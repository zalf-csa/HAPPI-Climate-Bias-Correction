#!/usr/bin/env Rscript
library(downscaleR)
source("settings.R")

# --- FINAL PROCESSING SCRIPT ---
# This script runs the bias-correction logic locally using consolidated CSV samples.

if (!dir.exists(output_dir)) dir.create(output_dir)

cat("--- Processing Bias Correction for:", site_name, "---\n")

# 1. LOAD CONSOLIDATED DATA
obs_df <- read.csv(paste0(sample_path, "/CHELSA_Observed_", site_name, ".csv"))
mod_ref_df <- read.csv(paste0(sample_path, "/HAPPI_Historical_", site_name, ".csv"))
mod_fut_df <- read.csv(paste0(sample_path, "/HAPPI_Future_", site_name, ".csv"))

# Convert dates
obs_df$date <- as.Date(obs_df$date)
mod_ref_df$date <- as.Date(mod_ref_df$date)
mod_fut_df$date <- as.Date(mod_fut_df$date)

# 2. PERFORM BIAS CORRECTION (EQM)
variables_to_correct <- c("pr", "tas", "tasrange", "tasskew")
bc_results <- list()

for (v in variables_to_correct) {
  cat("  Downscaling variable:", v, "...\n")
  
  is_precip <- (v == "pr")
  thresh <- if(is_precip) 0.0000011574 else NULL
  
  corrected_val <- downscaleR:::eqm(
    o = obs_df[[v]],
    p = mod_ref_df[[v]],
    s = mod_fut_df[[v]],
    precip = is_precip,
    pr.threshold = thresh,
    n.quantiles = 100,
    extrapolation = "constant"
  )
  
  bc_results[[v]] <- corrected_val
}

# 3. CONSOLIDATE AND CONVERT UNITS
final_df <- data.frame(date = mod_fut_df$date)
final_df$pr <- bc_results[["pr"]]
final_df$tas <- bc_results[["tas"]]
final_df$tasrange <- bc_results[["tasrange"]]
final_df$tasskew <- bc_results[["tasskew"]]

# Convert Temperature components to tasmin/tasmax
final_df$tasmin <- final_df$tas - final_df$tasskew * final_df$tasrange
final_df$tasmax <- final_df$tasrange + final_df$tasmin

# Load auxiliary variables (hurs, sfcWind, rsds)
final_df$hurs <- mod_fut_df$hurs
final_df$sfcWind <- mod_fut_df$sfcWind
final_df$rsds <- mod_fut_df$rsds

# 4. FINAL UNIT CONVERSIONS AND CLEANUP
final_df$pr <- final_df$pr * 86400
final_df$pr[final_df$pr < 0] <- 0

final_df$tasmin <- final_df$tasmin - 273.15
final_df$tasmax <- final_df$tasmax - 273.15

final_df$rsds <- final_df$rsds * 0.0864
final_df$rsds[final_df$rsds > 43.2] <- 43.2
final_df$rsds[final_df$rsds < 0] <- 0

final_df$hurs[final_df$hurs < 0] <- 0
final_df$hurs[final_df$hurs > 100] <- 100

final_df$sfcWind <- final_df$sfcWind * 4.87 / log(67.8 * 10 - 5.42)
final_df$sfcWind[final_df$sfcWind > 37.4] <- 37.4
final_df$sfcWind[final_df$sfcWind < 0] <- 0

# 5. WRITE FINAL CSV
output_cols <- c("date", "rsds", "tasmax", "tasmin", "hurs", "pr", "sfcWind")
output_filename <- paste0(output_dir, "/", gcm_name, "_", ens_member, "_", site_name, ".csv")
write.csv(final_df[, output_cols], output_filename, row.names = FALSE)

cat("Successfully generated REAL demo output:", output_filename, "\n")
