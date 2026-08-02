# Fetch EPC code values

Fetch EPC code values

## Usage

``` r
epb_get_code_info(code, key = NULL, schema_version = NULL)
```

## Arguments

- code:

  Code table name returned by
  [`epb_get_codes()`](https://gabrielegiraldo.github.io/enrgz/reference/epb_get_codes.md).

- key:

  Optional code key.

- schema_version:

  Optional EPC schema version. Sent as `schemaVersion`.

## Value

A tibble. Nested code values remain list-columns.

## Examples

``` r
if (FALSE) { # \dontrun{
epb_get_code_info("built_form")
epb_get_code_info("built_form", key = "NR", schema_version = "RdSAP-Schema-17.0")
} # }
```
