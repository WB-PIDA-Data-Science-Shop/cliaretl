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
d360_SOURCE_DICT <- list()
EFI_SOURCE_DICT <-list()
row_counter <- 0
# Loop over rows

for (row_index in 1:nrow(dbv_df)) {
  current_row <- dbv_df[row_index, ]

  if (!is.na(current_row$Indicator_ID)) {
    dataset_key <- extract_dataset_id(as.character(current_row$Indicator_ID))

    if (current_row$Process == "Data360") {
      row_counter <- row_counter + 1

      indicator_id <- if (grepl("WB.GTMI.I", current_row$Indicator_ID)) {
        gsub("-", ".", current_row$Indicator_ID)
      } else {
        current_row$Indicator_ID
      }

      if (dataset_key != 'nan' && !is.na(dataset_key)) {
        if (is.null(d360_SOURCE_DICT[[dataset_key]])) {
          d360_SOURCE_DICT[[dataset_key]] <- list()
        }
        d360_SOURCE_DICT[[dataset_key]] <- append(d360_SOURCE_DICT[[dataset_key]], indicator_id)
      }

    } else if (current_row$Process == "EFI") {
      row_counter <- row_counter + 1
      indicator_id <- current_row$Indicator_ID

      if (dataset_key != 'nan' && !is.na(dataset_key)) {
        if (is.null(EFI_SOURCE_DICT[[dataset_key]])) {
          EFI_SOURCE_DICT[[dataset_key]] <- list()
        }
        EFI_SOURCE_DICT[[dataset_key]] <- append(EFI_SOURCE_DICT[[dataset_key]], indicator_id)
      }
    }
  }
}

# ------------------ Initialize Variables ------------------

api_call_counter <- 0
missing_sources <- list()
failed_pull_counter <- 0
expected_length <- 0
year_range <- start_year:end_year
year_string <- paste(year_range, collapse = ", ")

# ------------------ Convert Dictionaries to Data Frames ------------------

Indicator_Dict <- lapply(d360_SOURCE_DICT, function(vals) gsub("\\.", "_", vals))
names(Indicator_Dict) <- gsub("\\.", "_", names(d360_SOURCE_DICT))

efi_Indicator_Dict <- EFI_SOURCE_DICT

df_d360 <- tibble::tibble(
  DATABASE_ID = rep(names(Indicator_Dict), lengths(Indicator_Dict)),
  INDICATOR = unlist(Indicator_Dict)
) %>% mutate(Status = 0)

df_efi <- tibble::tibble(
  DATABASE_ID = rep(names(efi_Indicator_Dict), lengths(efi_Indicator_Dict)),
  INDICATOR = unlist(efi_Indicator_Dict)
) %>% mutate(Status = 0)

# ------------------ EFI API Pull ------------------

efi_full_data <- data.frame(
  COUNTRY_CODE = character(), PARTNER = character(), INDICATOR_ID = character(),
  ATTRIBUTE_1 = character(), ATTRIBUTE_2 = character(), ATTRIBUTE_3 = character(),
  CAL_YEAR = character(), IND_VALUE = numeric(), Median = character(),
  stringsAsFactors = FALSE
)

for (row_index in 1:nrow(df_efi)) {
  api_call_counter <- api_call_counter + 1
  current_dataset <- df_efi$DATABASE_ID[row_index]
  current_indicators <- df_efi$INDICATOR[row_index]

  result <- Extract_data_from_API(current_dataset, current_indicators, 'efi')

  if (result[[1]] == 'ERROR') {
    next
  } else {
    api_pull <- result[[2]]
    efi_full_data <- bind_rows(efi_full_data, api_pull)
    df_efi$Status[row_index] <- 1
  }
}

efi_full_data <- distinct(efi_full_data)

# ------------------ Reshape EFI Data ------------------

efi_filtered_df <- efi_full_data %>%
  select(-any_of(c("PARTNER", "ATTRIBUTE_1", "ATTRIBUTE_2", "ATTRIBUTE_3", "Median")))

efi_wide_df <- efi_filtered_df %>%
  pivot_wider(names_from = INDICATOR_ID, values_from = IND_VALUE) %>%
  mutate(Year = as.integer(format(as.Date(CAL_YEAR, format = "%d/%m/%Y"), "%Y"))) %>%
  select(-CAL_YEAR)

efi_final_df <- efi_wide_df %>%
  filter(Year >= start_year & Year <= end_year) %>%
  rename(ISO3 = COUNTRY_CODE)

iso3_codes <- unique(efi_final_df$ISO3)
missing_rows <- expand.grid(ISO3 = iso3_codes, Year = year_range) %>%
  anti_join(efi_final_df, by = c("ISO3", "Year"))

efi_final_df <- bind_rows(efi_final_df, missing_rows) %>%
  arrange(ISO3, Year)

colnames(efi_final_df) <- colnames(efi_final_df) %>%
  str_replace_all("\\.", "_") %>%
  str_replace_all("-", "_") %>%
  str_replace_all("IMF_WoRLD", "IMF_WORLD") %>%
  str_replace_all("WB_ENTERPRISESURVEYS_IC_FRM", "WB_SURVEY") %>%
  str_replace_all("IDEA_GSOD_v", "IDEA_GSOD_V")

# ------------------ D360 API Pull ------------------

d360_full_data <- data.frame()

for (row_index in 1:nrow(df_d360)) {
  api_call_counter <- api_call_counter + 1
  current_dataset <- df_d360$DATABASE_ID[row_index]
  current_indicators <- df_d360$INDICATOR[row_index]

  result <- Extract_data_from_API(current_dataset, current_indicators, 'd360')

  if (result[[1]] == 'ERROR') {
    next
  } else {
    api_pull <- result[[2]]
    d360_full_data <- bind_rows(d360_full_data, api_pull)
    df_d360$Status[row_index] <- 1
  }
}

d360_full_data <- distinct(d360_full_data)

d360_data <- d360_full_data %>%
  select(INDICATOR, REF_AREA, TIME_PERIOD, OBS_VALUE) %>%
  rename(ISO3 = REF_AREA, Year = TIME_PERIOD)

d360_wide_df <- d360_data %>%
  pivot_wider(names_from = INDICATOR, values_from = OBS_VALUE)

d360_wide_df$Year <- as.integer(d360_wide_df$Year)

d360_final_df <- d360_wide_df %>%
  filter(Year >= start_year & Year <= end_year)

# ------------------ Merge EFI and D360 ------------------

key_df <- bind_rows(
  efi_final_df %>% select(ISO3, Year),
  d360_final_df %>% select(ISO3, Year)
) %>% distinct()

efi_merged_df <- left_join(key_df, efi_final_df, by = c("ISO3", "Year"))
d360_merged_df <- left_join(key_df, d360_final_df, by = c("ISO3", "Year"))

merged_final_df <- full_join(efi_merged_df, d360_merged_df, by = c("ISO3", "Year")) %>%
  filter(ISO3 != "AGGREGATE")

save(df_merged, file = here("data","D360_EFI_Data_extract.rda"))

