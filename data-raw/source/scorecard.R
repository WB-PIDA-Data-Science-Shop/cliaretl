###################################################################################
############### INCLUDE SCORECARD INDICATORS FROM THE OUTCOMES TEAM ###############
###################################################################################
library(dplyr)

### prepare the scorecard indicators dataset for the analytics

cscvars_tbl <- readxl::read_excel("data-raw/input/csc/csc_variables.xlsx")

csc_tbl <- 
  mapply(FUN = get_data360_api,
         dataset_id = cscvars_tbl$wb_dataset_id,
         indicator_id = cscvars_tbl$wb_indicator_id,
         SIMPLIFY = FALSE) |>
  Reduce(f = full_join) |>
  ### the API returns missing values as the string "null"
  mutate(across(
    .cols = !c("country_code", "year"),
    .fns = \(x) as.numeric(na_if(x, "null"))))

### the following code below should contain no duplicates
lapply(X = colnames(csc_tbl)[!colnames(csc_tbl) %in% c("country_code", "year")],
       FUN = function(x) {
         csc_tbl |>
           dplyr::summarize(n = dplyr::n(),
                            .by = c(country_code, year, !!sym(x))) |>
           dplyr::filter(n > 1L)
       })

scorecard <- csc_tbl |> 
  mutate(
    year = as.numeric(year)
  )

## lets make sure to only keep the countries in the wb_country_list

scorecard <- 
  scorecard |>
  dplyr::filter(country_code %in% unique(wb_country_list$country_code)) |>
  dplyr::filter(!is.na(country_code)) |>
  # we only retain the latest year, following the same convention
  # for the log gdp per capita
  dplyr::filter(
    year == 2024
  )


scorecard <- 
  scorecard |>
  add_plmetadata(source = "WB Data 360 API Pulls",
                 other_info = "Repulled from API on 9/11/2026")

usethis::use_data(scorecard, overwrite = TRUE)