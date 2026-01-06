# Get a tidy data frame of available EPC data files

Retrieve a clean data frame with file names and sizes. This provides a
convenient overview of all downloadable Energy Performance Certificate
data files.

## Usage

``` r
odc_get_file_list()
```

## Value

A tibble with two columns:

- file_name:

  Character vector of file names available for download

- size:

  Numeric vector of file sizes in bytes

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires API key set via odc_set_key()
odc_get_file_list()
} # }
```
