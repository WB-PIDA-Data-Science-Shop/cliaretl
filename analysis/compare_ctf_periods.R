# This provisional script allows to compare indicator coverage between
# different CTF periods (2023 vs 2024) for quality assurance purposes.

# setup ------------------------------------------------------------------------
# Load necessary libraries
library(haven)
library(here)
library(readxl)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(testthat)
library(janitor)
library(ggplot2)
library(scales)
library(dlookr)

devtools::load_all()

# read-in data ------------------------------------------------------------

compiled_indicators <- readRDS(
  here("data-raw/output/compiled_indicators.rds")
)

static_2024 <- readRDS(
  here("data-raw/output/static_ctf_full_2024.rds")
)

dynamic_2024 <- readRDS(
  here("data-raw/output/dynamic_ctf_full_2024.rds")
)

static_2023 <- closeness_to_frontier_static

dynamic_2023 <- closeness_to_frontier_dynamic


# compare ctf periods -------------------------------------------------------

# static
common_vars <- intersect(
  grep("^vars_", names(static_2023), value = TRUE),
  grep("^vars_", names(static_2024), value = TRUE)
)

id_cols <- names(static_2023)[1:4]  # e.g., country_code, country_name, income_group, region

# assume `common_vars` already exists (intersection of vars_* columns)
long_2023 <- static_2023 |>
  select(all_of(id_cols), all_of(common_vars)) |>
  pivot_longer(cols = all_of(common_vars),
               names_to = "indicator", values_to = "value_2023")

long_2024 <- static_2024 |>
  select(all_of(id_cols), all_of(common_vars)) |>
  pivot_longer(cols = all_of(common_vars),
               names_to = "indicator", values_to = "value_2024")

static_period_diff <- long_2023 |>
  left_join(long_2024, by = c(id_cols, "indicator")) |>
  mutate(difference = value_2024 - value_2023)

# NOTE:
# After checking the data availability differences between 2023 and 2024
# CTF periods, no major issues were found in the static indicators.
# Therefore, the decision is to proceed with the 2024 CTF static period.


# dynamic
common_vars_dyn <- intersect(
  grep("^vars_", names(dynamic_2023), value = TRUE),
  grep("^vars_", names(dynamic_2024), value = TRUE)
)

id_cols <- names(dynamic_2023)[1:5]

long_dyn_2023 <- dynamic_2023 |>
  filter(year >= 2013) |>
  select(all_of(id_cols), all_of(common_vars_dyn)) |>
  pivot_longer(cols = all_of(common_vars_dyn),
               names_to = "indicator", values_to = "value_2023")

long_dyn_2024 <- dynamic_2024 |>
  filter(year >= 2013) |>
  select(all_of(id_cols), all_of(common_vars_dyn)) |>
  pivot_longer(cols = all_of(common_vars_dyn),
               names_to = "indicator", values_to = "value_2024")

dynamic_period_diff <- long_dyn_2023 |>
  left_join(long_dyn_2024, by = c(id_cols, "indicator")) |>
  mutate(difference = value_2024 - value_2023)

dynamic_2024 |>
  select(year, all_of(c(var_lists$vars_dynamic_family_ctf, var_lists$vars_dynamic_partial_ctf))) |>
  filter(year == 2024) |>
  summary()

### NOTE:
# After checking the data availability differences between 2023 and 2024 CTF periods,
# Year 2024 shows low coverage for certain indicators for all the CLIAR families.
# The decition is to proceed with the 2023 CTF period for the CLIAR indicators for now.


