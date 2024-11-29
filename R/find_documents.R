#' Convert datetime to Eastern Time
#'
#' @param datetime A POSIXct or Date object to be converted.
#' @return A POSIXct object in Eastern Time.
convert_to_eastern <- function(datetime) {
  as.POSIXct(datetime, tz = "America/New_York")
}

#' Extract timestamp from a filename
#'
#' @param filename A character string representing the filename.
#' @return A POSIXct object if a timestamp is found, otherwise NULL.
extract_timestamp <- function(filename) {
  timestamp_pattern <- "\\d{8}_\\d{6}"
  matches <- regmatches(filename, regexpr(timestamp_pattern, filename))
  if (length(matches) > 0) {
    return(as.POSIXct(matches, format = "%Y%m%d_%H%M%S", tz = "America/New_York"))
  }
  return(NULL)
}

#' Check if a document is within a given time range
#'
#' @param doc_time A POSIXct object representing the document timestamp.
#' @param start, end POSIXct objects defining the range.
#' @return TRUE if the document is within the range, otherwise FALSE.
is_doc_in_range <- function(doc_time, start, end) {
  !is.null(doc_time) && doc_time >= start && doc_time <= end
}

#' Extract date from a journal filename
#'
#' @param filename A character string representing the filename.
#' @return A Date object if a date is found, otherwise NULL.
extract_journal_date <- function(filename) {
  journal_pattern <- "notebook\\d{8}\\.Rmd"
  if (grepl(journal_pattern, filename)) {
    date_match <- regmatches(filename, regexpr("\\d{8}", filename))
    return(as.Date(date_match, format = "%Y%m%d"))
  }
  return(NULL)
}

#' Get journal documents in a specified date range
#'
#' @param start_date, end_date Date objects defining the range.
#' @param root_dir Directory holding the documents.
#' @return A character vector of basenames for journal documents within the range.
get_journals_in_range <- function(start_date, end_date, root_dir) {
  all_docs <- list.files(root_dir, full.names = TRUE)
  
  # Use purrr::map_chr to apply the filter function for journal documents
  journal_docs <- purrr::map_chr(all_docs, filter_journal_docs, start_date, end_date)
  
  # Remove any empty strings from the result
  journal_docs <- journal_docs[journal_docs != ""]
  
  return(journal_docs)
}

#' Check and return timestamped documents within range
#'
#' @param doc A character string representing the document filename.
#' @param start, end POSIXct objects defining the range.
#' @return The basename of the document if it is within the range, otherwise an empty string.
filter_timestamped_docs <- function(doc, start, end) {
  doc_time <- extract_timestamp(doc)
  if (is_doc_in_range(doc_time, start, end)) {
    return(basename(doc))
  }
  return("")
}

#' Check and return journal documents within range
#'
#' @param doc A character string representing the document filename.
#' @param start_date, end_date Date objects defining the range.
#' @return The basename of the document if it is within the range, otherwise NULL.
filter_journal_docs <- function(doc, start_date, end_date) {
  journal_date <- extract_journal_date(doc)
  if (!is.null(journal_date) && 
      journal_date >= start_date && 
      journal_date <= end_date) {
    return(basename(doc))
  }
  return("")
}



#' Returns a vector with all documents that have a timestamped file name or daily journal
#'
#' @param start, end POSIXct objects defining the range.
#' @param root_dir Directory holding the documents.
#' @param include_daily Logical indicating whether to include daily journals.
#' @return A vector of basenames for documents within the range.
#' @export
get_documents_in_range <- function(start, end = lubridate::now(), 
                                   root_dir = Sys.getenv("LARKDOWN_DIR"),
                                   include_daily = TRUE) {
  
  start <- convert_to_eastern(start)
  end <- convert_to_eastern(end)
  
  all_docs <- list.files(root_dir, full.names = TRUE)
  
  # Use purrr::map_chr to apply the filter function for timestamped documents
  docs_in_range <- purrr::map_chr(all_docs, filter_timestamped_docs, start, end)
  
  # Remove any empty strings from the result
  docs_in_range <- docs_in_range[docs_in_range != ""]
  
  if (include_daily) {
    # Get journal documents within the date range
    journal_docs <- get_journals_in_range(as.Date(start), as.Date(end), root_dir)
    docs_in_range <- c(docs_in_range, journal_docs)
  }
  
  return(docs_in_range)
}