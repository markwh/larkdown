# context.R
# Functions for bringing data in to LLM context

#' Return text of a file
#' @param path Path to directory
#' @export
file_text <- function(path){
  path <- normalizePath(path)
  out <- paste(readLines(path), collapse = "\n")
  out
}


#' Return text of files for all files in a directory
#' @param path Path to directory
#' @importFrom purrr possibly
#' @export
dir_text <- function(path, pattern = ".*"){
  path <- normalizePath(path)
  files <- list.files(path, pattern = pattern, full.names = TRUE)
  
  file_names <- gsub(path, "", files)

  file_text_vec <- purrr::map_chr(files, possibly(~suppressWarnings(file_text(.)), 
                                                  otherwise = ""))

  # collapse these using a template
  templ_string <- "## File: %s\n\n%s\n\n"
  out_vec <- sprintf(templ_string, file_names, file_text_vec)
  out <- paste(out_vec, collapse = "\n")
  out
}

#' Return text of a youtube transcript
#' @param yt_url url of youtube video
#' @export
yt_text <- function(yt_url) {
  lcc <- reticulate::import("langchain_community")
  loader <- lcc$document_loaders$YoutubeLoader$from_youtube_url(yt_url, add_video_info = TRUE)
  yt_document <- loader$load()
  
  out <- yt_document[[1]]$page_content
  out
}

#' Returns a character vector (length 1) of concatenated message text
#' 
#' @param message_list list of BaseMessage objects
#' @export
messages_text <- function(message_list) {
  out_vec <- purrr::map_chr(message_list, ~.$pretty_repr())
  
  out <- paste(out_vec, collapse = "\n")
  out
}

#' Return token count and pricing for gpt-4 and gpt-3.5
#' 
#' @param input character string to pass as llm input. 
#' @param encoding passed to `tiktoken.get_encoding`
#' 
#' @export
count_tokens <- function(input, encoding = "cl100k_base") {
  tkt <- reticulate::import("tiktoken")
  enc <- tkt$get_encoding(encoding)
  
  n_token <- length(enc$encode(input))
  
  # prices might change over time--currently $10 per 1M tokens for gpt4, $0.5 for gpt3.5
  # See https://openai.com/api/pricing/
  cost_gpt35 <- n_token * 0.5 / 1e6
  cost_gpt4o <- n_token * 5 / 1e6
  
  out <- list(
    count = n_token,
    cost_gpt35 = cost_gpt35,
    cost_gpt4o = cost_gpt4o
  )
  
  out
}
