#' Construct API URL for certificate type and endpoint
#'
#' @description
#' Internal for constructing the complete API URL for a given
#' certificate type and endpoint.
#'
#' @details
#' Key transformations performed:
#' 1. Converting underscores to hyphens in `type` (e.g., `"non_domestic"` becomes
#'    `"non-domestic"` in the URL)
#' 2. Pluralizing `"recommendation"` to `"recommendations"` in the endpoint path
#'
#' All valid combinations are defined in an internal look-up table.
#'
#' @param type `character` Type of certificate. Must be one of:
#'   `"domestic"`, `"non_domestic"`, or `"display"`.
#' @param endpoint `character`. API endpoint. Must be one of:
#'   `"certificate"`, `"recommendation"`, or `"search"`.
#'
#' @return `character` The complete API URL for the requested combination.
#'   Returns a zero-length character vector if the combination is not found
#'   (though `rlang::arg_match()` validation should prevent this).
#'
#' @noRd
#'
#' @examples
#' \dontrun{
#' # Internal usage examples:
#' get_api_url("domestic", "search")
#' # Returns: "https://epc.opendatacommunities.org/api/v1/domestic/search"
#'
#' get_api_url("non_domestic", "certificate")
#' # Returns: "https://epc.opendatacommunities.org/api/v1/non-domestic/certificate"
#'
#' get_api_url("display", "recommendation")
#' # Returns: "https://epc.opendatacommunities.org/api/v1/display/recommendations"
#' }
get_api_url <- function(
  type = c("domestic", "non_domestic", "display"),
  endpoint = c("certificate", "recommendation", "search")
) {
  type <- rlang::arg_match(type)
  type <- gsub("_", "-", type)

  endpoint <- rlang::arg_match(endpoint)

  dat <- tibble::tribble(
    ~cert_type     , ~endpoint_path   , ~base_url                                    ,
    "domestic"     , "search"         , "https://epc.opendatacommunities.org/api/v1" ,
    "domestic"     , "certificate"    , "https://epc.opendatacommunities.org/api/v1" ,
    "domestic"     , "recommendation" , "https://epc.opendatacommunities.org/api/v1" ,

    "non-domestic" , "search"         , "https://epc.opendatacommunities.org/api/v1" ,
    "non-domestic" , "certificate"    , "https://epc.opendatacommunities.org/api/v1" ,
    "non-domestic" , "recommendation" , "https://epc.opendatacommunities.org/api/v1" ,

    "display"      , "search"         , "https://epc.opendatacommunities.org/api/v1" ,
    "display"      , "certificate"    , "https://epc.opendatacommunities.org/api/v1" ,
    "display"      , "recommendation" , "https://epc.opendatacommunities.org/api/v1" ,
  )

  endpoint_url <-
    dat %>%
    dplyr::mutate(
      modified_endpoint_path = dplyr::case_when(
        endpoint_path == "recommendation" ~ "recommendations",
        TRUE ~ endpoint_path
      ),
      endpoint_url = paste(base_url, type, modified_endpoint_path, sep = "/")
    ) %>%
    dplyr::filter(
      cert_type == type & endpoint == endpoint_path
    ) %>%
    dplyr::pull(endpoint_url)

  return(endpoint_url)
}
