quietly <- function(code) {
  withr::local_options(list(
    cli.dynamic = FALSE,
    crayon.enabled = FALSE # Disables ANSI colors, often used by cli messages
  ))
  suppressMessages({
    force(code)
  })
}
