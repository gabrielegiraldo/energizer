# Download and extract EPC data files from ZIP archives

Downloads specified ZIP files from the EPC Open Data API, extracts
either certificate or recommendation CSV data, and saves it to the
destination path. Handles authentication, error checking, and cleanup of
temporary files.

## Usage

``` r
odc_bulk_download(
  file_name,
  destination_path,
  type = c("certificate", "recommendation"),
  keep_zip = FALSE
)
```

## Arguments

- file_name:

  `character` File name to be downloaded (extension included) Should be
  a valid file name from
  [`odc_get_file()`](https://gggiraldo.github.io/enrgz/reference/odc_get_file.md)
  or
  [`odc_get_file_list()`](https://gggiraldo.github.io/enrgz/reference/odc_get_file_list.md).

- destination_path:

  `character` Directory path where extracted CSV file will be saved.
  Directory will be created if it doesn't exist.

- type:

  `character` String specifying which data type to extract from the ZIP
  archive. Must be either "certificate" (default) or "recommendation".

- keep_zip:

  `logical` Should the downloaded ZIP file be kept? If yes, it will be
  saved in `destination_path`. Default is `FALSE` (only extracted CSV is
  kept).

## Value

Invisibly returns `NULL`. The function's primary purpose is the side
effect of saving extracted CSV data to disk.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download and extract domestic certificate data for London
odc_bulk_download(
  file_name = "domestic-E08000025.zip",
  destination_path = here::here("downloads"),
  type = "certificate"
)

# Download and keep the ZIP file along with extracted recommendations
odc_bulk_download(
  file_name = "non_domestic-E08000025.csv.zip",
  destination_path = here::here("downloads"),
  type = "recommendation",
  keep_zip = TRUE
)
} # }
```
