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
## how big do we expect the xpoints 
nparams <- fit.pca$numDim
cat("# expecting: ", nparams, "coordinate points per input line\n")

## now loop over stdin
f <- file("stdin")
open(f)
while(length(line <- readLines(f,n=1)) > 0) {
  #write(line, stderr()) ## echo!
  # process line

  pt <- as.numeric(strsplit(line, " ")[[1]])
  if(length(pt) < nparams)
    stop(paste("need",nparams,"coordinates to make a prediction at a single point"))

  pred <- predict.output.at.point(pt, fit.pca)
  ## simple output, just print everything on a single line
  cat(pred$mean, "\n")
  cat(pred$var, "\n")
  cat(pred$varMat, "\n")
}
