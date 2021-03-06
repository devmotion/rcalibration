#' Load namespace of CalibrationErrors.jl and CalibrationTests.jl
#'
#' @export
load <- function() {
  # Define RCalibration submodule
  JuliaCall::julia_command(paste0('include("', system.file("julia/RCalibration.jl", package = "rcalibration"), '");'))

  # Obtain exports of CalibrationErrors and CalibrationTests
  mods <- c("RCalibration.CalibrationErrors", "RCalibration.CalibrationTests")
  exports <- unique(unlist(lapply(mods, julia_exports)))

  JuliaCall::julia_pkg_import("Main.RCalibration", exports)
}

#' Obtain a list of exported symbols with valid identifiers
julia_exports <- function(mod) {
  cmd <- paste0("filter(isascii, map(x -> replace(string(x), \"!\" => \"_bang\"), propertynames(", mod, ")))")
  JuliaCall::julia_eval(cmd)
}
