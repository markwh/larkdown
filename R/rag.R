# Functions for doing RAG of some for or other

#' RAG-over-larkdown function
#' 
#' Relies on a deployed langserve endpoint
#' 
#' @param input text input for searching
#' @param endpoint_url best to set this via `ld_register_endpoints()`.
#' 
#' @export
ld_search <- function(input, 
                      endpoint_url = getOption("ld_search_endpoint_url", default = "")) {
  
  if (endpoint_url == "") stop("Please set the `search_endpoint_url` option or ", 
                               "provide an `enpoint_url` manually.")
  
  ls <- reticulate::import("langserve")
  rr <- ls$RemoteRunnable(url=endpoint_url)
  
  out <- rr$invoke(input)
  
  out
}