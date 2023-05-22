#' Read a Praat spectrogram file produced by Praat
#' @param path path to a .Spectrogram file
#' @return a dataframe with the Spectrogram data
#' @export
read_spectogram <- function(path) {
  lines <- readLines(path)

  powers <- lines |>
    stringr::str_match("z \\[(\\d+)\\] \\[(\\d+)\\] = (\\S+) ") |>
    as.data.frame() |>
    stats::setNames(c("line", "y", "x", "power"))

  # ugly bc i removed dplyr functions
  powers <- powers[!is.na(powers$line), 2:4] |>
    lapply(as.numeric) |>
    as.data.frame()

  create_praat_sequence <- function(nx, dx, x1) {
    seq(from = x1, length.out = nx, by = dx)
  }

  # the x and y values follow sequences which we reconstruct
  values <- lines[1:15] |>
    stringr::str_subset(
      "(nx|dx|x1|ny|dy|y1) = (\\S+) "
    ) |>
    stringr::str_match(
      "(nx|dx|x1|ny|dy|y1) = (\\S+) "
    )

  seq_rules <- values[, 3] |>
    as.numeric() |>
    as.list() |>
    stats::setNames(values[, 2])

  xs <- create_praat_sequence(seq_rules$nx, seq_rules$dx, seq_rules$x1)
  ys <- create_praat_sequence(seq_rules$ny, seq_rules$dy, seq_rules$y1)

  powers$time <- xs[powers$x]
  powers$frequency <- ys[powers$y]

  # Pa^2/Hz is stored in spectrograms, but db/Hz are drawn
  # https://www.fon.hum.uva.nl/praat/manual/power_spectral_density.html
  db <- 10 * log10(powers$power / (0.000020 ^ 2))

  # 70 dB dynamic range
  # https://www.fon.hum.uva.nl/praat/manual/Spectrogram__Paint___.html
  db <- db - (max(db) - 70)
  db <- ifelse(0 > db, 0, db)
  powers$db <- db
  powers
}
