
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
#'   \item{textgrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/create_silences_textgrid.Rmd
"create_silences_textgrid"


#' Merge duplicated interval labels
#'
#' If successive intervals have the same label, they are merged together.
#'
#' @format A Praat script
#' \describe{
#'   \item{textgrid_in}{path of the textgrid file to read in}
#'   \item{target_tier}{tier to update}
#'   \item{textgrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/merge_duplicate_intervals.Rmd
"merge_duplicate_intervals"


#' Duplicate a textgrid tier
#'
#' Duplicate (and rename) a textgrid tier.
#'
#' @format A Praat script
#' \describe{
#'   \item{textgrid_in}{path of the textgrid file to read in}
#'   \item{target_tier}{tier to copy}
#'   \item{duplicate_name}{name to use for the duplicated tier}
#'   \item{duplicate_position}{where to place the new tier: `last` (default),
#'   `first`, `before` or `after` the original.}
#'   \item{textgrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/duplicate_tier.Rmd
"duplicate_tier"


#' Convert a textgrid tier into a "silences" tier
#'
#' Interval text that matches the silence pattern is replaced with `"silent"`.
#' All others are replaced with `"sounding"`.
#'
#' @format A Praat script
#' \describe{
#'   \item{textgrid_in}{path of the textgrid file to read in}
#'   \item{target_tier}{tier to copy}
#'   \item{silence_regex}{regular expression (regex) used to indentify
#'   silences. Current default is `^$|sil|sp` which treats empty strings (`^$`)
#'   or (`|`) a string containing `sil` or a string containing `sp` as
#'   silences.}
#'   \item{textgrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/convert_tier_to_silences.Rmd
"convert_tier_to_silences"

