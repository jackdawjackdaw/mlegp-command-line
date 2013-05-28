\name{plot.main.effects.pca}
\alias{plot.main.effects.pca}
\title{Plot Main Effects Nicely}
\description{
	Make a nice set of plots of the main effects, in the PCA basis
}
\usage{
		plot.main.effects(fit.pca, nobs=6, file.name.stub="main-effects-", ylim.in=c(-1,1))
	}
\arguments{
	\item{fit.pca} a gp list produced by mlegp
	\item{nobs} the number of observables to produce main effects plots
	for. This should be less than or equal to total number of true
	observables or the 
	\item{file.name.stub} the main effects for each observable are
	written out to a separate file, the supplied stub is suffixed with
	the observable index.
	\item{ylim.in} The ylimits for the plots, defaults to -1 to 1
}
\value{
	Tables of the main effects for each observable are written out to
	disk.

	Plots of the main effects in the *PCA basis* are drawn to the
	default device.
}
\seealso{
	mlegpFULL:plotMainEffects
	}