library(dplyr)
library(readxl)

### get the db_variables data
dbvar_df <-
  readxl::read_excel("data-raw/input/cliar/db_variables.xlsx") |>
  filter(source == "OECD")

### lets download the data via the API
url <- readLines("data-raw/input/epl/epl")

url <- paste0(url, "&format=csvfilewithlabels")

epl_df <- read.csv(url)

write.csv(epl_df, "data-raw/input/epl/epl_raw.csv")

### include country data

epl_regular <-
  epl_df |>
  filter(
      Version == "Version 4 (2013-2019)",
      Measure == "Individual and collective dismissals (regular contracts)"
  ) |>
  transmute(
    # the country code used by the OECD is equivalent to the WB
    country_code = REF_AREA,
    year = TIME_PERIOD,
    oecd_epl_regular = OBS_VALUE,
    version = Version,
    measure = Measure,
  )

epl_temporary <-
  epl_df |>
  filter(
    Version == "Version 4 (2013-2019)",
    Measure == "Temporary contracts"
  ) |>
  transmute(
    country_code = REF_AREA,
    year = as.numeric(TIME_PERIOD),
    oecd_epl_temporary = OBS_VALUE
  )

# note that there is higher coverage for regular vs. temporary contracts
epl_df <-
  epl_regular |>
  full_join(epl_temporary,
            by = c("country_code", "year")) |>
  filter(country_code %in% unique(wb_country_list$country_code))

epl <- epl_df

rm(epl_df)

epl <-
  epl |>
  add_plmetadata(source = url,
                 other_info = "CSV Data Pulled for OECD API")

## write data to data folder
usethis::use_data(epl, overwrite = TRUE)




