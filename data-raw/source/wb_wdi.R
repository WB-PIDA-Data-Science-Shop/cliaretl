## code to prepare `wdi_indicators` dataset goes here
# source: WDI Package https://cran.r-project.org/web/packages/WDI/WDI.pdf
# access date: 6/10/2025
library(here)
library(dplyr)
library(readr)
library(stringr)
library(WDI)
library(janitor)
library(countrycode)

# read-in -----------------------------------------------------------------

# Download indicators
# Define the start and end years for data retrieval
start_year <- 1990
end_year <- 2023

# Define a comprehensive list of World Bank Development Indicators
# Grouped for better readability and easier management.
# Indicators are sourced from the World Bank Metadata Glossary:
# https://databank.worldbank.org/metadataglossary/all/series


# For problematic indicator: # "EN.ATM.CO2E.PP.GD.KD", it's recommended to:
# replace it for the "EN.GHG.CO2.RT.GDP.PP.KD", Carbon intensity of GDP (kg CO2e per 2021 PPP $ of GDP)
# Implement it also in the compiled indicators

wdi_indicators_list <- c(
  # Macroeconomic Indicators
  "GC.DOD.TOTL.GD.ZS",        # Central government debt, total (% of GDP)
  # "EN.ATM.CO2E.PP.GD.KD",   # CO2 emissions (kg per 2021 PPP $ of GDP) [Dropped]
  "EN.GHG.CO2.RT.GDP.PP.KD",  # Carbon intensity of GDP (kg CO2e per 2021 PPP $ of GDP) [Replaced]
  "BN.CAB.XOKA.GD.ZS",        # Current account balance (% of GDP)
  "GC.XPN.TOTL.GD.ZS",        # Expense (% of GDP)
  "NE.EXP.GNFS.ZS",           # Exports of goods and services (% of GDP)
  "NE.CON.TOTL.ZS",           # Final consumption expenditure (% of GDP)
  "BX.KLT.DINV.WD.GD.ZS",     # Foreign direct investment, net inflows (% of GDP)
  "BM.KLT.DINV.WD.GD.ZS",     # Foreign direct investment, net outflows (% of GDP)
  "NY.GDP.MKTP.KD",            # GDP (constant 2015 US$)
  "NY.GDP.DEFL.ZS",           # GDP deflator (base year varies by country)
  "NY.GDP.DEFL.ZS.AD",        # GDP deflator: linked series (base year varies by country)
  "NY.GDP.MKTP.KD.ZG",        # GDP growth (annual %)
  "NY.GDP.PCAP.KD",           # GDP per capita (constant 2015 US$)
  "NY.GDP.PCAP.KD.ZG",        # GDP per capita growth (annual %)
  "NY.GDP.PCAP.PP.KD",        # GDP per capita, PPP (constant 2017 international $)
  "NY.GDP.MKTP.PP.KD",        # GDP, PPP (constant 2017 international $)
  "NE.CON.GOVT.ZS",           # General government final consumption expenditure (% of GDP)
  "NE.GDI.TOTL.ZS",           # Gross capital formation (% of GDP)
  "NY.GDS.TOTL.ZS",           # Gross domestic savings (% of GDP)
  "NE.GDI.FTOT.ZS",           # Gross fixed capital formation (% of GDP)
  "NE.DAB.TOTL.ZS",           # Gross national expenditure (% of GDP)
  "NY.GNS.ICTR.ZS",           # Gross national income (constant 2015 US$)
  "NE.IMP.GNFS.ZS",           # Imports of goods and services (% of GDP)
  "NY.GDP.DEFL.KD.ZG",        # Inflation, GDP deflator (annual %)
  "NY.GDP.DEFL.KD.ZG.AD",     # Inflation, GDP deflator: linked series (annual %)
  "NV.IND.MANF.ZS",           # Manufacturing, value added (% of GDP)
  "MS.MIL.XPND.GD.ZS",        # Military expenditure (% of GDP)
  "NY.GDP.MINR.RT.ZS",        # Mineral rents (% of GDP)
  "NY.GDP.NGAS.RT.ZS",        # Natural gas rents (% of GDP)
  "GC.NLD.TOTL.GD.ZS",        # Net lending/borrowing (% of GDP)
  "NY.GDP.PETR.RT.ZS",        # Oil rents (% of GDP)
  "BX.TRF.PWKR.DT.GD.ZS",     # Personal remittances, received (% of GDP)
  "GC.REV.XGRT.GD.ZS",        # Revenue, excluding grants (% of GDP)
  "NV.SRV.TOTL.ZS",           # Services, value added (% of GDP)
  "GC.TAX.TOTL.GD.ZS",        # Tax revenue (% of GDP)
  "NY.GDP.TOTL.RT.ZS",        # Total natural resource rents (% of GDP)
  "NE.TRD.GNFS.ZS",           # Trade (% of GDP)
  "NY.GNP.MKTP.KD",           # GNI (constant 2015 US$) - Equivalent to NY.GNS.ICTR.ZS
  "DT.DOD.DECT.GN.ZS",        # External debt stocks (% of GNI)
  "NY.GNP.MKTP.KD.ZG",        # GNI growth (annual %)
  "NY.GNP.PCAP.KD",           # GNI per capita (constant 2015 US$)
  "NY.GNP.PCAP.KD.ZG",        # GNI per capita growth (annual %)
  "NY.GNP.PCAP.PP.KD",        # GNI per capita, PPP (constant 2017 international $)
  "NY.GNP.MKTP.PP.KD",        # GNI, PPP (constant 2017 international $)
  "DT.ODA.ODAT.GN.ZS",        # Net official development assistance and official aid received (% of GNI)
  "DC.ODA.TOTL.GN.ZS",        # Net official development assistance and official aid received (current US$)
  "DT.TDS.DPPG.GN.ZS",        # Debt service (PPG and IMF only, % of GNI)
  "DT.TDS.DECT.GN.ZS",        # Debt service on external debt (% of GNI)
  "DT.DOD.PVLX.GN.ZS",        # Present value of external debt (% of GNI)
  "DT.DOD.DSTC.ZS",           # Debt service (debt service on external debt) (% of exports of goods, services and primary income)
  "DT.DOD.DSTC.IR.ZS",        # Debt service (IBRD and IDA, % of exports of goods, services and primary income)
  "DT.TDS.DECT.EX.ZS",        # Debt service (TDS, total debt service) (% of exports of goods, services and primary income)
  "FI.RES.TOTL.DT.ZS",        # Total reserves (% of total external debt)
  "DT.DOD.DSTC.XP.ZS",        # Debt service (debt service on external debt) (% of exports of goods, services and primary income)
  "DT.TDS.MLAT.PG.ZS",        # Debt service on multilateral debt (% of goods, services and primary income exports)
  "GC.REV.SOCL.ZS",           # Social contributions (% of revenue)
  "MS.MIL.TOTL.TF.ZS",        # Armed forces personnel, total (% of total labor force)
  "SL.UEM.TOTL.NE.ZS",        # Unemployment, total (% of total labor force) (modeled ILO estimate) - This might be a duplicate of SL.UEM.TOTL.ZS
  "SL.UEM.TOTL.ZS",           # Unemployment, total (% of total labor force) (modeled ILO estimate)

  # Social and Human Development Indicators
  "SH.XPD.GHED.GD.ZS",        # Domestic general government health expenditure (% of GDP)
  "SE.XPD.TOTL.GD.ZS",        # Expenditure on education (% of GDP)
  "SE.XPD.PRIM.PC.ZS",        # Expenditure per student, primary (% of GDP per capita)
  "SE.XPD.SECO.PC.ZS",        # Expenditure per student, secondary (% of GDP per capita)
  "SE.XPD.TERT.PC.ZS",        # Expenditure per student, tertiary (% of GDP per capita)
  "SE.ADT.LITR.FE.ZS",        # Literacy rate, adult female (% of females ages 15 and above)
  "SE.ADT.LITR.MA.ZS",        # Literacy rate, adult male (% of males ages 15 and above)
  "SE.ADT.LITR.ZS",           # Literacy rate, adult total (% of people ages 15 and above)
  "SH.DYN.MORT",              # Mortality rate, under-5 (per 1,000 live births)
  "SH.STA.ANVC.ZS",           # Pregnant women receiving prenatal care (% of pregnant women) - Check if "SH.STA.PRSC.ZS" is an older code.
  "SH.STA.MMRT",              # Maternal mortality ratio (modeled estimate, per 100,000 live births) - Check if "SH.MMR.RATIO" is an older code.
  "SH.DYN.MORT.FE",           # Mortality rate, adult, female (per 1,000 female adults)
  "SH.DYN.MORT.MA",           # Mortality rate, adult, male (per 1,000 male adults)
  "SE.COM.DURS",              # Compulsory education, duration (years)
  "SE.XPD.CPRM.ZS",           # Current education expenditure, primary (% of total expenditure in primary public institutions)
  "SE.XPD.CSEC.ZS",           # Current education expenditure, secondary (% of total expenditure in secondary public institutions)
  "SE.XPD.CTER.ZS",           # Current education expenditure, tertiary (% of total expenditure in tertiary public institutions)
  "SE.XPD.CTOT.ZS",           # Current education expenditure, total (% of total expenditure in all public institutions)
  "SE.XPD.TOTL.GB.ZS",        # Expenditure on education, total (% of government expenditure)
  "SE.SEC.TCAQ.LO.ZS",        # Trained teachers in lower secondary education (% of total teachers)
  "SE.PRE.TCAQ.ZS",           # Trained teachers in preprimary education (% of total teachers)
  "SE.PRM.TCAQ.ZS",           # Trained teachers in primary education (% of total teachers)
  "SE.SEC.TCAQ.ZS",           # Trained teachers in secondary education (% of total teachers)
  "SE.SEC.TCAQ.UP.ZS",        # Trained teachers in upper secondary education (% of total teachers)
  "SE.PRM.TENR",              # Primary school enrollment (% net)
  "SH.STA.BRTC.ZS",           # Births attended by skilled health personnel (% of total)
  "SH.MED.CMHW.P3",           # Community health workers (per 1,000 people)
  "SH.XPD.CHEX.GD.ZS",        # Current health expenditure (% of GDP)
  "SH.XPD.OOPC.CH.ZS",        # Out-of-pocket expenditure (% of current health expenditure)
  "SH.XPD.OOPC.PP.CD",        # Out-of-pocket expenditure per capita (current US$)
  "SI.POV.MDIM",              # Multidimensional poverty index
  "SI.POV.MDIM.XQ",           # Multidimensional poverty index (data quality: average, fair, good, poor)
  "SI.POV.GAPS",              # Poverty gap at national poverty lines (% of poverty line)
  "SI.POV.LMIC.GP",           # Poverty gap at $3.65 a day (2017 PPP) (% of poverty line) - for lower middle income countries
  "SI.POV.UMIC.GP",           # Poverty gap at $6.85 a day (2017 PPP) (% of poverty line) - for upper middle income countries
  "SI.POV.DDAY",              # Poverty headcount ratio at $2.15 a day (2017 PPP) (% of population)
  "SI.POV.LMIC",              # Poverty headcount ratio at $3.65 a day (2017 PPP) (% of population) - for lower middle income countries
  "SI.POV.UMIC",              # Poverty headcount ratio at $6.85 a day (2017 PPP) (% of population) - for upper middle income countries
  "SI.POV.NAHC",              # Poverty headcount ratio at national poverty lines (% of population)
  "SE.PRM.ENRL.TC.ZS",        # Primary enrollment, female (% gross)
  "SE.SEC.ENRL.TC.ZS",        # Secondary enrollment, female (% gross)
  "SE.TER.ENRL.TC.ZS",        # Tertiary enrollment, female (% gross)
  "SH.MED.BEDS.ZS",           # Hospital beds (per 1,000 people)
  "SH.MED.PHYS.ZS",           # Physicians (per 1,000 people)
  "SP.REG.BRTH.ZS",           # Completeness of birth registration, total (%)
  "SP.REG.BRTH.RU.ZS",        # Completeness of birth registration, rural (%)
  "SP.REG.BRTH.UR.ZS",        # Completeness of birth registration, urban (%)

  # CPIA Indicators (Country Policy and Institutional Assessment)
  "IQ.CPA.HRES.XQ",           # CPIA: Human resources (quality of public administration) (1=low to 6=high)
  "IQ.CPA.BREG.XQ",           # CPIA: Business regulatory environment (1=low to 6=high)
  "IQ.CPA.DEBT.XQ",           # CPIA: Debt policy (1=low to 6=high)
  "IQ.CPA.ECON.XQ",           # CPIA: Economic management (1=low to 6=high)
  "IQ.CPA.REVN.XQ",           # CPIA: Revenue mobilization (1=low to 6=high)
  "IQ.CPA.PRES.XQ",           # CPIA: Quality of public administration (1=low to 6=high)
  "IQ.CPA.FISP.XQ",           # CPIA: Fiscal policy (1=low to 6=high)
  "IQ.CPA.FINS.XQ",           # CPIA: Financial sector (1=low to 6=high)
  "IQ.CPA.GNDR.XQ",           # CPIA: Gender equality (1=low to 6=high)
  "IQ.CPA.MACR.XQ",           # CPIA: Macroeconomic management (1=low to 6=high)
  "IQ.CPA.SOCI.XQ",           # CPIA: Social protection and labor (1=low to 6=high)
  "IQ.CPA.ENVR.XQ",           # CPIA: Environmental sustainability (1=low to 6=high)
  "IQ.CPA.PROP.XQ",           # CPIA: Property rights and rule-based governance (1=low to 6=high)
  "IQ.CPA.PUBS.XQ",           # CPIA: Quality of public sector administration (1=low to 6=high)
  "IQ.CPA.FINQ.XQ",           # CPIA: Financial sector (1=low to 6=high)
  "IQ.CPA.PADM.XQ",           # CPIA: Public administration (1=low to 6=high)
  "IQ.CPA.PROT.XQ",           # CPIA: Transparency, accountability, and corruption in the public sector (1=low to 6=high)
  "IQ.CPA.STRC.XQ",           # CPIA: Structural policies (1=low to 6=high)
  "IQ.CPA.TRAD.XQ",           # CPIA: Trade (1=low to 6=high)
  "IQ.CPA.TRAN.XQ"            # CPIA: Transport and communications (1=low to 6=high)
)

# Attempt the full download
# It's good practice to wrap the download in a tryCatch block
# to handle potential errors gracefully, especially with network operations.
tryCatch({
  wdi_data <- WDI(
    country = "all",
    indicator = wdi_indicators_list,
    start = start_year,
    end = end_year,
    extra = FALSE, # Set to FALSE if you don't need extra country/series info
    cache = NULL,  # No caching if you always want fresh data, or set a path
    latest = NULL, # Retrieve all available data within the start/end range
    language = "en"
  )

  # Check for indicators that were not downloaded
  downloaded_indicators <- names(wdi_data)[!(names(wdi_data) %in% c("iso2c", "country", "year"))]
  missing_indicators <- setdiff(wdi_indicators_list, downloaded_indicators)

  if (length(missing_indicators) > 0) {
    warning("The following indicators could not be downloaded or might be unavailable for the specified period: ",
            paste(missing_indicators, collapse = ", "),
            "\nPlease verify their codes and availability on the World Bank DataBank.")
  }


}, error = function(e) {
  message("An error occurred during WDI data download: ", e$message)
  message("Please check your internet connection and the validity of the indicator codes.")
})


# cleaning ----------------------------------------------------------------

# Clean col names
wdi_name <- wdi_data |>
            clean_names() |>
            rename(
              country_name = country,
              country_code = iso3c
            )

# Replace ISO2 to ISO3
wdi_iso3 <- wdi_name |>
             mutate(
               iso3c = countrycode(iso2c,
                                   origin = "iso2c",
                                   destination = "iso3c")
               )

# Identify the unmatched country codes
unmatched_iso2c <- wdi_iso3 |>
                    filter(is.na(iso3c)) |>
                    distinct(iso2c) |>
                    pull(iso2c) # None of them are WB territories


# Drop rows where iso3c is NA
wdi_cleaned_codes <- wdi_iso3 |>
                    filter(!is.na(iso3c)) |>
                    select(-c(iso2c, iso3c))

# Remove underscores from column names and replace prefixes with `wdi_` convention
wdi_named <- wdi_cleaned_codes |>
  rename_with(~ str_replace_all(.x, "_", ""),
              .cols = -c(country_name, country_code)
  ) |>
  rename_with(~ str_replace_all(.x, "^(.+)", "wdi_\\1"),
              .cols = !starts_with("country") & !starts_with("year")
  )

# process -----------------------------------------------------------------

# Step 1: Extract variable names and labels
var_labels <- sapply(wdi_named, function(x) attr(x, "label"))  # Extract labels from the attributes
var_names <- names(var_labels)  # Get the variable names

wdi_clean <- wdi_named |>
  rename_with(
    ~ str_to_lower(.) %>%
      str_replace_all("^wdi_", "wdi_"),
    starts_with("wdi_")
  )

columns_to_drop <- c(
  "country_name",
  "wdi_dcodatotlgnzs",
  "wdi_dtdodpvlxgnzs",
  "wdi_shmedcmhwp3",
  "wdi_sipovmdim",
  "wdi_sipovmdimxq"
)

wdi_indicators <- wdi_clean |>
  select(!all_of(columns_to_drop)) |>
  filter(!is.na(country_code) & country_code != ""
  ) |>
  distinct(country_code, year, .keep_all = TRUE)



# write-out ---------------------------------------------------------------
usethis::use_data(wdi_indicators, overwrite = TRUE)

