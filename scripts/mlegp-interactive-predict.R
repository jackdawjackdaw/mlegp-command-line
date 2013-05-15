#!/usr/bin/env Rscript
args <- commandArgs(TRUE) ## get the arguments
## ccs, cec24@phy.duke.edu
##
##
## try making predictions from a command line invocation of R
## outputs the mean, variance and covariance matrix (on separate lines)
##
## package deps: mlegpFull, adapt
## 
## needs: a mlegp trained pca gp list object named "fit.pca" written into
## an R file with the "save" command
## 
## run with: Rscript
## 
## 1st arg: the path to the mlegp save file containing a list: fit.pca 
## containing the trained pca emulator
##
## reads input points from stdin, expects fit.pca$numDim cpts per line
## will stop otherwise
#source("mlegp-predict-grid.R")
library(mlegpInter)
suppressPackageStartupMessages(library(mlegpFULL))

##
if(length(args) == 0){
  stop(" run with path to mlegp save file\nreads points in parameter space from stdin\noutputs means + variances to stdoutn ")
}

save.file.name <- args[1]
cat("# reading data from: ", save.file.name, "\n");
if(!file.exists(save.file.name)){
  stop(paste(" cannot open", save.file.name))
}
## now load the data
load(save.file.name)
## need to check that there is a "fit.pca" object
if(!exists("fit.pca")){
  stop(paste("file:", save.file.name, "doesn't contain a fit.pca object"))
} 
if(!exists("training.scale.info"))
  warning(paste("file:", save.file.name, "doesn't contain a training scale object"))
if(!exists("des.scale.info"))
  warning(paste("file:", save.file.name, "doesn't contain a design scale object"))

## how big do we expect the xpoints 
nparams <- fit.pca$numDim
cat("# expecting: ", nparams, "coordinate points per input line\n")
cat("# ngps: ", fit.pca$numGP, "\n")
cat("# nobs: ", dim(fit.pca$UD)[1], "\n")

## now loop over stdin
f <- file("stdin")
open(f)
while(length(line <- readLines(f,n=1)) > 0) {
  #write(line, stderr()) ## echo!
  # process line

  pt <- as.numeric(strsplit(line, " ")[[1]])
  ## we cut out potential NAs caused by extra whitespace
  pt <- as.vector(na.omit(pt))

  if(length(pt) < nparams)
    stop(paste("need",nparams,"coordinates to make a prediction at a single point"))

  if(length(pt) > nparams){
    warning(paste("read: ", length(pt), " need: ", nparams, "ignoring the excess"))
    pt <- pt[1:nparams]
  }
  
  ## i'm concerned about the rotation back from principle components...
  pred <- predict.output.at.point(pt, fit.pca,
                                  training.scale.info,
                                  des.scale.info)
  ## simple output, just print everything on a single line
  cat(pred$mean, "\n")
  cat(pred$var, "\n")
  cat(pred$varMat, "\n")
}
