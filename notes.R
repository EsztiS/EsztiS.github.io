# To print category names of boxes that are too small. Needs more work.
#output$category_names <- renderPrint({
#  outlay3 = newOut()[newOut()$total != 0, ]
#})

####======= If want to use number of accounts for area of rectangle
# newOut <- reactive({
#    part1 = data.frame(table(outlays[input$o_index]))
#    names(part1)[1] = input$o_index
#    part2 = group_by_(outlays, .dots=as.symbol(input$o_index)) %>%
#      summarise_(., total = interp(~sum(var), var = as.name(input$o_year)))
#    outlay2 = inner_join(part1,part2,by=input$o_index)
#  })

# output$ploto <- renderPlot({
#    outlay3 = newOut()[newOut()$total != 0, ]
#    total = sum(outlay3$total)
#    treemap(outlay3, 
#            index=input$o_index, 
#            vSize='Freq', 
#            vColor='total', 
#            type='value',
#            title = paste('TOTAL ', total, 'x 1000'))
#  })


#newBud <- reactive({
#  part1 = data.frame(table(budauth[input$b_index]))
#  names(part1)[1] = input$b_index
#  part2 = group_by_(budauth, .dots=as.symbol(input$b_index)) %>%
#    summarise_(., total = interp(~sum(var), var = as.name(input$b_year)))
#  budauth2 = inner_join(part1,part2,by=input$b_index)
#})