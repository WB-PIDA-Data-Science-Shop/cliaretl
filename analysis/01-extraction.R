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

# Load custom functions
devtools::load_all()

# read-in data ------------------------------------------------------------

# Extracted indicators dfs
debt_transparency_indicators <- cliaretl::debt_transparency
wdi_wb_indicators <- cliaretl::wdi_indicators
pefa_assessments_indicators <- cliaretl::pefa_assessments
romelli_indicators <- cliaretl::romelli
vdem_data_indicators <- cliaretl::vdem_data
gfdb_indicators <- cliaretl::gfdb
heritage_indicators <- cliaretl::heritage
pmr_indicators <- cliaretl::pmr
epl_indicators <- cliaretl::epl
d30_indicators <- cliaretl::d360_efi_data
fraser_indicators <- cliaretl::fraser
aspire_indicators <- cliaretl::aspire
wbl_indicators <- cliaretl::wbl_data

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
# PLACEHOLDER

# 2. Conflicting indicators analysis -------------------------------------------

# a. Mismatching -------------------------------------------------------------

# Mismatching Indicators
# Identify indicators in the databases that do not match the reference dictionary (`db_variables`).
# For each flagged indicator, assess the following:
# a. Has the original data source renamed or updated the indicator?
#    If yes, use the `update_db_variables` function above to update the file accordingly.
# b. Is the indicator irrelevant to the current indicator framework?
#    If yes, consider removing it from the database to maintain consistency with `db_variables`.

dataframes <- list(
  debt_transparency_indicators = debt_transparency,
  wdi_wb_indicators = wdi_indicators,
  pefa_assessments_indicators = pefa_assessments,
  romelli_indicators = romelli,
  vdem_data_indicators = vdem_data,
  gfdb_indicators = gfdb,
  heritage_indicators = heritage,
  pmr_indicators = pmr,
  epl_indicators = epl,
  d30_indicators = d360_efi_data,
  fraser_indicators = fraser,
  aspire_indicators = aspire,
  wbl_indicators = wbl_data
)

# Apply the `flag_mismatched_indicators` function across all and bind results
all_mismatched_vars <- map_dfr(
  #From list to data frame
  names(dataframes),
  function(name) {
    mismatched_df <- flag_mismatched_indicators(
      dataframes[[name]],
      db_variables_2025
    )[[1]]
    mismatched_df |> mutate(source = name)
  }
)

# b. Missing Indicators ---------------------------------------------------

# Here we are interested in flagging those variables expected but not present.

# First, anchor the data frame to the source to subset db_variables to the indicators of
# interest with the following object:

# ... by source -----------------------------------------------------------

dictionary_identifiers <- db_variables_2025 |>
  mutate(
    variable = case_when(
      str_starts(variable, "wdi_") ~ "wdi_",
      ### To be updated in the extraction
      TRUE ~ str_extract(variable, "^([^_]+_[^_]+)")
    )
  ) |>
  distinct(variable, source)

# Then call the function to each of the data frames
wdi_missing_df <- flag_missing_indicators(
  db_variables_2025,
  wdi_indicators,
  source_type = ("WDI")
)

# Important WDI note: indicators come also from d360 API pull
d360_cols <- colnames(d360_efi_data)

wdi_missing_df <- wdi_missing_df |>
  mutate(is_present = variable %in% d360_cols)
# This should be empty:
wdi_missing_df |> filter(!is_present)

vdem_missing_df <- flag_missing_indicators(
  db_variables_2025,
  vdem_data_indicators,
  source_type = "V-Dem, Variety of Democracy database"
)

pefa_missing_df <- flag_missing_indicators(
  db_variables_2025,
  pefa_assessments_indicators,
  source_type = "Public Expenditure Financial Accountability"
)

pmr_oecd_missing_df <- flag_missing_indicators(
  db_variables_2025,
  pmr_indicators,
  source_type = "OECD Product Market Regulation Database"
)

epl_oecd_missing_df <- flag_missing_indicators(
  db_variables_2025,
  epl_indicators,
  source_type = "OECD"
)

gfdb_missing_df <- flag_missing_indicators(
  db_variables_2025,
  gfdb_indicators,
  source_type = "wb_gfdb"
)

heritage_missing_df <- flag_missing_indicators(
  db_variables_2025,
  heritage_indicators,
  source_type = "Heritage Index of Economic Freedom"
)

fraser_missing_df <- flag_missing_indicators(
  db_variables_2025,
  fraser_indicators,
  source_type = "Fraser Institute"
)

aspire_missing_df <- flag_missing_indicators(
  db_variables_2025,
  aspire_indicators,
  source_type = "ASPIRE"
)

wbl_missing_df <- flag_missing_indicators(
  db_variables_2025,
  wbl_indicators,
  source_type = "CLIAR"
)

# Combine them into a single dataframe
all_missing_vars <- bind_rows(
  vdem_missing_df,
  # Ommiting WDI
  pefa_missing_df,
  pmr_oecd_missing_df,
  epl_oecd_missing_df,
  gfdb_missing_df,
  heritage_missing_df,
  fraser_missing_df,
  aspire_missing_df,
  wbl_missing_df
)

# flag mismatched indicators
if (nrow(all_mismatched_vars) > 0) {
  message(
    "⚠️ Issue detected:
There are mismatched indicators between extracted data and the dictionary."
  )
  print(all_mismatched_vars)
} else {
  message("✅ All extracted indicators match the dictionary definitions.")
}

if (nrow(all_missing_vars) > 0) {
  message(
    "⚠️ Issue detected:
There are missing indicators not found in the extracted data."
  )
  print(all_missing_vars)
} else {
  message("✅ All expected indicators are present in the extracted data.")
}


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
