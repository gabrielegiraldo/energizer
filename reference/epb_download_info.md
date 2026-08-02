# Fetch full-load download metadata

Fetch full-load download metadata

## Usage

``` r
epb_download_info(type = .epb_download_types, format = c("csv", "json"))
```

## Arguments

- type:

  Dataset type: `"domestic"`, `"non_domestic"`, `"display"`,
  `"non_domestic_recommendation"`, or `"display_recommendation"`.

- format:

  File format: `"csv"` or `"json"`.

## Value

A one-row tibble containing file size and last-updated timestamp.
