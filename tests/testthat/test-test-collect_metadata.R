library(testthat)
library(tibble)
library(purrr)

test_that("collect_metadata reads valid metadata from a .rda file", {
  test_dir <- "tests/testthat/testdata/meta1"
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)

  df <- data.frame(a = 1:3)
  df <- add_plmetadata(df,
                       source = "https://example.com/data.csv",
                       other_info = "Metadata test")

  save(df, file = file.path(test_dir, "mock1.rda"))

  metadata <- collect_metadata(test_dir)

  expect_s3_class(metadata, "data.frame")
  expect_equal(nrow(metadata), 1)
  expect_equal(metadata$dataset, "df")
  expect_equal(metadata$source, "https://example.com/data.csv")
  expect_equal(metadata$other_info, "Metadata test")
  expect_equal(metadata$latest_download, as.character(Sys.Date()))

  # Clean up
  unlink(test_dir, recursive = TRUE)
})


test_that("collect_metadata handles missing metadata attributes", {
  test_dir <- "tests/testthat/testdata/meta2"
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)

  plain_df <- data.frame(x = 1:5)
  save(plain_df, file = file.path(test_dir, "plain.rda"))

  metadata <- collect_metadata(test_dir)

  expect_equal(metadata$dataset, "plain_df")
  expect_true(is.na(metadata$source))
  expect_true(is.na(metadata$other_info))
  expect_true(is.na(metadata$latest_download))

  # Clean up
  unlink(test_dir, recursive = TRUE)
})


test_that("collect_metadata returns 0 rows for empty directory", {
  test_dir <- "tests/testthat/testdata/empty"
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)

  metadata <- collect_metadata(test_dir)
  expect_equal(nrow(metadata), 0)

  # Clean up
  unlink(test_dir, recursive = TRUE)
})


test_that("collect_metadata reads only the first object in .rda if multiple present", {
  test_dir <- "tests/testthat/testdata/multiple"
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)

  df1 <- add_plmetadata(data.frame(a = 1), source = "s1", other_info = "info1")
  df2 <- add_plmetadata(data.frame(b = 2), source = "s2", other_info = "info2")

  save(df1, df2, file = file.path(test_dir, "multi.rda"))

  metadata <- collect_metadata(test_dir)

  expect_equal(nrow(metadata), 1)
  expect_equal(metadata$dataset, "df1")
  expect_equal(metadata$source, "s1")
  expect_equal(metadata$other_info, "info1")

  # Clean up
  unlink(test_dir, recursive = TRUE)

  unlink("tests", recursive = TRUE)

})


