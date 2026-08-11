#########################################################################################
####################### COMPUTE THE COVERAGE FOR ALL LAZYLOADS ##########################
#########################################################################################

##### a quick script to compute the coverage for all lazyloads i.e. how many countries 
##### and years of data we have in each dataset


### get the lazyload list
newpipeline_list <- list(aspire = aspire,
                         d360_efi_data = d360_efi_data,
                         debt_transparency = debt_transparency,
                         epl = epl,
                         fraser = fraser,
                         gfdb = gfdb,
                         heritage = heritage,
                         pefa_assessments = pefa_assessments,
                         pmr = pmr,
                         romelli = romelli,
                         vdem_data = vdem_data,
                         wdi_indicators = wdi_indicators,
                         labor_income = labor_income[, c("country_code", "year", "labor_income")],
                         scorecard = scorecard)

## get the list of benchmarked variables
benchmark_list <- db_variables_final |>
                  dplyr::filter(benchmarked_ctf == "Yes") |>
                  dplyr::pull(variable)



coverage_dt <-
  purrr::imap(newpipeline_list,
              function(x, name){

                keep_cols <- intersect(benchmark_list, colnames(x))

                ## skip datasets that have no benchmarked variables
                if (length(keep_cols) == 0) {
                  return(NULL)
                }

                x <- x |>
                  dplyr::select(country_code, year, dplyr::all_of(keep_cols))

                y <- compute_coverage2(data = x,
                                       country_id = country_code,
                                       year_id = year,
                                       dataset_name = name,
                                       ref_year = 2025,
                                       country_region_list = wb_income_and_region)

                return(y)

              }) |> dplyr::bind_rows()

# lets merge in the clusters from db_variables
coverage_dt <- 
  coverage_dt |>
  dplyr::left_join(db_variables_final |> 
                   dplyr::select(variable, family_var, family_name), 
                   by = c("Indicator" = "variable"))


# dir.create("data-raw/output", recursive = TRUE, showWarnings = FALSE)
utils::write.csv(coverage_dt, file = "data-raw/output/coverage_report.csv", row.names = FALSE)



## some notes from meeting

# turn this script perhaps into a function
# include the cluster average for this as well in this table