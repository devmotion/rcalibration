#' Load namespace of CalibrationErrors.jl and CalibrationTests.jl
#'
#' @export
load <- function() {
  ce = wrap_julia_pkg("CalibrationErrors")
  ct = wrap_julia_pkg("CalibrationTests")
  as.environment(sapply(c(ce, ct), as.list))
}

wrap_julia_pkg <- function(pkg) {
  # precompile and load Julia package
  JuliaCall::julia_library(pkg)

  # obtain a list of exported symbols with valid identifiers
  cmd <- paste0("filter(isascii, map(x -> replace(string(x), \"!\" => \"_bang\"), propertynames(", pkg, ")))")
  exports <- JuliaCall::julia_eval(cmd)

  JuliaCall::julia_pkg_import(pkg, func_list = exports)
}
