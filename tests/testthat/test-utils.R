test_that("odc_to_tibble converts API response correctly", {
  # Test 1: Normal API response structure
  mock_response <- list(
    rows = list(
      list(lmkKey = "123", address = "1 Test St", currentEnergyRating = "C"),
      list(lmkKey = "456", address = "2 Test St", currentEnergyRating = "B")
    )
  )

  result <- odc_to_tibble(mock_response)

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("lmk_key", "address", "current_energy_rating"))
  expect_equal(nrow(result), 2)
  expect_equal(result$lmk_key, c("123", "456"))
  expect_equal(result$current_energy_rating, c("C", "B"))

  # Test 2: Empty response
  empty_response <- list(rows = list())
  empty_result <- odc_to_tibble(empty_response)
  expect_s3_class(empty_result, "tbl_df")
  expect_equal(nrow(empty_result), 0)
})

test_that("try_catch_response handles request outcomes", {
  # Test 1: Successful request
  mock_req <- structure(list(), class = "httr2_request")

  # Mock successful response
  mock_success <- mockery::mock(
    structure(list(body = charToRaw("{}")), class = "httr2_response")
  )
  mockery::stub(try_catch_response, "httr2::req_perform", mock_success)

  # Suppress CLI output for cleaner tests
  withr::local_options(list(cli.progress_show_after = Inf))

  result <- try_catch_response(mock_req)
  expect_s3_class(result, "httr2_response")
  mockery::expect_called(mock_success, 1)

  # Test 2: Failed request - should abort with custom message
  mock_failure <- mockery::mock(stop("HTTP 404 Not Found"))
  mockery::stub(try_catch_response, "httr2::req_perform", mock_failure)

  expect_error(try_catch_response(mock_req))
})
