# Search for Energy Performance Certificates and Display Energy Certificates

This function allows to search for energy certificates from the Open
Data Communities API. It provides access to *Domestic*, *Non-domestic*,
and *Display* Certificates, with full support for pagination.

## Usage

``` r
odc_search_data(
  type = c("domestic", "non_domestic", "dislay"),
  paginate = c("none", "all", "manual"),
  max_pages = NULL,
  max_records = NULL,
  ...
)
```

## Arguments

- type:

  `character` The **type of certificate** to search for. Must be one of:

  - `"domestic"`: Domestic Energy Performance Certificates (homes)

  - `"non_domestic"`: Non-domestic Energy Performance Certificates
    (business premises)

  - `"display"`: Display Energy Certificates (public buildings)

- paginate:

  `character` **Pagination control mode**. Must be one of:

  - `"none"`: Fetch only the first page of results (default, fastest)

  - `"all"`: Automatically retrieve all available pages

  - `"manual"`: Fetch first page and display continuation token for
    manual control

- max_pages:

  `integer` or `NULL`. **Maximum pages** to retrieve when
  `paginate = "all"`. Useful for limiting large queries during testing.
  Ignored in other modes.

- max_records:

  `integer` or `NULL`. **Maximum total records** to retrieve. When
  specified, automatically switches `paginate = "all"` and fetches
  records across multiple pages until the limit is reached. Efficiently
  adjusts page sizes.

- ...:

  **Search filters** passed as name-value pairs. Common parameters
  include:

  - `address`: `character` Address search string (e.g.,
    `"Downing Street"`)

  - `postcode`: `character` UK postcode, full or partial (e.g.,
    `"SW1A"`, `"SW1A 1AA"`)

  - `local_authority`: `character` Local authority code (e.g.,
    `"E09000030"`)

  - `from_date`, `to_date`: `character` Date range in `"YYYY-MM"` format

  - `property_type`: `character` Property type (e.g., `"house"`,
    `"flat"`)

  - `size`: `integer` Page size (1-5000, defaults to 25)

  **Note:** Parameters with hyphens in the API (`local-authority`) can
  be written with underscores instead (`local_authority`).

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing certificate records matching the search criteria. The tibble
includes all available fields from the API. Returns an empty tibble if
no matches are found.

## Examples

``` r
if (FALSE) { # \dontrun{
# Basic search for domestic certificates by postcode
odc_search_data("domestic", postcode = "SW1A 1AA")

# Search non-domestic certificates with address filter
odc_search_data("non_domestic", address = "London", size = 100)

# Search Display Energy Certificates with authority filter
odc_search_data("display", local_authority = "E09000030")

# Get exactly 500 records (automatically paginates)
odc_search_data("domestic", max_records = 500, postcode = "SW1A")

# Manual pagination control
first_page <- odc_search_data("domestic", paginate = "manual",
                              address = "Manchester")
# Use token from message to get next page manually

# Complex search with multiple filters
odc_search_data(
  "domestic",
  paginate = "all",
  max_records = 1000,
  postcode = "SW1A",
  from_date = "2020-01",
  to_date = "2023-12",
  property_type = "flat"
)
} # }
```
