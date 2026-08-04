################################################################################
#################### SOME FUNS FOR QUICK DATA ESTIMATES ########################
################################################################################

utils::globalVariables(c(
  "indicator",
  "country_coverage",
  "year_coverage",
  "year_range",
  "percent_complete_records",
  "percent_complete_records_last_five",
  "standard_deviation",
  "region",
  "country"
))


#' Calculate coverage for an indicator
#'
#' This function computes the number of distinct identifiers (`id`)
#' for which a given indicator has non-missing values. It is useful
#' to measure the coverage of an indicator across countries, years,
#' or any other grouping identifier.
#'
#' @param indicator A vector containing indicator values. May include `NA`s.
#' @param id A vector of identifiers (e.g., country codes, years) corresponding
#'   to the indicator values.
#'
#' @export
calculate_coverage <- function(indicator, id) {
  coverage_id <- n_distinct({{id}}[!is.na(indicator)])
  return(coverage_id)
}

#' Flag continuity of an indicator series
#'
#' Returns a flag indicating whether an indicator has been updated
#' within the last five years relative to a reference year.
#'
#' @param indicator A vector of indicator values. May include `NA`s.
#' @param year_id A vector of years corresponding to the indicator values.
#' @param ref_year A numeric value indicating the most recent year of reference.
#'
#' @return An integer flag:
#' \itemize{
#'   \item `1` if at least one non-missing value is available in the last five years.
#'   \item `0` otherwise.
#' }
#'
#' @export
flag_continued <- function(indicator, year_id, ref_year) {
  times_updated <- length(indicator[{{year_id}} >= ref_year - 5 & !is.na(indicator)])
  flag_continued <- if_else(times_updated > 0, 1, 0)
  return(flag_continued)
}

#' Flag sufficient country coverage
#'
#' Returns a flag indicating whether an indicator achieves a minimum
#' level of country and regional coverage in the last five years.
#'
#' @param indicator A vector of indicator values.
#' @param country_id A vector of country identifiers.
#' @param year_id A vector of years.
#' @param ref_year A numeric value indicating the most recent year of reference.
#' @param country_region_list A data frame mapping `country_code` to `region`.
#'
#' @details
#' The flag is set to `1` if either:
#' \itemize{
#'   \item At least 100 countries have non-missing values in the last five years; or
#'   \item At least 50 countries have non-missing values and all 7 regions are represented.
#' }
#'
#' Otherwise, the flag is set to `0`.
#'
#' @return An integer flag (`1` or `0`).
#'
#' @export
flag_country <- function(indicator, country_id, year_id, ref_year, country_region_list) {
  country_coverage <- n_distinct({{country_id}}[{{year_id}} >= ref_year - 5 & !is.na(indicator)])
  country_code_unique <- unique({{country_id}}[{{year_id}} >= ref_year - 5 & !is.na(indicator)])

  regions_covered <- country_region_list %>%
    filter(country_code %in% country_code_unique) %>%
    distinct(region) %>%
    nrow()

  flag_country <- if_else(
    country_coverage >= 100 | (country_coverage >= 50 & regions_covered == 7),
    1, 0
  )

  return(flag_country)
}


#' Flag minimum coverage of an indicator
#'
#' Returns a flag indicating whether an indicator has sufficient
#' country coverage over time.
#'
#' @param indicator A vector of indicator values.
#' @param country_id A vector of country identifiers.
#' @param year_id A vector of years.
#'
#' @details
#' The flag is set to `1` if the indicator has values in at least two years
#' where each of those years covers 10 or more distinct countries.
#' Otherwise, the flag is set to `0`.
#'
#' @return An integer flag (`1` or `0`)
#'
#' @export
flag_minimum_coverage <- function(indicator, country_id, year_id) {
  country_coverage <- tibble(
    indicator = indicator,
    country = country_id,
    year = year_id
  )

  minimum_country_coverage <- country_coverage %>%
    filter(!is.na(indicator)) %>%
    group_by(year) %>%
    summarise(country_coverage = n_distinct(country), .groups = "drop") %>%
    filter(country_coverage >= 10)

  flag_minimum_coverage <- if_else(nrow(minimum_country_coverage) >= 2, 1, 0)
  return(flag_minimum_coverage)
}


#' Calculate the time range of an indicator
#'
#' Returns the first and last year (inclusive) for which an indicator
#' has non-missing values.
#'
#' @param indicator A vector of indicator values.
#' @param time_id A vector of years corresponding to the indicator values.
#'
#' @return A character string of the form `"start_year-end_year"`.
#'
#' @export
calculate_time_range <- function(indicator, time_id) {
  year_range <- paste0(
    min({{time_id}}[!is.na(indicator)], na.rm = TRUE),
    "-",
    max({{time_id}}[!is.na(indicator)], na.rm = TRUE)
  )

  return(year_range)
}

#' Compute coverage and summary statistics for indicators
#'
#' This function evaluates coverage and data quality for a set of indicators
#' across countries and years. It summarizes country coverage, year coverage,
#' continuity flags, completeness, and basic descriptive statistics (mean,
#' median, standard deviation, min, max) for each indicator in a dataset.
#'
#' @param data A data frame or tibble containing indicator values along with
#'   country and year identifiers.
#' @param country_id A column identifying countries (e.g., `country_code`).
#' @param year_id A column identifying years.
#' @param ref_year A numeric value indicating the most recent year of reference
#'   (used to calculate last-five-years coverage and continuity flags).
#' @param country_region_list A data frame with columns `country_code` and `region`
#'   used to assess regional country coverage. If `NULL` (the default), the
#'   `flag_country` metric will return `NA` for all indicators.
#'
#' @details
#' The function computes, for each indicator:
#' - **Country Coverage**: number of distinct countries with non-missing values.
#' - **Year Coverage**: number of distinct years with non-missing values.
#' - **Flag Continuity**: indicator of whether values are continuous up to `ref_year`.
#' - **Flag Country Coverage**: indicator of sufficient country coverage
#'   (requires `country_region_list` to be supplied).
#' - **Flag Year Coverage**: indicator of whether minimum year coverage criteria are met.
#' - **Year Range**: minimum and maximum year observed with non-missing values.
#' - **Percentage of Complete Records**: share of complete observations.
#' - **Percentage of Complete Records in Last Five Years**: completeness restricted
#'   to the period close to `ref_year`.
#' - **Summary statistics**: mean, median, standard deviation, minimum, and maximum.
#'
#' @return A tibble with one row per indicator and the following columns:
#' \describe{
#'   \item{Indicator}{Indicator name.}
#'   \item{Country Coverage}{Number of countries with non-missing values.}
#'   \item{Year Coverage}{Number of years with non-missing values.}
#'   \item{Flag Continuity}{Logical or numeric flag for continuity up to `ref_year`.}
#'   \item{Flag Country Coverage}{Flag for sufficient cross-country coverage.}
#'   \item{Flag Year Coverage}{Flag for sufficient time coverage.}
#'   \item{Year Range}{Earliest and latest years with available data.}
#'   \item{Percentage of Complete Records}{Proportion of complete cases overall.}
#'   \item{Percentage of Complete Records in Last Five Years}{Proportion complete near `ref_year`.}
#'   \item{Mean, Median, Standard Deviation, Minimum, Maximum}{Basic summary statistics.}
#' }
#'
#' @export
compute_coverage <- function(data, country_id, year_id, ref_year, country_region_list = NULL){

  # ---- local helpers (no external packages) ----
  prop_complete_vec <- function(x) {
    n <- length(x)
    if (n == 0) return(NA_real_)
    mean(!is.na(x))
  }

  percent_str <- function(p, digits = 1) {
    # p is a proportion in [0,1]; returns "xx.x%" (or NA_character_ if NA)
    if (is.na(p)) return(NA_character_)
    paste0(round(100 * p, digits), "%")
  }

  data_coverage <- data |>
    # compute per-indicator metrics (excluding id cols)
    dplyr::summarise(
      dplyr::across(
        c(
          dplyr::everything(),
          -{{country_id}},
          -{{year_id}}
        ),
        list(
          country_coverage = ~ calculate_coverage(.x, {{country_id}}),
          year_coverage = ~ calculate_coverage(.x, {{year_id}}),
          flag_continued = ~ flag_continued(.x, {{year_id}}, ref_year),
          flag_country = ~ flag_country(.x, {{country_id}}, {{year_id}}, ref_year, country_region_list),
          flag_minimum_coverage = ~ flag_minimum_coverage(.x, {{country_id}}, {{year_id}}),
          year_range = ~ calculate_time_range(.x, {{year_id}}),

          # proportions (base) and then format as strings with %
          percent_complete_records = ~ percent_str(prop_complete_vec(.x)),
          percent_complete_records_last_five = ~ percent_str(prop_complete_vec(.x[{{year_id}} >= ref_year])),

          mean = ~ round(mean(.x, na.rm = TRUE), 2),
          median = ~ stats::median(.x, na.rm = TRUE),
          standard_deviation = ~ round(stats::sd(.x, na.rm = TRUE), 2),
          min = ~ suppressWarnings(min(.x, na.rm = TRUE)),
          max = ~ suppressWarnings(max(.x, na.rm = TRUE))
        ),
        .names = "{.col}__{.fn}"
      )
    ) |>
    tidyr::pivot_longer(
      cols = dplyr::everything(),
      cols_vary = "slowest",
      names_to = c("indicator", ".value"),
      names_pattern = "(.*)__(.*)"
    ) |>
    dplyr::arrange(indicator) |>
    dplyr::select(
      Indicator = indicator,
      `Country Coverage` = country_coverage,
      `Year Coverage` = year_coverage,
      `Flag Continuity` = flag_continued,
      `Flag Country Coverage` = flag_country,
      `Flag Year Coverage` = flag_minimum_coverage,
      `Year Range` = year_range,
      `Percentage of Complete Records` = percent_complete_records,
      `Percentage of Complete Records in Last Five Years` = percent_complete_records_last_five,
      `Mean` = mean,
      `Median` = median,
      `Standard Deviation` = standard_deviation,
      `Minimum` = min,
      `Maximum` = max
    )

  return(data_coverage)
}

#' Compute coverage and summary statistics for indicators (version 2)
#'
#' This function evaluates coverage and data quality for a set of indicators
#' across countries and years, similar to `compute_coverage()`, but includes
#' additional features for dynamic and static window analysis. It summarizes
#' country coverage, year coverage, continuity flags, completeness, and basic
#' descriptive statistics (mean, median, standard deviation, min, max) for each
#' indicator in a dataset. It also assesses coverage in specified static and
#' dynamic windows and flags indicators based on eligibility criteria for
#' benchmarking.
#'
#' @param data A data frame or tibble containing indicator values along with
#'   country and year identifiers.
#' @param country_id A column identifying countries (e.g., `country_code`).
#' @param year_id A column identifying years.
#' @param ref_year A numeric value indicating the most recent year of reference
#'   (used to calculate last-five-years coverage and continuity flags).
#' @param country_region_list A data frame with columns `country_code` and `region`
#'   used to assess regional country coverage. If `NULL` (the default), the
#'   `flag_country` metric will return `NA` for all indicators.
#' @param dataset_name An optional column indicating the dataset or source of
#'   the indicators, used to apply specific rules or exclusions for certain datasets.
#' @param static_window A numeric vector specifying the years defining the static
#'   window for coverage assessment (default is 2021 to 2025).
#' @param dynamic_even_years A numeric vector specifying the even years for the
#'   dynamic panel coverage assessment (default is every second year from 2016 to 2025).
#' @param dynamic_excluded A character vector of dataset names to be excluded from
#'   dynamic benchmarking (default includes "PEFA", "OECD PMR", "GTMI").
#' @param exception_datasets A character vector of dataset names that have
#'   documented methodology exceptions, meaning red flags on coverage are expected
#'   and should not be interpreted as data quality failures (default includes
#'   "PEFA", "OECD PMR").
#'
#' @details
#' The function computes, for each indicator:
#' - **Country Coverage**: number of distinct countries with non-missing values.
#' - **Year Coverage**: number of distinct years with non-missing values.
#' - **Flag Continuity**: indicator of whether values are continuous up to `ref_year`.
#' - **Flag Country Coverage**: indicator of sufficient country coverage
#'   (requires `country_region_list` to be supplied).
#' - **Flag Year Coverage**: indicator of whether minimum year coverage criteria are met.
#' - **Year Range**: minimum and maximum year observed with non-missing values.
#' - **Percentage of Complete Records**: share of complete observations.
#' - **Percentage of Complete Records in Last Five Years**: completeness restricted
#'   to the period close to `ref_year`.
#' - **Summary statistics**: mean, median, standard deviation, minimum, and maximum.
#' - **Static Valid Years**: count of years with at least 10 countries in the static window.
#' - **Dynamic Valid Years**: count of years with at least 10 countries in the dynamic panel.
#' - **Static Country Coverage**: count of distinct countries in the static window.
#' - **Dynamic Country Coverage**: count of distinct countries in the dynamic panel.
#'
#' @return A tibble with one row per indicator and the following columns:
#' \describe{
#'   \item{Indicator}{Indicator name.}
#'   \item{Country Coverage}{Number of countries with non-missing values.}
#'   \item{Year Coverage}{Number of years with non-missing values.}
#'   \item{Flag Continuity}{Logical or numeric flag for continuity up to `ref_year`.}
#'   \item{Flag Country Coverage}{Flag for sufficient cross-country coverage.}
#'   \item{Flag Year Coverage}{Flag for sufficient time coverage.}
#'   \item{Year Range}{Earliest and latest years with available data.}
#'   \item{Percentage of Complete Records}{Proportion of complete cases overall.}
#'   \item{Percentage of Complete Records in Last Five Years}{Proportion complete near `ref_year`.}
#'   \item{Mean, Median, Standard Deviation, Minimum, Maximum}{Basic summary statistics.}
#'   \item{Static Valid Years}{Number of years with at least 10 countries in the static window.}
#'   \item{Dynamic Valid Years}{Number of years with at least 10 countries in the dynamic panel.}
#'   \item{Static Country Coverage}{Number of distinct countries in the static window.}
#'   \item{Dynamic Country Coverage}{Number of distinct countries in the dynamic panel.}
#' }
#'
#' @export
compute_coverage2 <- function(data,
                              country_id,
                              year_id,
                              ref_year,
                              country_region_list    = NULL,
                              dataset_name           = NULL,
                              static_window          = 2021:2025,
                              dynamic_even_years     = seq(2016, 2025, by = 2),
                              dynamic_excluded       = c("PEFA", "OECD PMR", "GTMI"),
                              exception_datasets     = c("PEFA", "OECD PMR")) {

  # ---- local helpers ----
  prop_complete_vec <- function(x) {
    n <- length(x)
    if (n == 0) return(NA_real_)
    mean(!is.na(x))
  }

  percent_str <- function(p, digits = 1) {
    if (is.na(p)) return(NA_character_)
    paste0(round(100 * p, digits), "%")
  }

  # Count distinct years within `window` where the indicator has >= 10 non-missing obs.
  # This implements the Box 1 "each year must have >= 10 countries" criterion
  # restricted to the window of interest (static or dynamic).
  count_valid_years_in_window <- function(x, yr, window) {
    target_years <- unique(yr[yr %in% window])
    if (length(target_years) == 0L) return(0L)
    sum(vapply(target_years, function(y) sum(!is.na(x[yr == y])) >= 10L, logical(1L)))
  }

  # Count distinct countries with >= 1 non-missing observation in `window`.
  # This is the country-level analogue of count_valid_years_in_window():
  # it answers "how many countries can actually contribute to the CTF score
  # in this window?" rather than "how many years are sufficiently populated?"
  count_countries_in_window <- function(x, yr, cty, window) {
    in_window <- yr %in% window & !is.na(x)
    length(unique(cty[in_window]))
  }

  # ---- main summarise ----
  data_coverage <- data |>
    dplyr::summarise(
      dplyr::across(
        c(
          dplyr::everything(),
          -{{ country_id }},
          -{{ year_id }}
        ),
        list(
          country_coverage              = ~ calculate_coverage(.x, {{ country_id }}),
          year_coverage                 = ~ calculate_coverage(.x, {{ year_id }}),
          flag_continued                = ~ flag_continued(.x, {{ year_id }}, ref_year),
          flag_country                  = ~ flag_country(.x, {{ country_id }}, {{ year_id }}, ref_year, country_region_list),
          flag_minimum_coverage         = ~ flag_minimum_coverage(.x, {{ country_id }}, {{ year_id }}),
          year_range                    = ~ calculate_time_range(.x, {{ year_id }}),
          percent_complete_records      = ~ percent_str(prop_complete_vec(.x)),
          percent_complete_records_last_five = ~ percent_str(prop_complete_vec(.x[{{ year_id }} >= ref_year])),
          mean                          = ~ round(mean(.x, na.rm = TRUE), 2),
          median                        = ~ stats::median(.x, na.rm = TRUE),
          standard_deviation            = ~ round(stats::sd(.x, na.rm = TRUE), 2),
          min                           = ~ suppressWarnings(min(.x, na.rm = TRUE)),
          max                           = ~ suppressWarnings(max(.x, na.rm = TRUE)),
          # new: years with >= 10 countries in the static 5-year window
          static_valid_years            = ~ count_valid_years_in_window(.x, {{ year_id }}, static_window),
          # new: even years with >= 10 countries in the dynamic panel
          dynamic_valid_years           = ~ count_valid_years_in_window(.x, {{ year_id }}, dynamic_even_years),
          # new: country counts within each window
          static_countries     = ~ count_countries_in_window(.x, {{ year_id }}, {{ country_id }}, static_window),
          dynamic_countries    = ~ count_countries_in_window(.x, {{ year_id }}, {{ country_id }}, dynamic_even_years)
        ),
        .names = "{.col}__{.fn}"
      )
    ) |>
    tidyr::pivot_longer(
      cols       = dplyr::everything(),
      cols_vary  = "slowest",
      names_to   = c("indicator", ".value"),
      names_pattern = "(.*)__(.*)"
    ) |>
    dplyr::arrange(indicator) |>
    dplyr::select(
      Indicator                                        = indicator,
      `Country Coverage`                               = country_coverage,
      `Year Coverage`                                  = year_coverage,
      `Flag Continuity`                                = flag_continued,
      `Flag Country Coverage`                          = flag_country,
      `Flag Year Coverage`                             = flag_minimum_coverage,
      `Year Range`                                     = year_range,
      `Percentage of Complete Records`                 = percent_complete_records,
      `Percentage of Complete Records in Last Five Years` = percent_complete_records_last_five,
      `Mean`                                           = mean,
      `Median`                                         = median,
      `Standard Deviation`                             = standard_deviation,
      `Minimum`                                        = min,
      `Maximum`                                        = max,
      `Static Valid Years`                             = static_valid_years,
      `Dynamic Valid Years`                            = dynamic_valid_years,
      `Static Country Coverage`                        = static_countries,
      `Dynamic Country Coverage`                       = dynamic_countries
    ) #    |>
    # # ---- eligibility classification ----
    # dplyr::mutate(
    #   # All benchmarked CTF indicators are static-eligible by definition;
    #   # this is an explicit column so the dashboard can filter on it.
    #   `Static Eligible`    = TRUE,

    #   # Dynamic eligibility: FALSE for datasets excluded from dynamic benchmarking.
    #   # NA when dataset_name was not supplied (defensive fallback).
    #   `Dynamic Eligible`   = if (is.null(dataset_name)) NA
    #                          else !(dataset_name %in% dynamic_excluded),

    #   # Exception flag: TRUE for datasets with a documented methodology exception
    #   # (PEFA and OECD PMR), meaning red flags on coverage are expected and
    #   # should not be interpreted as data quality failures.
    #   `Exception Granted`  = if (is.null(dataset_name)) NA
    #                          else (dataset_name %in% exception_datasets)
    # )

  return(data_coverage)
}


