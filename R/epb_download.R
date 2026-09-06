.epb_download_types <- c(
  "domestic",
  "non_domestic",
  "display",
  "non_domestic_recommendation",
  "display_recommendation"
)

epb_download_endpoint <- function(type, info = FALSE) {
  download_paths <- c(
    domestic = "domestic",
    non_domestic = "non-domestic",
    display = "display",
    non_domestic_recommendation = "non-domestic-recommendation",
    display_recommendation = "display-recommendation"
  )
  info_paths <- c(
    domestic = "domestic",
    non_domestic = "non-domestic",
    display = "display",
    non_domestic_recommendation = "non-domestic-recommendations",
    display_recommendation = "display-recommendations"
  )

  if (info) unname(info_paths[[type]]) else unname(download_paths[[type]])
}

#' Download a full-load energy certificate dataset
#'
#' Downloads a monthly full-load ZIP. Recommendation datasets are available in
#' JSON only. Redirects to time-limited download URLs are followed automatically.
#'
#' @param type Dataset type: `"domestic"`, `"non_domestic"`, `"display"`,
#'   `"non_domestic_recommendation"`, or `"display_recommendation"`.
#' @param format File format: `"csv"` or `"json"`.
#' @param destination_path Directory where ZIP is saved.
#' @param unzip Whether to extract ZIP contents into a sibling directory.
#' @param overwrite Whether to replace an existing ZIP.
#'
#' @return Downloaded ZIP path, invisibly.
#' @export
#'
#' @examples
#' \dontrun{
#' download_full_load("domestic", "csv", tempdir())
#' }
download_full_load <- function(
  type = .epb_download_types,
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  type <- rlang::arg_match(type, .epb_download_types)
  format <- rlang::arg_match(format)
  epb_validate_download_options(type, format, destination_path, unzip, overwrite)

  endpoint <- epb_download_endpoint(type)
  file_name <- paste(endpoint, format, "zip", sep = ".")
  file_name <- sub("\\.([^.]+)\\.zip$", "-\\1.zip", file_name)

  if (!dir.exists(destination_path)) {
    dir.create(destination_path, recursive = TRUE)
  }
  destination_path <- normalizePath(destination_path, mustWork = TRUE)
  target_path <- file.path(destination_path, file_name)

  if (file.exists(target_path) && !overwrite) {
    cli::cli_abort(c(
      "File already exists: {.file {target_path}}.",
      "i" = "Set {.arg overwrite} to `TRUE` to replace it."
    ))
  }

  request <-
    epb_request(paste("api/files", endpoint, format, sep = "/")) |>
    httr2::req_options(followlocation = TRUE) |>
    httr2::req_progress()

  temporary_path <- tempfile(tmpdir = destination_path, fileext = ".zip")
  on.exit(unlink(temporary_path), add = TRUE)
  epb_perform(request, path = temporary_path)

  copied <- file.copy(temporary_path, target_path, overwrite = overwrite)
  if (!copied) {
    cli::cli_abort("Could not save downloaded file to {.file {target_path}}.")
  }

  if (unzip) {
    extract_path <- file.path(destination_path, sub("\\.zip$", "", file_name))
    if (!dir.exists(extract_path)) {
      dir.create(extract_path, recursive = TRUE)
    }
    utils::unzip(target_path, exdir = extract_path)
  }

  cli::cli_alert_success("Saved full-load dataset to {.file {target_path}}.")
  invisible(target_path)
}

#' Fetch full-load download metadata
#'
#' @inheritParams download_full_load
#'
#' @return A one-row tibble containing file size and last-updated timestamp.
#' @export
download_info <- function(
  type = .epb_download_types,
  format = c("csv", "json")
) {
  type <- rlang::arg_match(type, .epb_download_types)
  format <- rlang::arg_match(format)
  epb_validate_download_format(type, format)

  endpoint <- epb_download_endpoint(type, info = TRUE)
  request <- epb_request(paste("api/files", endpoint, format, "info", sep = "/"))
  epb_parse_response(epb_perform(request))$data
}

#' Download domestic full-load data
#' @inheritParams download_full_load
#' @export
download_domestic <- function(
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  download_full_load(
    "domestic", format, destination_path, unzip, overwrite
  )
}

#' Download non-domestic full-load data
#' @inheritParams download_full_load
#' @export
download_non_domestic <- function(
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  download_full_load(
    "non_domestic", format, destination_path, unzip, overwrite
  )
}

#' Download display full-load data
#' @inheritParams download_full_load
#' @export
download_display <- function(
  format = c("csv", "json"),
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  download_full_load(
    "display", format, destination_path, unzip, overwrite
  )
}

#' Download non-domestic recommendation data
#' @inheritParams download_full_load
#' @export
download_non_domestic_recommendations_json <- function(
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  download_full_load(
    "non_domestic_recommendation", "json", destination_path, unzip, overwrite
  )
}

#' Download display recommendation data
#' @inheritParams download_full_load
#' @export
download_display_recommendations_json <- function(
  destination_path = ".",
  unzip = FALSE,
  overwrite = FALSE
) {
  download_full_load(
    "display_recommendation", "json", destination_path, unzip, overwrite
  )
}

epb_validate_download_options <- function(type, format, destination_path, unzip, overwrite) {
  epb_validate_download_format(type, format)
  if (!rlang::is_string(destination_path) || !nzchar(trimws(destination_path))) {
    cli::cli_abort("{.arg destination_path} must be a non-empty path.")
  }
  if (!is.logical(unzip) || length(unzip) != 1L || is.na(unzip)) {
    cli::cli_abort("{.arg unzip} must be `TRUE` or `FALSE`.")
  }
  if (!is.logical(overwrite) || length(overwrite) != 1L || is.na(overwrite)) {
    cli::cli_abort("{.arg overwrite} must be `TRUE` or `FALSE`.")
  }
}

epb_validate_download_format <- function(type, format) {
  recommendation <- grepl("recommendation$", type)
  if (recommendation && format != "json") {
    cli::cli_abort("Recommendation full-load datasets are available in JSON only.")
  }
}
