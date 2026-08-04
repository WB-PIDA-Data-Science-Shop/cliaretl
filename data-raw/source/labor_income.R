## code to prepare `labor_income` dataset goes here
# source: https://ilostat.ilo.org/topics/labour-income/
# last updated: 7/21/2026
library(dplyr)
library(readr)
library(countrycode)

labor_income_raw <- read_csv(
  "https://rplumber.ilo.org/data/indicator/?id=SDG_1041_NOC_RT_A&lang=en&type=label&format=.csv&channel=ilostat&title=sdg-indicator-1041-labour-income-share-as-a-percent-of-gdp-annual"
)

labor_income <- labor_income_raw |> 
  transmute(
    country_code = countrycode(ref_area.label, origin = "country.name", dest = "wb"),
    year = time,
    labor_income = obs_value,
    status_label = obs_status.label
  )

labor_income <- labor_income |>
  add_plmetadata(
    source = "https://ilostat.ilo.org/topics/labour-income/",
    other_info = "The data is from ILOSTAT and represents the share of labor income as a percentage of GDP."
  )

usethis::use_data(labor_income, overwrite = TRUE)
