\name{predict.output.at.point}
\alias{predict.output.at.point}
\title{Predict mlegp output at a point}
\description{
	make a prediction of  trained gp at a given point
	return the mean, var and var matrix for the given input point
	}
	\usage{
		predict.output.at.point(xpt, fit.pca)
	}
	\arguments{
		\item{xpt} a vector of length fit.pca$numDim
		\item{fit.pca} a gp list produced by mlegp
	}
	\value{
		a list with components: mean, var, varMat which contain the
		reconstructed mean, variance and covarance matrices of the gp at the
		given input point
	}