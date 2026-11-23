# Fixtures -------------------------------------------------------------------
# A miniature `data/`: three datasets shaped like real lazyloads (ID columns
# plus indicator columns).
# - wdi_indicators holds two dictionary variables
# - vdem_data holds one
# - budget_execution holds a column the dictionary does not know about, to
#   check that extra extracted indicators are ignored
make_lazyloads <- function() {
  list(
    wdi_indicators = tibble::tibble(
      country_code = "KEN", year = 2020, wdi_a = 1, wdi_b = 2
    ),
    vdem_data = tibble::tibble(country_code = "KEN", year = 2020, vdem_c = 3),
    budget_execution = tibble::tibble(country_code = "KEN", year = 2020, not_in_dict = 4)
  )
}

# A miniature `db_variables`. Its `etl_source` values are deliberately
# wrong/stale ("wdi", "wb_api", "vdem"), as in the hand-typed dictionary, so
# the tests can confirm they are replaced rather than kept.
make_dictionary <- function() {
  tibble::tibble(
    variable = c("wdi_a", "wdi_b", "vdem_c"),
    var_name = c("A", "B", "C"),
    etl_source = c("wdi", "wb_api", "vdem")
  )
}

test_that("etl_source is replaced by the name of the dataset holding each variable", {
  out <- map_lazyload_data(make_dictionary(), lazyloads = make_lazyloads()) |>
    suppressMessages()

  expect_equal(out$etl_source, c("wdi_indicators", "wdi_indicators", "vdem_data"))
})

test_that("rows, row order and column order of the dictionary are preserved", {
  dict <- make_dictionary()
  out <- map_lazyload_data(dict, lazyloads = make_lazyloads()) |>
    suppressMessages()

  expect_equal(out$variable, dict$variable)
  expect_named(out, names(dict))
})

test_that("dataset columns that are not in the dictionary are ignored", {
  out <- map_lazyload_data(make_dictionary(), lazyloads = make_lazyloads()) |>
    suppressMessages()

  expect_false("budget_execution" %in% out$etl_source)
  expect_equal(nrow(out), 3)
})

test_that("dictionary variables found in no dataset are kept as NA and reported", {
  dict <- tibble::add_row(make_dictionary(), variable = "rise_ee_1", var_name = "R")

  expect_warning(
    out <- map_lazyload_data(dict, lazyloads = make_lazyloads()) |>
      suppressMessages(),
    class = "cliaretl_warning_unmapped_variables"
  )
  expect_true(is.na(out$etl_source[out$variable == "rise_ee_1"]))
})

test_that("a variable that is a column of two datasets is an error", {
  lazyloads <- make_lazyloads()
  lazyloads$vdem_data$wdi_a <- 9

  expect_error(
    map_lazyload_data(make_dictionary(), lazyloads = lazyloads),
    class = "cliaretl_error_ambiguous_etl_source"
  )
})

test_that("excluded datasets are not used as sources", {
  lazyloads <- make_lazyloads()
  lazyloads$closeness_to_frontier_static <- tibble::tibble(country_code = "KEN", wdi_a = 0.5)

  out <- map_lazyload_data(make_dictionary(), lazyloads = lazyloads) |>
    suppressMessages()

  expect_equal(out$etl_source[out$variable == "wdi_a"], "wdi_indicators")
})

test_that("a dictionary without an etl_source column gains one", {
  dict <- dplyr::select(make_dictionary(), -etl_source)
  out <- map_lazyload_data(dict, lazyloads = make_lazyloads()) |>
    suppressMessages()

  expect_equal(names(out), c(names(dict), "etl_source"))
})

test_that("default reader loads .rda files from data_dir by file name", {
  dir <- withr::local_tempdir()
  wdi_indicators <- tibble::tibble(country_code = "KEN", year = 2020, wdi_a = 1)
  save(wdi_indicators, file = file.path(dir, "wdi_indicators.rda"))

  out <- map_lazyload_data(
    tibble::tibble(variable = "wdi_a"),
    data_dir = dir
  ) |>
    suppressMessages()

  expect_equal(out$etl_source, "wdi_indicators")
})
