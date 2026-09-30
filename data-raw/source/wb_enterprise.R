#####################################################################
########## PULL FOR ENTERPRISE SURVEYS CONSTRAINT INDICATORS ########
#####################################################################

### pulling the enterprise surveys "major constraint" indicators from
### WB Data 360 (dataset WB_ES). Each concept below is queried using its
### "_T" (Total) series, i.e. the economy-wide aggregate across firm
### size, sector, and other breakdowns - matching the db_variables
### description for each variable (a single national percentage, not a
### sub-group estimate).

library(dplyr)
library(tidyr)

# map of db_variables `variable` name -> WB_ES Data 360 indicator id
es_indicator_map <- c(
  wb_es_ic_frm_corr_corr11 = "WB_ES_T_CORR11", # firms identifying corruption as a major constraint
  wb_es_ic_frm_corr_crime9 = "WB_ES_T_CRIME9",  # firms identifying the courts system as a major constraint
  wb_es_ic_frm_infra_in12  = "WB_ES_T_IN12",    # firms identifying electricity as a major constraint
  wb_es_ic_frm_obs_obst1   = "WB_ES_T_OBST1",   # firms identifying access to finance as a major constraint
  wb_es_ic_frm_reg_bus5    = "WB_ES_T_BUS5",    # firms identifying business licensing/permits as a major constraint
  wb_es_ic_frm_reg_reg5    = "WB_ES_T_REG5",    # firms identifying tax administration as a major constraint
  wb_es_ic_frm_trd_tr9     = "WB_ES_T_TR9",     # firms identifying customs/trade regulations as a major constraint
  wb_es_ic_frm_wrkf_wk9    = "WB_ES_T_WK9"      # firms identifying labor regulations as a major constraint
)

es_raw <- extract_data_from_api(dataset_id = "WB_ES",
                                source = "d360",
                                indicator_ids = unname(es_indicator_map))[[2]]

wb_enterprise <- es_raw |>
  # keep only the economy-wide total (drop sector/size/sex/age/urbanisation breakdowns)
  filter(
    COMP_BREAKDOWN_1 == "_T", COMP_BREAKDOWN_2 == "_T", COMP_BREAKDOWN_3 == "_T",
    SEX == "_T", AGE == "_T", URBANISATION == "_T"
  ) |>
  mutate(
    OBS_VALUE = as.numeric(OBS_VALUE),
    TIME_PERIOD = as.integer(as.numeric(TIME_PERIOD)),
    variable = names(es_indicator_map)[match(INDICATOR, es_indicator_map)]
  ) |>
  select(country_code = REF_AREA, year = TIME_PERIOD, variable, OBS_VALUE) |>
  distinct(country_code, year, variable, .keep_all = TRUE) |>
  pivot_wider(names_from = variable, values_from = OBS_VALUE)

### lets drop the countries that are not in wb_country_list
wb_enterprise <- 
  wb_enterprise |>
  dplyr::filter(!is.na(country_code) &
                country_code %in% unique(wb_country_list$country_code))

### add metadata
wb_enterprise <- 
  wb_enterprise |> 
  add_plmetadata(source = "WB Data 360 API Pulls", 
                 other_info = "Enterprise Surveys constraint indicators pulled on 9/26/2026")

### writing the lazyload

usethis::use_data(wb_enterprise, overwrite = TRUE)
