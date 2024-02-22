#' streamWindow UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_streamWindow_ui <- function(id, md_file) {
  ns <- NS(id)
  tagList(
    tabsetPanel(
      tabPanel("GUI",
        fluidRow(
          includeMarkdown(md_file)
        )
      )
    )
      
  )
}
    
#' streamWindow Server Functions
#'
#' @noRd 
mod_streamWindow_server <- function(id, md_file){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
 
  })
}
    
## To be copied in the UI
# mod_streamWindow_ui("streamWindow_1")
    
## To be copied in the server
# mod_streamWindow_server("streamWindow_1")
