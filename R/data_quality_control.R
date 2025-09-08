#' Validate that values are not outliers using the IQR rule
#'
#' A custom validation function for use with \pkg{pointblank}.
#' Flags values as failures if they lie outside the interval
#' `[Q1 - 1.5*IQR, Q3 + 1.5*IQR]`.
#' Missing values are treated as passing by default.
#'
#' @param x A numeric vector.
#'
#' @return A logical vector of the same length as `x`, where `TRUE`
#'   indicates that the row passes the check.
#'
#' @examples
#' library(pointblank)
#' df <- data.frame(x = c(rnorm(95), 50, -40, NA))
#' create_agent(df) |>
#'   col_vals_expr(vars(x), expr = col_vals_no_outliers(x)) |>
#'   interrogate()
#'
#' @importFrom stats quantile
#' @export
col_vals_no_outliers <- function(x) {
  q1 <- stats::quantile(x, 0.25, na.rm = TRUE)
  q3 <- stats::quantile(x, 0.75, na.rm = TRUE)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr
  upper <- q3 + 1.5 * iqr
  (x >= lower & x <= upper) | is.na(x)
}

#' Validate that missing values are below a threshold
#'
#' A custom validation function for use with \pkg{pointblank}.
#' Flags the column as failing if the proportion of missing values
#' exceeds the given threshold. The same logical result is returned
#' for all rows.
#'
#' @param x A vector.
#' @param threshold Numeric value in `[0,1]` giving the maximum allowed
#'   proportion of missing values. Defaults to `0.1` (10%).
#'
#' @return A logical vector of the same length as `x`, where `TRUE`
#'   indicates the column-wide missing rate is below the threshold.
#'
#' @examples
#' library(pointblank)
#' df <- data.frame(x = c(1:9, NA))
#' create_agent(df) |>
#'   col_vals_expr(vars(x), expr = col_vals_missing_below(x, threshold = 0.05)) |>
#'   interrogate()
#'
#' @export
col_vals_missing_below <- function(x, threshold = 0.1) {
  missing_rate <- mean(is.na(x))
  rep(missing_rate <= threshold, length(x))
}

#' Validate that a variable is discrete with limited unique values
#'
#' A custom validation function for use with \pkg{pointblank}.
#' Flags the column as failing if the number of unique (non-missing)
#' values exceeds a specified maximum.
#'
#' @param x A vector.
#' @param max_unique Integer giving the maximum allowed number of
#'   unique values (excluding `NA`). Defaults to `10`.
#'
#' @return A logical vector of the same length as `x`, where `TRUE`
#'   indicates the column's cardinality is at or below the threshold.
#'
#' @examples
#' library(pointblank)
#' df <- data.frame(z = sample(c("A", "B", "C"), 20, replace = TRUE))
#' create_agent(df) |>
#'   col_vals_expr(vars(z), expr = col_vals_discrete(z, max_unique = 5)) |>
#'   interrogate()
#'
#' @importFrom dplyr n_distinct
#' @export
col_vals_discrete <- function(x, max_unique = 10) {
  n_unique <- dplyr::n_distinct(x, na.rm = TRUE)
  rep(n_unique <= max_unique, length(x))
}

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
#'
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
