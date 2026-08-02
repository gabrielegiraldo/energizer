# Search display energy certificates

Search display energy certificates

## Usage

``` r
epb_search_display(
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

A tibble with pagination metadata in `attr(result, "pagination")`.
