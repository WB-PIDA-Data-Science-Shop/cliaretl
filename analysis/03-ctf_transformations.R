# Title: Calculating global closeness to frontier
# Description: This script calculates the global closeness to frontier (CTF) scores

# Inputs:
#   - data/db_variables.rda
#   - data/wb_country_list.rda
#   - data/wb_income_and_region.rda
#   - data-raw/output/compiled_indicators.csv.gz` file.
# Outputs:
#   - data/ctf_static.rda
#   - data/ctf_dynamic.rda


# INDICATORS TO RESCALE:
#
# V-DEM: Flip corruption indicators:
# Measure corruption in the opposite direction: from less corrupt to more corrupt
# so that higher values indicate stronger institutions
# PRM indicators:
# Countries are graded between 0 (less control/involvement) and
# 6 (more control/involvement).In order to rescale these indicators,
# after 2018, each indicator value is subtracted from 6. Therefore, as
# previously 0 for less control, is now 6, indicating a stronger institution.
#
# NOTE:
# Methodological note for PRM indicates that 1998 and 2013 indicators are
# comparable, but not with 2018 due to change in methodology, so we only retain
# post-2018 data.
#
# Enterprise Survey: Percent Of Firms Identifying X As A Major Constraint
# Subtract each indicator from 100, so that a low percentage of firm, for example
# 10%, will now have a score of 90, indicating stronger institutions
#
# Freedom house: Countries are graded between 1 (most free) and 7 (least free)
# Subtract each indicator from 8 so that a value of 1 for the most free is now 7,
# indicating stronger institutions.


# set-up ------------------------------------------------------------------
# Load necessary libraries
library(haven)
library(here)
library(readxl)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(janitor)

devtools::load_all()

# read-in data ------------------------------------------------------------
db_variables <- db_variables
country_list <- wb_country_list
income_and_region_class <- wb_income_and_region

compiled_indicators <- read_rds(
  here(
    "data-raw/output/compiled_indicators.rds"
  )
)

# 1. Data Preparation & Rescaling ----------------------------------------------

## 1.1 Prepare Data -----

# Subset data to only include year 2013 -> ref_year
cliar_indicators <- compiled_indicators |>
  # filter to only years 2013 or later
  filter(
    year >= 2013
  )

# Identify variables that are benchmarked for CTF calculations
vars_ctf <- db_variables |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  pull(variable)


# Build lists from metadata - auxiliary lists such as: vars_static_ctf, vars_all, etc.
var_lists <- get_variable_lists(db_variables)


## 1.2 Rescale Indicators -----
cliar_indicators_rescaled <- cliar_indicators |>
  mutate(
    # OECD PMR (0–6): reverse; drop pre-2018
    across(starts_with("oecd_pmr"),
           ~ if_else(year < 2018, NA_real_, reverse_indicator(.x, min = 0, max = 6))),
    # Freedom House (1–7): reverse
    across(starts_with("fh_fiw"), ~ reverse_indicator(.x, min = 1, max = 7)),
    # Enterprise Survey (0–100): reverse (use the actual prefix you have)
    across(starts_with("wb_enterprisesurveys"), ~ reverse_indicator(.x, min = 0, max = 100)),
    # V-DEM: flip so higher = stronger institutions
    across(c(vdem_core_v2x_pubcorr, vdem_core_v2x_execorr, vdem_core_v2cacamps), flip_indicator),
    # WDI pupil–teacher ratios: rescale to 0–1, then flip so higher = stronger
    wdi_seprmenrltczs = flip_indicator(rescale_indicator(wdi_seprmenrltczs, scale_to = 1)),
    wdi_sesecenrltczs = flip_indicator(rescale_indicator(wdi_sesecenrltczs, scale_to = 1)),
    # GFDB bank concentration (0–100): reverse
    wb_gfdb_oi_01 = reverse_indicator(wb_gfdb_oi_01, min = 0, max = 100)
  )


## 1.3 Country-Level Aggregation -----

# Calculate country-level average for each indicator
country_average <-
  #filter only data from years we are using
  cliar_indicators_rescaled |>
  # 2025 relase: use 2020-2024 average for static indicators
  filter(between(year,2020,2024)) |>
  #this groups countries together so average can be taken
  group_by(
    country_code
  ) |>
  summarise(
    across(all_of(var_lists$vars_static_ctf), ~ mean(.x, na.rm = TRUE)),
    .groups = "drop"
  ) |>
  left_join(
    cliar_indicators_rescaled |>
      filter(year == 2024) |> # 2025 release: use 2024 value for gdp per capita
      select(country_code, wdi_nygdppcapppkd),
    by = "country_code"
  )

# Get last available year for each country for static indicators
country_last_year <-
  #filter only data from years we are using
  cliar_indicators_rescaled |>
  # 2025 relase: use 2020-2024 average for static indicators
  filter(between(year,2020,2024)) |>
  arrange(country_code, year) |>
  #this groups countries together so average can be taken
  group_by(
    country_code
  ) |>
  select(
    all_of(c("year", "country_code", var_lists$vars_static_ctf))
  ) |>
  # fill missing observations for each indicator with the latest available data
  fill() |>
  # slice last available data for each country_code
  slice_tail() |>
  ungroup()

# 2. CTF Score Calculations ----------------------------------------------------
# helper fns that don't warn on all-NA
safe_min <- function(x) if (all(is.na(x))) NA_real_ else min(x, na.rm = TRUE)
safe_max <- function(x) if (all(is.na(x))) NA_real_ else max(x, na.rm = TRUE)


# Identify min and max values for each indicator to benchmark CTF scores
# Static
min_max_static <-
  cliar_indicators_rescaled |>
  # 2025 relase: use 2020-2024 average for static indicators
  filter(dplyr::between(year, 2020, 2024)) |>
  dplyr::summarise(
    dplyr::across(
      dplyr::all_of(var_lists$vars_static_ctf),
      list(min = safe_min, max = safe_max),
      .names = "{.col}-{.fn}"
    )
  ) |>
  tidyr::pivot_longer(
    dplyr::everything(),
    names_to = c("variable", ".value"),
    names_pattern = "(.*)-(.*)"
  )

# Dynamic
# note: there are quite a few cases of Infinite warnings (due to missingness)
min_max_dynamic <- cliar_indicators_rescaled |>
  filter(
    between(year,2014,2023)
  ) |>
  summarise(
    across(
      all_of(var_lists$vars_dynamic_ctf),
      list(
        min = ~ min(., na.rm = TRUE),
        max = ~ max(., na.rm = TRUE)
      ),
      .names = "{.col}-{.fn}"
    )
  ) |>
  pivot_longer(
    everything(),
    names_to = c("variable", ".value"),
    names_pattern = "(.*)-(.*)"
  ) |>
  filter(!is.infinite(min) & !is.infinite(max))


## 2.1 Static CTF -----
# Static
ctf_static <-
  country_average |>
  compute_ctf(
    var_lists$vars_static_ctf,
    min_max_static,
    "country_code",
    zero_floor = 0.01,
    exclude_pattern = "^gdp")


## 2.2 Dynamic CTF -----
# Dynamic
ctf_dynamic <-
  compute_ctf(
    cliar_indicators_rescaled,
    var_lists$vars_dynamic_ctf,
    min_max_dynamic,
    c("country_code","year"),
    zero_floor = 0.01)

# 3. Group median aggregations -------------------------------------------------
## Calculate median per group
# Static
group_ctf_static <-
  #join country list with ctf
  country_list |>
  left_join(
    ctf_static,
    by = "country_code"
  ) |>
  #group by group code
  group_by(
    group_code,
    group
  ) |>
  #take median
  summarise(
    across(
      c(all_of(var_lists$vars_static_ctf)),
      ~ median(., na.rm = TRUE)
    ),
    .groups = "drop"  # optionally ungroup after summarise
  ) |>
  filter(!is.na(group)) |>
  rename(
    country_name = group,
    country_code = group_code
  )

#add group_ctf value to ctf dataset
ctf_static <- tibble::add_column(ctf_static,
                                 country_group = 0,
                                 .after = "country_code")

group_ctf_static <- tibble::add_column(group_ctf_static,
                                       country_group = 1,
                                       .after = "country_code")

# Dynamic
group_ctf_dynamic <-
  country_list |>
  #join country list with ctf
  left_join(
    ctf_dynamic,
    by = "country_code",
    relationship = "many-to-many"
  ) |>
  # group by group_code, group_name, and year
  group_by(group_code, group, year) |>
  # take median
  summarise(across(all_of(var_lists$vars_dynamic_ctf),
                   ~ median(., na.rm = TRUE)),
            .groups = "drop") |>  # optionally drop grouping
  # filter out rows with missing group_name
  filter(!is.na(group)) |>
  # rename group_name to country_name and group_code to country_code
  rename(country_name = group,
         country_code = group_code)

# add group_ctf value to ctf dynamic dataset
ctf_dynamic <- tibble::add_column(ctf_dynamic,
                          country_group = 0,
                          .after = "country_code")

group_ctf_dynamic <- tibble::add_column(group_ctf_dynamic,
                                country_group = 1,
                                .after = "country_code")

## 3.1 Prepare static data ----
# Clean CTF static data and incorporate logged GDP per capita and
ctf_static <-
  ctf_static |>
  # add country codes and names
  left_join(
    country_list |> distinct(country_code, country_name),
    by = c("country_code")
  ) |>
  # add gdp per capita (PPP) data
  # use average value (as in legacy ctf)
  left_join(
    country_average |> select(country_code, wdi_nygdppcapppkd),
    by = c("country_code")
  ) |>
  # rename and transform gdp per capita to log
  mutate(
    log_gdp = log(wdi_nygdppcapppkd)
  ) |>
  bind_rows(group_ctf_static) |>
  ungroup() |>
  arrange(country_name) |>
  select(
    country_code,
    country_name,
    everything()
  )

# Convert to long-form
ctf_long <-
  ctf_static |>
  pivot_longer(
    all_of(var_lists$vars_static_ctf),
    names_to = "variable"
  ) |>
  select(-contains("gdp")) |>
  left_join(
    db_variables |>
      select(variable, var_name, family_name, family_var),
    by = "variable"
  ) |>
  left_join(
    country_list |>
      select(country_code, group),
    relationship = "many-to-many",
    by = "country_code",
  )

# Add group medians to long data
ctf_long_clean <-
  ctf_long |>
  group_by(family_name, family_var, country_name, country_code, group, country_group) |>
  summarise(value = median(value, na.rm = TRUE)) |>
  ungroup() |>
  mutate(
    variable = family_var,
    var_name = family_name
  ) |>
  bind_rows(ctf_long)

## 3.2 Prepare dynamic data ----
# Clean CTF dynamic data and incorporate logged GDP per capita
ctf_dynamic <-
  ctf_dynamic |>
  # add country codes and names
  left_join(
    country_list |> distinct(country_code, country_name),
    by = "country_code"
  ) |>
  # add gdp per capita (PPP) data
  left_join(
    cliar_indicators |> select(country_code, year, wdi_nygdppcapppkd),
    by = c("country_code", "year")
  ) |>
  # rename and transform gdp per capita to log
  mutate(
    log_gdp = log(wdi_nygdppcapppkd)
  ) |>
  bind_rows(group_ctf_dynamic) |>
  ungroup() |>
  arrange(country_name) |>
  select(
    country_code,
    country_name,
    everything()
  )

ctf_dynamic_long <-
  ctf_dynamic |>
  pivot_longer(
    all_of(var_lists$vars_dynamic_ctf),
    names_to = "variable"
  ) |>
  select(-contains("gdp")) |>
  left_join(
    db_variables |>
      select(variable, var_name, family_name, family_var)
  ) |>
  left_join(
    country_list |>
      select(country_code, country_name, country_name, group),
    relationship = "many-to-many",
    by = "country_code",
  )

ctf_dynamic_long_clean <-
  ctf_dynamic_long |>
  group_by(family_name, family_var, country_code, country_group, group, year) |>
  summarise(value = median(value, na.rm = TRUE)) |>
  ungroup() |>
  mutate(
    variable = family_var,
    var_name = family_name
  )

# 4. Clusters aggregated data -----------------------------------------------

# Calculate family level data. For more info '?compute_family_average()'
# Static
ctf_static_family <-
  ctf_static |>
  compute_family_average(
    vars = var_lists$vars_static_family_ctf,
    db_variables = db_variables)

# Dynamic
ctf_dynamic_family <-
  ctf_dynamic |>
  # only retain even years because data is updated every two-years
  filter(
    year %% 2 == 0
  ) |>
  compute_family_average(
    vars = c(var_lists$vars_dynamic_family_ctf, var_lists$vars_dynamic_partial_ctf),
    type = "dynamic",
    db_variables = db_variables
  )

# join family averages to ctfs
ctf_static_clean <-
  ctf_static |>
  left_join(
    ctf_static_family,
    by = "country_code"
  )

ctf_dynamic_clean <- ctf_dynamic |>
  left_join(
    ctf_dynamic_family,
    by = c("country_code", "year")
  )

# Export Data -----
saveRDS(
  ctf_static_clean,
    here("data-raw", "output", "static_ctf_pre_quality.rds")
)

saveRDS(
  ctf_dynamic_clean,
    here("data-raw", "output", "dynamic_ctf_pre_quality.rds")
)

