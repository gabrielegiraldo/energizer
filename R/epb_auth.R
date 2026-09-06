#' Set Energy Performance API bearer token
#'
#' Stores a bearer token for the current R session in the
#' `EPB_BEARER_TOKEN` environment variable. Tokens are available from the
#' service's **My account** page.
#'
#' @param token A non-empty bearer token. A leading `Bearer ` prefix is removed.
#' @param overwrite Whether to replace an existing token. Defaults to `FALSE`.
#'
#' @return `NULL`, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' set_token("your-bearer-token")
#' }
set_token <- function(token, overwrite = FALSE) {
  if (!rlang::is_string(token) || !nzchar(trimws(token))) {
    cli::cli_abort("{.arg token} must be a non-empty character string.")
  }

  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    cli::cli_abort("{.arg overwrite} must be `TRUE` or `FALSE`.")
  }

  current_token <- Sys.getenv("EPB_BEARER_TOKEN")
  if (nzchar(current_token) && !overwrite) {
    cli::cli_abort(c(
      "{.field EPB_BEARER_TOKEN} is already set.",
      "i" = "Set {.arg overwrite} to `TRUE` to replace it."
    ))
  }

  token <- sub("^\\s*Bearer\\s+", "", token, ignore.case = TRUE)
  token <- trimws(token)

  if (!nzchar(token)) {
    cli::cli_abort("{.arg token} must contain a bearer token value.")
  }

  Sys.setenv(EPB_BEARER_TOKEN = token)
  cli::cli_alert_success("Bearer token set for this R session.")
  invisible(NULL)
}

#' Read configured bearer token
#'
#' @return Bearer token as a character scalar.
#' @noRd
epb_get_token <- function() {
  token <- Sys.getenv("EPB_BEARER_TOKEN")

  if (!nzchar(token)) {
    cli::cli_abort(c(
      "No Energy Performance API bearer token found.",
      "i" = "Copy token from service's My account page and call {.fn set_token}."
    ))
  }

  token
}
