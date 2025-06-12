#' @title Debt Reporting Heat Map
#' @description How transparent are IDA countries in their debt reporting practices? This heat map presents an assessment based on the availability, completeness, and timeliness of public debt statistics and debt management documents posted on national authorities' websites. The assessment will be updated annually.
#' @format A data frame with 373 rows and 13 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code}
#'   \item{\code{year}}{integer Year}
#'   \item{\code{country}}{character Country name}
#'   \item{\code{debt_transp_data}}{double Data accessibility}
#'   \item{\code{debt_transp_instrument}}{double Instrument coverage}
#'   \item{\code{debt_transp_sectorial}}{double Secotiral coverage}
#'   \item{\code{debt_transp_information}}{double Information on recent contracted loans}
#'   \item{\code{debt_transp_periodicity}}{double Periodicity of reporting}
#'   \item{\code{debt_transp_time}}{double Time lag of reporting}
#'   \item{\code{debt_transp_dms}}{double Debt management strategy}
#'   \item{\code{debt_transp_abp}}{double Annual borrowing plan}
#'   \item{\code{debt_transp_addition}}{double Other debt statistics/contingent liabilities}
#'   \item{\code{debt_transp_index}}{double Row average of all debt transparency indicators}
#'}
#' @source https://www.worldbank.org/en/topic/debt/brief/debt-transparency-report/
"debt_transparency"

#' @title World Bank Country and Lending Groups
#' @description A dataset containing the World Bank's standard country codes, country names, and their respective groups and group codes. This dataset is used to identify countries and their classifications in various World Bank reports and analyses.
#' @format A data frame with 762 rows and 4 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code}
#'   \item{\code{country_name}}{character World Bank country name}
#'   \item{\code{group}}{character Country group}
#'   \item{\code{group_code}}{character Country group code}
#'}
#' @source https://datacatalogapi.worldbank.org/ddhxext/ResourceDownload?resource_unique_id=DR0090755
"wb_country_list"

#' @title World Bank Country Group
#' @description DATASET_DESCRIPTION
#' @format A data frame with 18 rows and 2 variables:
#' \describe{
#'   \item{\code{group_name}}{character Group name}
#'   \item{\code{group_category}}{character Group category (e.g., Economic, Region)}
#'}
#' @source https://datacatalogapi.worldbank.org/ddhxext/ResourceDownload?resource_unique_id=DR0090755
"wb_country_groups"
