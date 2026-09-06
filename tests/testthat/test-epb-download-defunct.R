test_that("download saves ZIP and uses documented endpoint", {
  captured_request <- NULL
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_request <<- request
      writeBin(charToRaw("mock zip"), path)
      httr2::response()
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))
  destination <- withr::local_tempdir()

  expect_message(
    path <- download_domestic("csv", destination),
    "Saved full-load dataset"
  )

  expect_equal(basename(path), "domestic-csv.zip")
  expect_true(file.exists(path))
  expect_match(captured_request$url, "/api/files/domestic/csv")
})

test_that("recommendation downloads use singular path", {
  captured_request <- NULL
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_request <<- request
      writeBin(charToRaw("mock zip"), path)
      httr2::response()
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))
  destination <- withr::local_tempdir()

  download_non_domestic_recommendations_json(destination)
  expect_match(captured_request$url, "/api/files/non-domestic-recommendation/json")
})

test_that("download info uses documented plural recommendation path", {
  captured_request <- NULL
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_request <<- request
      httr2::response_json(body = list(data = list(
        fileSize = 123L,
        lastUpdated = "2025-08-01T00:31:19.000+00:00"
      )))
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- download_info("display_recommendation", "json")
  expect_equal(result$file_size, 123L)
  expect_match(captured_request$url, "/api/files/display-recommendations/json/info")
})

test_that("recommendation downloads reject CSV", {
  expect_error(
    download_full_load("display_recommendation", "csv", tempdir()),
    "JSON only"
  )
})

test_that("legacy ODC functions are defunct", {
  expect_error(odc_set_key(), class = "defunctError")
  expect_error(odc_get_data(), class = "defunctError")
  expect_error(odc_search_data(), class = "defunctError")
  expect_error(odc_bulk_download(), class = "defunctError")
})
