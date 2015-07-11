shinyUI(fluidPage(
  titlePanel("Changing the values of inputs from the server"),
  fluidRow(
    column(3,
      selectInput("chosen_pane",
                  label = 'Which index?',
                  choices = names(receipts)[r_indices])
    ),
    column(3,
             selectInput("inSelect", 
                         label = "Select panes",
                         #multiple = TRUE,
                         c('Confusing'))
                         #c("label 1" = "option1",
                          # "label 2" = "option2"))
    ),
    plotOutput('plot1')
  )
))



