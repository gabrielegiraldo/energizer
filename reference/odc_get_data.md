# Retrieve certificate or recommendations data by LMK key

`odc_get_data()` fetches detailed data for a specific Energy Performance
Certificate (EPC) or Display Energy Certificate (DEC) using its unique
LMK key. This function is the core mechanism for retrieving individual
certificate records and their recommendations from the API.

## Usage

``` r
odc_get_data(lmk_key = NULL, type, endpoint)
```

## Arguments

- lmk_key:

  `character` The unique Landmark (LMK) identifier for the certificate.
  This is a required parameter.

- type:

  `character` Type of certificate. Must be one of: `"domestic"`,
  `"non_domestic"`, or `"display"`.

- endpoint:

  `character` Type of data to retrieve. Must be one of: `"certificate"`
  (for full certificate details) or `"recommendation"` (for improvement
  recommendations).

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)
containing the requested data. For certificate endpoints, this includes
property details, energy ratings, and certificate information. For
recommendation endpoints, this includes improvement suggestions, costs,
and potential savings.

## Details

The function constructs the appropriate API endpoint URL based on the
certificate type and data endpoint, performs an authenticated request,
and returns the results as a tibble.

## Examples

``` r
if (FALSE) { # \dontrun{
# Retrieve full details for a domestic EPC
cert_data <- odc_get_data(
  lmk_key = "12345678901234567890123456789012",
  type = "domestic",
  endpoint = "certificate"
)

# Retrieve recommendations for a non-domestic EPC
rec_data <- odc_get_data(
  lmk_key = "98765432109876543210987654321098",
  type = "non_domestic",
  endpoint = "recommendation"
)

# Retrieve details for a Display Energy Certificate (DEC)
dec_data <- odc_get_data(
  lmk_key = "55555555555555555555555555555555",
  type = "display",
  endpoint = "certificate"
)
} # }
```
