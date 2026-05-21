# Retrieval: Advan foot traffic data from Dewey

This script downloads raw monthly data from the Dewey API, filters for restaurants (NAICS 722511, 722513), and unpacks the `visitor_home_cbgs` JSON column.

## How `visitor_home_cbgs` works

The raw data stores visitor origins as a JSON dictionary (string) where:
- **Keys** = Census Block Group (CBG) FIPS codes (home locations of visitors)
- **Values** = estimated number of visits from that CBG to the POI

Example: `{"360610001001": 42, "360610001002": 17}`

The script expands this dictionary into a long‑format table with one row per (POI, visitor_home_cbg) pair, making it suitable for aggregation at the CBG level.

## Requirements
- Dewey API key (proprietary, requires license)
- Python 3.8+ with: `pandas`, `numpy`, `requests`, `safegraph_py`

> **For R users:** There exist similar dedicated R packages for unpacking (e.g. SafeGraphR). Otherwise the `jsonlite` package could also work.

## Usage
1. Edit `dewey_pipeline.py` – set:
   - `API_KEY` (your Dewey key)
   - `PRODUCT_API_PATH` (your product endpoint)
   - Working directories (two `os.chdir()` calls)
2. Run: `python dewey_pipeline.py`

## Output
- Long‑format CSV: `YYYY_MM_unpacked.csv` (columns: `placekey`, `location_name`, `region`, `sub_category`, `category_tags`, `visitor_home_cbg`, `count`)

> **Note:** This step is not reproducible without a Dewey license. The final ECD dataset and processing scripts (which *are* reproducible) are in the parent directory.