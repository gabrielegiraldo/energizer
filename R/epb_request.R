.epb_default_base_url <-
  "https://api.get-energy-performance-data.communities.gov.uk"

epb_base_url <- function() {
  base_url <- Sys.getenv("EPB_BASE_URL")
  if (!nzchar(base_url)) {
    base_url <- getOption("energizer.base_url", .epb_default_base_url)
  }

  if (!rlang::is_string(base_url) || !nzchar(trimws(base_url))) {
    cli::cli_abort("Energy Performance API base URL must be a non-empty string.")
  }

  sub("/+$", "", trimws(base_url))
}

epb_request <- function(path, query = list(), auth = TRUE) {
  if (!rlang::is_string(path) || !nzchar(path)) {
    cli::cli_abort("{.arg path} must be a non-empty character string.")
  }

  if (!is.list(query) || (length(query) > 0L && is.null(names(query)))) {
    cli::cli_abort("{.arg query} must be a named list.")
  }

  request <-
    httr2::request(epb_base_url()) |>
    httr2::req_url_path_append(sub("^/+", "", path)) |>
    httr2::req_method("GET") |>
    httr2::req_headers(Accept = "application/json")

  if (auth) {
    request <- httr2::req_headers(
      request,
      Authorization = paste("Bearer", epb_get_token())
    )
  }

  if (length(query) > 0L) {
    request <- rlang::exec(
      httr2::req_url_query,
      request,
      !!!query,
      .multi = "explode"
    )
  }

  request
}

epb_error_message <- function(response) {
  status <- httr2::resp_status(response)
  reason <- httr2::resp_status_desc(response)
  body <- tryCatch(
    httr2::resp_body_json(response, simplifyVector = TRUE),
    error = function(error) NULL
  )

  detail <- NULL
  if (is.list(body)) {
    detail <- body$message %||% body$error %||% body$detail
  }

  if (status == 429L) {
    return(paste0(
      "Energy Performance API request failed: 429 Too Many Requests. ",
      "Stop requests briefly before retrying."
    ))
  }

  message <- paste0("Energy Performance API request failed: ", status, " ", reason, ".")
  if (rlang::is_string(detail) && nzchar(detail)) {
    message <- paste(message, detail)
  }

  message
}

epb_perform <- function(request, path = NULL) {
  tryCatch(
    {
      cli::cli_process_start("Reading data from Energy Performance API")
      response <- httr2::req_perform(request, path = path)
      cli::cli_process_done()
      response
    },
    httr2_http = function(error) {
      cli::cli_process_failed()
      cli::cli_abort(epb_error_message(error$response), parent = error)
    },
    error = function(error) {
      cli::cli_process_failed()
      cli::cli_abort(
        "Energy Performance API request failed: {conditionMessage(error)}",
        parent = error
      )
    }
  )
}

epb_parse_response <- function(response) {
  body <- httr2::resp_body_json(response, simplifyVector = FALSE)

  if (!is.list(body) || is.null(body$data)) {
    cli::cli_abort("Energy Performance API response did not contain a {.field data} field.")
  }

  list(
    data = epb_data_to_tibble(body$data),
    pagination = body$pagination %||% NULL
  )
}

epb_data_to_tibble <- function(data) {
  if (is.null(data) || length(data) == 0L) {
    return(tibble::tibble())
  }

  if (is.atomic(data)) {
    return(tibble::tibble(value = data))
  }

  is_record <- !is.null(names(data)) && any(nzchar(names(data)))
  records <- if (is_record) list(data) else data

  if (!all(vapply(records, is.list, logical(1)))) {
    return(tibble::tibble(value = unlist(records, use.names = FALSE)))
  }

  result <- data.table::rbindlist(records, fill = TRUE)
  result <- tibble::as_tibble(result)

  if (ncol(result) > 0L) {
    result <- janitor::clean_names(result, case = "snake")
  }

  result
}

`%||%` <- function(left, right) {
  if (is.null(left)) right else left
}
