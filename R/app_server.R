#' @import shiny
app_server <- function(input, output, session) {

  MD_FILE = get_golem_options("md_file")
  if (!file.exists(MD_FILE)) file.create(MD_FILE)
  ENDPOINT_URL = get_golem_options("endpoint_url")
  mod_streamWindow_server("streamWindow_1",
                          md_file = MD_FILE,
                          endpoint_url = ENDPOINT_URL)

}
