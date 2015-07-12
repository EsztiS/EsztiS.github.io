library(dplyr)
library(treemap)
library(lazyeval)
library(RColorBrewer)
library(ggplot2)
# setwd('~/Documents/__NYC_DSA/Dev/EsztiS.github.io/shiny_app')
# library(shiny)
# IMPROVEMENTS:
# 1. have receipts, outlays and budget authority in variable dependent
# on current tab chosen.
# 2. print $amounts with commas.
# 3. get rid of X in front of years

shinyServer(function(input, output, session) {
  
  # Plotting treemap of receipts. (Area and Color) = $ amount.
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
  # Dynamic UI input for selecting subcategories to plot.======
  observe({
    pane <- input$r_index
    # Select input =============================================
    # Create a list of subcategories, where the name of the items
    # is the row and the values are the row contents.
    s_options <- list()
    s_options[[ paste(1:length(receipts[pane]))]] <- 
      unique(receipts[pane])
    
    # Select items. With multi-select, can chose >1.============
    updateSelectInput(session, "inSelect",
                      choices = s_options,
                      selected = s_options
    )
  print(class(input$inSelect))
  print(input$inSelect)
    output$plotr_yrs <- renderPlot({
      y = colSums(receipts[(receipts[ ,pane] == input$inSelect), r_years])
      qplot(1:length(y), y, 
            main = input$inSelect,
            xlab = 'Year',
            ylab = 'USD in $1000s',
            colour = I('blue'),
            shape = I(17),
            geom = c('point','line')) +
        theme_bw() +
        scale_x_discrete(
          breaks = seq(1,length(y),5), 
          labels = names(receipts[r_years[seq(1,length(y),5)]])
        )
    })
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
