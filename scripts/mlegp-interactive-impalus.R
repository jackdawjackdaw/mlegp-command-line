args <- commandArgs(TRUE) ## get the arguments
## ccs, cec24@phy.duke.edu
##
##
## try making IMPLAUS calculations from a command line invocation of R
## outputs the joint implaus and the independent ones on two separate lines
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
## 2nd arg: the path to a text file containing observable data, this
## should have nobs columns and 2 rows. The first row will be read as the observable means
## and the second row as the observable errors (std-deviations, not variances)
##
## reads input points from stdin, expects fit.pca$numDim cpts per line
## will stop otherwise
#source("mlegp-predict-grid.R")
library(mlegpInter)
library(mlegpFULL)

##
if(length(args) < 2){
  cat("# invocation: Rscript ./mleg-interactive-implaus <mlegp-save-file> <obs-dat-file>\n")
  stop(" run with path to mlegp save file and observable data file\nreads points in parameter space from stdin\noutputs joint-implaus and inde implaus ")
}

save.file.name <- args[1]
cat("# reading mlegp data from: ", save.file.name, "\n");
if(!file.exists(save.file.name)){
  stop(paste(" cannot open", save.file.name))
}

obs.file.name <- args[2]
cat("# reading observable data from: ", obs.file.name, "\n");
if(!file.exists(obs.file.name)){
  stop(paste(" cannot open", obs.file.name))
}


## now load the mlegp data
load(save.file.name)
## need to check that there is a "fit.pca" object
if(!exists("fit.pca")){
  stop(paste("file:", save.file.name, "doesn't contain a fit.pca object"))
} 
## how big do we expect the xpoints 
nparams <- fit.pca$numDim
cat("# expecting: ", nparams, "coordinate points per input line\n")


## now load the observable data
obs.dat <- as.matrix(read.table(obs.file.name))
nObsCpts <- dim(fit.pca$UD)[1]
if(dim(obs.dat)[1] < 2)
  stop(paste("not enough rows (mean, error), in observable file:", obs.dat))
if(dim(obs.dat)[2] < nObsCpts)
  stop(paste("not enough columns, expected: ", nObsCpts, "got:", dim(obs.dat)[2]))

obs.means <- obs.dat[1,]
obs.errs <- obs.dat[2,]
cat("# obs.means: ", obs.means, "\n")
cat("# obs.errors: ", obs.errs, "\n")
cat("#############################################\n")
cat("# WARNING: obs errors and means are assumed to\n# be scaled exactly the same as the mlegp emulator\n# the unscaled values will give *useless* results\n")
cat("#############################################\n")       

## now loop over stdin
f <- file("stdin")
open(f)
while(length(line <- readLines(f,n=1)) > 0) {
  #write(line, stderr()) ## echo!
  # process line

  pt <- as.numeric(strsplit(line, " ")[[1]])
  if(length(pt) < nparams)
    stop(paste("need",nparams,"coordinates to make a prediction at a single point"))

  #pred <- predict.output.at.point(pt, fit.pca)
  imp <- implaus.output.at.point(pt, fit.pca, obs.means, obs.errs)
  ## output to file
  cat(imp$implaus.joint, "\n")
  cat(imp$implaus.inde, "\n")
}
