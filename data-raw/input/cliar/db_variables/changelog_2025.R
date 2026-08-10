
## 1.1 Renaming variables ----------
# Documenting variable changes in our dictionary
# Use `update_db_variables` function to update the `db_variables` dataframe.

# Named vector of changes: new name = old name
rename_variable <- c(
  "wdi_enghgco2rtgdpppkd" = "wdi_enatmco2eppgdkd",
  "wb_spi_std_and_methods" = "spi_std_and_methods",
  "wb_spi_census_and_survey_index" = "spi_census_and_survey_index"
)

# fix six variables that are incorrectly classified as `var_level` = NA
db_variables_2024 <- db_variables_2024 |>
  mutate(
    var_level = if_else(
      variable %in%
        c(
          "vdem_core_v2lgcrrpt",
          "vdem_core_v2x_execorr",
          "vdem_core_v2x_pubcorr",
          "wb_gtmi_i_12",
          "wb_pefa_pi_2016_07",
          "wb_pefa_pi_2016_08"
        ),
      "indicator",
      var_level
    )
  )

# Apply the renaming to the db_variables dataframe
db_variables_2024 <- update_db_variables(
  db_variables_2024,
  rename_map = rename_variable,
  column_name = "variable"
)


# Documenting var_names changes in our dictionary
# Cite: https://www.v-dem.net/documents/55/codebook.pdf

# vdem_core_v2lgfemleg       Lower chamber female legislators (v2lgqugen) extra
# vdem_core_v2caassemb       Freedom of peaceful assembly
# vdem_core_v2peasjgen       Access to state jobs by gender

## 1.2 Renaming SOE vars ---------

### Fix internal labeling for SOE Corporate Governance #34

rename_family <- c(
  "vars_soe" = "vars_service_del"
)

db_variables_2024 <- update_db_variables(
  db_variables_2024,
  rename_map = rename_family,
  column_name = "family_var"
)

## 1.3 Including the new pmr variables and deleting those we have removed

## remove the 2018 variable that was agreed to be dropped
dbpmr_varlist <- db_variables_2024$variable[grepl(
  "oecd_pmr",
  db_variables_2024$variable
)]

dropvars_list <- dbpmr_varlist[!dbpmr_varlist %in% colnames(pmr)]

db_variables_2024 <- db_variables_2024 |>
  dplyr::filter(
    !variable %in%
      c("oecd_pmr_2018_1_1", "oecd_pmr_2018_1_2", "oecd_pmr_2018_2_2")
  )

newpmr_tbl <-
  tibble::tibble(
    var_name = c(
      "Involvement in Business Operations in Services Sectors",
      "Involvement in Business Operations in Network Sectors"
    ),
    api_id = NA_character_,
    variable = c("oecd_pmr_2018_2_2_2", "oecd_pmr_2018_2_2_1"),
    var_level = "indicator",
    family_var = "vars_soe",
    family_name = rep("SOE Corporate Governance", 2),
    family_order = 10,
    processing = NA_character_,
    description = c(
      "measures the extent to which the government imposes restrictions on the conduct of firms in key service sectors (e.g., restrictions on the ownership and legal form of professional firms, restrictions on the geographic location of pharmacies, regulation of retail shop opening hours)",
      "measures the extent to which the government imposes restrictions on the conduct of firms in key network sectors (e.g., regulation of fixed and mobile number portability, constraints on airline route and frequency choices)"
    ),
    description_short = c(
      "measure how much government imposes restrictions on key service sector firms",
      "measure how much government imposes restrictions on key network sector firms"
    ),
    source = rep("OECD Product Market Regulation Database", 2),
    benchmarked_ctf = rep("Yes", 2),
    benchmark_static_family_aggregate_download = rep("No", 2),
    benchmark_dynamic_indicator = rep("No", 2),
    benchmark_dynamic_family_aggregate = rep("No", 2),
    etl_source = rep("oecd_pmr", 2),
    indicator_order = c(7, 8)
  )

## add new pmr variables
db_variables_2024 <-
  addnew_db_variables(
    db_variables = db_variables_2024,
    new_rows = newpmr_tbl
  ) |>
  arrange(variable)

## add new scorecard variables
scorecard_variables <- readr::read_csv(
  here("data-raw", "input", "csc", "scorecard_variables.csv")
) |> 
  mutate(
    variable = str_to_lower(variable)
  )

db_variables_2024 <- db_variables_2024 |> 
  addnew_db_variables(
    new_rows = scorecard_variables
  )

## 1.4 Fix benchmarking status of Democracy Status in the Political Institutions family
db_variables_2024 <- db_variables_2024 |>
  mutate(
    across(
      c(
        starts_with("benchmark")
      ),
      .fns = \(col) if_else(variable == "bs_bti_si", "Yes", col) # Adjusted benchmark status to "Yes" for that variable
    ),
    # fix indicator order
    indicator_order = case_when(
      family_var == "vars_pol" & variable == "bs_bti_si" ~ NA_real_,
      family_var == "vars_pol" ~ indicator_order - 1,
      T ~ indicator_order
    )
  )
