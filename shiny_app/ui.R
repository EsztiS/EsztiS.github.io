library(dplyr)

shinyUI(fluidPage(
  
  titlePanel('Treemap of US-Budget Per Year'),
  
  tabsetPanel(
    tabPanel('Receipts',
      fluidRow(
        column(2, offset = 1,
          selectInput('r_year',
                  label = 'Year', 
                  choices = names(receipts)[r_years])
              ),
        column(3,
          selectInput('r_index',
                  label = 'Index',
                  choices = names(receipts)[r_indices])
              ),
        column(3,
               selectInput("inSelect", 
                           label = "Select panes",
                           multiple = TRUE,
                           c('N O   I N P U T'))
        ),
      submitButton('Submit')
              ),
      plotOutput('plotr'),
      plotOutput('plotr_yrs')
    ),
    
    tabPanel('Outlays',
      fluidRow(
        column(2, offset = 1,
          selectInput('o_year',
                  label = 'Year', 
                  choices = names(outlays)[o_years])
              ),
        column(3,
          selectInput('o_index',
                  label = 'Index',
                  choices = names(outlays)[o_indices])
              ),
      submitButton('Submit')
           ),
    plotOutput('ploto'),
    verbatimTextOutput("category_names")
    ),
    
    tabPanel('BudgetAuthority',
      fluidRow(
        column(2, offset = 1,
          selectInput('b_year',
            label = 'Year', 
            choices = names(budauth)[b_years])
                      ),
          column(3,
            selectInput('b_index',
              label = 'Index',
              choices = names(budauth)[b_indices])
                        ),
               submitButton('Submit')
             ),
             plotOutput('plotb')
    )
  ) 
))