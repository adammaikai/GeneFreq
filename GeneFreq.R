library(data.table)
library(splitstackshape)
library(mygene)
library(myvariant)

.collapse <- function (...) {
  paste(unlist(list(...)), sep = ",", collapse = ",")
}

## ExAc amino acid frequencies (normal)
ExAcGene <- function(Gene) {
  query <- queryVariant(gsub(":", paste0(":", Gene), "dbnsfp.genename:"), fields="dbnsfp.hg19.start,exac.ac.ac", size=10000, return.as="records")
  pos <- sapply(query[[1]]$hits, function(i) .collapse(i$dbnsfp$hg19$start))
  ac <- sapply(query[[1]]$hits, function(i) .collapse(i$exac$ac$ac))
  gene.df <- data.frame(Position=pos, AlleleCount=ac)
  gene.df <- cSplit(gene.df, "Position", ",", direction="long")
  gene.df <- unique(arrange(data.frame(gene.df), Position))
  gene.df$AlleleCount <- as.numeric(gene.df$AlleleCount)
  gene.count <- aggregate(AlleleCount ~ Position, gene.df, sum)
  gene.count <- rep(gene.count$Position, gene.count$AlleleCount)
  data.frame(Position=gene.count, type=rep("ExAc", length(gene.count)))
  }

IntogenGene <- function(Gene){
  ## Intogen amino acid frequencies (tumor)
  ensembl.gene <- mygene::query(Gene, scopes="symbol", fields="ensembl.gene", species="human", return.as="records")$hits[[1]]$ensembl$gene
  geneCodingDriversUq <- subset(allCodingDriversUq, GENE==ensembl.gene)
  Position=geneCodingDriversUq$LOC
  AlleleCount=unlist(lapply(geneCodingDriversUq$LOC, function(x) length(unique(allCodingDf[which(allCodingDf$LOC %in% x),]$SAMPLE))))
  ac <- DataFrame(Position, AlleleCount)
  row.names(ac) <- NULL
  ac.df <- rep(ac$Position, ac$AlleleCount)
  start <- sapply(strsplit(ac.df, ":"), function(i) as.numeric(i[2]))
  data.frame(Position=start, type=rep("Intogen", length(start)))
}

GeneFreq <- function(Gene){
  ExAc <- ExAcGene(Gene)
  cat("\n")
  Intogen <- IntogenGene(Gene)
  if(nrow(ExAc) > nrow(Intogen)){
    ExAc <- ExAc[sample(1:nrow(ExAc), nrow(Intogen), replace=FALSE),]
  }
  else{
    Intogen <- Intogen[sample(1:nrow(Intogen), nrow(ExAc), replace=FALSE),]
  }
  rbind(ExAc, Intogen)
}