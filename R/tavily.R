# Functions for working with tavily search

#' Wrapper around langchain TavilySearchResults
#' 
#' Returns a list of search results
#' 
#' @param text search string
#' @param max_results,search_depth,include_anser,include_raw_content,include_raw_images passed to TavilySearchResults
#' @export
tavily_search <- function(text,
                          max_results=5,
                          search_depth="advanced",
                          include_answer=TRUE,
                          include_raw_content=TRUE,
                          include_images=TRUE) {
  
  lcc <- reticulate::import("langchain_community")
  
  tool <- lcc$tools$TavilySearchResults(
    max_results = max_results, 
    search_depth = search_depth,
    include_answer = include_answer,
    include_raw_content = include_raw_content,
    include_images = include_images
  )
  
  out <- tool$invoke(text)
  out
}