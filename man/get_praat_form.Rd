% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/main.R
\name{get_praat_form}
\alias{get_praat_form}
\title{Extract the form from a Praat script}
\usage{
get_praat_form(x)
}
\arguments{
\item{x}{a single string (a Praat script)}
}
\value{
the lines of text from \code{form} to \code{endform}
}
\description{
Extract the form from a Praat script
}
\examples{
get_praat_form(duplicate_tier)
}
