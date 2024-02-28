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
          textAreaInput(ns("chat"), "Chat", height = "300px"),
          actionButton(ns("submit"), "Submit")
        ),
        fluidRow(
          # includeMarkdown(md_file)
          uiOutput(ns("file_content"))
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

    observeEvent(input$submit, {
      print("Submit!")
      writeLines(input$chat, md_file)
    })

    output$file_content <- renderUI({
      invalidateLater(500)
      includeMarkdown(md_file)
    })
  })
}

## To be copied in the UI
# mod_streamWindow_ui("streamWindow_1")

## To be copied in the server
# mod_streamWindow_server("streamWindow_1")