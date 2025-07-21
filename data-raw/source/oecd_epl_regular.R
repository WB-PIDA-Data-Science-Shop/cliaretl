
############################################
#epl_regular.csv
##  Source: OECD
##  path: G:\data\cliar\input\oecd\oecd_2025

############################################

## oecd

library(dplyr)       # provides %>% and rename()
library(readxl)

# import xls:

epl <- readxl::read_excel("G:/data/cliar/input/oecd/oecd_2025/epl_regular.xlsx")

## Rename columns
epl_renamed <- epl %>%
  rename(
    country      = Reference_area,
    country_code = REF_AREA,
    year         = TIME_PERIOD,
    Value        = OBS_VALUE
  )

head(epl_renamed)
View(epl_renamed)


## Keep only country country year Value

epl_selected <- epl_renamed %>%
  select(country, country_code, year, Value)

dbvar_epl_reg <- readxl::read_excel("data-raw/input/cliar/db_variables.xlsx")

## pull the data
eplraw_path <- "data-raw/input/epl_reg/epl_regu_raw.xlsx"

View(epl_selected)


## oecd_epl

oecd_epl <- epl_selected

rm(epl_selected)

### add to the metadata pipeline

oecd_epl <-
  oecd_epl |>
  add_plmetadata(source = oecd,
                 other_info = "")

usethis::use_data(oecd_epl, overwrite = TRUE)


          ##THE END##





##renv::restore()
##devtools:: load_all()


url = "https://sdmx.oecd.org/public/rest/data/OECD.SDD.STES,DSD_STES@DF_CLI/.M.LI...AA...H?startPeriod=2023-02&dimensionAtObservation=AllDimensions&format=csvfilewithlabels"

df<-read.csv(url)

View(df)

# URL

url <- "https://sdmx.oecd.org/public/rest/data/OECD.ELS.JAI,DSD_EPL@DF_EPL/.EPL_OV..VERSION4?startPeriod=2000&dimensionAtObservation=AllDimensions&format=csvfile"

# Read as a data frame
oecd_epl <- read.csv(url, stringsAsFactors = FALSE)

# Check rows name
head(oecd_epl)
str(oecd_epl)
summary(oecd_epl)
