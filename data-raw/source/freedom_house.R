#####################################################################
############# PULL FOR FREEDOM HOUSE "FREEDOM IN THE WORLD" #########
#####################################################################

### pulling the Freedom House Freedom in the World (FIW) Political Rights
### and Civil Liberties ratings from WB Data 360 (dataset FH_FIW), instead
### of relying on the legacy pull baked into d360_efi_api.R. Confirmed
### 9/28/2026 that the Data360 API is already current -- it has the FIW
### 2026 edition (TIME_PERIOD 2026, LATEST_DATA = TRUE), two rounds ahead
### of what was previously pulled (which topped out at 2024). Ratings are
### left on Freedom House's native 1-7 scale (1 = most free, 7 = least
### free), matching what was already stored -- despite the legacy
### CLIAR_Metadata_Prod_D360.xlsx processing note ("8 - .x"), the values
### already in the package are on the raw 1-7 scale (e.g. USA scores 1-2),
### so no inversion is applied here.

library(dplyr)
library(tidyr)

# map of db_variables_final `variable` name -> FH_FIW Data 360 indicator id
fh_indicator_map <- c(
  fh_fiw_pr_rating = "FH_FIW_PR_RATING", # Political Rights (1-7, 1 = most free)
  fh_fiw_cl_rating = "FH_FIW_CL_RATING"  # Civil Liberties (1-7, 1 = most free)
)

fh_raw <- extract_data_from_api(dataset_id = "FH_FIW",
                                source = "d360",
                                indicator_ids = unname(fh_indicator_map))[[2]]

freedom_house <- fh_raw |>
  mutate(
    OBS_VALUE = as.numeric(OBS_VALUE),
    TIME_PERIOD = as.integer(as.numeric(TIME_PERIOD)),
    variable = names(fh_indicator_map)[match(INDICATOR, fh_indicator_map)]
  ) |>
  select(country_code = REF_AREA, year = TIME_PERIOD, variable, OBS_VALUE) |>
  distinct(country_code, year, variable, .keep_all = TRUE) |>
  pivot_wider(names_from = variable, values_from = OBS_VALUE)

### lets drop the countries that are not in wb_country_list
freedom_house <-
  freedom_house |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))

### add metadata
freedom_house <-
  freedom_house |>
  add_plmetadata(source = "WB Data 360 API Pulls (dataset FH_FIW)",
                 other_info = "Freedom House Freedom in the World ratings pulled on 9/28/2026")

### writing the lazyload

usethis::use_data(freedom_house, overwrite = TRUE)
