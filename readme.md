# HAPPI Climate Data Bias-Correction (Logic Demo)

This repository demonstrates the scientific logic used to process and bias-adjust daily climate projection data from the **HAPPI** (Half a degree Additional warming, Prognosis and Projected Impacts) dataset, using **CHELSA-W5E5** as a reference.

## 🔗 Original Data Sources
- **HAPPI Model Data:** [NERC Portal](https://portal.nersc.gov/c20c/data.html)
- **CHELSA-W5E5 Reference Data:** [ISIMIP Repository](https://data.isimip.org/10.48364/ISIMIP.836809.3)

## 📂 Repository Structure

| File | Category | Purpose |
| :--- | :--- | :--- |
| `settings.R` | Configuration | Site coordinates, GCM selection, and period settings. For this demo, we run only for 1 GCM, 1 ensemble member, and 1 period for 1 location. |
| `01_extract_cluster_data.R` | Cluster Script | Script used on the cluster to extract filtering data. |
| **`extracted_sample_Tempelberg/`** | **Data Sample** | Pre-extracted CSV files for Tempelberg (Observed, Hist, Future). |
| **`02_bias_correction.R`** | **Primary Demo** | Core scientific logic (EQM) and unit conversions. Runs locally. |

## 🛠 Installation and Workflow

### Prerequisites

Before you begin, ensure you have the following installed:
- **Git**: [Download here](https://git-scm.com/downloads)
- **R (>= 4.0 recommended)**: [Download here](https://cloud.r-project.org/)
- **RTools (Windows only)**: [Download here](https://cran.r-project.org/bin/windows/Rtools/)

### Getting Started

To clone the repository and set up the environment, run the following commands in your terminal:

```bash
git clone https://github.com/zalf-csa/HAPPI-Climate-Bias-Correction.git
cd HAPPI-Climate-Bias-Correction

# Ensure R is in your PATH. If 'Rscript' is not recognized, run:
# (Developed using R 4.4.3, but compatible with most recent R versions)
# Windows (Command Prompt): set PATH=C:\Path\To\R\bin;%PATH%
# Windows (PowerShell): $env:PATH += ";C:\Path\To\R\bin"
# Linux/macOS: export PATH="/path/to/R/bin:$PATH"

# Initialize the R environment
Rscript -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv')"
Rscript -e "renv::init(bare = TRUE)"

# Install required dependencies
Rscript -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes')"
Rscript -e "remotes::install_github(c('SantanderMetGroup/transformeR', 'SantanderMetGroup/downscaleR'))"
```

### Step 1: Data Extraction (Cluster Script)
The script `01_extract_cluster_data.R` is used on the cluster to extract filtering data from the massive global datasets for a specific location. It assumes a cluster environment where the datasets from the **Original Data Sources** section have been downloaded into a base directory (e.g., `base_dir <- "/beegfs/common/data/climate"`). Due to the huge amount of weather data involved in the extraction, this repository already provides the output from this step in the `extracted_sample_Tempelberg/` folder. You can review the script to understand the extraction and filtering logic.

### Step 2: Bias Correction (Processing Script)
To produce the bias correction results, run:
```bash
Rscript 02_bias_correction.R
```
This script applies the **Empirical Quantile Mapping (EQM)** method to the sample data and performs necessary unit conversions. 

**Output:** Upon execution, the script generates a final bias-adjusted daily weather CSV file (e.g., `ETH-CAM4-2degree_ens0000_Tempelberg.csv`) in the `results/` folder.

## 📊 Output Data Format
The final output is a CSV file (e.g., `ETH-CAM4-2degree_ens0000_Tempelberg.csv`) containing:

| Column | Description | Unit |
| :--- | :--- | :--- |
| **date** | Date (YYYY-MM-DD) | - |
| **rsds** | Global radiation | W m-2 |
| **tasmax** | Maximum Temperature | °C |
| **tasmin** | Minimum Temperature | °C |
| **hurs** | Relative humidity | % |
| **pr** | Daily Precipitation | mm d-1 |
| **sfcWind** | Wind speed | m s-1 |

## 🧪 Methodology
- **Method:** Empirical Quantile Mapping (EQM) using the `downscaleR` package.
- **Resolution:** Point-based extraction linked to CHELSA 90 arcsec resolution.
- **Reference Period:** 1979-01-01 to 2015-12-31.

---
*Data Processing by ZALF CSA Team*
