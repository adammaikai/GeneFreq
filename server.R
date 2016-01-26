
## ExAc amino acid frequencies (normal)
shinyServer(function(input, output) {
    
  output$GenePlot <- renderPlot({
    if(input$gene != "Enter Gene Symbol..."){
      ggplot(data=GeneFreq(input$gene), aes(x=Position, colour=type)) + geom_density() + stat_bin(bins = 1000)#input$bins)
    }
    
  })
  
  output$dblclick_info <- renderPrint({
    if(!is.null(input$plot_dblclick)){
      #     cat("Genomic position:", input$plot_dblclick$x, "\n",
      #           "Allele Count:", round(input$plot_dblclick$y, 0))
      q <- queryVariant(paste("dbnsfp.hg19.start:", round(input$plot_dblclick$x, 0), "AND dbnsfp.genename:", input$gene),
                        fields=c("dbnsfp.aa.pos", "dbnsfp.polyphen2.hdiv.score"), return.as="records")[[1]]$hits[[1]]
      cat("Amino Acid position:", q$dbnsfp$aa$pos)
      cat("\n")
      cat("Polyphen2 score:", q$dbnsfp$polyphen2$hdiv$score)
    }
  })
  
})

  

