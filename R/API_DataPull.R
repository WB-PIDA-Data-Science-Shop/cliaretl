# ========== Import Section
library(readxl)
library(dplyr)
library(tidyr)
library(httr)
library(jsonlite)
library(stringr)
library(lubridate)

# ============= Dummy Inputs for Testing
start_year <- 1990
end_year <- 2024
patch_bool <- 'TRUE'
patch_bool <- ifelse(patch_bool == 'FALSE', FALSE, TRUE)
og_file_path <- "G:/data/cliaretl/input/"

# =================== Data Read
# Interacting with Cliar metadata
temp_dbv_path <- "CLIAR_Metadata_Prod_D360.xlsx"
dbv_df <- read_excel(paste0(og_file_path, temp_dbv_path))

# ===================== Function Creation
# This function pulls the efi source needed for the API pull from any indicator name
extract_dataset_id <- function(input_id, splitchar = '.') {
  # Find first occurrence of splitchar
  first_dot_index <- str_locate(input_id, fixed(splitchar))[1]

  if (!is.na(first_dot_index)) {
    # Find second occurrence of splitchar
    remaining_string <- substr(input_id, first_dot_index + 1, nchar(input_id))
    second_dot_pos <- str_locate(remaining_string, fixed(splitchar))[1]

    if (!is.na(second_dot_pos)) {
      second_dot_index <- first_dot_index + second_dot_pos
      return(substr(input_id, 1, second_dot_index - 1))
    }
  }

  return(input_id)
}

# Function to format API JSON into data frames

API_toDF <- function(dataset_id, indicator_ids, source, verbose = FALSE) {
  # Base URLs (define these beforehand)
  d360_baseurl <- "https://data360api.worldbank.org/data360/data"
  efi_baseurl <- "https://datacatalogapi.worldbank.org/dexapps/efi/data"

  if (source == 'd360') {
    url <- paste0(d360_baseurl, "?DATABASE_ID=", dataset_id,
                  "&INDICATOR=", paste(indicator_ids, collapse = ","),
                  "&skip=0")
  } else {
    url <- paste0(efi_baseurl, "?datasetId=", dataset_id,
                  "&indicatorIds=", paste(indicator_ids, collapse = ","),
                  "&top=0&skip=0")
  }

  print(url)
  response <- GET(url)
  print(paste("REQUEST STATUS:", status_code(response)))

  if (status_code(response) == 200) {
    data <- content(response, as = "parsed", type = "application/json")
    total_count <- data$count

    if (verbose) {
      print("REQUEST TEXT:")
      print(data)
    }

    all_data <- list()

    if (total_count > 1000) {
      for (i in seq(0, total_count, by = 1000)) {
        if (source == 'd360') {
          fetch_url <- paste0(d360_baseurl, "?DATABASE_ID=", dataset_id,
                              "&INDICATOR=", paste(indicator_ids, collapse = ","),
                              "&skip=", i)
        } else {
          fetch_url <- paste0(efi_baseurl, "?datasetId=", dataset_id,
                              "&indicatorIds=", paste(indicator_ids, collapse = ","),
                              "&top=1000&skip=", i)
        }
        response_chunk <- GET(fetch_url)

        if (status_code(response_chunk) == 200) {
          if (verbose) {
            print("CHUNK RESPONSE TEXT:")
            print(content(response_chunk, as = "text"))
          }
          data_chunk <- content(response_chunk, as = "parsed", type = "application/json")$value
          all_data <- append(all_data, data_chunk)
        } else {
          print(paste("FAILED TO FETCH DATA, status code:", status_code(response_chunk)))
          return(list("ERROR", data.frame()))
        }
      }
    } else {
      data_formatted <- data$value
      all_data <- data_formatted
    }

    # Convert list to dataframe
    APIDataFrame <- bind_rows(all_data)

    if ("count" %in% colnames(APIDataFrame)) {
      APIDataFrame <- select(APIDataFrame, -count)
    }

    return(list("SUCCESS", APIDataFrame))
  } else {
    print(paste("FAILED TO CONNECT TO API, status code:", status_code(response)))
    print(paste("ERROR MSG:", content(response, as = "text")))
    return(list("ERROR", data.frame()))
  }
}



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
for (i in 1:nrow(dbv_df)) {
  row <- dbv_df[i, ]

  # Check for non-missing Indicator_ID
  if (!is.na(row$Indicator_ID)) {
    key <- extract_dataset_id(as.character(row$Indicator_ID))

    if (row$Process == "Data360") {
      row_counter <- row_counter + 1

      if (grepl("WB.GTMI.I", row$Indicator_ID)) {
        value <- gsub("-", ".", row$Indicator_ID)
      } else {
        value <- row$Indicator_ID
      }

      if (key != 'nan' && !is.na(key))  {
        if (is.null(d360_SOURCE_DICT[[key]])) {
          d360_SOURCE_DICT[[key]] <- list()
        }
        d360_SOURCE_DICT[[key]] <- append(d360_SOURCE_DICT[[key]], value)
      }

    } else if (row$Process == "EFI") {
      row_counter <- row_counter + 1
      value <- row$Indicator_ID

      if (key != 'nan' && !is.na(key))  {
        if (is.null(EFI_SOURCE_DICT[[key]])) {
          EFI_SOURCE_DICT[[key]] <- list()
        }
        EFI_SOURCE_DICT[[key]] <- append(EFI_SOURCE_DICT[[key]], value)
      }
    }
  }
}

# Initialize variables
API_CALLS <- 0
Missing_sources <- list()
Fail_Pull <- 0
Expected_L <- 0
Year_range <- start_year:end_year
Years <- paste(Year_range, collapse = ", ")

# Convert d360 dictionary to R list
Indicator_Dict <- lapply(d360_SOURCE_DICT, function(vals) gsub("\\.", "_", vals))
names(Indicator_Dict) <- gsub("\\.", "_", names(d360_SOURCE_DICT))

# EFI dictionary remains same
efi_Indicator_Dict <- EFI_SOURCE_DICT

# Convert to data frame
df_d360 <- tibble::tibble(
  DATABASE_ID = rep(names(Indicator_Dict), lengths(Indicator_Dict)),
  INDICATOR = unlist(Indicator_Dict)
) %>% mutate(Status = 0)

df_efi <- tibble::tibble(
  DATABASE_ID = rep(names(efi_Indicator_Dict), lengths(efi_Indicator_Dict)),
  INDICATOR = unlist(efi_Indicator_Dict)
) %>% mutate(Status = 0)

# Prepare output containers
Full_df_efi <- data.frame(
  COUNTRY_CODE = character(), PARTNER = character(), INDICATOR_ID = character(),
  ATTRIBUTE_1 = character(), ATTRIBUTE_2 = character(), ATTRIBUTE_3 = character(),
  CAL_YEAR = character(), IND_VALUE = numeric(), Median = character(),
  stringsAsFactors = FALSE
)

# ----------- EFI API Pull
for (i in 1:nrow(df_efi)) {
  API_CALLS <- API_CALLS + 1
  Current_dataset <- df_efi$DATABASE_ID[i]
  current_indicators <- df_efi$INDICATOR[i]

  result <- API_toDF(Current_dataset, current_indicators, 'efi')

  if (result[[1]] == 'ERROR') {
    next
  } else {
    api_pull <- result[[2]]
    Full_df_efi <- bind_rows(Full_df_efi, api_pull)
    df_efi$Status[i] <- 1
  }
}

Full_df_efi <- distinct(Full_df_efi)

# ----------- Reshape EFI data
df_filtered <- Full_df_efi %>% select(-any_of(c("PARTNER", "ATTRIBUTE_1", "ATTRIBUTE_2", "ATTRIBUTE_3", "Median")))
pivot_df <- df_filtered %>%
  pivot_wider(names_from = INDICATOR_ID, values_from = IND_VALUE) %>%
  mutate(Year = as.integer(lubridate::year(as.Date(CAL_YEAR))))

pivot_df <- pivot_df %>%
  mutate(Year = as.integer(format(as.Date(CAL_YEAR, format = "%d/%m/%Y"), "%Y"))) %>%
  select(-CAL_YEAR)

df_final <- pivot_df %>%
  filter(Year >= start_year & Year <= end_year) %>%
  rename(ISO3 = COUNTRY_CODE)

# Fill missing (ISO3, Year) combinations
iso3_codes <- unique(df_final$ISO3)
missing_rows <- expand.grid(ISO3 = iso3_codes, Year = Year_range) %>%
  anti_join(df_final, by = c("ISO3", "Year"))
df_final <- bind_rows(df_final, missing_rows) %>%
  arrange(ISO3, Year)


# Clean column names
colnames(df_final) <- colnames(df_final) %>%
  str_replace_all("\\.", "_") %>%
  str_replace_all("-", "_") %>%
  str_replace_all("IMF_WoRLD", "IMF_WORLD") %>%
  str_replace_all("WB_ENTERPRISESURVEYS_IC_FRM", "WB_SURVEY") %>%
  str_replace_all("IDEA_GSOD_v", "IDEA_GSOD_V")


# ------------ D360 API Pull
Full_df_d360 <- data.frame()

for (i in 1:nrow(df_d360)) {
  API_CALLS <- API_CALLS + 1
  Current_dataset <- df_d360$DATABASE_ID[i]
  current_indicators <- df_d360$INDICATOR[i]

  result <- API_toDF(Current_dataset, current_indicators, 'd360')

  if (result[[1]] == 'ERROR') {
    next
  } else {
    api_pull <- result[[2]]
    Full_df_d360 <- bind_rows(Full_df_d360, api_pull)
    df_d360$Status[i] <- 1
  }
}

Full_df_d360 <- distinct(Full_df_d360)

# Reshape D360
data <- Full_df_d360 %>%
  select(INDICATOR, REF_AREA, TIME_PERIOD, OBS_VALUE) %>%
  rename(ISO3 = REF_AREA, Year = TIME_PERIOD)

pivot_df2 <- data %>%
  pivot_wider(names_from = INDICATOR, values_from = OBS_VALUE)

pivot_df2$Year <- as.integer(pivot_df2$Year)
df_final2 <- pivot_df2 %>%
  filter(Year >= start_year & Year <= end_year)

# Merge EFI and D360
key_df <- bind_rows(
  df_final %>% select(ISO3, Year),
  df_final2 %>% select(ISO3, Year)
) %>% distinct()

df_final_left <- left_join(key_df, df_final, by = c("ISO3", "Year"))
df_final2_left <- left_join(key_df, df_final2, by = c("ISO3", "Year"))
df_merged <- full_join(df_final_left, df_final2_left, by = c("ISO3", "Year"))
df_merged <- df_merged %>% filter(ISO3 != "AGGREGATE")


