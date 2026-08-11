# ========== Import Section
library(readxl)
library(dplyr)
library(tidyr)
library(httr)
library(jsonlite)
library(stringr)
library(lubridate)
library(janitor)
library(here)
library(purrr)
library(countrycode)

devtools::load_all()

# # ============= Dummy Inputs for Testing
# start_year <- 1990
# end_year <- 2024
# patch_bool <- 'TRUE'
# patch_bool <- ifelse(patch_bool == 'FALSE', FALSE, TRUE)
# og_file_path <- "/data-raw/cliar/"

# # =================== Data Read
# dbv_df <- read_excel(
#   here("data-raw", "input", "cliar", "CLIAR_Metadata_Prod_D360.xlsx")
# )

# dbvars_dt <- read_excel("data-raw/input/cliar/db_variables.xlsx")

# wb_country_codes <- wb_country_list

# # ======== OBJECT INITIALIZATION
# # Dictionary of country names for conversion later on in the code
# Country_DICT <- c(
#   'DZA' = 'Algeria', 'AFG' = 'Afghanistan', 'ALB' = 'Albania', 'ASM' = 'American Samoa',
#   'AND' = 'Andorra', 'AGO' = 'Angola', 'ATG' = 'Antigua and Barbuda', 'ARG' = 'Argentina',
#   'ARM' = 'Armenia', 'ABW' = 'Aruba', 'AUS' = 'Australia', 'AUT' = 'Austria',
#   'AZE' = 'Azerbaijan', 'BHS' = 'Bahamas', 'BHR' = 'Bahrain', 'BGD' = 'Bangladesh',
#   'BRB' = 'Barbados', 'BLR' = 'Belarus', 'BEL' = 'Belgium', 'BLZ' = 'Belize',
#   'BEN' = 'Benin', 'BMU' = 'Bermuda', 'BTN' = 'Bhutan', 'BOL' = 'Bolivia',
#   'BIH' = 'Bosnia and Herzegovina', 'BWA' = 'Botswana', 'BRA' = 'Brazil',
#   'BRN' = 'Brunei Darussalam', 'BGR' = 'Bulgaria', 'BFA' = 'Burkina Faso',
#   'BDI' = 'Burundi', 'KHM' = 'Cambodia', 'CMR' = 'Cameroon', 'CAN' = 'Canada',
#   'CPV' = 'Cape Verde', 'CYM' = 'Cayman Islands', 'CAF' = 'Central African Republic',
#   'TCD' = 'Chad', 'CHL' = 'Chile', 'CHN' = 'China', 'COL' = 'Colombia', 'COM' = 'Comoros',
#   'COG' = 'Congo', 'COD' = 'Congo, The Democratic Republic of ', 'CRI' = 'Costa Rica',
#   'CIV' = "Cote d'Ivoire", 'HRV' = 'Croatia', 'CUB' = 'Cuba', 'CUW' = 'Curaçao',
#   'CYP' = 'Cyprus', 'CZE' = 'Czechia', 'DNK' = 'Denmark', 'DJI' = 'Djibouti',
#   'DMA' = 'Dominica', 'DOM' = 'Dominican Republic', 'ECU' = 'Ecuador',
#   'EGY' = 'Egypt', 'SLV' = 'El Salvador', 'GNQ' = 'Equatorial Guinea',
#   'ERI' = 'Eritrea', 'EST' = 'Estonia', 'ETH' = 'Ethiopia', 'FRO' = 'Faroe Islands',
#   'FJI' = 'Fiji', 'FIN' = 'Finland', 'FRA' = 'France', 'PYF' = 'French Polynesia',
#   'GAB' = 'Gabon', 'GMB' = 'Gambia', 'GEO' = 'Georgia', 'DEU' = 'Germany',
#   'GHA' = 'Ghana', 'GIB' = 'Gibraltar', 'GRC' = 'Greece', 'GRL' = 'Greenland',
#   'GRD' = 'Grenada', 'GUM' = 'Guam', 'GTM' = 'Guatemala', 'GIN' = 'Guinea',
#   'GNB' = 'Guinea-Bissau', 'GUY' = 'Guyana', 'HTI' = 'Haiti', 'HND' = 'Honduras',
#   'HKG' = 'Hong Kong', 'HUN' = 'Hungary', 'ISL' = 'Iceland', 'IND' = 'India',
#   'IDN' = 'Indonesia', 'IRN' = 'Iran, Islamic Republic of', 'IRQ' = 'Iraq',
#   'IRL' = 'Ireland', 'IMN' = 'Isle of Man', 'ISR' = 'Israel', 'ITA' = 'Italy',
#   'JAM' = 'Jamaica', 'JPN' = 'Japan', 'JOR' = 'Jordan', 'KAZ' = 'Kazakstan',
#   'KEN' = 'Kenya', 'KIR' = 'Kiribati', 'PRK' = "Korea, Democratic People's Republic of",
#   'KOR' = 'Korea, Republic of', 'XKX' = 'Kosovo (temporary code)', 'KWT' = 'Kuwait',
#   'KGZ' = 'Kyrgyzstan', 'LAO' = "Lao, People's Democratic Republic", 'LVA' = 'Latvia',
#   'LBN' = 'Lebanon', 'LSO' = 'Lesotho', 'LBR' = 'Liberia', 'LBY' = 'Libyan Arab Jamahiriya',
#   'LIE' = 'Liechtenstein', 'LTU' = 'Lithuania', 'LUX' = 'Luxembourg',
#   'MAC' = 'Macao', 'MKD' = 'Macedonia, The Former Yugoslav Republic Of', 'MDG' = 'Madagascar',
#   'MWI' = 'Malawi', 'MYS' = 'Malaysia', 'MDV' = 'Maldives', 'MLI' = 'Mali', 'MLT' = 'Malta',
#   'MHL' = 'Marshall Islands', 'MRT' = 'Mauritania', 'MUS' = 'Mauritius', 'MEX' = 'Mexico',
#   'FSM' = 'Micronesia, Federated States of', 'MDA' = 'Moldova, Republic of', 'MCO' = 'Monaco',
#   'MNG' = 'Mongolia', 'MNE' = 'Montenegro', 'MAR' = 'Morocco', 'MOZ' = 'Mozambique',
#   'MMR' = 'Myanmar', 'NAM' = 'Namibia', 'NRU' = 'Nauru', 'NPL' = 'Nepal',
#   'NLD' = 'Netherlands', 'NCL' = 'New Caledonia', 'NZL' = 'New Zealand',
#   'NIC' = 'Nicaragua', 'NER' = 'Niger', 'NGA' = 'Nigeria', 'MNP' = 'Northern Mariana Islands',
#   'NOR' = 'Norway', 'OMN' = 'Oman', 'PAK' = 'Pakistan', 'PLW' = 'Palau',
#   'PSE' = 'Palestinian Territory, Occupied', 'PAN' = 'Panama', 'PNG' = 'Papua New Guinea',
#   'PRY' = 'Paraguay', 'PER' = 'Peru', 'PHL' = 'Philippines', 'POL' = 'Poland',
#   'PRT' = 'Portugal', 'PRI' = 'Puerto Rico', 'QAT' = 'Qatar', 'SRB' = 'Republic of Serbia',
#   'ROU' = 'Romania', 'RUS' = 'Russia Federation', 'RWA' = 'Rwanda',
#   'KNA' = 'Saint Kitts & Nevis', 'LCA' = 'Saint Lucia', 'MAF' = 'Saint Martin',
#   'VCT' = 'Saint Vincent and the Grenadines', 'WSM' = 'Samoa',
#   'SMR' = 'San Marino', 'STP' = 'Sao Tome and Principe',
#   'SAU' = 'Saudi Arabia', 'SEN' = 'Senegal', 'SYC' = 'Seychelles',
#   'SLE' = 'Sierra Leone', 'SGP' = 'Singapore', 'SXM' = 'Sint Maarten', 'SVK' = 'Slovakia',
#   'SVN' = 'Slovenia', 'SLB' = 'Solomon Islands', 'SOM' = 'Somalia', 'ZAF' = 'South Africa',
#   'SSD' = 'South Sudan', 'ESP' = 'Spain', 'LKA' = 'Sri Lanka', 'SDN' = 'Sudan',
#   'SUR' = 'Suriname', 'SWZ' = 'Swaziland', 'SWE' = 'Sweden', 'CHE' = 'Switzerland',
#   'SYR' = 'Syrian Arab Republic', 'TWN' = 'Taiwan, Province of China',
#   'TJK' = 'Tajikistan', 'TZA' = 'Tanzania, United Republic of',
#   'THA' = 'Thailand', 'TLS' = 'Timor-Leste', 'TGO' = 'Togo', 'TON' = 'Tonga',
#   'TTO' = 'Trinidad and Tobago', 'TUN' = 'Tunisia', 'TUR' = 'Turkey',
#   'TKM' = 'Turkmenistan', 'TCA' = 'Turks and Caicos Islands', 'TUV' = 'Tuvalu',
#   'UGA' = 'Uganda', 'UKR' = 'Ukraine', 'ARE' = 'United Arab Emirates',
#   'GBR' = 'United Kingdom', 'USA' = 'United States', 'URY' = 'Uruguay',
#   'UZB' = 'Uzbekistan', 'VUT' = 'Vanuatu', 'VEN' = 'Venezuela', 'VNM' = 'Vietnam',
#   'VGB' = 'Virgin Islands, British', 'VIR' = 'Virgin Islands, U.S.',
#   'YEM' = 'Yemen', 'ZMB' = 'Zambia', 'ZWE' = 'Zimbabwe'
# )

# # =====================================
# # Create the Source List for The API calls

# EFI_SOURCE_DICT <-list()


# dataset_id <- 'WB.ASPIRE'
# indicator_ids <- c('WB.ASPIRE.per_allsp.adq_pop_tot', 'WB.ASPIRE.per_allsp.cov_pop_tot')

# result <- extract_data_from_api(dataset_id, indicator_ids, 'efi')[[2]]


dest_dir <- here("data-raw", "input", "aspire")


url <- "https://ddh-openapi.worldbank.org/resources/DR0087109/download"
tmp_file <- file.path(dest_dir, "aspire_raw.dta")

## lets download the file and tell me the progress of the download
resp <- GET(url, write_disk(tmp_file, overwrite = TRUE), progress())

## read the downloaded file into STATA
aspire_dt <- haven::read_dta(tmp_file)

aspire_dt <- 
aspire_dt |>
  rename(country_code = Country_Code,
         year = Year) |>
  filter(country_code %in% unique(wb_country_list$country_code)) |>
  filter(year >= 1990 & year <= 2024) |>
  filter(country_code != "AGGREGATE") |>
  mutate(year = as.integer(as.numeric(year))) |> 
  select(-region, -incomeclassification, -idaeligibility, -Countries) |>
  filter(Indicator_Code %in% c("per_allsp.adq_pop_tot", "per_allsp.cov_pop_tot")) |>
  filter(!is.na(country_code)) |>
  select(-matches("Sub_Topic")) |>
  pivot_wider(
    id_cols = c(country_code, year),
    values_from = val,
    names_from = Indicator_Code
  ) |>
  rename(
    wb_aspire_coverage = per_allsp.cov_pop_tot,
    wb_aspire_adequacy_benefits = per_allsp.adq_pop_tot)


### lets quickly compare the old vintage to the new one
check_obj <- 
  aspire_dt |>
  full_join(aspire, by = c("country_code", "year")) |>
  arrange(country_code, year)

aspire <- aspire_dt

rm(aspire_dt)

aspire <- 
aspire |>
  add_plmetadata(source = "https://ddh-openapi.worldbank.org/resources/DR0087109/download",
                 other_info = "API pull")


usethis::use_data(aspire, overwrite = TRUE)
