# Title: Compiled Indicators Panel Analysis
# Description: This script compiles all the indicators into a data panel.

# Essentially, it checks for wb countries analysis, uniqueness and completenes .

# - Input:
# All `data/*.rda` files.
# - Output:
# `data-raw/output/compiled_indicators.csv.gz` file.


# set-up ------------------------------------------------------------------
# Load necessary libraries
library(haven)
library(here)
library(readxl)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)

# Load custom functions
devtools::load_all()


# read-in data ------------------------------------------------------------
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
db_variables <- db_variables
wb_countries <- wb_country_list


# compiling indicators ----------------------------------------------------

# Combine all indicators into a single data frame
cliar_indicators <- list(
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
  aspire_indicators = aspire
) |>
  map(
    # fix country codes for full join
    ~ mutate(
      .,
      country_code = case_when(
        country_code == "ZAR" ~ "COD", # democratic republic of congo
        country_code == "ROM" ~ "ROU", # romania
        T ~ country_code)
      )
    ) |>
  reduce(
    full_join,
    by = c("country_code", "year")
  ) |>
  filter(
    year >= 1990
  )

# order column names
cliar_indicators <- cliar_indicators |>
  select(
    country_code,
    year,
    sort(colnames(cliar_indicators))
  ) |>
  arrange(
    country_code,
    year
  ) |>
  mutate(
    index = row_number()
  )


# 1. Indicators Selection control ------------------------------------------
# Verify that the indicators are selected correctly. To do this, take the non-removed indicators from the metadata file as the indicators from combined dataset created in step 5 and ensure they have the same contents by using an anti-join in both directions. Re-select indicators to ensure that only the indicators in metadata and v2 id cols are in data.

# verify that the indicators are selected correctly
db_variables_indicators <- db_variables |>
  select(
    variable
  )


cliar_indicators <- cliar_indicators |>
  # add country names
  left_join(
    wb_country_list |>
      distinct(country_code, country_name),
    by = "country_code"
  ) |>
  select(
    country_code,
    country_name,
    year,
    all_of(db_variables_indicators |> pull(variable))
  )

cliar_indicators_id <- cliar_indicators |>
  colnames()|>
  tibble(
    variable = colnames(cliar_indicators)
  )

test_that(
  "All indicators contained in metadata are in the CLIAR dataset",{
    expect_equal(
      nrow(
        db_variables_indicators |>
          anti_join(cliar_indicators_id, by = "variable") |>
          as.data.frame()
      ),
      0
    )
  }
)

# Print issues
db_variables_indicators |>
  anti_join(cliar_indicators_id, by = "variable") |>
  as.data.frame()




# 1.1 Country avgs processing ---------------------------------------------

## Compute family averages

# This section computes family averages, dynamically adapting to the selection of indicators.

# compute family averages
cliar_indicators_long <-
  cliar_indicators |>
  pivot_longer(
    any_of(vars_all), # [ISSUE]
    names_to = "variable"
  ) |>
  select(-contains("gdp")) |>
  left_join(
    db_variables |>
      select(variable, var_name, family_name, family_var),
    by = "variable"
  )

# # only calculate family averages for relevant institutional clusters
# cliar_family_level_long <- cliar_indicators_long |>
#   filter(
#     family_var %in% vars_family
#   ) |>
#   group_by(
#     country_code, year, family_var
#   ) |>
#   summarise(
#     value = mean(value, na.rm = TRUE),
#     .groups = "drop"
#   )
#
# cliar_family_level <- cliar_family_level_long |>
#   pivot_wider(
#     id_cols = c(country_code, year),
#     names_from = family_var,
#     names_glue = "{family_var}_avg",
#     values_from = value
#   )
#
# cliar_indicators_clean <- cliar_indicators |>
#   left_join(
#     cliar_family_level,
#     by = c("country_code", "year")
#   ) |>
#   filter(!country_code %in% c("DDR", "YMD"))






