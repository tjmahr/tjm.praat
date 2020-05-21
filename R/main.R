
#' Make a function that runs a Praat script
#' @export
wrap_praat_script <- function(
  praat_location,
  script_code_to_run,
  return = c("last-argument", "info-window")
) {
  return <- match.arg(return)

  # Make a script file to run
  script_file_to_run <- tempfile(fileext = ".praat")
  writeLines(script_code_to_run, con = script_file_to_run)

  function(...) {
    if (return == "info-window") {
      # Return what would be printed to InfoWindow
      results <- system2(
        praat_location,
        c("--ansi", "--run", script_file_to_run, ...),
        stdout = TRUE
      )
      return(results)
    } else if (return == "last-argument") {
      # Return the script's final argument, so that output files can
      # pipe into other functions
      results <- system2(
        praat_location,
        c("--ansi", "--run", script_file_to_run, ...)
      )
      return(...elt(...length()))
    }
  }
}

#' @export
set_textgrid_ext <- function(xs) {
  paste0(tools::file_path_sans_ext(xs), ".TextGrid")
}


#' Create a silences textgrid
#'
#' @format A Praat script
#' \describe{
#'   \item{wav_file_in}{path for the wave to read}
#'   \item{textGrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/create_silences_textgrid.Rmd
#'
#' @section Source code:
#'
#'#' ```{r, echo = FALSE, comment = ""}
#' create_silences_textgrid
#' ```
"create_silences_textgrid"


#' Merge duplicated interval labels
#'
#' If successive intervals have the same label, they are merged together.
#'
#' @format A Praat script
#' \describe{
#'   \item{textGrid_in}{path of the textgrid file to read in}
#'   \item{target_tier}{tier to update}
#'   \item{textGrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/merge_duplicate_intervals.Rmd
#'
#' @section Source code:
#'
#' ```{r, echo = FALSE, comment = ""}
#' merge_duplicate_intervals
#' ```
"merge_duplicate_intervals"
