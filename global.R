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

load("intogenCoding.RData")
load("tcgaGeneSymbols.RData")
allCodingDriversUq <- allCodingDf[match(unique(allCodingDf$LOC), allCodingDf$LOC), -1]