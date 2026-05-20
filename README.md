# ecd-dataset
Experiential Culinary Diversity (ECD) Dataset – code for processing Advan foot traffic data, classification, diversity indices, and validation.


[![DOI](https://img.shields.io/badge/DOI-10.7910/DVN/XXXXXX-blue)](https://doi.org/10.7910/DVN/XXXXXX)  
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains all code and documentation required to process raw foot‑traffic data (from Advan/Dewey) into the **Experiential Culinary Diversity (ECD) dataset** at the US Census Block Group level. The final dataset, which includes quarterly diversity indices (`q=0,1,2`) for three classification levels (service type, ethnic cuisine, and combined), is publicly available via the DOI above.

**Associated manuscript:**  
Liu, P., Li, M., Wang, F., & Zhang, W. (2025). *A high‑resolution dataset of experiential culinary diversity for the United States*. Scientific Data. (In review / accepted)

---

## Repository Structure

ecd-dataset/

├── README.md # This file

├── retrieval/ # Stage 1: Python API download & unpacking

│ ├── dewey_pipeline.py # Downloads raw data from Dewey API

│ └── README_retrival.md # Instructions for the retrieval step

├── processing/ # Stage 2: R scripts for classification & diversity

│ ├── code_calculate_diversity_cbg_quarter.R # Main script (quarterly, final dataset)

│ ├── code_calculate_diversity_cbg_monthly.R # Monthly version (reference only)

│ ├── lookup_tables/ # Quick‑reference mapping files

│ │ ├── generate_lookup_tables.R # Creates priority‑aware CSV lookup tables

│ │ ├── service_lookup.csv

│ │ └── ethnic_lookup.csv

│ └── README_processing.md # Details on running the R scripts

├── validation/ # Stage 3: Reproducible validation analyses (if any)

│ └── (Scripts for construct validity, moved to supplementary)

├── data/ # Example subset of unpacked input data (for testing)

│ └── example_unpacked.csv # Small sample (e.g., one month, one state)

└── environment/ # Computational environment specifications

├── requirements.txt # Python packages (pip)

└── renv.lock # R packages (renv) – optional



---

## Overview of the Pipeline

The creation of the ECD dataset consists of three main stages:

1. **Retrieval & unpacking** (Python) – Download monthly foot‑traffic data from the Dewey API, filter for restaurants, remove duplicates/outliers, and unpack the `visitor_home_cbgs` JSON column into long format (CBG–restaurant pairs with visit counts).  
   *This step requires a Dewey API key and is not fully reproducible without access to the proprietary raw data.*

2. **Classification & diversity calculation** (R) – Assign each restaurant an **experiential service type** and an **ethnic cuisine type** using hierarchical rules (priority‑based), combine them, and compute Hill numbers (`q=0,1,2`) at the CBG‑quarter level.  
   *This step is fully reproducible given the unpacked input files.*

3. **Validation & final dataset** – The final ECD indices are archived in a public repository. The validation regressions (construct validity checks) are described in the manuscript and the supplementary materials; the code is provided here for completeness.

---

## Getting Started

### Prerequisites

- **Python 3.8+** (for the retrieval step, only needed if you obtain a Dewey license)
- **R 4.0+** (for the processing step)
- Git (optional, for cloning)


### Step 1 – Prepare the environment

**Python**  

Install basic required packages: 

`numpy, pandas, json, requests, os`

Install and Read the sgpy package:

`pip install -q --upgrade git+https://github.com/SafeGraphInc/safegraph_py`
`from safegraph_py_functions import safegraph_py_functions as sgpy`

**R**

Install the required packages:

`install.packages(c("dplyr", "tidyverse", "data.table", "readr"))`





### Step 2 – Obtain the unpacked input data

The processing scripts expect **unpacked CSV files** named `YYYY_MM_unpacked.csv`.

- If you have a Dewey license, run the retrieval script (`retrieval/dewey_pipeline.py`) to generate these files.
- If you only want to test the R pipeline, use the example subset provided in `data/example_unpacked.csv`.

### Step 3 – Run the diversity calculation

1. Open `processing/code_calculate_diversity_cbg_quarter.R`.
2. Set the `data_dir` variable to the folder containing your unpacked CSV files (e.g., `data_dir <- "./data"`).
3. Run the script. It will produce quarterly CSV files (e.g., `2019_Q1.csv`) with diversity indices for each CBG.

These quarterly files are the **final ECD dataset** used in the manuscript.

## Reproducibility & Reuse

| Component | Reproducible? |
|-----------|---------------|
| Dewey raw data download & unpacking | ❌ No – requires proprietary API key and raw data access |
| Restaurant classification (R code) | ✅ Yes – given the same unpacked input files |
| Hill number calculation (R code) | ✅ Yes |
| Final ECD dataset (CSV files) | ✅ Yes – archived separately with a DOI |

If you cannot obtain the Dewey data, the classification and diversity logic can be **conceptually replicated** using any similar foot‑traffic dataset (e.g., SafeGraph, PlaceIQ). The lookup tables and R code provide a ready‑to‑use framework for such replication.


## Citing This Repository ##
Please cite both this repository and the associated data archive:

Liu, P., Li, M., Wang, F., & Zhang, W. (2025). ecd-dataset: Code and documentation for the Experiential Culinary Diversity dataset. GitHub. https://github.com/fangyao-wang/ecd-dataset

Liu, P., Li, M., Wang, F., & Zhang, W. (2025). Experiential Culinary Diversity (ECD) Index for the United States, 2019‑2023. Harvard Dataverse. https://doi.org/10.7910/DVN/XXXXXX

For the full methodological details, please refer to the Scientific Data paper.

## License ##
Code (all scripts): MIT

Data (the final ECD indices): CC‑BY‑4.0

## Contact ##
For questions, please open an issue on this repository or contact the corresponding authors:


## Notes ##
The raw Dewey data are not included in this repository due to licensing restrictions.

The example subset in data/ is synthetic or a very small sample of real data, provided solely to test the processing pipeline.