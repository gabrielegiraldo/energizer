test_that("validate_size converts underscores to hyphens in parameter names", {
  result <- validate_size(list(
    local_authority = "E09000030",
    from_date = "2020-01"
  ))
  expect_named(result, c("local-authority", "from-date", "size"))
})

test_that("validate_size enforces size between 1 and 5000", {
  expect_error(validate_size(list(size = 0)), "must be between 1 and 5000")
  expect_silent(validate_size(list(size = 5000)))
  expect_equal(validate_size(list(size = 5000))$size, 5000)
})

test_that("validate_size warns and caps size exceeding 5000", {
  expect_message(validate_size(list(size = 10000)), "applied 5000 as fallback")
  expect_equal(validate_size(list(size = 10000))$size, 5000)
})

test_that("validate_size sets default size of 25 when missing", {
  result <- validate_size(list(address = "London"))
  expect_equal(result$size, 25)
})

test_that("validate_dots throws an error when no arguments are provided", {
  expect_error(validate_dots())
})

test_that("calculate_page_size returns expected output", {
  expect_equal(calculate_page_size(250, 1000, 500), 250)
  expect_equal(calculate_page_size(250, 1000, 800), 200)
  expect_equal(calculate_page_size(250, 1000, 1000), 0)
  expect_equal(calculate_page_size(250, NULL, 500), 250)
})

test_that("odc_search_data completes a basic search and returns a tibble", {
  # Mock the entire internal pipeline to return a simple, valid result
  mockery::stub(odc_search_data, "validate_dots", function(...) list(size = 25))
  mockery::stub(odc_search_data, "get_api_url", function(...) "mocked_url")
  mockery::stub(odc_search_data, "execute_paginated_search", function(...) {
    list(all_results = list(), page_count = 0, total_records = 0)
  })
  mockery::stub(odc_search_data, "finalize_search_results", function(...) {
    tibble::tibble()
  })

  # Execute a simple search
  result <- odc_search_data("domestic", postcode = "SW1A")

  # Core contract: It must return a tibble without error
  expect_s3_class(result, "tbl_df")
})

test_that("odc_search_data forces paginate='all' when max_records is set", {
  # Capture the paginate argument passed to the core executor
  captured_paginate <- NULL
  mockery::stub(odc_search_data, "validate_dots", function(...) list(size = 25))
  mockery::stub(odc_search_data, "get_api_url", function(...) "mocked_url")
  mockery::stub(
    odc_search_data,
    "execute_paginated_search",
    function(paginate, ...) {
      captured_paginate <<- paginate # Capture the value
      list(all_results = list(), page_count = 0, total_records = 0)
    }
  )
  mockery::stub(odc_search_data, "finalize_search_results", function(...) {
    tibble::tibble()
  })

  # Call with max_records
  result <- odc_search_data("domestic", max_records = 100, postcode = "SW1A")

  # The key advertised behavior: max_records should trigger paginate = "all"
  expect_equal(captured_paginate, "all")
})

test_that("request is built correctly without search_after", {
  # Mock the external functions
  mock_odc_get_key <- function() "mocked_key"
  mock_try_catch_response <- function(req) {
    list(test = "mocked_response", req = req)
  }

  # Execute with mocked bindings
  result <- with_mocked_bindings(
    build_and_execute_request(
      api_url = "https://api.test.com",
      search_after = NULL,
      page_count = 100,
      query_params = list(param = "value")
    ),
    odc_get_key = mock_odc_get_key,
    try_catch_response = mock_try_catch_response
  )

  expect_equal(result$req$url, "https://api.test.com/?param=value")
  expect_equal(result$test, "mocked_response")
  expect_equal(result$req$method, "GET")
})

test_that("search_after is added to query params when provided", {
  mock_odc_get_key <- function() "key"
  mock_try_catch_response <- function(req) list(req = req)

  result <- with_mocked_bindings(
    build_and_execute_request(
      api_url = "https://api.test.com",
      search_after = "cursor123",
      page_count = 50,
      query_params = list(q = "test")
    ),
    odc_get_key = mock_odc_get_key,
    try_catch_response = mock_try_catch_response
  )

  expect_equal(
    result$req$url,
    "https://api.test.com/?q=test&search-after=cursor123"
  )
})
