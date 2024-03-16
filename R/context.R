# context.R
# Functions for bringing data in to LLM context

#' Return text of a file
file_text <- function(path){
  path <- normalizePath(path)
  out <- paste(readLines(path), collapse = "\n")
  out
}


#' Return text of files for all files in a directory
#' @param path Path to directory
dir_text <- function(path, pattern = ".*"){
  path <- normalizePath(path)
  files <- list.files(path, pattern = pattern, full.names = TRUE)

  file_names <- gsub(path, "", files)

  file_text_vec <- purrr::map_chr(files, file_text)

  # collapse these using a template
  templ_string <- "## File: %s\n\n%s\n\n"
  out_vec <- sprintf(templ_string, file_names, file_text_vec)
  out <- paste(out_vec, collapse = "\n")
  out
}

