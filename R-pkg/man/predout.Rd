\name{predict.output.at.point}
\alias{predict.output.at.point}
\title{Predict mlegp output at a point}
\description{
	make a prediction of trained gp at a given point
	return the mean, var and var matrix for the given input point.
	}
	\usage{
		predict.output.at.point(xpt, fit.pca, train.scale.info, des.scale.info)
	}
	\arguments{
		\item{xpt} a vector of length fit.pca$numDim
		\item{fit.pca} a gp list produced by mlegp
		\item{train.scale.info} list of scales and centers for the training
		data, produced during the fitting process
		\item{des.scale.info} list of scales and centers for the design,
		produced during the fitting process
		}
	\value{
		a list with components: mean, var, varMat which contain the
		reconstructed mean, variance and covarance matrices of the gp at the
		given input point

		If train.scale.info and des.scale.info are not given (are null) then
		the input point is taken as being already scaled and the output is
		given in the scaled coordinates. 
	}