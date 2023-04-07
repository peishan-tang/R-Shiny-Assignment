library(shiny)

ui = fluidPage(
  titlePanel("Input Data"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Please Upload CSV File", accept = c(".csv")),
      numericInput("tail_factor", "Tail Factor", value = 1.1, min = 0, step = 0.1)
),

mainPanel(
  tabsetPanel(
    tabPanel("Input Data", tableOutput(outputId = "data_table")),
    tabPanel("Factor Table", tableOutput(outputId = "output_table")),
    tabPanel("Cumulative Plot", plotOutput(outputId = "cumulative_plot"))
  ))))



