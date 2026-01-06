#' Validate and set defaults for pagination size parameter
#'
#' Internal for `size` parameter validation within dynamic dots, ensuring `size`
#' is numeric between 1-5000, applies a maximum limit with warning, sets default
#' value of 25 if not provided, and converts underscores to hyphens in all
#' parameter names.
#'
#' @param dots A named list of query parameters passed via `...`.
#'
#' @return A modified named list with validated `size` parameter and
#'   hyphen-formatted parameter names.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage within search functions
#' params <- validate_size(list(size = 100, local_authority = "E09000030"))
#' # Returns: list(size = 100, "local-authority" = "E09000030")
#' }
validate_size <- function(dots) {
  if (length(dots) > 0) {
    names(dots) <- purrr::map_chr(names(dots), \(x) gsub("_", "-", x))
  }

  if (!is.null(dots$size) && (!is.numeric(dots$size) || dots$size < 1)) {
    cli::cli_abort("{.arg size} must be between 1 and 5000.")
  }

  if (!is.null(dots$size) && dots$size > 5000) {
    cli::cli_alert_warning(
      "Limit for {.arg size} exceeded: applied 5000 as fallback value."
    )
    dots$size <- 5000
  }

  if (is.null(dots$size)) {
    dots$size <- 25
  }

  return(dots)
}

#' Validate presence and format of additional query parameters
#'
#' Internal for ensuring that additional parameters (`...`) are provided,
#' then validates and normalizes the pagination `size` parameter via
#' `validate_size()`. Acts as a validation gateway for API query parameters.
#'
#' @param ... Additional query parameters to validate.
#'
#' @return A named list of validated parameters with hyphen-formatted names
#'   and normalized `size` value.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage within search functions
#' params <- validate_dots(size = 50, local_authority = "E09000030")
#' }
validate_dots <- function(...) {
  dots <- rlang::list2(...)

  if (purrr::is_empty(dots)) {
    cli::cli_abort(
      "Please, provide additional filtering parameters. If you want to retrieve all data for a particular certificate type or local authority, please use {cli::col_br_yellow('`odc_bulk_download`')} and its associated functions."
    )
  }

  dots <- validate_size(dots)

  return(dots)
}

#' Calculate page size for paginated API requests
#'
#' Internal for determining how many records to request for the current page when
#' using `max_records` pagination. Ensures the final request doesn't exceed the
#' total record limit.
#'
#' @param base_size Integer. The standard page size (typically 25 or user-set).
#' @param max_records Integer or NULL. Maximum total records to retrieve.
#' @param total_records Integer. Records already retrieved in previous pages.
#'
#' @return Integer. Number of records to request for the current page.
#'   Returns 0 if `max_records` has been reached.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Request up to 1000 records, 500 already received, base size is 250
#' calculate_page_size(250, 1000, 500) # Returns: 250
#'
#' # Only 200 records left to reach max_records
#' calculate_page_size(250, 1000, 800) # Returns: 200
#'
#' # Max records already reached
#' calculate_page_size(250, 1000, 1000) # Returns: 0
#'
#' # No max_records limit
#' calculate_page_size(250, NULL, 500) # Returns: 250
#' }
calculate_page_size <- function(base_size, max_records, total_records) {
  if (is.null(max_records)) {
    return(base_size)
  }

  records_needed <- max_records - total_records
  if (records_needed <= 0) {
    return(0)
  }

  min(base_size, records_needed)
}

#' Build and execute an authenticated API request
#'
#' Internal helper that constructs an HTTP GET request with query parameters
#' and pagination tokens, adds authentication, and executes it using the
#' package's standardized error handling.
#'
#' @param api_url `character` The complete API endpoint URL.
#' @param search_after `character` or NULL. Pagination token from previous
#'   response's `X-Next-Search-After` header.
#' @param page_count `integer` Current page number (used for error messages).
#' @param query_params `list` Parameters to include as URL query strings.
#'
#' @return An `httr2_response` object containing the API response.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage within pagination loop
#' resp <- build_and_execute_request(
#'   api_url = "https://epc.opendatacommunities.org/api/v1/domestic/search",
#'   search_after = "abc123",
#'   page_count = 2,
#'   query_params = list(address = "London", size = 100)
#' )
#' }
build_and_execute_request <- function(
  api_url,
  search_after,
  page_count,
  query_params
) {
  if (!is.null(search_after)) {
    query_params$`search-after` <- search_after
  }

  req <-
    httr2::request(api_url) %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = paste("Basic", odc_get_key())
    ) %>%
    httr2::req_url_query(!!!query_params)

  resp <- try_catch_response(req)

  return(resp)
}

#' Process and extract data from a search API response
#'
#' Internal helper function that parses the HTTP response from a search request,
#' extracts the JSON data, converts it to a tibble, and retrieves the pagination
#' token for the next page. Handles empty responses and provides a structured
#' output for the pagination loop.
#'
#' @param resp An `httr2_response` object from a search request.
#'
#' @return A list with three elements:
#'   * `data`: A tibble of the current page's records (or `NULL` if empty).
#'   * `next_search_after`: The pagination token for the next page (or `NULL`).
#'   * `record_count`: Integer count of records in the current page.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage within pagination loop
#' result <- process_search_response(resp)
#' current_data <- result$data
#' next_token <- result$next_search_after
#' }
process_search_response <- function(resp) {
  if (length(resp$body) == 0) {
    return(list(data = NULL, next_search_after = NULL, record_count = 0))
  }

  page_data <- httr2::resp_body_json(resp)

  if (
    length(page_data) == 0 ||
      (is.list(page_data) && length(page_data[[1]]) == 0)
  ) {
    return(list(data = NULL, next_search_after = NULL, record_count = 0))
  }

  cleaned_data <- odc_to_tibble(page_data)

  next_search_after <- httr2::resp_header(resp, "X-Next-Search-After")

  list(
    data = cleaned_data,
    next_search_after = next_search_after,
    record_count = nrow(cleaned_data)
  )
}

#' Determine whether paginated search should continue
#'
#' Internal decision function that evaluates whether to fetch another page
#' based on the current pagination mode, record limits, and API response.
#' Provides user feedback via CLI messages when stopping conditions are met.
#'
#' @param paginate Character. Pagination mode: `"none"`, `"manual"`, or `"all"`.
#' @param max_records Integer or NULL. Maximum total records to retrieve.
#' @param total_records Integer. Total records retrieved so far.
#' @param page_record_count Integer. Records retrieved in the current page.
#' @param requested_size Integer. Number of records requested for current page.
#' @param next_search_after Character or NULL. Pagination token for next page.
#'
#' @return Logical. `TRUE` if search should continue, `FALSE` otherwise.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Manual mode: stop after first page, show token if available
#' should_continue_search("manual", NULL, 25, 25, 25, "abc123")
#'
#' # All mode: continue if under max_records and more pages exist
#' should_continue_search("all", 100, 50, 25, 25, "def456") # TRUE
#'
#' # All mode: stop when max_records reached
#' should_continue_search("all", 100, 100, 25, 25, "ghi789") # FALSE
#'
#' # All mode: stop when API returns no more pages
#' should_continue_search("all", NULL, 75, 25, 25, NULL) # FALSE
#' }
should_continue_search <- function(
  paginate,
  max_records,
  total_records,
  page_record_count,
  requested_size,
  next_search_after
) {
  if (paginate == "none") {
    return(FALSE)
  }

  if (paginate == "manual") {
    if (!is.null(next_search_after)) {
      cli::cli_alert_info(
        "More results available. Next search-after token: {next_search_after}"
      )
    }
    return(FALSE)
  }

  if (paginate == "all") {
    # Check max_records limit
    if (!is.null(max_records) && total_records >= max_records) {
      cli::cli_alert_success("Reached max_records limit ({max_records}).")
      return(FALSE)
    }

    # Check if there are more pages
    if (is.null(next_search_after)) {
      cli::cli_alert_success(
        "Retrieved all available results ({total_records} records)."
      )
      return(FALSE)
    }

    # Check if we got fewer records than requested (end of data)
    if (page_record_count < requested_size) {
      cli::cli_alert_success(
        "Reached end of available data ({total_records} records)."
      )
      return(FALSE)
    }

    return(TRUE)
  }

  FALSE
}

#' Execute paginated search against the API
#'
#' Internal orchestrator function that manages the complete pagination loop for
#' API search requests. Coordinates page retrieval, state management, and
#' termination logic using the package's helper functions.
#'
#' @param paginate Character. Pagination mode: `"none"`, `"manual"`, or `"all"`.
#' @param max_pages Integer or NULL. Maximum number of pages to retrieve.
#' @param max_records Integer or NULL. Maximum total records to retrieve.
#' @param state List. Current pagination state containing:
#'   * `page_count`: Integer. Pages retrieved so far.
#'   * `total_records`: Integer. Total records retrieved so far.
#'   * `search_after`: Character or NULL. Pagination token for next page.
#'   * `all_results`: List. Accumulated results from all pages.
#'   * `continue`: Logical. Whether to continue pagination.
#' @param api_url Character. The complete API endpoint URL.
#' @param query_params Named list. Parameters for the API request.
#'
#' @return A list with three elements:
#'   * `all_results`: List of tibbles from all retrieved pages.
#'   * `total_records`: Integer total of all records retrieved.
#'   * `page_count`: Integer number of pages retrieved.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage within search functions
#' results <- execute_paginated_search(
#'   paginate = "all",
#'   max_pages = NULL,
#'   max_records = 1000,
#'   state = list(
#'     page_count = 0,
#'     total_records = 0,
#'     search_after = NULL,
#'     all_results = list(),
#'     continue = TRUE
#'   ),
#'   api_url = "https://epc.opendatacommunities.org/api/v1/domestic/search",
#'   query_params = list(address = "London", size = 100)
#' )
#' }
execute_paginated_search <- function(
  paginate,
  max_pages,
  max_records,
  state,
  api_url,
  query_params
) {
  while (state$continue) {
    state$page_count <- state$page_count + 1

    if (!is.null(max_pages) && state$page_count > max_pages) {
      cli::cli_alert_info("Reached max_pages limit ({max_pages}).")
      break
    }

    current_size <- calculate_page_size(
      query_params$size,
      max_records,
      state$total_records
    )

    if (current_size <= 0) {
      cli::cli_alert_success("Reached max_records limit ({max_records}).")
      break
    }

    resp <-
      build_and_execute_request(
        api_url = api_url,
        search_after = state$search_after,
        page_count = state$page_count,
        query_params = query_params
      )

    processed <- process_search_response(resp)

    if (is.null(processed$data)) {
      if (state$page_count == 1) {
        cli::cli_abort("No results matching the filtering criteria were found.")
      }
      cli::cli_alert_info("Page {state$page_count} returned empty response.")
      break
    }

    state$all_results[[state$page_count]] <- processed$data
    state$total_records <- state$total_records + processed$record_count

    if (!is.null(max_records)) {
      cli::cli_alert_info(
        "Page {state$page_count}: {processed$record_count} records (total: {state$total_records})"
      )
    } else {
      cli::cli_alert_info(
        "Page {state$page_count}: {processed$record_count} records (total: {state$total_records})"
      )
    }

    state$continue <- should_continue_search(
      paginate = paginate,
      max_records = max_records,
      total_records = state$total_records,
      page_record_count = processed$record_count,
      requested_size = current_size,
      next_search_after = processed$next_search_after
    )

    if (state$continue) {
      state$search_after <- processed$next_search_after
      Sys.sleep(0.05)
    }
  }

  list(
    all_results = state$all_results,
    total_records = state$total_records,
    page_count = state$page_count
  )
}

#' Finalize and combine paginated search results
#'
#' Internal helper for combining results from multiple pages into
#' a single tibble, trims to `max_records` if specified, and provides a
#' summary message. Handles empty results gracefully.
#'
#' @param raw_results List containing paginated results with elements:
#'   * `all_results`: List of tibbles from each page.
#'   * `page_count`: Integer number of pages retrieved.
#'   * `total_records`: Integer total records across all pages.
#' @param max_records Integer or NULL. Maximum records to return (trims excess).
#'
#' @return A tibble containing all combined and potentially trimmed results.
#'
#' @noRd
#' @examples
#' \dontrun{
#' # Internal usage after execute_paginated_search
#' combined_data <- finalize_search_results(
#'   list(
#'     all_results = list(tibble1, tibble2),
#'     page_count = 2,
#'     total_records = 200
#'   ),
#'   max_records = 150
#' )
#' }
finalize_search_results <- function(raw_results, max_records) {
  if (length(raw_results$all_results) == 0) {
    return(odc_to_tibble(list()))
  }

  # Combine results
  if (length(raw_results$all_results) == 1) {
    final_result <- raw_results$all_results[[1]]
  } else {
    final_result <- dplyr::bind_rows(raw_results$all_results)
  }

  if (!is.null(max_records) && nrow(final_result) > max_records) {
    cli::cli_alert_info("Trimming result to exactly {max_records} records.")
    final_result <- final_result[1:max_records, ]
  }

  cli::cli_alert_success(
    "Returning {nrow(final_result)} records from {raw_results$page_count} page(s)."
  )
  return(final_result)
}

#' Search for Energy Performance Certificates and Display Energy Certificates
#'
#' @description
#' This function allows to search for energy certificates from the Open Data
#' Communities API. It provides access to *Domestic*, *Non-domestic*, and *Display* Certificates, with full support for pagination.
#'
#' @param type `character` The **type of certificate** to search for. Must be one of:
#'   * `"domestic"`: Domestic Energy Performance Certificates (homes)
#'   * `"non_domestic"`: Non-domestic Energy Performance Certificates (business premises)
#'   * `"display"`: Display Energy Certificates (public buildings)
#' @param paginate `character` **Pagination control mode**. Must be one of:
#'   * `"none"`: Fetch only the first page of results (default, fastest)
#'   * `"all"`: Automatically retrieve all available pages
#'   * `"manual"`: Fetch first page and display continuation token for manual control
#' @param max_pages `integer` or `NULL`. **Maximum pages** to retrieve when `paginate = "all"`.
#'   Useful for limiting large queries during testing. Ignored in other modes.
#' @param max_records `integer` or `NULL`. **Maximum total records** to retrieve.
#'   When specified, automatically switches `paginate = "all"` and fetches records
#'   across multiple pages until the limit is reached. Efficiently adjusts page sizes.
#' @param ... **Search filters** passed as name-value pairs. Common parameters include:
#'   * `address`: `character`  Address search string (e.g., `"Downing Street"`)
#'   * `postcode`: `character`  UK postcode, full or partial (e.g., `"SW1A"`, `"SW1A 1AA"`)
#'   * `local_authority`: `character` Local authority code (e.g., `"E09000030"`)
#'   * `from_date`, `to_date`: `character` Date range in `"YYYY-MM"` format
#'   * `property_type`: `character` Property type (e.g., `"house"`, `"flat"`)
#'   * `size`: `integer` Page size (1-5000, defaults to 25)
#'
#'   **Note:** Parameters with hyphens in the API (`local-authority`) can be
#'   written with underscores instead (`local_authority`).
#'
#' @return
#' A [tibble][tibble::tibble-package] containing certificate records matching the
#' search criteria. The tibble includes all available fields from the API.
#' Returns an empty tibble if no matches are found.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Basic search for domestic certificates by postcode
#' odc_search_data("domestic", postcode = "SW1A 1AA")
#'
#' # Search non-domestic certificates with address filter
#' odc_search_data("non_domestic", address = "London", size = 100)
#'
#' # Search Display Energy Certificates with authority filter
#' odc_search_data("display", local_authority = "E09000030")
#'
#' # Get exactly 500 records (automatically paginates)
#' odc_search_data("domestic", max_records = 500, postcode = "SW1A")
#'
#' # Manual pagination control
#' first_page <- odc_search_data("domestic", paginate = "manual",
#'                               address = "Manchester")
#' # Use token from message to get next page manually
#'
#' # Complex search with multiple filters
#' odc_search_data(
#'   "domestic",
#'   paginate = "all",
#'   max_records = 1000,
#'   postcode = "SW1A",
#'   from_date = "2020-01",
#'   to_date = "2023-12",
#'   property_type = "flat"
#' )
#' }
odc_search_data <- function(
  type = c("domestic", "non_domestic", "dislay"),
  paginate = c("none", "all", "manual"),
  max_pages = NULL,
  max_records = NULL,
  ...
) {
  dots <- validate_dots(...)

  api_endpoint <-
    get_api_url(
      type = type,
      endpoint = "search"
    )

  paginate <- rlang::arg_match(paginate)

  if (!is.null(max_records) && paginate == "none") {
    paginate <- "all"
    cli::cli_alert_info(
      "Setting {.arg paginate} = `all` because max_records is specified."
    )
  }

  state <- list(
    page_count = 0,
    total_records = 0,
    search_after = NULL,
    all_results = list(),
    continue = TRUE
  )

  raw_results <-
    execute_paginated_search(
      paginate = paginate,
      max_pages = max_pages,
      max_records = max_records,
      state = state,
      api_url = api_endpoint,
      query_params = dots
    )

  results <- finalize_search_results(raw_results, max_records)

  return(results)
}
