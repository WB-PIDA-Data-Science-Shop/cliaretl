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
  mutate(across(
    .cols = !c("country_code", "year"), 
    .fns = as.numeric))


### the following code below should contain no duplicates
lapply(X = colnames(csc_tbl)[!colnames(csc_tbl) %in% c("country_code", "year")],
       FUN = function(x) {
         csc_tbl |>
           dplyr::summarize(n = dplyr::n(),
                            .by = c(country_code, year, !!sym(x))) |>
           dplyr::filter(n > 1L)
       })

csc <- csc_tbl 

rm(csc_tbl)


usethis::use_data(csc, overwrite = TRUE)