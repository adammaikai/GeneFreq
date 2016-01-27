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

load("intogenAllCodingDf.RData")
load("intogenCodingDrivers.RData")