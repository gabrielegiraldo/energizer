#' Extract and process schema data for a specific resource
#'
#' This internal function processes a JSON schema object to extract and transform
#' schema information for either certificates or recommendations. It converts
#' nested schema structures into a tidy tabular format suitable for data analysis.
#'
#' @param schema A list object containing the JSON schema data, typically loaded
#'   from a schema.json file.
#' @param resource Character string specifying the type of resource to extract.
#'   Must be either "certificate" or "recommendation".
#'
#' @return A tibble containing the processed schema data with the following columns:
#'   - `name`: Cleaned column names
#'   - `primary_key`: Cleaned primary key names (if present)
#'   - `column_reference`: Cleaned foreign key references (if present)
#'   - Additional columns from the schema's column definitions
#'
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Example schema would be a complex nested list from JSON
#' schema_data <- jsonlite::fromJSON("schema.json")
#' cert_schema <- extract_schema(schema_data, "certificate")
#' rec_schema <- extract_schema(schema_data, "recommendation")
#' }
extract_schema <- function(
  schema,
  resource = c("certificate", "recommendation")
) {
  resource <- rlang::arg_match(resource)
  resource <- paste0(resource, "s")

  results <-
    schema %>%
    purrr::pluck("tables") %>%
    tibble::tibble() %>%
    dplyr::filter(url %in% stringr::str_subset(.$url, resource)) %>%
    purrr::pluck("tableSchema") %>%
    tibble::tibble() %>%
    tidyr::unnest_wider(col = c("columns", "foreignKeys")) %>%
    janitor::clean_names("snake") %>%
    tidyr::unnest(col = tidyselect::where(function(x) is.list(x))) %>%
    dplyr::select(-c("columnReference")) %>%
    dplyr::mutate(
      dplyr::across(
        .cols = c(name, primary_key, column_reference),
        .fns = ~ janitor::make_clean_names(
          .,
          case = "snake",
          allow_dupes = TRUE
        )
      )
    )

  return(results)
}

#' Download and extract EPC schema data
#'
#' Fetches schema information for Energy Performance Certificate (EPC) data from
#' the Open Data Communities API. Downloads the specified dataset type, extracts
#' the schema.json file, and processes it into a tidy tabular format.
#'
#' @param type `character` string specifying the type of EPC data. Must be one of:
#'   - "domestic": Domestic EPC data
#'   - "non_domestic": Non-domestic EPC data
#'   - "display": Display Energy Certificate data
#' @param resource `character` string specifying the resource type to extract from
#'   the schema. Must be either "certificate" or "recommendation".
#'
#' @return A tibble containing the processed schema information for the requested
#'   resource type.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get schema for domestic certificates
#' schema_domestic_cert <- odc_get_schema("domestic", "certificate")
#'
#' # Get schema for non-domestic recommendations
#' schema_nondomestic_rec <- odc_get_schema("non_domestic", "recommendation")
#'
#' # View the resulting schema structure
#' print(schema_domestic_cert)
#' colnames(schema_domestic_cert)
#' }
odc_get_schema <- function(
  type = c("domestic", "non_domestic", "display"),
  resource = c("certificate", "recommendation")
) {
  type <- rlang::arg_match(type)
  resource <- rlang::arg_match(resource)

  file_name <-
    switch(
      type,
      "domestic" = "domestic-2025-10.zip",
      "non_domestic" = "non-domestic-2025-10.zip",
      "display" = "display-2025-10.zip"
    )

  temp_dir <- tempdir()
  dir.create(temp_dir, showWarnings = FALSE)
  zip_path <- file.path(temp_dir, basename(file_name))

  req <-
    httr2::request("https://epc.opendatacommunities.org/api/v1/files/") %>%
    httr2::req_url_path_append(file_name) %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      Authorization = paste("Basic", odc_get_key())
    )

  resp <- try_catch_response(req, path = zip_path)

  cli::cli_process_start("Start parsing the schema to tabular format")

  to_unzip <- "schema.json"
  files_in_zip <- unzip(zip_path, list = TRUE)$Name

  if (!(to_unzip %in% files_in_zip)) {
    cli::cli_abort(c(
      "The requested file '{to_unzip}' was not found in the archive '{file_name}'.",
      "i" = "Available files are: {paste(files_in_zip, collapse = ', ')}"
    ))
  }

  utils::unzip(zip_path, to_unzip, exdir = temp_dir)

  raw_schema <- jsonlite::fromJSON(file.path(temp_dir, to_unzip))

  clean_schema <- extract_schema(raw_schema, resource = resource)

  unlink(temp_dir)

  cli::cli_process_done()

  return(clean_schema)
}
