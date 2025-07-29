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

# ============= Dummy Inputs for Testing
start_year <- 1990
end_year <- 2024
patch_bool <- 'TRUE'
patch_bool <- ifelse(patch_bool == 'FALSE', FALSE, TRUE)
og_file_path <- "/data-raw/cliar/"

# =================== Data Read
dbv_df <- read_excel(
  here("data-raw", "input", "cliar", "CLIAR_Metadata_Prod_D360.xlsx")
)

dbvars_dt <- read_excel("data-raw/input/cliar/db_variables.xlsx")

country_info<-read.csv("data-raw/input/cliar/Country Code Mapping.csv")

# ======== OBJECT INITIALIZATION
# Dictionary of country names for conversion later on in the code
Country_DICT <- c(
  'DZA' = 'Algeria', 'AFG' = 'Afghanistan', 'ALB' = 'Albania', 'ASM' = 'American Samoa',
  'AND' = 'Andorra', 'AGO' = 'Angola', 'ATG' = 'Antigua and Barbuda', 'ARG' = 'Argentina',
  'ARM' = 'Armenia', 'ABW' = 'Aruba', 'AUS' = 'Australia', 'AUT' = 'Austria',
  'AZE' = 'Azerbaijan', 'BHS' = 'Bahamas', 'BHR' = 'Bahrain', 'BGD' = 'Bangladesh',
  'BRB' = 'Barbados', 'BLR' = 'Belarus', 'BEL' = 'Belgium', 'BLZ' = 'Belize',
  'BEN' = 'Benin', 'BMU' = 'Bermuda', 'BTN' = 'Bhutan', 'BOL' = 'Bolivia',
  'BIH' = 'Bosnia and Herzegovina', 'BWA' = 'Botswana', 'BRA' = 'Brazil',
  'BRN' = 'Brunei Darussalam', 'BGR' = 'Bulgaria', 'BFA' = 'Burkina Faso',
  'BDI' = 'Burundi', 'KHM' = 'Cambodia', 'CMR' = 'Cameroon', 'CAN' = 'Canada',
  'CPV' = 'Cape Verde', 'CYM' = 'Cayman Islands', 'CAF' = 'Central African Republic',
  'TCD' = 'Chad', 'CHL' = 'Chile', 'CHN' = 'China', 'COL' = 'Colombia', 'COM' = 'Comoros',
  'COG' = 'Congo', 'COD' = 'Congo, The Democratic Republic of ', 'CRI' = 'Costa Rica',
  'CIV' = "Cote d'Ivoire", 'HRV' = 'Croatia', 'CUB' = 'Cuba', 'CUW' = 'Curaçao',
  'CYP' = 'Cyprus', 'CZE' = 'Czechia', 'DNK' = 'Denmark', 'DJI' = 'Djibouti',
  'DMA' = 'Dominica', 'DOM' = 'Dominican Republic', 'ECU' = 'Ecuador',
  'EGY' = 'Egypt', 'SLV' = 'El Salvador', 'GNQ' = 'Equatorial Guinea',
  'ERI' = 'Eritrea', 'EST' = 'Estonia', 'ETH' = 'Ethiopia', 'FRO' = 'Faroe Islands',
  'FJI' = 'Fiji', 'FIN' = 'Finland', 'FRA' = 'France', 'PYF' = 'French Polynesia',
  'GAB' = 'Gabon', 'GMB' = 'Gambia', 'GEO' = 'Georgia', 'DEU' = 'Germany',
  'GHA' = 'Ghana', 'GIB' = 'Gibraltar', 'GRC' = 'Greece', 'GRL' = 'Greenland',
  'GRD' = 'Grenada', 'GUM' = 'Guam', 'GTM' = 'Guatemala', 'GIN' = 'Guinea',
  'GNB' = 'Guinea-Bissau', 'GUY' = 'Guyana', 'HTI' = 'Haiti', 'HND' = 'Honduras',
  'HKG' = 'Hong Kong', 'HUN' = 'Hungary', 'ISL' = 'Iceland', 'IND' = 'India',
  'IDN' = 'Indonesia', 'IRN' = 'Iran, Islamic Republic of', 'IRQ' = 'Iraq',
  'IRL' = 'Ireland', 'IMN' = 'Isle of Man', 'ISR' = 'Israel', 'ITA' = 'Italy',
  'JAM' = 'Jamaica', 'JPN' = 'Japan', 'JOR' = 'Jordan', 'KAZ' = 'Kazakstan',
  'KEN' = 'Kenya', 'KIR' = 'Kiribati', 'PRK' = "Korea, Democratic People's Republic of",
  'KOR' = 'Korea, Republic of', 'XKX' = 'Kosovo (temporary code)', 'KWT' = 'Kuwait',
  'KGZ' = 'Kyrgyzstan', 'LAO' = "Lao, People's Democratic Republic", 'LVA' = 'Latvia',
  'LBN' = 'Lebanon', 'LSO' = 'Lesotho', 'LBR' = 'Liberia', 'LBY' = 'Libyan Arab Jamahiriya',
  'LIE' = 'Liechtenstein', 'LTU' = 'Lithuania', 'LUX' = 'Luxembourg',
  'MAC' = 'Macao', 'MKD' = 'Macedonia, The Former Yugoslav Republic Of', 'MDG' = 'Madagascar',
  'MWI' = 'Malawi', 'MYS' = 'Malaysia', 'MDV' = 'Maldives', 'MLI' = 'Mali', 'MLT' = 'Malta',
  'MHL' = 'Marshall Islands', 'MRT' = 'Mauritania', 'MUS' = 'Mauritius', 'MEX' = 'Mexico',
  'FSM' = 'Micronesia, Federated States of', 'MDA' = 'Moldova, Republic of', 'MCO' = 'Monaco',
  'MNG' = 'Mongolia', 'MNE' = 'Montenegro', 'MAR' = 'Morocco', 'MOZ' = 'Mozambique',
  'MMR' = 'Myanmar', 'NAM' = 'Namibia', 'NRU' = 'Nauru', 'NPL' = 'Nepal',
  'NLD' = 'Netherlands', 'NCL' = 'New Caledonia', 'NZL' = 'New Zealand',
  'NIC' = 'Nicaragua', 'NER' = 'Niger', 'NGA' = 'Nigeria', 'MNP' = 'Northern Mariana Islands',
  'NOR' = 'Norway', 'OMN' = 'Oman', 'PAK' = 'Pakistan', 'PLW' = 'Palau',
  'PSE' = 'Palestinian Territory, Occupied', 'PAN' = 'Panama', 'PNG' = 'Papua New Guinea',
  'PRY' = 'Paraguay', 'PER' = 'Peru', 'PHL' = 'Philippines', 'POL' = 'Poland',
  'PRT' = 'Portugal', 'PRI' = 'Puerto Rico', 'QAT' = 'Qatar', 'SRB' = 'Republic of Serbia',
  'ROU' = 'Romania', 'RUS' = 'Russia Federation', 'RWA' = 'Rwanda',
  'KNA' = 'Saint Kitts & Nevis', 'LCA' = 'Saint Lucia', 'MAF' = 'Saint Martin',
  'VCT' = 'Saint Vincent and the Grenadines', 'WSM' = 'Samoa',
  'SMR' = 'San Marino', 'STP' = 'Sao Tome and Principe',
  'SAU' = 'Saudi Arabia', 'SEN' = 'Senegal', 'SYC' = 'Seychelles',
  'SLE' = 'Sierra Leone', 'SGP' = 'Singapore', 'SXM' = 'Sint Maarten', 'SVK' = 'Slovakia',
  'SVN' = 'Slovenia', 'SLB' = 'Solomon Islands', 'SOM' = 'Somalia', 'ZAF' = 'South Africa',
  'SSD' = 'South Sudan', 'ESP' = 'Spain', 'LKA' = 'Sri Lanka', 'SDN' = 'Sudan',
  'SUR' = 'Suriname', 'SWZ' = 'Swaziland', 'SWE' = 'Sweden', 'CHE' = 'Switzerland',
  'SYR' = 'Syrian Arab Republic', 'TWN' = 'Taiwan, Province of China',
  'TJK' = 'Tajikistan', 'TZA' = 'Tanzania, United Republic of',
  'THA' = 'Thailand', 'TLS' = 'Timor-Leste', 'TGO' = 'Togo', 'TON' = 'Tonga',
  'TTO' = 'Trinidad and Tobago', 'TUN' = 'Tunisia', 'TUR' = 'Turkey',
  'TKM' = 'Turkmenistan', 'TCA' = 'Turks and Caicos Islands', 'TUV' = 'Tuvalu',
  'UGA' = 'Uganda', 'UKR' = 'Ukraine', 'ARE' = 'United Arab Emirates',
  'GBR' = 'United Kingdom', 'USA' = 'United States', 'URY' = 'Uruguay',
  'UZB' = 'Uzbekistan', 'VUT' = 'Vanuatu', 'VEN' = 'Venezuela', 'VNM' = 'Vietnam',
  'VGB' = 'Virgin Islands, British', 'VIR' = 'Virgin Islands, U.S.',
  'YEM' = 'Yemen', 'ZMB' = 'Zambia', 'ZWE' = 'Zimbabwe'
)

# =====================================
# Create the Source List for The API calls

EFI_SOURCE_DICT <-list()


dataset_id <- 'WB.ASPIRE'
indicator_ids <- c('WB.ASPIRE.per_allsp.adq_pop_tot', 'WB.ASPIRE.per_allsp.cov_pop_tot')

result <- extract_data_from_api(dataset_id, indicator_ids, 'efi')[[2]]

df <- result %>%
  select(-matches("PARTNER|ATTRIBUTE|Median"), everything()) %>%
  mutate(Year = year(as.Date(CAL_YEAR,format = "%d/%m/%Y"))) %>%
  select(-CAL_YEAR) %>%
  filter(Year >= 1990 & Year <= 2024) %>%
  mutate(Countries = Country_DICT[COUNTRY_CODE]) %>%
  rename(Country_Code = COUNTRY_CODE) %>%
  relocate(Country_Code, Countries, Year)

df <- left_join(df, country_info, by = "Country_Code")


df <- df %>%
  mutate(Indicator_Code = str_replace(INDICATOR_ID, "WB\\.ASPIRE\\.", "")) %>%
  rename(val = IND_VALUE)

# Define the nested list (equivalent to Python's dict of dicts)
mapping_dict <- list(
  indicator_name = list(
    "per_allsp.adq_pop_tot" = "Adequacy of benefits (%) -All Social Protection and Labor ",
    "per_allsp.cov_pop_tot" = "Coverage (%) -All Social Protection and Labor "
  ),
  Sub_Topic1 = list(
    "per_allsp.adq_pop_tot" = "Indicators estimated using post-transfer welfare",
    "per_allsp.cov_pop_tot" = "Indicators estimated using post-transfer welfare"
  ),
  Sub_Topic2 = list(
    "per_allsp.adq_pop_tot" = "Benefit level",
    "per_allsp.cov_pop_tot" = "Coverage"
  ),
  Sub_Topic3 = list(
    "per_allsp.adq_pop_tot" = "Adequacy of benefits",
    "per_allsp.cov_pop_tot" = "Coverage"
  ),
  Sub_Topic4 = list(
    "per_allsp.adq_pop_tot" = "Total",
    "per_allsp.cov_pop_tot" = "Total"
  ),
  Sub_Topic5 = list(
    "per_allsp.adq_pop_tot" = "All Social Protection and Labor",
    "per_allsp.cov_pop_tot" = "All Social Protection and Labor"
  ),
  Sub_Topic6 = list(
    "per_allsp.adq_pop_tot" = "All Social Protection and Labor",
    "per_allsp.cov_pop_tot" = "All Social Protection and Labor"
  )
)

# Add each mapped column to ASPIRE using the dictionary
aspire <- df %>%
  mutate(
    indicator_name = map_chr(Indicator_Code, ~ mapping_dict$indicator_name[[.x]] %||% NA_character_),
    Sub_Topic1 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic1[[.x]] %||% NA_character_),
    Sub_Topic2 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic2[[.x]] %||% NA_character_),
    Sub_Topic3 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic3[[.x]] %||% NA_character_),
    Sub_Topic4 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic4[[.x]] %||% NA_character_),
    Sub_Topic5 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic5[[.x]] %||% NA_character_),
    Sub_Topic6 = map_chr(Indicator_Code, ~ mapping_dict$Sub_Topic6[[.x]] %||% NA_character_)
  )

usethis::use_data(aspire, overwrite = TRUE)
