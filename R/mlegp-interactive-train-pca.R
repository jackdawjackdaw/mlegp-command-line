args <- commandArgs(TRUE) ## get the arguments
## ccs, cec24@phy.duke.edu
##
##
## train a set of GP's on a multidimensional model output
## 
##
## package deps: mlegpFull, adapt
##
## run with: Rscript
## 
## 1st arg: the path to the designfile
## 2nd arg: the path to the model output file (trainingfile)
## 3rd arg: path to save the trained mlegp pca emulators in
##
## design file should have header line with names of the design cpts,
## otherwise defaults "v1",..."vn" will be used
##
## mlegp gp list is saved into "save.file.name" along with information about
## the scalings of the design and training data
##
library(mlegpFULL)

if(length(args) < 3){
  cat("# run with: <designfile> <trainingfile> <savefile>\n")
  stop(" args error")
}

design.file.name <- args[1]
training.file.name <- args[2]
save.file.name <- args[3]

## check the deisgn and training files exist
if(!file.exists(design.file.name))
  stop(paste("design file: ", design.file.name, "doesn't exist"))
if(!file.exists(training.file.name))
  stop(paste("training file: ", training.file.name, "doesn't exist"))
if(file.exists(save.file.name)){
  cat("# save file exists already")
  ans <- NA
  ## open stdin
  f <-  file("stdin")
  while(is.na(ans) | !is.logical(ans)){
    cat("clobber the file yes-no?: ")
    ans <- readLines(f,n=1)
    ans <- ifelse(grepl("yes|y",ans, ignore.case=TRUE),TRUE,FALSE)
  }
  if(!ans){
    stop("# re-run with a new save file name to avoid clobbering")
  }
  close(f)
}

## first load the design data
des.data.raw <- as.matrix(read.table(design.file.name))
des.names <- colnames(des.data.raw)
cat("# deisgn variables: ", des.names, "\n")
nparams <- dim(des.data.raw)[2]
ndespts <- dim(des.data.raw)[1]

cat("# nparams: ", nparams, "\n")
cat("# ndespts: ", ndespts, "\n")

## scale the design
des.scaled <- scale(des.data.raw)
## save this into the final file
des.scale.info <- c()
des.scale.info$center <- attr(des.scaled,"scaled:center")
des.scale.info$scale <- attr(des.scaled,"scaled:scale")

## now load the training data
training.raw <- as.matrix(read.table(training.file.name))

nbins <- dim(training.raw)[2]
nobs <- dim(training.raw)[1]

cat("# number of observables: ", nbins, "\n")
cat("# number of observations: ", nobs, "\n")

## scale the training data
training.scaled <- scale(training.raw)
training.scale.info <- c()
training.scale.info$center <- attr(training.scaled, "scaled:center")
training.scale.info$scale <- attr(training.scaled, "scaled:scale")

## set the pca number (by hand...)
pca.number <- 5
if(nbins < pca.number){
  pca.number <- nbins
}

cat("# number principle cpts: ", pca.number, "\n")
pca.importance <- 100 - singularValueImportance(t(training.scaled))[1:pca.number]
cat("# pca importance: ", pca.importance, "\n")

## now actually train everything
bfgs.seed <- round(runif(1) * .Machine$integer.max) ## stupid way to actually sample on 1..IntMax
fit.pca <- mlegp(des.scaled, t(training.scaled), min.nugget=1e-5, nugget=1e-1,
                 PC.num=pca.number,
                 param.names=des.names, seed=bfgs.seed)
## now save it
save(fit.pca, des.scale.info, training.scale.info, file=save.file.name)

## we're done
