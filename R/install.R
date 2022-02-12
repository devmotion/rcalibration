#' Install Julia dependencies of rcalibration
#'
#' This function installs the Julia dependencies of rcalibration.
#' Note that the first initialization will take more time since it
#' includes precompilation.
#
#' @export
install <- function() {
  JuliaCall::julia_command("x = 2")
}
