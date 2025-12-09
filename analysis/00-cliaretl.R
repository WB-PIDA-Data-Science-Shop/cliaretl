# run cliaretl pipeline
source(here::here("analysis", "01-extraction.R"), local = TRUE)
source(here::here("analysis", "01.1-extraction_quality_control.R"), local = TRUE)
source(here::here("analysis", "02-compiled_indicators_panel.R"), local = TRUE)
source(here::here("analysis", "02.1-compiled_indicators_quality_control.R"), local = TRUE)
source(here::here("analysis", "03-ctf_transformations.R"), local = TRUE)
source(here::here("analysis", "03.1-ctf_quality_control.R"), local = TRUE)
source(here::here("analysis", "04-map_indicators.R"), local = TRUE)


# IMPORTANT NOTE ON VERSIONING:
# This project follows semantic versioning as described in the R Packages book:
# https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number
# Making use of the 'usethis' package to manage versioning:
# https://usethis.r-lib.org/reference/use_version.html


# Increment the minor version for small changes, bug fixes, or documentation updates
# run the following code in the console to update the version 'usethis::use_version("minor")'
