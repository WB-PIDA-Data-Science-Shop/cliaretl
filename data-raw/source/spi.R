#####################################################################
########## PULL FOR STATISTICAL PERFORMANCE INDICATORS ##############
#####################################################################

### pulling the statistical performance indicators that currently 
### failing from WB Data 360

# spi_census_and_survey_index census and surveys
# Dimension 4.1: Censuses and Surveys - Surveys only
# spi_std_and_methods standards and methods

library(dplyr)

id_list <- c("SPI_DIM4_1_INDEX", "SPI_DIM5_2_INDEX")

## pull the standards and methods indicator first and then compute the average
stdmethods_tbl <- extract_data_from_api(dataset_id = "WB_SPI", 
                                        source = "d360", 
                                        indicator_ids = "SPI_DIM5_2_INDEX")[[2]] 

stdmethods_tbl <- 
  stdmethods_tbl |>
  mutate(OBS_VALUE = as.numeric(OBS_VALUE),
         TIME_PERIOD = as.integer(as.numeric(TIME_PERIOD))) |>
  group_by(REF_AREA, TIME_PERIOD) |>
  summarize(wb_spi_std_and_methods = mean(OBS_VALUE, na.rm = TRUE)) |>
  rename(country_code = "REF_AREA",
         year = "TIME_PERIOD")

census_and_survey_tbl <- extract_data_from_api(dataset_id = "WB_SPI", 
                                               source = "d360", 
                                               indicator_ids = "SPI_DIM4_1_INDEX")[[2]]

census_and_survey_tbl <- 
  census_and_survey_tbl |>
  mutate(OBS_VALUE = as.numeric(OBS_VALUE),
         TIME_PERIOD = as.integer(as.numeric(TIME_PERIOD))) |>
  group_by(REF_AREA, TIME_PERIOD) |>
  summarize(wb_spi_census_and_survey_index = mean(OBS_VALUE, na.rm = TRUE)) |>
  rename(country_code = "REF_AREA",
         year = "TIME_PERIOD")

spi <- full_join(stdmethods_tbl, census_and_survey_tbl, by = c("country_code", "year"))

### lets drop the countries that are not in wb_country_list
spi <- spi |> 
       dplyr::filter(!is.na(country_code) & 
       country_code %in% unique(wb_country_list$country_code))

### add metadata
spi <- spi |> add_plmetadata(source = "WB Data 360 API Pulls", other_info = "Pulled on 9/11/2026")

### writing the lazyload

usethis::use_data(spi, overwrite = TRUE)


