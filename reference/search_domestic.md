# Search domestic energy certificates

Searches domestic EPCs using geographic or registration-date filters.

## Usage

``` r
search_domestic(
  ...,
  paginate = c("none", "all", "manual"),
  page_size = 5000L,
  current_page = 1L,
  max_pages = NULL,
  max_records = NULL
)
```

## Arguments

- ...:

  Search filters such as `postcode`, `uprn`, `address`, `council`,
  `constituency`, `efficiency_rating`, `date_start`, and `date_end`.

- paginate:

  Pagination mode: `"none"`, `"all"`, or `"manual"`.

- page_size:

  Maximum records per API page, from 1 to 5000.

- current_page:

  First page to request.

- max_pages:

  Maximum pages to request when paginating, or `NULL`.

- max_records:

  Maximum records to return, or `NULL`. Supplying this switches
  pagination to `"all"`.

## Value

A tibble. Pagination metadata is available through
`attr(result, "pagination")`.

## Examples

``` r
if (FALSE) { # \dontrun{
search_domestic(postcode = "LS1 4AP")
search_domestic(
  council = c("Manchester", "Salford"),
  paginate = "all",
  max_records = 10000
)
} # }
```
