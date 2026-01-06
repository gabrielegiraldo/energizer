#' Encode user and key for Basic Authentication
#'
#' @description
#' Internal helper function that encodes the provided username and API key
#' into a Base64 string, formatted as required for HTTP Basic Authentication
#' (`user:key`).
#'
#' @param user `character` Open Data Communities username (email).
#' @param key `character` Open Data Communities API key.
#'
#' @return `character` Base64-encoded string for use in the `Authorization` header.
#'
#' @noRd
.encode_key <- function(user, key) {
  testthat::expect(is.character(user), "user must be a character string")
  testthat::expect(is.character(key), "key must be a character string")

  user <- stringr::str_trim(user)
  key <- stringr::str_trim(key)

  raw_key <- charToRaw(paste(user, key, sep = ":"))
  encoded_key <- base64enc::base64encode(raw_key)

  return(encoded_key)
}

#' Retrieve the stored API key from environment variable
#'
#' @description
#' Internal function that reads the `ODC_API_KEY` environment variable.
#' This is the primary function used by all API-wrapping functions to
#' obtain credentials for authentication.
#'
#' @return `character` The Base64-encoded API key stored in `ODC_API_KEY`.
#'   Returns an empty string (`""`) if the variable is not set.
#'
#' @noRd
odc_get_key <- function() {
  key <- Sys.getenv("ODC_API_KEY")
  if (identical(key, "")) {
    cli::cli_abort(
      "No API key found. Please, set it up via the {cli::col_br_yellow('`odc_set_key`')} function."
    )
  }

  return(key)
}

#' Set your Open Data Communities API credentials
#'
#' @description
#' `odc_set_key()` stores your Open Data Communities username and API key
#' as an environment variable (`ODC_API_KEY`) for use in all subsequent API calls.
#' The credentials are combined and encoded in Base64 as required for the API's
#' HTTP Basic Authentication.
#'
#' @details
#' This function only needs to be run once per R session, or whenever your
#' credentials change. The key is stored in the `ODC_API_KEY` environment
#' variable for the current session.
#'
#' For security, it is recommended *not* to hard-code credentials in your
#' scripts. Consider using this function interactively or sourcing it from a
#' secure location.
#'
#' @param odc_user `character` Your Open Data Communities username (usually your
#'   email address). If `NULL`, the function will abort.
#' @param odc_key `character` Your Open Data Communities API key. If `NULL`,
#'   the function will abort.
#' @param overwrite `logical` If `TRUE`, will overwrite an existing `ODC_API_KEY`
#'   environment variable. Defaults to `FALSE`, preventing accidental overwrites.
#'
#' @return Returns `NULL`. Called primarily for its side effect of
#'   setting the environment variable.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Set your credentials for the first time
#' odc_set_key(
#'   odc_user = "email@example.com",
#'   odc_key = "your_api_key_here"
#' )
#'
#' # Overwrite existing credentials (if needed)
#' odc_set_key(
#'   odc_user = "email@example.com",
#'   odc_key = "new_api_key",
#'   overwrite = TRUE
#' )
#' }
odc_set_key <- function(odc_user = NULL, odc_key = NULL, overwrite = FALSE) {
  if (is.null(odc_key) & is.null(odc_user)) {
    cli::cli_abort("Please, provide your OpenDataCommunity username & API key.")
    return(invisible())
  }

  if (!identical(Sys.getenv("ODC_API_KEY"), "")) {
    if (!overwrite) {
      cli::cli_abort(
        "{.field ODC_API_KEY} environment variable already found.\n
        Please set {.arg overwrite} to {.field TRUE} to overwrite the existing value."
      )
      return(invisible())
    } else {
      encoded_key <- .encode_key(odc_user, odc_key)
    }
  }

  encoded_key <- .encode_key(odc_user, odc_key)

  Sys.setenv(ODC_API_KEY = encoded_key)
  cli::cli_alert_success(
    "API key successfully set."
  ) # You can find it in the {.val ODC_API_KEY} environment variable."
  return(invisible())
}
