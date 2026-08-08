##############################################################
###### WORLD JUSTICE PROJECT RULE OF LAW INDEX DATA ##########
##############################################################

### lets pull the rule of law data from WJP website and
### clean it up a little since the subscores are not
### available in WB DATA 360 yet

library(here)
library(dplyr)
library(httr)
library(tidyr)

devtools::load_all()

url <- "https://worldjusticeproject.org/rule-of-law-index/downloads/2025_wjp_rule_of_law_index_HISTORICAL_DATA_FILE.xlsx"

dest_dir <- here("data-raw", "input", "wjp")
tmp_file <- file.path(dest_dir, "wjp_raw.xlsx")

resp <- GET(url, write_disk(tmp_file, overwrite = TRUE), progress())

## read the data in particularly the sheet called "Historical Data"
wjp_tbl <- readxl::read_excel(tmp_file, sheet = "Historical Data")

## check which variables we keep from db_variables_final
wjp_var_list <- 
db_variables_final |>
  filter(source == "World Justice Project, Rule of Law") |>
  pull(variable)

### the variables wjp_rol_7_1 and wjp_rol_8_2 appear to have been wrongly
### labelled in db_variables. In the actual data from WJP downloads, the 
### descriptions that match the variable names are wjp_rol_7 and wjp_rol_8
### I'll rename these in wjp_var_list so that we pull the correct thing
### also wjp_rol_6_6 is actually wjp_rol_6_5
wjp_var_list[wjp_var_list %in% c("wjp_rol_7_1", "wjp_rol_8_2", "wjp_rol_6_6")] <- 
  c("wjp_rol_7", "wjp_rol_8", "wjp_rol_6_5")

## lets convert the column names in wjp_tbl to match the wjp_rol_ format
## lets rename the variables with "Factor" in the name to be wjp_rol_*
## where this refers to the factor number in the current variable name

wjp_tbl <- 
wjp_tbl |>
  rename(country_code = "Country Code",
         year = "Year") |>
  rename_with(~ sub("^Factor (\\d+):.*", "wjp_rol_\\1", .x)) |>
  rename_with(~ sub("^(\\d+)\\.(\\d+)\\.?\\s.*", "wjp_rol_\\1_\\2", .x)) |> 
  dplyr::select(country_code, year, wjp_var_list) |>
  rename(wjp_rol_7_1 = "wjp_rol_7",
         wjp_rol_8_2 = "wjp_rol_8",
         wjp_rol_6_6 = "wjp_rol_6_5")

### duplicate the observations for the years for wjp is combined i.e. 2012-2013 
### and 2017-2018 

wjp_tbl <- 
  wjp_tbl |>
  separate_rows(year, sep = "-") |>
  mutate(year = as.integer(year))

wjp <- wjp_tbl

rm(wjp_tbl)

usethis::use_data(wjp, overwrite = TRUE)

