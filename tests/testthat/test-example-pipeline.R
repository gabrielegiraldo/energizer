pipeline_environment <- new.env(parent = globalenv())
pipeline_path <- system.file("examples", "epb_pipeline.R", package = "energizer")
if (nzchar(pipeline_path)) {
  sys.source(pipeline_path, envir = pipeline_environment)
}

test_that("example pipeline produces curated and audit outputs", {
  skip_if(!nzchar(pipeline_path), "Pipeline example is not shipped")
  output_path <- withr::local_tempdir()
  config <- list(
    date_start = "2026-07-01",
    date_end = "2026-07-07",
    council = "Manchester",
    max_records = 100L,
    output_path = output_path
  )

  certificate <- function(number, date, type_address) {
    tibble::tibble(
      certificate_number = number,
      registration_date = date,
      address_line1 = type_address,
      post_town = "Manchester",
      postcode = "M1 1AA"
    )
  }
  clients <- list(
    search = list(
      domestic = function(...) certificate("1111", "2026-07-01", "1 Test Street"),
      non_domestic = function(...) certificate("2222", "2026-07-02", "2 Test Street"),
      display = function(...) certificate("3333", "2026-07-03", "3 Test Street")
    ),
    deltas = function(...) tibble::tibble(
      certificate_number = "3333",
      event_type = "removed",
      timestamp = "2026-07-04T10:00:00Z"
    ),
    codes = function() tibble::tibble(code = "built_form"),
    download_info = function(type, format) tibble::tibble(
      file_size = 1000,
      last_updated = "2026-07-01T00:00:00Z"
    )
  )

  result <- pipeline_environment$run_epb_pipeline(config, clients)

  expect_equal(nrow(result$certificates), 2L)
  expect_false("3333" %in% result$certificates$certificate_number)
  expect_true(all(result$quality$passed))
  expect_true(file.exists(file.path(output_path, "manifest.csv")))
  expect_true(file.exists(file.path(output_path, "curated", "certificates.csv")))
  expect_true(file.exists(file.path(output_path, "audit", "certificate-deltas.csv")))
  expect_true(file.exists(file.path(output_path, "reference", "full-load-info.csv")))
})

test_that("example pipeline deduplicates latest certificate record", {
  skip_if(!nzchar(pipeline_path), "Pipeline example is not shipped")
  certificates <- tibble::tibble(
    certificate_number = c("1111", "1111"),
    certificate_type = c("domestic", "domestic"),
    registration_date = c("2026-07-01", "2026-07-02"),
    address_line1 = c("Old address", "New address")
  )

  result <- pipeline_environment$epb_curate_certificates(
    certificates,
    tibble::tibble()
  )

  expect_equal(nrow(result), 1L)
  expect_equal(result$address_line1, "New address")
})
