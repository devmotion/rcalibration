# setup Julia dependencies
rcalibration::install()

# install and load package for sampling from Dirichlet distribution
if (!require(extraDistr)) install.packages("extraDistr")
library(extraDistr)
