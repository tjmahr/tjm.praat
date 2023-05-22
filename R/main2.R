# f_merge_duplicate_intervals
# formals(f_merge_duplicate_intervals)
#
# script <- glue::glue('
#   form: "Create a spectrogram"
#   infile: "Wav_file_in", ""
#   positive: "Max_frequency", "5000"
#   outfile: "Spectrogram_out", ""
#   endform
#   Read from file: wav_file_in$
#     Pre-emphasize (in-place): 50
#   To Spectrogram: 0.005, max_frequency, 0.002, 20, "Gaussian"
#   Save as text file: spectrogram_out$
# ')
#
# script <- glue::glue("
#   form Draw a textgrid
#   sentence Textgrid_in
#   integer Width 6
#   integer Height 4
#   sentence Png_out
#   endform
# ")
#
# normalize_s

new_praat_function <- function(
  script_code_to_run,
  return = c("last-argument", "info-window"),
  praat_location = NULL
) {
  return <- match.arg(return)

  # Make a script file to run
  script_file_to_run <- tempfile(fileext = ".praat")
  writeLines(script_code_to_run, con = script_file_to_run)

  f <- function(...) {
    # Get the function arguments/values and make sure they match the
    # order of the formals
    args <- as.list(environment(), all = TRUE)
    args <- args[names(formals())]
    if (return == "info-window") {
      # Return what would be printed to InfoWindow
      results <- system2(
        praat_location,
        c(
          "--utf8", "--run",
          shQuote(script_file_to_run),
          vapply(args, shQuote, "")
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
          vapply(args, shQuote, "")
        )
      )
      return(args[[length(args)]])
    }
  }

  formals(f) <- extract_form_arguments(script_code_to_run)

  class(f) <- c("wrapped_praat_script", "function")
  attr(f, "script") <- script_code_to_run
  attr(f, "returning") <- return
  attr(f, "location") <- script_file_to_run
  f
}


extract_form_arguments <- function(script) {
  form_lines <- get_praat_form(script) |>
    strsplit("\\n") |>
    getElement(1)
  form_parts <- form_lines[-c(1, length(form_lines))] |>
    stringr::str_remove("^\\s+") |>
    stringr::str_split_fixed("( |, )", 3)

  args <- rep(list(NULL), nrow(form_parts))

  args <- form_parts[, 3] |>
    as.list() |>
    lapply(function(x) if (x %in% c("", "\"\"", "\'\'")) NULL else x)
  names(args) <- tolower(form_parts[, 2])

  args
}
#
# a <- get_praat_form(
#   script2
# )
# stringr::str
#
#
#
# formals(f) <- list(a = NULL, b = 10, c = NULL)
#
# alist()
#
#
# str(a)
