## code to prepare `debt_transparency` dataset goes here
# Source: World Bank Debt Transparency Report (Tableau dashboard)
#   https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report
#
# 1. DOWNLOAD: In Tableau, click "Download" (bottom-right) > "Corsstab" (not
#    Image/PDF) > "Debt Report" if offered. Export as CSV UTf-8.
#
# 2. NAME: Save to data-raw/input/debt_transparency/ as
#    debt_report_data_<YEAR>.csv (e.g. debt_report_data_2024.csv). The
#    pipeline detects the year from this filename, so follow it exactly.
#    If the format is wide, add the prefix to the file name (e.g. wide_debt_report_data_2025.csv). 

# access date: 8/11/2026

library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(countrycode)
library(janitor)
library(stringr)
library(here)



# load-data --------------------------------------------------------------

# load all debt transparency datasets untill 2024 and combine into one dataframe
debt_transparency_input <- list.files(
  here("data-raw", "input", "debt_transparency"),
  pattern = "^debt_report*",
  full.names = TRUE
) |>
  map(read_csv, id = "dataset") |>
  bind_rows() |>
  clean_names()

# load 2025 debt transparency dataset separately (wide)
debt_2025_raw <- read_csv(here("data-raw", "input", "debt_transparency", "wide_debt_report_data_2025.csv"),
          skip = 1) |> 
          clean_names() 
  


# data-clean -------------------------------------------------------------

# convert long panel to tidy format
debt_transparency_panel <- debt_transparency_input |>
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

# rename first columns under 2020 -2024 convention
debt_2025_long <- debt_2025_raw |>
  select(-c(3,6:7)) |> 
  rename(
    country = x1,
    criteria = x2,
    assessment = x4,
    explanation = x5
  ) |> 
   pivot_longer(
    cols = c(data_accessibility:additional_statistics_memo_items),
    names_to = "indicator",
    values_to = "size"
   ) |> 
  drop_na(size
  ) |>
  # insert year column
  mutate(year = 2025) |>
  # select relevant columns
  select(country, year, indicator, criteria, assessment, explanation) 


# Tranform amd rename iondicators 
debt_2025_clean <- debt_2025_long |> 
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
    debt_transp_information = information_on_recently_contracted_external_loans,  
    debt_transp_periodicity = periodicity,                             
    debt_transp_time = time_lag,                                            
    debt_transp_dms = debt_management_strategy_dms,                   
    debt_transp_abp = annual_borrowing_plan_abp,                       
    debt_transp_addition = additional_statistics_memo_items                
  ) |>
  mutate(
    across(
      starts_with("debt_transp"),
      \(string) substr(string, 1, 1) |> as.numeric()
    )
  )



# data tranf -------------------------------------------------------------

# bind the two datasets together
debt_transparency_full <- bind_rows(debt_transparency_panel, debt_2025_clean)


# correct country names
debt_transparency_cname <- debt_transparency_full |>
  mutate(
    country = case_when(
      country == "Cabo Verde" ~ "Cape Verde",
      country == "Côte d'Ivoire" ~ "Ivory Coast",
      country == "São Tomé and Príncipe" ~ "Sao Tome and Principe",
      country == "São Tomé and Principe" ~ "Sao Tome and Principe",
      TRUE ~ country
    )
  )

# add iso3c country codes
debt_transparency_ccode <- debt_transparency_cname |>
  mutate(
    country_code = countrycode(country, origin = "country.name", destination = "iso3c")
  )

# correct Kosovo country code
debt_transparency_final <- debt_transparency_ccode |>
  mutate(
    country_code = ifelse(country == "Kosovo", "XKX", country_code)
  ) |>
  select(country_code, year, everything())


# create debt transparency index (average of all indicators) and clean column names
debt_transparency <-
  debt_transparency_final |>
  mutate(
    debt_transp_index = rowMeans(
      across(starts_with("debt_transp")),
      na.rm = TRUE
    ) |>
      round(2)
  ) |>
  clean_names() |>
  rename_with(
    # add prefixes with cliar conventions
    ~ paste0("wb_", .),
    .cols = starts_with("debt")
  ) |>
  dplyr::select(country_code, year, wb_debt_transp_index)



# export -----------------------------------------------------------------

debt_transparency <-
  debt_transparency |>
  add_plmetadata(source = "https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report",
                 other_info = "2026 extraction date: 8/11/2026.")


usethis::use_data(debt_transparency, overwrite = TRUE)