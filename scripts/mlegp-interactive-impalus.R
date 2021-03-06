#!/usr/bin/env Rscript
suppressPackageStartupMessages(library("optparse"))
#args <- commandArgs(TRUE) ## get the arguments
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
suppressPackageStartupMessages(library(mlegpInter))
suppressPackageStartupMessages(library(mlegpFULL))

option.list <- list(
  make_option(c("-v", "--verbose"), action="store_true", default=FALSE, help="Print extra output"))

parser <- OptionParser(usage="%prog [options] savefile obsfile", option_list=option.list)
args.in <- parse_args(parser, positional_arguments=TRUE)
opt <- args.in$options
#args <- parse <- args(parser, 
#opt <- parse_args(OptionParser(option_list=option.list))
args <- strsplit(args.in$args, " ")
#cat(class(args), "\n")
#cat(args[[1]], "\n")


##
if(length(args) < 2){
  cat("# invocation: Rscript ./mleg-interactive-implaus <mlegp-save-file> <obs-dat-file>\n")
  stop(" run with path to mlegp save file and observable data file\nreads points in parameter space from stdin\noutputs joint-implaus and inde implaus ")
}

save.file.name <- args[[1]]
cat("# reading mlegp data from: ", save.file.name, "\n");
if(!file.exists(save.file.name)){
  stop(paste(" cannot open", save.file.name))
}

obs.file.name <- args[[2]]
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

if(!exists("training.scale.info"))
  warning(paste("file:", save.file.name, "doesn't contain a training scale object"))
if(!exists("des.scale.info"))
  warning(paste("file:", save.file.name, "doesn't contain a design scale object"))

## how big do we expect the xpoints 
nparams <- fit.pca$numDim
cat("# expecting: ", nparams, "coordinate points per input line\n")


## now load the observable data
obs.dat <- as.matrix(read.table(obs.file.name))
if(class(fit.pca)=="gp.list"){
  nObsCpts <- dim(fit.pca$UD)[1]
} else {
  nObsCpts <- 1
}
if(dim(obs.dat)[1] < 2)
  stop(paste("not enough rows (mean, error), in observable file:", obs.dat))
if(dim(obs.dat)[2] < nObsCpts)
  stop(paste("not enough columns, expected: ", nObsCpts, "got:", dim(obs.dat)[2]))

obs.means <- obs.dat[1,]
obs.errs <- obs.dat[2,]
cat("# obs.means: ", obs.means, "\n")
cat("# obs.errors: ", obs.errs, "\n")

## now loop over stdin
## does setting this blocking matter? yes
f <- file("stdin", blocking=TRUE)
open(f)
while(length(line <- readLines(f,n=1)) > 0) {
#  write(line, stderr()) ## echo!
# process line

  pt <- as.numeric(strsplit(line, " ")[[1]])
  ## we cut out potential NAs caused by extra whitespace
  pt <- as.vector(na.omit(pt))
#  cat("#pt.split: ", pt, "\n")

  if(length(pt) < nparams)
    stop(paste("need",nparams,"coordinates to make a prediction at a single point"))

  if(length(pt) > nparams){
    warning(paste("read: ", length(pt), " need: ", nparams, "ignoring the excess"))
    pt <- pt[1:nparams]
  }

#  cat("read point: ", pt, "\n")
  
  #pred <- predict.output.at.point(pt, fit.pca)
  imp <- implaus.output.at.point(pt, fit.pca, obs.means, obs.errs,
                                 training.scale.info,
                                 des.scale.info)
  ## output to file
  cat(imp$implaus.joint, "\n")
  cat(imp$implaus.inde, "\n")
  ## debug info to stderr
  if(opt$verbose){
    write(paste(imp$implaus.joint, paste(pt, sep=" ", collapse=" ")), stderr())
  }
  
}
