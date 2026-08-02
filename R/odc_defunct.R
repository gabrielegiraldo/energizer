#' Defunct Open Data Communities API functions
#'
#' Open Data Communities API and Basic Authentication workflow were replaced by
#' Get energy performance of buildings data API. Use corresponding `epb_*`
#' function.
#'
#' @param ... Ignored.
#'
#' @return These functions always throw a defunct-function error.
#' @name odc-defunct
NULL

#' @export
#' @rdname odc-defunct
odc_set_key <- function(...) {
  .Defunct("epb_set_token", package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_get_data <- function(...) {
  .Defunct("epb_get_certificate", package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_search_data <- function(...) {
  .Defunct(
    "epb_search_domestic, epb_search_non_domestic, or epb_search_display",
    package = "energizer"
  )
}

#' @export
#' @rdname odc-defunct
odc_bulk_download <- function(...) {
  .Defunct("epb_download_full_load", package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_get_file_list <- function(...) {
  .Defunct("epb_download_info", package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_get_file <- function(...) {
  .Defunct("epb_download_info", package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_get_meta <- function(...) {
  .Defunct(package = "energizer")
}

#' @export
#' @rdname odc-defunct
odc_get_schema <- function(...) {
  .Defunct("epb_get_codes", package = "energizer")
}
