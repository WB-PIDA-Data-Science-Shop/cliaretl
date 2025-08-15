################################################################################
##################### PREPARE THE PEFA ASSESSMENTS DATA ########################
################################################################################

#### load packages
library(janitor)
library(dplyr)
library(countrycode)
library(readxl)


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

dbvar_dt <- read_excel("data-raw/input/cliar/db_variables.xlsx")


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

#### prepare the country list from the previous pefa dataset and the worldbank
#### country list
# country_list <- unique(c(origpefa_tbl$country,
#                          wb_country_list$country_name))

code_df <-
  wb_country_list |>
  dplyr::select(country_code, country_name) |>
  unique()

#### select the set of variables from the db_variables list
pefa_vars <- intersect(colnames(pefaclean_tbl), dbvar_dt$variable)


#### save the data
pefaclean_tbl <-
  pefaclean_tbl |>
  rename(country_name = "country") |>
  dplyr::filter(country_code %in% unique(code_df[["country_code"]])) |>
  dplyr::select(country_name, country_code, year, all_of(pefa_vars))

pefa_assessments <- pefaclean_tbl


### write the pefa assessments data to rda
usethis::use_data(pefa_assessments, overwrite = TRUE)





