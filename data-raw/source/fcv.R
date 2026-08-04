## code to prepare `fcv` dataset goes here
# last updated: 7/21/2026
library(openxlsx)
library(dplyr)
library(countrycode)
library(janitor)

# note that starting in FY2027, the World Bank publishes two separate lists:
# 1. Public FCV List and 2. Institutional Fragility List
# for simplicity, we combine them
fcv_input <- read.xlsx(
  "data-raw/input/wb/fcv.xlsx"
)

fcv <- fcv_input |>
  clean_names() |>
  transmute(
    country_name = country,
    group = "Fragile, Conflict and Violence (FCV)",
    group_code = "FCV"
  ) |> 
  mutate(
    country_code = countrycode(country_name, origin = "country.name", dest = "wb")
  ) |> 
  select(
    country_code, country_name, group, group_code
  )

fcv <- fcv |>
  add_plmetadata(
    source = "https://www.worldbank.org/en/topic/fragilityconflictviolence/brief/classification-of-fragile-and-conflict-affected-situations",
    other_info = "The data is from the World Bank and represents countries classified as fragile, conflict-affected, or experiencing violence."
  )

usethis::use_data(fcv, overwrite = TRUE)
