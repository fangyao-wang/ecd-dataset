# Processing Scripts for ECD Diversity Indices

This folder contains R scripts that take the **unpacked CBG–restaurant visit data** (output from the Python retrieval script) and compute the Experiential Culinary Diversity (ECD) indices at quarterly and monthly levels.

## Lookup Tables

The files `service_lookup.csv` and `ethnic_lookup.csv` provide merely **quick reference** mappings from raw Advan category tags to the standardized service types and ethnic cuisine categories. They are **documentation aids**, not executables.

For the **full hierarchical priority rules**, handling of ambiguous/missing tags, and worked examples, please see the main manuscript (Section: Restaurant Categorization Scheme) and its supplementary tables.

## R Scripts

### `code_calculate_diversity_cbg_quarter.R` (main)

This script processes **quarterly** data and produces the **primary ECD dataset** used in the manuscript.

**What it does:**
- Reads monthly unpacked CSV files (`YYYY_MM_unpacked.csv`) for a given quarter.
- Aggregates visits to the quarter level (summing counts per CBG–restaurant pair).
- Applies the service type and ethnicity classification rules (using `case_when` logic with sequential priority).
- Combines the two dimensions into a final `combined` category.
- Calculates Hill numbers (`q = 0, 1, 2`) for three levels: service only (Method 1), ethnicity only (Method 2), and combined (Method 3).
- Outputs one CSV per quarter (`YYYY_QX.csv`) containing diversity indices for each CBG.

**Input requirement:** Unpacked files named exactly `YYYY_MM_unpacked.csv` (e.g., `2019_01_unpacked.csv`).

**To run:** Set the `data_dir` variable at the top of the script to the folder containing your unpacked files, then source the script.

### `code_calculate_diversity_cbg_monthly.R` (for reference only)

This script processes **monthly** data and is **not** used for the final dataset. It is provided for completeness and for users who may need monthly granularity. The logic is identical to the quarterly version but without temporal aggregation.

## Dependencies

All scripts require the following R packages:
- `dplyr`, `tidyverse`, `data.table`, `readr`

Install them with:
```r
install.packages(c("dplyr", "tidyverse", "data.table", "readr"))