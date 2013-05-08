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
		\item{obs.means.scaled} a vector of the observation means scaled to
		the same scalings as the training data used to generate the gp
		\item{obs.errs.scaled} a vector of the std errors for the
	observation means.
	}
	\value{
		a list with components: implaus.inde, implaus.joint

		implaus.inde is the implausibility for the individual pca components
		implaus.joint is the joint implausibility created using the
		covaraince matrix

	}