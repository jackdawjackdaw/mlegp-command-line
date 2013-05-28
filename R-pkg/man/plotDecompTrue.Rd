\name{plot.main.effects.true}
\alias{plot.main.effects.true}
\title{Plot Main Effects Nicely}
\description{
	Make a nice set of plots of the main effects, in the true basis
}
\usage{
		plot.main.effects.true(fit.pca, plot.leg=TRUE, ylim=c(-3,3))
	}
\arguments{
	\item{fit.pca} a gp list produced by mlegp
	\item{plot.leg} Include a legend
	\item{file.name.stub} the main effects for each observable are
	written out to a separate file, the supplied stub is suffixed with
	the observable index. 
}
\value{
	Plots of the main effects in the *true basis* are drawn to the
	default device.

	Returns a list of the main effects in the rotated basis
}