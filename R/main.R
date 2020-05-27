
#' Make a function that runs a Praat script
#'
#' @param praat_location path to the Praat executable
#' @param script_code_to_run Praat script to run
#' @param return value to return. `"last-argument"` returns the last argument to
#'   the Praat script. `"info-window"` returns the contents of the Praat Info
#'   Window.
#' @return see `return` argument
#' @export
#'
#' @details This function basically sets up a call to Praat's command-line
#'   interface using `system2()`.
#'
#'
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
        c("--utf8", "--run", script_file_to_run, ...),
        stdout = TRUE
      )
      return(results)
    } else if (return == "last-argument") {
      # Return the script's final argument, so that output files can
      # pipe into other functions
      results <- system2(
        praat_location,
        c("--utf8", "--run", script_file_to_run, ...)
      )
      return(...elt(...length()))
    }
  }
}

#' Extract the form from a Praat script
#' @param x a single string (a Praat script)
#' @return the lines of text from `form` to `endform`
#' @export
#' @examples
#' get_praat_form(duplicate_tier)
get_praat_form <- function(x) {
  start <- regexpr("form.*endform", x)
  end <- attr(regexpr("form.*endform", x), "match.length")
  substring(x, start, end)
}

#' Set the file-extension in a path to `.TextGrid`
#' @param xs paths or filenames
#' @return the paths with their extensions replaced with `.TextGrid`
#' @export
#' @examples
#' set_textgrid_ext("C:/Programs/Nullsoft/Winamp/Demo.mp3")
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

