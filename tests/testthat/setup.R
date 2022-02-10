# setup Julia dependencies
Sys.setenv(LD_LIBRARY_PATH = "")
rcalibration::install()

# install and load package for sampling from Dirichlet distribution
if (!require(extraDistr)) install.packages("extraDistr")
library(extraDistr)
