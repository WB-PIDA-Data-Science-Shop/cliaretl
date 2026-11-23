################################################################################
############## MAP DICTIONARY VARIABLES TO THEIR LAZYLOADED DATASET ############
################################################################################

# Why this file exists -------------------------------------------------------
# `etl_source` in `db_variables` used to be typed by hand, so its labels drifted
# away from the actual datasets in `data/` (e.g. "wb_api" for variables that
# live in `d360_efi_data` or `wjp`). The functions below derive `etl_source`
# from the data itself: a variable's source is simply the lazyloaded dataset
# whose columns contain it. See GitHub issue #108.

#' Lazyloaded objects that are not extraction sources
#'
#' Pipeline outputs (the dictionary itself, CTF results) and reference tables
#' (country lists, FCV classification). They are skipped when mapping
#' `etl_source`, because they either repeat the source variables or hold none.
#'
#' @return A character vector of object names in `data/`.
#' @noRd
lazyload_exclusions <- function() {
  c(
    # CTF outputs: built from the compiled panel, so they contain the same
    # indicator columns as the source datasets. Including them would make
    # almost every variable look like it belongs to two datasets.
    "closeness_to_frontier_static", "closeness_to_frontier_dynamic",
    # The dictionary objects themselves: outputs of 01-extraction.R, not data.
    "db_variables", "db_variables_final", "family_order",
    # Reference tables: country lists and FCV classification. They hold no
    # indicators, so they would never match anyway, but are listed explicitly
    # so it is clear they are not extraction sources.
    "wb_country_list", "wb_country_groups", "wb_income_and_region", "fcv"
  )
}

#' Read the lazyloaded source datasets in a package data directory
#'
#' @description
#' Loads every `.rda` file in `data_dir` into a named list, so scripts can
#' loop over all extraction sources without keeping a hand-written list of
#' dataset names. A new source is picked up as soon as its `.rda` is saved.
#'
#' Reads the files on disk rather than the installed package, so it reflects
#' the latest `usethis::use_data()` output even before the package is
#' reinstalled.
#'
#' @param data_dir Path to the directory holding the `.rda` files, typically
#'   `here::here("data")`.
#' @param exclude Character vector of object names to skip. Defaults to
#'   pipeline outputs and reference tables that are not extraction sources:
#'   the CTF results, the dictionary objects, `family_order`, the country
#'   lists and `fcv`.
#'
#' @return A named list of data frames, one per `.rda` file, named by the
#'   file name without extension (e.g. `wdi_indicators`). Files holding
#'   anything other than a data frame are dropped.
#'
#' @seealso [map_lazyload_data()], which uses this list to assign
#'   `etl_source`.
#'
#' @examples
#' dir <- tempfile()
#' dir.create(dir)
#' wdi_indicators <- tibble::tibble(country_code = "KEN", year = 2020, wdi_a = 1)
#' save(wdi_indicators, file = file.path(dir, "wdi_indicators.rda"))
#' names(read_lazyloads(dir))
#'
#' @export
read_lazyloads <- function(data_dir, exclude = lazyload_exclusions()) {
  # Name each file path by its file name without extension (e.g.
  # "data/wdi_indicators.rda" -> "wdi_indicators"). That name becomes the
  # `etl_source` value, so it matches what users call via cliaretl::<name>.
  files <- list.files(data_dir, pattern = "[.]rda$", full.names = TRUE)
  names(files) <- tools::file_path_sans_ext(basename(files))

  # Drop excluded objects before loading, so the large CTF outputs are never
  # read into memory.
  files <- files[!names(files) %in% exclude]

  purrr::map(files, function(file) {
    # load() writes into an environment and returns the names of the objects
    # it created. use_data() saves one object per file, so take the first.
    # A fresh environment per file keeps objects from overwriting each other.
    env <- new.env()
    get(load(file, envir = env)[[1]], envir = env)
  }) |>
    # Only data frames have indicator columns; skip anything else.
    purrr::keep(is.data.frame)
}

#' Assign each dictionary variable the lazyloaded dataset that holds it
#'
#' @description
#' Rebuilds the `etl_source` column of the variable dictionary from the data
#' itself: each variable's `etl_source` becomes the name of the lazyloaded
#' dataset (`data/*.rda`) whose columns include it. This replaces hand-typed
#' source labels, so `etl_source` always matches the dataset names one-to-one.
#'
#' The dictionary is the source of truth: dataset columns that are not in the
#' dictionary are ignored, and dictionary variables found in no dataset are
#' kept with `etl_source = NA` and reported in a warning.
#'
#' @param dictionary A data frame with a unique `variable` column, typically
#'   `db_variables`. An existing `etl_source` column is replaced.
#' @param data_dir Path to the package data directory. Only used to build the
#'   default `lazyloads`.
#' @param lazyloads A named list of data frames to map against. Defaults to
#'   every `.rda` file in `data_dir` except those in `exclude`.
#' @param exclude Character vector of dataset names to skip: pipeline outputs
#'   and reference tables that are not extraction sources. Defaults to the
#'   CTF results, the dictionary objects, `family_order`, the country lists
#'   and `fcv`.
#'
#' @return `dictionary` with `etl_source` (character) as its last column.
#'   Rows and their order are unchanged.
#'
#' @section Conditions:
#' * Errors with class `cliaretl_error_ambiguous_etl_source` if a dictionary
#'   variable is a column of more than one dataset.
#' * Warns with class `cliaretl_warning_unmapped_variables` if any dictionary
#'   variable is a column of no dataset, listing them.
#'
#' @examples
#' dictionary <- tibble::tibble(variable = c("wdi_a", "vdem_b"))
#' lazyloads <- list(
#'   wdi_indicators = tibble::tibble(country_code = "KEN", year = 2020, wdi_a = 1),
#'   vdem_data = tibble::tibble(country_code = "KEN", year = 2020, vdem_b = 2)
#' )
#' map_lazyload_data(dictionary, lazyloads = lazyloads)
#'
#' @export
map_lazyload_data <- function(dictionary,
                              data_dir = "data",
                              lazyloads = read_lazyloads(data_dir, exclude),
                              exclude = lazyload_exclusions()) {
  stopifnot(is.data.frame(dictionary), "variable" %in% names(dictionary))

  # Apply the exclusions here too, not only in read_lazyloads(): callers who
  # pass their own `lazyloads` list (e.g. tests, or a future targets pipeline)
  # get the same filtering.
  lazyloads <- lazyloads[!names(lazyloads) %in% exclude]

  # Step 1: build `lazyload_tbl`, a long table with one row per dataset
  # column: `etl_source` (dataset name) and `variable` (column name). It has
  # the same column names as db_variables so it can be joined directly.
  lazyload_tbl <- purrr::imap(
    lazyloads,
    \(df, name) tibble::tibble(etl_source = name, variable = names(df))
  ) |>
    purrr::list_rbind() |>
    # Keep only the columns the dictionary knows about. This drops ID columns
    # (country_code, year, ...) and indicators that were extracted but are not
    # in db_variables -- the dictionary is the source of truth.
    dplyr::filter(.data$variable %in% dictionary$variable)

  # Check: each dictionary variable must live in exactly one dataset. If one
  # appears in two, there is no single correct `etl_source`, and the join
  # below would duplicate that dictionary row. Stop and name the datasets
  # involved so the overlap can be fixed at the extraction step.
  ambiguous <- lazyload_tbl |>
    dplyr::filter(dplyr::n() > 1, .by = "variable")

  if (nrow(ambiguous) > 0) {
    # One bullet per variable, e.g. "x wdi_a: wdi_indicators, d360_efi_data".
    sources <- split(ambiguous$etl_source, ambiguous$variable)
    rlang::abort(
      c(
        "Some dictionary variables are columns of more than one dataset.",
        rlang::set_names(
          paste0(names(sources), ": ", purrr::map_chr(sources, paste, collapse = ", ")),
          "x"
        )
      ),
      class = "cliaretl_error_ambiguous_etl_source"
    )
  }

  # Step 2: attach the new `etl_source` to the dictionary.
  # - Remove the old hand-typed column first, so the joined one replaces it
  #   (it is the last column of db_variables, so column order is unchanged).
  # - left_join keeps every dictionary row, even variables with no dataset.
  #   An inner join would silently delete them.
  # - relationship = "one-to-one" makes dplyr error if a variable is ever
  #   repeated on either side: a last guard against duplicated rows.
  mapped <- dictionary |>
    dplyr::select(-dplyr::any_of("etl_source")) |>
    dplyr::left_join(lazyload_tbl, by = "variable", relationship = "one-to-one")

  # Report dictionary variables that no dataset provides. They are kept with
  # etl_source = NA. Usually they are read straight from a file elsewhere in
  # the pipeline (e.g. the provisional RISE indicators in
  # 02-compiled_indicators_panel.R) or have been dropped by a source.
  unmapped <- mapped$variable[is.na(mapped$etl_source)]

  if (length(unmapped) > 0) {
    rlang::warn(
      c(
        paste0(length(unmapped), " dictionary variable(s) are not in any lazyloaded dataset:"),
        rlang::set_names(unmapped, "!")
      ),
      class = "cliaretl_warning_unmapped_variables"
    )
  }

  # Summary line, so each run of 01-extraction.R shows how many datasets feed
  # db_variables and how much of the dictionary they cover.
  rlang::inform(paste0(
    "Mapped ", nrow(mapped) - length(unmapped), " of ", nrow(mapped),
    " variables to ", dplyr::n_distinct(mapped$etl_source, na.rm = TRUE),
    " lazyloaded datasets."
  ))

  mapped
}
