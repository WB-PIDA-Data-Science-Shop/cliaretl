## code to prepare `vdem_data` dataset goes here
# source: V-dem Package https://github.com/vdeminstitute/vdemdata
# access date: 6/10/2025
library(here)
library(dplyr)
library(readr)
library(stringr)
library(janitor)
library(countrycode)
library(vdemdata)

# read-in -----------------------------------------------------------------

# Download indicators
vdem_df <- vdemdata::vdem


# cleaning ----------------------------------------------------------------
vdem_clean <- vdem_df |>
                filter(year >= 1990) |>
                rename(
                  country_code = country_text_id
                ) |>
                clean_names() |>  # Clean column names to lower case with underscores
                distinct(country_code, year, .keep_all = TRUE)|>  # Remove duplicates
                select(
                  country_code,
                  year,
                  v2x_corr,
                  v2exbribe,
                  v2xcl_prpty,
                  v2xcl_acjst,
                  v2juhcind,
                  v2juncind,
                  v2juaccnt,
                  v2pepwrgen,
                  v2pepwrsoc,
                  v2pepwrses,
                  v2xlg_legcon,
                  v2x_gender,
                  v2stcritrecadm,
                  v2clrspct,
                  v2cseeorgs,
                  v2dlengage,
                  v2clacfree,
                  v2csreprss,
                  v2x_civlib,
                  v2x_cspart,
                  v2clstown,
                  v2clacjstm,
                  v2clacjstw,
                  v2lgqugen,
                  # v2lgfemleg,
                  v2cldiscm,
                  v2cldiscw,
                  # v2caassemb,
                  v2cacamps,
                  v2peapsecon,
                  v2peasjsoecon,
                  v2peapsgen,
                  # v2peasjgen,
                  v2peapspol,
                  v2peasjpol,
                  v2x_pubcorr,
                  v2x_execorr,
                  v2lgcrrpt,
                  v2dlencmps,
                  v2clstown,
                  v2peedueq,
                  v2pehealth,
                  v2peasbepol,
                  v2cafres,
                  v2cafexch,
                  v2x_rule,
                  v2xed_ed_cent,
                  v2xed_ed_ctag,
                  v2xed_ed_con,
                  v2edteautonomy,
                  v2edteunionindp
                )


# process -----------------------------------------------------------------
# Remove underscores from column names and replace prefixes with `vdem_` convention
vdem_data <- vdem_clean |>
  rename_with(
    ~ paste0("vdem_core_", .),
    .cols = starts_with("v2")
  )

# write-out ---------------------------------------------------------------
usethis::use_data(vdem_data, overwrite = TRUE)
