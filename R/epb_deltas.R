#' Fetch changed energy certificates
#'
#' Retrieves certificates recorded as removed or having an updated UPRN during
#' a date range.
#'
#' @param date_start Start date in `YYYY-MM-DD` format.
#' @param date_end End date in `YYYY-MM-DD` format. Defaults to `date_start`.
#'
#' @return A tibble containing certificate number, event type, and timestamp.
#' @export
#'
#' @examples
#' \dontrun{
#' epb_get_deltas("2025-01-01", "2025-01-31")
#' }
epb_get_deltas <- function(date_start, date_end = date_start) {
  date_start <- epb_validate_date(date_start, "date_start")
  date_end <- epb_validate_date(date_end, "date_end")

  if (date_end < date_start) {
    cli::cli_abort("{.arg date_end} must not be earlier than {.arg date_start}.")
  }

  request <- epb_request(
    "api/deltas",
    query = list(
      date_start = format(date_start),
      date_end = format(date_end)
    )
  )

  epb_parse_response(epb_perform(request))$data
}

epb_validate_date <- function(value, argument) {
  if (inherits(value, "Date") && length(value) == 1L && !is.na(value)) {
    return(value)
  }

  if (!rlang::is_string(value) || !grepl("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", value)) {
    cli::cli_abort("{.arg {argument}} must use `YYYY-MM-DD` format.")
  }

  parsed <- as.Date(value)
  if (is.na(parsed)) {
    cli::cli_abort("{.arg {argument}} must be a valid calendar date.")
  }
  parsed
}
