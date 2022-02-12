#' Load namespace of CalibrationErrors.jl and CalibrationTests.jl
#'
#' @export
load <- function() {
  # Update Julia LOAD_PATH
  load_path <- system.file("julia/RCalibration", package = "rcalibration")
  JuliaCall::julia_command(paste0('first(LOAD_PATH) != "', load_path, '" && pushfirst!(LOAD_PATH, "', load_path, '");'))

  # Load RCalibration package
  JuliaCall::julia_library("RCalibration")

  # Obtain exports of CalibrationErrors and CalibrationTests
  mods <- c("RCalibration.CalibrationErrors", "RCalibration.CalibrationTests")
  exports <- unique(unlist(lapply(mods, julia_exports)))

  JuliaCall::julia_pkg_import("RCalibration", exports)
}

#' Obtain a list of exported symbols with valid identifiers
julia_exports <- function(mod) {
  cmd <- paste0("filter(isascii, map(x -> replace(string(x), \"!\" => \"_bang\"), propertynames(", mod, ")))")
  JuliaCall::julia_eval(cmd)
}
