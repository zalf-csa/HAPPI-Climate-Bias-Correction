# --- REPO CONFIGURATION ---
# This file centralizes all settings for the extraction and processing demo.

# 1. Site Metadata
site_name <- "Tempelberg"
lon <- 14.1607
lat <- 52.4426

# 2. Climate Model Metadata
gcm_name <- "ETH-CAM4-2degree"
ens_member <- "ens0000"

# 3. Processing Options
# Set run_future to FALSE if you only want to process Happi_historical (e.g. for testing)
run_future <- TRUE

# 4. Paths
# Local or Cluster Path to the global datasets
base_dir <- "/beegfs/common/data/climate" 

# Using file.path() for cross-platform compatibility
sample_path <- file.path(".", paste0("extracted_sample_", site_name))
output_dir <- file.path(".", "results")
