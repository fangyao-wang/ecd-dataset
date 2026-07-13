# ecd-dataset
Experiential Culinary Diversity (ECD) Dataset – code for processing Advan foot traffic data, classification, diversity indices, and validation.


[![Data DOI](https://img.shields.io/badge/Data%20DOI-10.7910/DVN/PXKT5F-blue)](https://doi.org/10.7910/DVN/PXKT5F)
[![Code DOI](https://img.shields.io/badge/Code%20DOI-10.5281/zenodo.21330947-blue)](https://doi.org/10.5281/zenodo.21330947)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This repository contains all code and documentation required to process raw foot‑traffic data (from Advan/Dewey) into the **Experiential Culinary Diversity (ECD) dataset** at the US Census Block Group (CBG) level. The final dataset – quarterly diversity indices (`q = 0, 1, 2`) for three classification levels (service type, ethnic cuisine, and combined) – is publicly available via the Data DOI above.

**Associated manuscript:**  
Wang, F., Li, M., Liu, P., & Zhang, W. (2026). *A visit-based dataset of experiential culinary diversity for U.S. census block groups*. Manuscript in preparation for submission to *Nature Scientific Data*.  
*Note: This paper has not yet been published. Please do not cite it until the final version appears.*

---

## Repository Structure

```text
ecd-dataset/
├── README.md                                # This file
├── retrieval/                               # Stage 1: Python API download & unpacking
│ ├── dewey_pipeline.py                      # Downloads raw data from Dewey API
│ └── README_retrival.md                     # Instructions for the retrieval step
├── processing/                              # Stage 2: R scripts for classification & diversity
│ ├── code_calculate_diversity_cbg_quarter.R # Main script (quarterly, final dataset)
│ ├── code_calculate_diversity_cbg_monthly.R # Monthly version (reference only)
│ ├── lookup_tables/                         # Quick‑reference mapping files
│ │ ├── generate_lookup_tables.R             # Creates priority‑aware CSV lookup tables
│ │ ├── service_lookup.csv
│ │ └── ethnic_lookup.csv
│ └── README_processing.md                   # Details on running the R scripts
├── validation/                              # Stage 3: Reproducible validation analyses (if any)
│ └── (Scripts for construct validity, regression, and visualization)
├── data/                                    # Example subset of unpacked input data (for testing)
│ └── example_unpacked.csv                   # Small sample (100 restaurants, anonymized)
```


---

## Overview of the Pipeline

The creation of the ECD dataset consists of three main stages:

1. **Retrieval & unpacking (Python)** – Download monthly foot‑traffic data from the Dewey API, filter for restaurants (NAICS 722511, 722513), remove duplicates/outliers, and unpack the `visitor_home_cbgs` JSON column into a long format (CBG–restaurant pairs with visit counts).  
   *This step requires a Dewey API key and access to proprietary raw data. It is not reproducible without a license.*

2. **Classification & diversity calculation (R)** – Assign each restaurant an **experiential service type** (e.g., fast food, casual dining, café) and an **ethnic cuisine type** (e.g., Italian, Chinese, Mexican) using hierarchical priority rules. Then compute Hill numbers (`q = 0, 1, 2`) at the CBG‑quarter level.  
   *This step is fully reproducible given the unpacked input files.*

3. **Validation & final dataset** – The final ECD indices are archived in a public data repository (Harvard Dataverse). Validation regressions (construct validity checks) are described in the manuscript; code is provided here for completeness.

---

## Getting Started

### Prerequisites

- **Python 3.8+** (for the retrieval step, only needed if you obtain a Dewey license)
- **R 4.0+** (for the processing step)
- Git (optional, for cloning)


### Step 1 – Prepare the environment

**Python (for retrieval only)**  

Install basic required packages: 

```bash
pip install numpy pandas json requests
```

Install the SafeGraph Python helper:

```bash
pip install -q --upgrade git+https://github.com/SafeGraphInc/safegraph_py
```

Then in python:
```python
from safegraph_py_functions import safegraph_py_functions as sgpy
```

**R (processing)**

Install required packages from CRAN:

```R
install.packages(c("dplyr", "tidyverse", "data.table", "readr"))
```




### Step 2 – Obtain the unpacked input data

The processing scripts expect **unpacked CSV files** named `YYYY_MM_unpacked.csv`.

- If you have a Dewey license, run the retrieval script (`retrieval/dewey_pipeline.py`) to generate these files.
- If you only want to test the R pipeline, use the example subset provided in `data/example_unpacked.csv`.

### Step 3 – Run the diversity calculation

1. Open `processing/code_calculate_diversity_cbg_quarter.R`.
2. Set the `data_dir` variable to point to your folder of unpacked CSV files, e.g., 

```r
data_dir <- "./data"`)
```

3. Run the script. It will produce quarterly CSV files (e.g., `2019_Q1.csv`) with diversity indices for each CBG.

These quarterly files constitute the **final ECD dataset** used in the manuscript.


## Reproducibility & Reuse

| Component | Reproducible? |
|-----------|---------------|
| Dewey raw data download & unpacking (Python) | ❌ No – requires proprietary API key |
| Restaurant classification (R) | ✅ Yes – given the same unpacked input files |
| Hill number calculation (R) | ✅ Yes |
| Final ECD dataset (CSV files) | ✅ Yes – archived separately with a DOI |

If you cannot obtain the Dewey data, the classification and diversity logic can potentially be **conceptually replicated** using any similar POI-based foot‑traffic dataset (e.g. PlaceIQ, Veraset). The lookup tables and R code provide a ready‑to‑use framework for such replication.


## Citing This Repository ##

Please cite both the code (this repository via Zenodo) and the data (Harvard Dataverse):

**Code** 

Wang, F., Li, M., Liu, P., & Zhang, W. (2026). *ecd-dataset: Code and documentation for the Experiential Culinary Diversity dataset* (Version v1.0.0). Zenodo. https://doi.org/10.5281/zenodo.21330947

**Data**

Wang, F., Li, M., Liu, P., & Zhang, W. (2026). *Experiential Culinary Diversity (ECD) Dataset for U.S. Census Block Groups, 2019 & 2023* [Data set]. Harvard Dataverse. https://doi.org/10.7910/DVN/PXKT5F


For the full methodological details, please refer to the Scientific Data paper.

## License ##

- Code (all scripts in this repository): MIT

- Data (final ECD indices in Harvard Dataverse): CC‑BY‑4.0

## Contact ##
For questions, please open an issue on this repository or contact the authors:

- Fangyao Wang - fwang225@wisc.edu

- Miao Li - forli0829@163.com

- Peng Liu - peng.liu@cornell.edu

- Wendong Zhang - wendongz@cornell.edu

## Notes ##

- The raw Dewey data are not included in this repository due to licensing restrictions.

- The example file data/example_unpacked.csv is either synthetic or a very small sample of real data, provided solely to test the processing pipeline.

- The final ECD dataset is not stored on GitHub; please use the Harvard Dataverse DOI to access the full data.
