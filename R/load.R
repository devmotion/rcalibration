#' Load namespace of CalibrationErrors.jl and CalibrationTests.jl
#'
#' @export
load <- function() wrap_julia_pkgs(c("CalibrationErrors", "CalibrationTests"))

wrap_julia_pkgs <- function(pkg_list) {
  exports <- unique(unlist(lapply(pkg_list, julia_exports)))
  julia_pkgs_import(pkg_list, func_list = exports)
}

julia_exports <- function(pkg) {
  # Precompile and load Julia package
  JuliaCall::julia_library(pkg)

  # Obtain a list of exported symbols with valid identifiers
  cmd <- paste0("filter(isascii, map(x -> replace(string(x), \"!\" => \"_bang\"), propertynames(", pkg, ")))")
  exports <- JuliaCall::julia_eval(cmd)

  exports
}

# Copied from JuliaCall and extended to multiple packages
julia_pkgs_import <- function(pkg_list, func_list,
                             env = new.env(parent = emptyenv())){
  env$setup <- function(...){
    JuliaCall::julia_setup(...)
    for (pkg in pkg_list) {
      JuliaCall::julia_library(pkg)
    }
    for (hook in env$hooks) {
      if (is.function(hook)) {hook()}
      else {warning("Some hook is not a function.")}
    }
    env$initialized <- TRUE
  }
  for (fname in func_list) {
    JuliaCall::julia_function(func_name = fname,
                   pkg_name = pkg_name,
                   env = env)
  }
  reg.finalizer(env,
                function(e) e$initialized <- FALSE,
                onexit = TRUE)
  env
}