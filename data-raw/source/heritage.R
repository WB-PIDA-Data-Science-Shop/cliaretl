################################################################################
########## DOWNLOAD AND PROCESS HERITAGE'S INDEX OF FREEDOM DATA #############
################################################################################

library(readr)
library(dplyr)
library(httr)
library(countrycode)

#### The site moved from www.heritage.org/index/... to
#### economicfreedom.heritage.org/... at some point, and the new domain
#### sits behind Cloudflare bot-protection that blocks a plain GET with no
#### headers (returns a 403 challenge page). Confirmed by pulling the
#### page's own ef-all-scores-page.js, which shows these are still the
#### exact same files the live table itself fetches via d3.csv() --
#### just relocated, not replaced.

heritage_headers <- add_headers(
  `User-Agent`      = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  `Accept`          = "text/csv,*/*",
  `Referer`         = "https://economicfreedom.heritage.org/pages/all-country-scores.html",
  `Accept-Language` = "en-US,en;q=0.9"
)

#### reading the data directly from the internet

urldata <- "https://economicfreedom.heritage.org/assets/data/csv/ef-country-scores.csv"
res_data <- GET(urldata, heritage_headers)
stopifnot(status_code(res_data) == 200)
heritage_df <- read_csv(content(res_data, "text", encoding = "UTF-8"))

urlcountry <- "https://economicfreedom.heritage.org/assets/data/csv/ef-country-names.csv"
res_country <- GET(urlcountry, heritage_headers)
stopifnot(status_code(res_country) == 200)
country_df <- read_csv(content(res_country, "text", encoding = "UTF-8"))

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
#### (note: the new site's CSV already uses "." instead of spaces in some
#### column names once read by read_csv/read.csv's default name repair --
#### confirm colnames(heritage_df) match what this gsub expects before
#### relying on it; adjust the pattern to "\\." if needed)
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

### lets ensure we only have wb country iso3 codes
heritage_df <- 
heritage_df |> 
  dplyr::filter(!is.na(country_code) & country_code %in% unique(wb_country_list$country_code))

heritage_df <-
  heritage_df |>
  add_plmetadata(source = urldata,
                 other_info = "")

heritage <- heritage_df

rm(heritage_df) ## drop the heritage_df

usethis::use_data(heritage, overwrite = TRUE)