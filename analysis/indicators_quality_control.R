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
debt_transparency <- debt_transparency
wdi_indicators <- wdi_indicators
pefa_assessments <- pefa_assessments
romelli <- romelli
vdem_data <- vdem_data


# Dictionary df
db_variables <-  read_xlsx(
  here("data-raw", "input", "cliar", "db_variables.xlsx")
)


# conflicting indicators analysis ---------------------------------------------

# 1. Mismatching Indicators
# Identify indicators in the databases that do not match the reference dictionary (`db_variables`).
# For each flagged indicator, assess the following:
# a. Has the original data source renamed or updated the indicator?
#    If yes, notify the team so the `db_variables` dictionary can be updated accordingly.
# b. Is the indicator irrelevant to the current indicator framework?
#    If yes, consider removing it from the database to maintain consistency with `db_variables`.

dataframes <- list(
                  debt_transparency = debt_transparency,
                  wdi_indicators = wdi_indicators,
                  pefa_assessments = pefa_assessments,
                  romelli = romelli,
                  vdem_data = vdem_data
                )

# Apply the `flag_mismatched_indicators` function across all and bind results
all_mismatched_vars <- map_dfr( #From list to data frame
  names(dataframes),
  function(name) {
    mismatched_df <- flag_mismatched_indicators(dataframes[[name]], db_variables)[[1]]
    mismatched_df|> mutate(source = name)
  }
)

print(all_mismatched_vars)

# 2. Missing Indicators
# Here we are interested in flagging those variables expected but not present.

# First, anchor the data frame to the source to subset db_variables to the indicators of
# interest with the following object:

db_var_meta_source <- db_variables|>
  mutate(variable = case_when(
    str_starts(variable, "wdi_") ~ "wdi_", ### To be updated in the extraction
    TRUE ~ str_extract(variable, "^([^_]+_[^_]+)")
  )) |>
  distinct(variable, source)

# Then call the function to each of the data frames
wdi_missing_df <- flag_missing_indicators(db_variables, wdi_indicators, source_type = "WDI")

vdem_missing_df <- flag_missing_indicators(db_variables, vdem_data, source_type = "V-Dem, Variety of Democracy database")

pefa_missing_df <- flag_missing_indicators(db_variables, pefa_assessments, source_type = "Public Expenditure Financial Accountability")


# Combine them into a single dataframe
all_missing_vars <- bind_rows(wdi_missing_df, vdem_missing_df, pefa_missing_df)


# test draft --------------------------------------------------------------

if (nrow(all_mismatched_vars) > 0) {
  message("⚠️ Issue detected: There are mismatched indicators between extracted data and the dictionary.")
  print(all_mismatched_vars)
} else {
  message("✅ All extracted indicators match the dictionary definitions.")
}


if (nrow(all_missing_vars) > 0) {
  message("⚠️ Issue detected: There are missing indicators not found in the extracted data.")
  print(all_missing_vars)
} else {
  message("✅ All expected indicators are present in the extracted data.")
}

