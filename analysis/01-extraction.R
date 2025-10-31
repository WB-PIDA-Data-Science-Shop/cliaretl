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
library(janitor)

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
wbl_indicators <- wbl_data

# Dictionary df
db_variables_2024 <-  read_xlsx(here("data-raw", "input", "cliar", "db_variables.xlsx"))

# Generate vars_lists object
vars_ctf <- db_variables |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  pull(variable)

var_lists <- get_variable_lists(db_variables)


# 1. Update db_variables -----------------------------------------------------


## 1.1 Renaming variables ----------
# Documenting variable changes in our dictionary
# Use `update_db_variables` function to update the `db_variables` dataframe.

# Named vector of changes: new name = old name
rename_variable <- c(
  "wdi_enghgco2rtgdpppkd" = "wdi_enatmco2eppgdkd",
  "wb_spi_std_and_methods" = "spi_std_and_methods",
  "wb_spi_census_and_survey_index" = "spi_census_and_survey_index"
)


# fix six variables that are incorrectly classified as `var_level` = NA
db_variables_2024 <- db_variables_2024 |>
  mutate(
    var_level = if_else(
      variable %in% c(
        "vdem_core_v2lgcrrpt", "vdem_core_v2x_execorr", "vdem_core_v2x_pubcorr",
        "wb_gtmi_i_12", "wb_pefa_pi_2016_07", "wb_pefa_pi_2016_08"
      ),
      "indicator",
      var_level
    )
  )

# Apply the renaming to the db_variables dataframe
db_variables_2024 <- update_db_variables(
  db_variables_2024,
  rename_map = rename_variable,
  column_name = "variable"
)


# Documenting var_names changes in our dictionary
# Cite: https://www.v-dem.net/documents/55/codebook.pdf


# vdem_core_v2lgfemleg       Lower chamber female legislators (v2lgqugen) extra
# vdem_core_v2caassemb       Freedom of peaceful assembly
# vdem_core_v2peasjgen       Access to state jobs by gender


## 1.2 Renaming SOE vars ---------

### Fix internal labeling for SOE Corporate Governance #34

rename_family <- c(
  "vars_soe" = "vars_service_del"
)

db_variables_2024 <- update_db_variables(db_variables_2024,
                                         rename_map = rename_family,
                                         column_name = "family_var")

## 1.3 Including the new pmr variables and deleting those we have removed

newpmr_tbl <-
  tibble::tibble(var_name = c("Involvement in Business Operations in Services Sectors",
                              "Involvement in Business Operations in Network Sectors"),
                 api_id = NA_character_,
                 variable = c("oecd_pmr_2018_2_2_2", "oecd_pmr_2018_2_2_1"),
                 var_level = "indicator",
                 family_var = "vars_soe",
                 family_name = rep("SOE Corporate Governance", 2),
                 family_order = 10,
                 processing = NA_character_,
                 description = c("measures the extent to which the government imposes restrictions on the conduct of firms in key service sectors (e.g., restrictions on the ownership and legal form of professional firms, restrictions on the geographic location of pharmacies, regulation of retail shop opening hours)",
                                 "measures the extent to which the government imposes restrictions on the conduct of firms in key network sectors (e.g., regulation of fixed and mobile number portability, constraints on airline route and frequency choices)"),
                 description_short = c("measure how much government imposes restrictions on key service sector firms",
                                       "measure how much government imposes restrictions on key network sector firms"),
                 source = rep("OECD Product Market Regulation Database", 2),
                 benchmarked_ctf = rep("Yes", 2),
                 benchmark_static_family_aggregate_download = rep("No", 2),
                 benchmark_dynamic_indicator = rep("No", 2),
                 benchmark_dynamic_family_aggregate = rep("No", 2),
                 etl_source = rep("oecd_pmr", 2),
                 indicator_order = c(7, 8))

## add new pmr variables
db_variables_2024 <-
  addnew_db_variables(db_variables = db_variables_2024,
                      new_rows = newpmr_tbl) |>
  arrange(variable)

## remove the 2018 version that is no longer being used
dbpmr_varlist <- db_variables_2024$variable[grepl("oecd_pmr", db_variables_2024$variable)]

dropvars_list <- dbpmr_varlist[!dbpmr_varlist %in% colnames(pmr)]

db_variables_2024 <- db_variables_2024 |> dplyr::filter(!variable %in% dropvars_list)



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
  gfdb_indicators =  gfdb,
  heritage_indicators = heritage,
  pmr_indicators = pmr,
  epl_indicators = epl,
  d30_indicators = d360_efi_data,
  fraser_indicators = fraser,
  aspire_indicators = aspire,
  wbl_indicators = wbl_data
)

# Apply the `flag_mismatched_indicators` function across all and bind results
all_mismatched_vars <- map_dfr(#From list to data frame
  names(dataframes), function(name) {
    mismatched_df <- flag_mismatched_indicators(dataframes[[name]], db_variables_2024)[[1]]
    mismatched_df |> mutate(source = name)
  })

# b. Missing Indicators ---------------------------------------------------

# Here we are interested in flagging those variables expected but not present.

# First, anchor the data frame to the source to subset db_variables to the indicators of
# interest with the following object:


# ... by source -----------------------------------------------------------

dictionary_identifiers <- db_variables_2024 |>
  mutate(variable = case_when(
    str_starts(variable, "wdi_") ~ "wdi_",
    ### To be updated in the extraction
    TRUE ~ str_extract(variable, "^([^_]+_[^_]+)")
  )) |>
  distinct(variable, source)


# Then call the function to each of the data frames
wdi_missing_df <- flag_missing_indicators(db_variables_2024, wdi_indicators, source_type = ("WDI"))

# Important WDI note: indicators come also from d360 API pull
d360_cols <- colnames(d360_efi_data)

wdi_missing_df <- wdi_missing_df |>
  mutate(is_present = variable %in% d360_cols)
# This should be empty:
wdi_missing_df |> filter(!is_present)


vdem_missing_df <- flag_missing_indicators(db_variables_2024, vdem_data_indicators, source_type = "V-Dem, Variety of Democracy database")

pefa_missing_df <- flag_missing_indicators(db_variables_2024, pefa_assessments_indicators, source_type = "Public Expenditure Financial Accountability")

pmr_oecd_missing_df <- flag_missing_indicators(db_variables_2024, pmr_indicators, source_type = "OECD Product Market Regulation Database")

epl_oecd_missing_df <- flag_missing_indicators(db_variables_2024, epl_indicators, source_type = "OECD")

gfdb_missing_df <- flag_missing_indicators(db_variables_2024, gfdb_indicators, source_type = "wb_gfdb")

heritage_missing_df <- flag_missing_indicators(db_variables_2024, heritage_indicators, source_type = "Heritage Index of Economic Freedom")

fraser_missing_df <- flag_missing_indicators(db_variables_2024, fraser_indicators, source_type = "Fraser Institute")

aspire_missing_df <- flag_missing_indicators(db_variables_2024, aspire_indicators, source_type = "ASPIRE")

wbl_missing_df <- flag_missing_indicators(db_variables_2024,
                                          wbl_indicators,
                                          source_type = "CLIAR")


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
  message("⚠️ Issue detected:
There are missing indicators not found in the extracted data.")
  print(all_missing_vars)
} else {
  message("✅ All expected indicators are present in the extracted data.")
}

# ...by etl source -------------------------------------------------------
# db variables source column is not reliable at this point.
# Build a compiled indicators panel df to check matching
sources <-  db_variables_2024 |>
  count(source)

# Step 1: Clean and classify
dictionary_clean <- dictionary_identifiers |>
  mutate(
    variable = str_trim(as.character(variable)),
    etl_source = case_when(
      # Exact match group
      variable %in% c(
        "bs_sgi",
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
        "wb_wwbi",
        "wjp_rol"
      ) ~ "wb_api",
      variable == "fraser_efw" ~ "fraser",
      variable %in% c(
        "heritage_business",
        "heritage_financial",
        "heritage_investment"
      ) ~ "heritage",
      variable == "oecd_epl" ~ "oecd_epl",
      variable == "oecd_pmr" ~ "oecd_pmr",
      variable == "romelli_cbi" ~ "romelli",
      variable == "aspire" ~ "wb_aspire_api",
      variable == "wb_debt" ~ "debt_transparency",
      variable == "wb_gfdb" ~ "gfdb",
      variable == "wb_pefa" ~ "pefa",
      variable == "wb_wbl" ~ "wb_wbl",
      variable == "vdem_core" ~ "vdem",
      TRUE ~ "wdi"
    )
  )

# Map etl_source by source
etl_mapping <- dictionary_clean |>
  distinct(source, etl_source) |>
  # fix sources to be more specific about provenance
  mutate(
    source = case_when(
      source == "CLIAR" & etl_source == "debt_transparency" ~ "CLIAR (Debt Transparency)",
      source == "CLIAR" & etl_source == "wb_wbl" ~ "CLIAR (WBL)",
      source == "CLIAR" & etl_source == "wb_api" ~ "CLIAR (WB API)",
      T ~ source
    )
  )

# Step 3:Join to db_variables_2024
db_variables_2025 <- db_variables_2024 |>
  mutate(
    source = case_when(
      source == "CLIAR" & str_detect(variable, "^wb_debt") ~ "CLIAR (Debt Transparency)",
      source == "CLIAR" & str_detect(variable, "^wb_wbl") ~ "CLIAR (WBL)",
      source == "CLIAR" & str_detect(variable, "^wb_gtmi") ~ "CLIAR (WB API)",
      T ~ source
    )
  ) |>
  left_join(etl_mapping, by = "source")

# Ultimately check d360 API indicators
api_missing_indicators <- flag_missing_indicators(
  db_variables_2025,
  d360_efi_data,
  source_type = "wb_api",
  source_colname = "etl_source"
)

print(api_missing_indicators)


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
    "Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","Yes","No","No","No","Yes"
  ),
  Benchmark_dynamic_indicator = c(
    "Yes","Yes","Yes","Yes","Yes","No","Yes","Yes","Yes","No","No","Yes","Yes"
  ),
  Benchmark_dynamic_family_aggregate = c(
    "Partial","Partial","Partial","Partial","Partial","No","Partial","No","No","No","No","No","Partial"
  )
)

# Clean and prepare db_variables
db_variables <- db_variables_2025 |>
  clean_names() |>
  mutate(
    variable = make_clean_names(variable),
    var_name = str_to_sentence(var_name, locale = "en") # To Sentence
  )


# Add family-level variables to db_variables: ranks and names
db_variables <- db_variables |>
  mutate(
    across(where(is.character), str_squish)
  ) |>
  rename(
    rank_id = indicator_order
  ) |>
  mutate(
    rank_id = rank_id + 1
  )



# Create a family_var column to link family-level vars
family_level_vars <- db_variables |>
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
db_variables_final <- db_variables |>
  bind_rows(family_level_vars) |>
  arrange(family_var, rank_id)


# Add time stamp
db_variables <- db_variables |>
  add_plmetadata(source = "metadata dictionary",
                 other_info = "")


# Add year attribute
attr(db_variables, "ref_year") <- 2025


db_variables <- db_variables |>
  add_plmetadata(source = "Own dictionary", other_info = "Version 2025, updated with indicators extracted from various sources and cleaned.")

# export data -----------------------------------------------------
usethis::use_data(db_variables, overwrite = TRUE)
usethis::use_data(db_variables_final, overwrite = TRUE)
usethis::use_data(family_order, overwrite = TRUE)
