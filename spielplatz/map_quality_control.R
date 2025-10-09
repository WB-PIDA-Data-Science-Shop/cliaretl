
# Purpose: Compare column names and some content across current and legacy map

library(dplyr)
library(tidyr)
library(stringr)
library(sf)
library(here)
library(readr)
library(janitor)
library(sf)


files <- c(
  legacy = here("data-raw", "output", "indicators_map_legacy.rds"),
  lowres  = here("data-raw", "output", "indicators_map.rds")
)

objs <- lapply(files, readRDS)

summ_df <- data.frame(
  file   = names(objs),
  class  = sapply(objs, function(x) paste(class(x), collapse = ",")),
  n_rows = sapply(objs, nrow),
  n_cols = sapply(objs, ncol),
  stringsAsFactors = FALSE
)

# First 10 column names for a quick peek
summ_df$first_cols <- sapply(
  objs, function(x) paste(utils::head(names(x), 10), collapse = ", ")
)

summ_df

cols_list <- lapply(objs, names)

# Columns present in ALL files
common_cols <- Reduce(intersect, cols_list)

# Columns present in ANY file
union_cols  <- Reduce(union, cols_list)

# Columns unique to each file (not in the others)
unique_cols <- lapply(names(objs), function(nm) {
  setdiff(cols_list[[nm]], Reduce(union, cols_list[names(objs) != nm]))
})
names(unique_cols) <- names(objs)

# What differs pairwise?
pairwise_diff <- combn(names(objs), 2, simplify = FALSE, FUN = function(p) {
  a <- p[1]; b <- p[2]
  list(
    pair = paste(a, b, sep = " vs "),
    only_in_a = setdiff(cols_list[[a]], cols_list[[b]]),
    only_in_b = setdiff(cols_list[[b]], cols_list[[a]])
  )
})

# Print a compact report
cat("\n=== Column name comparison ===\n")
cat("Common columns across ALL files:", length(common_cols), "\n")
cat(paste(utils::head(common_cols, 20), collapse = ", "), if (length(common_cols) > 20) " ...\n" else "\n")
cat("\nColumns unique to each file:\n")
for (nm in names(unique_cols)) {
  cat("\n- ", nm, " (", length(unique_cols[[nm]]), "): ",
      paste(utils::head(unique_cols[[nm]], 20), collapse = ", "),
      if (length(unique_cols[[nm]]) > 20) " ..." else "",
      "\n", sep = "")
}
cat("\nPairwise differences:\n")
for (x in pairwise_diff) {
  cat("\n* ", x$pair, "\n  only_in_first  (", length(x$only_in_a), "): ",
      paste(utils::head(x$only_in_a, 15), collapse = ", "),
      if (length(x$only_in_a) > 15) " ..." else "", "\n", sep = "")
  cat("  only_in_second (", length(x$only_in_b), "): ",
      paste(utils::head(x$only_in_b, 15), collapse = ", "),
      if (length(x$only_in_b) > 15) " ..." else "", "\n", sep = "")
}


lowres <- readRDS(here("data-raw", "output", "indicators_map.rds"))

legacy <- readRDS(here("data-raw", "output", "indicators_map_legacy.rds"))


# Quick geometry check
cat("\n=== Geometry check ===\n")
cat("Lowres geometry type: ", unique(st_geometry_type(lowres)), "\n")
cat("Legacy geometry type:", unique(st_geometry_type(legacy)), "\n")
cat("Lowres CRS: ", st_crs(lowres)$epsg, "\n")
cat("Legacy CRS:", st_crs(legacy)$epsg, "\n")
cat("Lowres valid geometries: ", all(st_is_valid(lowres)), "\n")
cat("Legacy valid geometries:", all(st_is_valid(legacy)), "\n")
