
#' Get or set the location of the Praat executable
#'
#' @param path the full path to the Praat executable
#' @return the full path to the Praat executable
#' @export
#' @details
#'
#' `set_praat_location()` sets an R [options()] for
#' `options("tjm.praat_location")`. `get_praat_location()` retrieves the value
#' of this option.
#'
#' ## Default location
#'
#' On package load, this package checks for a pre-existing value in
#' `options("tjm.praat_location")` and defers to that value. If there is no such value,
#' this package then searches the system PATH using [Sys.which()] on `"praat"`.
#' If Praat is not found on the PATH, `NULL` is used.
#'
#' A user can set a default location for Praat by 1) adding it to their PATH.
#' For example, I use a folder called `bin` in my Documents folder. My copy of
#' Praat.exe lives in this folder, and this folder is on my user PATH on
#' Windows. Alternatively, a user can 2) add a line like
#' `options(tjm.praat_location = [value])` to a .Rprofile file so that the
#' option is set at the start of each R session.
#'
#' @rdname praat_location
set_praat_location <- function(path) {
  options(tjm.praat_location = normalizePath(path, "/"))
  getOption("tjm.praat_location")
}

#' @rdname praat_location
#' @export
get_praat_location <- function() {
  getOption("tjm.praat_location")
}


#' Make a function that runs a Praat script
#'
#' @param script_code_to_run a Praat script to run.
#' @param returning value to return. `"last-argument"` returns the last argument to
#'   the Praat script. `"info-window"` returns the contents of the Praat Info
#'   Window.
#' @param praat_location path to the Praat executable. Defaults to the value
#'   provided by [get_praat_location()].
#' @return see `return` argument
#' @export
#'
#' @details This function basically sets up a call to Praat's command-line
#'   interface using `system2()`.
wrap_praat_script <- function(
  script_code_to_run,
  returning = c("last-argument", "info-window"),
  praat_location = get_praat_location()
) {
  returning <- match.arg(returning)

  # Make a script file to run
  script_file_to_run <- tempfile(fileext = ".praat")
  writeLines(script_code_to_run, con = script_file_to_run)

  f <- function(...) {
    args <- as.list(environment(), all = TRUE)
    args <- args[names(formals())]

    std_out <- if (returning == "info-window") TRUE else ""

    results <- system2(
      praat_location,
      c(
        "--utf8", "--run",
        shQuote(script_file_to_run),
        vapply(args, shQuote, "")
      ),
      stdout = std_out
    )

    if (returning == "last-argument") {
      results <- args[[length(args)]]
    }

    results
  }

  formals(f) <- extract_form_arguments(script_code_to_run)
  class(f) <- c("wrapped_praat_script", "function")
  attr(f, "script") <- script_code_to_run
  attr(f, "returning") <- returning
  attr(f, "location") <- script_file_to_run
  f
}

extract_form_arguments <- function(script) {
  unquote <- function(xs) {
    xs |>
      stringr::str_remove("\\W+$") |>
      stringr::str_remove("^\\W")
  }

  form_lines <- get_praat_form(script) |>
    strsplit("\\n") |>
    getElement(1)

  form_parts <- form_lines[-c(1, length(form_lines))] |>
    # ignore lines where form has multiple-choice button selection
    stringr::str_subset("\\s+button", negate = TRUE) |>
    stringr::str_remove("^\\s+") |>
    stringr::str_split_fixed("( |, )", 3)

  args <- rep(list(NULL), nrow(form_parts))

  args <- form_parts[, 3] |>
    unquote() |>
    as.list() |>
    lapply(function(x) if (x %in% "") NULL else x)

  names(args) <- form_parts[, 2] |>
    tolower() |>
    unquote()

  args
}


#' @export
print.wrapped_praat_script <- function(x, condense = TRUE, ...) {
  l <- format(x, condense = condense)
  cli::cli({
      cli::cli_text(l$signature)
      cli::cli_text("# {.cls wrapped_praat_script}")
      cli::cli_text("# returning: {.val {l$returning}}")
      cli::cli_code(cli::style_italic(l$script_lines), language = "praat")
    })
  invisible(x)
}

#' @export
format.wrapped_praat_script <- function(x, condense = TRUE, ...) {
  signature <- format(args(x))
  signature <- signature[-length(signature)]

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
#' @details
#'
#' ```{r child = "inst/demos/create_silences_textgrid.Rmd"}
#' ```
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
#' @details
#'
#' ```{r child = "inst/demos/merge_duplicate_intervals.Rmd"}
#' ```
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
#' @details
#'
#' ```{r child = "inst/demos/duplicate_tier.Rmd"}
#' ```
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
#' @details
#'
#' ```{r child = "inst/demos/convert_tier_to_silences.Rmd"}
#' ```
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
#' @details
#'
#' ```{r child = "inst/demos/bind_tiers.Rmd"}
#' ```
"bind_tiers"


#' Create a spectrogram
#'
#' @format A Praat script
#' \describe{
#'   \item{wav_file_in}{path for the wave to read}
#'   \item{max_frequency}{maximum frequency to show for the spectrogram}
#'   \item{spectrogram_out}{path of the .Spectrogram file to create}
#' }
#'
#' @details
#'
#' ```{r child = "inst/demos/create_spectrogram.Rmd"}
#' ```
"create_spectrogram"


