shinyServer(function(input, output, session) {
  
  observe({
    pane <- input$chosen_pane

    # Select input =============================================
    # Create a list of subcategories, where the name of the items
    # is the row and the values are the row contents.
    s_options <- list()
    s_options[[ paste(1:length(receipts[pane]))]] <- 
    unique(receipts[pane])
    
    # Can also set the label and select an item (or more than
    # one if it's a multi-select)
    updateSelectInput(session, "inSelect",
                      choices = s_options,
                      selected = s_options
    )
    output$plot1 <- renderPlot({
      y = colSums(receipts[(receipts[ ,pane] == input$inSelect), r_years])
      #print(paste('index: ',pane))
      #print(paste('selected: ', input$inSelect))
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
})