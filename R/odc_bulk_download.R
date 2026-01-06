#' Internal to build the request to the GET/files endpoint
#' @noRd
odc_file_request <- function() {
  req <-
    httr2::request("https://epc.opendatacommunities.org/api/v1/files") %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      accept = "application/json",
      Authorization = paste("Basic", odc_get_key())
    )

  resp <- try_catch_response(req)

  return(resp)
}

#' Get a tidy data frame of available EPC data files
#'
#' Retrieve a clean data frame with file names and sizes. This provides a convenient overview of all downloadable Energy Performance Certificate data files.
#'
#' @return A tibble with two columns:
#' \describe{
#'   \item{file_name}{Character vector of file names available for download}
#'   \item{size}{Numeric vector of file sizes in bytes}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Requires API key set via odc_set_key()
#' odc_get_file_list()
#' }
odc_get_file_list <- function() {
  resp <- odc_file_request()

  results <- httr2::resp_body_json(resp)

  results <-
    results %>%
    purrr::flatten() %>%
    stack() %>%
    tibble::tibble() %>%
    magrittr::set_names(c("size", "file_name"))

  return(results)
}

#' Filter available EPC data files by type and/or local authority
#'
#' Returns a subset of available Energy Performance Certificate data files
#' filtered by certificate type (domestic, non-domestic, display) and/or
#' local authority code. Useful for finding specific files to download.
#'
#' @param type `character` string specifying certificate type to filter by.
#'   Must be one of: "domestic", "non_domestic", or "display". Case-sensitive.
#' @param local_authority_code `character` string of local authority code to
#'   filter by (e.g., "E09000001" for City of London). Optional.
#'
#' @return A tibble with two columns:
#' \describe{
#'   \item{file_name}{Character vector of filtered file names}
#'   \item{size}{Numeric vector of corresponding file sizes in bytes}
#' }
#' Returns an empty tibble if no files match the filter criteria.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get all domestic certificate files
#' domestic_files <- odc_get_file(type = "domestic")
#'
#' # Get domestic files for a specific local authority
#' domestic_birmingham <- odc_get_file(type = "domestic", local_authority_code = "E08000025")
#'
#' # Get all files for a local authority (any type)
#' birmingham <- odc_get_file(local_authority_code = "E08000025")
#' }
#'
odc_get_file <- function(type = NULL, local_authority_code = NULL) {
  `%!in%` = Negate(`%in%`)

  if (!is.null(type)) {
    if (type %!in% c("domestic", "non_domestic", "display")) {
      cli::cli_abort(
        "{.arg type} should be one of {.val domestic}, {.val non_domestic}, {.val display}."
      )
    } else {
      type <-
        gsub("_", "-", type) %>%
        paste0("^", .)
    }
  }

  resp <- odc_file_request()

  results <- httr2::resp_body_json(resp)

  results <-
    results %>%
    purrr::flatten() %>%
    utils::stack() %>%
    tibble::tibble() %>%
    magrittr::set_names(c("size", "file_name"))

  args <-
    list(
      type = type,
      local_authority_code = local_authority_code
    ) %>%
    purrr::compact() %>%
    paste(collapse = "-")

  results <-
    results %>%
    dplyr::mutate(
      file_name = as.character(file_name)
    ) %>%
    dplyr::filter(
      file_name %in% stringr::str_subset(.$file_name, args)
    )

  return(results)
}

#' Download and extract EPC data files from ZIP archives
#'
#' Downloads specified ZIP files from the EPC Open Data API, extracts either
#' certificate or recommendation CSV data, and saves it to the destination path.
#' Handles authentication, error checking, and cleanup of temporary files.
#'
#' @param file_name `character` File name to be downloaded (extension included)
#'   Should be a valid file name from `odc_get_file()` or `odc_get_file_list()`.
#' @param destination_path `character` Directory path where extracted
#'   CSV file will be saved. Directory will be created if it doesn't exist.
#' @param type `character` String specifying which data type to extract from
#'   the ZIP archive. Must be either "certificate" (default) or "recommendation".
#' @param keep_zip `logical` Should the downloaded ZIP file be kept? If yes, it will
#' be saved in `destination_path`. Default is `FALSE` (only extracted CSV is kept).
#'
#' @return Invisibly returns `NULL`. The function's primary purpose is the
#'   side effect of saving extracted CSV data to disk.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Download and extract domestic certificate data for London
#' odc_bulk_download(
#'   file_name = "domestic-E08000025.zip",
#'   destination_path = here::here("downloads"),
#'   type = "certificate"
#' )
#'
#' # Download and keep the ZIP file along with extracted recommendations
#' odc_bulk_download(
#'   file_name = "non_domestic-E08000025.csv.zip",
#'   destination_path = here::here("downloads"),
#'   type = "recommendation",
#'   keep_zip = TRUE
#' )
#' }
odc_bulk_download <- function(
  file_name,
  destination_path,
  type = c("certificate", "recommendation"),
  keep_zip = FALSE
) {
  type <- rlang::arg_match(type)
  type <- paste0(type, "s")

  temp_dir <- tempfile()
  dir.create(temp_dir)
  temp_zip_path <- file.path(temp_dir, basename(file_name))

  if (length(file_name) > 1) {
    cli::cli_abort("No more than one file at a time.")
  }

  req <-
    httr2::request("https://epc.opendatacommunities.org/api/v1/files/") %>%
    httr2::req_url_path_append(file_name) %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      Authorization = paste("Basic", odc_get_key())
    )

  resp <- try_catch_response(request = req, path = temp_zip_path)

  to_unzip <- paste0(type, ".csv")

  files_in_zip <- utils::unzip(temp_zip_path, list = TRUE)$Name

  if (!(to_unzip %in% files_in_zip)) {
    cli::cli_abort(c(
      "The requested file '{to_unzip}' was not found in the archive '{file_name}'.",
      "i" = "Available files are: {paste(files_in_zip, collapse = ', ')}"
    ))
  }

  utils::unzip(temp_zip_path, to_unzip, exdir = temp_dir)

  dat <-
    rio::import(file.path(temp_dir, to_unzip), setclass = "tibble") %>%
    janitor::clean_names("snake")

  rio::export(
    dat,
    file.path(destination_path, fs::path_ext_remove(file_name), to_unzip),
    row.names = FALSE
  )

  if (!keep_zip) {
    unlink(temp_dir, recursive = TRUE)
  } else {
    # If keeping, move zip to current directory
    fs::file_copy(
      path = temp_zip_path,
      new_path = file.path(destination_path, file_name)
    )
    unlink(temp_dir, recursive = TRUE)
  }

  cli::cli_alert_success(
    "{type}.csv file has been saved to {.file {destination_path}}"
  )

  return(invisible())
}
