#' Install Julia dependencies of rcalibration
#'
#' This function installs the Julia dependencies of rcalibration.
#' Note that the first initialization will take more time since it
#' includes precompilation.
#
#' @export
install <- function() {
  JuliaCall::julia_command(paste0('include("', system.file("julia/install.jl", package = "rcalibration"), '")'))
}
