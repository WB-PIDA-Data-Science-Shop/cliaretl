################################################################################
#### READING, CLEANING AND INCORPORATING THE ROMELlI DATA INTO THE PIPELINE ####
################################################################################

library(httr)
library(readxl)
library(dplyr)
library(janitor)


### download the data from site and write to file
GET(url = "https://cbidata.org/dataset/CBIData_Romelli_2025.xlsx",
    write_disk("data-raw/input/romelli/CBIData_Romelli_2025.xlsx",
               overwrite = TRUE))


### read in the data
romelli_tbl <-
readxl::read_excel("data-raw/input/romelli/CBIData_Romelli_2025.xlsx",
                   sheet = 2) |>
  clean_names()

### applying the 03_process_data modifications to the romelli_tbl data

# romelli - central bank independence
# The romelli data is cleaned by setting the country code variable name
# and casting the year variable to numeric
romelli_tbl <-
  romelli_tbl |>
  transmute(country_code = iso_a3,
            year = as.numeric(year),
            romelli_cbi_central_bank_independence = cbie_cwn_lvau)

dbvar_dt <- read_excel("data-raw/input/cliar/db_variables.xlsx")

romelli <- romelli_tbl

usethis::use_data(romelli, overwrite = TRUE)










