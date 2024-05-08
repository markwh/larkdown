# R/utils.R
# Utilty functions

#' Launches a journaling session for the current day. 
#' 
#' @export
journal <- function(base_path = Sys.getenv("LARKDOWN_DIR")) {

  filename <- file.path(base_path,
                        sprintf("notebook%s.Rmd", format(Sys.Date(), "%Y%m%d")))
  if (file.exists(filename)) {
    rstudioapi::documentOpen(filename)
  } else {
    new_larkdown(filename, template = "larkdown-journal", package = "larkdown")
  }
  return(TRUE)
}

#' Creates a new Rmarkdown file with a Larkdown template, then opens the file
#'
#' @export
new_larkdown <- function(filename = ts_filename(prefix = "larkdown"), 
                         template="larkdown-file", package = "larkdown") {
  
  rmarkdown::draft(filename, template = template, package = package, edit = FALSE)
  rstudioapi::documentOpen(filename)
}

#' Wrapper for `reticulate::import_from_path()` to pull in larkdown module
#' 
#' @export
import_larkdown <- function() {
  reticulate::import_from_path(
    module = "larkdown",
    path = system.file("pysrc", package = "larkdown", mustWork = TRUE), 
    delay_load = TRUE)
}

#' Sets the `ld_endpoint_url` option
#'
#' @export
register_endpoint <- function(endpoint_url) {
  options(ld_endpoint_url = endpoint_url)
}

#' Timestamp filename creator
#'
#' @export
ts_filename <- function(prefix = "", suffix = "", ext = ".Rmd") {
  basename <- format(Sys.time(), "%Y%m%d_%H%M%S")
  out <- paste0(prefix, basename, suffix, ext)
  out
}

#' Returns the full path of the current document, saving it first.
#' 
#' @export
current_document <- function() {
  rstudioapi::documentSave()
  doccontext <- rstudioapi::getActiveDocumentContext()
  out <- normalizePath(doccontext$path)
  out
}
