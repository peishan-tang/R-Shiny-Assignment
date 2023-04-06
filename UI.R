library(shiny)

ui = fluidPage(
  titlePanel("Cumulative Paid Claims($)"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Please Upload CSV File", accept = ".csv"),
      numericInput("tail_factor", "Tail Factor", value = 1.1, min = 0, step = 0.1),
),

mainPanel(
  tableOutput(outputId = "table")
    )
  )
)