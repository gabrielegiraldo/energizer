# Set Energy Performance API bearer token

Stores a bearer token for the current R session in the
`EPB_BEARER_TOKEN` environment variable. Tokens are available from the
service's **My account** page.

## Usage

``` r
epb_set_token(token, overwrite = FALSE)
```

## Arguments

- token:

  A non-empty bearer token. A leading `Bearer ` prefix is removed.

- overwrite:

  Whether to replace an existing token. Defaults to `FALSE`.

## Value

`NULL`, invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
epb_set_token("your-bearer-token")
} # }
```
