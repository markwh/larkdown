#' Utility function to generate a random number
#'
#' @return A random number between 0 and 1
generate_random_number <- function() {
  return(runif(1))
}

#' Utility function to format a date
#'
#' @param date The date to format
#' @return The formatted date
format_date <- function(date) {
  return(format(date, "%Y-%m-%d"))
}

# TODO: make an Rmarkdown template for notebook files
#' @export
boot_up <- function(base_path = Sys.getenv("NOTEBOOK_DIR")) {

  filename <- file.path(base_path,
                        sprintf("notebook%s.Rmd", format(Sys.Date(), "%Y%m%d")))
  if (!file.exists(filename)) file.create(filename)
  rstudioapi::documentOpen(filename)
}

#' @export
import_larkdown <- function() {
  reticulate::import_from_path(module = "larkdown",
                               path = system.file("pysrc", package = "shinystream", mustWork = TRUE))
}


