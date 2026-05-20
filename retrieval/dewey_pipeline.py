# -*- coding: utf-8 -*-
"""
Retrieval and unpacking of the Advan monthly foot traffic data (raw data) from Dewey.

This script:
1. Downloads one month of raw data from the Dewey API (requires API key).
2. Filters for restaurants, removes duplicates and outliers.
3. Unpacks the 'visitor_home_cbgs' JSON column into long format (CBG–restaurant pairs).

Before running:
- Set your working directory to a folder where you have write access.
- Set your Dewey API key as an environment variable or paste it below (not recommended for sharing).
"""

# 1. Import libraries
import pandas as pd
import numpy as np
import json
import requests
import os

# 2. Set your working directory (change this to your own path)
os.chdir("")   # <-- REPLACE with your path

# 3. Dewey API credentials
API_KEY = "PASTE_YOUR_KEY_HERE"    # <-- Dewey API key – replace with your own
PRODUCT_API_PATH = "PASTE_PRODUCT_API_PATH_HERE"   # <-- Product API path – replace with your own

# Month/year to download (using Dec. 2023 as an example)
y = '2023'
m = '12'

# 4. Get list of file download links from API
results = requests.get(url=PRODUCT_API_PATH,
                       params={'page': 1,
                               'partition_key_after': y + '-' + m + '-01',
                               'partition_key_before': y + '-' + m + '-01'},
                       headers={'X-API-KEY': API_KEY,
                                'accept': 'application/json'})
response_json = results.json()
num = len(response_json["download_links"])

# 5. Download all ZIP files for that month
for i, link_data in enumerate(response_json["download_links"]):
    print(f"Downloading file {i}...")
    data = requests.get(link_data["link"])
    open(link_data["file_name"], 'wb').write(data.content)

# 6. Combine and filter for restaurants
relevant = 'Restaurants and Other Eating Places'
batch = pd.DataFrame()

for i in range(0, num):
    file_name = f'Monthly_Patterns_Foot_Traffic-{i}-DATE_RANGE_START-{y}-{m}-01.csv.gz'
    temp = pd.read_csv(file_name, compression='gzip', low_memory=False)
    temp = temp[temp["TOP_CATEGORY"] == relevant]
    batch = pd.concat([batch, temp], axis=0)
    print(f'Compiling month {y}-{m}: file {i} done')

# 7. Select relevant columns
reduced_raw = pd.DataFrame({
    "placekey": batch['PLACEKEY'],
    "parent_placekey": batch['PARENT_PLACEKEY'],
    "location_name": batch['LOCATION_NAME'],
    "sub_category": batch['SUB_CATEGORY'],
    "category_tags": batch['CATEGORY_TAGS'],
    "region": batch['REGION'],
    "city": batch['CITY'],
    "postal_code": batch['POSTAL_CODE'],
    "poi_cbg": batch['POI_CBG'],
    "street_address": batch['STREET_ADDRESS'],
    "longitude": batch['LONGITUDE'],
    "latitude": batch['LATITUDE'],
    "raw_visit_counts": batch['RAW_VISIT_COUNTS'],
    "raw_visitor_counts": batch['RAW_VISITOR_COUNTS'],
    "visitor_home_cbgs": batch['VISITOR_HOME_CBGS'],
    "wkt_area_sq_meters": batch['WKT_AREA_SQ_METERS']
})

# 8. Remove POIs that are part of a larger parent location (e.g., mall kiosks, airports)
duplicated_mask = reduced_raw.duplicated(subset=['street_address', 'raw_visit_counts'], keep=False)
reduced_raw['is_duplicated'] = duplicated_mask.astype(int)
not_duplicate = reduced_raw[reduced_raw['is_duplicated'] != 1]

# 9. Remove outliers (very low or extremely high visit counts)
q995 = not_duplicate['raw_visit_counts'].quantile(0.995)
not_duplicate = not_duplicate[(not_duplicate['raw_visit_counts'] >= 10) & (not_duplicate['raw_visit_counts'] <= q995)]

# 10. Save cleaned intermediate file (before unpacking)
not_duplicate.to_csv(f'advan_mp_{y}{m}_processed_newproj.csv', index=False)

# 11. Unpack the visitor_home_cbgs JSON column using SafeGraph's helper package
#    Install it once with: pip install git+https://github.com/SafeGraphInc/safegraph_py
from safegraph_py_functions import safegraph_py_functions as sgpy

data_for_unpack = not_duplicate[["placekey", "location_name", "region",
                                 "visitor_home_cbgs", "sub_category", "category_tags"]]
data_for_unpack = data_for_unpack[(data_for_unpack['visitor_home_cbgs'] != '{}') &
                                  (data_for_unpack['visitor_home_cbgs'].notnull())]

data_long = sgpy.unpack_json_and_merge_fast(data_for_unpack,
                                            json_column='visitor_home_cbgs',
                                            key_col_name='visitor_home_cbg',
                                            value_col_name='count')
data_long = data_long[['placekey', 'location_name', 'region', 'sub_category',
                       'category_tags', 'visitor_home_cbg', 'count']]

# 12. Save final long‑format data (CBG–restaurant pairs)
os.chdir("")   # <-- REPLACE with your unpack output folder
data_long.to_csv(f'{y}_{m}_unpacked.csv', index=False)

print("Pipeline finished successfully.")