## code to prepare `fraser_data` dataset goes here
# Manual download instructions:
#
# 1. Go to the following URL in your browser:
#    https://efotw.org/economic-freedom/dataset?geozone=world&page=dataset&min-year=2&max-year=0&filter=0
# 2. Make sure you are on the "Dataset" tab (top-right corner) and
#    that "World" is selected in the top-left dropdown menu.
# 3. Click the green "Download Entire Dataset" button.
#    This will download the Excel file named:
#    `efotw-2024-master-index-data-for-researchers-iso.xlsx`
# 4. # Locate the file in your Downloads folder and move it to:
#   `.../cliaretl/data-raw/input/fraser/`

### access date: 7/30/2025

library(janitor)
library(dplyr)
library(here)
library(countrycode)
library(readxl)
library(stringr)

devtools::load_all()

# read-in -----------------------------------------------------------------

fraser_df <- read_xlsx(
  here("data-raw", "input", "fraser", "efotw-2024-master-index-data-for-researchers-iso.xlsx"),
  skip = 4
) |>
  clean_names() |>
  as_tibble()

# process -----------------------------------------------------------------
# Define the columns to convert to double type
double_columns <- c(
    "year",
    "freedom_to_own_foreign_currency_bank_accounts",
    "freedom_of_foreigners_to_visit",
    "capital_controls",
    "credit_market_regulations"
  )


fraser_clean <- fraser_df |>
  transmute(
    country_code = iso_code_3,
    across(all_of(double_columns), as.double)
  ) |>
  rename_with(
      # add prefixes with cliar conventions
      ~ paste0("fraser_efw_", .),
      .cols = c(3:6)
  )

fraser <- fraser_clean |>
  rename(
   fraser_efw_foreign_currency_bank_accounts =  fraser_efw_freedom_to_own_foreign_currency_bank_accounts,
   fraser_efw_credit_market_regulation = fraser_efw_credit_market_regulations
  )


fraser |>
  add_plmetadata(source = "https://efotw.org/economic-freedom/dataset?geozone=world&page=dataset&min-year=2&max-year=0&filter=0",
                 other_info = "Manually downloaded")


# write-out ---------------------------------------------------------------
usethis::use_data(fraser, overwrite = TRUE)

