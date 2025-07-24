################################################################################
########### INCLUDING OECD PMR DATABASE INTO THE CLIAR PIPELINE ################
################################################################################

library(dplyr)
library(janitor)
library(haven)

### read in the db variables data
dbvar_dt <-
  readxl::read_excel("data-raw/input/cliar/db_variables.xlsx") |>
  filter(source == "OECD Product Market Regulation Database")


pmr_df <- haven::read_dta("data-raw/input/pmr/PMR_2018.dta")

pmr_df <-
  pmr_df |>
  select(
    country_code,
    year,
    PMR_2018_3_3,
    PMR_2018_1_3,
    PMR_2018_6,
    PMR_2018_1_4,
    PMR_2018_1_2,
    PMR_2018_2_1,
    PMR_2018_1_1,
    PMR_2018_2_2
  ) |>
  clean_names() |>
  rename_with(
    # replace prefixes with efi conventions
    ~ paste0("oecd_", .),
    .cols = starts_with("pmr")
  )


pmr_df <-
  pmr_df |>
  add_plmetadata(source = "",
                 other_info = "")

pmr <- pmr_df

rm(pmr_df)

usethis::use_data(pmr, overwrite = TRUE)

