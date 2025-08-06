# Title: Extraction Quality Control Report
# Description: This script generates a quality control report for the indicators
# extracted from various databases and updates metadata accordingly.

# Essentially, it checks for mismatched and missing indicators against a reference dictionary.

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

# Load custom functions
devtools::load_all()


# read-in data ------------------------------------------------------------

# Extracted indicators dfs
debt_transparency_indicators <- debt_transparency
wdi_wb_indicators <- wdi_indicators
pefa_assessments_indicators <- pefa_assessments
romelli_indicators <- romelli
vdem_data_indicators <- vdem_data
gfdb_indicators <-  gfdb
heritage_indicators <- heritage
pmr_indicators <- pmr
epl_indicators <- epl
d30_indicators <- d360_efi_data
fraser_indicators <- fraser
aspire_indicators <- aspire

# Dictionary df
db_variables <-  read_xlsx(
  here("data-raw", "input", "cliar", "db_variables.xlsx")
)


# Update db_variables -----------------------------------------------------

# Documenting variable changes in our dictionary

# Use `update_db_variables` function to update the `db_variables` dataframe.

# Named vector of changes: new name = old name
renames <- c(
  "wdi_enghgco2rtgdpppkd" = "wdi_enatmco2eppgdkd",
  "wb_spi_std_and_methods" = "spi_std_and_methods",
  "wb_spi_census_and_survey_index" = "spi_census_and_survey_index"
)

# Apply the renaming to the db_variables dataframe
db_renamed <- update_db_variables(db_variables, rename_map = renames)

# Continue to use the updated db_variables
db_variables <- db_renamed


# VDEM
# Problematic indicators that changed their variable name:
# vdem_core_v2lgfemleg       Lower chamber female legislators (v2lgqugen) extra
# vdem_core_v2caassemb       Freedom of peaceful assembly
# vdem_core_v2peasjgen       Access to state jobs by gender

# https://www.v-dem.net/documents/55/codebook.pdf



# Conflicting indicators analysis ---------------------------------------------

# 1. Mismatching -------------------------------------------------------------

# Mismatching Indicators
# Identify indicators in the databases that do not match the reference dictionary (`db_variables`).
# For each flagged indicator, assess the following:
# a. Has the original data source renamed or updated the indicator?
#    If yes, use the `update_db_variables` function above to update the file accordingly.
# b. Is the indicator irrelevant to the current indicator framework?
#    If yes, consider removing it from the database to maintain consistency with `db_variables`.


dataframes <- list( debt_transparency_indicators = debt_transparency,
                    wdi_wb_indicators = wdi_indicators,
                    pefa_assessments_indicators = pefa_assessments,
                    romelli_indicators = romelli,
                    vdem_data_indicators = vdem_data,
                    gfdb_indicators =  gfdb,
                    heritage_indicators = heritage,
                    pmr_indicators = pmr,
                    epl_indicators = epl,
                    d30_indicators = d360_efi_data,
                    fraser_indicators = fraser,
                    aspire_indicators = aspire
                )

# Apply the `flag_mismatched_indicators` function across all and bind results
all_mismatched_vars <- map_dfr( #From list to data frame
  names(dataframes),
  function(name) {
    mismatched_df <- flag_mismatched_indicators(dataframes[[name]],
                                                db_variables)[[1]]
    mismatched_df|> mutate(source = name)
  }
)



# 2. Missing Indicators ---------------------------------------------------

# Here we are interested in flagging those variables expected but not present.

# First, anchor the data frame to the source to subset db_variables to the indicators of
# interest with the following object:


# 2.1 by source -----------------------------------------------------------

dictionary_identifiers <- db_variables|>
  mutate(variable = case_when(
    str_starts(variable, "wdi_") ~ "wdi_", ### To be updated in the extraction
    TRUE ~ str_extract(variable, "^([^_]+_[^_]+)")
  )) |>
  distinct(variable, source)


# Then call the function to each of the data frames
wdi_missing_df <- flag_missing_indicators(db_variables,
                                          wdi_indicators,
                                          source_type = ("WDI")
)

# Important WDI note: indicators come also from d360 API pull
d360_cols <- colnames(d360_efi_data)

wdi_missing_df <- wdi_missing_df |>
  mutate(is_present = variable %in% d360_cols)
# This should be empty:
wdi_missing_df |> filter(!is_present)


vdem_missing_df <- flag_missing_indicators(db_variables,
                                           vdem_data_indicators,
                                           source_type = "V-Dem, Variety of Democracy database")

pefa_missing_df <- flag_missing_indicators(db_variables,
                                           pefa_assessments_indicators,
                                           source_type = "Public Expenditure Financial Accountability")

pmr_oecd_missing_df <- flag_missing_indicators(db_variables,
                                          pmr_indicators,
                                          source_type = "OECD Product Market Regulation Database")

epl_oecd_missing_df <- flag_missing_indicators(db_variables,
                                       epl_indicators,
                                       source_type = "OECD")

gfdb_missing_df <- flag_missing_indicators(db_variables,
                                       gfdb_indicators,
                                       source_type = "wb_gfdb")

heritage_missing_df <- flag_missing_indicators(db_variables,
                                           heritage_indicators,
                                           source_type = "Heritage Index of Economic Freedom")

fraser_missing_df <- flag_missing_indicators(db_variables,
                                               fraser_indicators,
                                               source_type = "Fraser Institute")

aspire_missing_df <- flag_missing_indicators(db_variables,
                                             aspire_indicators,
                                             source_type = "ASPIRE")


# Combine them into a single dataframe
all_missing_vars <- bind_rows(vdem_missing_df, # Ommiting WDI
                              pefa_missing_df,
                              pmr_oecd_missing_df,
                              epl_oecd_missing_df,
                              gfdb_missing_df,
                              heritage_missing_df,
                              fraser_missing_df,
                              aspire_missing_df
                              )


if (nrow(all_mismatched_vars) > 0) {
  message("⚠️ Issue detected:
There are mismatched indicators between extracted data and the dictionary.")
  print(all_mismatched_vars)
} else {
  message("✅ All extracted indicators match the dictionary definitions.")
}


if (nrow(all_missing_vars) > 0) {
  message("⚠️ Issue detected:
There are missing indicators not found in the extracted data.")
  print(all_missing_vars)
} else {
  message("✅ All expected indicators are present in the extracted data.")
}



# 2.2 all vs all db -------------------------------------------------------
# db variables source column is not reliable at this point.
# Build a compiled indicators panel df to check matching

sources <-  db_variables |> count(source)

# Step 1: Clean and classify
dictionary_clean <- dictionary_identifiers |>
  mutate(variable = str_trim(as.character(variable)),
         etl_source = case_when(
           # Exact match group
           variable %in% c("bs_sgi",
                           "bs_bti",
                           "fh_fiw",
                           "ibp_obs",
                           "idea_gsod",
                           "imf_fm",
                           "imf_gfscofog",
                           "imf_world",
                           "rise_ee",
                           "rise_re",
                           "rwb_pfi",
                           "spi_census",
                           "spi_std",
                           "wb_es",
                           "wb_girg",
                           "wb_gtmi",
                           "wb_lpi",
                           "wb_wbl",
                           "wb_wwbi",
                           "wjp_rol") ~ "wb_api",
           variable == "fraser_efw" ~ "fraser",
           variable %in% c("heritage_business",
                           "heritage_financial",
                           "heritage_investment") ~ "heritage",
           variable == "oecd_epl" ~ "oecd_epl",
           variable == "oecd_pmr" ~ "oecd_pmr",
           variable == "romelli_cbi" ~ "romelli",
           variable == "aspire" ~ "wb_aspire_api",
           variable == "wb_debt" ~ "debt_transparency",
           variable == "wb_gfdb" ~ "gfdb",
           variable == "wb_pefa" ~ "pefa",
           variable == "vdem_core" ~ "vdem",
           TRUE ~ "wdi"
         ))


# Map etl_source by source
etl_mapping <- dictionary_clean |>
  group_by(source) |>
  summarise(etl_source = first(etl_source), .groups = "drop")

# Step 3: Join to db_variables
db_variables <- db_variables |>
                        left_join(etl_mapping,
                                  by = "source")

# Ultimately check d360 API indicators
api_missing_indicators <- flag_missing_indicators(db_variables,
                                     d360_efi_data,
                                     source_type = "wb_api",
                                     source_colname = "etl_source")

devprint(api_missing_indicators)

db_variables <- db_variables |>
  add_plmetadata(source = "metadata dictionary",
                 other_info = "")

# export db_variables -----------------------------------------------------
usethis::use_data(db_variables, overwrite = TRUE)

