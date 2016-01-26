library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Gene Freq!"),

  textInput("gene", label=h3("Gene Input"), value="Enter Gene Symbol..."),
  #submitButton("Submit"),
  plotOutput("GenePlot", height = 350,
             dblclick = dblclickOpts(
               id = "plot_dblclick"
             ))
  ,
  fluidRow(
    column(width = 3,
           verbatimTextOutput("dblclick_info")
    )
  )
))
