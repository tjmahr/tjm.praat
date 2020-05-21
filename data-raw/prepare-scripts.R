create_silences_textgrid <- glue::glue('
  form Make silence text grid
      sentence Wav_file_in
      sentence TextGrid_out
  endform
  Read from file: wav_file_in$
  To TextGrid (silences): 100, 0, -25, 0.1, 0.1, "silent", "sounding"
  Save as text file: textGrid_out$
')

merge_duplicate_intervals <-
  glue::as_glue(readLines("./data-raw/merge-duplicate-intervals.praat"))

usethis::use_data(create_silences_textgrid, overwrite = TRUE)
usethis::use_data(merge_duplicate_intervals, overwrite = TRUE)
