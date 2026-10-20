################################################################################
############## LOAD PAST VINTAGES OF THE COMPILED INDICATORS FROM GIT ##########
################################################################################

#' Repository paths at which the compiled indicators panel has been stored
#'
#' The panel moved over time; every location is listed so that any past date
#' can be served. Newest location first. Add a path here if the panel moves
#' again.
#'
#' @noRd
vintage_paths <- c(
  "inst/extdata/compiled_indicators.rds",        # Feb 2026 -
  "data-raw/output/compiled_indicators.rds",     # Sep - Dec 2025
  "data-raw/output/compiled_indicators.csv.gz",  # Aug - Sep 2025 (deleted)
  "data-raw/input/cliar/compiled_indicators.rds" # Jun - Jul 2025 (published 2025)
)

#' List the past vintages of the compiled indicators in git
#'
#' @description
#' Answers *"which versions of the compiled indicators can I go back to?"* by
#' listing every change to the panel in the history of `ref` (by default the
#' published `main` branch), wherever the panel was stored at the time.
#'
#' Each row is one commit on `ref` that added or changed the panel. Its `date`
#' is the day that change reached `ref` (for a pull request, the day it was
#' merged), so any listed date can be passed to [load_vintage()] to get that
#' version back.
#'
#' @details
#' **Where it looks.** The panel has lived at several paths:
#' `data-raw/input/cliar/compiled_indicators.rds` (June-July 2025),
#' `data-raw/output/compiled_indicators.csv.gz` (August-September 2025),
#' `data-raw/output/compiled_indicators.rds` (September-December 2025) and
#' `inst/extdata/compiled_indicators.rds` (February 2026 onwards). All are
#' searched by default.
#'
#' **History, not GitHub.** Only commits on the branch itself are listed (git's
#' "first-parent" history), so each pull request appears once, as its merge
#' commit; the commits inside it are not listed separately. The list is read
#' from your local clone, so it only knows what your clone knows: run
#' `git fetch` first to include the latest merges on GitHub. Deletions are not
#' listed, and nothing exists before the first version reached `main`
#' (16 June 2025).
#'
#' **Errors.** Stops if git cannot be found, `repo` is not a git repository, or
#' `ref` does not exist.
#'
#' @param ref Character, the branch (or other git reference) whose history to
#'   read. Default `"origin/main"`: your clone's copy of the published branch.
#'   Use e.g. `"main"` or a feature branch name to read another history.
#' @param paths Character vector of repository paths at which the panel has
#'   been stored. The default covers every location the panel has used; extend
#'   it only if the panel moves again.
#' @param repo Character, path to a local clone of the cliaretl repository.
#'   Default `"."`, the working directory (the package root when working on
#'   cliaretl in RStudio).
#'
#' @return A tibble with one row per change to the panel, newest first:
#'   `date` (Date, when the change reached `ref`), `commit` (character, short
#'   hash), `author` (character), `message` (character, the commit message's
#'   first line) and `path` (character, the file changed). Zero rows if the
#'   panel never appears in that history.
#'
#' @md
#' @family vintage comparison
#' @seealso [load_vintage()] to load one of the listed versions.
#'
#' @examplesIf nzchar(Sys.which("git")) && file.exists("inst/extdata/compiled_indicators.rds")
#' # run from the root of a cliaretl clone
#' list_vintages()
#'
#' @export
list_vintages <- function(ref = "origin/main", paths = vintage_paths, repo = ".") {
  # For each stored location, the commits on `ref` that added or modified it.
  # Each log line is "date <tab> hash <tab> author <tab> subject"
  out <- purrr::map(paths, function(path) {
    lines <- run_git(
      repo,
      c("log", ref, "--first-parent", "--diff-filter=AM",
        "--format=%cs%x09%h%x09%an%x09%s", "--", path)
    )
    if (length(lines) == 0) return(NULL)

    # Split each line on tabs into columns
    fields <- strsplit(lines, "\t", fixed = TRUE)
    tibble::tibble(
      date    = as.Date(vapply(fields, `[`, character(1), 1)),
      commit  = vapply(fields, `[`, character(1), 2),
      author  = vapply(fields, `[`, character(1), 3),
      message = vapply(fields, `[`, character(1), 4),
      path    = path
    )
  }) |>
    purrr::list_rbind()

  # No history at any location: return an empty table with the same columns
  if (nrow(out) == 0) {
    return(tibble::tibble(date = as.Date(character()), commit = character(),
                          author = character(), message = character(), path = character()))
  }

  # All locations together, newest first
  dplyr::arrange(out, dplyr::desc(.data$date))
}

#' Load a past vintage of the compiled indicators from git
#'
#' @description
#' Answers *"what did the compiled indicators look like on a given date?"* by
#' reading the panel as it was on `ref` (by default the published `main`
#' branch) at the end of `date`, or at a given `commit`, straight from git
#' history. Pass the result to [compare_vintages()] as `previous`.
#'
#' How the version is found:
#'
#' 1. **The branch on that day.** The last commit that was on `ref` by 23:59:59
#'    on `date` (in your computer's time zone). A pull request counts from the
#'    day it was merged, not the day its commits were written.
#' 2. **The right file.** Of the locations the panel has used, those that exist
#'    at that commit are candidates; if more than one does (e.g. in early 2026
#'    an outdated copy remained in `data-raw/output/` next to the current one in
#'    `inst/extdata/`), the one changed most recently is used.
#' 3. **Read without touching your files.** The file is extracted from git to a
#'    temporary file and read (`.rds`, or the old `.csv.gz`); your working copy
#'    and current branch are left as they are.
#'
#' A message reports which file and commit were used. The result carries a
#' `"vintage"` attribute recording where it came from, which
#' [compare_vintages()] uses to label it, e.g.
#' `"origin/main @ 2025-12-09 (9e2d4a2)"`.
#'
#' @details
#' **Local clone.** Versions are read from your local clone, so it only knows
#' what your clone knows: run `git fetch` first to include the latest merges on
#' GitHub. Nothing exists before the first version reached `main`
#' (16 June 2025).
#'
#' **Column types.** Versions stored as `.csv.gz` (August-September 2025) are
#' read back from text, so column types are re-guessed (e.g. a column of whole
#' numbers comes back as integer); values are unaffected.
#'
#' **Errors.** Stops if:
#' - both or neither of `date` and `commit` are given;
#' - `ref` has no commits on or before `date`;
#' - none of `paths` exists at the resolved commit (e.g. a date before June
#'   2025);
#' - git cannot be found, `repo` is not a git repository, or `ref`/`commit`
#'   does not exist.
#'
#' @inheritParams list_vintages
#' @param date A `Date`, or a character string `"YYYY-MM-DD"`: load the panel as
#'   it was on `ref` at the end of that day. Dates from [list_vintages()] work
#'   directly.
#' @param commit Character, alternative to `date`: a commit hash (full or
#'   short) or any other git revision to load the panel from. When given, `ref`
#'   is ignored. Supply exactly one of `date` and `commit`.
#'
#' @return A tibble: the panel, one row per country-year, exactly as stored at
#'   that point. Its `"vintage"` attribute is a list with `ref` (the reference
#'   or commit asked for), `commit` (short hash of the resolved commit), `path`
#'   (the file read), `file_commit` and `file_date` (the change that last
#'   brought that file onto the branch) and `label` (character, used by
#'   [compare_vintages()]).
#'
#' @md
#' @family vintage comparison
#' @seealso [list_vintages()] to see which versions exist;
#'   [compare_vintages()] to compare a loaded version with the latest panel.
#'
#' @examplesIf nzchar(Sys.which("git")) && file.exists("inst/extdata/compiled_indicators.rds")
#' # run from the root of a cliaretl clone
#' previous <- load_vintage("2025-12-31")
#' attr(previous, "vintage")$label
#'
#' compare_vintages(previous, readRDS("inst/extdata/compiled_indicators.rds"))
#'
#' @export
load_vintage <- function(date = NULL, commit = NULL, ref = "origin/main",
                         paths = vintage_paths, repo = ".") {
  # Exactly one way of choosing the version
  if (is.null(date) == is.null(commit)) {
    stop("Supply exactly one of `date` and `commit`.", call. = FALSE)
  }

  # If a date: the last commit on the branch by the end of that day
  if (!is.null(date)) {
    date <- as.Date(date)
    target <- run_git(
      repo,
      c("rev-list", "-1", "--first-parent", paste0("--before=", format(date), " 23:59:59"), ref)
    )
    if (length(target) == 0) {
      stop("`", ref, "` has no commits on or before ", format(date), ".", call. = FALSE)
    }
    resolved_from <- paste(ref, "on", format(date))

  # If a commit: resolve it to a full commit hash (errors if it does not exist)
  } else {
    target <- run_git(repo, c("rev-parse", "--verify", paste0(commit, "^{commit}")))
    resolved_from <- paste("commit", commit)
  }

  # Drop the "ok" marker run_git() attaches, leaving the plain hash
  target <- as.vector(target)

  # Every stored copy present at the target commit, with the change that last
  # brought it onto the branch (first-parent, matching list_vintages())
  candidates <- purrr::map(paths, function(path) {
    exists <- run_git(repo, c("cat-file", "-e", paste0(target, ":", path)), allow_error = TRUE)
    if (!isTRUE(attr(exists, "ok"))) return(NULL)
    last <- strsplit(run_git(repo, c("log", "-1", "--first-parent", "--format=%ct%x09%cs%x09%h%x09%s", target, "--", path)), "\t")[[1]]
    tibble::tibble(path = path, time = as.numeric(last[1]), file_date = last[2],
                   file_commit = last[3], file_message = last[4])
  }) |>
    purrr::list_rbind()

  # No copy at that point in history: the date is too early
  if (nrow(candidates) == 0) {
    stop("No compiled indicators file found at ", resolved_from, ". ",
         "The earliest versions are listed by `list_vintages()`.", call. = FALSE)
  }

  # If several copies coexist, use the one changed most recently
  pick <- candidates[which.max(candidates$time), ]

  # Extract that file from git into a temporary file, deleted when the
  # function exits (`on.exit()` runs its code however the function ends)
  tmp <- tempfile(fileext = if (grepl("[.]csv[.]gz$", pick$path)) ".csv.gz" else ".rds")
  on.exit(unlink(tmp), add = TRUE)
  git_show_to_file(repo, paste0(target, ":", pick$path), tmp)

  # Read it in the format it was stored in
  panel <- if (grepl("[.]rds$", pick$path)) {
    readRDS(tmp)
  } else {
    utils::read.csv(tmp, stringsAsFactors = FALSE)
  }
  panel <- tibble::as_tibble(panel)

  # Record where this version came from, for labels and traceability
  ref_label <- if (is.null(commit)) ref else commit
  attr(panel, "vintage") <- list(
    ref         = ref_label,
    commit      = substr(target, 1, 7),
    path        = pick$path,
    file_commit = pick$file_commit,
    file_date   = pick$file_date,
    label       = sprintf("%s @ %s (%s)", ref_label, pick$file_date, pick$file_commit)
  )

  # Tell the user which version was loaded, and remind them to fetch when
  # reading a remote branch
  message(
    "Loaded ", pick$path, " as of ", resolved_from, ": last changed ", pick$file_date,
    " in ", pick$file_commit, " \"", pick$file_message, "\".",
    if (startsWith(ref_label, "origin/")) "\nBased on your local copy of the remote; run `git fetch` to include the latest pushes."
  )
  panel
}

# ---- helpers -------------------------------------------------------------------

#' Label a vintage for display
#'
#' @param df A vintage (data frame), possibly from `load_vintage()`.
#' @param default Character, the label to use when `df` has no `"vintage"`
#'   attribute.
#' @return Character: the `label` recorded by `load_vintage()` if present,
#'   otherwise `default`. Used for the default `labels` in `compare_vintages()`.
#' @noRd
vintage_label <- function(df, default) {
  # Prefer the label load_vintage() recorded; otherwise use the fallback
  label <- attr(df, "vintage")$label
  if (is.null(label)) default else label
}

#' Locate the git executable
#'
#' @return Character, the path to git: `getOption("cliaretl.git")` if set,
#'   otherwise git found on the system `PATH`. Stops with instructions if
#'   neither is available.
#' @noRd
git_binary <- function() {
  # A user-set option wins; otherwise search the PATH
  git <- getOption("cliaretl.git", Sys.which("git"))
  if (!nzchar(git)) {
    stop("Could not find git. Install Git, add it to your PATH, ",
         "or set options(cliaretl.git = \"path/to/git\").", call. = FALSE)
  }
  git
}

#' Quote command-line arguments that contain spaces or quotes
#'
#' `system2()` passes arguments to the program as they are (on Windows without
#' a shell), so an argument containing spaces would be split in two. Only such
#' arguments are quoted, using Windows (`cmd`) quoting on Windows and shell
#' quoting elsewhere; all others pass through unchanged.
#'
#' @param x Character vector of arguments.
#' @return Character vector, the same length as `x`.
#' @noRd
quote_arg <- function(x) {
  # Quoting style for the platform R is running on
  type <- if (.Platform$OS.type == "windows") "cmd" else "sh"

  # Quote only the arguments that need it
  ifelse(grepl("[[:space:]\"']", x), shQuote(x, type = type), x)
}

#' Run a git command in a repository and capture its text output
#'
#' @param repo Character, path to the repository (passed as `git -C <repo>`).
#' @param args Character vector, the git subcommand and its arguments.
#' @param allow_error Logical. If `FALSE` (default), a failing command stops
#'   with git's own message. If `TRUE`, failure is reported through the `"ok"`
#'   attribute instead, for commands used as yes/no checks.
#' @return Character vector, one element per line of output (stdout and stderr
#'   combined), with attribute `"ok"` (logical, whether git exited with status
#'   0). Strip the attribute with `as.vector()` before using the text as a
#'   value.
#' @noRd
run_git <- function(repo, args, allow_error = FALSE) {
  # Run git, capturing its output lines; a non-zero exit is recorded in the
  # "status" attribute rather than raised as an R warning
  out <- suppressWarnings(
    system2(git_binary(), quote_arg(c("-C", repo, args)), stdout = TRUE, stderr = TRUE)
  )
  status <- attr(out, "status")
  ok <- is.null(status) || status == 0

  # Stop on failure unless the caller only wants to know whether it worked
  if (!ok && !allow_error) {
    stop("git ", paste(args, collapse = " "), " failed:\n", paste(out, collapse = "\n"), call. = FALSE)
  }

  # Replace system2()'s attributes with a single success flag
  attributes(out) <- NULL
  attr(out, "ok") <- ok
  out
}

#' Extract a file from git history into a local file
#'
#' Streams the file's bytes straight to disk, so binary files (`.rds`, `.gz`)
#' are copied exactly; capturing them as text would corrupt them.
#'
#' @param repo Character, path to the repository.
#' @param spec Character, `"<commit>:<path>"` naming the file at a commit.
#' @param file Character, the local file to write; overwritten if it exists.
#' @return `file`, invisibly. Stops if git fails or writes nothing.
#' @noRd
git_show_to_file <- function(repo, spec, file) {
  # `git show <commit>:<path>` prints the file's contents; send them to `file`
  status <- system2(git_binary(), quote_arg(c("-C", repo, "show", spec)), stdout = file, stderr = FALSE)

  # A non-zero status or an empty file means the extraction failed
  if (!identical(as.integer(status), 0L) || !file.exists(file) || file.size(file) == 0) {
    stop("Could not read ", spec, " from git.", call. = FALSE)
  }
  invisible(file)
}
