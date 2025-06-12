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


#' @title PEFA Assessment Dataset (2016 Framework Indicators)
#'
#' @description This dataset contains indicators from the PEFA (Public Expenditure and Financial Accountability) assessments conducted using the 2016 PEFA framework. It provides scores on various dimensions of public financial management across countries and time periods. The indicators cover budget credibility, transparency, asset and debt management, internal controls, auditing, and more.
#'
#' The data are sourced from the PEFA bulk download page: \url{https://www.pefa.org/assessments/batch-downloads}.
#'
#' @format A data frame with one row per PEFA assessment and the following variables:
#' \describe{
#'   \item{wb_pefa_pi_2016_05}{Budget Documentation — Quality and comprehensiveness of budget documentation provided to the legislature.}
#'   \item{wb_pefa_pi_2016_07}{Transfers to subnational governments — Transparency and timeliness of transfers from central to subnational levels.}
#'   \item{wb_pefa_pi_2016_08}{Performance information for service delivery — Availability and quality of performance information for service delivery sectors.}
#'   \item{wb_pefa_pi_2016_10}{Fiscal risk reporting — Identification and disclosure of fiscal risks to public finances.}
#'   \item{wb_pefa_pi_2016_11}{Public investment management — Effectiveness of planning, selection, and implementation of public investment projects.}
#'   \item{wb_pefa_pi_2016_12}{Public asset management — Management of public assets, including non-financial assets and natural resources.}
#'   \item{wb_pefa_pi_2016_13}{Debt management — Strategy, recording, reporting, and evaluation of public debt.}
#'   \item{wb_pefa_pi_2016_14}{Macroeconomic and fiscal forecasting — Realism and consistency of macroeconomic and fiscal projections.}
#'   \item{wb_pefa_pi_2016_15}{Fiscal strategy — Existence and quality of a medium-term fiscal strategy.}
#'   \item{wb_pefa_pi_2016_16}{Medium term perspective in expenditure budgeting — Integration of the medium-term expenditure framework into the budget process.}
#'   \item{wb_pefa_pi_2016_17}{Budget preparation process — Orderliness and timeliness of the annual budget preparation.}
#'   \item{wb_pefa_pi_2016_18}{Legislative scrutiny of budgets — Scope and timeliness of legislative review of the budget.}
#'   \item{wb_pefa_pi_2016_19}{Revenue administration — Efficiency, transparency, and effectiveness of revenue administration.}
#'   \item{wb_pefa_pi_2016_20}{Accounting for revenues — Recording and reconciliation of revenue collections.}
#'   \item{wb_pefa_pi_2016_21}{Predictability of in-year resource allocation — Reliability and transparency of in-year budget releases.}
#'   \item{wb_pefa_pi_2016_22}{Expenditure arrears — Monitoring and controlling of expenditure arrears.}
#'   \item{wb_pefa_pi_2016_23}{Payroll controls — Effectiveness of payroll controls, including integrity of personnel records.}
#'   \item{wb_pefa_pi_2016_24}{Procurement — Transparency, competitiveness, and monitoring of public procurement processes.}
#'   \item{wb_pefa_pi_2016_25}{Internal controls on nonsalary expenditure — Effectiveness of internal controls and compliance for non-salary expenditures.}
#'   \item{wb_pefa_pi_2016_26}{Internal audit effectiveness — Effectiveness, coverage, and follow-up of internal audit.}
#'   \item{wb_pefa_pi_2016_27}{Financial data integrity — Reliability and integrity of financial data.}
#'   \item{wb_pefa_pi_2016_28}{In-year budget reports — Timeliness and coverage of in-year budget execution reports.}
#'   \item{wb_pefa_pi_2016_29}{Annual financial reports — Completeness, accuracy, and timeliness of annual financial reports.}
#'   \item{wb_pefa_pi_2016_30}{External audit — Coverage, timeliness, and follow-up of external audit.}
#' }
#'
#' @source \url{https://www.pefa.org/assessments/batch-downloads}
#' @keywords datasets
#' @name pefa_assessments
#' @docType data
"pefa_assessments"




