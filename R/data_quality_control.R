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
