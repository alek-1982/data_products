
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  # Application title
  titlePanel("Machine Learning - Training and comparing model performance on ChickWeight data"),

  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
            h3("Choose learning algorithm"),
            checkboxGroupInput("modelId", "Checkbox (choose at least two)",
                               c("CART decision tree" = "1", "Linear Regression" = "2", "Artificial Neural Network" = "3"), selected = NULL), 
            #submitButton('Submit')
            actionButton("goButton", "Go!")
    ),

    # Show a plot of the generated distribution
    mainPanel(
            h3("Model Performance based on 10-fold cross validation"),
            h4('You selected:'), 
            verbatimTextOutput("oid1"), 
            
      plotOutput("distPlot"),
        h5("formula used: 'weight ~ Time+Chick+Diet' (which does not make sense but suffices for the purpose of the task")
    )
  )
))
