## code to prepare `debt_transparency` dataset goes here
# source: https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report
# access date: 7/27/2026
library(dplyr)
library(readr)
library(tidyr)
library(purrr)
library(countrycode)
library(janitor)
library(stringr)
library(here)

# Get all input files
input_files <- list.files(
  here("data-raw", "input", "debt_transparency"),
  pattern = "^debt_report.*\\.csv$",
  full.names = TRUE
)

message("\n=== Reading data files ===")

# Simple read function - just try different delimiters
read_file_flexible <- function(filepath, id = "dataset") {
  tryCatch(
    {
      # Check file size first
      file_size <- file.size(filepath)
      if (file_size < 100) {
        warning("Skipping tiny file (", file_size, " bytes): ", basename(filepath))
        return(NULL)
      }
      
      message("  Reading: ", basename(filepath))
      
      # Try comma first (2024 files)
      data <- tryCatch(
        read_delim(filepath, delim = ",", 
                  locale = locale(encoding = "UTF-8"),
                  id = id, show_col_types = FALSE),
        error = function(e) {
          # Try tab (2025 files)
          tryCatch(
            read_delim(filepath, delim = "\t",
                      locale = locale(encoding = "UTF-8"),
                      id = id, show_col_types = FALSE),
            error = function(e2) {
              # Try auto-detect
              read_delim(filepath, delim = NULL,
                        locale = locale(encoding = "UTF-8"),
                        id = id, show_col_types = FALSE)
            }
          )
        }
      )
      
      if (nrow(data) == 0) {
        warning("Empty file: ", basename(filepath))
        return(NULL)
      }
      
      message("    Loaded: ", nrow(data), " rows, ", 
              ncol(data), " columns")
      return(data)
    },
    error = function(e) {
      warning("FAIL - ", basename(filepath), ": ", e$message)
      return(NULL)
    }
  )
}

# Read all files
all_data <- input_files |>
  map(read_file_flexible, id = "dataset") |>
  discard(is.null) |>
  bind_rows() |>
  clean_names()

message("\n=== Combined data ===")
message("Total rows: ", nrow(all_data))
message("Years present: ", paste(sort(unique(
  gsub("^.*?([0-9]{4}).*$", "\\1", all_data$dataset)
)), collapse = ", "))

# Extract year and pivot to wide format
# IMPORTANT: We need to aggregate at the country-year level first to handle
# cases where multiple records exist for same country-year-indicator
debt_transparency_wide <- all_data |>
  mutate(
    year = gsub("^.*?([0-9]{4}).*$", "\\1", dataset),
  ) |>
  select(
    country,
    year,
    indicator,
    criteria
  ) |>
  filter(!is.na(country), !is.na(indicator), !is.na(criteria)) |>
  # First aggregate: get unique country-year-indicator combinations
  # (take first if duplicates exist)
  distinct(country, year, indicator, .keep_all = TRUE) |>
  pivot_wider(
    id_cols = c(country, year),
    names_from = "indicator",
    values_from = "criteria",
    values_fn = first
  ) |>
  clean_names()

message("\n=== After pivot (all years) ===")
message("Rows: ", nrow(debt_transparency_wide))
message("Years: ", paste(sort(unique(debt_transparency_wide$year)), collapse = ", "))
message("Columns: ", paste(names(debt_transparency_wide), collapse = ", "))

# Function to extract numeric from text like "4. Full" -> 4
# Handles vectors properly
extract_numeric <- function(x) {
  # Handle NA values
  result <- rep(NA_real_, length(x))
  
  # Find non-NA values
  non_na <- !is.na(x)
  
  # Extract first character and convert to numeric for non-NA values
  if (any(non_na)) {
    val <- substr(as.character(x[non_na]), 1, 1)
    result[non_na] <- suppressWarnings(as.numeric(val))
  }
  
  return(result)
}

# Create final dataset - convert all criteria columns to numeric
# Handle missing columns gracefully for years with incomplete data
debt_transparency <- debt_transparency_wide |>
  transmute(
    country = country,
    year = as.integer(year),
    debt_transp_data = if (exists("data_accessibility", where = cur_data())) 
      extract_numeric(data_accessibility) else NA_real_,
    debt_transp_instrument = if (exists("instrument_coverage", where = cur_data())) 
      extract_numeric(instrument_coverage) else NA_real_,
    debt_transp_sectorial = if (exists("sectorial_coverage", where = cur_data())) 
      extract_numeric(sectorial_coverage) else NA_real_,
    debt_transp_information = coalesce(
      if (exists("information_on_recent_contracted_loans", where = cur_data())) 
        extract_numeric(information_on_recent_contracted_loans) else NA_real_,
      if (exists("information_on_recently_contracted_external_loans", where = cur_data())) 
        extract_numeric(information_on_recently_contracted_external_loans) else NA_real_
    ),
    debt_transp_periodicity = if (exists("periodicity", where = cur_data())) 
      extract_numeric(periodicity) else NA_real_,
    debt_transp_time = coalesce(
      if (exists("time_range", where = cur_data())) 
        extract_numeric(time_range) else NA_real_,
      if (exists("time_lag", where = cur_data())) 
        extract_numeric(time_lag) else NA_real_
    ),
    debt_transp_dms = coalesce(
      if (exists("debt_management_strategy", where = cur_data())) 
        extract_numeric(debt_management_strategy) else NA_real_,
      if (exists("debt_management_strategy_dms", where = cur_data())) 
        extract_numeric(debt_management_strategy_dms) else NA_real_
    ),
    debt_transp_abp = coalesce(
      if (exists("annual_borrowing_plan", where = cur_data())) 
        extract_numeric(annual_borrowing_plan) else NA_real_,
      if (exists("annual_borrowing_plan_abp", where = cur_data())) 
        extract_numeric(annual_borrowing_plan_abp) else NA_real_
    ),
    debt_transp_addition = coalesce(
      if (exists("other_debt_statistics_contingent_liabilities_c_ls", where = cur_data())) 
        extract_numeric(other_debt_statistics_contingent_liabilities_c_ls) else NA_real_,
      if (exists("additional_statistics_memo_items", where = cur_data())) 
        extract_numeric(additional_statistics_memo_items) else NA_real_
    )
  )

message("\n=== Final dataset ===")
message("Dimensions: ", nrow(debt_transparency), " rows x ", ncol(debt_transparency), " columns")
message("Years: ", paste(sort(unique(debt_transparency$year)), collapse = ", "))
message("Countries: ", n_distinct(debt_transparency$country), " unique")

# Summary by year
message("\n=== Records by year ===")
print(debt_transparency |> count(year))

message("\n=== First 10 rows ===")
print(head(debt_transparency, 10))

# correct country names
debt_transparency <- debt_transparency %>%
  mutate(
    country = case_when(
      country == "Cabo Verde" ~ "Cape Verde",
      country == "Côte d'Ivoire" ~ "Ivory Coast",
      country == "São Tomé and Príncipe" ~ "Sao Tome and Principe",
      country == "São Tomé and Principe" ~ "Sao Tome and Principe",
      TRUE ~ country
    )
  )

debt_transparency <- debt_transparency %>%
  mutate(
    country_code = countrycode(country, origin = "country.name", destination = "iso3c")
  )

debt_transparency <- debt_transparency %>%
  mutate(
    country_code = ifelse(country == "Kosovo", "XKX", country_code)
  )

debt_transparency <- debt_transparency %>% 
  select(country_code, year, everything())

debt_transparency <-
  debt_transparency %>%
  mutate(
    debt_transp_index = rowMeans(
      across(starts_with("debt_transp")),
      na.rm = TRUE
    ) |>
      round(2)
  ) |>
  clean_names() |>
  rename_with(
    # add prefixes with cliar conventions
    ~ paste0("wb_", .),
    .cols = starts_with("debt")
  ) |>
  dplyr::select(country_code, year, wb_debt_transp_index)

debt_transparency <-
debt_transparency |>
  add_plmetadata(source = "https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report",
                 other_info = "2026 extraction date: 7/27/2026.")

usethis::use_data(debt_transparency, overwrite = TRUE)
