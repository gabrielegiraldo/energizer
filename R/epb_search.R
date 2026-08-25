#' Search domestic energy certificates
#'
#' Searches domestic EPCs using geographic or registration-date filters.
#'
#' @inheritParams search_common
#' @param ... Search filters such as `postcode`, `uprn`, `address`, `council`,
#'   `constituency`, `efficiency_rating`, `date_start`, and `date_end`.
#'
#' @return A tibble. Pagination metadata is available through
#'   `attr(result, "pagination")`.
#' @export
#'
#' @examples
#' \dontrun{
#' search_domestic(postcode = "LS1 4AP")
#' search_domestic(
#'   council = c("Manchester", "Salford"),
#'   paginate = "all",
#'   max_records = 10000
#' )
#' }
search_domestic <- function(
  ...,
  paginate = c("none", "all", "manual"),
  page_size = 5000L,
  current_page = 1L,
  max_pages = NULL,
  max_records = NULL
) {
  epb_search(
    type = "domestic",
    ...,
    paginate = paginate,
    page_size = page_size,
    current_page = current_page,
    max_pages = max_pages,
    max_records = max_records
  )
}

#' Search non-domestic energy certificates
#'
#' @inheritParams search_domestic
#' @return A tibble with pagination metadata in `attr(result, "pagination")`.
#' @export
#' @rdname search_non_domestic
search_non_domestic <- function(
  ...,
  paginate = c("none", "all", "manual"),
  page_size = 5000L,
  current_page = 1L,
  max_pages = NULL,
  max_records = NULL
) {
  epb_search(
    type = "non-domestic",
    ...,
    paginate = paginate,
    page_size = page_size,
    current_page = current_page,
    max_pages = max_pages,
    max_records = max_records
  )
}

#' Search display energy certificates
#'
#' @inheritParams search_domestic
#' @return A tibble with pagination metadata in `attr(result, "pagination")`.
#' @export
#' @rdname search_display
search_display <- function(
  ...,
  paginate = c("none", "all", "manual"),
  page_size = 5000L,
  current_page = 1L,
  max_pages = NULL,
  max_records = NULL
) {
  epb_search(
    type = "display",
    ...,
    paginate = paginate,
    page_size = page_size,
    current_page = current_page,
    max_pages = max_pages,
    max_records = max_records
  )
}

#' Common search pagination parameters
#'
#' @param paginate Pagination mode: `"none"`, `"all"`, or `"manual"`.
#' @param page_size Maximum records per API page, from 1 to 5000.
#' @param current_page First page to request.
#' @param max_pages Maximum pages to request when paginating, or `NULL`.
#' @param max_records Maximum records to return, or `NULL`. Supplying this
#'   switches pagination to `"all"`.
#'
#' @keywords internal
#' @name search_common
NULL

epb_search <- function(
  type,
  ...,
  paginate,
  page_size,
  current_page,
  max_pages,
  max_records
) {
  paginate <- rlang::arg_match(paginate, c("none", "all", "manual"))
  page_size <- epb_validate_count(page_size, "page_size", maximum = 5000L)
  current_page <- epb_validate_count(current_page, "current_page")
  max_pages <- epb_validate_optional_count(max_pages, "max_pages")
  max_records <- epb_validate_optional_count(max_records, "max_records")

  filters <- rlang::list2(...)
  if (length(filters) == 0L || is.null(names(filters)) || any(!nzchar(names(filters)))) {
    cli::cli_abort("Provide at least one named search filter.")
  }
  filters <- filters[!vapply(filters, is.null, logical(1))]
  if (length(filters) == 0L) {
    cli::cli_abort("Provide at least one non-`NULL` search filter.")
  }
  filters <- epb_normalize_search_filters(filters)

  if (!is.null(max_records) && paginate != "all") {
    paginate <- "all"
    cli::cli_alert_info("Using {.val all} pagination because {.arg max_records} is set.")
  }

  epb_paginate_search(
    path = paste("api", type, "search", sep = "/"),
    filters = filters,
    paginate = paginate,
    page_size = page_size,
    current_page = current_page,
    max_pages = max_pages,
    max_records = max_records
  )
}

epb_paginate_search <- function(
  path,
  filters,
  paginate,
  page_size,
  current_page,
  max_pages,
  max_records
) {
  pages <- list()
  page_count <- 0L
  total_records <- 0L
  pagination <- NULL

  repeat {
    page_count <- page_count + 1L
    request_size <- page_size
    if (!is.null(max_records)) {
      request_size <- min(page_size, max_records - total_records)
    }
    if (request_size <= 0L) {
      break
    }

    query <- c(
      filters,
      list(current_page = current_page, page_size = request_size)
    )
    request <- epb_request(path, query = query) |>
      httr2::req_error(
        is_error = function(response) {
          httr2::resp_is_error(response) && httr2::resp_status(response) != 404L
        }
      )
    response <- epb_perform(request)
    if (httr2::resp_status(response) == 404L) {
      break
    }
    parsed <- epb_parse_response(response)
    pages[[page_count]] <- parsed$data
    pagination <- parsed$pagination
    total_records <- total_records + nrow(parsed$data)

    next_page <- epb_pagination_value(pagination, "nextPage", "next_page")

    if (paginate == "manual") {
      if (!is.null(next_page)) {
        cli::cli_alert_info("More results available on page {next_page}.")
      }
      break
    }
    if (paginate == "none" || is.null(next_page)) {
      break
    }
    if (!is.null(max_pages) && page_count >= max_pages) {
      break
    }
    if (!is.null(max_records) && total_records >= max_records) {
      break
    }
    if (identical(as.character(next_page), as.character(current_page))) {
      cli::cli_abort("API pagination returned same page repeatedly.")
    }

    current_page <- next_page
  }

  result <- epb_bind_pages(pages)
  if (!is.null(max_records) && nrow(result) > max_records) {
    result <- result[seq_len(max_records), , drop = FALSE]
  }

  if (is.null(pagination)) {
    pagination <- list()
  }
  pagination$retrievedPages <- page_count
  pagination$retrievedRecords <- nrow(result)
  attr(result, "pagination") <- pagination
  result
}

epb_normalize_search_filters <- function(filters) {
  array_parameters <- c("council", "constituency", "efficiency_rating")
  names(filters) <- vapply(names(filters), function(name) {
    if (name %in% array_parameters) paste0(name, "[]") else name
  }, character(1))
  filters
}

epb_pagination_value <- function(pagination, camel_name, snake_name) {
  if (is.null(pagination)) {
    return(NULL)
  }
  value <- pagination[[camel_name]] %||% pagination[[snake_name]] %||% NULL
  if (is.null(value) || length(value) == 0L) {
    return(NULL)
  }
  value
}

epb_bind_pages <- function(pages) {
  if (length(pages) == 0L) {
    return(tibble::tibble())
  }

  tibble::as_tibble(data.table::rbindlist(pages, fill = TRUE))
}

epb_validate_count <- function(value, argument, maximum = Inf) {
  valid <- is.numeric(value) && length(value) == 1L && !is.na(value) &&
    is.finite(value) && value >= 1 && value == floor(value) && value <= maximum

  if (!valid) {
    requirement <- if (is.finite(maximum)) {
      paste0("a whole number between 1 and ", maximum)
    } else {
      "a positive whole number"
    }
    cli::cli_abort("{.arg {argument}} must be {requirement}.")
  }

  as.integer(value)
}

epb_validate_optional_count <- function(value, argument) {
  if (is.null(value)) {
    return(NULL)
  }
  epb_validate_count(value, argument)
}
