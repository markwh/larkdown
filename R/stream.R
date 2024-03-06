# Functions for interacting with Rstudio

#' Parse the current document and stream response back to it
#' 
#' @importFrom reticulate import
ld_stream_current <- function() { # Possible naming convention?
  ld <- import_larkdown()
  langserve <- import("langserve")

  doccontext <- rstudioapi::getActiveDocumentContext()
  stream_path <- normalizePath(doccontext$path)
  doc_text <- paste(readLines(stream_path), collapse = "\n")
  ld_messages <- ld$parse_larkdown(doc_text)

  endpoint <- langserve$RemoteRunnable(getOption("ld_endpoint_url"))
  rstudioapi::documentSave()
  ld$stream_to_file(messages = ld_messages, endpoint = endpoint, file = stream_path)
}
