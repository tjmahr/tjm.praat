# I want to reuse procedure definitions across files. So, the .txt files in
# data-raw/snips/ are Praat scripts written with glue {placeholders}. These are
# filled in when this script is run. The full, un-templated scripts are saved
# into data-raw.

library(magrittr)

read_praat_script <- function(x) {
  x %>%
    readLines() %>%
    glue::glue_collapse("\n") %>%
    glue::as_glue()
}

# Reuse code by using {templates} and filling the templates using glue
snips <- list.files("data-raw/snips/", full.names = TRUE)

snips_list <- snips %>%
  lapply(read_praat_script) %>%
  setNames(tools::file_path_sans_ext(basename(snips)))



# Write out untransformed scripts
create_silences_textgrid <- snips_list$`create-silences-textgrid` %T>%
  writeLines("data-raw/create-silences-textgrid.praat")



# Fill in placeholder code in the snips
merge_duplicate_intervals <- snips_list$`merge-duplicate-intervals` %>%
  glue::glue_data(snips_list, . ) %T>%
  writeLines("data-raw/merge-duplicate-intervals.praat")



usethis::use_data(create_silences_textgrid, overwrite = TRUE)
usethis::use_data(merge_duplicate_intervals, overwrite = TRUE)
