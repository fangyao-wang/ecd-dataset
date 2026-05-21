# Sample Input Data for Testing

This folder contains a small, anonymized subset of the unpacked Advan foot‑traffic data, provided solely to test the R processing pipeline (`processing/code_calculate_diversity_cbg_quarter.R`).

## File: `example_unpacked.csv`

- **Rows:** 4433 (100 randomly sampled restaurants × their visitor home CBGs)
- **Columns:** `placekey`, `location_name`, `region`, `sub_category`, `category_tags`, `visitor_home_cbg`, `count`
- **Time period:** January 2019 (one month only)

## How it was generated

1. From the full January 2019 unpacked dataset, 100 unique restaurants were randomly sampled (seed = 2026).
2. All rows corresponding to these restaurants were kept.
3. The original `placekey` values were replaced with `"restaurant_1"`, `"restaurant_2"`, … `"restaurant_100"` to anonymize POI identities.
4. CBG codes (`visitor_home_cbg`) remain unchanged – they are public geographic identifiers and contain no personal information.
5. The `location_name` column was dropped (optional; not used in the diversity calculation).

## Limitations (important)

This sample is **not** suitable for any actual analysis. It is intended only to:

- Verify that the classification and Hill‑number scripts run without errors.
- Confirm that the output CSV structure matches expectations.

**Do not** use this sample to draw conclusions about culinary diversity, visitation patterns, or any substantive research question. The sample size is far too small and the selection is random, not representative.

## Full dataset

The complete ECD dataset (quarterly indices for all US CBGs, 2019–2023) is available at the Harvard Dataverse DOI listed in the main README.