## ExAc amino acid frequencies (normal)
shinyServer(function(input, output) {
    
  
  ranges <- reactiveValues(x = NULL, y = NULL)
  
  exac <- reactive({
    if(input$gene != "Select Gene Symbol..."){
      ExAcGene(input$gene)
    }
  })
  
  intogen <- reactive({
    if(input$gene != "Select Gene Symbol..."){
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
  
  output$plot1 <- renderPlot({
    if(input$gene != "Select Gene Symbol..."){
      ggplot(data=df(), aes(x=Position, colour=type)) + geom_bar() + coord_cartesian(xlim = ranges$x, ylim = ranges$y) + scale_colour_manual(values = c("green", "red"))
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
  output$allele_count <- renderPrint({
     if(input$gene != "Select Gene Symbol..."){
       if(!is.null(exac()) & !is.null(intogen())){
      cat("ExAc:", nrow(exac()), "missense variants in", input$gene)
        cat("\n")
        cat("Intogen:", nrow(intogen()), "missense variants in", input$gene)
        cat("\n")
       if(nrow(exac()) > nrow(intogen())){
         cat("The set of ExAc", input$gene, "variants were randomly subsetted to match the sample size of Intogen", input$gene,"Variants.")
         cat("\n")
       }
       else{
         cat("The set of Intogen", input$gene, "variants were randomly subsetted to match the sample size of Exac", input$gene, "Variants.")
         cat("\n")
       }
       cat("Final sample size:", min(nrow(exac()), nrow(intogen())), "ExAc variants and", min(nrow(exac()), nrow(intogen())), "Intogen variants.")
       }
     }
    else{cat("Sample set info:")}
   })
  
})

  

