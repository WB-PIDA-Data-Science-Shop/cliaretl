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
library(testthat)
library(janitor)

# Load custom functions
devtools::load_all()

# Generate output data folder
if(
  !dir.exists(here::here("data-raw", "output"))
) dir.create(here::here("data-raw", "output"))

# Extract the reference year
ref_year <- attr(db_variables, "ref_year")
print(ref_year)


# read-in data ------------------------------------------------------------

# read-in data sources
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

# read-in metadate variables
db_variables <- db_variables
wb_countries <- wb_country_list
family_order <- family_order

# Provisional data
rise_indicators <- read_dta(
  here("data-raw", "input", "RISE_20102021.dta")
  ) |> clean_names()




# compiling indicators ----------------------------------------------------

d30_indicators_clean <- d30_indicators |>
  select(!starts_with("wb_pefa_"))

excluded_country_code <- c(
  "AIA", # Anguilla
  "OECD", # OECD
  "SML", # Somaliland
  "ZZB", # Zanzibar
  "CUB", # Cuba
  "PRK", # Democratic People's Republic of Korea
  "KMH", # Unclear, listed in Open Budget Survey
  "PSG", # Palestine and Gaza (VDEM)

  # From missing_countries
  "COK", # Cook Islands
  "ECB", # Eastern Caribbean Bank area
  "LTE", # Low- and Middle-Income Europe & Central Asia (aggregate)
  "MIC", # Middle Income Countries (aggregate)
  "NIU", # Niue
  "PSS", # Pacific Island Small States
  "SPM"  # Saint Pierre and Miquelon
)

cliar_indicators <- list(
  debt_transparency_indicators = debt_transparency,
  pefa_assessments_indicators = pefa_assessments,
  romelli_indicators = romelli,
  vdem_data_indicators = vdem_data,
  gfdb_indicators = gfdb,
  heritage_indicators = heritage,
  pmr_indicators = pmr,
  epl_indicators = epl,
  d30_indicators = d30_indicators_clean,
  fraser_indicators = fraser,
  aspire_indicators = aspire,
  wbl_indicators = wbl_data,
  rise_indicators = rise_indicators,
  wdi_wb_indicators = wdi_indicators
) |>
  map(
    ~ mutate(
      .x,
      country_code = case_when(
        country_code == "ZAR" ~ "COD",
        country_code == "ROM" ~ "ROU",
        TRUE ~ country_code
      )
    )
  ) |>
  reduce(full_join, by = c("country_code", "year")) |>
  filter(
    !(country_code %in% excluded_country_code),
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

# verify that the indicators are selected correctly
db_variables_indicators <- db_variables |>
  select(
    variable
  )

# labell indicators with country codes
cliar_indicators <- cliar_indicators |>
  left_join(
    wb_countries |> distinct(country_code, country_name),
    by = "country_code"
  ) |>
  select(
    country_code,
    country_name,
    year,
    any_of(db_variables_indicators |>
             pull(variable))  # Changed from all_of to any_of
  )

# this object allows to track all indicators that are landing
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



 ## Country avgs processing ---------------------------------------------

## Compute family averages
vars_family <- get_variable_lists(db_variables)

# This section computes family averages, dynamically adapting to the selection of indicators.

# compute family averages
cliar_indicators_long <-
  cliar_indicators |>
  pivot_longer(
    cols = -c(country_code, country_name, year),  # Added country_name here
    names_to = "variable"
  ) |>
  select(-contains("gdp")) |>
  left_join(
    db_variables |>
      select(variable, var_name, family_name, family_var),
    by = "variable"
  )

# only calculate family averages for relevant institutional clusters
cliar_family_level_long <- cliar_indicators_long |>
  filter(
    family_var %in% vars_family
  ) |>
  group_by(
    country_code, year, family_var
  ) |>
  summarise(
    value = mean(value, na.rm = TRUE),
    .groups = "drop"
  )

cliar_family_level <- cliar_family_level_long |>
  pivot_wider(
    id_cols = c(country_code, year),
    names_from = family_var,
    names_glue = "{family_var}_avg",
    values_from = value
  )

cliar_indicators_clean <- cliar_indicators |>
  left_join(
    cliar_family_level,
    by = c("country_code", "year")
  ) |>
  filter(!country_code %in% c("DDR", "YMD"))



# 2. Country code consistency ------------------------------------------------
# Define the list of regional/aggregate codes to exclude
regional_codes <- c(
  "AFE", "AFW", "ARB", "CEB", "CSS", "EAP", "EAR", "EAS", "ECA", "ECS", "EMU", "EUU",
  "FCS", "HIC", "HPC", "IBD", "IBT", "IDA", "IDB", "IDX", "LAC", "LCN", "LDC", "LIC",
  "LMY", "LMC", "MEA", "MNA", "NAC", "OED", "OSS", "PRE", "PST", "SAS", "SSA", "SSF",
  "SST", "TEA", "TEC", "TLA", "TMN", "TSA", "TSS", "UMC", "WLD",
  "DDR", "YMD"
)

cliar_indicators_clean <- cliar_indicators |>
  left_join(cliar_family_level, by = c("country_code", "year")) |>
  filter(!country_code %in% regional_codes)

test_that("All country codes are official WB countries", {
  # 1) Codes subset check (by code only)
  bad_codes <- setdiff(
    unique(cliar_indicators_clean$country_code),
    unique(wb_country_list$country_code)
  )

  expect_equal(
    length(bad_codes), 0L,
    info = paste0("Unexpected codes found: ", paste(bad_codes, collapse = ", "))
  )

  # 2) Optional stricter check: code + name pairs match official list
  missing_pairs <- cliar_indicators_clean |>
    distinct(country_code, country_name) |>
    anti_join(
      wb_country_list |>
        distinct(country_code, country_name),
      by = c("country_code", "country_name")
    )

  expect_equal(
    nrow(missing_pairs), 0L,
    info = paste0(
      "Mismatched code-name pairs (first 10):\n",
      paste(utils::capture.output(print(utils::head(missing_pairs, 10))), collapse = "\n")
    )
  )
})


# 3. Distinct country-year consistency ------------------------------------

# Remove exact duplicates and ensure unique country-year pairs for Kosovo
cliar_indicators_clean <- cliar_indicators_clean |>
  distinct() |>  # remove exact duplicates
  group_by(country_code, year) |>
  filter(
    country_code != "XKX" | row_number() == 1
  ) |>
  ungroup()



test_that("CLIAR has no duplicate country-year pairs", {
  dup_check <- cliar_indicators_clean |>
    count(country_code, year) |>
    filter(n > 1)

  expect_equal(nrow(dup_check), 0L,
               info = paste("Duplicated country-years found:",
                            paste(dup_check$country_code, dup_check$year, sep = "-", collapse = ", ")))
})


# 4. Panel country-year observations --------------------------------------

test_that(
  "Verify that country codes have coverage for all years",{
    expect_equal(
      # calculate number of years covered by country
      cliar_indicators_clean |>
        count(country_code) |>
        pull(n) |>
        unique(),
      ref_year + 1 - 1990 # 1990 to ref_year inclusive
    )
  }
)

# See the distribution of years per country
coverage_summary <- cliar_indicators_clean |>
  count(country_code, name = "years_covered") |>
  count(years_covered, name = "countries_with_this_coverage")

print(coverage_summary)

# Find countries with incomplete coverage
incomplete_coverage <- cliar_indicators_clean |>
  count(country_code) |>
  filter(n != (ref_year - 1990)) |>
  arrange(n)

print(incomplete_coverage)

cliar_indicators_clean |>
  count(country_code, country_name, name = "years_covered") |>
  filter(years_covered == 36)

# 5. Save the compiled indicators panel -----------------------------------

# Work in progress

