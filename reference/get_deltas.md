# Fetch changed energy certificates

Retrieves certificates recorded as removed or having an updated UPRN
during a date range.

## Usage

``` r
get_deltas(date_start, date_end = date_start)
```

## Arguments

- date_start:

  Start date in `YYYY-MM-DD` format.

- date_end:

  End date in `YYYY-MM-DD` format. Defaults to `date_start`.

## Value

A tibble containing certificate number, event type, and timestamp.

## Examples

``` r
if (FALSE) { # \dontrun{
get_deltas("2025-01-01", "2025-01-31")
} # }
```
