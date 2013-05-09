\name{implaus.output.at.point}
\alias{implaus.output.at.point}
\title{Sample implausibility from mlegp output at a point}
\description{
	compute the joint implaus at a point
	needs obs mean and obs errors (scaled correctly)

	implaus_joint^2 = (E(f(x) - z))^t V^{-1} E(f(x) - z)
	where E(f(x)) is a vector of the emulator mean at the point x
	in the design space.
}
	\usage{
		implaus.output.at.point(xpt, fit.pca, obs.means.scaled, obs.errs.scaled)
	}
	\arguments{
		\item{xpt} a vector of length fit.pca$numDim
		\item{fit.pca} a gp list produced by mlegp
		\item{obs.means} a vector of the observation means 
		\item{obs.errs} a vector of the std errors for the
		observation means.
		\item{train.scale.info} the centers and scales for the training data
		\item{des.scale.info} the centers and scales for the design
	}
	\value{
		a list with components: implaus.inde, implaus.joint

		implaus.inde is the implausibility for the individual pca components
		implaus.joint is the joint implausibility created using the
		covaraince matrix

		If train.scale.info and des.scale.info are not given than the
		observables and their errors are taken as being already scaled to
		match the scales of the design and training data. In this case the
		predictions will be made as if xpt is unscaled. 

	}