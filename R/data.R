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
