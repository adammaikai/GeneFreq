# library(shiny)
# library(data.table)
# library(splitstackshape)
# library(mygene)
# library(myvariant)
# library(ggplot2)
# library(DT)
# setwd("~/avera/repos/GeneFreq")
# source("GeneFreq.R")
# load("intogenCodingDrivers.RData")
# load("intogenAllCodingDf.RData")
# .collapse <- function(...) {
#   paste(unlist(list(...)), sep=",", collapse=",")
# }

ui <- fluidPage(
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
)


 server <- function(input, output) {
   ranges <- reactiveValues(x = NULL, y = NULL)
   
   exac <- reactive({
     if(input$gene != "Enter Gene Symbol..."){
      ExAcGene(input$gene)
     }
    })
   
   intogen <- reactive({
     if(input$gene != "Enter Gene Symbol..."){
       IntogenGene(input$gene)
     }
   })
   
   df <- reactive({
   if(nrow(exac()) > nrow(intogen())){
     exac <- exac()[sample(1:nrow(exac()), nrow(intogen()), replace=FALSE),]
     intogen <- intogen()
   }
   else{
     intogen <- intogen()[sample(1:nrow(intogen()), nrow(exac()), replace=FALSE),]
     exac <- exac()
   }
   rbind(exac(), intogen())
   })
   
   output$allele_count <- renderPrint({
     if(!is.null(df())){
     cat("ExAc:", nrow(exac()), "missense variants in", input$gene)
     cat("\n")
     cat("Intogen:", nrow(intogen()), "missense variants in", input$gene)
     cat("\n")
     if(nrow(exac()) > nrow(intogen())){
       cat("The set of ExAc", input$gene, "variants were randomly subsetted to match the sample size of Intogen", input$gene,"Variants")
       cat("\n")
     }
     else{
       cat("The set of Intogen", input$gene, "variants were randomly subsetted to match the sample size of Exac", input$gene, "Variants")
       cat("\n")
     }
     cat("Final sample size:", min(nrow(exac()), nrow(intogen())), "ExAc variants and", min(nrow(exac()), nrow(intogen())), "Intogen variants")
     }
   })
   
   output$plot1 <- renderPlot({
       if(input$gene != "Enter Gene Symbol..."){
            ggplot(data=df(), aes(x=Position, colour=type)) + geom_bar() + coord_cartesian(xlim = ranges$x, ylim = ranges$y)
          }
   })
   
   # When a double-click happens, check if there's a brush on the plot.
   # If so, zoom to the brush bounds; if not, reset the zoom.
   observeEvent(input$plot1_dblclick, {
     brush <- input$plot1_brush
     if (!is.null(brush)) {
       ranges$x <- c(brush$xmin, brush$xmax)
       ranges$y <- c(brush$ymin, brush$ymax)
       
     } else {
       ranges$x <- NULL
       ranges$y <- NULL
     }
   })

  output$click_info <- renderPrint({
    if(!is.null(input$plot_click)){
    q <- queryVariant(paste("dbnsfp.hg19.start:", round(input$plot_click$x, 0), "AND dbnsfp.genename:", input$gene),
                 fields=c("dbnsfp.chrom",
                          "dbnsfp.aa.pos",
                          "dbnsfp.aa.ref",
                          "dbnsfp.aa.alt",
                          "dbsnp.rsid",
                          "clinvar.rcv.clinical_significance",
                          "dbnsfp.polyphen2.hdiv.score"),
                 return.as="records")[[1]]$hits[[1]]
    
    cat(paste0("Genomic position: chr", q$dbnsfp$chrom, ":g.", round(input$plot_click$x, 0)))
    cat("\n")
    cat("dbSnp:", q$dbsnp$rsid)
    cat("\n")
    cat("Amino Acid:", paste0(q$dbnsfp$aa$ref, unique(q$dbnsfp$aa$pos), unique(q$dbnsfp$aa$alt)))
    cat("\n")
    cat("ClinVar:", q$clinvar$rcv$clinical_significance)
    cat("\n")
    cat("Polyphen2 score:", unique(q$dbnsfp$polyphen2$hdiv$score))
    }
  })
}


shinyApp(ui, server)