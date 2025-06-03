## code to prepare `debt_transparency` dataset goes here
# source: https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report
# access date: 6/3/2025
# note: each dataset had to be individually downloaded using the Tableau interface.
# to do so, ensure that you select the "Download" option (bottom right) in the Tableau interface and choose "Data" to get the data in a tabular format.
library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(countrycode)
library(janitor)
library(haven)
library(here)

debt_test <- read_dta(
  here("data-raw", "input", "debt_transparency", "debt_transparency_2021-2022.dta")
)

debt_transparency_input <- list.files(
  here("data-raw", "input", "debt_transparency"),
  pattern = "^debt_report*",
  full.names = TRUE
) |>
  map(read_csv, id = "dataset") |>
  bind_rows() |>
  clean_names()

# convert to tidy format
debt_transparency <- debt_transparency_input |>
  mutate(
    year = gsub("^.*?([0-9]{4}).*$", "\\1", dataset),
  ) |>
  select(country, year, indicator, criteria) |>
  pivot_wider(
    id_cols = c(country, year),
    names_from = "indicator",
    values_from = "criteria"
  ) |>
  clean_names() |>
  transmute(
    country = country,
    year = as.integer(year),
    debt_transp_data = data_accessibility,
    debt_transp_instrument = instrument_coverage,
    debt_transp_sectorial = sectorial_coverage,
    debt_transp_information = coalesce(information_on_recent_contracted_loans, information_on_recently_contracted_external_loans),
    debt_transp_periodicity = periodicity,
    debt_transp_time = coalesce(time_range, time_lag),
    debt_transp_dms = coalesce(debt_management_strategy, debt_management_strategy_dms),
    debt_transp_abp = coalesce(annual_borrowing_plan, annual_borrowing_plan_abp),
    debt_transp_addition = coalesce(other_debt_statistics_contingent_liabilities_c_ls, additional_statistics_memo_items)
  ) |>
  mutate(
    across(
      starts_with("debt_transp"),
      \(string) substr(string, 1, 1) |> as.numeric()
    )
  )

# correct country names
debt_transparency <- debt_transparency %>%
  mutate(
    country = case_when(
      country == "Cabo Verde" ~ "Cape Verde",
      country == "Côte d'Ivoire" ~ "Ivory Coast",
      country == "São Tomé and Príncipe" ~ "Sao Tome and Principe",
      country == "São Tomé and Principe" ~ "Sao Tome and Principe",
      TRUE ~ country
    )
  )

debt_transparency <- debt_transparency %>%
  mutate(
    country_code = countrycode(country, origin = "country.name", destination = "iso3c")
  )

debt_transparency <- debt_transparency %>%
  mutate(
    country_code = ifelse(country == "Kosovo", "XKX", country_code)
  )

debt_transparency <- debt_transparency %>%
  select(country_code, year, everything())

debt_transparency_clean <- debt_transparency %>%
  mutate(
    debt_transp_index = rowMeans(across(starts_with("debt_transp")), na.rm = TRUE) |>
      round(2)
  )

# identify inconsistencies in the data
# in this case, we identify inconsistencies in 22/143 cases
debt_test |>
  mutate(
    debt_transp_index = round(debt_transp_index, 2)
  ) |>
  inner_join(
    debt_transparency_clean,
    by = c("country_code", "year")
  ) |>
  select(starts_with("debt_transp_index")) |>
  filter(
    debt_transp_index.x != debt_transp_index.y
  )

usethis::use_data(debt_transparency_clean, overwrite = TRUE)
