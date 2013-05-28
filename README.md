Mlegp Command Line Interface
==============================

ccs, cec24@phy.duke.edu
09.05.2013

A Rscript driven command line interface to the wonderful Mlegp package.
http://cran.r-project.org/web/packages/mlegp/index.html

Contents
=======

#### MlegpInter
A small R library (mlegpInter) with some helper functions to make
predictions from an mlegp GP list (in ./R-pkg)

#### Scripts
- _mlegp-interactive-train.R_: train a set of GP's on a multivariate
  data set with multivariate output.
- _mlegp-interactive-predict.R_: make predictions (mean, variance,
  covariance) from the trained GP's produced by
  "mlegp-interactive-train", reads points in parameter space from
  stdin, prints output to stdout
- _mlegp-interactive-implaus.R_: output the joint and independent
  implausibility for a given set of trained GP's. Needs a file
  containing the observed means and std.errors.

Depends
=======

- R (tested on 2.15.2, 2.15.3), Rscript
- R packages: mlegpFull (get this from the maintainer), adapt, optparse


Installing
=========

### Install the R Package

- The library depends upon the following R packages: optparse, mlegp, adapt, mlegpFull
  the latter can be obtained directly from the mlegp maintainer. You can install any missing dependencies
  via R by using the `install.packages` command.

`cd ./R-pkg`
- tell R to build the library and install it
`R CMD INSTALL .`
  
- you can access the lib in R with:
`library(mlegpInter)`
but there's basically no need to.

### Install the Scripts

- copy the contents of scripts to somewhere in your path, or leave
  them where they are.

Usage
=====

- see /example/mw1-5param-example/README.md for a full example

Plotting Main Effects
=====

If you've trained a multivariate GP using the
_melgp-interactive-train_ script you can now make plots of the main
effects in the true and pca basis (of the outputs). There's no direct
command line support for this but it's easy to do from an R
terminal. The functions provided by this library just wrap the
mlegpFull

- _plot.main.effects.pca_ plots the effects in the pca basis
- _plot.main.effects.true_ plots the effects in the true basis

both functions also return a list of matrices of the main effects for each
observable that can be written to file etc.


Suppose that you've saved the data from the training process into
"trained-emu-save.dat", to plot the main effects in the PCA basis
do the following in an R process:

```library(mlegpFull)
library(mlegpInter)
load("trained-emu-save.dat")
main.pca.table <- plot.main.effects.pca(fit.pca)```

This will produce a set of graph panels on the default device and
main.pca.table will be init to a list of the main effects. Each list
item is a matrix of the effects for a given PCA observable with the
first column as the arbitrary index on the parameter space and then
each column giving the predicted main effect for that parameter.

The process is the same for plotting the main effects in the *true*
basis but one needs to supply the training scale info. This saved by
default as `training.scale.info` in the file created by the mlegp
fitting process.

```library(mlegpFull)
library(mlegpInter)
load("trained-emu-save.dat")
main.pca.table.true <- plot.main.effects.true(fit.pca, train.scale.info=training.scale.info)```

The resulting table can be saved to disk etc. 


TODO
=====

- add the code for the senstivity analysis to the R lib and a command line interface
- check the design/model-data for actually being numeric and complain appropriately

