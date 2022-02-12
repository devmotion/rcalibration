#' Install Julia dependencies of rcalibration
#'
#' This function installs the Julia dependencies of rcalibration.
#' Note that the first initialization will take more time since it
#' includes precompilation.
#
#' @export
install <- function() {
  # Update Julia LOAD_PATH
  load_path <- system.file("julia", package = "rcalibration")
  JuliaCall::julia_command(paste0('first(LOAD_PATH) != "', load_path, '" && pushfirst!(LOAD_PATH, "', load_path, '")'))

  # Install RCalibration package
  JuliaCall::julia_command('import Pkg; Pkg.add("RCalibration")')
}
