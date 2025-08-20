
#' Extract Dataset ID from Indicator Name
#'
#' This function extracts the EFI source (dataset ID) required for an API pull
#' from a given indicator name. It identifies and returns the substring between
#' the first and second occurrences of a specified delimiter character.
#'
#' @param input_id A character string representing the full indicator name.
#' @param splitchar A character string used as the delimiter to split the input. Default is \code{'.'}.
#'
#' @return A character string representing the extracted dataset ID. If the delimiter
#'         is not found twice, the original \code{input_id} is returned.
#'
#' @examples
#' extract_dataset_id("WDI.GDP.PC")
#' extract_dataset_id("IMF.WEO.GDP", splitchar = ".")
#'
#' @importFrom stringr str_locate fixed
#'
#' @export
#'
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

#' Extract Data from World Bank APIs (Data360 or EFI)
#'
#' This function retrieves indicator-level data from either the World Bank Data360 API
#' or the EFI (Enterprise Surveys/EFI Data Catalog) API. It automatically handles pagination
#' for large datasets (over 1000 records) by fetching data in chunks and combining the
#' results into a single data frame.
#'
#' @details
#' - The function constructs a query URL based on the provided `dataset_id`, `indicator_ids`,
#'   and `source` parameters.
#' - For `source = "d360"`, the function queries the Data360 API endpoint.
#' - For `source = "efi"`, it queries the EFI Data Catalog API endpoint.
#' - If the total number of records exceeds 1000, the function iteratively fetches
#'   data in batches of 1000 records until all data is retrieved.
#' - If any API call fails (status code != 200), the function returns an error result.
#'
#' @param dataset_id A character string specifying the dataset ID (e.g., \code{"WDI"}).
#' @param indicator_ids A character vector of indicator IDs to retrieve (e.g., \code{c("NY.GDP.MKTP.CD")}).
#' @param source A character string indicating the API source.
#'        Must be one of \code{"d360"} or \code{"efi"}.
#' @param verbose Logical; if \code{TRUE}, prints detailed request information
#'        (including URLs and raw responses for each request).
#'
#' @return A list of length two:
#' \describe{
#'   \item{\code{"SUCCESS"}}{A data frame containing all requested indicator data.}
#'   \item{\code{"ERROR"}}{An empty data frame if any API request fails.}
#' }
#'
#' @section Error Handling:
#' - If the initial request fails, an "ERROR" result is returned along with an empty data frame.
#' - If a chunked request (pagination) fails, the function stops and returns "ERROR".
#'
#' @examples
#' \dontrun{
#' # Example: Retrieve GDP data from the WDI dataset using the Data360 API
#' result <- Extract_data_from_API(
#'   dataset_id = "WDI",
#'   indicator_ids = c("NY.GDP.MKTP.CD"),
#'   source = "d360",
#'   verbose = TRUE
#' )
#'
#' if (result[[1]] == "SUCCESS") {
#'   head(result[[2]])
#' }
#' }
#'
#' @seealso
#' \itemize{
#'   \item{\code{\link[httr]{GET}} for HTTP GET requests.}
#'   \item{\code{\link[dplyr]{bind_rows}} for combining the paginated results.}
#' }
#'
#' @import httr
#' @export
#'
extract_data_from_api <- function(dataset_id,
                                  indicator_ids,
                                  source,
                                  verbose = FALSE) {

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
  response <- httr::GET(url)
  print(paste("REQUEST STATUS:", httr::status_code(response)))

  if (httr::status_code(response) == 200) {
    data <- httr::content(response, as = "parsed", type = "application/json")
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
        response_chunk <- httr::GET(fetch_url)

        if (httr::status_code(response_chunk) == 200) {
          if (verbose) {
            print("CHUNK RESPONSE TEXT:")
            print(httr::content(response_chunk, as = "text"))
          }
          data_chunk <- httr::content(response_chunk, as = "parsed", type = "application/json")$value
          all_data <- append(all_data, data_chunk)
        } else {
          print(paste("FAILED TO FETCH DATA, status code:", httr::status_code(response_chunk)))
          return(list("ERROR", data.frame()))
        }
      }
    } else {
      data_formatted <- data$value
      all_data <- data_formatted
    }

    # Convert list to dataframe
    APIDataFrame <- dplyr::bind_rows(all_data)

    if ("count" %in% colnames(APIDataFrame)) {
      APIDataFrame <- dplyr::select(APIDataFrame, -count)
    }

    return(list("SUCCESS", APIDataFrame))
  } else {
    print(paste("FAILED TO CONNECT TO API, status code:", httr::status_code(response)))
    print(paste("ERROR MSG:", httr::content(response, as = "text")))
    return(list("ERROR", data.frame()))
  }
}
