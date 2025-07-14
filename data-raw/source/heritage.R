################################################################################
########## DOWNLOAD AND PROCESS HERITAGE'S INDEX OF FREEDOM DATA ###############
################################################################################

library(readr)
library(dplyr)
library(countrycode)

#### reading the data directly from the internet

urldata <- "https://www.heritage.org/index/assets/data/csv/ef-country-scores.csv"
heritage_df <- read_csv(urldata)

urlcountry <- "https://www.heritage.org/index/assets/data/csv/ef-country-names.csv"
country_df <- read_csv(urlcountry)

#### quickly store raw data with its attributes
heritage_df |>
  add_plmetadata(source = urldata,
                 other_info = "Index of Economic Freedom Raw Data") |>
  saveRDS("data-raw/input/heritage/heritage_iof_raw.rds")


#### lets merge in country name and country code and remove
#### original "webname" in the raw data
heritage_df <- merge(heritage_df,
                     country_df[, c("name_web", "name_ISO3166_3")] |>
                       rename(country_code = "name_ISO3166_3"),
                     all.x = TRUE,
                     by = "name_web") |>
               mutate(country_code = case_when(
                 country_code == "KOS" ~ "XKX",
                 TRUE ~ country_code
               )) |>
               merge(wb_country_list[, c("country_code", "country_name")] |>
                       unique() |>
                       add_row(country_code = "XKX",
                               country_name = "Kosovo"),
                     by = "country_code") |>
               dplyr::select(-name_web) |>
               as_tibble()

dbvar_dt <- readxl::read_excel("data-raw/input/cliar/db_variables.xlsx")

#### change column names by just removing any spaces
colnames(heritage_df) <- gsub(pattern = " ",
                              replacement = "_",
                              x = colnames(heritage_df)) |>
                         tolower()

#### convert indicator columns to numeric and represent missing values as NA
#### and a few changes to match the naming conventions of the last year's data
heritage_df <-
  heritage_df |>
  mutate(across(
    .cols = where(~ any(. == "N/A", na.rm = TRUE)),
    .fns = ~ suppressWarnings(as.numeric(na_if(., "N/A")))
  ),
  year = year - 1) |>
  dplyr::select(country_code, year, business_freedom,
                financial_freedom, investment_freedom) |>
  rename_with(.cols = ends_with("_freedom"),
              .fn = ~ paste0("heritage_", .)) |>
  filter(year >= 2012)

heritage_df <-
  heritage_df |>
  add_plmetadata(source = urldata,
                 other_info = "")

heritage <- heritage_df

usethis::use_data(heritage, overwrite = TRUE)




