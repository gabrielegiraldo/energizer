#' Retrieve API metadata and information
#'
#' @description
#' `odc_get_meta()` fetches metadata and server information from the Open Data
#' Communities API. This endpoint provides information about the API service,
#' including version details, available endpoints, and other server metadata.
#'
#' Unlike other functions in this package, this endpoint does not require
#' authentication.
#'
#' @return
#' A list containing the parsed JSON response from the API info endpoint.
#' Common fields in the response include:
#' \describe{
#'   \item{`latestDate`}{Date of the most recent available certificate in the
#'         database. Format: `YYYY-MM-DD`.}
#'   \item{`updatedDate`}{Date when the site or database was last updated.
#'         Format: `YYYY-MM-DD`.}
#' }
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Get API metadata
#' meta <- odc_get_meta()
#'
#' # Check the most recent certificate date
#' print(meta$latestDate)
#'
#' # Check when the data was last updated
#' print(meta$updatedDate)
#' }
odc_get_meta <- function() {
  req <-
    httr2::request("https://epc.opendatacommunities.org/api/v1/info") %>%
    httr2::req_method("GET") %>%
    httr2::req_headers(
      accept = "application/json",
    )

  resp <- try_catch_response(req)

  results <- httr2::resp_body_json(resp)

  return(results)
}
