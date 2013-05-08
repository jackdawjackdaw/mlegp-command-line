chemtree-5param-example
======================

An example from the chemtree N round robin data set. 

To get started you need to have installed: mlegpFull and adapt

1 - training mlegp 
----------------------

To train a GP with mlegp we need: 

- a design file: the set of points at which the model was run. The
	first line should be the names of the design variables
	
- a training file: the set of model outputs. The training file should
	be sorted so that the n'th output line corresponds to the n'th
	location in the design file.

with Rscript we can run the file "mlegp-interactive-train-pca.R", this
takes paths to the designFile and training files along with a path to
the save file.

Suppose you're at the top level of this project

`Rscript ./R/mlegp-interactive-train-pca.R ./example/mw1-5param-example/design_MW1.dat ./example/mw1-5param-example/combined-training.dat ./example/mw1-5param-example/training-test.dat ./example/mw1-5param-example/save-file.dat`


2 - sampling the gp
----------------------

Once you've trained the gp the mean, variance and covariance can be
interactively sampled with 'mlegp-interactive-predict.R'. This takes
the path to a save file made by 'mlegp-interactive-train-pca.R' as the first argument.



3 - sampling the implaus
----------------------



