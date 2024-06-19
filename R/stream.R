
#' Parse the current document and stream response back to it
#' 
#' @param endpoint_url endpoint of LangServe endpoint
#' @param prompt Larkdown prompt character
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

#' knit the current document, parse to messages, and stream from endpoint
#' 
#' @param endpoint_url endpoint of LangServe endpoint
#' @param prompt Larkdown prompt character
#' 
#' @export
knit_and_stream_current <- function(endpoint_url = getOption("ld_endpoint_url"), 
                                    prompt = getOption("ld_prompt", default = "@")
                                    ) {
  ld <- import_larkdown()
  langserve <- import("langserve")
  
  infile <- current_document()
  rstudioapi::documentClose()
  rstudioapi::executeCommand("activateConsole")
  
  ld_messages <- knit_to_messages(infile, prompt = prompt)
  endpoint <- langserve$RemoteRunnable(endpoint_url)
  
  pid <- sys::exec_background("tail", c("-f", infile), std_out = TRUE)
  ld$stream_to_file(messages = ld_messages, endpoint = endpoint, file = infile)
  
  rstudioapi::documentOpen(infile)
  tools::pskill(pid)
  # reopen_current_document()
  # blink()
}

#' Returns the result of calling `lardkown.parse_larkdown()` on the specified file
#' 
#' @param file defaults to `current_document()`
#' @param prompt Larkdown prompt character
#' 
#' @export
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


