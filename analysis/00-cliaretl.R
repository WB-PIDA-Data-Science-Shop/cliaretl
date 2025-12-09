# run cliaretl pipeline
source(here::here("analysis", "01-extraction.R"), local = TRUE)
source(here::here("analysis", "01.1-extraction_quality_control.R"), local = TRUE)
source(here::here("analysis", "02-compiled_indicators_panel.R"), local = TRUE)
source(here::here("analysis", "02.1-compiled_indicators_quality_control.R"), local = TRUE)
source(here::here("analysis", "03-ctf_transformations.R"), local = TRUE)
source(here::here("analysis", "03.1-ctf_quality_control.R"), local = TRUE)
source(here::here("analysis", "04-map_indicators.R"), local = TRUE)

# Documentation for versioning:
# https://r-pkgs.org/lifecycle.html#sec-lifecycle-version-number

usethis::use_version("minor")
