# R/utils.R
# Utilty functions


#' Wrapper for `reticulate::import_from_path()` to pull in larkdown module
#' 
#' @export
import_larkdown <- function() {
  ld <- reticulate::import_from_path(
    module = "larkdown",
    path = system.file("pysrc", package = "larkdown", mustWork = TRUE), 
    delay_load = TRUE)
  ld$larkdown
}

#' Sets the `ld_endpoint_url` option
#'
#' @param endpoint_url url of larkdown langserve endpoint
#' 
#' @export
register_endpoint <- function(endpoint_url) {
  options(ld_endpoint_url = endpoint_url)
}

#' Sets larkdown endpoint url options.
#'
#' @param root_url url of larkdown langserve project root
#' 
#' @export
ld_register_endpoints <- function(root_url) {
  options(ld_endpoint_url = paste0(root_url, "/larkdown-chat"),
          chaz_endpoint_url = paste0(root_url, "/chaz"),
          ld_search_endpoint_url = paste0(root_url, "/ld_search"))
}

#' Timestamp filename creator
#'
#' @param prefix,suffix,ext appended to the timestamp to create the filename
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

