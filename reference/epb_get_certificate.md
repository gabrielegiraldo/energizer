# Fetch an energy certificate

Retrieves full EPC or DEC data using its 20-digit certificate number.

## Usage

``` r
epb_get_certificate(certificate_number)
```

## Arguments

- certificate_number:

  Certificate number, with or without hyphens.

## Value

A one-row tibble. Fields vary by certificate schema.

## Examples

``` r
if (FALSE) { # \dontrun{
epb_get_certificate("1111-2222-3333-4444-5555")
} # }
```
