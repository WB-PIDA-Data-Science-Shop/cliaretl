#GFDB
# install.packages("readxl")
library(readxl)
library(dplyr)
library(tidyr)
library(janitor)
# URL

url <- "https://thedocs.worldbank.org/en/doc/5882f2b2117b882d58a78f9c64ea3613-0050062022/original/20220909-global-financial-development-database.xlsx"
# tf <- tempfile(fileext = ".xlsx")

dbvar_df <- read_excel("data-raw/input/cliar/db_variables.xlsx")

## pull the data
gfdbraw_path <- "data-raw/input/gfdb/gfdb_raw.xlsx"

download.file(url = url,
              destfile = gfdbraw_path,
              mode = "wb")



##  select relevant sheet
sheets <- excel_sheets(gfdbraw_path)

gfdb_df <- read_excel(gfdbraw_path,
                      sheet = "Data - August 2022",
                      skip = 0)

# reshape the gfdb_df into the long format to match last year's cliar input
gfdb_df <-
  gfdb_df %>%
  pivot_longer(
    cols = matches("^[a-z]{2}\\d{2}[a-z]?$"),
    names_to       = c("series", "item"),
    names_pattern  = "([a-z]{2})(\\d{2}[a-z]?)",
    values_to      = "value"
  )

#keep years between 2000 and 2021

gfdb_df <-
  gfdb_df |>
    filter(series %in% c("di", "oi"), item == "01") |>
    dplyr::select(iso3, year, series, item, value) |>
    unite("series_item", series, item, sep = "_") |>
    pivot_wider(names_from = series_item,
                values_from = value) |>
    rename_with(~ paste0("wb_gfdb_", .),
                .cols = -c(iso3, year)) |>
    filter(year >= 1990) |>
    rename(country_code = "iso3")

gfdb <- gfdb_df

rm(gfdb_df)

### add to the metadata pipeline
gfdb <-
gfdb |>
  add_plmetadata(source = url,
                 other_info = "")

usethis::use_data(gfdb, overwrite = TRUE)






