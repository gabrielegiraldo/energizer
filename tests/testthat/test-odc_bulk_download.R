test_that("odc_file_request works as intended", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
    quietly(odc_set_key(
      Sys.getenv("ODC_USERNAME"),
      Sys.getenv("ODC_PW")
    ))
    quietly(req_status <- odc_file_request()$status)
    expect_identical(req_status, 200L)
  })
})

test_that("odc_get_file_list returns non-empty tibble", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
    quietly(odc_set_key(
      Sys.getenv("ODC_USERNAME"),
      Sys.getenv("ODC_PW")
    ))
    quietly(res <- odc_get_file_list())
    expect(nrow(res) > 0, "odc_get_file_list returns empty tibble")
  })
})

test_that("odc_get_file returns non-empty tibble", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
    quietly(odc_set_key(
      Sys.getenv("ODC_USERNAME"),
      Sys.getenv("ODC_PW")
    ))
    quietly(res <- odc_get_file(local_authority_code = "E08000025"))
    expect(nrow(res) > 0, "odc_get_file_list returns empty tibble")
  })
})

test_that("odc_bulk_download returns message", {
  withr::with_envvar(c("ODC_API_KEY" = ""), {
    quietly(odc_set_key(
      Sys.getenv("ODC_USERNAME"),
      Sys.getenv("ODC_PW")
    ))
    file_name <- "non-domestic-E08000025-Birmingham.zip"
    expect_message(
      odc_bulk_download(
        file_name = file_name,
        destination_path = tempdir()
      )
    )
  })
})
