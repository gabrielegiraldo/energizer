# Set your Open Data Communities API credentials

`odc_set_key()` stores your Open Data Communities username and API key
as an environment variable (`ODC_API_KEY`) for use in all subsequent API
calls. The credentials are combined and encoded in Base64 as required
for the API's HTTP Basic Authentication.

## Usage

``` r
odc_set_key(odc_user = NULL, odc_key = NULL, overwrite = FALSE)
```

## Arguments

- odc_user:

  `character` Your Open Data Communities username (usually your email
  address). If `NULL`, the function will abort.

- odc_key:

  `character` Your Open Data Communities API key. If `NULL`, the
  function will abort.

- overwrite:

  `logical` If `TRUE`, will overwrite an existing `ODC_API_KEY`
  environment variable. Defaults to `FALSE`, preventing accidental
  overwrites.

## Value

Returns `NULL`. Called primarily for its side effect of setting the
environment variable.

## Details

This function only needs to be run once per R session, or whenever your
credentials change. The key is stored in the `ODC_API_KEY` environment
variable for the current session.

For security, it is recommended *not* to hard-code credentials in your
scripts. Consider using this function interactively or sourcing it from
a secure location.

## Examples

``` r
if (FALSE) { # \dontrun{
# Set your credentials for the first time
odc_set_key(
  odc_user = "email@example.com",
  odc_key = "your_api_key_here"
)

# Overwrite existing credentials (if needed)
odc_set_key(
  odc_user = "email@example.com",
  odc_key = "new_api_key",
  overwrite = TRUE
)
} # }
```
