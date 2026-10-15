previous_fixture <- tibble::tibble(
  country_code = c("AAA", "AAA", "BBB", "BBB"),
  country_name = c("A", "A", "B", "B"),
  year         = c(2020, 2021, 2020, 2021),
  x            = c(10,   10,   0.5,  0.5),
  y            = c(5,    NA,   0,    1),
  z_old        = 1
)

latest_fixture <- tibble::tibble(
  country_code = c("AAA", "AAA", "AAA", "BBB", "BBB", "CCC"),
  country_name = c("A", "A", "A", "B", "B", "C"),
  year         = c(2020, 2021, 2022, 2020, 2021, 2021),
  x            = c(10.005, 11, 12, 0.5004, 0.502, NA),
  y            = c(NA,     3,  NA, 2,      1,     7),
  w_new        = 1
)

metadata_fixture <- tibble::tibble(
  variable    = c("x", "y"),
  var_name    = c("X", "Y"),
  family_var  = "vars_a",
  family_name = "Fam A",
  source      = c("Src 1", "Src 2")
)

compare_fixture <- function(...) {
  compare_vintages(previous_fixture, latest_fixture, metadata = metadata_fixture, ...)
}

cell_status <- function(cmp, country, yr, var) {
  as.character(cmp$cells$status[cmp$cells$country_code == country & cmp$cells$year == yr & cmp$cells$variable == var])
}

test_that("each published cell gets the right status", {
  cmp <- compare_fixture()
  counts <- stats::setNames(cmp$summary$n, cmp$summary$status)

  expect_equal(unname(counts[c("Same", "Revised", "Dropped", "Added (backfilled)", "Added (new period)")]),
               c(3, 3, 1, 2, 1))
  expect_equal(cell_status(cmp, "AAA", 2021, "x"), "Revised")
  expect_equal(cell_status(cmp, "AAA", 2020, "y"), "Dropped")
  expect_equal(cell_status(cmp, "AAA", 2021, "y"), "Added (backfilled)")
  expect_equal(cell_status(cmp, "CCC", 2021, "y"), "Added (backfilled)")
  expect_equal(cell_status(cmp, "AAA", 2022, "x"), "Added (new period)")
  # "Same" cells are counted but not listed
  expect_false(any(cmp$cells$status == "Same"))
})

test_that("tolerance is relative above 1 and absolute below", {
  cmp <- compare_fixture()
  expect_length(cell_status(cmp, "AAA", 2020, "x"), 0) # 10 -> 10.005: within 0.001 * 10
  expect_length(cell_status(cmp, "BBB", 2020, "x"), 0) # 0.5 -> 0.5004: within 0.001
  expect_equal(cell_status(cmp, "BBB", 2021, "x"), "Revised") # 0.5 -> 0.502

  loose <- compare_fixture(tolerance = 0.01)
  expect_length(cell_status(loose, "BBB", 2021, "x"), 0)
})

test_that("revisions are ordered by percentage change, zero-base changes first", {
  revised <- compare_fixture()$cells |> dplyr::filter(status == "Revised")

  expect_equal(revised$variable[1], "y") # 0 -> 2: no percentage, listed first
  expect_true(is.na(revised$pct_change[1]))
  expect_equal(revised$pct_change[2:3], c(10, 0.4))
})

test_that("variables, countries and years in only one vintage are listed", {
  s <- compare_fixture()$structure

  expect_setequal(s$value[s$type == "Variable"], c("z_old", "w_new"))
  expect_equal(s$value[s$type == "Country"], "CCC")
  expect_equal(s$value[s$type == "Year"], "2022")
  expect_equal(s$change[s$value == "z_old"], "Only in Previous")
})

test_that("per-variable shares are computed over published cells", {
  v <- compare_fixture()$variables

  expect_equal(v$published[v$variable == "y"], 3)
  expect_equal(v$pct_dropped[v$variable == "y"], 100 / 3)
  expect_equal(v$source[v$variable == "x"], "Src 1")
})

test_that("duplicated keys are rejected", {
  dup <- dplyr::bind_rows(previous_fixture, previous_fixture[1, ])
  expect_error(compare_vintages(dup, latest_fixture, metadata = metadata_fixture), "duplicated")
})
