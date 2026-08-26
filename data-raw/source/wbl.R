## code to prepare `wbl_data` dataset goes here
# Manual download instructions:
#
# 1. Go to the following URL in your browser:
#    https://wbl.worldbank.org/en/wbl-data
# 2. Make sure you csroll down to the the "Women, Business and the Law 1.0 Data for 1971-2024" section.
# 3. Click the Stata link,this will download the Dta file named:
#    `WBL1-0-1971-2024.dta`
# 4. # Locate the file in your Downloads folder and move it to:
#   `.../cliaretl/data-raw/input/wbl/`

### access date: 8/13/2025
library(here)
library(haven)
library(dplyr)
library(tidyr)
library(stringr)
library(readxl)
library(janitor)
library(purrr)



# Load data ---------------------------------------------------------------

# reading the wbl 1.0 data data directly from the internet
urldata1.0 <- "https://wbl.worldbank.org/content/dam/sites/wbl/documents/2024/WBL1-0-1971-2024.dta"
wbl1_raw <- read_dta(urldata1.0) |>
  clean_names()


# reading the wbl 2.0 data data directly from the internet
url_data2.0 <- "https://wbl.worldbank.org/content/dam/sites/wbl/documents/2026/2026.02.19_WBL26_FINAL%20Data%20for%20Download.xlsx"

# download to a temp file
tmp <- tempfile(fileext = ".xlsx")
download.file(url_data2.0, tmp, mode = "wb")

# Get the sheet names from the downloaded Excel file
sheet_names <- excel_sheets(tmp)
wbl2_sheets_list <- sheet_names |>
  set_names() |>
  map(~ read_xlsx(tmp, sheet = .x, skip = 3) |> clean_names())

# Get elements 7 to 14 from the sheets list
wbl2_raw <- wbl2_sheets_list[2]   # for 2026 use full questionare: [7:14]

  


# clean-wbl1.0(1990-2023) -----------------------------------------------------------------

# Clean up variable names
wbl_df1 <- wbl1_raw |>
  filter(year >= 1990) |>
  # Drop variables
  select(-economycode, -region, -incomegroup, -reportyr, -economy) |>
  rename(country_code = is_ocode) |>
  arrange(country_code, year)


# Select relevant variables
wbl_df_filter1 <- wbl_df1 |>
  filter(year >= 1990) |>
  select(
    country_code,
    year,
    gr6_entrprnshp,
    matches("^gr2_|^gr3_|^gr7_|^gr1_|^gr4_|^gr5_")
  )

# drop indicators that won't be used
wbl_df_clean1 <- wbl_df_filter1 |>
  select(
    -gr5_19govleaveprov,
    -gr5_20patleave,
    -gr5_21paidprntl
  )


### NOTE:
### Here the scale of the indicators is 0-1, so we multiply by 100 to get a percentage score.
# WBL ENTREPRENEURSHIP (business indicators on entrepreneurship)
wbl_rename1 <- wbl_df_clean1 |>
  mutate(
    wb_wbl_entrepreneurship = gr6_entrprnshp # scale is 0 to 100 already
  )

# WBL LABOR: workplace, pay, parental leave, dismissal of pregnant
wbl_labor1 <- wbl_rename1 |> 
  mutate(
    wb_wbl_labor = rowMeans(
      across(matches("^gr2_|^gr3_|^gr7_") |
               c(gr5_18wpdleave14, gr5_22pregdism)),
      na.rm = TRUE
    ) * 100
  )


# WBL SOCIAL: mobility, marriage, assets
wbl_clean1 <- wbl_labor1 |>
  mutate(
    wb_wbl_social = rowMeans(
      across(matches("^gr1_|^gr4_|^gr7_")),
      na.rm = TRUE
    ) * 100
  )

# Keep only required variables
wbl1_data_to_merge <- wbl_clean1 |>
  select(country_code, year, wb_wbl_entrepreneurship, wb_wbl_social, wb_wbl_labor)


# 1.0 option b -------------------------------------------------------------
# Following the file: https://openknowledge.worldbank.org/entities/publication/853a55af-f1ba-4979-949c-61979af2fbb9 framework
# This is an alternative agroupation:
# Clean up variable names
wbl_df1 <- wbl1_raw |>
  filter(year >= 1990) |>
  # Drop variables
  select(-economycode, -region, -incomegroup, -reportyr, -economy) |>
  rename(country_code = is_ocode) |>
  arrange(country_code, year)


# Select relevant variables
wblb_df_filter <- wbl_df1 |>
  filter(year >= 1990) |>
  select(
    country_code,
    year,
    3:11
  )

### NOTE:
### Here the scale of the indicators is 0-1, so we multiply by 100 to get a percentage score.
# WBL INDEX AND  ENTREPRENEURSHIP 
wblb_rename <- wblb_df_filter |>
  mutate(
    wb_wbl_entrepreneurship = gr6_entrprnshp, # scale is 0 to 100 already
    wb_wbl_sg_law_indx = wbl_index 
  )

# WBL LABOR: workplace, pay, parenthood, dismissal of pregnant
wbl_laborb <- wblb_rename |> 
  mutate(
    wb_wbl_labor = rowMeans(
      across(matches("^gr2_|^gr3_|^gr8_")
    )), na.rm = TRUE
  )


# WBL SOCIAL: mobility, marriage, PARENTHOOD, assets
wbl_cleanb <- wbl_laborb |>
  mutate(
    wb_wbl_social = rowMeans(
      across(matches("^gr1_|^gr4_|^gr5_|^gr7_")),
      na.rm = TRUE
    ) 
  )

  wblb_data_to_merge <- wbl_cleanb |>
  select(country_code, year,  wb_wbl_sg_law_indx,, wb_wbl_entrepreneurship, wb_wbl_social, wb_wbl_labor)

# clean-wbl2.0(2024-2025) --------------------------------------------------------

score_cols <- c(
  "i_economy_lf_index", 
  "x2_mobility_lf_topic_score",
  "x3_work_lf_topic_score",
  "x4_pay_lf_topic_score",
  "x5_marriage_lf_topic_score",
  "x6_parenthood_lf_topic_score",
  "x7_childcare_lf_topic_score",
  "x8_entrepreneurship_lf_topic_score",
  "x9_assets_lf_topic_score"
)

wbl2_clean <- bind_rows(wbl2_raw, .id = "sheet") |>
  clean_names() |>
  rename(country_code = iso_code, year = report_year) |>
  select(all_of(c("country_code", "year", score_cols)))



# Combine those 8 sheets into a single data frame, tracking source sheet
wbl2_clean <- bind_rows(wbl2_raw, .id = "sheet") |> 
  clean_names() |>
  rename(country_code = iso_code,
         year = report_year
  ) |>
  select(-sheet, -economy_code, -region, -income_group, -economy)  |> 
  # drop column not used
   select(-(14:last_col()))



# transform --------------------------------------------------------------

wbl2_data_to_merge <- wbl2_clean |>
  mutate(
    wb_wbl_entrepreneurship = x8_entrepreneurship_lf_topic_score,
    # Extract overall index as well
    wb_wbl_sg_law_indx = i_economy_lf_index,
    wb_wbl_social = rowMeans(
      across(c(
        x2_mobility_lf_topic_score,
        x5_marriage_lf_topic_score,
        x9_assets_lf_topic_score
      )),
      na.rm = TRUE
    ),
    wb_wbl_labor = rowMeans(
      across(c(
        x3_work_lf_topic_score,
        x4_pay_lf_topic_score,
        x6_parenthood_lf_topic_score
        # x7_childcare_lf_topic_score
      )),
      na.rm = TRUE
    )
  ) |>
  select(country_code, year, wb_wbl_sg_law_indx, wb_wbl_entrepreneurship, wb_wbl_social, wb_wbl_labor)

# Add version column to each dataset
wbl1_data_to_merge <- mutate(wbl1_data_to_merge, wbl_version = "1.0")
wbl2_data_to_merge <- mutate(wbl2_data_to_merge, wbl_version = "2.0")
wblb_data_to_merge <- mutate(wblb_data_to_merge, wbl_version = "1.0b")


# =============================================================================
# WBL 1.0 (<=2023) vs WBL 2.0 (2024+) framework compatibility checks
# -----------------------------------------------------------------------------
# 1. Item inventory: what actually feeds each construct in each era?
# -----------------------------------------------------------------------------
# WBL 1.0 group numbering (inferred -- verify against the .dta labels):
#   gr1 mobility | gr2 workplace | gr3 pay | gr4 marriage | gr5 parenthood
#   gr6 entrepreneurship | gr7 assets | gr8 pension
# WBL 2.0 topics: safety, mobility, workplace, pay, marriage, parenthood,
#   childcare, entrepreneurship, assets, pension -- each x 3 pillars
#   (legal frameworks / supportive frameworks / expert opinions).
#   You use `_lf_` = legal frameworks, the de jure pillar matching 1.0.
#   Confirm that before trusting anything below:

names(wbl2_clean)[str_detect(names(wbl2_clean), "topic_score")]

items_v1 <- list(
  social = wbl_df_clean1 |> select(matches("^gr1_|^gr4_|^gr7_")) |> names(),
  labor  = wbl_df_clean1 |>
    select(matches("^gr2_|^gr3_|^gr7_"), gr5_18wpdleave14, gr5_22pregdism) |>
    names(),
  entrep = "gr6_entrprnshp"
)

str(items_v1)

# Must be character(0) -- anything here is double-counted:
intersect(items_v1$social, items_v1$labor)

# Which gr* columns are silently unused? (expect gr8 pension + dropped leave vars)
setdiff(
  wbl_df_clean1 |> select(starts_with("gr")) |> names(),
  unlist(items_v1, use.names = FALSE)
)

# Items per construct per era. 1.0 averages QUESTIONS, 2.0 averages TOPICS.
tibble(
  construct  = c("social", "labor", "entrep"),
  n_items_v1 = c(length(items_v1$social), length(items_v1$labor), 1L),
  n_items_v2 = c(3L, 4L, 1L)   # social: mobility/marriage/assets
)                              # labor: work/pay/parenthood/CHILDCARE (no v1 twin)


# -----------------------------------------------------------------------------
# 2. Scale check -- catches the un-rescaled entrepreneurship immediately
# -----------------------------------------------------------------------------
scale_check <- bind_rows(
  wbl1_data_to_merge |> mutate(v = "1.0"),
  wbl2_data_to_merge |> mutate(v = "2.0")
) |>
  pivot_longer(starts_with("wb_wbl"), names_to = "construct", values_to = "value") |>
  group_by(construct, v) |>
  summarise(
    n          = sum(!is.na(value)),
    min        = min(value, na.rm = TRUE),
    max        = max(value, na.rm = TRUE),
    mean       = mean(value, na.rm = TRUE),
    sd         = sd(value, na.rm = TRUE),
    share_le_1 = mean(value <= 1, na.rm = TRUE),   # ~1 => still on 0-1
    .groups = "drop"
  ) |>
  arrange(construct, v)

scale_check


scale_check_all <- bind_rows(
  wbl1_data_to_merge |> mutate(v = "1.0"),
  wblb_data_to_merge |> mutate(v = "1.0b"),
  wbl2_data_to_merge |> mutate(v = "2.0")
) |>
  pivot_longer(starts_with("wb_wbl"), names_to = "construct", values_to = "value") |>
  group_by(construct, v) |>
  summarise(
    n          = sum(!is.na(value)),
    min        = min(value, na.rm = TRUE),
    max        = max(value, na.rm = TRUE),
    mean       = mean(value, na.rm = TRUE),
    sd         = sd(value, na.rm = TRUE),
    share_le_1 = mean(value <= 1, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(construct, v)

scale_check_all

# -----------------------------------------------------------------------------
# 3. Cross-sectional comparison: v1.0/1.0b (2023) vs v2.0 (2024)
# -----------------------------------------------------------------------------
# Get latest year from v1.0 datasets and earliest from v2.0
latest_v1 <- wbl1_data_to_merge |> filter(year == max(year))
latest_v1b <- wblb_data_to_merge |> filter(year == max(year))
earliest_v2 <- wbl2_data_to_merge |> filter(year == min(year))

# Join by country only (different years)
cross_compare <- latest_v1 |>
  inner_join(
    latest_v1b |> select(-wbl_version, -year),
    by = "country_code",
    suffix = c("_v1", "_v1b")
  ) |>
  inner_join(
    earliest_v2 |> select(-wbl_version, -year, -wb_wbl_sg_law_indx),
    by = "country_code"
  ) |>
  rename_with(~paste0(., "_v2"), starts_with("wb_wbl_") & !ends_with("_v1") & !ends_with("_v1b"))

cat("Countries in cross-sectional comparison:", nrow(cross_compare), "\n")

# -----------------------------------------------------------------------------
# 4. Country-level scatter plots: v1.0 vs v2.0 and v1.0b vs v2.0
# -----------------------------------------------------------------------------

library(ggplot2)
library(patchwork)

# Prepare data for scatter plots (2023 vs 2024)
scatter_data <- cross_compare |>
  select(country_code, year, 
         wb_wbl_entrepreneurship_v1, wb_wbl_entrepreneurship_v1b, wb_wbl_entrepreneurship_v2,
         wb_wbl_social_v1, wb_wbl_social_v1b, wb_wbl_social_v2,
         wb_wbl_labor_v1, wb_wbl_labor_v1b, wb_wbl_labor_v2)

# Theme for consistent plotting
theme_scatter <- theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", size = 11),
    plot.subtitle = element_text(size = 9, color = "gray30"),
    axis.title = element_text(size = 9),
    panel.grid.minor = element_blank()
  )

# Function to create scatter plot with 45-degree reference line
plot_45_scatter <- function(data, x_var, y_var, title, subtitle, xlab, ylab) {
  # Calculate correlation
  cor_val <- cor(data[[x_var]], data[[y_var]], use = "pairwise.complete.obs")
  
  # Get axis limits
  lims <- c(
    min(c(data[[x_var]], data[[y_var]]), na.rm = TRUE),
    max(c(data[[x_var]], data[[y_var]]), na.rm = TRUE)
  )
  
  ggplot(data, aes(x = .data[[x_var]], y = .data[[y_var]])) +
    # 45-degree line (perfect agreement)
    geom_abline(intercept = 0, slope = 1, 
                linetype = "dashed", color = "gray40", linewidth = 0.5) +
    # Points
    geom_point(alpha = 0.6, size = 2, color = "#2C3E50") +
    # Smooth trend
    geom_smooth(method = "lm", se = TRUE, color = "#E74C3C", 
                linewidth = 0.8, alpha = 0.2) +
    # Correlation annotation
    annotate("text", x = lims[1] + (lims[2] - lims[1]) * 0.05, 
             y = lims[2] - (lims[2] - lims[1]) * 0.05,
             label = sprintf("r = %.3f", cor_val),
             hjust = 0, vjust = 1, size = 3.5, fontface = "bold") +
    # Styling
    coord_fixed(ratio = 1, xlim = lims, ylim = lims) +
    labs(title = title, subtitle = subtitle, x = xlab, y = ylab) +
    theme_scatter
}

# ENTREPRENEURSHIP plots
p_entrep_1_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_entrepreneurship_v1", 
  "wb_wbl_entrepreneurship_v2",
  "Entrepreneurship: v1.0 (2023) vs v2.0 (2024)",
  "Points above line = higher score in v2.0",
  "WBL 1.0 Score (2023)",
  "WBL 2.0 Score (2024)"
)

p_entrep_1b_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_entrepreneurship_v1b", 
  "wb_wbl_entrepreneurship_v2",
  "Entrepreneurship: v1.0b (2023) vs v2.0 (2024)",
  "Alternative grouping comparison",
  "WBL 1.0b Score (2023)",
  "WBL 2.0 Score (2024)"
)

# SOCIAL plots
p_social_1_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_social_v1", 
  "wb_wbl_social_v2",
  "Social: v1.0 (2023) vs v2.0 (2024)",
  "Mobility, Marriage, Assets",
  "WBL 1.0 Score (2023)",
  "WBL 2.0 Score (2024)"
)

p_social_1b_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_social_v1b", 
  "wb_wbl_social_v2",
  "Social: v1.0b (2023) vs v2.0 (2024)",
  "Includes Parenthood in v1.0b",
  "WBL 1.0b Score (2023)",
  "WBL 2.0 Score (2024)"
)

# LABOR plots
p_labor_1_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_labor_v1", 
  "wb_wbl_labor_v2",
  "Labor: v1.0 (2023) vs v2.0 (2024)",
  "Workplace, Pay, Parenthood aspects",
  "WBL 1.0 Score (2023)",
  "WBL 2.0 Score (2024)"
)

p_labor_1b_2 <- plot_45_scatter(
  scatter_data,
  "wb_wbl_labor_v1b", 
  "wb_wbl_labor_v2",
  "Labor: v1.0b (2023) vs v2.0 (2024)",
  "Different parenthood grouping",
  "WBL 1.0b Score (2023)",
  "WBL 2.0 Score (2024)"
)

# Combine plots using patchwork
combined_entrep <- p_entrep_1_2 + p_entrep_1b_2 +
  plot_annotation(
    title = "Entrepreneurship Score Comparison Across WBL Versions",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

combined_social <- p_social_1_2 + p_social_1b_2 +
  plot_annotation(
    title = "Social Score Comparison Across WBL Versions",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

combined_labor <- p_labor_1_2 + p_labor_1b_2 +
  plot_annotation(
    title = "Labor Score Comparison Across WBL Versions",
    theme = theme(plot.title = element_text(face = "bold", size = 14))
  )

# Display plots
print(combined_entrep)
print(combined_social)
print(combined_labor)

# All-in-one comparison
all_plots <- (p_entrep_1_2 | p_entrep_1b_2) /
             (p_social_1_2 | p_social_1b_2) /
             (p_labor_1_2 | p_labor_1b_2) +
  plot_annotation(
    title = "WBL Framework Comparison: Country-Level Correlations",
    subtitle = "Comparing 2023 scores (v1.0 and v1.0b) with 2024 scores (v2.0) | Dashed line = perfect agreement",
    theme = theme(
      plot.title = element_text(face = "bold", size = 16),
      plot.subtitle = element_text(size = 11, color = "gray30")
    )
  )

print(all_plots)

# Identify countries with largest deviations
deviations <- scatter_data |>
  mutate(
    entrep_dev_1 = wb_wbl_entrepreneurship_v2 - wb_wbl_entrepreneurship_v1,
    entrep_dev_1b = wb_wbl_entrepreneurship_v2 - wb_wbl_entrepreneurship_v1b,
    social_dev_1 = wb_wbl_social_v2 - wb_wbl_social_v1,
    social_dev_1b = wb_wbl_social_v2 - wb_wbl_social_v1b,
    labor_dev_1 = wb_wbl_labor_v2 - wb_wbl_labor_v1,
    labor_dev_1b = wb_wbl_labor_v2 - wb_wbl_labor_v1b
  )

cat("\n=== Countries with Largest Score Changes (v1.0 -> v2.0) ===\n")

cat("\nEntrepreneurship - Top 5 Gainers:\n")
print(deviations |> 
  arrange(desc(entrep_dev_1)) |> 
  select(country_code, entrep_dev_1) |> 
  head(5))

cat("\nEntrepreneurship - Top 5 Decliners:\n")
print(deviations |> 
  arrange(entrep_dev_1) |> 
  select(country_code, entrep_dev_1) |> 
  head(5))

cat("\nSocial - Top 5 Gainers:\n")
print(deviations |> 
  arrange(desc(social_dev_1)) |> 
  select(country_code, social_dev_1) |> 
  head(5))

cat("\nLabor - Top 5 Gainers:\n")
print(deviations |> 
  arrange(desc(labor_dev_1)) |> 
  select(country_code, labor_dev_1) |> 
  head(5))
# -----------------------------------------------------------------------------
# 5. Distribution comparison - box plots data
# -----------------------------------------------------------------------------
version_comparison <- bind_rows(
  wblb_data_to_merge,
  wbl2_data_to_merge
) |>
  pivot_longer(
    cols = starts_with("wb_wbl_") & !contains("version") & !contains("sg_law"),
    names_to = "construct",
    values_to = "value"
  ) |>
  mutate(
    construct = str_remove(construct, "wb_wbl_"),
    construct = str_to_title(construct)
  )

# Summary by version and construct
version_summary <- version_comparison |>
  group_by(wbl_version, construct) |>
  summarise(
    n_obs = sum(!is.na(value)),
    mean = mean(value, na.rm = TRUE),
    median = median(value, na.rm = TRUE),
    sd = sd(value, na.rm = TRUE),
    min = min(value, na.rm = TRUE),
    max = max(value, na.rm = TRUE),
    .groups = "drop"
  ) |>
  arrange(construct, wbl_version)

version_summary


# -----------------------------------------------------------------------------
# 6. Consolidate datasets for export
# -----------------------------------------------------------------------------

# bind the two datasets together
wbl_data  <- bind_rows(wblb_data_to_merge, wbl2_data_to_merge) |> 
  arrange(country_code, year)



# Add metadata
wbl_data <- wbl_data |>
  add_plmetadata(source = "https://wbl.worldbank.org/en/wbl-data",
                 other_info = "WBL Data for 1971-2024 and WBL Data for 2026. Accessed on 8/26/2026.")


# export data -----------------------------------------------------
usethis::use_data(wbl_data, overwrite = TRUE)

