test_that("get_certificate normalizes number and returns one-row tibble", {
  captured_request <- NULL
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_request <<- request
      httr2::response_json(body = list(data = list(
        certificateNumber = "1111-2222-3333-4444-5555",
        currentEnergyEfficiencyBand = "D"
      )))
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- get_certificate("11112222333344445555")

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 1L)
  expect_match(captured_request$url, "certificate_number=1111-2222-3333-4444-5555")
})

test_that("get_certificate validates certificate number", {
  expect_error(get_certificate("123"), "exactly 20 digits")
})

test_that("get_deltas validates dates and parses changes", {
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      httr2::response_json(body = list(data = list(list(
        certificateNumber = "1111-2222-3333-4444-5555",
        eventType = "removed",
        timestamp = "2025-01-01T10:00:00Z"
      ))))
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- get_deltas("2025-01-01")
  expect_equal(result$event_type, "removed")
  expect_error(get_deltas("2025-02-01", "2025-01-01"), "earlier")
  expect_error(get_deltas("01-01-2025"), "YYYY-MM-DD")
})

test_that("get_codes returns code column", {
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      httr2::response_json(body = list(data = list(
        "built_form", "construction_age_band"
      )))
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- get_codes()
  expect_equal(result$code, c("built_form", "construction_age_band"))
})

test_that("get_code_info sends API parameter names", {
  captured_request <- NULL
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_request <<- request
      httr2::response_json(body = list(data = list(list(
        key = "NR",
        values = list(list(value = "Detached"))
      ))))
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- get_code_info(
    "built_form",
    key = "NR",
    schema_version = "RdSAP-Schema-17.0"
  )

  expect_s3_class(result, "tbl_df")
  expect_match(captured_request$url, "code=built_form")
  expect_match(captured_request$url, "key=NR")
  expect_match(captured_request$url, "schemaVersion=RdSAP-Schema-17.0")
})
