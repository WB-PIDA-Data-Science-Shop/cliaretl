######################################################
##  epl_temporary.xlsx
##  Source: OECD
##  path: G:\data\cliar\input\oecd\oecd_2025

####################################################

library(dplyr)
install.packages("readxl")
library(readxl)

# import xls:

epl_temp <- readxl::read_excel("G:/data/cliar/input/oecd/oecd_2025/epl_temporary.xlsx")

View(epl_temp)

# Keep Country, Year, country_code, Value

head(epl_temp)


## Keep only country country year Value

epl_selected <- epl_temp %>%
  select(Country, country_code, Year, Value)


dbvar_epl_tem <- readxl::read_excel("data-raw/input/cliar/db_variables.xlsx")

## pull the data
eplraw_path <- "data-raw/input/epl_tem/epl_temp_raw.xlsx"

## oecd_epl

oecd_epl_temp <- epl_selected

rm(epl_selected)

### add to the metadata pipeline

oecd_epl_temp <-
  oecd_epl_temp |>
  add_plmetadata(source = source,
                 other_info = "")

usethis::use_data(oecd_epl_temp, overwrite = TRUE)

                     ##THE END##


