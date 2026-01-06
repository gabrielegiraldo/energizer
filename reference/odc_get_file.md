# Filter available EPC data files by type and/or local authority

Returns a subset of available Energy Performance Certificate data files
filtered by certificate type (domestic, non-domestic, display) and/or
local authority code. Useful for finding specific files to download.

## Usage

``` r
odc_get_file(type = NULL, local_authority_code = NULL)
```

## Arguments

- type:

  `character` string specifying certificate type to filter by. Must be
  one of: "domestic", "non_domestic", or "display". Case-sensitive.

- local_authority_code:

  `character` string of local authority code to filter by (e.g.,
  "E09000001" for City of London). Optional.

## Value

A tibble with two columns:

- file_name:

  Character vector of filtered file names

- size:

  Numeric vector of corresponding file sizes in bytes

Returns an empty tibble if no files match the filter criteria.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get all domestic certificate files
domestic_files <- odc_get_file(type = "domestic")

# Get domestic files for a specific local authority
domestic_birmingham <- odc_get_file(type = "domestic", local_authority_code = "E08000025")

# Get all files for a local authority (any type)
birmingham <- odc_get_file(local_authority_code = "E08000025")
} # }
```
