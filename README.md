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
- mlegp-interactive-train.R: train a set of GP's on a multivariate
  data set with multivariate output.
- mlegp-interactive-predict.R: make predictions (mean, variance,
  covariance) from the trained GP's produced by
  "mlegp-interactive-train", reads points in parameter space from
  stdin, prints output to stdout
- mlegp-interactive-implaus.R: output the joint and independent
  implausibility for a given set of trained GP's. Needs a file
  containing the observed means and std.errors.

Depends
=======

- R (tested on 2.15.2, 2.15.3), Rscript
- R packages: mlegpFull (get this from the maintainer), adapt


Installing
=========

### Build the R Package

`cd ./R-pkg`
- tell R to build the library and install it
`R CMD INSTALL .`
- you can access the lib in R with:
`library(mlegpInter)`
but there's basically no need to.

### Install the Scripts

- copy the contents of scripts to somewhere in your path, or leave
  them where they are.


TODO
=====

- add the code for the senstivity analysis to the R lib and a command line interface
- check the design/model-data for actually being numeric and complain appropriately
- write up examples and install process

