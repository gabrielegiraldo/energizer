#' Retrieve certificate or recommendations data by LMK key
#'
#' @description
#' `odc_get_data()` fetches detailed data for a specific Energy Performance
#' Certificate (EPC) or Display Energy Certificate (DEC) using its unique
#' LMK key. This function is the core mechanism for retrieving individual certificate
#' records and their recommendations from the API.
#'
#' @details
#' The function constructs the appropriate API endpoint URL based on the
#' certificate type and data endpoint, performs an authenticated request,
#' and returns the results as a tibble.
#'
#' @param lmk_key `character` The unique Landmark (LMK) identifier for the
#'   certificate. This is a required parameter.
#' @param type `character` Type of certificate. Must be one of:
#'   `"domestic"`, `"non_domestic"`, or `"display"`.
#' @param endpoint `character` Type of data to retrieve. Must be one of:
#'   `"certificate"` (for full certificate details) or `"recommendation"`
#'   (for improvement recommendations).
#'
#' @return A [tibble][tibble::tibble-package] containing the requested data.
#'   For certificate endpoints, this includes property details, energy ratings,
#'   and certificate information. For recommendation endpoints, this includes
#'   improvement suggestions, costs, and potential savings.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Retrieve full details for a domestic EPC
#' cert_data <- odc_get_data(
#'   lmk_key = "12345678901234567890123456789012",
#'   type = "domestic",
#'   endpoint = "certificate"
#' )
#'
#' # Retrieve recommendations for a non-domestic EPC
#' rec_data <- odc_get_data(
#'   lmk_key = "98765432109876543210987654321098",
#'   type = "non_domestic",
#'   endpoint = "recommendation"
#' )
#'
#' # Retrieve details for a Display Energy Certificate (DEC)
#' dec_data <- odc_get_data(
#'   lmk_key = "55555555555555555555555555555555",
#'   type = "display",
#'   endpoint = "certificate"
#' )
#' }
odc_get_data <- function(lmk_key = NULL, type, endpoint) {
  if (identical(endpoint, "search")) {
    cli::cli_abort(
      "Please use the {cli::col_red('`odc_search_data`')} function instead."
    )
  }

  if (is.null(lmk_key)) {
    cli::cli_abort(
      "{.arg lmk_key} is set to `NULL`: please, provide a valid value."
    )
  }

  api_endpoint <-
    get_api_url(
      type = type,
      endpoint = endpoint
    )

  req <-
    httr2::request(api_endpoint) %>%
    httr2::req_url_path_append(lmk_key) %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = paste("Basic", odc_get_key())
    )

  resp <- try_catch_response(req)

  results <- httr2::resp_body_json(resp)

  results <- odc_to_tibble(results)

  return(results)
}
