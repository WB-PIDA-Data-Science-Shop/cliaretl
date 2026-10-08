#####################################################################
######### PULL FOR BERTELSMANN SUSTAINABLE GOVERNANCE INDICATORS ####
#####################################################################

### pulling the Sustainable Governance Indicators (SGI) from WB Data 360
### (dataset BS_SGI) directly, instead of relying on the legacy pull baked
### into d360_efi_api.R.
###
### NOTE ON bs_sgi_196: confirmed 9/28/2026 that Data360 has no 2024 data
### for BS_SGI_196 ("Audit Office") -- it stops at 2022, same as what was
### already stored. This isn't a pull bug: bs_sgi_195 ("Independent
### Supervisory Bodies") DOES have 2024 data (30 of 41 countries) under
### the same indicator ID, so the two aren't tracking together. SGI's
### 2024 edition was a methodology overhaul (per Bertelsmann's own 2024
### codebook), and it's likely "Audit Office" was renumbered or folded
### into a different indicator rather than actually discontinued -- but
### which of the ~190 other BS_SGI_* codes it became, if any, isn't
### resolvable from the Data360 API alone (it exposes indicator IDs but
### not labels/descriptions). Pulling this one as-is for now; identifying
### a 2024-vintage successor for bs_sgi_196 needs the SGI 2024 codebook.

library(dplyr)
library(tidyr)

# map of db_variables_final `variable` name -> BS_SGI Data 360 indicator id
sgi_indicator_map <- c(
  bs_sgi_195 = "BS_SGI_195", # Independent Supervisory Bodies (audit/ombuds/data protection offices)
  bs_sgi_196 = "BS_SGI_196"  # Audit Office (independent and effective)
)

sgi_raw <- extract_data_from_api(dataset_id = "BS_SGI",
                                 source = "d360",
                                 indicator_ids = unname(sgi_indicator_map))[[2]]

sgi <- sgi_raw |>
  mutate(
    OBS_VALUE = as.numeric(OBS_VALUE),
    TIME_PERIOD = as.integer(as.numeric(TIME_PERIOD)),
    variable = names(sgi_indicator_map)[match(INDICATOR, sgi_indicator_map)]
  ) |>
  select(country_code = REF_AREA, year = TIME_PERIOD, variable, OBS_VALUE) |>
  distinct(country_code, year, variable, .keep_all = TRUE) |>
  pivot_wider(names_from = variable, values_from = OBS_VALUE)

### lets drop the countries that are not in wb_country_list
sgi <-
  sgi |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))

### add metadata
sgi <-
  sgi |>
  add_plmetadata(source = "WB Data 360 API Pulls (dataset BS_SGI)",
                 other_info = "Sustainable Governance Indicators pulled on 9/28/2026. bs_sgi_196 still caps at 2022 in the source -- see note above.")

### writing the lazyload

usethis::use_data(sgi, overwrite = TRUE)
