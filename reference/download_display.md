# Download display full-load data

Download display full-load data

## Usage

``` r
download_display(
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
)
```

## Arguments

- format:

  File format: `"csv"` or `"json"`.

- destination_path:

  Directory where ZIP is saved.

- unzip:

  Whether to extract ZIP contents into a sibling directory.

- overwrite:

  Whether to replace an existing ZIP.
