# Retrieve API metadata and information

`odc_get_meta()` fetches metadata and server information from the Open
Data Communities API. This endpoint provides information about the API
service, including version details, available endpoints, and other
server metadata.

Unlike other functions in this package, this endpoint does not require
authentication.

## Usage

``` r
odc_get_meta()
```

## Value

A list containing the parsed JSON response from the API info endpoint.
Common fields in the response include:

- `latestDate`:

  Date of the most recent available certificate in the database. Format:
  `YYYY-MM-DD`.

- `updatedDate`:

  Date when the site or database was last updated. Format: `YYYY-MM-DD`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get API metadata
meta <- odc_get_meta()

# Check the most recent certificate date
print(meta$latestDate)

# Check when the data was last updated
print(meta$updatedDate)
} # }
```
