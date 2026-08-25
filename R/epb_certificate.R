#' Fetch an energy certificate
#'
#' Retrieves full EPC or DEC data using its 20-digit certificate number.
#'
#' @param certificate_number Certificate number, with or without hyphens.
#'
#' @return A one-row tibble. Fields vary by certificate schema.
#' @export
#'
#' @examples
#' \dontrun{
#' get_certificate("1111-2222-3333-4444-5555")
#' }
get_certificate <- function(certificate_number) {
  certificate_number <- epb_normalize_certificate_number(certificate_number)

  request <- epb_request(
    "api/certificate",
    query = list(certificate_number = certificate_number)
  )

  response <- epb_perform(request)
  epb_parse_response(response)$data
}

epb_normalize_certificate_number <- function(certificate_number) {
  if (!rlang::is_string(certificate_number)) {
    cli::cli_abort("{.arg certificate_number} must be a character string.")
  }

  digits <- gsub("-", "", trimws(certificate_number), fixed = TRUE)
  if (!grepl("^[0-9]{20}$", digits)) {
    cli::cli_abort(
      "{.arg certificate_number} must contain exactly 20 digits."
    )
  }

  paste(substring(digits, seq(1L, 17L, 4L), seq(4L, 20L, 4L)), collapse = "-")
}
