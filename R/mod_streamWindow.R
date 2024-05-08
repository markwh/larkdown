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
          # includeMarkdown(md_file)
          uiOutput(ns("file_content"))
        ),
        fluidRow(
          textAreaInput(ns("chat"), "Chat", height = "300px"),
          actionButton(ns("submit"), "Submit")
        )
      )
    )

  )
}

#' streamWindow Server Functions
#'
#' @noRd
mod_streamWindow_server <- function(id, md_file, endpoint_url){
  reticulate::py_none() # hack to make sure python session is initialized and path is set
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    observeEvent(input$submit, {
      print("Submit!")
      # writeLines(input$chat, md_file)

      pyfile <- system.file("pysrc/larkdown.py", package = "larkdown")
      cmdargs <- c(pyfile, md_file, endpoint_url)

      system2("python", cmdargs, wait = FALSE)

    })


    output$file_content <- renderUI({
      invalidateLater(500)
      includeMarkdown(md_file)
    })
  })
}

