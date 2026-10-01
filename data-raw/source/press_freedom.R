#####################################################################
############# PULL FOR THE RSF WORLD PRESS FREEDOM INDEX ############
#####################################################################

### pulling the RSF (Reporters Without Borders) World Press Freedom Index
### directly from rsf.org's own per-year CSV exports, instead of relying
### on the legacy pull baked into d360_efi_api.R (EFI dataset RWB.PFI via
### datacatalogapi.worldbank.org, which is stuck at the 2023 edition --
### confirmed 9/28/2026 -- even though RSF has since published the 2024,
### 2025, and 2026 editions).
###
### rsf.org serves each year's index as a semicolon-delimited CSV at
### /sites/default/files/import_classement/<year>.csv, with a comma as
### the decimal separator. The file schema changed twice: 2002-2021 uses
### a "Score N" column (pre-2022 methodology); 2022-2024 uses a plain
### "Score" column (post-2022 methodology); 2025-2026 uses "Score <year>".
### The score column is matched by pattern rather than a fixed name to
### handle all three eras. RSF has no standalone 2011 file (404 at that
### URL) -- 2011 and 2012 were combined into a single edition, served
### today as "2012.csv" but internally still labelled "Year (N)" =
### "2011-12". The pre-existing pipeline stored this edition under year
### 2011 (confirmed: FIN score -10 under year 2011 in the legacy data,
### which matches this file's values exactly), so that file is remapped
### to year 2011 here too, instead of trusting its "Year (N)" field or
### introducing a new, previously-nonexistent "2012" data point. Every
### other year (2002-2026) was cross-checked against the existing
### d360_efi_data values (rwb_pfi_index) and matches exactly.

library(dplyr)
library(readr)
library(stringr)

dest_dir <- here::here("data-raw", "input", "press_freedom")

rsf_years <- c(2002:2010, 2012:2026)

pull_rsf_year <- function(yr) {
  url <- paste0("https://rsf.org/sites/default/files/import_classement/", yr, ".csv")
  tmp_file <- file.path(dest_dir, paste0("rsf_", yr, ".csv"))
  httr::GET(url, httr::write_disk(tmp_file, overwrite = TRUE))

  raw <- read_delim(tmp_file, delim = ";",
                    locale = locale(decimal_mark = ",", encoding = "UTF-8"),
                    show_col_types = FALSE)

  score_col <- names(raw)[str_detect(names(raw), "^Score( N| \\d{4})?$")]
  stopifnot("Could not identify a unique Score column" = length(score_col) == 1)

  ### the "2012" file is really the combined 2011-12 edition -- see note above
  out_year <- if (yr == 2012) 2011L else as.integer(yr)

  raw |>
    select(country_code = ISO, rwb_pfi_index = all_of(score_col)) |>
    mutate(year = out_year,
           rwb_pfi_index = as.numeric(rwb_pfi_index))
}

press_freedom <- purrr::map_dfr(rsf_years, pull_rsf_year)

### lets drop the countries that are not in wb_country_list
press_freedom <-
  press_freedom |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))

### add metadata
press_freedom <-
  press_freedom |>
  add_plmetadata(source = "https://rsf.org/en/index",
                 other_info = "RSF World Press Freedom Index, per-year CSV exports pulled directly on 9/28/2026")

### writing the lazyload

usethis::use_data(press_freedom, overwrite = TRUE)
