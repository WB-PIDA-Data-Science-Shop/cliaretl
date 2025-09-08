# place quality checks here.
# global check on the data after all the intermediate quality checks have been done.

# check for consistency with the previous dataset (compiled_indicators.rds in the data-raw/input/cliar folder)

# set-up ------------------------------------------------------------------
library(dlookr)
library(readr)
library(dplyr)
library(here)

compiled_indicators <- read_csv(
  here("data-raw", "output", "compiled_indicators.csv.gz")
)

compiled_indicators_legacy <- read_rds(
  here("data-raw", "input", "cliar", "compiled_indicators.rds")
)

# statistical assessment --------------------------------------------------
diagnostics <- compiled_indicators |>
  diagnose() |>
  arrange(
    desc(unique_rate)
  )

diagnostics_outlier <- compiled_indicators |>
  diagnose_outlier() |>
  filter(
    outliers_cnt > 0
  ) |>
  arrange(
    desc(outliers_ratio)
  )

compiled_indicators |>
  plot_outlier(
    diagnostics_outlier |>
      pull(variables)
  )

diagnostics_categorical <- compiled_indicators |>
  diagnose_category()
