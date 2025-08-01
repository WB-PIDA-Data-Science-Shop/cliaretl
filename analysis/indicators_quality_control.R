# set-up ------------------------------------------------------------------
library(haven)
library(dplyr)
library(here)
library(readxl)
library(dplyr)
library(purrr)
library(stringr)



devtools::load_all()



# read-in data ------------------------------------------------------------

# Extracted indicators dfs
debt_transparency_indicators <- debt_transparency
wdi_wb_indicators <- wdi_indicators
pefa_assessments_indicators <- pefa_assessments
romelli_indicators <- romelli
vdem_data_indicators <- vdem_data
# Second batch
gfdb_indicators <-  gfdb
heritage_indicators <- heritage
pmr_indicators <- pmr
epl_indicators <- epl
# API indicators
d30_indicators <- d360_efi_data

# Dictionary df
db_variables <-  read_xlsx(
  here("data-raw", "input", "cliar", "db_variables.xlsx")
)


# dictionary-fix -----------------------------------------------------

# 1. WDI
# Documenting variable changes in our dictionary
# Backup original variable names (optional)
db_variables$variable_old <- db_variables$variable

# Named vector of changes: new name = old name
rename_vector <- c(
  "wdi_enghgco2rtgdpppkd" = "wdi_enatmco2eppgdkd"
)

# Apply the renaming in the `variable` column
idx <- match(db_variables$variable, rename_vector)
db_variables$variable[!is.na(idx)] <- names(rename_vector)[na.omit(idx)]


# 2. VDEM
# Problematic indicators that changed their name:
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
#    If yes, notify the team so the `db_variables` dictionary can be updated accordingly.
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
                    d30_indicators = d360_efi_data

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
                                          source_type = "WDI")

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



# Combine them into a single dataframe
all_missing_vars <- bind_rows(wdi_missing_df, vdem_missing_df, pefa_missing_df)


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

# Step 1.Build panel
# Let's re map the sources form the ETL extraction
dictionary_clean <- dictionary_identifiers |>
  mutate(etl_source = case_when(
    variable == "bs_sgi"              ~ "wb_api",
    variable == "bs_bti"              ~ "wb_api",
    variable == "fh_fiw"              ~ "wb_api",
    variable == "fraser_efw"          ~ "wb_api", # NEW TO API
    variable == "heritage_business"   ~ "heritage",
    variable == "heritage_financial"  ~ "heritage",
    variable == "heritage_investment" ~ "heritage",
    variable == "ibp_obs"             ~ "wb_api",
    variable == "idea_gsod"           ~ "wb_api",
    variable == "imf_fm"              ~ "wb_api",
    variable == "imf_gfscofog"        ~ "wb_api",
    variable == "imf_world"           ~ "wb_api",
    variable == "oecd_epl"            ~ "oecd_epl",
    variable == "oecd_pmr"            ~ "oecd_pmr",
    variable == "rise_ee"             ~ "wb_api", # NEW TO API
    variable == "rise_re"             ~ "wb_api", # NEW TO API
    variable == "romelli_cbi"         ~ "romelli",
    variable == "rwb_pfi"             ~ "wb_api",
    variable == "spi_census"          ~ "wb_api",
    variable == "spi_std"             ~ "wb_api",
    variable == "vdem_core"           ~ "vdem",
    variable == "wb_aspire"           ~ "wb_api", # NEW TO API
    variable == "wb_debt"             ~ "debt_transparency",
    variable == "wb_es"               ~ "wb_api",
    variable == "wb_gfdb"             ~ "gfdb",
    variable == "wb_girg"             ~ "wb_api",
    variable == "wb_gtmi"             ~ "wb_api",
    variable == "wb_lpi"              ~ "wb_api",
    variable == "wb_pefa"             ~ "pefa",
    variable == "wb_wbl"              ~ "wb_api",
    variable == "wb_wdi"              ~ "wb_api",
    variable == "wb_wwbi"             ~ "wb_api",
    variable == "wdi_"                ~ "wdi",
    variable == "wjp_rol"             ~ "wb_api",
    TRUE                              ~ "unknown")
  )


# Add to db_variables a new variable called etl_source

etl_mapping <- dictionary_clean |>
  group_by(source) |>
  summarise(etl_source = first(etl_source), .groups = "drop")

db_variables_joined <- db_variables |>
  left_join(etl_mapping, by = "source")

# Run full check:

compiled_sources_missing <- flag_missing_indicators(db_variables_joined,
                                                    wdi_indicators,
                                                    source_type = "source")


