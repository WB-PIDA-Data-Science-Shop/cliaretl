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

compiled_indicators <- readRDS(
  here("data-raw", "input", "cliar", "compiled_indicators.rds")
)


# 1. Create Panel ----------------------------------------------------

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
  rise_indicators = rise_indicators, # Provisional
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


##QC: Indicators Selection control ------------------------------------------

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



# 2. Clusters avgs processing ---------------------------------------------

# This section computes family (clusters) averages,
# dynamically adapting to the selection of indicators from `db_variables`.
# Essentially creating the family averages for each country and year useful for
# the CLIAR CTF analysis.

# a. Get the variable lists from the database variables
# Pull the family keys as a character vector
vars_all_lists <- get_variable_lists(db_variables)
families_vec   <- vars_all_lists$vars_family  # <- this is the vector you need

# Create a long format of the indicators
cliar_indicators_long <-
  cliar_indicators |>
  tidyr::pivot_longer(
    cols = -c(country_code, country_name, year),
    names_to = "variable", values_to = "value"
  ) |>
  # if you meant to drop GDP *variables*, filter rows (not select columns)
  dplyr::filter(!grepl("gdp", variable, ignore.case = TRUE)) |>
  dplyr::left_join(
    db_variables |>
      dplyr::select(variable, var_name, family_name, family_var),
    by = "variable"
  )

# b. Calculate the family averages
cliar_family_level_long <- cliar_indicators_long |>
  dplyr::filter(family_var %in% families_vec) |>
  dplyr::group_by(country_code, year, family_var) |>
  dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop")


# Pivot the long format to wide format
cliar_family_level <- cliar_family_level_long |>
  tidyr::pivot_wider(
    id_cols   = c(country_code, year),
    names_from  = family_var,
    names_glue  = "{family_var}_avg",
    values_from = value
  )

# c. Join the family averages back to the original indicators
cliar_indicators_clean <- cliar_indicators |>
  left_join(
    cliar_family_level,
    by = c("country_code", "year")
  ) |>
  filter(!country_code %in% c("DDR", "YMD"))



## QC: Country code consistency ------------------------------------------------
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

  # 2) Optional check: code + name pairs match official list
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


## QC: Uniqueness ------------------------------------

# Identify duplicates for Kosovo (country code "XKX")
dup_xkx <- cliar_indicators_clean |>
  filter(country_code == "XKX") |>
  group_by(year) |>
  filter(n() > 1) |>
  ungroup()

# Remove id-only columns
id_cols <- c("country_code", "year")
dup_noid <- dup_xkx |> select(-country_name)

# Find duplicates that are not identical across all indicators
non_identical <- dup_noid |>
  distinct() |>           # collapse perfectly identical rows
  anti_join(dup_noid, by = names(dup_noid))

# print(non_identical) #For all duplicates for XKX, all values are the same

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


## QC: Panel completeness --------------------------------------

# Define your year range
all_years <- 1990:ref_year

# Ensure every country has the full set of years
cliar_indicators_completed <- cliar_indicators_clean |>
  group_by(country_code, country_name) |>
  complete(year = all_years) |>
  ungroup()

# Issue with TUV
extra_years <- cliar_indicators_completed |>
  filter(country_code == "TUV", year == 2025) |>
  summarise(across(everything(), ~!is.na(.))) |>
  pivot_longer(everything(),
               names_to = "column",
               values_to = "has_value") |>
  filter(has_value)

# Drop Tuvalu (TUV) for 2025 as it has only PEFA data
cliar_indicators_clean <- cliar_indicators_completed |>
  filter(!(year == "2025"))


test_that(
  "Verify that country codes have coverage for all years",{
    expect_equal(
      # calculate number of years covered by country
      cliar_indicators_clean |>
        count(country_code) |>
        pull(n) |>
        unique(),
      ref_year - 1990 # 1990 to ref_year inclusive
    )
  }
)
# 3. Brief Coverage diagnostics -------------------------------------------------

# Internal coverage: Use the compute_coverage function from funs.R to create
# the coverage countries and years it is present for. With that information,
# percentage coverage,# year range, percent of complete records, as well as
# standard distribution information such as mean and standard deviation are calculated.

wb_regions <- c(
  "Africa Eastern and Southern",
  "Africa Western and Central",
  "East Asia & Pacific",
  "Europe & Central Asia",
  "Latin America & Caribbean",
  "Middle East & North Africa",
  "South Asia"
)

# Create a list of country codes and regions
country_region_list <- wb_countries |>
  # this filter excludes Canada, Bermuda and USA
  filter(group %in% wb_regions) |>
  select(country_code, region = group)

# Compute coverage for each indicator
cliar_indicators_diagnostic <- cliar_indicators_clean |>
  select(-country_name) |>
  compute_coverage(country_code, year, ref_year - 5) |>
  left_join(
    db_variables |> select(variable, var_name, source, family_name),
    by = c("Indicator" = "variable")
  ) |>
  select(
    `Indicator`,
    `Indicator Name` = var_name,
    `Institutional Family` = family_name,
    everything(),
    `Data Source` = source
  ) |>
  arrange(
    `Institutional Family`,
    Indicator
  )


# 4. Incorporate income and region class -------------------------------------

# We incorporate the country income group and region.
# Please note that there is no available data on income group for Venezuela
# (`country_code` == "VEN").

# We retroactively classify income groups using must recent data.
# For info on income groups, see: ?wb_income_and_region

cliar_indicators_classified_complete <- cliar_indicators_clean |>
  left_join(
    wb_income_and_region |>
    select(-country_name), # Keep cliar country_codes only
    by = c("country_code")
  ) |>
  select(
    country_code, country_name, income_group, region, year, everything()
  )


# 5. Save the compiled indicators panel -------------------------------------

write.csv(
  cliar_indicators_classified_complete,
  here("data-raw", "output", "compiled_indicators.csv.gz"),
  row.names = FALSE,
  fileEncoding = "UTF-8"
)


