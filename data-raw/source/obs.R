#####################################################################
################## PULL FOR THE OPEN BUDGET SURVEY (OBS) ############
#####################################################################

### pulling the Open Budget Index (OBI) directly from IBP's own published
### long-format timeseries file, instead of relying on the legacy pull
### baked into d360_efi_api.R (dataset IBP_OBS via Data360, which is
### stuck at the OBS 2023 round -- confirmed 9/28/2026 that the Data360
### API and the World Bank's static xlsx mirror have not been updated
### with OBS 2025, even though IBP published the OBS 2025 global round
### (82 countries, 10th edition) this year).
###
### IBP's own interactive download page (internationalbudget.org/open-
### budget-survey/download) sits behind Cloudflare bot protection that
### blocks scripted GETs, but the underlying data files under
### /sites/default/files/ are plain static assets and are not blocked.

library(readxl)
library(dplyr)

dest_dir <- here::here("data-raw", "input", "obs")

url <- "https://internationalbudget.org/sites/default/files/2026-06/OBS_Full_Timeseries_2006_2025.xlsx"
tmp_file <- file.path(dest_dir, "obs_raw.xlsx")

## lets download the file and tell me the progress of the download
resp <- httr::GET(url, httr::write_disk(tmp_file, overwrite = TRUE), httr::progress())

### long-format sheet: all countries, all rounds (2006-2025). Header row
### is row 4 (rows 1-3 are a title, a footnote, and a blank spacer row)
obs_raw <- read_excel(tmp_file, sheet = "OBS_Data_AllYears", skip = 3)

obs <- obs_raw |>
  select(country_code = ISO, year = Year, ibp_obs_obi = `OBI (unrounded)`) |>
  filter(!is.na(country_code)) |>
  mutate(year = as.integer(year))

### lets drop the countries that are not in wb_country_list
obs <-
  obs |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))


### add metadata
obs <-
  obs |>
  add_plmetadata(source = url,
                 other_info = "OBS full timeseries (2006-2025), pulled directly from IBP on 9/28/2026")

### writing the lazyload

usethis::use_data(obs, overwrite = TRUE)
