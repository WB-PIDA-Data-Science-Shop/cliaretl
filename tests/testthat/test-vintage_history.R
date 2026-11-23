# builds a throwaway repo whose history mimics how the panel moved over time:
#   2025-07-01  data-raw/input/cliar/compiled_indicators.rds   (v1)
#   2025-09-01  data-raw/output/compiled_indicators.csv.gz     (v2)
#   2025-10-01  data-raw/output/compiled_indicators.rds        (v3), csv.gz deleted
#   2026-02-01  inst/extdata/compiled_indicators.rds           (v4)
#   2026-03-01  unrelated commit
local_vintage_repo <- function() {
  # git_binary() also finds Git for Windows outside the PATH; it errors if
  # git is nowhere to be found
  skip_if(inherits(try(git_binary(), silent = TRUE), "try-error"), "git not available")

  repo <- tempfile("vintage repo ") # space in the path on purpose
  dir.create(repo)

  git <- function(...) run_git(repo, c("-c", "user.name=Test", "-c", "user.email=t@example.com", ...))
  panel <- function(v) tibble::tibble(country_code = "AAA", year = 2020, x = v)
  write_to <- function(path, v) {
    full <- file.path(repo, path)
    dir.create(dirname(full), recursive = TRUE, showWarnings = FALSE)
    if (grepl("csv[.]gz$", path)) {
      con <- gzfile(full, "w"); utils::write.csv(panel(v), con, row.names = FALSE); close(con)
    } else {
      saveRDS(panel(v), full)
    }
  }
  commit_at <- function(date, msg) {
    Sys.setenv(GIT_AUTHOR_DATE = paste(date, "12:00:00"), GIT_COMMITTER_DATE = paste(date, "12:00:00"))
    on.exit(Sys.unsetenv(c("GIT_AUTHOR_DATE", "GIT_COMMITTER_DATE")))
    git("add", "-A")
    git("commit", "-q", "-m", msg)
  }

  git("init", "-q", "-b", "main")
  write_to("data-raw/input/cliar/compiled_indicators.rds", 1); commit_at("2025-07-01", "v1 published")
  write_to("data-raw/output/compiled_indicators.csv.gz", 2);   commit_at("2025-09-01", "v2 csv")
  unlink(file.path(repo, "data-raw/output/compiled_indicators.csv.gz"))
  write_to("data-raw/output/compiled_indicators.rds", 3);      commit_at("2025-10-01", "v3 rds")
  write_to("inst/extdata/compiled_indicators.rds", 4);         commit_at("2026-02-01", "v4 extdata")
  writeLines("x", file.path(repo, "README")); commit_at("2026-03-01", "unrelated")
  repo
}

test_that("list_vintages() lists every change across locations, newest first", {
  repo <- local_vintage_repo()
  v <- list_vintages(ref = "main", repo = repo)

  expect_equal(v$message, c("v4 extdata", "v3 rds", "v2 csv", "v1 published"))
  expect_equal(v$date, as.Date(c("2026-02-01", "2025-10-01", "2025-09-01", "2025-07-01")))
  expect_named(v, c("date", "commit", "author", "message", "path"))
})

test_that("load_vintage() returns the panel as it was on a date", {
  repo <- local_vintage_repo()
  load <- function(d) suppressMessages(load_vintage(d, ref = "main", repo = repo))

  expect_equal(load("2025-07-01")$x, 1) # same day counts
  expect_equal(load("2025-09-15")$x, 2) # read from the csv.gz
  expect_equal(load("2025-12-31")$x, 3)
  # in March 2026 both data-raw/output and inst/extdata exist: newest wins
  expect_equal(load("2026-03-15")$x, 4)
  expect_equal(attr(load("2026-03-15"), "vintage")$path, "inst/extdata/compiled_indicators.rds")
})

test_that("load_vintage() accepts a commit and labels the vintage", {
  repo <- local_vintage_repo()
  v3 <- list_vintages(ref = "main", repo = repo)$commit[2]
  panel <- suppressMessages(load_vintage(commit = v3, repo = repo))

  expect_equal(panel$x, 3)
  info <- attr(panel, "vintage")
  expect_equal(info$file_date, "2025-10-01")
  expect_equal(info$label, paste0(v3, " @ 2025-10-01 (", v3, ")"))
})

test_that("compare_vintages() picks up load_vintage() labels", {
  repo <- local_vintage_repo()
  previous <- suppressMessages(load_vintage("2025-12-31", ref = "main", repo = repo))
  latest   <- suppressMessages(load_vintage("2026-03-15", ref = "main", repo = repo))
  cmp <- compare_vintages(previous, latest, metadata = tibble::tibble(
    variable = "x", var_name = "X", family_var = NA_character_, family_name = NA_character_, source = NA_character_
  ))

  expect_match(cmp$settings$labels[["previous"]], "^main @ 2025-10-01")
  expect_match(cmp$settings$labels[["latest"]], "^main @ 2026-02-01")
})

test_that("load_vintage() validates its inputs", {
  repo <- local_vintage_repo()

  expect_error(load_vintage(repo = repo), "exactly one")
  expect_error(load_vintage("2025-01-01", commit = "abc", repo = repo), "exactly one")
  expect_error(suppressMessages(load_vintage("2024-01-01", ref = "main", repo = repo)), "no commits")
})

test_that("vintage_repo() copies a remote and picks up its new commits on the next call", {
  # The throwaway repo plays the part of GitHub. Copies made with
  # --filter=blob:none over file:// need the source to allow filtering
  remote <- local_vintage_repo()
  run_git(remote, c("config", "uploadpack.allowFilter", "true"))
  url  <- paste0("file:///", sub("^/", "", normalizePath(remote, winslash = "/")))
  copy <- file.path(withr::local_tempdir(), "copy.git")

  # First call: the copy has the remote's full history
  vintage_repo(url, copy)
  expect_equal(list_vintages(repo = copy), list_vintages(ref = "main", repo = remote))

  # A new version reaches the remote's main after the copy was made...
  saveRDS(tibble::tibble(country_code = "AAA", year = 2020, x = 5),
          file.path(remote, "inst/extdata/compiled_indicators.rds"))
  run_git(remote, c("-c", "user.name=Test", "-c", "user.email=t@example.com",
                    "commit", "-q", "-am", "v5 after copy"))

  # ...and the next call brings it in, and it can be loaded
  vintage_repo(url, copy)
  expect_equal(list_vintages(repo = copy)$message[1], "v5 after copy")
  expect_equal(suppressMessages(load_vintage(commit = "main", repo = copy))$x, 5)
})

test_that("by default, vintages are read from GitHub", {
  skip_on_cran()
  skip_if_offline("github.com")
  skip_if(inherits(try(git_binary(), silent = TRUE), "try-error"), "git not available")

  # 684139d merged PR #74 (May 2026), which changed the panel on main
  expect_true("684139d" %in% list_vintages()$commit)
})
