
#' Praat location
#' @param path k
#' @return k
#' @export
#' @rdname praat_location
set_praat_location <- function(path) {
  options("tjm.praat_location" = path)
  path
}

#' @rdname praat_location
#' @export
get_praat_location <- function() {
  getOption("tjm.praat_location")
}


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
wrap_praat_script <- function(
  praat_location,
  script_code_to_run,
  return = c("last-argument", "info-window")
) {
  return <- match.arg(return)

  # Make a script file to run
  script_file_to_run <- tempfile(fileext = ".praat")
  writeLines(script_code_to_run, con = script_file_to_run)

  f <- function(...) {
    if (return == "info-window") {
      # Return what would be printed to InfoWindow
      results <- system2(
        praat_location,
        c(
          "--utf8", "--run",
          shQuote(script_file_to_run),
          vapply(list(...), shQuote, "")
        ),
        stdout = TRUE
      )
      return(results)
    } else if (return == "last-argument") {
      # Return the script's final argument, so that output files can
      # pipe into other functions
      results <- system2(
        praat_location,
        c(
          "--utf8", "--run",
          shQuote(script_file_to_run),
          vapply(list(...), shQuote, "")
        )
      )
      return(...elt(...length()))
    }
  }
  class(f) <- c("wrapped_praat_script", "function")
  attr(f, "script") <- script_code_to_run
  attr(f, "returning") <- return
  attr(f, "location") <- script_file_to_run
  f
}

#' @export
print.wrapped_praat_script <- function(x, condense = TRUE, ...) {
  l <- format(x, condense = condense)
  cli::cli({
      cli::cli_text(l$signature)
      cli::cli_text("# <wrapped_praat_script>")
      cli::cli_text("# <returning: {.field {l$returning}}>")
      cli::cli_code(cli::style_italic(l$script_lines), language = "praat")
    })
  invisible(x)
}

#' @export
format.wrapped_praat_script <- function(x, condense = TRUE, ...) {
  signature <- format(args(x))[1]

  # separate into lines if needed
  script <- attr(x, "script") |>
    strsplit("\\n") |>
    # splitting on lines of just `"\\n"` leaves `character(0)` values
    # so replace with `""` strings
    lapply(function(x) if(length(x) == 0) "" else x) |>
    unlist()

  script_lines <- script

  if (condense) {
    # extract form or first 6 lines
    form <- get_praat_form(paste0(script, collapse = "\n"))
    found_form <- grepl("form", form)
    if (found_form) {
      script_lines <- strsplit(form, "\n") |> unlist()
    } else {
      script_lines <- utils::head(script)
    }

    # abbreviate script if needed
    if (length(script_lines < length(script))) {
      n_more_lines <- length(script) - length(script_lines)
      line_label <- ngettext(n_more_lines, "line", "lines")
      comment <- glue::glue("# ... with {n_more_lines} more {line_label}")
      script_lines <- c(script_lines, comment)
    }
  }

  l <- list(
    returning = attr(x, "returning"),
    signature = signature,
    script_lines = script_lines
  )
  l
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


#' Bind (copy) tiers from one textgrid onto another textgrid
#'
#' The name is meant to evoke `dplyr::bind_rows()` which "stacks" one dataframe
#' on top of another. Here we pull selected tiers from one textgrid and bind
#' them onto another other one.
#'
#' @format A Praat script
#' \describe{
#'   \item{textgrid_receiver}{path of the textgrid file to update (attach tiers onto)}
#'   \item{textgrid_sender}{path of the textgrid file to extract tiers from}
#'   \item{tiers_to_pull}{comma-separated names of tiers to extract}
#'   \item{textgrid_out}{path of the textgrid file to create}
#' }
#'
#' @includeRmd inst/demos/bind_tiers.Rmd
"bind_tiers"

