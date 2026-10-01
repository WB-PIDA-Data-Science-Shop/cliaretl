# CLIAR ETL Pipeline
#
# Orchestrates the full pipeline, from raw source extraction
# (data-raw/source/*.R) through the compiled panel, CTF transformations, and
# the indicators map (analysis/01-04*.R).
#
# Every script stays the single, actual implementation -- nothing is
# duplicated into R/ functions. Each script gets a `format = "file"` target
# that hashes its content, paired with a target that sources it into a
# scoped environment via `source_script_env()` (R/pipeline_management_funs.R)
# and plucks the object(s) it produces out. Editing a script changes its file
# target's hash, which correctly reruns just that target and whatever
# actually depends on it downstream.
#
# Run with: targets::tar_make()
# Visualise with: targets::tar_visnetwork()

library(targets)

tar_option_set(
  packages = c(
    "dplyr", "tidyr", "purrr", "stringr", "readr", "readxl",
    "haven", "janitor", "here", "usethis", "tibble", "httr", "jsonlite",
    "countrycode", "openxlsx", "rsdmx", "vdemdata",
    "sf", "geojsonio", "rmapshaper", "ggplot2", "patchwork",
    "testthat", "dlookr", "scales"
  ),
  format = "rds"
)

devtools::load_all()

list(

  # ==========================================================================
  # STAGE 0: root -- country lists (almost everything else depends on this)
  # ==========================================================================

  tar_target(country_list_script, "data-raw/source/country_list.R", format = "file"),
  tar_target(country_list_env, source_script_env(country_list_script)),
  tar_target(wb_country_list, country_list_env$wb_country_list),
  tar_target(wb_country_groups, country_list_env$wb_country_groups),
  tar_target(wb_income_and_region, country_list_env$wb_income_and_region),

  # ==========================================================================
  # STAGE 1: extraction -- data-raw/source/*.R, one file-tracked target pair
  # per script. Grouped by dependency shape, not alphabetically.
  # ==========================================================================

  # ---- no dependencies beyond internal package functions -------------------

  tar_target(romelli_script, "data-raw/source/romelli.R", format = "file"),
  tar_target(romelli, source_script_env(romelli_script)$romelli),

  tar_target(bready_script, "data-raw/source/bready.R", format = "file"),
  tar_target(bready, source_script_env(bready_script)$bready),

  tar_target(credit_rating_script, "data-raw/source/credit_rating.R", format = "file"),
  tar_target(credit_rating, source_script_env(credit_rating_script)$credit_rating),

  tar_target(budget_execution_script, "data-raw/source/budget_execution.R", format = "file"),
  tar_target(budget_execution, source_script_env(budget_execution_script)$budget_execution),

  tar_target(gfdb_script, "data-raw/source/gfdb.R", format = "file"),
  tar_target(gfdb, source_script_env(gfdb_script)$gfdb),

  tar_target(pmr_url_file, "data-raw/input/pmr/url.txt", format = "file"),
  tar_target(pmr_script, "data-raw/source/pmr.R", format = "file"),
  tar_target(pmr, {
    pmr_url_file # force: script re-reads this file by its own path
    source_script_env(pmr_script)$pmr
  }),

  # ---- needs wb_country_list only -------------------------------------------

  tar_target(epl_url_file, "data-raw/input/epl/epl", format = "file"),
  tar_target(epl_script, "data-raw/source/epl.R", format = "file"),
  tar_target(epl, {
    epl_url_file
    source_script_env(epl_script, wb_country_list = wb_country_list)$epl
  }),

  tar_target(spi_script, "data-raw/source/spi.R", format = "file"),
  tar_target(spi, source_script_env(spi_script, wb_country_list = wb_country_list)$spi),

  tar_target(heritage_script, "data-raw/source/heritage.R", format = "file"),
  tar_target(heritage, source_script_env(heritage_script, wb_country_list = wb_country_list)$heritage),

  tar_target(labor_income_script, "data-raw/source/labor_income.R", format = "file"),
  tar_target(labor_income, source_script_env(labor_income_script, wb_country_list = wb_country_list)$labor_income),

  tar_target(scorecard_vars_file, "data-raw/input/csc/csc_variables.xlsx", format = "file"),
  tar_target(scorecard_script, "data-raw/source/scorecard.R", format = "file"),
  tar_target(scorecard, {
    scorecard_vars_file
    source_script_env(scorecard_script, wb_country_list = wb_country_list)$scorecard
  }),

  tar_target(vdem_script, "data-raw/source/vdem.R", format = "file"),
  tar_target(vdem_data, source_script_env(vdem_script, wb_country_list = wb_country_list)$vdem_data),

  tar_target(wb_wdi_script, "data-raw/source/wb_wdi.R", format = "file"),
  tar_target(wdi_indicators, source_script_env(wb_wdi_script, wb_country_list = wb_country_list)$wdi_indicators),

  tar_target(wbl_script, "data-raw/source/wbl.R", format = "file"),
  tar_target(wbl_data, source_script_env(wbl_script, wb_country_list = wb_country_list)$wbl_data),

  tar_target(obs_script, "data-raw/source/obs.R", format = "file"),
  tar_target(obs, source_script_env(obs_script, wb_country_list = wb_country_list)$obs),

  tar_target(freedom_house_script, "data-raw/source/freedom_house.R", format = "file"),
  tar_target(freedom_house, source_script_env(freedom_house_script, wb_country_list = wb_country_list)$freedom_house),

  tar_target(press_freedom_script, "data-raw/source/press_freedom.R", format = "file"),
  tar_target(press_freedom, source_script_env(press_freedom_script, wb_country_list = wb_country_list)$press_freedom),

  tar_target(sgi_script, "data-raw/source/sgi.R", format = "file"),
  tar_target(sgi, source_script_env(sgi_script, wb_country_list = wb_country_list)$sgi),

  tar_target(wb_enterprise_script, "data-raw/source/wb_enterprise.R", format = "file"),
  tar_target(wb_enterprise, source_script_env(wb_enterprise_script, wb_country_list = wb_country_list)$wb_enterprise),

  tar_target(aspire_script, "data-raw/source/aspire.R", format = "file"),
  tar_target(aspire, source_script_env(aspire_script, wb_country_list = wb_country_list)$aspire),

  # ---- manual-file sources: no live download, human places the file(s) -----

  tar_target(fraser_input_file,
             "data-raw/input/fraser/efotw-2024-master-index-data-for-researchers-iso.xlsx",
             format = "file"),
  tar_target(fraser_script, "data-raw/source/fraser.R", format = "file"),
  tar_target(fraser, {
    fraser_input_file
    source_script_env(fraser_script, wb_country_list = wb_country_list)$fraser
  }),

  tar_target(fcv_input_file, "data-raw/input/wb/fcv.xlsx", format = "file"),
  tar_target(fcv_script, "data-raw/source/fcv.R", format = "file"),
  tar_target(fcv, {
    fcv_input_file
    source_script_env(fcv_script)$fcv
  }),

  tar_target(debt_transparency_input_files,
             list.files(here::here("data-raw", "input", "debt_transparency"), full.names = TRUE),
             format = "file"),
  tar_target(debt_transparency_script, "data-raw/source/debt_transparency.R", format = "file"),
  tar_target(debt_transparency, {
    debt_transparency_input_files
    source_script_env(debt_transparency_script, wb_country_list = wb_country_list)$debt_transparency
  }),

  # ---- needs wb_country_list + db_variables.xlsx (genuinely consumed) ------

  tar_target(db_variables_xlsx_file, "data-raw/input/cliar/db_variables.xlsx", format = "file"),
  tar_target(pefa_legacy_file,
             "data-raw/input/pefa_assessments/assessments_1730149268.csv",
             format = "file"),
  tar_target(pefa_assessments_script, "data-raw/source/pefa_assessments.R", format = "file"),
  tar_target(pefa_assessments, {
    db_variables_xlsx_file
    pefa_legacy_file
    source_script_env(pefa_assessments_script, wb_country_list = wb_country_list)$pefa_assessments
  }),

  # ---- reads CLIAR_Metadata_Prod_D360.xlsx (the file that gets hand-edited) -

  tar_target(d360_metadata_file,
             "data-raw/input/cliar/CLIAR_Metadata_Prod_D360.xlsx",
             format = "file"),
  tar_target(d360_efi_api_script, "data-raw/source/d360_efi_api.R", format = "file"),
  tar_target(d360_efi_data, {
    d360_metadata_file
    source_script_env(d360_efi_api_script)$d360_efi_data
  }),

  # ==========================================================================
  # STAGE 1b: extraction scripts that depend on the dictionary (stage 2) --
  # these sit downstream of db_variables/db_variables_final, not alongside
  # the roots above.
  # ==========================================================================

  tar_target(gsod_script, "data-raw/source/gsod.R", format = "file"),
  tar_target(gsod, {
    source_script_env(gsod_script, wb_country_list = wb_country_list, db_variables = db_variables)$gsod
  }),

  tar_target(wjp_script, "data-raw/source/wjp.R", format = "file"),
  tar_target(wjp, {
    source_script_env(wjp_script, db_variables_final = db_variables_final)$wjp
  }),

  # ==========================================================================
  # STAGE 2: dictionary & extraction QC -- analysis/01*.R
  # ==========================================================================

  # db_variables/db_variables_final/family_order's actual VALUES come only
  # from db_variables_2025.rds + a hardcoded family_order table inside the
  # script -- the cliaretl::x reads in 01-extraction.R are namespace access
  # (resolve automatically once the package is loaded, no injection needed)
  # used only for QC message printing. The bare references below force
  # those 14 targets to run first, so the QC messages reflect this run's
  # fresh pulls rather than a stale previously-installed version.
  tar_target(db_variables_2025_file,
             "data-raw/input/cliar/db_variables/db_variables_2025.rds",
             format = "file"),
  tar_target(extraction_script, "analysis/01-extraction.R", format = "file"),
  tar_target(extraction_env, {
    db_variables_2025_file
    debt_transparency; wdi_indicators; pefa_assessments; romelli; vdem_data
    gfdb; heritage; pmr; epl; d360_efi_data; fraser; aspire; wbl_data; scorecard
    source_script_env(extraction_script)
  }),
  tar_target(db_variables, extraction_env$db_variables),
  tar_target(db_variables_final, extraction_env$db_variables_final),
  tar_target(family_order, extraction_env$family_order),

  # this one genuinely reads its comparison sources as bare globals
  tar_target(extraction_qc_script, "analysis/01.1-extraction_quality_control.R", format = "file"),
  tar_target(extraction_qc, {
    source_script_env(
      extraction_qc_script,
      aspire = aspire, d360_efi_data = d360_efi_data, debt_transparency = debt_transparency,
      epl = epl, fraser = fraser, gfdb = gfdb, heritage = heritage,
      pefa_assessments = pefa_assessments, pmr = pmr, romelli = romelli,
      vdem_data = vdem_data, wdi_indicators = wdi_indicators
    )
    TRUE
  }),

  # ==========================================================================
  # STAGE 3: compiled indicators panel -- analysis/02*.R
  # ==========================================================================

  tar_target(compiled_indicators_script, "analysis/02-compiled_indicators_panel.R", format = "file"),
  tar_target(
    compiled_indicators,
    {
      source_script_env(
        compiled_indicators_script,
        db_variables = db_variables, wb_country_list = wb_country_list, family_order = family_order,
        debt_transparency = debt_transparency, wdi_indicators = wdi_indicators,
        pefa_assessments = pefa_assessments, romelli = romelli, vdem_data = vdem_data,
        gfdb = gfdb, heritage = heritage, pmr = pmr, epl = epl, d360_efi_data = d360_efi_data,
        fraser = fraser, aspire = aspire, wbl_data = wbl_data, scorecard = scorecard,
        spi = spi, wjp = wjp, budget_execution = budget_execution, credit_rating = credit_rating,
        freedom_house = freedom_house, gsod = gsod, labor_income = labor_income, obs = obs,
        press_freedom = press_freedom, sgi = sgi, wb_enterprise = wb_enterprise
      )
      here::here("inst", "extdata", "compiled_indicators.rds")
    },
    format = "file"
  ),

  tar_target(compiled_indicators_qc_script,
             "analysis/02.1-compiled_indicators_quality_control.R", format = "file"),
  tar_target(compiled_indicators_qc, {
    force(compiled_indicators)
    source_script_env(compiled_indicators_qc_script, db_variables = db_variables)
    TRUE
  }),

  # ==========================================================================
  # STAGE 4: CTF transformations -- analysis/03*.R
  # ==========================================================================

  tar_target(ctf_transformations_script, "analysis/03-ctf_transformations.R", format = "file"),
  tar_target(ctf_results, {
    force(compiled_indicators)
    source_script_env(
      ctf_transformations_script,
      db_variables = db_variables, wb_country_list = wb_country_list,
      wb_income_and_region = wb_income_and_region
    ) |>
      (\(env) list(ctf_static = env$ctf_static_clean, ctf_dynamic = env$ctf_dynamic_clean))()
  }),
  tar_target(ctf_static, ctf_results$ctf_static),
  tar_target(ctf_dynamic, ctf_results$ctf_dynamic),

  tar_target(ctf_qc_script, "analysis/03.1-ctf_quality_control.R", format = "file"),
  tar_target(ctf_qc_env, {
    force(ctf_static); force(ctf_dynamic); force(compiled_indicators)
    source_script_env(
      ctf_qc_script,
      db_variables = db_variables, wb_country_list = wb_country_list,
      wb_income_and_region = wb_income_and_region
    )
  }),

  tar_target(closeness_to_frontier_static, ctf_qc_env$closeness_to_frontier_static),
  tar_target(closeness_to_frontier_dynamic, ctf_qc_env$closeness_to_frontier_dynamic),

  # ==========================================================================
  # STAGE 5: indicators map -- analysis/04*.R
  # ==========================================================================

  tar_target(worldmap_url_file, "data-raw/input/wb/worldmap_url.txt", format = "file"),
  tar_target(disputedareas_url_file, "data-raw/input/wb/disputedareas_url.txt", format = "file"),
  tar_target(indicators_map_script, "analysis/04-map_indicators.R", format = "file"),
  tar_target(
    indicators_map,
    {
      force(closeness_to_frontier_static); force(compiled_indicators); force(db_variables)
      worldmap_url_file; disputedareas_url_file
      source_script_env(indicators_map_script)
      here::here("inst", "extdata", "indicators_map.rds")
    },
    format = "file"
  )
)
