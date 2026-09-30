################################################################################
########## DOWNLOAD AND PROCESS IDEA GLOBAL STATE OF DEMOCRACY (GSOD) DATA ###
################################################################################

### these "v_XX_YY" coded indicators were previously pulled through the World
### Bank EFI Data Catalog (dataset "IDEA.GSOD"); that dataset is not indexed on
### the newer, unified Data 360 platform (confirmed against data360api's own
### indicator search), so we pull International IDEA's own bulk release
### instead. Values were cross-checked against the old EFI pull (e.g. USA/CUB
### 1975 v_21_05) and match exactly.

library(readr)
library(dplyr)
library(stringr)
library(httr)

gsod_url <- paste0(
  "https://www.idea.int/democracytracker/idea-mod/download-proxy?url=",
  "https%3A%2F%2Fwww.idea.int%2Fsites%2Fdefault%2Ffiles%2F2026-06%2Fgsod_indices_v10.csv"
)

res <- GET(gsod_url)
stopifnot(status_code(res) == 200)
gsod_raw <- read_csv(content(res, "text", encoding = "UTF-8"), show_col_types = FALSE)

### keep only the gsod variables that are lazyloaded in db_variables, and map
### them back to their raw GSOD indicator codes (e.g. "idea_gsod_v_21_05" -> "v_21_05")
gsod_vars <- db_variables |>
  filter(str_starts(variable, "idea_gsod")) |>
  pull(variable) |>
  str_remove("^idea_gsod_")

gsod <- gsod_raw |>
  transmute(
    country_code = iso3c,
    year = as.integer(year),
    across(all_of(gsod_vars), as.numeric)
  ) |>
  rename_with(.cols = all_of(gsod_vars), .fn = ~ paste0("idea_gsod_", .))

### lets drop the countries that are not in wb_country_list
gsod <- gsod |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))

### add metadata
gsod <- gsod |>
  add_plmetadata(source = "International IDEA, Global State of Democracy (GSoD) Indices, v10 (2026)",
                 other_info = "Pulled directly from idea.int (Data 360 does not yet index this dataset) on 9/26/2026")

### keep only data from after 1990
gsod <-
  gsod |>
  filter(year >= 1990)

### writing the lazyload

usethis::use_data(gsod, overwrite = TRUE)
