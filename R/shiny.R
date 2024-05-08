# Functions for working with Shiny apps
# Uses golem conventions


#' Run the Shiny Application
#'
#' @param ... arguments to pass to golem_opts.
#' See `?golem::get_golem_options` for more details.
#' @inheritParams shiny::shinyApp
#'
#' @export
#' @importFrom shiny shinyApp
#' @importFrom golem with_golem_options
run_app <- function(
    md_file,
    endpoint_url,
    onStart = NULL,
    options = list(),
    enableBookmarking = NULL,
    uiPattern = "/",
    ...
) {
  with_golem_options(
    app = shinyApp(
      ui = app_ui,
      server = app_server,
      onStart = onStart,
      options = options,
      enableBookmarking = enableBookmarking,
      uiPattern = uiPattern
    ),
    golem_opts = list(md_file = md_file,
                      endpoint_url = endpoint_url,
                      ...)
  )
}


#' UI for shiny app
app_ui <- function(request) {
  fluidPage(
    # Add UI elements here
    # For example, a title panel and a sidebar layout
    # titlePanel("My Shiny App"),
    sidebarLayout(
      sidebarPanel(
      ),
      mainPanel(
        # Add output elements here
        # For example, a text output
        # textOutput("result")
        mod_streamWindow_ui("streamWindow_1", md_file = get_golem_options("md_file"))

      )
    )
  )
}


#' Server for shiny app
#' @import shiny
app_server <- function(input, output, session) {
  
  MD_FILE = get_golem_options("md_file")
  if (!file.exists(MD_FILE)) file.create(MD_FILE)
  ENDPOINT_URL = get_golem_options("endpoint_url")
  mod_streamWindow_server("streamWindow_1",
                          md_file = MD_FILE,
                          endpoint_url = ENDPOINT_URL)
  
}



# app_config.R ------------------------------------------------------------

#' Access files in the current app
#'
#' NOTE: If you manually change your package name in the DESCRIPTION,
#' don't forget to change it here too, and in the config file.
#' For a safer name change mechanism, use the `golem::set_golem_name()` function.
#'
#' @param ... character vectors, specifying subdirectory and file(s)
#' within your package. The default, none, returns the root of the app.
#'
#' @noRd
app_sys <- function(...) {
  system.file(..., package = "larkdown")
}


#' Read App Config
#'
#' @param value Value to retrieve from the config file.
#' @param config GOLEM_CONFIG_ACTIVE value. If unset, R_CONFIG_ACTIVE.
#' If unset, "default".
#' @param use_parent Logical, scan the parent directory for config file.
#' @param file Location of the config file
#'
#' @noRd
get_golem_config <- function(
    value,
    config = Sys.getenv(
      "GOLEM_CONFIG_ACTIVE",
      Sys.getenv(
        "R_CONFIG_ACTIVE",
        "default"
      )
    ),
    use_parent = TRUE,
    # Modify this if your config file is somewhere else
    file = app_sys("golem-config.yml")
) {
  config::get(
    value = value,
    config = config,
    file = file,
    use_parent = use_parent
  )
}
