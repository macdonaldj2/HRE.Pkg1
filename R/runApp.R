#' @export
runApp <- function() {
  appDir <- system.file("HREApp1", package = "HRE.Pkg1")
  if (appDir == "") {
    stop("Could not find example directory. Try re-installing `ShinyPkg.Teste`.", call. = FALSE)
  }

  shiny::runApp(appDir, display.mode = "normal")
}
