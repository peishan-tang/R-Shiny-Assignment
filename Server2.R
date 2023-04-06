library(shiny)
library(readr)

server = function(input, output){
  
  data = reactive({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  factors = reactive({
    factor_table = data.frame(
      Loss_Year = unique(data()$Loss_Year),
      Dev1 = NA,
      Dev2 = NA,
      Dev3 = NA,
      Dev4 = NA
    )
    
    for (i in 1:length(unique(data$Loss_Year))) {
      factor_table$Dev1[i] = sum(
        data$Amount_of_Claims_Paid[
          data$Loss_Year == unique(data$Loss_Year)[i] &
            data$Development_Year == 1
        ],
        na.rm = TRUE
      )
    }
    
    for (i in 1:length(unique(data$Loss_Year))) {
      factor_table$Dev2[i] = sum(
        data$Amount_of_Claims_Paid[
          data$Loss_Year == unique(data$Loss_Year)[i] &
            data$Development_Year == 2 &
            data$Development_Year == tail(factor_table$Dev2,1) + i-1
        ], na.rm = TRUE)
    }
    
    for (i in 1:length(unique(data$Loss_Year))) {
      if(unique(data$Loss_Year)[i] == max(unique(data$Loss_Year))){
        factor_table$Dev3[i] = sum(
          data$Amount_of_Claims_Paid[
            data$Loss_Year == unique(data$Loss_Year)[i] &
              data$Development_Year == 3 &
              data$Development_Year == tail(factor_table$Dev3,1) + 1
          ], na.rm = TRUE)
      } else{
        factor_table$Dev[i] = factor_table$Dev2[i+1]*input$tail_factor/factor_table$Dev2[i]
      }
    }
    
    for (i in 1:length(unique(data$Loss_Year))) {
      if(unique(data$Loss_Year)[i] == max(unique(data$Loss_Year))){
        factor_table$Dev4[i] = factor_table$Dev3[i]*input$tail_factor
      } else{
        factor_table$Dev4[i] = factor_table$Dev3[i+1]*factor_table$Dev2[i+1]/factor_table$Dev2[i]
      }
    }
    
    factor_table
  })
  
  output$output_table = renderTable({factors()})
}


shinyApp(ui, server)