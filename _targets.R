# CLIAR ETL Pipeline
# Orchestrates analysis/01 through analysis/04 scripts using the targets package.
# Extraction scripts (data-raw/source/) are intentionally excluded — run those
# separately to refresh the lazy-loaded data/*.rda files before running this pipeline.
#
# Run with: targets::tar_make()
# Visualise with: targets::tar_visnetwork()

library(targets)

tar_option_set(
  packages = c(
    "dplyr", "tidyr", "purrr", "stringr", "readr", "readxl",
    "haven", "janitor", "here", "usethis", "tibble"
  ),
  format = "rds"
)

devtools::load_all()

list(

  # ---- Stage 1: dictionary & extraction QC --------------------------------
  # Source 01-extraction.R once, return both outputs as a list
  tar_target(
    extraction_results,
    {
      env <- new.env(parent = globalenv())
      source(here::here("analysis", "01-extraction.R"), local = env)
      list(
        db_variables       = env$db_variables,
        db_variables_final = env$db_variables_final
      )
    }
  ),

  tar_target(db_variables,       extraction_results$db_variables),
  tar_target(db_variables_final, extraction_results$db_variables_final),

  tar_target(
    extraction_qc,
    {
      env <- new.env(parent = globalenv())
      source(here::here("analysis", "01.1-extraction_quality_control.R"), local = env)
      TRUE
    }
  ),

  # ---- Stage 2: compiled indicators panel ---------------------------------
  # Script writes inst/extdata/compiled_indicators.rds — track the file itself
  tar_target(
    compiled_indicators,
    {
      force(db_variables)
      env <- new.env(parent = globalenv())
      env$db_variables <- db_variables
      source(here::here("analysis", "02-compiled_indicators_panel.R"), local = env)
      here::here("inst", "extdata", "compiled_indicators.rds")
    },
    format = "file"
  ),

  tar_target(
    compiled_indicators_qc,
    {
      force(compiled_indicators)
      env <- new.env(parent = globalenv())
      source(here::here("analysis", "02.1-compiled_indicators_quality_control.R"), local = env)
      TRUE
    }
  ),

  # ---- Stage 3: CTF transformations ---------------------------------------
  # Source 03-ctf_transformations.R once, return both outputs as a list
  tar_target(
    ctf_results,
    {
      force(compiled_indicators); force(db_variables)
      env <- new.env(parent = globalenv())
      env$db_variables <- db_variables
      source(here::here("analysis", "03-ctf_transformations.R"), local = env)
      list(
        ctf_static  = env$ctf_static_clean,
        ctf_dynamic = env$ctf_dynamic_clean
      )
    }
  ),

  tar_target(ctf_static,  ctf_results$ctf_static),
  tar_target(ctf_dynamic, ctf_results$ctf_dynamic),

  tar_target(
    ctf_qc,
    {
      force(ctf_static); force(ctf_dynamic)
      env <- new.env(parent = globalenv())
      source(here::here("analysis", "03.1-ctf_quality_control.R"), local = env)
      TRUE
    }
  ),

  # ---- Stage 4: indicators map --------------------------------------------
  # Script writes inst/extdata/indicators_map.rds — track the file itself
  tar_target(
    indicators_map,
    {
      force(ctf_static); force(compiled_indicators); force(db_variables)
      env <- new.env(parent = globalenv())
      env$db_variables <- db_variables
      source(here::here("analysis", "04-map_indicators.R"), local = env)
      here::here("inst", "extdata", "indicators_map.rds")
    },
    format = "file"
  )
)