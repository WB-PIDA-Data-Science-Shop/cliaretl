metadata_fixture <- tibble::tibble(
  variable                    = c("v_both", "v_static", "v_none", "v_missing", "v_other"),
  var_name                    = c("Both", "Static", "None", "Missing", "Other family"),
  description                 = "desc",
  source                      = "src",
  family_name                 = c(rep("Fam A", 4), "Fam B"),
  var_level                   = "indicator",
  rank_id                     = 1:5,
  benchmarked_ctf             = c("Yes", "Yes", "No", "No", "Yes"),
  benchmark_dynamic_indicator = c("Yes", "No", "No", NA, "Yes")
)

test_that("get_family_variables() labels benchmarking status", {
  out <- get_family_variables("Fam A", metadata = metadata_fixture)

  expect_named(out, c("Variable", "Name", "Benchmarked", "Definition", "Source"))
  expect_equal(out$Variable, c("v_both", "v_static", "v_none", "v_missing"))
  expect_equal(out$Benchmarked, c("Yes", "Yes", "No", "No"))
})

test_that("compute_family_coverage() carries Benchmarked after Name", {
  panel <- tibble::tibble(
    country_code = rep(c("AAA", "BBB"), each = 2),
    year         = rep(2024:2025, times = 2),
    v_both = 1, v_static = 2, v_none = 3, v_missing = 4
  )

  out <- compute_family_coverage(
    panel, "Fam A",
    country_id = country_code, year_id = year, ref_year = 2026,
    country_region_list = tibble::tibble(country_code = c("AAA", "BBB"), region = "R1"),
    metadata = metadata_fixture
  )

  expect_equal(names(out)[1:3], c("Indicator", "Name", "Benchmarked"))
  expect_equal(out$Benchmarked, c("Yes", "Yes", "No", "No"))
})
