## code to prepare `country_list` dataset goes here
library(readxl)
library(here)
library(dplyr)
library(readr)
library(stringr)


# read-in -----------------------------------------------------------------
# read in world bank standard country codes and mutate them to be compatible
# with the other files
wb_country_list_temp <- tempfile(fileext = ".xlsx")

# Download the file
download.file(
  "https://datacatalogapi.worldbank.org/ddhxext/ResourceDownload?resource_unique_id=DR0090755",
  destfile = wb_country_list_temp,
  mode = "wb"
  )

wb_country_list <- read_xlsx(
  wb_country_list_temp,
  sheet = "compositions"
) %>%
  transmute(
    country_code = WB_Country_Code,
    country_name = WB_Country_Name,
    group = WB_Group_Name,
    group_code = WB_Group_Code
  ) |>
  # exclude non-WB member countries
  filter(
    country_code != "CUB" &
      country_code != "PRK"
  )

# country income group and region
wb_country_income_and_region <- read_xlsx(
  wb_country_list_temp,
  sheet = "List of economies"
) |>
  transmute(
    country_code = Code,
    country_name = Economy,
    region = Region,
    income_group = `Income group`
  ) |>
  # exclude non-WB member countries
  filter(
    country_code != "CUB" &
      country_code != "PRK"
  )

wb_country_list_original <- read_rds(
  here("data-raw", "input", "wb", "wb_country_list.rds")
)

# process -----------------------------------------------------------------
# note that North America is not included in this list
wb_regions <- c(
  "Africa Eastern and Southern",
  "Africa Western and Central",
  "East Asia & Pacific",
  "Europe & Central Asia",
  "Latin America & Caribbean",
  "Middle East & North Africa",
  "South Asia"
)

wb_country_groups_economic <- tibble(
  group_name = c("European Union", "OECD members"),
  group_category = "Economic"
)

wb_country_groups_income <- wb_country_list |>
  filter(
    str_detect(group, "income$")
  ) |>
  distinct(group) |>
  transmute(
    group_name = group,
    group_category = "Income"
  ) |>
  arrange(
    group_name
  )

wb_country_groups_region <- tibble(
    group_name = c(wb_regions, "North America"),
    group_category = "Region"
  ) |>
  add_row(
    group_name = c("Arab World", "Central Europe and the Baltics"),
    group_category = "Region"
  ) |>
  arrange(
    group_name
  )

wb_country_groups <- bind_rows(
  wb_country_groups_economic,
  wb_country_groups_income,
  wb_country_groups_region
)

wb_country_list <- wb_country_list |>
  inner_join(
    wb_country_groups |> select(group = group_name),
    by = "group"
  )

# these are the countries that have had their income classification modified
wb_country_list |>
  distinct(country_code, group) |>
  anti_join(
    wb_country_list_original |> distinct(country_code, group_name) |> rename(group = group_name)
  )

# write-out ---------------------------------------------------------------
usethis::use_data(wb_country_list, overwrite = TRUE)
usethis::use_data(wb_country_groups, overwrite = TRUE)
