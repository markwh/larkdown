#' Utility function to generate a random number
#'
#' @return A random number between 0 and 1
generate_random_number <- function() {
  return(runif(1))
}

#' Utility function to format a date
#'
#' @param date The date to format
#' @return The formatted date
format_date <- function(date) {
  return(format(date, "%Y-%m-%d"))
}