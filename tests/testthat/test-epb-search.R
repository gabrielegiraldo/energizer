search_response <- function(data, current_page, next_page = NULL) {
  httr2::response_json(body = list(
    data = data,
    pagination = list(
      totalRecords = 3L,
      currentPage = current_page,
      totalPages = 2L,
      nextPage = next_page,
      prevPage = if (current_page > 1L) current_page - 1L else NULL,
      pageSize = 2L
    )
  ))
}

test_that("search wrappers use correct endpoints", {
  captured_urls <- character()
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      captured_urls <<- c(captured_urls, request$url)
      search_response(list(list(certificateNumber = "1111")), 1L)
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  epb_search_domestic(postcode = "LS1 4AP")
  epb_search_non_domestic(postcode = "LS1 4AP")
  epb_search_display(postcode = "LS1 4AP")

  expect_match(captured_urls[[1]], "/api/domestic/search")
  expect_match(captured_urls[[2]], "/api/non-domestic/search")
  expect_match(captured_urls[[3]], "/api/display/search")
})

test_that("search expands array filters and paginates", {
  state <- new.env(parent = emptyenv())
  state$page <- 0L
  state$urls <- character()
  responses <- list(
    search_response(
      list(
        list(certificateNumber = "1111", currentEnergyEfficiencyBand = "D"),
        list(certificateNumber = "2222", currentEnergyEfficiencyBand = "C")
      ),
      1L,
      2L
    ),
    search_response(
      list(list(certificateNumber = "3333", currentEnergyEfficiencyBand = "B")),
      2L
    )
  )

  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      state$page <- state$page + 1L
      state$urls <- c(state$urls, request$url)
      responses[[state$page]]
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  result <- epb_search_domestic(
    council = c("Manchester", "Salford"),
    efficiency_rating = c("F", "G"),
    paginate = "all",
    page_size = 2L
  )

  expect_equal(nrow(result), 3L)
  expect_equal(attr(result, "pagination")$retrievedPages, 2L)
  expect_match(state$urls[[1]], "council%5B%5D=Manchester")
  expect_match(state$urls[[1]], "council%5B%5D=Salford")
  expect_match(state$urls[[2]], "current_page=2")
})

test_that("max_records enables pagination and trims result", {
  state <- new.env(parent = emptyenv())
  state$page <- 0L
  responses <- list(
    search_response(list(
      list(certificateNumber = "1111"),
      list(certificateNumber = "2222")
    ), 1L, 2L),
    search_response(list(
      list(certificateNumber = "3333"),
      list(certificateNumber = "4444")
    ), 2L)
  )
  local_mocked_bindings(
    epb_perform = function(request, path = NULL) {
      state$page <- state$page + 1L
      responses[[state$page]]
    },
    .package = "energizer"
  )
  withr::local_envvar(c(EPB_BEARER_TOKEN = "secret"))

  expect_message(
    result <- epb_search_domestic(postcode = "LS1", max_records = 3L, page_size = 2L),
    "max_records"
  )
  expect_equal(nrow(result), 3L)
})

test_that("search validates filters and pagination", {
  expect_error(epb_search_domestic(), "named search filter")
  expect_error(epb_search_domestic(postcode = "LS1", page_size = 0), "page_size")
  expect_error(epb_search_domestic(postcode = "LS1", page_size = 5001), "page_size")
})
