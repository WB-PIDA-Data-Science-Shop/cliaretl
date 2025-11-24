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
                         pefa_assessments,
                         pmr,
                         romelli,
                         vdem_data,
                         wdi_indicators,
                         wbl_data)

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
                                                        wdi_indicators,
                                                        wbl_data)))[-1]

newpipeline_list <- lapply(newpipeline_list, as_tibble)

#### lets apply compare_pipeline_indicators() to compare values across all our objects


plot_paths <- file.path(
  "data-raw/output/figures/pipeline_check",
  paste0(names(newpipeline_list), ".png")
)

check_list <- Map(
  f = compare_pipeline_indicators,
  new_df = newpipeline_list,
  plot_save_path = plot_paths,
  MoreArgs = list(old_df = readRDS("data-raw/input/cliar/compiled_indicators.rds"))
)