# Functions for interacting with Rstudio

#' Parse the current document and stream response back to it
#' 
#' @importFrom reticulate import
stream_current <- function(endpoint_url=getOption("ld_endpoint_url"),
                           prompt = getOption("ld_prompt", default = "@")) { 
  ld <- import_larkdown()
  langserve <- import("langserve")

  stream_path <- current_document()
  doc_text <- paste(readLines(stream_path), collapse = "\n")
  ld_messages <- ld$parse_larkdown(doc_text, prompt)

  endpoint <- langserve$RemoteRunnable(endpoint_url)
  rstudioapi::documentSave()
  ld$stream_to_file(messages = ld_messages, 
                    endpoint = endpoint, 
                    file = stream_path)
}

knit_and_stream_current <- function(endpoint_url = getOption("ld_endpoint_url"), 
                                    prompt = getOption("ld_prompt", default = "@")) {
  ld <- import_larkdown()
  langserve <- import("langserve")
  
  infile <- current_document()
  
  ld_messages <- knit_to_messages(infile, prompt = prompt)
  endpoint <- langserve$RemoteRunnable(endpoint_url)
  ld$stream_to_file(messages = ld_messages, endpoint = endpoint, file = infile)
}

#' Returns the result of calling `lardkown.parse_larkdown()` on the specified file
#' 
#' @param file defaults to `current_document()`
knit_to_messages <- function(file = current_document(),
                             prompt = getOption("ld_prompt", default = "@")) {
  
  ld <- import_larkdown()
  
  # render current document to tempfile md
  outfile <- tempfile(fileext = ".md")
  knitr::knit(file, outfile)
  
  # parse messages
  doc_text <- paste(readLines(outfile), collapse = "\n")
  ld_messages <- ld$parse_larkdown(doc_text, prompt)
  
  ld_messages
}


