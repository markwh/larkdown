
#' Returns a list of `description` and `prompt` and optionally creates a new
#'  larkdown file.
#'  
#' @param input Request for a persona to generate
#' @param file if not NULL, create
#' @export
chaz_persona <- function(input, 
                         file = NULL, 
                         open = !is.null(file),
                         endpoint_url = getOption("chaz_endpoint_url", default = "")) {
  
  if (endpoint_url == "") stop("Please set the `chaz_endpoint_url` option or ", 
                               "provide an `enpoint_url` manually.")
  
  ls <- reticulate::import("langserve")
  rr <- ls$RemoteRunnable(url=endpoint_url)
  
  chaz_output <- rr$invoke(list(user_input=input))
  
  if (is.character(file)) {
    new_larkdown(file, 
                 system_message = chaz_output$prompt, 
                 header_text = chaz_output$description,
                 open = open)
    return(invisible(chaz_output))
  } else {
    return(chaz_output)
  }
}
