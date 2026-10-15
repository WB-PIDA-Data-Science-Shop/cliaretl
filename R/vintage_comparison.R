################################################################################
############### COMPARE TWO VINTAGES OF THE COMPILED INDICATORS ################
################################################################################

#' Statuses a compared cell can take, in reporting order
#'
#' The order here is the order statuses appear in every output table (it is
#' used as the factor levels of `status`).
#'
#' @noRd
vintage_statuses <- c(
  "Same", "Revised", "Dropped", "Added (backfilled)", "Added (new period)"
)

#' Compare two vintages of the compiled indicators panel
#'
#' @description
#' Answers the quality-control question *"how does the panel we are about to
#' publish differ from the one we already published?"*, value by value.
#'
#' The two vintages are matched on country, year and variable. Every such
#' **cell** that has a value in either vintage gets one **status**:
#'
#' - `"Same"`: the published value is unchanged, within `tolerance`.
#' - `"Revised"`: the published value changed by more than `tolerance`.
#' - `"Dropped"`: the published value is missing from the latest vintage.
#' - `"Added (backfilled)"`: a new value for a year the previous vintage already
#'   covered.
#' - `"Added (new period)"`: a new value for a year after the previous vintage's
#'   last year.
#'
#' Cells that are `"Same"`, `"Revised"` or `"Dropped"` are the **published
#' cells**: the values the previous vintage put on the dashboard. Shares such as
#' `pct_dropped` are computed over them. The counts are then rolled up per
#' variable, per data source and per institutional family. Write the result to
#' an Excel workbook and a Word summary with [write_vintage_comparison()].
#'
#' @details
#' **What is compared.** Only numeric columns present in both vintages, other
#' than the two key columns, are compared cell by cell. Text columns (e.g.
#' `country_name`, `region`) are ignored. Variables, countries and years present
#' in only one vintage are listed in `structure` instead, so a renamed variable
#' appears there as one variable removed and another added.
#'
#' **Tolerance rule.** A published cell counts as `"Same"` when
#' `abs(latest - previous) <= tolerance * max(abs(previous), 1)`. For values of
#' magnitude 1 or more this is a *relative* tolerance (0.1% of the old value by
#' default); below 1 it becomes an *absolute* one (a difference of at most
#' 0.001 by default), so indicators on a 0-1 scale are not held to an
#' impossibly tight standard.
#'
#' **Percentage change.** `pct_change` is `100 * (latest - previous) /
#' |previous|`. It is `NA` when the previous value was 0, since the relative
#' change is then undefined; in `cells` those rows are sorted ahead of all other
#' revisions.
#'
#' **Limits.** A `"Revised"` status says only that the number moved. It does not
#' say why (a source revision, a rescaling, or a processing change all look the
#' same). New period is decided by the year alone: a value for a year after the
#' previous vintage's last year counts as `"Added (new period)"` even for a
#' country that is new to the panel.
#'
#' **Errors.** Stops if either vintage lacks `country_col` or `year_col`, or has
#' more than one row for the same country-year pair.
#'
#' @param previous A data frame with one row per country-year: the vintage that
#'   is already published, e.g. from [load_vintage()].
#' @param latest A data frame with one row per country-year: the vintage about
#'   to be published, e.g. `readRDS("inst/extdata/compiled_indicators.rds")`.
#' @param country_col,year_col Character, the names of the country and year key
#'   columns. Default `"country_code"` and `"year"`, as in the compiled panel.
#' @param tolerance Non-negative number, default `0.001`. How much a published
#'   value may move and still count as `"Same"`; see Details. Raise it to ignore
#'   small revisions, set it to 0 to flag every difference.
#' @param metadata A variable metadata table with columns `variable`,
#'   `var_name`, `family_var`, `family_name` and `source`. Defaults to
#'   [db_variables]. It only labels variables (it does not filter them):
#'   family-average columns (`<family_var>_avg`) are labelled with their family,
#'   and variables not found in it get `NA` labels.
#' @param labels Named character vector with elements `previous` and `latest`,
#'   the names shown for the two vintages in every output. By default, a vintage
#'   loaded with [load_vintage()] is named after its git reference, date and
#'   commit (e.g. `"origin/main @ 2025-12-09 (9e2d4a2)"`), and any other is
#'   named `"Previous"` / `"Latest"`.
#' @param x A `vintage_comparison` object (for `print()`).
#' @param ... Unused; for compatibility with the `print()` generic.
#'
#' @return An object of class `vintage_comparison`: a list with
#'   \describe{
#'     \item{about}{Tibble, one row per setting: `item` and `value` (both
#'       character): run date, vintage labels, dimensions, year ranges, number
#'       of variables compared and the tolerance rule.}
#'     \item{summary}{Tibble, one row per status: `status` (factor), `n`
#'       (integer, number of cells) and `pct_of_published` (numeric, share of
#'       published cells in %; `NA` for the two added statuses).}
#'     \item{structure}{Tibble, one row per variable, country or year present
#'       in only one vintage: `type` (`"Variable"`, `"Country"` or `"Year"`),
#'       `change` (`"Only in <label>"`) and `value` (character).}
#'     \item{variables}{Tibble, one row per compared variable: `variable`,
#'       `var_name`, `family_name`, `source`; one integer count column per
#'       status, named after the status (e.g. `Revised`);
#'       `median_abs_pct_change` and `max_abs_change`
#'       (numeric, over revised cells only); `published` (integer); `pct_same`,
#'       `pct_revised`, `pct_dropped` (numeric, % of published); and `added`
#'       (integer, both added statuses). Sorted by `Dropped`, then `Revised`,
#'       largest first.}
#'     \item{by_source, by_family}{Tibbles, one row per `source` /
#'       `family_name`, with `variables` (number of variables) and the same
#'       count and share columns as `variables`.}
#'     \item{cells}{Tibble, one row per cell whose status is not `"Same"`:
#'       the key columns, `country_name` (if either vintage has it), `variable`,
#'       `var_name`, `status`, `previous` and `latest` values, `change`
#'       (`latest - previous`) and `pct_change` (in %). Sorted by status, then
#'       changes from a published 0 first, then by absolute percentage change,
#'       largest first.}
#'     \item{settings}{List with `tolerance`, `last_year` (the previous
#'       vintage's last year) and `labels`.}
#'   }
#'   Printing it shows the counts by status and the variables that lost the
#'   most published cells.
#'
#' @md
#' @family vintage comparison
#' @seealso [load_vintage()] to fetch a past vintage from git;
#'   [write_vintage_comparison()] to write the results to Excel and Word.
#'
#' @examples
#' # two tiny vintages: AAA's 2021 value is revised, BBB's 2020 value is
#' # dropped, and 2022 is a new year
#' previous <- data.frame(
#'   country_code = c("AAA", "AAA", "BBB"),
#'   year         = c(2020, 2021, 2020),
#'   score        = c(10, 20, 5)
#' )
#' latest <- data.frame(
#'   country_code = c("AAA", "AAA", "AAA", "BBB"),
#'   year         = c(2020, 2021, 2022, 2020),
#'   score        = c(10, 25, 30, NA)
#' )
#' metadata <- data.frame(
#'   variable = "score", var_name = "Score", family_var = "vars_x",
#'   family_name = "Family X", source = "Source X"
#' )
#'
#' comparison <- compare_vintages(previous, latest, metadata = metadata)
#' comparison           # counts: 1 same, 1 revised, 1 dropped, 1 new period
#' comparison$cells     # the three cells that are not "Same"
#'
#' @export
compare_vintages <- function(previous,
                             latest,
                             country_col = "country_code",
                             year_col    = "year",
                             tolerance   = 0.001,
                             metadata    = cliaretl::db_variables,
                             labels      = c(previous = vintage_label(previous, "Previous"),
                                             latest   = vintage_label(latest, "Latest"))) {
  # Check both vintages have the key columns and one row per country-year
  key_cols <- c(country_col, year_col)
  check_vintage(previous, key_cols, "previous")
  check_vintage(latest, key_cols, "latest")

  # Variables to compare: numeric columns present in both vintages. The last
  # year of the previous vintage separates backfilled from new-period additions
  numeric_vars <- function(df) {
    setdiff(names(df)[vapply(df, is.numeric, logical(1))], key_cols)
  }
  previous_vars <- numeric_vars(previous)
  latest_vars   <- numeric_vars(latest)
  common_vars   <- intersect(previous_vars, latest_vars)
  last_year     <- max(previous[[year_col]], na.rm = TRUE)

  # Reshape a vintage to one row per country-year-variable cell, keeping only
  # cells that have a value
  to_long <- function(df, values_to) {
    df |>
      dplyr::select(dplyr::all_of(c(key_cols, common_vars))) |>
      tidyr::pivot_longer(
        -dplyr::all_of(key_cols),
        names_to = "variable", values_to = values_to, values_drop_na = TRUE
      )
  }

  # Line up every cell valued in either vintage and give it a status. Rules are
  # checked top to bottom and the first match wins. (`.data$x` refers to column
  # x of the table being worked on.)
  cells <- dplyr::full_join(
    to_long(previous, "previous"),
    to_long(latest, "latest"),
    by = c(key_cols, "variable")
  ) |>
    dplyr::mutate(
      change     = .data$latest - .data$previous,
      pct_change = dplyr::if_else(.data$previous != 0, 100 * .data$change / abs(.data$previous), NA_real_),
      status     = dplyr::case_when(
        is.na(.data$latest) ~ "Dropped",
        is.na(.data$previous) & .data[[year_col]] > last_year ~ "Added (new period)",
        is.na(.data$previous) ~ "Added (backfilled)",
        abs(.data$change) <= tolerance * pmax(abs(.data$previous), 1) ~ "Same",
        TRUE ~ "Revised"
      ),
      status = factor(.data$status, levels = vintage_statuses)
    )

  # Name, family and source of each compared variable
  var_labels <- vintage_variable_labels(common_vars, metadata)

  # Per-variable table: cell counts by status, size of revisions, and shares
  # of published cells
  variables <- cells |>
    dplyr::count(.data$variable, .data$status, .drop = FALSE) |>
    tidyr::pivot_wider(names_from = "status", values_from = "n", values_fill = 0) |>
    dplyr::left_join(
      cells |>
        dplyr::filter(.data$status == "Revised") |>
        dplyr::summarise(
          median_abs_pct_change = stats::median(abs(.data$pct_change), na.rm = TRUE),
          max_abs_change        = max(abs(.data$change)),
          .by = "variable"
        ),
      by = "variable"
    ) |>
    dplyr::right_join(var_labels, by = "variable") |>
    # variables with no values in either vintage have no cells to count
    # (`\(x)` is shorthand for `function(x)`)
    dplyr::mutate(dplyr::across(dplyr::all_of(vintage_statuses), \(x) dplyr::coalesce(x, 0L))) |>
    add_vintage_shares() |>
    dplyr::relocate("variable", "var_name", "family_name", "source") |>
    dplyr::arrange(dplyr::desc(.data$Dropped), dplyr::desc(.data$Revised))

  # Total the per-variable counts by a grouping column (source or family)
  roll_up <- function(group) {
    variables |>
      dplyr::summarise(
        variables = dplyr::n(),
        dplyr::across(dplyr::all_of(vintage_statuses), sum),
        .by = dplyr::all_of(group)
      ) |>
      add_vintage_shares() |>
      dplyr::arrange(dplyr::desc(.data$Dropped), dplyr::desc(.data$Revised))
  }

  # Overall counts by status; shares only for the published statuses
  summary <- cells |>
    dplyr::count(.data$status, .drop = FALSE) |>
    dplyr::mutate(
      pct_of_published = dplyr::if_else(
        .data$status %in% c("Same", "Revised", "Dropped"),
        100 * .data$n / sum(.data$n[.data$status %in% c("Same", "Revised", "Dropped")]),
        NA_real_
      )
    )

  # Variables, countries and years found in only one vintage
  structure_tbl <- dplyr::bind_rows(
    vintage_diff("Variable", previous_vars, latest_vars, labels),
    vintage_diff("Country", previous[[country_col]], latest[[country_col]], labels),
    vintage_diff("Year", previous[[year_col]], latest[[year_col]], labels)
  )

  # Country names for the cell list, preferring the latest vintage's spelling
  country_names <- dplyr::bind_rows(
    latest |> dplyr::select(dplyr::any_of(c(country_col, "country_name"))),
    previous |> dplyr::select(dplyr::any_of(c(country_col, "country_name")))
  ) |>
    dplyr::distinct(.data[[country_col]], .keep_all = TRUE)

  # Cell list: everything that is not "Same", labelled and ordered for review
  cells_out <- cells |>
    dplyr::filter(.data$status != "Same") |>
    dplyr::left_join(country_names, by = country_col) |>
    dplyr::left_join(var_labels |> dplyr::select("variable", "var_name"), by = "variable") |>
    dplyr::select(
      dplyr::any_of(c(country_col, "country_name")), dplyr::all_of(year_col),
      "variable", "var_name", "status", "previous", "latest", "change", "pct_change"
    ) |>
    # largest relative changes first; changes from a published 0 have no
    # percentage (infinite) so they lead, ordered by absolute change
    dplyr::arrange(
      .data$status,
      dplyr::desc(is.na(.data$pct_change) & !is.na(.data$change) & .data$change != 0),
      dplyr::desc(abs(.data$pct_change)),
      dplyr::desc(abs(.data$change))
    )

  # Record of what was compared and how
  about <- tibble::tibble(
    item = c(
      "Run date", "Previous vintage", "Latest vintage",
      "Previous: rows x columns", "Latest: rows x columns",
      "Previous: years", "Latest: years",
      "Variables compared", "Tolerance"
    ),
    value = c(
      format(Sys.Date()), labels[["previous"]], labels[["latest"]],
      paste(nrow(previous), "x", ncol(previous)), paste(nrow(latest), "x", ncol(latest)),
      paste(range(previous[[year_col]]), collapse = "-"),
      paste(range(latest[[year_col]]), collapse = "-"),
      as.character(length(common_vars)),
      paste0("|latest - previous| <= ", tolerance, " x max(|previous|, 1)")
    )
  )

  # Bundle everything as a "vintage_comparison" object (the class lets
  # print() show a summary instead of the raw list)
  structure(
    list(
      about      = about,
      summary    = summary,
      structure  = structure_tbl,
      variables  = variables,
      by_source  = roll_up("source"),
      by_family  = roll_up("family_name"),
      cells      = cells_out,
      settings   = list(tolerance = tolerance, last_year = last_year, labels = labels)
    ),
    class = "vintage_comparison"
  )
}

#' @rdname compare_vintages
#' @export
print.vintage_comparison <- function(x, ...) {
  # Header naming the two vintages
  cat("<vintage_comparison>", x$settings$labels[["previous"]], "->", x$settings$labels[["latest"]], "\n\n")

  # One line per status: number of cells and, for published statuses, share
  s <- x$summary
  for (i in seq_len(nrow(s))) {
    pct <- if (is.na(s$pct_of_published[i])) "" else sprintf(" (%.1f%% of published)", s$pct_of_published[i])
    cat(sprintf("  %-20s %10s%s\n", s$status[i], format(s$n[i], big.mark = ","), pct))
  }

  # Count of structural changes, then the ten variables losing most cells
  cat("\nStructural changes:", nrow(x$structure), "\n")
  top <- utils::head(x$variables[x$variables$Dropped > 0, c("variable", "Dropped", "pct_dropped")], 10)
  if (nrow(top) > 0) {
    cat("\nVariables with the most dropped cells:\n")
    print(top, n = 10)
  }
  invisible(x)
}

#' Write a vintage comparison to an Excel workbook and a Word summary
#'
#' @description
#' Saves the result of [compare_vintages()] in two files that share a name:
#'
#' - an **Excel workbook** for working through the detail, with one sheet per
#'   table: About (settings and status definitions), Summary, Structure,
#'   Variables, By source, By family, and the cell lists Dropped, Revised and
#'   Added. Every sheet has a frozen, filterable header row. The Revised sheet
#'   is sorted from the largest percentage change to the smallest.
#' - a **Word summary** for sharing, rendered from
#'   `inst/report/vintage_comparison.Rmd`: an overview, structural changes,
#'   changes by source, the variables above `share_threshold` for dropped and
#'   for revised values, new observations by source, and status definitions.
#'
#' @details
#' **Size.** The Revised sheet lists every revised cell; with a full panel it
#' can hold several hundred thousand rows, making the workbook tens of
#' megabytes. Excel's limit is 1,048,576 rows per sheet.
#'
#' **Requirements.** Writing the workbook needs the openxlsx package; the Word
#' summary needs flextable and pandoc (bundled with RStudio and Quarto).
#'
#' **Errors.** Stops if `comparison` is not a `vintage_comparison`, if openxlsx
#' is not installed, or if the report template cannot be found. Existing files
#' with the same name are overwritten.
#'
#' @param comparison A `vintage_comparison` object from [compare_vintages()].
#' @param output_dir Character, the folder to write to; created if it does not
#'   exist. Default `"inst/qcheck/reports"`, relative to the working directory
#'   (the package root when working on cliaretl).
#' @param file_stem Character, the file name without extension, used for both
#'   files. Default `"vintage_comparison_<YYYYMMDD>"` with today's date, so
#'   running twice on the same day overwrites that day's files.
#' @param share_threshold Number, in %, default `5`. The Word summary lists the
#'   variables whose share of published cells dropped, or revised, exceeds it.
#'   Lower it to see more variables, raise it to shorten the summary.
#'
#' @return Invisibly, a named character vector with the full paths of the
#'   workbook (`xlsx`) and the summary (`docx`).
#'
#' @md
#' @family vintage comparison
#' @seealso [compare_vintages()] to produce `comparison`.
#'
#' @examplesIf requireNamespace("openxlsx", quietly = TRUE) && requireNamespace("flextable", quietly = TRUE) && rmarkdown::pandoc_available()
#' previous <- data.frame(country_code = "AAA", year = 2020:2021, score = c(10, 20))
#' latest   <- data.frame(country_code = "AAA", year = 2020:2022, score = c(10, 25, 30))
#' metadata <- data.frame(
#'   variable = "score", var_name = "Score", family_var = "vars_x",
#'   family_name = "Family X", source = "Source X"
#' )
#' comparison <- compare_vintages(previous, latest, metadata = metadata)
#'
#' # writes example.xlsx and example.docx to a temporary folder
#' paths <- write_vintage_comparison(comparison, output_dir = tempdir(), file_stem = "example")
#' basename(paths)
#'
#' @export
write_vintage_comparison <- function(comparison,
                                     output_dir      = file.path("inst", "qcheck", "reports"),
                                     file_stem       = paste0("vintage_comparison_", format(Sys.Date(), "%Y%m%d")),
                                     share_threshold = 5) {
  # Accept only the output of compare_vintages()
  if (!inherits(comparison, "vintage_comparison")) {
    stop("`comparison` must be the output of `compare_vintages()`.", call. = FALSE)
  }

  # Prepare the output folder and the two file paths
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir)
  xlsx_path <- file.path(output_dir, paste0(file_stem, ".xlsx"))
  docx_path <- file.path(output_dir, paste0(file_stem, ".docx"))

  # Excel workbook with the full detail
  write_vintage_workbook(comparison, xlsx_path)
  message("Workbook written to: ", xlsx_path)

  # Word summary, rendered from the report template shipped with the package
  template <- system.file("report", "vintage_comparison.Rmd", package = "cliaretl")
  if (template == "") {
    stop("Could not find the report template 'inst/report/vintage_comparison.Rmd'.", call. = FALSE)
  }
  rmarkdown::render(
    input             = template,
    output_format     = "word_document",
    output_file       = docx_path,
    intermediates_dir = tempdir(),
    params            = list(
      comparison      = comparison,
      share_threshold = share_threshold,
      workbook        = basename(xlsx_path)
    ),
    envir             = new.env(),
    quiet             = TRUE
  )
  message("Summary written to: ", docx_path)

  invisible(c(xlsx = xlsx_path, docx = docx_path))
}

# ---- helpers -------------------------------------------------------------------

#' Write the comparison tables to an Excel workbook
#'
#' One sheet per table, plus an About sheet that adds the status definitions
#' and a note on `pct_change`. Each sheet gets a bold, filterable header row
#' frozen at the top. Cell lists are split by status, dropping columns that are
#' always empty for that status (e.g. `latest` for dropped cells).
#'
#' @param comparison A `vintage_comparison` object.
#' @param path Character, the `.xlsx` file to write; overwritten if it exists.
#' @return `path`, invisibly. Side effect: writes the file. Stops if openxlsx is
#'   not installed.
#' @noRd
write_vintage_workbook <- function(comparison, path) {
  # openxlsx is only suggested, so check for it before use
  if (!requireNamespace("openxlsx", quietly = TRUE)) {
    stop("Package 'openxlsx' is needed to write the workbook.", call. = FALSE)
  }

  # Plain-language definitions shown on the About sheet
  status_definitions <- tibble::tibble(
    item  = paste("Status:", vintage_statuses),
    value = c(
      "Published value unchanged, within the tolerance.",
      "Published value changed by more than the tolerance.",
      "Published value is missing from the latest vintage.",
      "New value for a year the previous vintage already covered.",
      "New value for a year after the previous vintage's last year."
    )
  )
  notes <- tibble::tibble(
    item  = "Note: pct_change",
    value = paste(
      "Percentage change relative to the previous value. Blank when the previous",
      "value was 0; those rows are listed first in the Revised sheet."
    )
  )

  # Sheet name -> table, with the cell list split by status
  cells <- comparison$cells
  sheets <- list(
    About        = dplyr::bind_rows(comparison$about, status_definitions, notes),
    Summary      = comparison$summary,
    Structure    = comparison$structure,
    Variables    = comparison$variables,
    `By source`  = comparison$by_source,
    `By family`  = comparison$by_family,
    Dropped      = cells |> dplyr::filter(.data$status == "Dropped") |>
      dplyr::select(-"latest", -"change", -"pct_change"),
    Revised      = cells |> dplyr::filter(.data$status == "Revised"),
    Added        = cells |> dplyr::filter(grepl("^Added", .data$status)) |>
      dplyr::select(-"previous", -"change", -"pct_change")
  )

  # Write each sheet with a styled, frozen, filterable header; widths follow
  # the column-name length, within 12-60 characters
  wb <- openxlsx::createWorkbook()
  header_style <- openxlsx::createStyle(textDecoration = "bold", fgFill = "#DDE4EE", border = "bottom")
  for (sheet in names(sheets)) {
    df <- sheets[[sheet]] |> dplyr::mutate(dplyr::across(dplyr::where(is.factor), as.character))
    openxlsx::addWorksheet(wb, sheet)
    openxlsx::writeData(wb, sheet, df, headerStyle = header_style, withFilter = TRUE)
    openxlsx::freezePane(wb, sheet, firstRow = TRUE)
    openxlsx::setColWidths(wb, sheet, cols = seq_along(df), widths = pmin(pmax(nchar(names(df)) + 4, 12), 60))
  }

  # Wider columns for the About sheet's long text, then save
  openxlsx::setColWidths(wb, "About", cols = 1:2, widths = c(28, 90))
  openxlsx::saveWorkbook(wb, path, overwrite = TRUE)
  invisible(path)
}

#' Check that a vintage can be compared
#'
#' @param df The vintage (data frame).
#' @param key_cols Character, the country and year column names.
#' @param arg Character, the argument name to cite in errors (`"previous"` or
#'   `"latest"`).
#' @return `df`, invisibly. Stops if a key column is missing or a country-year
#'   pair appears more than once (the comparison matches cells on those keys,
#'   so duplicates would make the match ambiguous).
#' @noRd
check_vintage <- function(df, key_cols, arg) {
  # Both key columns must be present
  missing_cols <- setdiff(key_cols, names(df))
  if (length(missing_cols) > 0) {
    stop("`", arg, "` is missing key column(s): ", paste(missing_cols, collapse = ", "), call. = FALSE)
  }

  # Each country-year pair must appear only once
  if (anyDuplicated(df[key_cols]) > 0) {
    stop("`", arg, "` has duplicated ", paste(key_cols, collapse = "-"), " pairs.", call. = FALSE)
  }
  invisible(df)
}

#' Label variables with their name, family and source
#'
#' Indicators are looked up in `metadata` by `variable`. Family-average columns
#' have no row of their own there, so `<family_var>_avg` is labelled from the
#' family it averages, with source `"CLIAR family average"`.
#'
#' @param variables Character, the variable names to label.
#' @param metadata Metadata table with `variable`, `var_name`, `family_var`,
#'   `family_name` and `source`.
#' @return Tibble with one row per element of `variables`, in the same order:
#'   `variable`, `var_name`, `family_name`, `source`; `NA` labels where a
#'   variable is not found. If a name matched both lookups, the indicator row
#'   wins.
#' @noRd
vintage_variable_labels <- function(variables, metadata) {
  # Labels for indicators, straight from the metadata
  indicator_labels <- metadata |>
    dplyr::select("variable", "var_name", "family_name", "source")

  # Labels for family averages, built from each family in the metadata
  family_labels <- metadata |>
    dplyr::distinct(.data$family_var, .data$family_name) |>
    dplyr::filter(!is.na(.data$family_var)) |>
    dplyr::transmute(
      variable    = paste0(.data$family_var, "_avg"),
      var_name    = paste(.data$family_name, "(family average)"),
      .data$family_name,
      source      = "CLIAR family average"
    )

  # Attach labels to the requested variables, one row each
  tibble::tibble(variable = variables) |>
    dplyr::left_join(
      dplyr::bind_rows(indicator_labels, family_labels) |> dplyr::distinct(.data$variable, .keep_all = TRUE),
      by = "variable"
    )
}

#' Add published-cell totals and shares to a table of status counts
#'
#' @param df Data frame with one integer column per status (named as in
#'   `vintage_statuses`).
#' @return `df` with added columns `published` (`Same + Revised + Dropped`),
#'   `pct_same`, `pct_revised`, `pct_dropped` (% of `published`; `NA` when
#'   `published` is 0) and `added` (both added statuses).
#' @noRd
add_vintage_shares <- function(df) {
  # Published cells, the base for every share, and total additions
  df |>
    dplyr::mutate(
      published     = .data$Same + .data$Revised + .data$Dropped,
      pct_same      = 100 * .data$Same / .data$published,
      pct_revised   = 100 * .data$Revised / .data$published,
      pct_dropped   = 100 * .data$Dropped / .data$published,
      added         = .data$`Added (backfilled)` + .data$`Added (new period)`
    ) |>
    # a variable with no published cells gives 0/0 (NaN): report it as NA
    dplyr::mutate(dplyr::across(dplyr::starts_with("pct_"), \(x) dplyr::if_else(is.nan(x), NA_real_, x)))
}

#' List values found in only one of two vintages
#'
#' @param type Character, what is compared (`"Variable"`, `"Country"` or
#'   `"Year"`), copied into the `type` column.
#' @param previous,latest Vectors of values (names, codes or years) from each
#'   vintage; duplicates are fine.
#' @param labels Named character vector with `previous` and `latest` labels.
#' @return Tibble with `type`, `change` (`"Only in <label>"`) and `value`
#'   (character), values sorted within each side; zero rows if both match.
#' @noRd
vintage_diff <- function(type, previous, latest, labels) {
  # Values present on one side but not the other
  only_previous <- sort(setdiff(unique(previous), unique(latest)))
  only_latest   <- sort(setdiff(unique(latest), unique(previous)))

  # One row per such value, saying which vintage has it
  tibble::tibble(
    type   = type,
    change = c(
      rep(paste("Only in", labels[["previous"]]), length(only_previous)),
      rep(paste("Only in", labels[["latest"]]), length(only_latest))
    ),
    value  = as.character(c(only_previous, only_latest))
  )
}
