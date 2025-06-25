library(testthat)

test_that("add_plmetadata correctly attaches metadata", {
  df <- data.frame(x = 1:5)
  source_url <- "https://example.com/data.csv"
  info <- "Test dataset"

  df_meta <- add_plmetadata(df, source = source_url, other_info = info)

  expect_equal(attr(df_meta, "source"), source_url)
  expect_equal(attr(df_meta, "other_info"), info)
  expect_equal(attr(df_meta, "latest_download"), Sys.Date())
})

test_that("add_plmetadata preserves original data", {
  df <- data.frame(x = 1:5)
  df_meta <- add_plmetadata(df, source = "source", other_info = "info")
  expect_equal(df_meta$x, 1:5)
})


test_that("collect_metadata handles missing attributes gracefully", {
  skip_if_not(dir.exists("data"), "No 'data' directory found")

  # Dataset with no metadata
  df_plain <- data.frame(z = 1:10)
  save(df_plain, file = file.path("data", "plain_dataset.rda"))

  metadata <- collect_metadata("data")

  expect_s3_class(metadata, "data.frame")
  expect_equal(metadata$source[1], NA_character_)
  expect_equal(metadata$other_info[1], NA_character_)
  expect_true(is.na(metadata$latest_download[1]))

  # Clean up
  file.remove(file.path("data", "plain_dataset.rda"))
})

test_that("collect_metadata works on one .rda file", {
  test_dir <- "tests/testthat/testdata"
  dir.create(test_dir, recursive = TRUE, showWarnings = FALSE)

  # Create a mock dataset with metadata
  df <- data.frame(a = 1:3)
  df <- add_plmetadata(df,
                       source = "https://example.com/test.csv",
                       other_info = "Unit test dataset")

  # Save only this dataset to testdata folder
  save(df, file = file.path(test_dir, "mock_dataset.rda"))

  # Run metadata collection on isolated test folder
  metadata <- collect_metadata(test_dir)

  expect_s3_class(metadata, "data.frame")
  expect_equal(nrow(metadata), 1)
  expect_equal(metadata$dataset[1], "df")
  expect_equal(metadata$source[1], "https://example.com/test.csv")
  expect_equal(metadata$other_info[1], "Unit test dataset")
  expect_equal(metadata$latest_download[1], as.character(Sys.Date()))

  # Clean up test file
  file.remove(file.path(test_dir, "mock_dataset.rda"))

  unlink("tests", recursive = TRUE)

})

