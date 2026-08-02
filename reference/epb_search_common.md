# Common search pagination parameters

Common search pagination parameters

## Arguments

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
