library(testthat)
library(httr)

# Helpers -----------------------------------------------------------------

# Build a mock httr response with a given status and body
mock_response <- function(status, body) {
  structure(
    list(
      status_code = status,
      content = chartr("", "", body),  # kept for httr internals
      headers = list("content-type" = "application/json; charset=utf-8"),
      url = "https://data360api.worldbank.org/data360/indicators?datasetId=WB_CSC"
    ),
    class = "response"
  )
}

# Tests -------------------------------------------------------------------

test_that("get_csc_indicators returns a character vector", {
  skip_if_offline()

  result <- get_csc_indicators("WB_CSC")

  expect_type(result, "character")
  expect_gt(length(result), 0L)
})

test_that("get_csc_indicators returns indicator IDs prefixed with the database_id", {
  skip_if_offline()

  result <- get_csc_indicators("WB_CSC")

  expect_true(all(startsWith(result, "WB_CSC")))
})

test_that("get_csc_indicators works with a different database_id", {
  skip_if_offline()

  result <- get_csc_indicators("WB_WDI")

  expect_type(result, "character")
  expect_true(all(startsWith(result, "WB_WDI")))
})

test_that("get_csc_indicators errors on a bad HTTP status", {
  local_mocked_bindings(
    GET = function(...) mock_response(400L, '{"title":"Bad Request","status":400}'),
    .package = "httr"
  )

  expect_error(get_csc_indicators("WB_CSC"), regexp = "400")
})

test_that("get_csc_indicators uses datasetId (not DATABASE_ID) as query param", {
  captured_url <- NULL

  local_mocked_bindings(
    GET = function(url, ...) {
      captured_url <<- url
      structure(
        list(
          status_code = 200L,
          headers = list("content-type" = "application/json"),
          url = url
        ),
        class = "response"
      )
    },
    stop_for_status = function(...) invisible(NULL),
    content = function(...) '["WB_CSC_IND_1","WB_CSC_IND_2"]',
    .package = "httr"
  )

  get_csc_indicators("WB_CSC")

  expect_match(captured_url, "datasetId=WB_CSC")
  expect_no_match(captured_url, "DATABASE_ID")
})
