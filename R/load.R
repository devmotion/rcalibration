#' Load namespace of CalibrationErrors.jl
#'
#' @export
calerrors <- function() wrap_julia_pkg("CalibrationErrors")

#' Load namespace of CalibrationTests.jl
#'
#' @export
caltests <- function() wrap_julia_pkg("CalibrationTests")

wrap_julia_pkg <- function(pkg) {
  # precompile and load Julia package
  JuliaCall::julia_command(paste0("using ", pkg, ": ", pkg))

  # obtain a list of exported symbols with valid identifiers
  cmd <- paste0("filter(isascii, map(string, propertynames(", pkg, ")))")
  exports <- JuliaCall::julia_eval(cmd)

  JuliaCall::julia_pkg_import(pkg, func_list = exports)
}
