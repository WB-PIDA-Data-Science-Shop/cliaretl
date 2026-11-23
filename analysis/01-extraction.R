# Title: Extraction Quality Control Report
# Description: This script generates a quality control report for the indicators
# extracted from various databases and updates metadata accordingly. 
# It checks for mismatched and missing indicators against a reference dictionary.

# - Input:
# Lazy loaded `data/*.rda` files containing extracted indicators and
# `data-raw/input/cliar/db_variables.xlsx` for updating dictionary.
# - Output:
# `data/db_variables.rds` containing the updated dictionary

# set-up ------------------------------------------------------------------
# Load necessary libraries
library(haven)
library(dplyr)
library(here)
library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(janitor)

# read-in data ------------------------------------------------------------

# Every lazyloaded source dataset in data/, named by file (e.g.
# `wdi_indicators`). Pipeline outputs and reference tables are left out (see
# lazyload_exclusions() in R/etl_source_funs.R). A new source is picked up
# automatically once its .rda is saved to data/.
lazyloads <- read_lazyloads(here("data"))

# Dictionary df
db_variables_2025 <- readr::read_rds(
  here(
    "data-raw",
    "input",
    "cliar",
    "db_variables",
    "db_variables_2025.rds"
  )
)

# Generate vars_lists object
vars_ctf <- db_variables |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  pull(variable)

var_lists <- get_variable_lists(db_variables)

# 1. Change log for db_variables -----------------------------------------
# ref_year: 2026

# 1.1 WBL indicators: Update benchmark_dynamic_indicator and benchmark_dynamic_family_aggregate 

db_variables_2025 <- db_variables_2025 |>
  mutate( # Apply this renaming only to the variables that start with "wb_wbl_"
    is_wbl = str_starts(variable, "wb_wbl_"),
    benchmark_dynamic_indicator = if_else(
      is_wbl,
      "No",
      benchmark_dynamic_indicator
    ),
    benchmark_dynamic_family_aggregate = if_else(
      is_wbl,
      "No",
      benchmark_dynamic_family_aggregate
    )
  ) |>
  select(-is_wbl)

# print out the changes made
db_variables_2025 |>
filter(str_starts(variable, "wb_wbl_")) |>
  select(variable, benchmark_dynamic_indicator, benchmark_dynamic_family_aggregate)

# 1.2. B-Ready indicators: add pillars 1-3 as static benchmarked
db_variables_2025 <- db_variables_2025 |>
  addnew_db_variables(
    new_rows = tibble::tibble(
      api_id = NA,
      variable = c(
        "wb_bready_pillar_1",
        "wb_bready_pillar_2",
        "wb_bready_pillar_3"
      ),
      var_name = c(
        "B-Ready Pillar 1: Regulatory Framework",
        "B-Ready Pillar 2: Public Services",
        "B-Ready Pillar 3: Operational Efficiency"
      ),
      var_level = c("indicator", "indicator", "indicator"),
      family_var = rep("vars_mkt", 3),
      family_name = rep("Business Environment", 3),
      family_order = rep(9, 3),
      processing = NA,
      description = c(
        "The B-Ready Pillar 1 focuses on the rules that shape business activity. This pillar examines the laws and regulations that businesses must follow, such as how to register a company, labor protections, and rules for resolving disputes. It also considers how governments set up these rules to promote transparency, fair competition, and property rights.",
        "The B-Ready Pillar 2 measures the support governments provide to help businesses comply with regulations. This includes the availability of online systems for permits, digital tax platforms, and infrastructure at borders for trade",
        "The B-Ready Pillar 3 captures how easy it is for businesses to comply with rules and use public services. This pillar looks at the real-world experience of firms, such as how long it takes to get utilities connected, how easy it is to participate in public procurement, and the reliability of digital payment systems. "
      ),
      description_short = c(
        "The B-Ready Pillar measures rules and regulations that firms must follow as they open, operate, and close a business",
        "The B-Ready Pillar 2 measures the facilities that support regulatory compliance and institutions and infrastructure to enable business activities",
        "The B-Ready Pillar 3 measures the ease of regulatory compliance and effective use of public services directly relevant to firms"
      ),
      source = c("Business Ready", "Business Ready", "Business Ready"),
      benchmarked_ctf = c("Yes", "Yes", "Yes"),
      benchmark_static_family_aggregate_download = c("Yes", "Yes", "Yes"),
      benchmark_dynamic_indicator = rep("No", 3),
      benchmark_dynamic_family_aggregate = rep("No", 3),
      rank_id = c(21, 22, 23),
      etl_source = NA_character_ # assigned by map_lazyload_data() in section 3
    )
  )

# 2. Conflicting indicators analysis -------------------------------------------

# a. Mismatching -------------------------------------------------------------

# Mismatching Indicators
# Identify indicators in the databases that do not match the reference dictionary (`db_variables`).
# For each flagged indicator, assess the following:
# a. Has the original data source renamed or updated the indicator?
#    If yes, use the `update_db_variables` function above to update the file accordingly.
# b. Is the indicator irrelevant to the current indicator framework?
#    If yes, consider removing it from the database to maintain consistency with `db_variables`.

# Flag dataset columns that are not in the dictionary, for every lazyloaded
# source. `source` records the dataset name (e.g. "wdi_indicators").
all_mismatched_vars <- imap(
  lazyloads,
  \(df, name) flag_mismatched_indicators(df, db_variables_2025)[[1]] |>
    mutate(source = name)
) |>
  list_rbind()

if (nrow(all_mismatched_vars) > 0) {
  message(
    "⚠️ Issue detected:
There are mismatched indicators between extracted data and the dictionary."
  )
  print(all_mismatched_vars)
} else {
  message("✅ All extracted indicators match the dictionary definitions.")
}

# b. Missing Indicators ---------------------------------------------------

# Dictionary variables that are in no lazyloaded dataset are reported by
# map_lazyload_data() in section 3, as a warning listing each one. Because
# etl_source is now derived from the data, a variable is "missing" only if no
# dataset provides it at all (e.g. WDI variables pulled via d360_efi_data are
# found there and are not missing).


# 3. Add important attributes to db_variables ---------------------------------------------------

family_order <- tibble(
  family_order = c(13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1),
  family_name = c(
    "Political Institutions",
    "Social Institutions",
    "Degree of Integrity",
    "Transparency and Accountability Institutions",
    "Justice Institutions",
    "Public Finance Institutions",
    "Public Human Resource Management Institutions",
    "Digital and Data Institutions",
    "Business Environment",
    "SOE Corporate Governance",
    "Labor and Social Protection Institutions",
    "Service Delivery Institutions",
    "Energy and Environment Institutions"
  ),
  Benchmark_static_family_aggregate_download = c(
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "No",
    "No",
    "No",
    "Yes"
  ),
  Benchmark_dynamic_indicator = c(
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "Yes",
    "No",
    "Yes",
    "Yes",
    "Yes",
    "No",
    "No",
    "Yes",
    "Yes"
  ),
  Benchmark_dynamic_family_aggregate = c(
    "Partial",
    "Partial",
    "Partial",
    "Partial",
    "Partial",
    "No",
    "Partial",
    "No",
    "No",
    "No",
    "No",
    "No",
    "Partial"
  )
)

# Clean and prepare db_variables
db_variables_2026 <- db_variables_2025 |>
  clean_names() |>
  mutate(
    variable = make_clean_names(variable),
    var_name = str_to_sentence(var_name, locale = "en") # To Sentence
  )

# Rank ID was already created in db_variables_2025, but we can ensure it's present and correct
db_variables_2026 <- db_variables_2026 |>
  group_by(family_var) |>
  mutate(rank_id = row_number()) |>
  ungroup()

# Assign etl_source from the lazyloaded dataset that holds each variable.
# Variables in no dataset (e.g. provisional RISE indicators) stay NA and are
# listed in a warning.
db_variables_2026 <- db_variables_2026 |>
  map_lazyload_data(lazyloads = lazyloads)

# Create a family_var column to link family-level vars
family_level_vars <- db_variables_2026 |>
  distinct(family_var, family_name) |>
  rowwise() |>
  mutate(
    variable = paste0(family_var, "_avg"),
    var_name = paste0(family_name, " Average"),
    var_level = "indicator",
    description = "The cluster-level average is an unweighted average of the corresponding and included indicators of this cluster. See Methodological note for details on the inclusion criteria.",
    description_short = "The cluster-level average is an unweighted average of the corresponding and included indicators for this cluster.",
    source = "CLIAR",
    benchmarked_ctf = "Yes",
    rank_id = 1
  )

# Create final db_variables with family-level vars included
db_variables_final <- db_variables_2026 |>
  bind_rows(family_level_vars) |>
  arrange(family_var, rank_id) |> 
  add_plmetadata(source = "2026 metadata dictionary", other_info = "Last updated: 08/26/2026")

# Add time stamp
db_variables <- db_variables_2026 |>
  add_plmetadata(source = "2026 metadata dictionary", other_info = "Last updated: 08/26/2026")

# Add year attribute
attr(db_variables, "ref_year") <- 2026

db_variables <- db_variables |>
  add_plmetadata(
    source = "Own dictionary",
    other_info = "Last updated: 08/26/2026. Version 2026, updated with indicators extracted from various sources and cleaned."
  )

# snapshot data ----------------------------------------------------------
db_variables |>
  readr::write_rds( 
    here(
      "data-raw",
      "input",
      "cliar",
      "db_variables",
      "db_variables_2026.rds"
    )
  )

# export data -----------------------------------------------------
usethis::use_data(db_variables, overwrite = TRUE)
usethis::use_data(db_variables_final, overwrite = TRUE)
usethis::use_data(family_order, overwrite = TRUE)
