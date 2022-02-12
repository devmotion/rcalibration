#' Install Julia dependencies of rcalibration
#'
#' This function installs the Julia dependencies of rcalibration.
#' Note that the first initialization will take more time since it
#' includes precompilation.
#
#' @export
install <- function() {
  JuliaCall::julia_command(paste0('import Pkg; Pkg.develop(Pkg.PackageSpec(; path="', system.file("julia/RCalibration", package = "rcalibration"), '")); Pkg.instantiate()'))
}
