library(here)
library(haven)
library(dplyr)
library(stringr)
library(readxl)
library(janitor)


# Load data ---------------------------------------------------------------
wbl_legacy_df <- read_dta(
  here("data-raw", "input", "WBL1971-2023.dta")
) |>
  clean_names()

meta_wbl <- read_excel(
  here("data-raw", "input", "wbl_meta_d360API.xlsx")
)


# process -----------------------------------------------------------------


# Extract variable labels
var_labels <- sapply(wbl_legacy_df, attr, "label")

# Clean up variable names
wbl_df <- wbl_legacy_df |>
  filter(year >= 1990) |>
  # Drop variables
  select(-economycode, -region, -incomegroup, -reportyr) |>
  rename(country_code = is_ocode) |>
  arrange(country_code, year)

# Select relevant variables
wbl_df_filter <- wbl_df |>
  select(
    country_code,
    year,
    wbl_index,
    gr6_entrprnshp,
    matches("^gr2_|^gr3_|^gr7_|^gr1_|^gr4_|^gr5_")
  )

# Rename extra indicators that won't be used
wbl_df_filter <- wbl_df_filter |>
  select(
    -gr5_19govleaveprov,
    -gr5_20patleave,
    -gr5_21paidprntl
  )

# Create a tibble with variable labels
label_df <- tibble(
  variable = names(var_labels),
  full_name   = unname(var_labels)
)

# Get the colnames from your filtered df
cols_in_filtered <- colnames(wbl_df_filter)

# Match only those columns
matched_labels <- label_df |>
  filter(variable %in% cols_in_filtered)



