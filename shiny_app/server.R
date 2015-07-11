library(dplyr)
library(treemap)
library(lazyeval)
library(RColorBrewer)
# setwd('~/Documents/__NYC_DSA/Dev/EsztiS.github.io/shiny_app')
# library(shiny, treemap)

shinyServer(function(input, output) {
  
  output$plotr <- renderPlot({
    total = sum(receipts[input$r_year])
    treemap(receipts, 
            index = input$r_index, 
            vSize = input$r_year, 
            vColor = input$r_year, 
            palette = 'Greens',
            type = 'value',
            title = paste('TOTAL ', total, 'x 1000'))
  })
  
  newOut <- reactive({
    part1 = data.frame(table(outlays[input$o_index]))
    names(part1)[1] = input$o_index
    part2 = group_by_(outlays, .dots=as.symbol(input$o_index)) %>%
      summarise_(., total = interp(~sum(var), var = as.name(input$o_year)))
    outlay2 = inner_join(part1,part2,by=input$o_index)
  })
  
  output$category_names <- renderPrint({
    outlay3 = newOut()[newOut()$total != 0, ]
  })
  
  output$ploto <- renderPlot({
    outlay3 = newOut()[newOut()$total != 0, ]
    total = sum(outlay3$total)
    treemap(outlay3, 
            index=input$o_index, 
            vSize='Freq', 
            vColor='total', 
            type='value',
            title = paste('TOTAL ', total, 'x 1000'))
  })
  
  newBud <- reactive({
    part1 = data.frame(table(budauth[input$b_index]))
    names(part1)[1] = input$b_index
    part2 = group_by_(budauth, .dots=as.symbol(input$b_index)) %>%
      summarise_(., total = interp(~sum(var), var = as.name(input$b_year)))
    budauth2 = inner_join(part1,part2,by=input$b_index)
  })
  
  output$plotb <- renderPlot({
    budauth3 = newBud()[newBud()$total != 0, ]
    total = sum(budauth3$total)
    treemap(budauth3, 
            index=input$b_index, 
            vSize='Freq', 
            vColor='total', 
            type='value',
            title = paste('TOTAL', total, 'x 1000'))
  })
  
})
