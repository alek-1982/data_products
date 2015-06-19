
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(shiny)
#library(doMC)
library(caret)
data(ChickWeight)
set.seed(1188)


# enable multicore computation
#registerDoMC(cores = detectCores(all.tests = TRUE, logical = FALSE))

shinyServer(function(input, output) {
        # return input values
        output$oid1 <- renderPrint({ if(input$goButton >= 1) isolate(input$modelId)})
        
        ### control parameters for model training using caret
        ctrl <- trainControl(method = "repeatedcv", number = 10, repeats = 1)
        
######################## train models only if they were selected ##########################
        rpart_reg <- reactive({
                if(input$goButton >= 1 & "1" %in% input$modelId){
                        grid <-  expand.grid(cp = 0.05)
                        fit1 <- isolate(train(weight ~ Time+Chick+Diet, 
                                           data = ChickWeight,
                                           method = "rpart",
                                           metric = "Rsquared",
                                           tuneGrid = grid,
                                           trControl = ctrl))
                        return(fit1)
                }
        })

XG_reg <- reactive({
        if(input$goButton >= 1 & "2" %in% input$modelId){
                        fit2 <- isolate(train(weight ~ Time+Chick+Diet, 
                              data = ChickWeight,
                              method = "lm",
                              metric = "Rsquared",
                              trControl = ctrl))
                        return(fit2)
        }
                
})
nnet_reg <- reactive({
        if(input$goButton >= 1 & "3" %in% input$modelId){
                        grid <-  expand.grid(size = 3,
                                             decay = 0.1)
                        fit3 <- isolate(train(weight ~ Time+Chick+Diet, 
                              data = ChickWeight,
                              method = "nnet",
                              metric = "Rsquared",
                              tuneGrid = grid,
                              trControl = ctrl))
                        return(fit3)
        }
                
})
# create list with selected models for resamples function
        modelList <- reactive({
                if      (input$goButton >= 1 & "1" %in% input$modelId & "2" %in% input$modelId & "3" %in% input$modelId) return(list(CART = rpart_reg(),
                                                                                                                                     LinearReg = XG_reg(),
                                                                                                                                     ANN = nnet_reg()))
                else if (input$goButton >= 1 & "1" %in% input$modelId & "2" %in% input$modelId) return(list(CART = rpart_reg(),
                                                                                                            LinearReg = XG_reg()))
                else if (input$goButton >= 1 & "1" %in% input$modelId & "3" %in% input$modelId) return(list(CART = rpart_reg(),
                                                                                                            ANN = nnet_reg()))
                else return(list(LinearReg = XG_reg(), ANN = nnet_reg()))
        })
# generate performance comparison dotplot
  output$distPlot <- renderPlot({
          
        if(input$goButton >= 1){
        
          cvValues <- isolate(resamples(modelList(), metric = "Rsquared", decreasing = TRUE))

          #creating plot to compare performances
          plot <- isolate(dotplot(cvValues, metric = "Rsquared", main = "Resampled Performance"))
          return(plot)
         }
  })

})
