suppressPackageStartupMessages(library(mlegpFULL))
## ccs,
## testing the mlegp predict method
##
## 

## set some paths (this is just for testing)
#mwString <- "./round-robin_5param/mw1-round/mw1"
#mwString.Up <- "MW1"
#save.file.name <- paste("./dat-pca/mlegp-single-obs-", tolower(mwString.Up), "-fits-pca.dat", sep="")

## the trained emluator file should be pointed to here
#emulator.save.file <- save.file.name
#load(save.file.name) ## this will enter "fit.pca" into the workspace

## make a prediction at a given point
## return the mean, var and var matrix for the given input point
##
## xpt: the prediction location, a vector of length nDim
## fit.pca: the trained mlegp list of GP's
## train.scale.info: the scale and center for the training data 
## des.scale.info: the scale ance center for the design 
predict.output.at.point <- function(xpt, fit.pca, train.scale.info=NULL, des.scale.info=NULL){

  if(!is.null(des.scale.info)){
    ## we have to scale the xpt
#    cat("# xpt: ", xpt, "\n")
    xpt <- (xpt - as.vector(des.scale.info$center)) / (as.vector(des.scale.info$scale))
#    cat("# xpt: ", xpt, "\n")
  } 
  
  xpred.mat <- matrix(xpt, nrow=1, ncol=fit.pca$numDim)
  # intermediate matrix for means
  Vprime <- matrix(0, fit.pca$numGP, 1)
  VprimeSE <- matrix(0, fit.pca$numGP, 1)
  for(i in 1:fit.pca$numGP){
    temp <- predict(fit.pca[[i]], newData = xpt, se.fit=TRUE)
    Vprime[i,] <- temp$fit
    VprimeSE[i,] <- temp$se.fit
  }
  predY = fit.pca$UD %*% Vprime
  ## these are standard deviations (square-roots of variances)

  ## we want to make the cov matrix so we can compute the implaus
  nObsCpts <- dim(fit.pca$UD)[1]
  nPca <- fit.pca$numGP
  ## the observations matrix is SVD"d to : Y = UD V
  ##
  VprimeOrig <- matrix(0,nrow=fit.pca$numObs, ncol=nPca)
  for(i in 1:nPca){
    VprimeOrig[,i] <- fit.pca[[i]]$Z
  }
  Yrecon <- fit.pca$UD %*% t(VprimeOrig)
  s = svd(Yrecon)

  
  #predYVar = fit.pca$UD %*% (VprimeSE**2)

  ur <- s$u[,1:nPca]
  lam <- s$d[1:nPca]
  
  predYVar <- rep(NA, nObsCpts)
  for(i in 1:nObsCpts)
    predYVar[i] <- sum(ur[i,]**2 * lam * (VprimeSE[,1]**2))
  
  tVar <- matrix(0, nrow=nObsCpts, ncol=nObsCpts)
  for(i in 1:nObsCpts){
    for(j in 1:nObsCpts){
      tVar[i,j] <- sum(ur[i,]*ur[j,] * lam*VprimeSE[,1]**2)
    }
  }

  ## unscale everything correctly
  if(!is.null(train.scale.info)){
    predY <- (predY * train.scale.info$scale ) + train.scale.info$center
    predYVar <- predYVar * (train.scale.info$scale**2)
    tVar <- outer(predYVar, predYVar) * tVar
  }
  
  
  list(mean=predY, var=predYVar, varMat = tVar)
}

## compute the joint implaus at a point
## needs obs mean and obs errors
##
## implaus_joint^2 = (E(f(x) - z))^t V^{-1} E(f(x) - z)
## where E(f(x)) is a vector of the emulator mean at the point x
## in the design space.
##
## xpt: the point to predict at, vector of length nDim
## fit.pca: list of GP emulators, output from mlegp
## (opt)train.scale.info: the scales and centers for the training data
## (opt)des.scale.info: the scales and centers for the design data
## 
## note: the observable means must be scaled & centred in the same way as the original trianing data
## the i'th entry in the obs vector should be scaled like this:
## mu_obs_scaled_i = (mu_obs_i - mean_training_Y_i) / sigma_training_Y_i
## 
## the observable errors should be scaled 
## err_obs_scaled_i = err_obs_scaled_i / (sigma_training_Y_i)
##
implaus.output.at.point <- function(xpt, fit.pca, obs.means, obs.errs, train.scale.info=NULL, des.scale.info=NULL){
  
  ## make the prediction
  emu.output <- predict.output.at.point(xpt, fit.pca, train.scale.info, des.scale.info)

  nObsCpts <- dim(fit.pca$UD)[1] ## number of dimensions in the output
  nPca <- fit.pca$numGP ## number of GP's 
    
  implaus.inde <- 0
  implaus.joint <- matrix(0, nrow=nObsCpts, ncol=nObsCpts)

#  cat("# mean: ", emu.output$mean, "\n")
#  cat("# var: ", emu.output$var, "\n")
  
  V.mat <- emu.output$varMat + diag(obs.errs**2)
  #V.mat <- obs.errs.scaled**2
  #V.mat.inv <- diag(1/diag(obs.errs.scaled**2))
  V.mat.inv <- solve(V.mat)
  
  implaus.joint <- t(obs.means - emu.output$mean) %*% V.mat.inv %*% (obs.means - emu.output$mean)
#  browser()
  implaus.inde <- (emu.output$mean - obs.means)**2 / diag(V.mat)

  list(implaus.inde=implaus.inde, implaus.joint=implaus.joint)
}

## this seems ok, we need to test it a bit i suppose
