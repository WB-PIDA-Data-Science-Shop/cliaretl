# Title: CTF transformations Quality Control
# Description: This script generates a quality control report for both ctf static
# and ctf dynamic transformations.


# - Input:
# `data-raw/output/static_ctf_quality.csv.gz`
# `data-raw/output/dynamic_ctf_quality.csv.gz`
# - Output:
# lazy loaded data
# static_ctf_scores.rds
# dynamic_ctf_scores.rds


# setup ------------------------------------------------------------------------
# Load necessary libraries
library(haven)
library(here)
library(readxl)
library(readr)
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(testthat)
library(janitor)
library(ggplot2)
library(scales)

devtools::load_all()

# read-in data ------------------------------------------------------------
country_list <- wb_country_list
db_variables <- db_variables
income_and_region_class <- wb_income_and_region

compiled_indicators <- readr::read_csv(
  here(
    "data-raw/output/compiled_indicators.csv.gz"
  )
)

static_clean <- read_csv(
  here(
    "data-raw/output/static_ctf_pre_quality.csv"
  )
)

dynamic_clean <- read_csv(
  here("data-raw/output/dynamic_ctf_pre_quality.csv"),
  na = c("", "NA", "N/A", "n/a", ".", "-", "--"),
  guess_max = 100000, # scan more
  show_col_types = FALSE
) |>
  mutate(across(where(is.logical), as.integer))  # 1/0 for logical flags


### Pre-pare data
# Generate vars_lists object
vars_ctf <- db_variables |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  pull(variable)

var_lists <- get_variable_lists(db_variables)

# 1. Regional Classification -------------------------------
# Add income group and region classifications to static and dynamic CTF datasets
ctf_static_complete <-
  static_clean |>
  left_join(
    income_and_region_class,
    by = c("country_code","country_name")
  ) |>
  select(
    country_code, country_name, income_group, region, everything()
  )

ctf_dynamic_complete <-
  dynamic_clean |>
  left_join(
    income_and_region_class,
    by = c("country_code")
  ) |>
  select(
    country_code, country_name, income_group, region, year, everything()
  )

# Create family-level variables
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
db_variables <- db_variables |>
  bind_rows(var_lists$family_level_vars) |>
  arrange(family_var, rank_id)


# 2. CTF Quality Control ---------------------------------------------------
# Test that all expected indicators and countries are covered

test_that(
  "All countries are covered",
  {
    expect_setequal(
      static_clean |> filter(country_group == 0) |> distinct(country_code) |> pull(),
      country_list |> distinct(country_code) |> pull()
    )
    expect_setequal(
      dynamic_clean |> filter(country_group == 0) |> distinct(country_code) |> pull(),
      country_list |> distinct(country_code) |> pull()
    )
  }
)

test_that(
  "All indicators are covered",
  {
    ## Shel added _avg to the pattern to take care of the new family level indicators (that all have an _avg suffix)
    expect_setequal(
      static_clean |> colnames() |> str_subset("year|country|gdp|_avg$", negate = TRUE),
      var_lists$vars_static_ctf
    )
    expect_setequal(
      dynamic_clean |> colnames() |> str_subset("year|country|gdp|_avg$", negate = TRUE),
      var_lists$vars_dynamic_ctf
    )
  }
)


# 3. Robustness Checks: 5-year Average vs. Last Available Data -----------------
# This section produces robustness checks on the computation
# of the static CTF by comparing:
#   (a) Scores based on the 5-year average
#   (b) Scores based on the latest available year
#
# First we compute the dispersion of institutional
# family-level scores by country.

# Static Benchmarking:
ctf_static_variance <- ctf_static_complete |>
  compute_family_variance(
    var_lists$vars_static_ctf,
    db_variables = db_variables
  )

# Dynamic Benchmarking:
ctf_dynamic_variance <- ctf_dynamic_complete |>
  compute_family_variance(
    var_lists$vars_dynamic_ctf,
    type = "dymamic",
    db_variables
  )

# These metrics allow us to assess the internal consistency
# and dispersion of institutional scores within each family.

## 3.1 Plot: Hist 5-year Average vs. Last Available Data -----------------

# This section produces robustness checks on the computation
# of the static CTF by comparing:
#   (a) Scores based on the 5-year average
#   (b) Scores based on the latest available year

# Rescale indicators again
cliar_indicators_rescaled <-
  compiled_indicators |>
  filter(year >= 2013) |>
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

# Transform last year ctf scores, next steps:
# 1. For each country, select the latest available year (2019-2023)
country_average_last_year <-
  cliar_indicators_rescaled |>
  #filter only data from years we are using
  filter(between(year,2019,2023)) |>
  arrange(country_code, year) |>
  #this groups countries together so average can be taken by country
  group_by(country_code) |>
  select(
    all_of(c(var_lists$vars_static_ctf))
  ) |>
  # Run "?fill" to see how it works. Essentially it helps to fill in
  # missing observations for each indicator with the latest available data
  # (e.g. if 2023 is missing, use 2022, etc. or the latest available year)
  fill() |>
  # slice last available data for each country_code
  slice_tail() |>
  ungroup()

# 2. Compute min and max for each indicator across 2019-2023
min_max_static_last <-
  cliar_indicators_rescaled |>
  filter(between(year,2019,2023)) |>
  summarise(
    across(
      all_of(var_lists$vars_static_ctf),
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
  )

# 3. Compute CTF scores using last available year data
ctf_static_last_year <-
  country_average_last_year |>
  compute_ctf(
    var_lists$vars_static_ctf,
    min_max_static_last,
    "country_code",
    zero_floor = 0.01,
    exclude_pattern = "^gdp")


# 4. Prepare long data for scatterplot
ctf_static_last_year_long <-
  ctf_static_last_year |>
  pivot_longer(
    cols = c(
      all_of(var_lists$vars_static_ctf)
    ),
    names_to = "variable",
    values_to = "ctf_last_year"
  )

# Bring the other object to merge
ctf_static_long <- static_clean |>
  filter(country_group == 0) |>
  select(country_code, all_of(var_lists$vars_static_ctf)) |>
  pivot_longer(
    cols = c(
      all_of(var_lists$vars_static_ctf)
    ),
    names_to = "variable",
    values_to = "ctf_year_average"
  )

# merge datasets using country code and variable to compute correlation
ctf_robustness <- ctf_static_last_year_long |>
  inner_join(
    ctf_static_long,
    by = c("country_code", "variable")
  )

# generate the plot
ctf_robustness |>
  ggplot() +
  geom_point(
    aes(ctf_year_average, ctf_last_year),
    color = "steelblue3",
    alpha = 0.7
  ) +
  labs(
    x = "CTF score: 5-year average",
    y = "CTF score: latest available data",
    caption = "The unit of analysis is at the country-indicator level. Please note that indicators for which either value were missing are not plotted."
  ) +
  ggtitle(
    "(2026) Correlation between CTF scores computed using (a) 5-Year Average and (b) Last-Year values for indicators"
  ) +
  theme_minimal()

## 3.2 Plot: Correlation Histogram----------
#    - Unit of analysis: country–indicator pair
#    - X-axis: 5-year average CTF score
#    - Y-axis: last available year CTF score
#    - Join keys: country_code + variable
#    - Expectation: points fall along the 45° line, indicating
#      strong correlation and consistency.

# Prepare long data for 5-year average
ctf_static_long <- static_clean |>
  filter(country_group == 0) |>
  select(country_code, all_of(var_lists$vars_static_ctf)) |>
  pivot_longer(
    cols = c(
      all_of(var_lists$vars_static_ctf)
    ),
    names_to = "variable",
    values_to = "ctf_year_average"
  )

#  plot 2: distribution of correlations by indicator
ctf_robustness |>
  group_by(variable) |>
  summarise(
    correlation = cor(ctf_last_year, ctf_year_average, use = "pairwise.complete", method = "pearson")
  ) |>
  ggplot() +
  geom_histogram(
    aes(correlation, y = stat(width*density),
        binwidth = 0.01,
        boundary = 0,  # for nicer bin alignment
        closed = "left") # control bin edges
  ) +
  geom_vline(
    xintercept = 0.95,
    linetype = "dashed",
    color = "red3"
  ) +
  scale_y_continuous(
    labels = scales::percent_format()
  ) +
  coord_cartesian(
    xlim = c(0.9, 1)
  ) +
  labs(
    x = "Correlation between CTF scores",
    y = "Percentage of Indicators",
    caption = "Dashed red line indicators a correlation above 0.95. 5 out of 137 (3.6%) indicators have a correlation below 0.95. No indicators have a correlation between 0.9."
  ) +
  ggtitle(
    "(2026) Distribution of indicator-level correlations of CTF scores"
  ) +
  theme_minimal()
# Finding: [ADD THE COEF FOR THE CORR]

# 4. Prepare final datasets ------------------------------------------------

# Final static CTF scores and time stamp
closeness_to_frontier_static <- ctf_static_complete |>
  add_plmetadata(source = "CLIAR database",
                 other_info = "")

# Final dynamic CTF scores and time stamp
closeness_to_frontier_dynamic <- ctf_dynamic_complete |>
  add_plmetadata(source = "CLIAR database",
                 other_info = "")

# Export data ------------------------------------------------------------
# Save the final datasets as RDS files for lazy loading
usethis::use_data(closeness_to_frontier_static, overwrite = TRUE)
usethis::use_data(closeness_to_frontier_dynamic, overwrite = TRUE)
