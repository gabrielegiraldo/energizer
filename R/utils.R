#' Convert Open Data Communities API response to tidy tibble
#'
#' @description
#'
#' Internal for transforming the raw JSON response from the Open Data Communities API
#' into a clean tibble with snake_case column names. This function extracts the `rows`
#' element from the API response and processes it into a standardized data frame format.
#'
#' @param odc_esp `list` The parsed JSON response from the Open Data Communities API,
#'   typically obtained via `httr2::resp_body_json()`.
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Internal usage only - called within odc_get_data()
#' odc_to_tibble(parsed_json_response)
#' }
odc_to_tibble <- function(odc_resp) {
  results <-
    odc_resp %>%
    purrr::pluck("rows") %>%
    data.table::rbindlist() %>%
    tibble::tibble() %>%
    janitor::clean_names("snake")

  return(results)
}

#' Perform HTTP request with error handling and progress indicators
#'
#' @description
#'
#' Internal wrapper around `httr2::req_perform()` that adds visual progress
#' indicators and standardized error handling.
#'
#' @details
#' The function displays a CLI progress spinner during the request and converts
#' any HTTP or network errors into user-friendly abort messages. Additional
#' arguments passed via `...` are forwarded to `httr2::req_perform()`.
#'
#' @param request An `httr2_request` object prepared for execution.
#' @param ... Additional arguments passed to `httr2::req_perform()`.
#'
#' @return An `httr2_response` object if the request succeeds.
#'
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Internal usage only
#' req <- httr2::request("https://api.example.com/data")
#' response <- try_catch_response(req)
#' }
try_catch_response <- function(request, ...) {
  tryCatch(
    {
      cli::cli_process_start("Reading data from API")
      resp <- httr2::req_perform(request, ...)
      cli::cli_process_done()
    },
    error = function(err) {
      cli::cli_process_failed()
      resp_status <-
        switch(
          as.character(httr2::last_response()$status),
          "404" = "404 Not Found",
          "401" = "401 Not Authorized"
        )
      cli::cli_abort(
        "Failed to read data with response status code: {resp_status}"
      )
    }
  )

  return(resp)
}
