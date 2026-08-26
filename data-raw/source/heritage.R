################################################################################
########## DOWNLOAD AND PROCESS HERITAGE'S INDEX OF FREEDOM DATA ###############
################################################################################

# Isntructions to manually download the panel data from Heritage's website:
# step 1. Go to the following URL in your browser: https://economicfreedom.heritage.org/pages/all-country-scores
# step 2. Click all box btoh for the years and country filter. then click "Filter Data" button 
# step 3. Click the "Download Filtered Data" button and select "CSV" to download the data and rename it to "heritage_iof_raw.csv"

library(readr)
library(dplyr)
library(countrycode)


# 1. Read the data and skip 4 rows of metadata at the top
heritage_raw <- read.csv(
  "data-raw/input/heritage/heritage_iof_raw.csv", 
  skip = 4, 
  stringsAsFactors = FALSE
)

# 2. Add standardized country code and country name using countrycode
heritage_df <- heritage_raw |>
  mutate(
    # Generate ISO3c code (handles Kosovo mapping to XKX)
    country_code = countrycode(
      sourcevar = Country,
      origin = "country.name",
      destination = "iso3c",
      custom_match = c("Kosovo" = "XKX")
    ),
    # Generate standardized country name
    country_name = countrycode(
      sourcevar = country_code,
      origin = "iso3c",
      destination = "country.name",
      custom_match = c("XKX" = "Kosovo")
    )
  ) |>
  # Remove the original raw country name column ("webname" equivalent)
  dplyr::select(-Country)

dbvar_dt <- readxl::read_excel("data-raw/input/cliar/db_variables.xlsx")

# 3. Change column names by replacing spaces/dots with underscores and converting to lowercase
colnames(heritage_df) <- colnames(heritage_df) |>
  gsub(pattern = "[ .]+", replacement = "_") |>
  tolower()

# 4. Convert indicator columns to numeric (handling "N/A"),
#    adjust year (-1 offset), select/rename key variables, and filter.
heritage_df <- heritage_df |>
  # Rename index_year to year before transforming
  rename(year = index_year) |>
  mutate(
    # Convert character columns containing "N/A" into proper numeric NAs
    across(
      .cols = where(~ is.character(.) && any(. == "N/A", na.rm = TRUE)),
      .fns = ~ suppressWarnings(as.numeric(na_if(., "N/A")))
    ),
    year = year - 1
  ) |>
  dplyr::select(
    country_code, 
    country_name,
    year, 
    business_freedom,
    financial_freedom, 
    investment_freedom
  ) |>
  rename_with(
    .cols = ends_with("_freedom"),
    .fn = ~ paste0("heritage_", .)
  ) |>
  filter(year >= 2012) |> 
  select(-country_name)  # Remove country_name column as it's redundant with country_code)

heritage <-
  heritage_df |>
  add_plmetadata(source = urldata,
                 other_info = " 2026 extraction date: 8/7/2026. Script was fully refactored")

# Export the processed data to the package's data directory

usethis::use_data(heritage, overwrite = TRUE)




