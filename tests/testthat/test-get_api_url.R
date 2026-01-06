# test_that("get_api_url behaves as expected", {
#   expect_error(get_api_url("domestic", "random"))
#   expect_error(get_api_url("non-domestic", "certificate"))
#
#   domestic_search_url <- "https://epc.opendatacommunities.org/api/v1/domestic/search"
#   expect_identical(get_api_url("domestic", "search"), domestic_search_url)
#
#   non_domestic_recommendation_url <-  "https://epc.opendatacommunities.org/api/v1/non-domestic/recommendations"
#   expect_identical(
#     get_api_url("non_domestic", "recommendation"),
#     non_domestic_recommendation_url
#   )
#
#   expect_error(
#     get_api_url("invalid_type", "search"),
#     class = "rlang_error"
#   )
# })

test_that("get_api_url validates inputs and constructs correct URLs", {
  # Test 1: Basic URL construction for all valid combinations
  expect_equal(
    get_api_url("domestic", "search"),
    "https://epc.opendatacommunities.org/api/v1/domestic/search"
  )
  expect_equal(
    get_api_url("domestic", "certificate"),
    "https://epc.opendatacommunities.org/api/v1/domestic/certificate"
  )
  expect_equal(
    get_api_url("domestic", "recommendation"),
    "https://epc.opendatacommunities.org/api/v1/domestic/recommendations"
  )

  # Test 2: Transformation of 'non_domestic' to 'non-domestic' in URL
  expect_equal(
    get_api_url("non_domestic", "search"),
    "https://epc.opendatacommunities.org/api/v1/non-domestic/search"
  )
  expect_equal(
    get_api_url("non_domestic", "certificate"),
    "https://epc.opendatacommunities.org/api/v1/non-domestic/certificate"
  )
  expect_equal(
    get_api_url("non_domestic", "recommendation"),
    "https://epc.opendatacommunities.org/api/v1/non-domestic/recommendations"
  )

  # Test 3: Display certificates
  expect_equal(
    get_api_url("display", "search"),
    "https://epc.opendatacommunities.org/api/v1/display/search"
  )
  expect_equal(
    get_api_url("display", "certificate"),
    "https://epc.opendatacommunities.org/api/v1/display/certificate"
  )
  expect_equal(
    get_api_url("display", "recommendation"),
    "https://epc.opendatacommunities.org/api/v1/display/recommendations"
  )
})

test_that("get_api_url correctly pluralizes 'recommendation' endpoint", {
  # Test the pluralization transformation specifically
  urls <- c(
    get_api_url("domestic", "recommendation"),
    get_api_url("non_domestic", "recommendation"),
    get_api_url("display", "recommendation")
  )

  # All should contain 'recommendations' (plural) not 'recommendation'
  expect_true(all(grepl("/recommendations$", urls)))
  expect_false(any(grepl("/recommendation$", urls)))
})

test_that("get_api_url handles input validation correctly", {
  # Test 1: Invalid type parameter (using rlang::arg_match error)
  expect_error(
    get_api_url("invalid_type", "search"),
    class = "rlang_error"
  )

  # Test 2: Invalid endpoint parameter
  expect_error(
    get_api_url("domestic", "invalid_endpoint"),
    class = "rlang_error"
  )

  # Test 3: Missing arguments use defaults and still work
  expect_equal(
    get_api_url(), # Uses defaults: type="domestic", endpoint="certificate"
    "https://epc.opendatacommunities.org/api/v1/domestic/certificate"
  )
})

test_that("get_api_url returns correct output type", {
  # Test 1: Returns character vector
  result <- get_api_url("domestic", "search")
  expect_type(result, "character")
  expect_length(result, 1)
})
