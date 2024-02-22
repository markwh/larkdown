#' Run the Shiny Application
#'
#' @export
run_app <- function() {
  shiny::runApp(
    appDir = system.file("app", package = "shinystream"),
    display.mode = "normal"
  )
}
