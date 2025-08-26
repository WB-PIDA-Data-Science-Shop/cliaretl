## code to prepare `wbl_data` dataset goes here
# Manual download instructions:
#
# 1. Go to the following URL in your browser:
#    https://wbl.worldbank.org/en/wbl-data
# 2. Make sure you csroll down to the the "Women, Business and the Law 1.0 Data for 1971-2024" section.
# 3. Click the Stata link,this will download the Dta file named:
#    `WBL1-0-1971-2024.dta`
# 4. # Locate the file in your Downloads folder and move it to:
#   `.../cliaretl/data-raw/input/wbl/`

### access date: 8/13/2025
library(here)
library(haven)
library(dplyr)
library(stringr)
library(readxl)
library(janitor)



# Load data ---------------------------------------------------------------

# reading the data directly from the internet
urldata <- "https://wbl.worldbank.org/content/dam/sites/wbl/documents/2024/WBL1-0-1971-2024.dta"
wbl_raw_df <- read_dta(urldata) |>
  clean_names()


wbl_raw_df |>
  add_plmetadata(source = urldata,
                 other_info = "WBL Data") |>
  saveRDS("data-raw/input/wbl/wbl_raw.rds")

wbl_df <- readRDS("data-raw/input/wbl/wbl_raw.rds")


# process -----------------------------------------------------------------

# Clean up variable names
wbl_df <- wbl_df |>
  filter(year >= 1990) |>
  # Drop variables
  select(-economycode, -region, -incomegroup, -reportyr, -economy) |>
  rename(country_code = is_ocode) |>
  arrange(country_code, year)


# Select relevant variables
wbl_df_filter <- wbl_df |>
  filter(year >= 1990) |>
  select(
    country_code,
    year,
    gr6_entrprnshp,
    matches("^gr2_|^gr3_|^gr7_|^gr1_|^gr4_|^gr5_")
  )

# Rename extra indicators that won't be used
wbl_df_clean <- wbl_df_filter |>
  select(
    -gr5_19govleaveprov,
    -gr5_20patleave,
    -gr5_21paidprntl
  )

# WBL ENTREPRENEURSHIP (business indicators on entrepreneurship)
wbl_rename <- wbl_df_clean |>
  mutate(
    wb_wbl_entrepreneurship = gr6_entrprnshp
  )

# WBL LABOR: workplace, pay, parental leave, dismissal of pregnant
wbl_labor <- wbl_rename %>%
  mutate(
    wb_wbl_labor = rowMeans(
      across(matches("^gr2_|^gr3_|^gr7_") |
               c(gr5_18wpdleave14, gr5_22pregdism)),
      na.rm = TRUE
    ) * 100
  )


# WBL SOCIAL: mobility, marriage, assets
wbl_clean <- wbl_labor |>
  mutate(
    wb_wbl_social = rowMeans(
      across(matches("^gr1_|^gr4_|^gr7_")),
      na.rm = TRUE
    ) * 100
  )

# Keep only required variables
wbl_data <- wbl_clean |>
  select(country_code, year, wb_wbl_entrepreneurship, wb_wbl_social, wb_wbl_labor)

# Add metadata
wbl_data <- wbl_data |>
  add_plmetadata(source = "https://wbl.worldbank.org/content/dam/sites/wbl/documents/2024/WBL1-0-1971-2024.dta",
                 other_info = "WBL Data")


# export data -----------------------------------------------------
usethis::use_data(wbl_data, overwrite = TRUE)

