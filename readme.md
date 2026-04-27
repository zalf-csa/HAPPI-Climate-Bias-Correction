# HAPPI Climate Data Bias-Correction

This repository demonstrates the scientific logic used to process and bias-adjust daily climate projection data from the **HAPPI** (Half a degree Additional warming, Prognosis and Projected Impacts) dataset, using **CHELSA-W5E5** as a reference.

## 🔗 Original Data Sources
- **HAPPI Model Data:** [NERC Portal](https://portal.nersc.gov/c20c/data.html)
- **CHELSA-W5E5 Reference Data:** [ISIMIP Repository](https://data.isimip.org/10.48364/ISIMIP.836809.3)

## 📂 Repository Structure

| File | Category | Purpose |
| :--- | :--- | :--- |
| `settings.R` | Configuration | Site coordinates, GCM selection, and period settings. For this demo, we run only for 1 GCM, 1 ensemble member, and 1 period for 1 location. |
| `01_extract_cluster_data.R` | Data Extraction | Script used to extract and filter data from global datasets. |
| `extracted_sample_Tempelberg/` | Data Sample | Pre-extracted CSV files for Tempelberg (Observed, Hist, Future). |
| `02_bias_correction.R` | Primary Demo | Core scientific logic (EQM) and unit conversions. Runs locally. |

## 🛠 Installation and Workflow

### Prerequisites

Ensure the following are installed before proceeding:
- **Git**: [Download here](https://git-scm.com/downloads)
- **R (>= 4.0 recommended, developed with 4.4.3)**: [Download here](https://cloud.r-project.org/)
- **RTools (Windows only)**: [Download here](https://cran.r-project.org/bin/windows/Rtools/)

### Getting Started

To clone the repository and set up the environment, follow these steps:

1. **Clone the repository and navigate into the folder:**
```bash
git clone https://github.com/zalf-csa/HAPPI-Climate-Bias-Correction.git
cd HAPPI-Climate-Bias-Correction
```

2. **Ensure R is in the system PATH:**
If `Rscript` is not recognized, run the appropriate command for the operating system:
- **Windows (Command Prompt):** `set PATH=C:\Path\To\R\bin;%PATH%`
- **Windows (PowerShell):** `$env:PATH += ";C:\Path\To\R\bin"`
- **Linux/macOS:** `export PATH="/path/to/R/bin:$PATH"`

3. **Set up the R environment:**
Run the following command to initialize the project environment and install all required packages (including dependencies from GitHub and `terra`):

```bash
Rscript -e "Sys.setenv(RENV_CONFIG_SYNCHRONIZED_CHECK = 'FALSE'); if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv'); renv::restore(prompt = FALSE)"
```

*Note: This command handles everything. If `renv::restore()` fails (e.g., due to GitHub connection issues), you can try installing the packages manually:*
```bash
Rscript -e "if (!requireNamespace('remotes', quietly = TRUE)) install.packages('remotes')"
Rscript -e "remotes::install_github(c('SantanderMetGroup/transformeR', 'SantanderMetGroup/downscaleR'), upgrade = 'never', dependencies = TRUE)"
```

### Step 1: Data Extraction (Informational / Reference Only)
The script `01_extract_cluster_data.R` is used to extract and filter data from the global datasets for a specific location. It assumes the datasets from the **Original Data Sources** section have been downloaded into a base directory (e.g., `base_dir <- "C:/Data/Climate"` or a network drive). 

**Note:** Running this script is **not required** for the demo. Due to the huge amount of weather data involved in the extraction (multi-terabyte scale), this repository already provides the output from this step in the `extracted_sample_Tempelberg/` folder. This pre-extracted data serves as the direct input for Step 2. One can review the script to understand the extraction and filtering logic.

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
