utils::globalVariables(c(
  "var_level",
  "family_var",
  "benchmarked_ctf",
  "benchmark_dynamic_indicator",
  "benchmark_dynamic_family_aggregate",
  "benchmark_static_family_aggregate_download",
  "family_name"
))



#' Generate Variable Lists from Database Variables
#'
#' This function creates a comprehensive list of variable groupings based on
#' institutional families, benchmarking criteria, and other categories from
#' the CLIAR database variables metadata.
#'
#' @param db_variables A data frame containing variable metadata with the following required columns:
#'   \itemize{
#'     \item \code{var_level}: Variable level (should contain "indicator")
#'     \item \code{family_var}: Variable family grouping
#'     \item \code{variable}: Variable names/codes
#'     \item \code{family_name}: Human-readable family names
#'     \item \code{benchmarked_ctf}: Static benchmarking flag ("Yes"/"No")
#'     \item \code{benchmark_dynamic_indicator}: Dynamic indicator benchmarking flag
#'     \item \code{benchmark_dynamic_family_aggregate}: Dynamic family aggregation flag
#'     \item \code{benchmark_static_family_aggregate_download}: Static family download flag
#'   }
#'
#' @return A named list containing the following variable groupings:
#' \describe{
#'   \item{vars_anticorruption}{Anti-corruption institution indicators}
#'   \item{vars_mkt}{Business environment and trade institution indicators}
#'   \item{vars_climate}{Climate change and environment institution indicators}
#'   \item{vars_digital}{Digital and data institution indicators}
#'   \item{vars_fin}{Financial market institution indicators}
#'   \item{vars_lab}{Labor market institution indicators}
#'   \item{vars_leg}{Justice institution indicators}
#'   \item{vars_pol}{Political institution indicators}
#'   \item{vars_hrm}{Public human resource management institution indicators}
#'   \item{vars_pfm}{Public financial management institution indicators}
#'   \item{vars_social}{Social institution indicators}
#'   \item{vars_service_del}{SOE corporate governance indicators}
#'   \item{vars_service_delivery}{Service delivery institution indicators}
#'   \item{vars_transp}{Transparency and accountability institution indicators}
#'   \item{vars_other}{Variables with other family classifications}
#'   \item{vars_removed}{Removed variables}
#'   \item{vars_missing}{Variables with missing family classifications}
#'   \item{vars_all}{All indicator-level variables}
#'   \item{vars_family}{Unique family variable names}
#'   \item{vars_static_ctf}{Variables with static benchmarking}
#'   \item{vars_dynamic_ctf}{Variables with dynamic indicator benchmarking}
#'   \item{vars_dynamic_partial_ctf}{Variables with partial dynamic family benchmarking}
#'   \item{vars_static_family_ctf}{Variables with static family aggregate downloads}
#'   \item{vars_dynamic_family_ctf}{Variables with dynamic family aggregation}
#'   \item{family_names}{Data frame mapping family variables to readable names}
#' }
#'
#' @details
#' This function efficiently organizes the CLIAR database variables into logical
#' groupings for analysis and reporting. It filters variables by institutional
#' families (anti-corruption, market, climate, etc.) and benchmarking criteria.
#'
#' The function uses a helper function to reduce code duplication when extracting
#' variables by family type. All variables are filtered to include only
#' indicator-level variables (\code{var_level == "indicator"}).
#'
#' @examples
#' \dontrun{
#' # Load database variables
#' db_variables <- read_rds("path/to/db_variables.rds")
#'
#' # Generate all variable lists
#' var_lists <- get_variable_lists(db_variables)
#'
#' # Access specific variable groups
#' anticorruption_vars <- var_lists$vars_anticorruption
#' all_variables <- var_lists$vars_all
#'
#' # Use with dplyr operations
#' selected_data <- my_data |>
#'   select(country_code, year, all_of(var_lists$vars_fin))
#' }
#'
#' @importFrom dplyr filter pull transmute
#'
#' @export
get_variable_lists <- function(db_variables) {
  # Helper function to extract variables by family
  extract_vars <- function(family) {
    db_variables |>
      filter(
        var_level == "indicator",
        family_var == family
      ) |>
      pull(variable)
  }

  # Create all variable lists
  list(
    # Institutional families
    vars_anticorruption = extract_vars("vars_anticorruption"),
    vars_mkt = extract_vars("vars_mkt"),
    vars_climate = extract_vars("vars_climate"),
    vars_digital = extract_vars("vars_digital"),
    vars_fin = extract_vars("vars_fin"),
    vars_lab = extract_vars("vars_lab"),
    vars_leg = extract_vars("vars_leg"),
    vars_pol = extract_vars("vars_pol"),
    vars_hrm = extract_vars("vars_hrm"),
    vars_pfm = extract_vars("vars_pfm"),
    vars_social = extract_vars("vars_social"),
    vars_service_del = extract_vars("vars_service_del"),
    vars_service_delivery = extract_vars("vars_service_delivery"),
    vars_transp = extract_vars("vars_transp"),

    # Special categories
    vars_other = extract_vars("vars_other"),
    vars_removed = extract_vars("vars_removed"),
    vars_missing = extract_vars("vars_missing"),

    # All variables
    vars_all = db_variables |>
      filter(var_level == "indicator") |>
      pull(variable),

    # Family variables
    vars_family = db_variables |>
      filter(family_var != "vars_other") |>
      pull(family_var) |>
      unique(),

    # Benchmarked variables
    vars_static_ctf = db_variables |>
      filter(benchmarked_ctf == "Yes") |>
      pull(variable),

    vars_dynamic_ctf = db_variables |>
      filter(benchmark_dynamic_indicator == "Yes") |>
      pull(variable),

    vars_dynamic_partial_ctf = db_variables |>
      filter(benchmark_dynamic_family_aggregate == "Partial") |>
      pull(variable),

    vars_static_family_ctf = db_variables |>
      filter(benchmark_static_family_aggregate_download == "Yes") |>
      pull(variable),

    vars_dynamic_family_ctf = db_variables |>
      filter(benchmark_dynamic_family_aggregate == "Yes") |>
      pull(variable),

    # Family names
    family_names = db_variables |>
      filter(
        family_var != "vars_other" &
          family_var != "vars_missing"
      ) |>
      transmute(
        variable = family_var,
        var_name = family_name
      ) |>
      unique()
  )
}

