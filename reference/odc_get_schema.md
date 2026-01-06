# Download and extract EPC schema data

Fetches schema information for Energy Performance Certificate (EPC) data
from the Open Data Communities API. Downloads the specified dataset
type, extracts the schema.json file, and processes it into a tidy
tabular format.

## Usage

``` r
odc_get_schema(
  type = c("domestic", "non_domestic", "display"),
  resource = c("certificate", "recommendation")
)
```

## Arguments

- type:

  `character` string specifying the type of EPC data. Must be one of:

  - "domestic": Domestic EPC data

  - "non_domestic": Non-domestic EPC data

  - "display": Display Energy Certificate data

- resource:

  `character` string specifying the resource type to extract from the
  schema. Must be either "certificate" or "recommendation".

## Value

A tibble containing the processed schema information for the requested
resource type.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get schema for domestic certificates
schema_domestic_cert <- odc_get_schema("domestic", "certificate")

# Get schema for non-domestic recommendations
schema_nondomestic_rec <- odc_get_schema("non_domestic", "recommendation")

# View the resulting schema structure
print(schema_domestic_cert)
colnames(schema_domestic_cert)
} # }
```
