## custom functions for plotting the main effects. Should be in their own file for the library

## plot the main effects in the PCA space
## calls plot.decomp.helper
##
## \todo: return a table instead
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
plot.main.effects.true <- function(fit.pca, train.scale.info=NULL, plot.leg=TRUE, ylim=c(-3,3))
{

  if(class(fit.pca)!="gp.list"){
    stop("this function is for plotting the main effects of a gp.list\n")
  }

  nobs.true <- dim(fit.pca$UD)[1] ## how many rotated/true values
  nparams <- fit.pca$numDim ## how many parameters
  colvec = 1:nobs.true
  nobs.gp <- fit.pca$numGPs

  cat("# computing true-basis main effects. ntrue: ", nobs.true , "npca: ", nobs.gp ,"\n")
  cat("# this can be slow...\n")
  
  d <- c()
  xs <- c()
  ef.list <- vector("list", nobs.gp)
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
    if(!is.null(train.scale.info)){ ## unscale correctly
      ymain.eff <- ymain.eff * train.scale.info$scale + train.scale.info$center
    }
    
    #main.effects[[i]] <- ymain.eff ## this is a confusing thing to return
    for(j in 1:nobs.true)  ## fill in the effect of the i'th parameter for each observable
      main.effects[[j]]$mat[,i] <- ymain.eff[,j]
  }

  ##browser()

  ## plot everything
  ncol <- min(3, 1+round(nobs.true/2)) ## try and guess the number of cols we need
  par(mfrow=c(2,ncol))
  for(i in 1:nobs.true){
    ## now make a plot
    for(j in 1:nparams){
      if(j==1){
        plot(xs, main.effects[[i]]$mat[,j], col=colvec[j], lwd=2, lty=j,
             ylim=range(main.effects[[i]]$mat)+0.2*range(main.effects[[i]]$mat),
             ylab="predicted output (arb)", xlab="param value (arb)", type="l")
      }
      lines(xs, main.effects[[i]]$mat[,j], col=colvec[j], lwd=2, lty=j)
      if(i==1){ ## only plot the legend once
        legend("bottomright", fit.pca$params,
               col=colvec, lwd=rep(2, nparams), lty=1:nparams)
      }
      title(main=paste("(true) obs.", i))
    }
  }
    
  invisible(list(xs=xs, yeff.list=main.effects))
}
