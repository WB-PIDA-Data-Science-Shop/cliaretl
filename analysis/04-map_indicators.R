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



# read-in -----------------------------------------------------------------

devtools::load_all()

ctf <- closeness_to_frontier_static

avg_columns = names(ctf)[grep("_avg", names(ctf))]

var_lists <- get_variable_lists(db_variables)

db_variables <- db_variables

raw_indicators <-
  readRDS(
    here("data-raw",
         "output",
         "compiled_indicators.rds")
  )


world_map <-
  read_sf(
    here(
      "data-raw",
      "input",
      "wb",
      "World Bank Official Boundaries - Admin 0.geojson"
    )
  )

disputed_areas <-
  read_sf(
    here(
      "data-raw",
      "input",
      "wb",
      "World Bank Official Boundaries - Admin 0_all_layers.geojson"
    )
  )



# cleaning ----------------------------------------------------------------
# In this section, we combine the world map data with disputed areas,
# in order to address potential boundary conflicts.

disputed_areas_renamed <-
  disputed_areas |>
  transmute(country_code = str_trim(WB_A3)) |>
  filter(
    !is.na(country_code),
    country_code != ""
  )

world_map_renamed <-
  world_map |>
  select(country_code = WB_A3)

world_map_full_picture <-
  world_map_renamed |>
  bind_rows(
    disputed_areas_renamed
  )

# Here is necessary to simplify the world map to improve loading performance on our Shiny App.
simplified_world_map <-
  world_map_full_picture |>
  # fix wrapping of dateline to avoid spurious ribbon
  # source: https://github.com/r-spatial/sf/issues/1046
  st_transform(4326) |>
  st_wrap_dateline() |>
  # project into robinson coordinate system
  st_transform(crs = '+proj=robin') |>
  # simplify polygons to improve rendering
  st_simplify(
    dTolerance = 0.05
  )

# prepare indicators ------------------------------------------------------

# keep only columns that actually exist in `ctf`
long_cols <- intersect(c(var_lists$vars_static_ctf, var_lists$avg_columns), names(ctf))

# desired bins: [0.0,0.2) [0.2,0.4) [0.4,0.6) [0.6,0.8) [0.8,1.0]
# Use cut() for clarity and stability (inclusive on the right for last bin)
breaks <- c(0, 0.2, 0.4, 0.6, 0.8, 1.0)
labels <- c("0.0 - 0.2", "0.2 - 0.4", "0.4 - 0.6", "0.6 - 0.8", "0.8 - 1.0")

# generate the bins and reshape to long format
ctf_bins <-
  ctf |>
  pivot_longer(
    cols = all_of(long_cols),
    names_to = "indicator",
    values_to = "ctf"
  ) |>
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

# join everything ---------------------------------------------------------
compiled_raw_for_joining <-
  raw_indicators |>
  # drop non-measure fields you don't want in the long step
  select(-income_group, -region) |>
  # pivot *all* columns except identifiers you want to keep as id
  pivot_longer(
    cols = -c(country_code, country_name, year),
    names_to = "name",
    values_to = "value"
  ) |>
  # keep rows with data
  filter(!is.na(value)) |>
  # keep most recent year per country & indicator
  group_by(country_code, name) |>
  slice_max(year, n = 1, with_ties = FALSE) |>
  ungroup() |>
  # widen to value_<indicator> and year_<indicator>
  pivot_wider(
    id_cols = country_code,
    names_from = name,
    values_from = c(value, year)
  )

# join raw indicators and ctf bins to the world map
complete_world_map <-
  simplified_world_map |>
  left_join(
    compiled_raw_for_joining
  ) |>
  left_join(
    ctf_bins
  )

# save output -------------------------------------------------------------

complete_world_map |>
  write_rds(
    here(
      "data-raw",
      "output",
      "indicators_map.rds"
    )
  )





