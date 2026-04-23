# --- REPO CONFIGURATION ---
# This file centralizes all settings for the extraction and processing demo.

# 1. Site Metadata
site_name <- "Tempelberg"
lon <- 14.1607
lat <- 52.4426

# 2. Climate Model Metadata
gcm_name <- "ETH-CAM4-2degree"
ens_member <- "ens0000"
period <- "Current"

# 3. Paths
# On Cluster: /beegfs/common/data/climate
# Local: Path where you saved the extracted CSVs
base_dir <- "/beegfs/common/data/climate" 

# Using file.path() for cross-platform compatibility
sample_path <- file.path(".", paste0("extracted_sample_", site_name))
output_dir <- file.path(".", "results")
