Steps for adding a new Praat script.

  - Get it to work in Praat
  - Save the source code in `data-raw/snips` as a `.txt` file
  - Update `data-raw/prepare-scripts.R` to handle the script and add it to the
    package data
  - Add the script and its documentation in `R/main.R`
  - Create an RMarkdown demo for the script in `inst/demos`, adding any
    necessary files for the demo to `inst`
  - Build, document, build
  - Check the documentation and the demo for the code
  - Add the script to `_pkgdown.yml`
  - Run `pkgdown::build_site()` and check the generated documentation page
