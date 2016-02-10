library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

  # Application title
  titlePanel("Gene Freq!"),
  h5("This a visual tool for comparing the distribution of nonsynonymous variants across a gene in the ExAc dataset versus the Intogen dataset. Select a gene symbol below (autocomplete is provided). Variant allele counts from the ExAc dataset as well as the Intogen dataset will then be plotted. You can select a region and double click to zoom. Repeat this action to achieve base pair resolution. You can then click a position on the plot to learn about the variant."),
  selectInput("gene", label = h3("Select Gene"), 
              choices = c("Select Gene Symbol...", symbols), 
              selected = "Select Gene Symbol..."),
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
