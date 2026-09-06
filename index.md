# energizer

R client for UK government’s [Get energy performance of buildings data
API](https://get-energy-performance-data.communities.gov.uk/api-technical-documentation).
It retrieves EPC and DEC records, searches certificates, tracks changes
and downloads monthly full-load datasets.

## Installation

Install development version from GitHub:

``` r

# install.packages("pak")
pak::pak("gabrielegiraldo/energizer")
```

## Authentication

Sign in to service, copy bearer token from **My account**, then set it
for current R session:

``` r

energizer::set_token("your-bearer-token")
```

For non-interactive use, set `EPB_BEARER_TOKEN` before starting R. Do
not commit token to source control.

## Fetch certificate

``` r

certificate <- energizer::get_certificate(
  "1111-2222-3333-4444-5555"
)
```

## Search certificates

Search domestic, non-domestic or display certificates with API filters:

``` r

domestic <- energizer::search_domestic(
  postcode = "LS1 4AP"
)

non_domestic <- energizer::search_non_domestic(
  council = c("Manchester", "Salford"),
  efficiency_rating = c("F", "G")
)

display <- energizer::search_display(
  date_start = "2025-01-01",
  date_end = "2025-01-31"
)
```

Retrieve all pages or cap result size:

``` r

results <- energizer::search_domestic(
  address = "Liverpool Road",
  paginate = "all",
  max_records = 10000
)

attr(results, "pagination")
```

## Changed certificates

``` r

changes <- energizer::get_deltas(
  "2025-01-01",
  "2025-01-31"
)
```

## Full-load downloads

Monthly full-load datasets can be large. Download ZIP first; extraction
is optional:

``` r

energizer::download_domestic(
  format = "csv",
  destination_path = "data"
)

energizer::download_info("domestic", "csv")
```

Recommendation datasets are JSON-only:

``` r

energizer::download_non_domestic_recommendations_json("data")
energizer::download_display_recommendations_json("data")
```

## EPC codes

``` r

energizer::get_codes()
energizer::get_code_info("built_form", key = "NR")
```

## Migration from 0.10.0

| Old function | Replacement |
|----|----|
| [`odc_set_key()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`set_token()`](https://gabrielegiraldo.github.io/enrgz/reference/set_token.md) |
| [`odc_get_data()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`get_certificate()`](https://gabrielegiraldo.github.io/enrgz/reference/get_certificate.md) |
| [`odc_search_data()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`search_domestic()`](https://gabrielegiraldo.github.io/enrgz/reference/search_domestic.md), [`search_non_domestic()`](https://gabrielegiraldo.github.io/enrgz/reference/search_non_domestic.md), or [`search_display()`](https://gabrielegiraldo.github.io/enrgz/reference/search_display.md) |
| [`odc_bulk_download()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`download_full_load()`](https://gabrielegiraldo.github.io/enrgz/reference/download_full_load.md) or type-specific download functions |
| [`odc_get_file()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) / [`odc_get_file_list()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`download_info()`](https://gabrielegiraldo.github.io/enrgz/reference/download_info.md) |
| [`odc_get_schema()`](https://gabrielegiraldo.github.io/enrgz/reference/odc-defunct.md) | [`get_codes()`](https://gabrielegiraldo.github.io/enrgz/reference/get_codes.md) / [`get_code_info()`](https://gabrielegiraldo.github.io/enrgz/reference/get_code_info.md) |

Old `odc_*` functions are defunct because old API authentication,
LMK-key endpoints and local-authority file listings no longer exist.

## Disclaimer

*This package is not affiliated with or endorsed by UK government.*
