#!/usr/bin/env Rscript
library(terra)
source("settings.R")

# --- CONSOLIDATED EXTRACTION SCRIPT ---
# This script generates the small CSV files for the repo from global datasets.
# It requires multi-terabyte datasets to be present at 'base_dir'.

if (!dir.exists(base_dir)) {
  stop(paste0("Error: Global data directory '", base_dir, "' not found.\n",
              "This script is for reference and requires massive external datasets.\n",
              "For the demo, use the pre-extracted data in '", sample_path, "' and run Step 2."))
}

if (!dir.exists(sample_path)) dir.create(sample_path)

# Variables to extract
bc_vars <- c("pr", "tas", "tasrange", "tasskew")
other_vars <- c("hurs", "sfcWind", "rsds")

# Function to extract time series for a single point
extract_ts <- function(path, pattern, lon, lat) {
  files <- list.files(path, pattern = pattern, full.names = TRUE)
  if (length(files) == 0) return(NULL)
  
  all_data <- data.frame()
  for (f in files) {
    cat("  Reading:", basename(f), "\n")
    r <- rast(f)
    val <- as.numeric(extract(r, data.frame(lon=lon, lat=lat), ID=FALSE))
    df <- data.frame(date = time(r), value = val)
    all_data <- rbind(all_data, df)
  }
  return(all_data[order(all_data$date), ])
}

# 1. EXTRACT CHELSA (Observed Reference 1979-2015)
cat("--- Extracting CHELSA (Observed) ---\n")
chelsa_list <- list()
for (v in bc_vars) {
  cat("Variable:", v, "\n")
  path <- paste0(base_dir, "/CHELSA-W5E5/90arcsec/global/", v)
  data <- extract_ts(path, NULL, lon, lat)
  if (!is.null(data)) {
    data <- data[data$date >= as.Date("1979-01-01") & data$date <= as.Date("2015-12-31"), ]
    colnames(data) <- c("date", v)
    chelsa_list[[v]] <- data
  }
}
chelsa_final <- Reduce(function(x, y) merge(x, y, by="date", all=TRUE), chelsa_list)
write.csv(chelsa_final, paste0(sample_path, "/CHELSA_Observed_", site_name, ".csv"), row.names=FALSE)

# 2. EXTRACT HAPPI HISTORICAL (Model Reference 1979-2015)
cat("\n--- Extracting HAPPI Historical (Model Ref) ---\n")
happi_hist_list <- list()
for (v in bc_vars) {
  cat("Variable:", v, "\n")
  path <- paste0(base_dir, "/HAPPI/", gcm_name, "/GlobalDimension/Historical/", v)
  data <- extract_ts(path, NULL, lon, lat)
  if (!is.null(data)) {
    data <- data[data$date >= as.Date("1979-01-01") & data$date <= as.Date("2015-12-31"), ]
    colnames(data) <- c("date", v)
    happi_hist_list[[v]] <- data
  }
}
happi_hist_final <- Reduce(function(x, y) merge(x, y, by="date", all=TRUE), happi_hist_list)
write.csv(happi_hist_final, paste0(sample_path, "/HAPPI_Historical_", site_name, ".csv"), row.names=FALSE)

# 3. EXTRACT HAPPI FUTURE (Period Current, 2006-2015)
cat("\n--- Extracting HAPPI Future (Period ", period, ") ---\n")
all_future_vars <- c(bc_vars, other_vars)
happi_future_list <- list()
for (v in all_future_vars) {
  cat("Variable:", v, "\n")
  path <- paste0(base_dir, "/HAPPI/", gcm_name, "/GlobalDimension/", period, "/", v)
  data <- extract_ts(path, ens_member, lon, lat)
  if (!is.null(data)) {
    data <- data[data$date >= as.Date("2006-01-01") & data$date <= as.Date("2015-12-31"), ]
    colnames(data) <- c("date", v)
    happi_future_list[[v]] <- data
  }
}
happi_future_final <- Reduce(function(x, y) merge(x, y, by="date", all=TRUE), happi_future_list)
write.csv(happi_future_final, paste0(sample_path, "/HAPPI_Future_", site_name, ".csv"), row.names=FALSE)

cat("\nDone! All files saved in:", sample_path, "\n")
