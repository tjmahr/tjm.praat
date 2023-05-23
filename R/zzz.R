.onLoad <- function(libname, pkgname) {
  op <- options()

  path <- Sys.which("praat")
  option_value <- if (path != "") path else NULL

  op_tjm.praat <- list(
    tjm.praat_location = option_value
  )

  toset <- !(names(op_tjm.praat) %in% names(op))
  if (any(toset)) options(op_tjm.praat[toset])

  invisible()
}
