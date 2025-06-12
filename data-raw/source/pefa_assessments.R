################################################################################
##################### PREPARE THE PEFA ASSESSMENTS DATA ########################
################################################################################

#### load packages
library(janitor)
library(dplyr)
library(countrycode)


#### read in the data
base_url <- "https://www.pefa.org/sites/pefa/files/bulk_downloads"

pefa_tbl <-
  read.csv(paste0(base_url, "/assessments_1749564823.csv")) |>
  as_tibble() |>
  clean_names()

origpefa_tbl <-
  read.csv("data-raw/input/pefa_assessments/assessments_1730149268.csv") |>
  as_tibble() |>
  clean_names()


#### PEFA manual update - Defining values, update for 2024

grade_pefa <- c("D" = 1,
                "D*" = 1,
                "D+" = 1.5,
                "C" = 2,
                "C+" = 2.5,
                "B" = 3,
                "A" = 4)

## transforming the PEFA data
pefatrans_tbl <-
  pefa_tbl |>
  mutate(across(starts_with("pi_"),
                ~ ifelse(. %in% names(grade_pefa),
                         grade_pefa[.],
                         NA_real_))) |>
  rename_with(~ gsub("^pi_", "pi_2016_", .), starts_with("pi_"))


pefaclean_tbl <-
  pefatrans_tbl |>
  rename_with(~ paste0("wb_pefa_", .), .cols = starts_with("pi_")) |>
  select(-framework, -uhlg_01, -uhlg_01_1, -uhlg_01_2, -uhlg_01_3)

### handling country codes, including Kosovo
pefaclean_tbl <-
pefaclean_tbl %>%
  mutate(country_code = case_when(
    country == "Kosovo" ~ "XKX",
    TRUE ~ countrycode(country, "country.name", "iso3c", custom_match = c("Kosovo" = "XKX"))
  )) %>%
  filter(country != "Bosnia and Herzegovina - District Brčko")

#### drop the subnational data
pefaclean_tbl <-
  pefaclean_tbl |>
  dplyr::filter()




