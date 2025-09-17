################################################################################
################### SOME FUNS FOR CTF DATA CALCULATIONS ########################
################################################################################

utils::globalVariables(c("ctf", "value", "var_name"))

#' Flip Indicator Direction
#'
#' Multiplies indicator values by `-1` so that higher values represent stronger institutions.
#' Typically used when the original indicator increases with institutional weakness.
#'
#' @param x Numeric vector. Indicator values to flip.
#' @param na_rm Logical, default = TRUE. If TRUE, `NA` values are preserved; if FALSE, produces `NaN` for missing values.
#'
#' @return A numeric vector with flipped values.
#' @examples
#' flip_indicator(c(1, 2, 3, NA))
#' # Returns: -1, -2, -3, NA
#'
#' @export
flip_indicator <- function(x, na_rm = TRUE) {
  if (na_rm) return(ifelse(is.na(x), NA, -1 * x))
  -1 * x
}


#' Reverse Indicator Scale
#'
#' Reverses the direction of an indicator using a known scale.
#' The formula applied is: \code{(max + min) - x}.
#'
#' @param x Numeric vector. Indicator values to reverse.
#' @param min Numeric. Minimum possible value of the indicator.
#' @param max Numeric. Maximum possible value of the indicator.
#' @param na_rm Logical, default = TRUE. If TRUE, `NA` values are preserved.
#'
#' @return A numeric vector with reversed values.
#' @examples
#' reverse_indicator(c(1, 2, 7), min = 1, max = 7)
#' # Returns: 7, 6, 1
#'
#' reverse_indicator(c(0, 3, 6), min = 0, max = 6)
#' # Returns: 6, 3, 0
#'
#' @export
reverse_indicator <- function(x, min, max, na_rm = TRUE) {
  if (missing(min) || missing(max)) {
    stop("Both 'min' and 'max' must be provided for reverse_indicator().")
  }

  if (na_rm) return(ifelse(is.na(x), NA, (max + min) - x))
  (max + min) - x
}


#' Re-scale Indicator Values
#'
#' Scales a numeric vector to a 0–1 range (or 0–100 if specified).
#'
#' @param x Numeric vector. Indicator values to re-scale.
#' @param scale_to Numeric, default = 1. Upper bound of the scale (1 for 0–1, 100 for 0–100).
#' @param na_rm Logical, default = TRUE. If TRUE, `NA` values are preserved.
#'
#' @return A numeric vector of re-scaled values.
#' @examples
#' rescale_indicator(c(10, 20, 30))
#' # Returns: 0, 0.5, 1
#'
#' rescale_indicator(c(10, 20, 30), scale_to = 100)
#' # Returns: 0, 50, 100
#'
#' @export
rescale_indicator <- function(x, scale_to = 1, na_rm = TRUE) {
  rng <- range(x, na.rm = TRUE)
  if (diff(rng) == 0) {
    warning("All values are identical; returning zeros.")
    return(rep(0, length(x)))
  }

  norm <- (x - rng[1]) / diff(rng) * scale_to
  if (na_rm) return(ifelse(is.na(x), NA, norm))
  norm
}



#' Family-level averages
#'
#' @description
#' Compute simple means of indicator columns by institutional family
#' (from `db_variables$family_var`). Works on static (by country) or
#' dynamic (by country-year) panels.
#'
#' @param cliar_data Data frame with `country_code`, optional `year`, and indicators.
#' @param vars Tidyselect for indicator columns (e.g., `starts_with("vdem_")`).
#' @param type `"static"` (default) or `"dynamic"`.
#' @param db_variables Data frame with columns: `variable`, `var_name`, `family_name`, `family_var`.
#' @param require_complete If `TRUE` (default), return `NA` unless all indicators in a family are present within a group.
#' @param exclude_pattern Optional regex to drop indicators before aggregating (default `"gdp"`, `NULL` to keep all).
#'
#' @return A tibble with one row per country (static) or country-year (dynamic),
#' and one column per family named as \code{<family_var>_avg}, where <family_var> is the code for each institutional family.
#' @export
#' @importFrom dplyr group_by summarise left_join select across all_of
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom stringr str_detect regex
compute_family_average <- function(cliar_data,
                                   vars,
                                   type = c("static", "dynamic"),
                                   db_variables,
                                   require_complete = TRUE,
                                   exclude_pattern = "gdp") {
  type <- match.arg(type)

  cliar_long <- cliar_data |>
    tidyr::pivot_longer(cols = {{ vars }}, names_to = "variable", values_to = "value")

  if (!is.null(exclude_pattern)) {
    cliar_long <- cliar_long |>
      dplyr::filter(!stringr::str_detect(variable, stringr::regex(exclude_pattern, TRUE)))
  }

  cliar_long <- cliar_long |>
    dplyr::left_join(
      db_variables |> dplyr::select(variable, var_name, family_name, family_var),
      by = "variable"
    )

  grouping <- if (type == "static") c("country_code", "family_var") else c("country_code", "year", "family_var")
  id_cols  <- setdiff(grouping, "family_var")

  fam_long <- cliar_long |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping))) |>
    dplyr::summarise(
      value = if (require_complete && any(is.na(value))) NA_real_ else mean(value, na.rm = !require_complete),
      .groups = "drop"
    )

  fam_long |>
    tidyr::pivot_wider(
      id_cols = dplyr::all_of(id_cols),
      names_from = family_var,
      names_glue = "{family_var}_avg",
      values_from = value
    )
}


#' Compute family-level summary stats
#'
#' @description
#' Computes mean, variance, min, and max of indicators aggregated by family,
#' either cross-sectional (`static`) or panel (`dynamic`).
#'
#' @param cliar_data Data with `country_code`, optional `year`, and indicators.
#' @param vars Indicators to include (character or tidyselect).
#' @param type `"static"` (default) or `"dynamic"`.
#' @param db_variables Lookup with `variable`–`family_var` mapping.
#'
#' @return Wide tibble: one row per country (or country-year) with family stats
#'   (`*_avg`, `*_var`, `*_min`, `*_max`).
#'
#' @export
compute_family_variance <- function(cliar_data, vars, type = "static", db_variables){
  # this function generates family-level variances
  # default is static
  cliar_data_long <-
    cliar_data |>
    pivot_longer(
      all_of({{vars}}),
      names_to = "variable"
    ) |>
    select(-contains("gdp")) |>
    left_join(
      db_variables |>
        select(variable, var_name, family_name, family_var),
      by = "variable"
    )

  # only calculate family averages for relevant institutional clusters
  if(type == "static"){
    grouping <- c("country_code", "family_var")
    id_cols <- c("country_code")
  } else{
    grouping = c("country_code", "year", "family_var")
    id_cols <- c("country_code", "year")
  }

  cliar_family_level_long <- cliar_data_long |>
    group_by(
      across(all_of(grouping))
    ) |>
    summarise(
      # we only compute statistics if all indicators are available
      # there na.rm = FALSE
      avg = mean(value, na.rm = FALSE),
      var = var(value, na.rm = FALSE),
      min = min(value, na.rm = FALSE),
      max = max(value, na.rm = FALSE),
      .groups = "drop"
    )

  cliar_family_level <- cliar_family_level_long |>
    pivot_wider(
      id_cols = all_of(id_cols),
      names_from = family_var,
      names_glue = "{family_var}_{.value}",
      values_from = c(avg, var, min, max)
    )

  return(cliar_family_level)
}

#' Compute Closeness to Frontier (CTF)
#'
#' This is a function to compute the closeness to frontier (CTF) score for indicators.
#'
#' @param data Data frame containing `vars` and identifier columns in `id_cols`.
#' @param vars Character vector of variable names to transform.
#' @param min_max_tbl Data frame with columns `variable`, `min`, `max`.
#' @param id_cols Character vector of identifier columns (e.g., "country_code", "year").
#' @param zero_floor Numeric. Exact zeros are replaced with this value (default `0.01`). Use `NULL` to skip.
#' @param exclude_pattern Optional regex to drop variables after computation (e.g., `"^gdp"`).
#' @return Tibble in wide format keyed by `id_cols`.
#' @importFrom dplyr left_join mutate if_else select all_of any_of relocate
#' @importFrom tidyr pivot_longer pivot_wider
#' @export
compute_ctf <- function(data,
                        vars,
                        min_max_tbl,
                        id_cols,
                        zero_floor = 0.01,
                        exclude_pattern = NULL) {

  out <- data |>
    tidyr::pivot_longer(dplyr::all_of(vars), names_to = "variable", values_to = "value") |>
    dplyr::left_join(min_max_tbl, by = "variable") |>
    dplyr::mutate(
      ctf = (min - value) / (min - max),
      ctf = if (!is.null(zero_floor)) dplyr::if_else(!is.na(ctf) & ctf == 0, zero_floor, ctf) else ctf
    ) |>
    tidyr::pivot_wider(
      id_cols   = dplyr::all_of(id_cols),
      names_from = "variable",
      values_from = "ctf"
    )

  if (!is.null(exclude_pattern) && nzchar(exclude_pattern)) {
    drops <- setdiff(grep(exclude_pattern, names(out), value = TRUE), id_cols)
    if (length(drops)) out <- dplyr::select(out, -dplyr::any_of(drops))
  }

  dplyr::relocate(out, dplyr::all_of(id_cols))
}

