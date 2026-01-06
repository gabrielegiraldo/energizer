test_that("odc_get_schema returns expected output", {
  withr::with_envvar(
    new = c(
      "ODC_API_KEY" = ""
    ),
    {
      odc_set_key(Sys.getenv("ODC_USERNAME"), Sys.getenv("ODC_PW"))
      results <- suppressMessages(odc_get_schema("domestic", "certificate"))
      is.tibble <- tibble::is_tibble(results)
      expect_true(is.tibble)
    }
  )
})
