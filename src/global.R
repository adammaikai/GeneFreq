library(data.table)
library(splitstackshape)
library(mygene)
library(myvariant)
library(ggplot2)
library(DT)
source("GeneFreq.R")
load("intogenCodingDrivers.RData")
.collapse <- function(...) {
  paste(unlist(list(...)), sep=",", collapse=",")
}