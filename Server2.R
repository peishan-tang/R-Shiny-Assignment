
library(shiny)
library(readr)
library(ggplot2)

server = function(input, output){
  
  tail_factor = reactive(input$tail_factor)
  data = reactive ({
    req(input$file)
    read.csv(input$file$datapath)
  })
  
  base_year = reactive({
    min(data()$Loss_Year)
  })
  
  factors = reactive ({
    factor_table = data.frame(
      Loss_Year = unique(data()$Loss_Year),
      Dev1 = NA,
      Dev2 = NA,
      Dev3 = NA,
      Dev4 = NA
    )
    
    for (i in 1:nrow(factor_table)) {
      lossyear = factor_table$Loss_Year[i]
      dev1 = sum(data()$Amount_of_Claims_Paid[data()$Loss_Year == lossyear & data()$Development_Year == 1])
      dev2 = sum(data()$Amount_of_Claims_Paid[data()$Loss_Year == lossyear & data()$Development_Year %in% c(1,2)])
      dev3 = sum(data()$Amount_of_Claims_Paid[data()$Loss_Year == lossyear & data()$Development_Year %in% c(1,2,3)])
      dev4 = sum(data()$Amount_of_Claims_Paid[data()$Loss_Year == lossyear & data()$Development_Year %in% c(1,2,3,4)])
      
      factor_table[i, c("Dev1", "Dev2", "Dev3", "Dev4")] = c(dev1, dev2, dev3, dev4)
    }
    
    factor_table$Dev2[factor_table$Loss_Year == base_year() + 2] = 
      (sum(factor_table$Dev2[factor_table$Loss_Year %in% c(base_year(), base_year() + 1)]) / 
         sum(factor_table$Dev1[factor_table$Loss_Year %in% c(base_year(), base_year() + 1)])) *
      factor_table$Dev1[factor_table$Loss_Year == base_year() + 2]
    
    factor_table$Dev3[factor_table$Loss_Year == (base_year() + 1)] = 
      (sum(factor_table$Dev3[factor_table$Loss_Year == base_year()]) / 
         sum(factor_table$Dev2[factor_table$Loss_Year == base_year()])) *
      factor_table$Dev2[factor_table$Loss_Year == (base_year() + 1)]
    
    factor_table$Dev3[factor_table$Loss_Year == base_year() + 2] = 
      (sum(factor_table$Dev3[factor_table$Loss_Year %in% c(base_year(), base_year() + 1)]) / 
         sum(factor_table$Dev2[factor_table$Loss_Year %in% c(base_year(), base_year() + 1)])) *
      factor_table$Dev2[factor_table$Loss_Year == (base_year() + 2)]
    
    factor_table$Dev4[factor_table$Loss_Year == base_year()] = factor_table$Dev3[factor_table$Loss_Year == base_year()] * tail_factor()
    factor_table$Dev4[factor_table$Loss_Year == (base_year() + 1)] = factor_table$Dev3[factor_table$Loss_Year == (base_year() + 1)] * tail_factor()
    factor_table$Dev4[factor_table$Loss_Year == (base_year() + 2)] = factor_table$Dev3[factor_table$Loss_Year == (base_year() + 2)] * tail_factor()
    
    return(factor_table)  
  })
  
  output$output_table = renderTable({
    factors()})
  output$data_table = renderTable({
    data()})
  output$plot = renderPlot({
    ggplot(factors(), aes(x = factors()$factor_table, y = Cumulative_Paid_Claims, 
                                    group = Loss_Year, color = as.factor(Loss_Year),
                                    label = format(Dev4, big.mark = ","))) +
      geom_point(size = 3) +
      geom_line() + 
      labs(title = "Cumulative Paid Claims and Projections by Development Year",
           x = "Development Year", y = "Cumulative Paid Claims") +
      scale_color_manual(name = "Loss Year", values = c("orange", "blue", "maroon"))
      scale_y_continuous(limits = c(500000, 1500000)) +
      theme_bw()
  })
  
  
 } 

shinyApp(ui, server)
    