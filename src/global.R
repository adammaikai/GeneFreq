library(shiny)
library(data.table)
library(splitstackshape)
library(mygene)
library(myvariant)
library(ggplot2)
library(plyr)
library(repmis)
source('GeneFreq.R')

.collapse <- function (...) {
  paste(unlist(list(...)), sep = ",", collapse = ",")
}

#allCodingDriversUq <- suppressWarnings(source_DropboxData("allCodingDriversUq.tsv", "6u20gfd7yi5ua3d", sep="\t", header=T))
#allCodingDf <- suppressWarnings(source_DropboxData("allCodingDf.tsv", "szlop3lsb9xgxnx", sep="\t", header=T))