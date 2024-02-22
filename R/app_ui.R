library(shiny)

app_ui <- function(request) {
  fluidPage(
    # Add UI elements here
    # For example, a title panel and a sidebar layout
    titlePanel("My Shiny App"),
    sidebarLayout(
      sidebarPanel(
        # Add input controls here
        # For example, a numeric input
        numericInput("num", "Enter a number:", value = 1)
      ),
      mainPanel(
        # Add output elements here
        # For example, a text output
        # textOutput("result")
        mod_streamWindow_ui("streamWindow_1", "README.md")
        
      )
    )
  )
}