#' Fetch available EPC code tables
#'
#' @return A tibble with one `code` column.
#' @export
#'
#' @examples
#' \dontrun{
#' get_codes()
#' }
get_codes <- function() {
  response <- epb_perform(epb_request("api/codes"))
  body <- httr2::resp_body_json(response, simplifyVector = FALSE)

  if (!is.list(body) || is.null(body$data)) {
    cli::cli_abort("Energy Performance API response did not contain a {.field data} field.")
  }

  tibble::tibble(code = unlist(body$data, use.names = FALSE))
}

#' Fetch EPC code values
#'
#' @param code Code table name returned by [get_codes()].
#' @param key Optional code key.
#' @param schema_version Optional EPC schema version. Sent as `schemaVersion`.
#'
#' @return A tibble. Nested code values remain list-columns.
#' @export
#'
#' @examples
#' \dontrun{
#' get_code_info("built_form")
#' get_code_info("built_form", key = "NR", schema_version = "RdSAP-Schema-17.0")
#' }
get_code_info <- function(code, key = NULL, schema_version = NULL) {
  if (!rlang::is_string(code) || !nzchar(trimws(code))) {
    cli::cli_abort("{.arg code} must be a non-empty character string.")
  }

  query <- list(
    code = trimws(code),
    key = key,
    schemaVersion = schema_version
  )
  query <- query[!vapply(query, is.null, logical(1))]

  response <- epb_perform(epb_request("api/codes/info", query = query))
  epb_parse_response(response)$data
}
