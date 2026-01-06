test_that("odc_get_data validates parameters correctly", {
  # Test 1: Missing lmk_key causes error
  expect_error(
    odc_get_data(lmk_key = NULL, type = "domestic", endpoint = "certificate"),
    "lmk_key.*is set to `NULL`"
  )

  # Test 2: Invalid type parameter
  expect_error(
    odc_get_data("123", type = "invalid", endpoint = "certificate"),
    class = "rlang_error"
  )

  # Test 3: Invalid endpoint parameter
  expect_error(
    odc_get_data("123", type = "domestic", endpoint = "invalid"),
    class = "rlang_error"
  )
})

test_that("odc_get_data constructs correct API request", {
  # Setup mocks for all dependencies
  mockery::stub(odc_get_data, "get_api_url", function(type, endpoint) {
    return(paste0("https://test.api/", type, "/", endpoint))
  })

  mockery::stub(odc_get_data, "odc_get_key", function() "fake_encoded_key")

  # Track the request that would be made
  captured_req <- NULL
  mock_perform <- mockery::mock(
    structure(list(), class = "httr2_response"),
    cycle = TRUE
  )
  mockery::stub(odc_get_data, "try_catch_response", function(req, ...) {
    captured_req <<- req
    return(structure(
      list(body = charToRaw('{"rows": []}')),
      class = "httr2_response"
    ))
  })

  mockery::stub(odc_get_data, "httr2::resp_body_json", function(resp) {
    return(list(rows = list()))
  })

  # Execute function
  result <- odc_get_data(
    lmk_key = "12345678901234567890123456789012",
    type = "domestic",
    endpoint = "certificate"
  )

  # Verify request construction
  expect_s3_class(captured_req, "httr2_request")
  expect_equal(
    captured_req$url,
    "https://test.api/domestic/certificate/12345678901234567890123456789012"
  )
  expect_equal(captured_req$method, "GET")
  expect_equal(captured_req$headers$accept, "application/json")
})

test_that("odc_get_data processes successful response correctly", {
  # Mock the entire chain for a successful request
  mockery::stub(odc_get_data, "get_api_url", function(...) "https://test.api")
  mockery::stub(odc_get_data, "odc_get_key", function() "fake_key")

  # Mock a realistic JSON response
  mock_json <- list(
    rows = list(
      list(
        lmkKey = "12345678901234567890123456789012",
        address1 = "1 Test Street",
        currentEnergyRating = "C",
        totalFloorArea = 85.5
      )
    )
  )

  mock_response <- structure(
    list(body = charToRaw('{"rows": []}')),
    class = "httr2_response"
  )

  mockery::stub(odc_get_data, "try_catch_response", function(...) {
    mock_response
  })
  mockery::stub(odc_get_data, "httr2::resp_body_json", function(...) mock_json)

  # Mock the tibble conversion to return expected format
  mockery::stub(odc_get_data, "odc_to_tibble", function(x) {
    tibble::tibble(
      lmk_key = "12345678901234567890123456789012",
      address1 = "1 Test Street",
      current_energy_rating = "C",
      total_floor_area = 85.5
    )
  })

  result <- odc_get_data("123", "domestic", "certificate")

  expect_s3_class(result, "tbl_df")
  expect_named(
    result,
    c("lmk_key", "address1", "current_energy_rating", "total_floor_area")
  )
  expect_equal(result$lmk_key, "12345678901234567890123456789012")
  expect_equal(result$current_energy_rating, "C")
})

test_that("odc_get_data handles API errors gracefully", {
  mockery::stub(odc_get_data, "get_api_url", function(...) "https://test.api")
  mockery::stub(odc_get_data, "odc_get_key", function() "fake_key")

  # Simulate API error in try_catch_response
  mockery::stub(odc_get_data, "try_catch_response", function(...) {
    cli::cli_abort("API request failed")
  })

  expect_error(
    odc_get_data("123", "domestic", "certificate"),
    "API request failed"
  )
})

test_that("odc_get_data works with different certificate types and endpoints", {
  mockery::stub(odc_get_data, "odc_get_key", function() "fake_key")

  # Test all type/endpoint combinations
  test_combinations <- expand.grid(
    type = c("domestic", "non_domestic", "display"),
    endpoint = c("certificate", "recommendation"),
    stringsAsFactors = FALSE
  )

  for (i in seq_len(nrow(test_combinations))) {
    combo <- test_combinations[i, ]

    # Mock get_api_url to verify it's called correctly
    mock_url_called <- FALSE
    mockery::stub(odc_get_data, "get_api_url", function(type, endpoint) {
      expect_equal(type, combo$type)
      expect_equal(endpoint, combo$endpoint)
      mock_url_called <<- TRUE
      return("https://test.api")
    })

    # Mock the rest of the chain for successful execution
    mockery::stub(odc_get_data, "try_catch_response", function(...) {
      structure(
        list(body = charToRaw('{"rows": []}')),
        class = "httr2_response"
      )
    })
    mockery::stub(odc_get_data, "httr2::resp_body_json", function(...) {
      list(rows = list())
    })
    mockery::stub(odc_get_data, "odc_to_tibble", function(...) {
      tibble::tibble()
    })

    result <- odc_get_data("test_key", combo$type, combo$endpoint)
    expect_s3_class(result, "tbl_df")
    expect_true(
      mock_url_called,
      info = paste("Failed for type:", combo$type, "endpoint:", combo$endpoint)
    )
  }
})
