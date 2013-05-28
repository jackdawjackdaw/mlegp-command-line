\name{plot.main.effects.true}
\alias{plot.main.effects.true}
\title{Plot Main Effects Nicely}
\description{
	Make a nice set of plots of the main effects, in the true basis
}
\usage{
		plot.main.effects.true(fit.pca, train.scale.info, plot.leg=TRUE,
title.stub="true obs:") 
	}
\arguments{
	\item{fit.pca} a gp list produced by mlegp
	\item{train.scale.info} optional list of scales and centers for the training
	data, if this is supplied the main effects are plotted/returned unscaled/uncentered
	\item{plot.leg} Include a legend in the bottom right
	\item{title.stub} Stub for the title of each sub plot, the full title
	is expanded to: title.stub <obs-number>
}
\value{
	Plots of the main effects in the *true basis* are drawn to the
	default device.

	Returns a list of the main effects in the rotated basis
}