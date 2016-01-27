library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Gene Freq!"),

  textInput("gene", label=h3("Gene Input"), value="Enter Gene Symbol..."),
  #submitButton("Submit"),
  ui <- fluidPage(
    fluidRow(
      column(width = 12, class = "well",
             h4("Brush and double-click to zoom"),
             plotOutput("plot1", height = 300,
                        click = "plot_click",
                        dblclick = dblclickOpts(
                          id = "plot1_dblclick"),
                        brush = brushOpts(
                          id = "plot1_brush",
                          resetOnNew = TRUE
                        )
             )
      )
    ),
    fluidRow(
      column(width = 4,
             verbatimTextOutput("click_info")
      ),
      column(width = 8,
             verbatimTextOutput("allele_count")
      )
    )
  )
))
