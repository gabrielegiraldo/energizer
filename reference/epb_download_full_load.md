# Download a full-load energy certificate dataset

Downloads a monthly full-load ZIP. Recommendation datasets are available
in JSON only. Redirects to time-limited download URLs are followed
automatically.

## Usage

``` r
epb_download_full_load(
  type = .epb_download_types,
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
)
```

## Arguments

- type:

  Dataset type: `"domestic"`, `"non_domestic"`, `"display"`,
  `"non_domestic_recommendation"`, or `"display_recommendation"`.

- format:

  File format: `"csv"` or `"json"`.

- destination_path:

  Directory where ZIP is saved.

- unzip:

  Whether to extract ZIP contents into a sibling directory.

- overwrite:

  Whether to replace an existing ZIP.

## Value

Downloaded ZIP path, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
epb_download_full_load("domestic", "csv", tempdir())
} # }
```
