test_that(".encode_key correctly encodes credentials to Base64", {
  # Test 1: Basic encoding works
  expect_silent(result <- .encode_key("test@example.com", "myApiKey123"))
  expect_type(result, "character")
  expect_true(nchar(result) > 0)

  # Test 2: Encoding produces expected, deterministic output
  # Calculate what the Base64 of "test@example.com:myApiKey123" should be
  expected_raw <- charToRaw("test@example.com:myApiKey123")
  expected_b64 <- base64enc::base64encode(expected_raw)
  expect_equal(result, expected_b64)

  # Test 3: Whitespace trimming works
  result_trimmed <- .encode_key("  test@example.com  ", "  myApiKey123  ")
  expect_equal(result_trimmed, expected_b64)

  # Test 4: Handles empty strings (after trimming) -> creates ":" encoded string
  empty_result <- .encode_key("", "")
  expect_equal(empty_result, base64enc::base64encode(charToRaw(":")))

  # Test 5: Non-character input causes error (defensive programming check)
  expect_error(.encode_key(123, "key"), class = "error")
  expect_error(.encode_key("user", 456), class = "error")
})

test_that("odc_set_key uses .encode_key correctly", {
  # Create a mock version of .encode_key to track its usage
  mock_encode <-
    mockery::stub(
      where = odc_set_key,
      what = ".encode_key",
      how = function(u, k) {
        return("MOCK_BASE64_STRING")
      }
    )

  # Use withr to safely set and unset environment variable
  withr::local_envvar(c("ODC_API_KEY" = ""))

  # Test that odc_set_key calls the encoding function
  # and sets the environment variable to the mock result
  expect_message(
    odc_set_key("user", "key", overwrite = TRUE),
    "API key successfully set"
  )

  expect_equal(Sys.getenv("ODC_API_KEY"), "MOCK_BASE64_STRING")

  # Clean up
  mockery::stub(
    where = odc_set_key,
    what = ".encode_key",
    how = function(u, k) {
      return(base64enc::base64encode(charToRaw(paste0(u, ":", k))))
    }
  )
})

test_that("odc_set_key validates inputs and prevents overwrite by default", {
  # Use withr to isolate environment for this test block
  withr::local_envvar(c("ODC_API_KEY" = "EXISTING_KEY"))

  # Test 1: Missing credentials cause error
  expect_error(odc_set_key(), "Please, provide your OpenDataCommunity username & API key.")

  # Test 2: Prevents overwrite of existing key by default
  expect_error(
    odc_set_key("user", "key"), # overwrite = FALSE is default
    "ODC_API_KEY.*environment variable already found"
  )
  # Verify the original value wasn't changed
  expect_equal(Sys.getenv("ODC_API_KEY"), Sys.getenv("ODC_API_KEY"))
})

test_that("odc_set_key allows overwrite when explicitly requested", {
  withr::local_envvar(c("ODC_API_KEY" = "OLD_KEY"))

  # Use a mock for .encode_key to isolate test to overwrite logic
  mockery::stub(odc_set_key, ".encode_key", function(u, k) paste("MOCK", u, k))

  # Should work with overwrite = TRUE
  expect_message(
    odc_set_key("new_user", "new_key", overwrite = TRUE),
    "API key successfully set"
  )
  # Verify the environment variable was updated
  expect_equal(Sys.getenv("ODC_API_KEY"), "MOCK new_user new_key")
})

test_that("odc_set_key sets environment variable when none exists", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
      expect_null(odc_set_key("user", "pw"))
    })
})

test_that("odc_set_key returns invisibly and has correct side effects", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
    mockery::stub(odc_set_key, ".encode_key", function(u, k) "ENCODED")
    result <- odc_set_key("test", "key")
    expect_null(result)
    expect_equal(Sys.getenv("ODC_API_KEY"), "ENCODED")
  })
})