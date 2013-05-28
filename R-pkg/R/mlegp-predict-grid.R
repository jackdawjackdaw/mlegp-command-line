suppressPackageStartupMessages(library(adapt))
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
  
  if(class(fit.pca) == "gp.list"){
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
  }
  else {
    ## single observable
    temp <- predict(fit.pca, newData=xpt, se.fit=TRUE)
    predY <- temp$fit
    predYVar <- temp$se.fit
    tVar <- 1
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

  if(class(fit.pca)=="gp.list"){
    nObsCpts <- dim(fit.pca$UD)[1] ## number of dimensions in the output
  } else { ## single observation
    nObsCpts <-  1
  }
  nPca <- fit.pca$numGP ## number of GP's 
    
  implaus.inde <- 0
  implaus.joint <- matrix(0, nrow=nObsCpts, ncol=nObsCpts)

#  cat("# mean: ", emu.output$mean, "\n")
#  cat("# var: ", emu.output$var, "\n")
  if(class(fit.pca) == "gp.list"){
    V.mat <- emu.output$varMat + diag(obs.errs**2)
  #V.mat <- obs.errs.scaled**2
  #V.mat.inv <- diag(1/diag(obs.errs.scaled**2))
    V.mat.inv <- solve(V.mat)

    implaus.joint <- t(obs.means - emu.output$mean) %*% V.mat.inv %*% (obs.means - emu.output$mean)
#  browser()
    implaus.inde <- (emu.output$mean - obs.means)**2 / diag(V.mat)
  } else {
    implaus.joint <- implaus.inde <- (emu.output$mean - obs.means)**2 / (emu.output$var + obs.errs**2)
  }
  

  list(implaus.inde=implaus.inde, implaus.joint=implaus.joint)
}

## custom functions for plotting the main effects. Should be in their own file for the library

## plot the main effects in the PCA space
## calls plot.decomp.helper
plot.main.effects.pca <- function(fit.list, nobs=5, file.name.stub="main-effects-", ylim.in=c(-1,1)){

  ## helper routine to plot main effects in a not horrible way
  plot.decomp.helper <- function(obs.gp, param.names, plot.leg=TRUE, plot.ylim=c(-1,1)){
    nplots <- obs.gp$numDim
    colvec <- 1:nplots
    dat <- plotMainEffects(obs.gp, no.plot=TRUE)
    plot(dat$index, dat$preds[1,], type="l", col=colvec[1], ylim=plot.ylim,
         xlab="param value (arb)", ylab="predicted output (arb)", lwd=2)
    for(i in 2:nplots){
      lines(dat$index, dat$preds[i,], col=colvec[i], lwd=2, lty=i)
    }
    if(plot.leg){
      legend("bottomright", param.names, col=colvec, lwd=rep(2, nplots), lty=1:nplots)
    }
    ## return the results
    main.effects <- cbind(dat$index, t(dat$preds))
    colnames(main.effects) <- c("param.val",param.names )
    invisible(main.effects)
  }

  ## try and work sensibly if there's only a single fit instead of a whole gp
  if(class(fit.list)=="gp.list"){
    nobs.max <- dim(fit.list$UD)[2] ## use the max of the pca dimension
    if(nobs > nobs.max)
      nobs <- nobs.max
    ## try and divide the canvas up nicely
    ncol = min(3, round(nobs)/2+1)
    par(mfrow=c(2,ncol))
  } else {
    nobs = 1
  }

  for(i in 1:nobs){
    if(i == 1){
      d <- plot.decomp.helper(fit.list[[i]], fit.list$params, plot.ylim=ylim.in)
    } else {
      d <- plot.decomp.helper(fit.list[[i]], fit.list$params, plot.leg=FALSE, plot.ylim=ylim.in)
    }
    title(main=paste("obs.", i, sep=""))
    file.name <- paste(file.name.stub,i,".dat", sep="")
    write.table(d, file=file.name, row.names=FALSE)
  }
}


## returns all the main effects in the original space
## also makes a nice graph of the main effects for each "true" output
## 
plot.main.effects.true <- function(fit.pca, plot.leg=TRUE, ylim=c(-3,3))
{

  if(class(fit.pca)!="gp.list"){
    stop("this function is for plotting the main effects of a gp.list\n")
  }

  nobs.true <- (fit.pca$UD)[1] ## how many rotated/true values
  nparams <- fit.pca$numDim ## how many parameters
  colvec = 1:nobs.max
  
  nobs.gp <- fit.pca$numGPs
  d <- c()
  xs <- c()
  ef.list <- vector("list", fit.pca$numGPs)
  for(i in 1:nobs.gp){
    effecs <- plotMainEffects(fit.pca[[i]], no.plot=TRUE)
    ef.list[[i]] <- effecs
    if(i ==1)
      xs <- effecs$index
  }

  ## should do the unscaling here, load in the scales from the fit files

  main.effects <- vector("list", nobs.true)
  for(i in 1:nobs.true) ## entries are observables 1:nobs.true
    main.effects[[i]]$mat <- matrix(0, nrow=length(xs), ncol=nparams) # cols are params
  
  ## generate the reconstructed main effect in each observable, (this now has 6 columns)
  for(i in 1:nparams){ ## loop over all params
    dat <- matrix(0, nrow=length(xs), ncol=nobs.gp)
    for(j in 1:nobs.gp) ## loop over all the principle components
      dat[,j] <- ef.list[[j]]$preds[i,] ## get all nobs contributions for parameter i
    ## now project back the main effects for this i'th parameter

    ymain.eff <- t(fit.pca$UD %*% t(dat))
    #main.effects[[i]] <- ymain.eff ## this is a confusing thing to return
    for(j in 1:nobs.true)  ## fill in the effect of the i'th parameter for each observable
      main.effects[[j]]$mat[,i] <- ymain.eff[,j]
  }

  ##browser()

  ## plot everything
  ncol <- min(3, 1+round(nobs.max/2)) ## try and guess the number of cols we need
  par(mfrow=c(2,ncol))
  for(i in 1:nobs.true){
    ## now make a plot
    for(j in 1:nparams){
      if(j==1){
        plot(xs, main.effects[[i]]$mat[,j], col=colvec[j], lwd=2, lty=j, ylim=range(main.effects[[i]]$mat)+0.2*range(main.effects[[i]]$mat),
             ylab="predicted output (arb)", xlab="param value (arb)", type="l")
      }
      lines(xs, main.effects[[i]]$mat[,j], col=colvec[j], lwd=2, lty=j)
      if(i==1){ ## only plot the legend once
        legend("bottomright", desNames, col=colvec, lwd=rep(2, nparams), lty=1:nparams)
      }
      title(main=paste("(true) obs.", i,mwString.Up))
    }
  }
    
  invisible(list(xs=xs, yeff.list=main.effects))
}
