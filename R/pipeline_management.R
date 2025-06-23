################################################################################
############### SOME FUNCTIONS FOR DATA PIPELINE MANAGEMENT ####################
################################################################################

#' Add Metadata Attributes to a Dataset
#'
#' Adds metadata to a `data.frame`, such as the source URL, download date, and any additional information.
#'
#' @param df A `data.frame` object to which metadata will be added.
#' @param source A `character` string indicating the URL or source of the dataset.
#' @param other_info A `character` string containing any additional metadata or descriptive information.
#'
#' @return The input `data.frame` with additional attributes:
#' \describe{
#'   \item{`source`}{The URL or source location of the dataset.}
#'   \item{`other info`}{Any user-supplied contextual information.}
#'   \item{`download_date`}{The date when the data was processed or downloaded.}
#' }
#'
#' @examples
#' df <- data.frame(x = 1:5)
#' df_meta <- add_plmetadata(df,
#'                           source = "https://example.com/data.csv",
#'                           other_info = "Mock dataset for demo")
#' attributes(df_meta)
#'
#' @export
add_plmetadata <- function(df,
                           source,
                           other_info) {
  attr(df, "source") <- source
  attr(df, "other_info") <- other_info
  attr(df, "latest_download") <- Sys.Date()

  return(df)

}


#' Collect metadata from all datasets in the package data folder
#'
#' @param data_path Path to the `data/` folder (default = "data").
#'
#' @return A data frame with metadata for each dataset in the package.
#'
#' @importFrom purrr map_dfr
#' @importFrom tibble tibble
#' @export
collect_metadata <- function(data_path = "data") {

  df <-
  list.files(data_path,
             pattern = "\\.rda$",
             full.names = TRUE) |>
    map_dfr(function(file_path) {
      env <- new.env()
      load(file_path, envir = env)

      obj_name <- ls(env)[1]
      obj <- env[[obj_name]]

      tibble::tibble(
        dataset = obj_name,
        source = attr(obj, "source") %||% NA_character_,
        other_info = attr(obj, "other_info") %||% NA_character_,
        latest_download = as.character(attr(obj, "latest_download") %||% NA)
      )
    })

  return(df)

}





