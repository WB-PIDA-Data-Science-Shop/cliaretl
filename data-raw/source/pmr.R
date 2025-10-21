################################################################################
########### INCLUDING OECD PMR DATABASE INTO THE CLIAR PIPELINE ################
################################################################################

library(dplyr)
library(janitor)
library(haven)
library(rsdmx)

### read in the db variables data
dbvar_dt <-
  readxl::read_excel("data-raw/input/cliar/db_variables.xlsx") |>
  filter(source == "OECD Product Market Regulation Database")


pmr_df <-
  rsdmx::readSDMX(read.table("data-raw/input/pmr/url.txt")[[1]]) |>
  as_tibble()

### lets prepare the data we need
pmr_df <-
  pmr_df |>
  pivot_wider(names_from = MEASURE,
              values_from = obsValue) |>
  mutate(oecd_pmr_2018_6 = rowMeans(across(c(TARIFFS, FDI_INDEX)), na.rm = TRUE),
         oecd_pmr_2018_1_3 = PUBLIC_OWNER * 6 / GOVERNANCE,
         TIME_PERIOD = as.integer(TIME_PERIOD)) |>
  rename(oecd_pmr_2018_2_2_1 = "INV_BUS_NET",
         oecd_pmr_2018_2_2_2 = "INV_BUS_SER",
         oecd_pmr_2018_1_4 = "GOVERNANCE",
         oecd_pmr_2018_2_1 = "PRICE",
         oecd_pmr_2018_3_3 = "COMMANDSIMPLIF_BURDEN",
         country_code = "REF_AREA",
         year = "TIME_PERIOD") |>
  dplyr::select(year, country_code, starts_with("oecd_pmr_"))


pmr_df <-
  pmr_df |>
  add_plmetadata(source = "https://www.oecd.org/en/topics/sub-issues/product-market-regulation.html",
                 other_info = "Pulled from the OECD API url stored in textfile")

pmr <- pmr_df

rm(pmr_df)

usethis::use_data(pmr, overwrite = TRUE)

