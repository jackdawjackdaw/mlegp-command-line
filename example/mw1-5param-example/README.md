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

After installing the R library, 

`../../scripts/mlegp-interactive-train-pca.R ./design_MW1.dat ./combined-training.dat ./save-file.dat`

This will call the estimation process in MLEGP, essentially training a
GP with design data from "./design_MW1.dat" and training data from
"combined-training.dat". The mlegp fit.list object along with the
scaling information for the design and the output will be written into "./save-file.dat"

If you start an R session now you can use the load command to examine
the data, look at the mlegp help docs for more information


2 - sampling the gp
----------------------

Once you've trained the gp the mean, variance and covariance can be
interactively sampled with 'mlegp-interactive-predict.R'. This takes
the path to a save file made by 'mlegp-interactive-train-pca.R' as the first argument.

`../../scripts/mlep-interactive-predict.R ./save-file.dat`

points to sample are read from stdin, the emulated mean, variance and covariance matrix are printed to stdout (on separate lines)

3 - sampling the implaus
----------------------

The implaus can be sampled interactively, once the gp has been
trained, using 'mlegp-interactive-implaus.R'. This taeks the save file
and a file with the experimentally observed data as arguments. The
observed data file should have as many columns as there are
observables in the training data and two rows. The first row should be
the observed mean values and the second row should be the std errors.

`../../scripts/mleg-interactive-implaus.R ./save-file.dat ./obs-data.txt`

points to sample are again read from stdin, the joint implaus and the
independen implausibilities are written on separate lines.

The interactive-implaus script takes an optional argument (-v,
--verbose), before the file paths. This turns on echoing of the
joint-implaus and the point in the design path to stderr. This is
useful for debugging while directly using the output. 
