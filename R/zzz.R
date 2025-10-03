.onLoad <- function(libname, pkgname) {
  op <- options()

  path <- unname(Sys.which("praat")[1])
  option_value <- if (file.exists(path)) {
    normalizePath(path, winslash = "/")
  } else {
    NULL
  }
  op_tjm.praat <- list(
    tjm.praat_location = option_value
  )

  toset <- !(names(op_tjm.praat) %in% names(op))
  if (any(toset)) options(op_tjm.praat[toset])

  invisible()
}
