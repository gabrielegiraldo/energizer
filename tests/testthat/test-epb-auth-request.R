test_that("epb_set_token stores normalized bearer token", {
  withr::local_envvar(c(EPB_BEARER_TOKEN = ""))

  expect_message(epb_set_token("  Bearer token-value  "), "Bearer token set")
  expect_equal(Sys.getenv("EPB_BEARER_TOKEN"), "token-value")
  expect_error(epb_set_token("replacement"), "already set")
  expect_message(epb_set_token("replacement", overwrite = TRUE))
  expect_equal(Sys.getenv("EPB_BEARER_TOKEN"), "replacement")
})

test_that("epb_set_token validates token", {
  withr::local_envvar(c(EPB_BEARER_TOKEN = ""))

  expect_error(epb_set_token(""), "non-empty")
  expect_error(epb_set_token(NULL), "non-empty")
  expect_error(epb_set_token("Bearer "), "bearer token value")
})

test_that("epb_get_token errors when token is missing", {
  withr::local_envvar(c(EPB_BEARER_TOKEN = ""))
  expect_error(epb_get_token(), "No Energy Performance API bearer token")
})

test_that("epb_request builds bearer-authenticated GET request", {
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))
  withr::local_options(list(energizer.base_url = "https://example.test/"))

  request <- epb_request(
    "/api/domestic/search",
    query = list("council[]" = c("Manchester", "Salford"))
  )

  expect_equal(request$method, "GET")
  expect_equal(request$headers$Accept, "application/json")
  expect_true("Authorization" %in% names(request$headers))
  expect_type(request$headers$Authorization, "weakref")
  expect_match(request$url, "https://example.test/api/domestic/search")
  expect_match(request$url, "council%5B%5D=Manchester")
  expect_match(request$url, "council%5B%5D=Salford")
})

test_that("EPB_BASE_URL overrides default base URL", {
  withr::local_envvar(c(
    EPB_BEARER_TOKEN = "secret",
    EPB_BASE_URL = "https://override.test/"
  ))

  request <- epb_request("api/codes")
  expect_equal(request$url, "https://override.test/api/codes")
})

test_that("epb response parser handles records and pagination", {
  response <- httr2::response_json(body = list(
    data = list(
      list(certificateNumber = "1111", currentEnergyEfficiencyBand = "D"),
      list(certificateNumber = "2222", currentEnergyEfficiencyBand = "C")
    ),
    pagination = list(nextPage = 2L, pageSize = 2L)
  ))

  parsed <- epb_parse_response(response)
  expect_s3_class(parsed$data, "tbl_df")
  expect_named(parsed$data, c("certificate_number", "current_energy_efficiency_band"))
  expect_equal(parsed$pagination$nextPage, 2L)
})

test_that("epb response parser handles null record fields without warnings", {
  response <- httr2::response_json(body = list(
    data = list(
      list(certificateNumber = "1111", addressLine3 = NULL),
      list(certificateNumber = "2222", addressLine3 = "Rear building")
    )
  ))

  expect_no_warning(parsed <- epb_parse_response(response))
  expect_equal(parsed$data$address_line3, c(NA, "Rear building"))
})

test_that("epb_perform reports nested API HTTP errors once", {
  httr2::local_mocked_responses(function(req) {
    httr2::response_json(
      status_code = 400L,
      body = list(data = list(
        error = "The search query was invalid - please provide a valid postcode"
      ))
    )
  })

  request <- httr2::request("https://example.test/api/domestic/search")

  error <- expect_error(
    quietly(epb_perform(request)),
    "400 Bad Request.*please provide a valid postcode"
  )
  expect_s3_class(error$parent, "httr2_http_400")
  expect_equal(
    lengths(regmatches(
      conditionMessage(error),
      gregexpr("Energy Performance API request failed", conditionMessage(error), fixed = TRUE)
    )),
    1L
  )
})

test_that("epb_perform reports rate limiting guidance", {
  httr2::local_mocked_responses(function(req) {
    httr2::response_json(status_code = 429L)
  })

  request <- httr2::request("https://example.test/api/domestic/search")

  expect_error(
    quietly(epb_perform(request)),
    "429 Too Many Requests.*Stop requests briefly"
  )
})
