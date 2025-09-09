# place quality checks here.
# global check on the data after all the intermediate quality checks have been done.

# check for consistency with the previous dataset (compiled_indicators.rds in the data-raw/input/cliar folder)

# set-up ------------------------------------------------------------------
library(dlookr)
library(readr)
library(dplyr)
library(ggplot2)
library(here)

compiled_indicators <- read_csv(
  here("data-raw", "output", "compiled_indicators.csv.gz")
)

compiled_indicators_legacy <- read_rds(
  here("data-raw", "input", "cliar", "compiled_indicators.rds")
)

theme_set(
  theme_classic()
)

# statistical assessment --------------------------------------------------
diagnostics <- compiled_indicators |>
  filter(year >= 2013) |>
  diagnose()

# append number of complete obs per indicator
diagnostics_complete_obs <- compiled_indicators |>
  filter(year >= 2013) |>
  summarise(
    across(everything(), \(var) sum(!is.na(var)))
  ) |>
  pivot_longer(
    everything(),
    names_to = "variables",
    values_to = "n_complete_obs"
  )

diagnostics <- diagnostics |>
  left_join(
    diagnostics_complete_obs,
    by = "variables"
  ) |>
  mutate(
    # we deduct unique count by 1 to account for the fact that NAs are considered
    # unique values
    unique_percent = (unique_count - 1)/n_complete_obs * 100
  )

diagnostics_outlier <- compiled_indicators |>
  diagnose_outlier() |>
  filter(
    outliers_ratio > 5
  )

diagnostics_categorical <- compiled_indicators |>
  diagnose_category()

## visualize drift --------------------------------------------------------
compiled_indicators_drift <- compare_pipeline_indicators(
  compiled_indicators_legacy |> select(country_code, where(is.double)),
  compiled_indicators |> select(country_code, where(is.double))
)

## visualize missingness --------------------------------------------------
diagnostics |>
  left_join(
    db_variables,
    by = c("variables" = "variable")
  ) |>
  filter(
    benchmarked_ctf == "Yes" &
      unique_rate >= 0.1
  ) |>
  ggplot(
    aes(missing_percent, reorder(variables, missing_percent))
  ) +
  geom_col() +
  ggtitle(
    "Missingness ratio"
  ) +
  labs(
    x = "Share of missingness (percentage)",
    y = "",
    caption = "Note: This visualization only includes variables with shares of missingness above 5 percent."
  ) +
  facet_wrap(
    vars(etl_source),
    scales = "free_y"
  )

## visualize discreteness -------------------------------------------------
diagnostics |>
  left_join(
    db_variables,
    by = c("variables" = "variable")
  ) |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  ggplot(
    aes(
      unique_percent, reorder(variables, desc(unique_percent))
    )
  ) +
  geom_col() +
  ggtitle(
    "Unique ratio"
  ) +
  labs(
    x = "Share of unique values (percentage)",
    y = "",
    caption = "Note: Share of unique values is computed as the number of distinct values (excluding missing value) divided by the number of complete observations."
  ) +
  facet_wrap(
    vars(etl_source),
    scales = "free_y"
  )

## visualize outliers ----------------------------------------------------
diagnostics_outlier |>
  left_join(
    db_variables,
    by = c("variables" = "variable")
  ) |>
  filter(
    benchmarked_ctf == "Yes"
  ) |>
  ggplot(
    aes(outliers_ratio, reorder(variables, outliers_ratio))
  ) +
  geom_col() +
  ggtitle(
    "Outliers ratio"
  ) +
  labs(
    x = "Share of outliers (percentage)",
    y = "",
    caption = "Note: Outliers are observations above or below 1.5 times the interquartile range. This visualization only includes variables with shares of outliers above 5 percent."
  ) +
  facet_wrap(
    vars(etl_source),
    scales = "free_y"
  )

