
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tjm.praat

<!-- badges: start -->
<!-- badges: end -->

The goal of tjm.praat is to make it easier to run
[Praat](http://www.fon.hum.uva.nl/praat/) scripts as part of an R
workflow. This package provides one main function `wrap_praat_script()`,
plus some scripts designed to work with this function. The name
`tjm.praat` indicates that the package houses my (tjm’s) `.praat` files.

## Installation

You can install tjm.praat from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("tjmahr/tjm.praat")
```

## Example of wrapping a Praat script as a function

Let’s make a function that draws a Praat textgrid and saves the image as
`.png` file. First, let’s make the minimal working Praat script, and
store it as a string in R. We use `glue::glue()` because it cleans up
the leading and trailing blank lines and the indentations on the string.

``` r
script <- glue::glue(
  '
  form Draw a textgrid
    sentence Textgrid_in
    integer Width 6
    integer Height 4
    sentence Png_out
  endform

  Read from file: textgrid_in$
  Select outer viewport: 0, width, 0, height
  
  Draw: 0, 0, "yes", "yes", "yes"
  Save as 300-dpi PNG file: png_out$
  '
)
```

Before we can wrap the script into a function, we need to set the
**Praat location**. By default, tjm.praat searches for a location in
`options("tjm.praat_location")` and `Sys.which("praat")`. So, on my
machine, tjm.praat manages to find a Praat executable:

``` r
library(tjm.praat)
get_praat_location()
#> [1] "C:/Users/trist/Documents/bin/Praat.exe"
```

But if I want to set or override this location, I can set the location
for the R session. For example, here I point to the copy of Praat.exe on
my desktop.

``` r
# Trying to use a relative path for the demo. 
# (These are normalized anyways).
set_praat_location("~/../Desktop/Praat.exe")
#> [1] "C:/Users/trist/Desktop/Praat.exe"

get_praat_location()
#> [1] "C:/Users/trist/Desktop/Praat.exe"
```

Now, we can convert this script into an R function. We tell
`wrap_praat_script()` to return the last argument of the script
(`png_out$` in this example) back to R after the script runs.

``` r
f_draw_textgrid <- wrap_praat_script(
  script_code_to_run = script,
  return = "last-argument"
)
```

Now we set up the file arguments to script. First, we need a textgrid
file. Let’s use a textgrid bundled with the package. The textgrid shows
the results of a forced-alignment on the phrase “bird house”.

``` r
tg_in <- system.file(
  "demo-textgrids/birdhouse.TextGrid", 
  package = "tjm.praat"
)
```

We also need a place to save the image. I’m going to use a temporary
file.

``` r
png_out <- tempfile("birdhouse", fileext = ".png")
```

Shoot. I just forgot what the arguments are to this script. That’s okay,
we can **print the function to view the script form**.

``` r
f_draw_textgrid
#> function (textgrid_in = NULL, width = "6", height = "4", png_out = NULL)
#> # <wrapped_praat_script>
#> # returning: "last-argument"
#> form Draw a textgrid
#>   sentence Textgrid_in
#>   integer Width 6
#>   integer Height 4
#>   sentence Png_out
#> endform
#> # ... with 6 more lines

print(f_draw_textgrid, condense = FALSE)
#> function (textgrid_in = NULL, width = "6", height = "4", png_out = NULL)
#> # <wrapped_praat_script>
#> # returning: "last-argument"
#> form Draw a textgrid
#>   sentence Textgrid_in
#>   integer Width 6
#>   integer Height 4
#>   sentence Png_out
#> endform
#> Read from file: textgrid_in$
#> Select outer viewport: 0, width, 0, height
#> Draw: 0, 0, "yes", "yes", "yes"
#> Save as 300-dpi PNG file: png_out$
```

Oh that’s right. *Width* then *height*. Now, let’s call the function and
view the resulting image.

``` r
result <- f_draw_textgrid(tg_in, 7, 2, png_out)
magick::image_read(result) 
```

<img src="man/figures/README-png-demo-1.png" width="100%" />

Note that when we printed the wrapped script’s function, the first line
of the output (**the function signature**) included the names of the
variables in the Praat form. Indeed, the arguments to this function are
set based on the Praat form:

``` r
args(f_draw_textgrid)
#> function (textgrid_in = NULL, width = "6", height = "4", png_out = NULL) 
#> NULL
```

This feature means that a text’s editor autocomplete/hint system can
help us remember the arguments to the Praat script and that we can
reorder the arguments in the function call as long as we use the correct
names.

``` r
result <- f_draw_textgrid(
  png_out = png_out, 
  height = 2,
  width = 7, 
  textgrid_in = tg_in
)
```

## Example using bundled Praat scripts

I have bundled some Praat scripts with this package. They are very
minimal and written under the assumption that the scripts would only
ever called via a Praat script.

In one of my projects, I needed to extract the silences identified by a
forced alignment algorithm. Thus, I needed to do three things for each
textgrid:

1.  Copy the tier with speech-sound intervals.
2.  Convert the speech-sound labels into “silence” and “sounding”.
3.  Merged adjacent “silence” intervals and “sounding” intervals
    together.

So I wrote a script for each of these steps. The last-argument of each
script is a Praat textgrid, so I can pipe these wrapped-script functions
into each other.

``` r
f_duplicate <- wrap_praat_script(duplicate_tier)
f_relabel   <- wrap_praat_script(convert_tier_to_silences)
f_merge     <- wrap_praat_script(merge_duplicate_intervals)
```

Let’s apply these scripts to our original example textgrid.

``` r
tg_out <- tempfile("demo", fileext = ".TextGrid")
png_out <- tempfile("demo", fileext = ".png")

tg_result <- tg_in |> 
  f_duplicate("phones", "pauses", "last", tg_out) |> 
  f_relabel("pauses", "^$|sil|sp", tg_out) |>
  f_merge("pauses", tg_out)

png_result <- f_draw_textgrid(tg_result, 7, 2, png_out)

magick::image_read(png_result)
```

<img src="man/figures/README-png-demo-2-1.png" width="100%" />

Now, with a little [purrr](https://purrr.tidyverse.org/) magic, we could
run this workflow on thousands of textgrids 😉.

Finally, as a little test, I want to make sure the package works when
spaces appear in the file names.

``` r
tg_out <- tempfile("demo with spaces in name", fileext = ".TextGrid")
png_out <- tempfile("demo with spaces in name", fileext = ".png")

tg_result <- tg_in |> 
  f_duplicate("phones", "pauses", "last", tg_out) |> 
  f_relabel("pauses", "^$|sil|sp", tg_out) |> 
  f_merge("pauses", tg_out)

png_result <- f_draw_textgrid(tg_result, 3.5, 2, png_out)
basename(png_result)
#> [1] "demo with spaces in name132050ba5926.png"
```

## Acknowledgments

tjm.praat was created to process data from the [WISC Lab
project](https://kidspeech.wisc.edu/). Thus, development of this package
was supported by NIH R01DC009411 and NIH R01DC015653.
