library(testthat)

test_that("compute_coverage: percent_complete_records_last_five uses a 5-year window, not just ref_year", {
  dt <- data.frame(
    country_code = rep("AAA", 8),
    year = 2018:2025,
    ind_a = c(NA, NA, 10, 20, 30, 40, NA, NA) # non-NA only in 2020:2023
  )

  region_list <- data.frame(country_code = "AAA", region = "Test Region")

  out <- compute_coverage(
    data = dt,
    country_id = country_code,
    year_id = year,
    ref_year = 2025,
    country_region_list = region_list
  )

  # last-five-years window = year >= 2025 - 5 = 2020, i.e. years 2020:2025 (6 rows),
  # of which 4 are non-missing (2020-2023) -> 4/6 = 66.7%
  expect_equal(
    out$`Percentage of Complete Records in Last Five Years`[out$Indicator == "ind_a"],
    "66.7%"
  )
})

test_that("compute_coverage: percent_complete_records_last_five is not 0 when data stops short of ref_year", {
  # Regression test: the filter used to be `year >= ref_year`, which returned
  # 0% for any dataset whose most recent year fell short of ref_year itself
  # (the common case, since most sources lag the reference year).
  dt <- data.frame(
    country_code = rep("AAA", 4),
    year = 2020:2023,
    ind_a = c(1, 2, 3, 4) # fully complete, but never reaches ref_year = 2025
  )

  region_list <- data.frame(country_code = "AAA", region = "Test Region")

  out <- compute_coverage(
    data = dt,
    country_id = country_code,
    year_id = year,
    ref_year = 2025,
    country_region_list = region_list
  )

  expect_equal(
    out$`Percentage of Complete Records in Last Five Years`[out$Indicator == "ind_a"],
    "100%"
  )
})

test_that("compute_coverage: percent_complete_records_last_five is NA when there are no rows in the window", {
  dt <- data.frame(
    country_code = rep("AAA", 4),
    year = 2010:2013,
    ind_a = c(1, 2, 3, 4) # all years fall well before the 2020-2025 window
  )

  region_list <- data.frame(country_code = "AAA", region = "Test Region")

  out <- compute_coverage(
    data = dt,
    country_id = country_code,
    year_id = year,
    ref_year = 2025,
    country_region_list = region_list
  )

  expect_true(
    is.na(out$`Percentage of Complete Records in Last Five Years`[out$Indicator == "ind_a"])
  )
})
