#' Coefficient of Variation
#'
#' Computes the coefficient of variation (CV), defined as the ratio of the
#' standard deviation to the mean. This is a scale-free measure of dispersion
#' that allows comparison of variability between datasets with different units
#' or magnitudes.
#'
#' @param x A numeric vector of values.
#' @param na.rm Logical; if \code{TRUE}, missing values are removed before
#'   computation. Defaults to \code{FALSE}.
#' @importFrom stats sd
#' @return A single numeric value representing the coefficient of variation.
#'
#' @details The coefficient of variation is computed as
#' \deqn{CV = \frac{sd(x)}{mean(x)}}{CV = sd(x) / mean(x)}.
#' If \code{mean(x)} is zero or very close to zero, the result may be
#' undefined or unstable.
#'
#' @examples
#' x <- c(10, 12, 9, 11, 13)
#' cv(x)
#' cv(x, na.rm = TRUE)
#'
#' @seealso \code{\link[stats]{sd}}, \code{\link[base]{mean}}
#'
#' @export
cv <- function(x, na.rm = FALSE) {
  sd(x, na.rm = na.rm) / mean(x, na.rm = na.rm)
}


#' Check a Dataset's Conformity Against db_variables and wb_country_list
#'
#' Runs a set of lightweight console diagnostics on a dataset before it is
#' folded into the CLIAR pipeline:
#' \itemize{
#'   \item Flags variables in \code{.data} that are not documented in
#'   \code{db_variables$variable}.
#'   \item Uses \code{.data}'s own object name to look it up in
#'   \code{db_variables$etl_source}, and flags variables expected for that
#'   source that are missing from \code{.data}.
#'   \item Checks that \code{.data} has both \code{country_code} and
#'   \code{year} columns.
#'   \item Flags any \code{country_code} values in \code{.data} that are not
#'   in \code{unique(wb_country_list$country_code)}.
#' }
#'
#' @param .data A data frame to check. Because the expected-variable check
#'   looks \code{.data}'s object name up in \code{db_variables$etl_source},
#'   \code{.data} should be passed by its lazy-loaded object name (i.e. the
#'   name referenced in \code{db_variables$etl_source}) for that check to
#'   run; otherwise it is skipped with a message.
#'
#' @return Invisibly, a named list with the results of each check:
#'   \code{extra_variables}, \code{missing_variables},
#'   \code{missing_id_columns}, and \code{invalid_country_codes}.
#'
#' @export
check_db_conformity <- function(.data) {
  data_name <- deparse(substitute(.data))
  all_clear <- TRUE

  ## ---- variables in .data not documented in db_variables ----
  data_vars <- setdiff(names(.data), c("country_code", "country_name", "year"))
  extra_vars <- setdiff(data_vars, db_variables$variable)

  if (length(extra_vars) > 0) {
    all_clear <- FALSE
    message(glue::glue(
      "Variables in `{data_name}` not found in `db_variables$variable`: ",
      "{paste(paste0('`', extra_vars, '`'), collapse = ', ')}"
    ))
  } else {
    message(glue::glue(
      "No variables in `{data_name}` are missing from `db_variables$variable`."
    ))
  }
  message("")

  ## ---- variables expected for this etl_source but missing from .data ----
  known_sources <- unique(db_variables$etl_source)
  missing_vars <- character(0)

  if (!data_name %in% known_sources) {
    all_clear <- FALSE
    message(glue::glue(
      "`{data_name}` does not match any `db_variables$etl_source` value, ",
      "so expected-variable coverage could not be checked. Make sure `.data` ",
      "is passed by its lazy-load name (matching `etl_source`)."
    ))
  } else {
    expected_vars <-
      db_variables |>
      dplyr::filter(etl_source == data_name) |>
      dplyr::pull(variable)

    missing_vars <- setdiff(expected_vars, names(.data))

    if (length(missing_vars) > 0) {
      all_clear <- FALSE
      message(glue::glue(
        "Variables expected for etl_source `{data_name}` but missing from ",
        "`{data_name}`: {paste(paste0('`', missing_vars, '`'), collapse = ', ')}"
      ))
    } else {
      message(glue::glue(
        "No variables expected for etl_source `{data_name}` are missing ",
        "from `{data_name}`."
      ))
    }
  }
  message("")

  ## ---- required identifier columns ----
  missing_id_cols <- setdiff(c("country_code", "year"), names(.data))

  if (length(missing_id_cols) > 0) {
    all_clear <- FALSE
    message(glue::glue(
      "`{data_name}` is missing required column(s): ",
      "{paste(paste0('`', missing_id_cols, '`'), collapse = ', ')}"
    ))
  } else {
    message(glue::glue(
      "`{data_name}` contains both required `country_code` and `year` columns."
    ))
  }
  message("")

  ## ---- country_code values not in wb_country_list ----
  invalid_countries <- character(0)

  if ("country_code" %in% missing_id_cols) {
    all_clear <- FALSE
    message(glue::glue(
      "Skipping country_code validity check because `{data_name}` has no ",
      "`country_code` column."
    ))
  } else {
    invalid_countries <- setdiff(unique(.data$country_code), unique(wb_country_list$country_code))

    if (length(invalid_countries) > 0) {
      all_clear <- FALSE
      message(glue::glue(
        "`{data_name}$country_code` contains value(s) not found in ",
        "`wb_country_list$country_code`: ",
        "{paste(paste0('`', invalid_countries, '`'), collapse = ', ')}"
      ))
    } else {
      message(glue::glue(
        "All `{data_name}$country_code` values are valid World Bank country codes."
      ))
    }
  }

  ## ---- final verdict ----
  if (all_clear) {
    message("")
    message(glue::glue(
      "\033[32m✔\033[39m `{data_name}` passed all checks and is verified for CTF computation."
    ))
  }
}





