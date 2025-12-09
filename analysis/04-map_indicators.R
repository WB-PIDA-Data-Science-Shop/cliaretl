# Map indicators for Shiny App (cliarapp)
# source: https://datacatalog.worldbank.org/int/search/dataset/0038272
# Download instructions:
# - Go to the website, under the title "World Bank Official Boundaries"
#   make sure you select the Version 5(latest - Metadata last updated on - Jun 17, 2025)
# - Click on the "World Bank Official Boundaries (GeoJSON)" button
# - Open the list, and click on both the following files:
#    a. World Bank Official Boundaries - Admin 0.geojson
#    b. World Bank Official Boundaries - Admin 0_all_layers.geojson
#
# access date: 10/03/2025
library(dplyr)
library(tidyr)
library(stringr)
library(sf)
library(here)
library(readr)
library(janitor)
library(sf)
library(rmapshaper)
library(geojsonio)


devtools::load_all()

# ---- data inputs ---------------------------------------------------------
ctf <- closeness_to_frontier_static
avg_columns <- names(ctf)[grep("_avg", names(ctf))]
var_lists <- get_variable_lists(db_variables)

raw_indicators <- readRDS(here("data-raw", "output", "compiled_indicators.rds"))

# world_map <- read_sf(
#   here("data-raw","input","wb","World Bank Official Boundaries - Admin 0.geojson")
# )
#
# disputed_areas <- read_sf(
#   here("data-raw","input","wb","World Bank Official Boundaries - Admin 0_all_layers.geojson")
# )

options(timeout = 600)

world_map <-
  geojsonio::geojson_read(readLines("data-raw/input/wb/worldmap_url.txt")[[1]],
                          what  = "sp") |>
  st_as_sf()

disputed_areas <-
  geojsonio::geojson_read(readLines("data-raw/input/wb/disputedareas_url.txt")[[1]],
                          what = "sp") |>
  st_as_sf()

# ---- merge base + disputed layers ----------------------------------------
disputed_areas_renamed <- disputed_areas |>
  transmute(country_code = str_trim(WB_A3)) |>
  filter(!is.na(country_code), country_code != "")

world_map_renamed <- world_map |>
  select(country_code = WB_A3)

world_map_full_picture <- bind_rows(world_map_renamed, disputed_areas_renamed)

# ---- geometry prep + simplification --------------------------------------
world_map_wrapped <- world_map_full_picture |>
  st_transform(4326) |>
  st_wrap_dateline() |>
  st_transform(crs = "+proj=robin")

# Use rmapshaper if available, else fallback to st_simplify
if (requireNamespace("rmapshaper", quietly = TRUE)) {
  simplified_world_map <- rmapshaper::ms_simplify(
    world_map_wrapped,
    keep = 0.05,         # keep 5% of vertices → very light
    keep_shapes = TRUE
  )
} else {
  message("rmapshaper not installed; using st_simplify() fallback.")
  simplified_world_map <- st_simplify(
    world_map_wrapped,
    dTolerance = 0.2,
    preserveTopology = TRUE
  )
}

# round coordinate precision to reduce file size (~3 decimal places)
simplified_world_map <- st_set_precision(simplified_world_map, 1e3)

# ---- indicator binning ---------------------------------------------------
long_cols <- intersect(c(var_lists$vars_static_ctf, avg_columns), names(ctf))

breaks <- c(0, 0.2, 0.4, 0.6, 0.8, 1.0)
labels <- c("0.0 - 0.2", "0.2 - 0.4", "0.4 - 0.6", "0.6 - 0.8", "0.8 - 1.0")

ctf_bins <- ctf |>
  pivot_longer(cols = all_of(long_cols), names_to = "indicator", values_to = "ctf") |>
  mutate(
    bin = cut(ctf, breaks = breaks, labels = labels, include.lowest = TRUE, right = TRUE),
    bin = as.character(bin),
    bin = tidyr::replace_na(bin, "No data")
  ) |>
  pivot_wider(
    id_cols = starts_with("country_"),
    names_from = indicator,
    values_from = c(bin, ctf)
  )

# ---- latest available values per indicator -------------------------------
compiled_raw_for_joining <- raw_indicators |>
  select(-income_group, -region) |>
  pivot_longer(
    cols = -c(country_code, country_name, year),
    names_to = "name",
    values_to = "value"
  ) |>
  filter(!is.na(value)) |>
  group_by(country_code, name) |>
  slice_max(year, n = 1, with_ties = FALSE) |>
  ungroup() |>
  pivot_wider(
    id_cols = country_code,
    names_from = name,
    values_from = c(value, year)
  )

# ---- join everything -----------------------------------------------------
complete_world_map_lowres <- simplified_world_map |>
  left_join(compiled_raw_for_joining, by = "country_code") |>
  left_join(ctf_bins, by = dplyr::join_by(country_code == country_code))

# ---- size check ----------------------------------------------------------
orig_size <- utils::object.size(world_map_full_picture)
lowr_size <- utils::object.size(complete_world_map_lowres)
cat(
  "\nSize (original geometries):", format(orig_size, units = "MB"),
  "\nSize (LOW-RES complete map):", format(lowr_size, units = "MB"), "\n"
)

### one additional check

complete_world_map_lowres <-
  st_make_valid(complete_world_map_lowres)

# ---- save ----------------------------------------------------------------
write_rds(
  complete_world_map_lowres,
  here("data-raw","output","indicators_map.rds")
)