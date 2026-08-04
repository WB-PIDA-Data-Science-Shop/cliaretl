## code to prepare `bready` dataset goes here
# last updated: 7/21/2026
library(openxlsx)
library(janitor)

# download zip file
url <- "https://www.worldbank.org/content/dam/sites/b-ready/documents/excel/B-READY_ALL_DATA_2025.zip"
temp_zip <- tempfile(fileext = ".zip")
download.file(url, destfile = temp_zip)
unzip(temp_zip, exdir = tempdir())

# read in excel file
xlsx_file <- list.files(tempdir(), pattern = "01_B-READY-2025-PILLAR-TOPIC-SCORES.xlsx", full.names = TRUE)
bready_input <- read.xlsx(
  xlsx_file,
  sheet = "00_B-READY_Pillar_Score",
  rows = 1:102
)

# clean data
bready <- bready_input |>
  clean_names() |>
  select(
    economy,
    country_code = economy_code,
    everything()
  )

bready <- bready |>
  add_plmetadata(
    source = url,
    other_info = "The data is from the World Bank B-READY dataset and represents various B-Ready pillar scores for countries."
  )

usethis::use_data(bready, overwrite = TRUE)