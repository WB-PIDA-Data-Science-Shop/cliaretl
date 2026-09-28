################################################################################
################ DATA REPORTS BY INSTITUTIONAL FAMILY ##########################
################################################################################

#' List the variables of an institutional family
#'
#' Returns the variables belonging to a given institutional family, along with
#' their names, definitions and sources, ordered by their rank within the family.
#'
#' @param family A character string with the institutional family name, as it
#'   appears in `metadata$family_name` (e.g., `"Political Institutions"`).
#' @param metadata A variable metadata table. Defaults to [db_variables].
#'
#' @return A tibble with columns `Variable`, `Name`, `Definition` and `Source`.
#'
#' @export
get_family_variables <- function(family, metadata = cliaretl::db_variables) {
  check_family(family, metadata)

  metadata |>
    dplyr::filter(.data$family_name == family, .data$var_level == "indicator") |>
    dplyr::arrange(.data$rank_id) |>
    dplyr::select(
      Variable   = "variable",
      Name       = "var_name",
      Definition = "description",
      Source     = "source"
    )
}

#' Compute coverage for the indicators of an institutional family
#'
#' Subsets an indicator panel to the variables of a given institutional family
#' and computes their coverage with [compute_coverage()].
#'
#' @inheritParams get_family_variables
#' @inheritParams compute_coverage
#' @param data A country-year panel with one column per indicator.
#'
#' @return The [compute_coverage()] table for the family's indicators, with an
#'   additional `Name` column, ordered as in [get_family_variables()].
#'
#' @export
compute_family_coverage <- function(data,
                                    family,
                                    country_id,
                                    year_id,
                                    ref_year,
                                    country_region_list = NULL,
                                    metadata            = cliaretl::db_variables,
                                    consolidate         = FALSE) {
  family_variables <- get_family_variables(family, metadata)

  missing_variables <- setdiff(family_variables$Variable, colnames(data))
  if (length(missing_variables) > 0) {
    warning(
      "Dropping ", length(missing_variables), " '", family,
      "' variable(s) not found in `data`: ",
      paste(missing_variables, collapse = ", "),
      call. = FALSE
    )
  }
  family_variables <- family_variables |>
    dplyr::filter(.data$Variable %in% colnames(data))

  data |>
    dplyr::select(
      {{ country_id }},
      {{ year_id }},
      dplyr::all_of(family_variables$Variable)
    ) |>
    compute_coverage(
      country_id          = {{ country_id }},
      year_id             = {{ year_id }},
      ref_year            = ref_year,
      country_region_list = country_region_list,
      consolidate         = consolidate
    ) |>
    dplyr::left_join(
      family_variables |> dplyr::select("Variable", "Name"),
      by = c("Indicator" = "Variable")
    ) |>
    dplyr::relocate("Name", .after = "Indicator") |>
    dplyr::arrange(match(.data$Indicator, family_variables$Variable))
}

list_family_names <- function() {
  dplyr::arrange(
    cliaretl::family_order, dplyr::desc(.data$family_order)
  ) |>
    dplyr::pull("family_name")
}

#' Generate data coverage reports by institutional family
#'
#' Renders one HTML or Word report per institutional family. Each report has two
#' sections: (1) the family's variables, with their definitions and sources
#' (see [get_family_variables()]); and (2) the coverage table produced by
#' [compute_coverage()] for those variables (see [compute_family_coverage()]).
#'
#' @inheritParams compute_family_coverage
#' @param data A country-year panel with one column per indicator. Defaults to
#'   the compiled indicators panel shipped in `inst/extdata`.
#' @param families A character vector of institutional family names. Defaults
#'   to all families in [family_order], in their dashboard order.
#' @param ref_year Reference year passed to [compute_coverage()]. Defaults to
#'   the `ref_year` attribute of `metadata`.
#' @param country_region_list A data frame with columns `country_code` and
#'   `region`. Defaults to [wb_income_and_region].
#' @param output_dir Directory in which to write the reports.
#' @param output_type Format of the reports: `"html"` (default) or `"docx"`.
#'   Also passed to the report template as `params$output_type`.
#'
#' @return Invisibly, a named character vector with the path to each report.
#'
#' @examples
#' \dontrun{
#' generate_data_report(families = "Political Institutions")
#' generate_data_report(families = "Political Institutions", output_type = "docx")
#' }
#'
#' @export
generate_data_report <- function(data                = readRDS(system.file("extdata", "compiled_indicators.rds", package = "cliaretl")),
                                 families            = list_family_names(),
                                 country_id          = country_code,
                                 year_id             = year,
                                 ref_year            = attr(metadata, "ref_year"),
                                 country_region_list = cliaretl::wb_income_and_region,
                                 metadata            = cliaretl::db_variables,
                                 output_dir          = tempdir(),
                                 output_type         = c("docx", "html")) {
  output_type   <- match.arg(output_type)
  output_format <- switch(output_type, html = "html_document", docx = "word_document")

  template <- system.file("report", "data_report.Rmd", package = "cliaretl")
  if (template == "") {
    stop("Could not find the report template 'inst/report/data_report.Rmd'.", call. = FALSE)
  }

  for (family in families) check_family(family, metadata)

  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

  report_paths <- purrr::map_chr(families, function(family) {
    output_file <- file.path(
      normalizePath(output_dir),
      paste0("data_report_", janitor::make_clean_names(family), ".", output_type)
    )

    rmarkdown::render(
      input             = template,
      output_format     = output_format,
      output_file       = output_file,
      intermediates_dir = tempdir(),
      params            = list(
        family         = family,
        ref_year       = ref_year,
        output_type    = output_type,
        variables      = get_family_variables(family, metadata),
        coverage       = compute_family_coverage(
          data                = data,
          family              = family,
          country_id          = {{ country_id }},
          year_id             = {{ year_id }},
          ref_year            = ref_year,
          country_region_list = country_region_list,
          metadata            = metadata,
          consolidate         = TRUE
        )
      ),
      envir             = new.env(),
      quiet             = TRUE
    )

    message("Report for '", family, "' generated at: ", output_file)
    output_file
  })

  invisible(stats::setNames(report_paths, families))
}

# stop early with the list of valid families when a family name is misspelled
check_family <- function(family, metadata) {
  valid_families <- unique(metadata$family_name[!is.na(metadata$family_name)])

  if (!is.character(family) || length(family) != 1 || !family %in% valid_families) {
    stop(
      "`family` must be one of: ",
      paste0("'", sort(valid_families), "'", collapse = ", "),
      call. = FALSE
    )
  }

  invisible(family)
}
