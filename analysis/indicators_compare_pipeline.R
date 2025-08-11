################################################################################
####### COMPARE PREVIOUS PIPELINE WITH LATEST UPDATE PIPELINE FOR CHANGES ######
################################################################################

newpipeline_list <- list(aspire,
                         d360_efi_data,
                         debt_transparency,
                         epl,
                         fraser,
                         gfdb,
                         heritage,
                         pefa_assessments |>
                           dplyr::select(-country_name),
                         pmr,
                         romelli,
                         vdem_data,
                         wdi_indicators)

names(newpipeline_list) <- as.character(substitute(list(aspire,
                                                        d360_efi_data,
                                                        debt_transparency,
                                                        epl,
                                                        fraser,
                                                        gfdb,
                                                        heritage,
                                                        pefa_assessments,
                                                        pmr,
                                                        romelli,
                                                        vdem_data,
                                                        wdi_indicators)))[-1]

newpipeline_list <- lapply(newpipeline_list, as_tibble)

#### lets apply compare_pipeline_indicators() to compare values across all our objects

check_list <- lapply(X = newpipeline_list,
                     old_df = readRDS(here("data-raw/input/cliar/compiled_indicators.rds")),
                     FUN = compare_pipeline_indicators)



