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

coverage_dt <- 
  purrr::imap(newpipeline_list, 
              function(x, name){

                y <- compute_coverage(data = x,
                                      country_id = country_code, 
                                      year_id = year,
                                      ref_year = 2024,
                                      country_region_list = wb_income_and_region)
                
                y <- y |> dplyr::mutate(dataset = name)
                
                return(y)

              }) |> dplyr::bind_rows()

dir.create("data-raw/output", recursive = TRUE, showWarnings = FALSE)
utils::write.csv(coverage_dt, file = "data-raw/output/coverage_report.csv", row.names = FALSE)