#' @title Debt Reporting Heat Map
#' @description How transparent are IDA countries in their debt reporting practices? This heat map presents an assessment based on the availability, completeness, and timeliness of public debt statistics and debt management documents posted on national authorities' websites. The assessment will be updated annually.
#' @format A data frame with 373 rows and 13 variables:
#' \describe{
#'   \item{\code{country_code}}{character World Bank country code}
#'   \item{\code{year}}{integer Year}
#'   \item{\code{wb_debt_transp_index}}{double. Composite index: row average of all debt transparency indicators}
#'}
#'#' @details
#' Below are the longer descriptions for each variable (when provided):
#' \itemize{
#'   \item \strong{wb_debt_transp_index}: The debt transparency index is obtained as a simple average of the World Bank's debt reporting heatmap sub-components (Debt Transparency in Developing Economies) that measure instrument and sectorial coverage of debt statistics, availability of financial terms on new loans, and publication of DMS and ABP.
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
#' @description This dataset contains indicators from the PEFA (Public Expenditure and Financial Accountability) assessments conducted using the 2016 PEFA framework. It provides scores on various dimensions of public financial management across countries and time periods. The indicators cover budget credibility, transparency, asset and debt management, internal controls, auditing, and more. The data are sourced from the PEFA bulk download page: \url{https://www.pefa.org/assessments/batch-downloads}.
#' @format A data frame with one row per PEFA assessment and the following variables:
#' \describe{
#'   \item{country_name}{The Country Name}
#'   \item{year}{Year}
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

#' Central Bank Independence Index (Romelli Update of Cukierman et al.)
#'
#' This dataset provides an annual panel of central bank independence (CBI) scores for countries,
#' based on the unweighted index developed by Cukierman et al. (1992) and recomputed by Romelli using
#' updated legal and institutional data.
#'
#' The index ranges from 0 to 1, where 0 represents the lowest level of independence and 1 the highest.
#' It measures de jure independence, focusing on aspects such as governor appointment, monetary policy formulation,
#' central bank objectives, and limitations on lending to the government.
#'
#' @format A tibble with 8,128 rows and 3 variables:
#' \describe{
#'   \item{country_code}{A 3-letter ISO country code (e.g., "USA", "FRA", "ARG").}
#'   \item{year}{The calendar year (numeric).}
#'   \item{romelli_cbi_central_bank_independence}{Cukierman central bank independence index (scaled 0 to 1).}
#' }
#'
#' @source Romelli, Davide (2022). \emph{The Political Economy of Reforms in Central Bank Design:
#' Evidence from a New Dataset}. Review of International Organizations.
#' \url{https://cbidata.org/}
#'
#' @references Cukierman, A., Webb, S. B., & Neyapti, B. (1992). \emph{Measuring the Independence of Central Banks
#' and Its Effect on Policy Outcomes}. The World Bank Economic Review, 6(3), 353–398.
#'
#'
"romelli"

#' @title World Development Indicators (WDI) Dataset
#' @description A dataset containing World Development Indicators from the World Bank, providing time-series data for multiple countries.
#' @format A data frame with 7,310 rows and 129 variables:
#' \describe{
#'   \item{\code{country_code}}{character The 3-letter ISO code for the country or region.}
#'   \item{\code{year}}{integer The year of the observation.}
#'   \item{\code{wdi_gcdodtotlgdzs}}{double Government Consumption, Domestic Defense, Total (percentage of GDP).}
#'   \item{\code{wdi_enghgco2rtgdpppkd}}{double Carbon intensity of GDP (kg CO2e per 2021 PPP USD of GDP)}
#'   \item{\code{wdi_bncabxokagdzs}}{double Current Account Balance (percentage of GDP).}
#'   \item{\code{wdi_gcxpntotlgdzs}}{double General government expenditure (percentage of GDP).}
#'   \item{\code{wdi_neexpgnfszs}}{double Exports of goods and services (percentage of GDP).}
#'   \item{\code{wdi_necontotlzs}}{double Total consumption (percentage of GDP).}
#'   \item{\code{wdi_bxkltdinvwdgdzs}}{double Foreign direct investment, net inflows (percentage of GDP).}
#'   \item{\code{wdi_bmkltdinvwdgdzs}}{double Foreign direct investment, net outflows (percentage of GDP).}
#'   \item{\code{wdi_nygdpmktpkd}}{double GDP (constant LCU).}
#'   \item{\code{wdi_nygdpdeflzs}}{double GDP deflator (base year varies by country).}
#'   \item{\code{wdi_nygdpdeflzsad}}{double Adjusted GDP deflator (base year varies by country).}
#'   \item{\code{wdi_nygdpmktpkdzg}}{double GDP growth (annual percentage).}
#'   \item{\code{wdi_nygdppcapkd}}{double GDP per capita (constant LCU).}
#'   \item{\code{wdi_nygdppcapkdzg}}{double GDP per capita growth (annual percentage).}
#'   \item{\code{wdi_nygdppcapppkd}}{double GDP per capita, PPP (constant 2017 international USD).}
#'   \item{\code{wdi_nygdpmktpppkd}}{double GDP, PPP (constant 2017 international USD).}
#'   \item{\code{wdi_necongovtzs}}{double General government final consumption expenditure (percentage of GDP).}
#'   \item{\code{wdi_negditotlzs}}{double Gross capital formation (percentage of GDP).}
#'   \item{\code{wdi_nygdstotlzs}}{double Gross domestic savings (percentage of GDP).}
#'   \item{\code{wdi_negdiftotzs}}{double Gross fixed capital formation (percentage of GDP).}
#'   \item{\code{wdi_nedabtotlzs}}{double Gross national expenditure (percentage of GDP).}
#'   \item{\code{wdi_nygnsictrzs}}{double Gross national income (constant LCU).}
#'   \item{\code{wdi_neimpgnfszs}}{double Imports of goods and services (percentage of GDP).}
#'   \item{\code{wdi_nygdpdeflkdzg}}{double Inflation, GDP deflator (annual percentage).}
#'   \item{\code{wdi_nygdpdeflkdzgad}}{double Adjusted inflation, GDP deflator (annual percentage).}
#'   \item{\code{wdi_nvindmanfzs}}{double Manufacturing, value added (percentage of GDP).}
#'   \item{\code{wdi_msmilxpndgdzs}}{double Military expenditure (percentage of GDP).}
#'   \item{\code{wdi_nygdpminrrtzs}}{double Ores and metals exports (percentage of merchandise exports).}
#'   \item{\code{wdi_nygdpngasrtzs}}{double Natural gas rents (percentage of GDP).}
#'   \item{\code{wdi_gcnldtotlgdzs}}{double Net lending/borrowing (percentage of GDP).}
#'   \item{\code{wdi_nygdppetrrtzs}}{double Oil rents (percentage of GDP).}
#'   \item{\code{wdi_bxtrfpwkrdtgdzs}}{double Personal remittances, received (percentage of GDP).}
#'   \item{\code{wb_wdi_gc_rev_xgrt_gd_zs}}{double Revenue, excluding grants (percentage of GDP).}
#'   \item{\code{wdi_nvsrvtotlzs}}{double Services, etc., value added (percentage of GDP).}
#'   \item{\code{wdi_nygdptotlrtzs}}{double Total natural resource rents (percentage of GDP).}
#'   \item{\code{wdi_netrdgnfszs}}{double Trade (percentage of GDP).}
#'   \item{\code{wdi_nygnpmktpkd}}{double GNI (constant LCU).}
#'   \item{\code{wdi_dtdoddectgnzs}}{double Debt service (PPG and IMF only, percentage of GNI).}
#'   \item{\code{wdi_nygnpmktpkdzg}}{double GNI growth (annual percentage).}
#'   \item{\code{wdi_nygnppcapkd}}{double GNI per capita (constant LCU).}
#'   \item{\code{wdi_nygnppcapkdzg}}{double GNI per capita growth (annual percentage).}
#'   \item{\code{wdi_nygnppcapppkd}}{double GNI per capita, PPP (constant 2017 international USD).}
#'   \item{\code{wdi_nygnpmktpppkd}}{double GNI, PPP (constant 2017 international USD).}
#'   \item{\code{wdi_dtodaodatgnzs}}{double Net ODA received (percentage of GNI).}
#'   \item{\code{wdi_dttdsdppggnzs}}{double Debt service on external debt (percentage of exports of goods, services and primary income).}
#'   \item{\code{wdi_dttdsdectgnzs}}{double Debt service on external debt (percentage of GNI).}
#'   \item{\code{wdi_dtdoddstczs}}{double External debt stocks (percentage of GDP).}
#'   \item{\code{wdi_dtdoddstcirzs}}{double External debt stocks, total (percentage of exports of goods, services and primary income).}
#'   \item{\code{wdi_dttdsdectexzs}}{double Total debt service (percentage of exports of goods, services and primary income).}
#'   \item{\code{wdi_firestotldtzs}}{double Total reserves (percentage of external debt).}
#'   \item{\code{wdi_dtdoddstcxpzs}}{double External debt stocks (percentage of exports of goods, services and primary income).}
#'   \item{\code{wdi_dttdsmlatpgzs}}{double Multilateral debt service (percentage of public and publicly guaranteed debt service).}
#'   \item{\code{wdi_gcrevsoclzs}}{double Social contributions (percentage of revenue).}
#'   \item{\code{wdi_msmiltotltfzs}}{double Armed forces personnel, total.}
#'   \item{\code{wdi_sluemtotlnezs}}{double Unemployment, total (percentage of total labor force) (national estimate).}
#'   \item{\code{wdi_sluemtotlzs}}{double Unemployment, total (percentage of total labor force) (ILO estimate).}
#'   \item{\code{wdi_shxpdghedgdzs}}{double Domestic general government health expenditure (percentage of GDP).}
#'   \item{\code{wdi_sexpdtotlgdzs}}{double Expenditure on education, total (percentage of GDP).}
#'   \item{\code{wdi_sexpdprimpczs}}{double Primary education expenditure per student (percentage of GDP per capita).}
#'   \item{\code{wdi_sexpdsecopczs}}{double Secondary education expenditure per student (percentage of GDP per capita).}
#'   \item{\code{wdi_sexpdtertpczs}}{double Tertiary education expenditure per student (percentage of GDP per capita).}
#'   \item{\code{wdi_seadtlitrfezs}}{double Literacy rate, adult female (percentage of females ages 15 and above).}
#'   \item{\code{wdi_seadtlitrmazs}}{double Literacy rate, adult male (percentage of males ages 15 and above).}
#'   \item{\code{wdi_seadtlitrzs}}{double Literacy rate, adult total (percentage of people ages 15 and above).}
#'   \item{\code{wdi_shdynmort}}{double Mortality rate, under-5 (per 1,000 live births).}
#'   \item{\code{wdi_shstaanvczs}}{double Prevalence of anemia among children (percentage of children under 5).}
#'   \item{\code{wdi_shstammrt}}{double Maternal mortality ratio (modeled estimate, per 100,000 live births).}
#'   \item{\code{wdi_shdynmortfe}}{double Mortality rate, female, under-5 (per 1,000 live births).}
#'   \item{\code{wdi_shdynmortma}}{double Mortality rate, male, under-5 (per 1,000 live births).}
#'   \item{\code{wdi_secomdurs}}{double Compulsory education, duration (years).}
#'   \item{\code{wdi_sexpdcprmzs}}{double Current education expenditure, primary (percentage of total expenditure).}
#'   \item{\code{wdi_sexpdcseczs}}{double Current education expenditure, secondary (percentage of total expenditure).}
#'   \item{\code{wdi_sexpdcterzs}}{double Current education expenditure, tertiary (percentage of total expenditure).}
#'   \item{\code{wdi_sexpdctotzs}}{double Current education expenditure, total (percentage of total expenditure).}
#'   \item{\code{wdi_sexpdtotlgbzs}}{double Expenditure on education, total (percentage of government expenditure).}
#'   \item{\code{wdi_sesectcaqlozs}}{double Teachers in secondary education, lower secondary (percentage of total teachers).}
#'   \item{\code{wdi_sepretcaqzs}}{double Teachers in preprimary education (percentage of total teachers).}
#'   \item{\code{wdi_seprmtcaqzs}}{double Teachers in primary education (percentage of total teachers).}
#'   \item{\code{wdi_sesectcaqzs}}{double Teachers in secondary education (percentage of total teachers).}
#'   \item{\code{wdi_sesectcaqupzs}}{double Teachers in secondary education, upper secondary (percentage of total teachers).}
#'   \item{\code{wdi_seprmtenr}}{double Primary education, teachers (number).}
#'   \item{\code{wdi_shstabrtczs}}{double Stunting prevalence, children (percentage).}
#'   \item{\code{wdi_shxpdchexgdzs}}{double Current health expenditure (percentage of GDP).}
#'   \item{\code{wdi_shxpdoopcchzs}}{double Out-of-pocket health expenditure (percentage of current health expenditure).}
#'   \item{\code{wdi_shxpdoopcppcd}}{double Out-of-pocket health expenditure per capita (current USD).}
#'   \item{\code{wdi_sipovgaps}}{double Poverty gap at national poverty line (percentage of poverty line).}
#'   \item{\code{wdi_sipovlmicgp}}{double Poverty gap at USD2.15 a day (2017 PPP) (percentage of poverty line).}
#'   \item{\code{wdi_sipovumicgp}}{double Poverty gap at USD3.65 a day (2017 PPP) (percentage of poverty line).}
#'   \item{\code{wdi_sipovdday}}{double Poverty headcount ratio at USD2.15 a day (2017 PPP) (percentage of population).}
#'   \item{\code{wdi_sipovlmic}}{double Poverty headcount ratio at USD3.65 a day (2017 PPP) (percentage of population).}
#'   \item{\code{wdi_sipovumic}}{double Poverty headcount ratio at USD6.85 a day (2017 PPP) (percentage of population).}
#'   \item{\code{wdi_sipovnahc}}{double Poverty headcount ratio at national poverty lines (percentage of population).}
#'   \item{\code{wdi_seprmenrltczs}}{double Primary school enrollment, total (percentage gross).}
#'   \item{\code{wdi_sesecenrltczs}}{double Secondary school enrollment, total (percentage gross).}
#'   \item{\code{wdi_seterenrltczs}}{double Tertiary school enrollment, total (percentage gross).}
#'   \item{\code{wdi_shmedbedszs}}{double Hospital beds (per 1,000 people).}
#'   \item{\code{wdi_shmedphyszs}}{double Physicians (per 1,000 people).}
#'   \item{\code{wdi_spregbrthzs}}{double Births registered (percentage of births).}
#'   \item{\code{wdi_spregbrthruzs}}{double Births registered, rural (percentage of rural births).}
#'   \item{\code{wdi_spregbrthurzs}}{double Births registered, urban (percentage of urban births).}
#'   \item{\code{wdi_iqcpahresxq}}{double CPIA policies for social inclusion and equity cluster average (1=low to 6=high).}
#'   \item{\code{wdi_iqcpabregxq}}{double CPIA building human capital cluster average (1=low to 6=high).}
#'   \item{\code{wdi_iqcpadebtxq}}{double CPIA debt policy (1=low to 6=high).}
#'   \item{\code{wdi_iqcpaeconxq}}{double CPIA economic management cluster average (1=low to 6=high).}
#'   \item{\code{wdi_iqcparevnxq}}{double CPIA revenue mobilization (1=low to 6=high).}
#'   \item{\code{wdi_iqcpapresxq}}{double CPIA quality of budgetary and financial management (1=low to 6=high).}
#'   \item{\code{wdi_iqcpafispxq}}{double CPIA fiscal policy (1=low to 6=high).}
#'   \item{\code{wdi_iqcpafinsxq}}{double CPIA financial sector (1=low to 6=high).}
#'   \item{\code{wdi_iqcpagndrxq}}{double CPIA gender equality (1=low to 6=high).}
#'   \item{\code{wdi_iqcpamacrxq}}{double CPIA macroeconomic management (1=low to 6=high).}
#'   \item{\code{wdi_iqcpasocixq}}{double CPIA social protection and labor (1=low to 6=high).}
#'   \item{\code{wdi_iqcpaenvrxq}}{double CPIA environmental sustainability (1=low to 6=high).}
#'   \item{\code{wdi_iqcpapropxq}}{double CPIA property rights and rule-based governance (1=low to 6=high).}
#'   \item{\code{wdi_iqcpapubsxq}}{double CPIA quality of public administration (1=low to 6=high).}
#'   \item{\code{wdi_iqcpafinqxq}}{double CPIA transparency, accountability, and corruption in the public sector (1=low to 6=high).}
#'   \item{\code{wdi_iqcpapadmxq}}{double CPIA public sector management and institutions cluster average (1=low to 6=high).}
#'   \item{\code{wdi_iqcpaprotxq}}{double CPIA business regulatory environment (1=low to 6=high).}
#'   \item{\code{wdi_iqcpastrcxq}}{double CPIA structural policies cluster average (1=low to 6=high).}
#'   \item{\code{wdi_iqcpatradxq}}{double CPIA trade (1=low to 6=high).}
#'   \item{\code{wdi_iqcpatranxq}}{double CPIA infrastructure (1=low to 6=high).}
#' }
#' @source World Development Indicators (WDI) R Package https://vincentarelbundock.github.io/WDI/.
"wdi_indicators"

#' @title V-Dem Core Indicators, Version 15
#' @description A country–year panel of 52 core indicators from the Varieties of Democracy (V‑Dem) 2025 release, processed for the CLIAR ETL pipeline.
#' @format A data frame with 6,204 rows and 52 variables:
#' \describe{
#'   \item{country_code}{Three‑letter ISO3 country code.}
#'   \item{year}{Calendar year.}
#'   \item{vdem_core_v2x_corr}{Political corruption index (`v2x_corr`). Higher values = less corruption.}
#'   \item{vdem_core_v2exbribe}{Executive bribery & corrupt exchanges (`v2exbribe`).}
#'   \item{vdem_core_v2xcl_prpty}{Private property rights index (`v2xcl_prpty`).}
#'   \item{vdem_core_v2xcl_acjst}{Access to justice for civil liberties (`v2xcl_acjst`).}
#'   \item{vdem_core_v2juhcind}{High court independence (`v2juhcind`).}
#'   \item{vdem_core_v2juncind}{Lower court independence (`v2juncind`).}
#'   \item{vdem_core_v2juaccnt}{Judicial accountability (`v2juaccnt`).}
#'   \item{vdem_core_v2pepwrgen}{Power distributed by gender (`v2pepwrgen`).}
#'   \item{vdem_core_v2pepwrsoc}{Power distributed by social group (`v2pepwrsoc`).}
#'   \item{vdem_core_v2pepwrses}{Power distributed by socioeconomic position (`v2pepwrses`).}
#'   \item{vdem_core_v2xlg_legcon}{Legislature constraints on the executive (`v2xlg_legcon`).}
#'   \item{vdem_core_v2x_gender}{Women’s political equality index (`v2x_gender`).}
#'   \item{vdem_core_v2stcritrecadm}{Rigorous public‐sector recruitment procedures (`v2stcritrecadm`).}
#'   \item{vdem_core_v2clrspct}{Government respect for religious freedom (`v2clrspct`).}
#'   \item{vdem_core_v2cseeorgs}{Civil society entry & exit freedom (`v2cseeorgs`).}
#'   \item{vdem_core_v2dlengage}{Deliberative popular engagement index (`v2dlengage`).}
#'   \item{vdem_core_v2clacfree}{Academic & cultural expression freedom (`v2clacfree`).}
#'   \item{vdem_core_v2csreprss}{Civil society repression (`v2csreprss`).}
#'   \item{vdem_core_v2x_civlib}{Core civil liberties index (`v2x_civlib`).}
#'   \item{vdem_core_v2x_cspart}{Civil society participatory environment (`v2x_cspart`).}
#'   \item{vdem_core_v2clstown}{State ownership of major broadcast media (`v2clstown`).}
#'   \item{vdem_core_v2clacjstm}{Media self‐censorship: military issues (`v2clacjstm`).}
#'   \item{vdem_core_v2clacjstw}{Media self‐censorship: welfare issues (`v2clacjstw`).}
#'   \item{vdem_core_v2lgqugen}{Legislature quota for gender (`v2lgqugen`).}
#'   \item{vdem_core_v2cldiscm}{State‐based political discrimination against men (`v2cldiscm`).}
#'   \item{vdem_core_v2cldiscw}{State‐based political discrimination against women (`v2cldiscw`).}
#'   \item{vdem_core_v2cacamps}{Freedom of campus assembly (`v2cacamps`).}
#'   \item{vdem_core_v2peapsecon}{Socio‑economic power inequality (`v2peapsecon`).}
#'   \item{vdem_core_v2peasjsoecon}{Socio‑economic power by social group (`v2peasjsoecon`).}
#'   \item{vdem_core_v2peapsgen}{Political power inequality by gender (`v2peapsgen`).}
#'   \item{vdem_core_v2peapspol}{Political power inequality by political group (`v2peapspol`).}
#'   \item{vdem_core_v2peasjpol}{Social group–political power interaction (`v2peasjpol`).}
#'   \item{vdem_core_v2x_pubcorr}{Public sector corruption index (`v2x_pubcorr`).}
#'   \item{vdem_core_v2x_execorr}{Executive corruption index (`v2x_execorr`).}
#'   \item{vdem_core_v2lgcrrpt}{Legislature corrupt activities (`v2lgcrrpt`).}
#'   \item{vdem_core_v2dlencmps}{Particularistic vs. public‐good orientation (`v2dlencmps`).}
#'   \item{vdem_core_v2peedueq}{Educational equality (`v2peedueq`).}
#'   \item{vdem_core_v2pehealth}{Health equality (`v2pehealth`).}
#'   \item{vdem_core_v2peasbepol}{Political power access by political group (`v2peasbepol`).}
#'   \item{vdem_core_v2cafres}{Academic freedom: research & teaching (`v2cafres`).}
#'   \item{vdem_core_v2cafexch}{Academic freedom: exchange & dissemination (`v2cafexch`).}
#'   \item{vdem_core_v2x_rule}{Rule of law index (`v2x_rule`).}
#'   \item{vdem_core_v2xed_ed_cent}{Education system centralization (`v2xed_ed_cent`).}
#'   \item{vdem_core_v2xed_ed_ctag}{Education system regional targeting (`v2xed_ed_ctag`).}
#'   \item{vdem_core_v2xed_ed_con}{Education system content control (`v2xed_ed_con`).}
#'   \item{vdem_core_v2edteautonomy}{Teacher autonomy in education (`v2edteautonomy`).}
#'   \item{vdem_core_v2edteunionindp}{Independence of teachers’ unions (`v2edteunionindp`).}
#' }
#' @source Varieties of Democracy (V‑Dem) Institute. 2025. V‑Dem v15 Dataset. \url{https://www.v-dem.net/data/the-v-dem-dataset/}
"vdem_data"


#' Heritage Index of Economic Freedom Data
#'
#' A dataset containing country-level scores from the Heritage Foundation's Index of Economic Freedom, focused on freedom indicators relevant to business, finance, and investment sectors.
#'
#' @format A tibble with 2,381 rows and 5 variables:
#' \describe{
#'   \item{country_code}{A three-letter ISO 3166-1 alpha-3 country code identifying the country.}
#'   \item{year}{The year of the score, adjusted so that a given year's value reflects the conditions of the previous year.}
#'   \item{heritage_business_freedom}{Score measuring the extent to which the regulatory and infrastructure environments constrain the efficient operation of businesses.
#'   A higher score indicates fewer regulatory barriers and more ease in starting, operating, and closing a business.}
#'   \item{heritage_financial_freedom}{Score reflecting banking efficiency and independence from government control or interference in the financial sector.
#'   State ownership of banks and other financial institutions typically reduces competition and lowers credit access.}
#'   \item{heritage_investment_freedom}{Score based on the degree of regulatory restrictions on investment activities.
#'   Deductions are made from a baseline score of 100 for various restrictions; countries with extremely high levels of restriction may receive a score of 0.}
#' }
#'
#' @details
#' The business freedom component measures the extent to which the regulatory and infrastructure environments constrain the efficient operation of businesses. The quantitative score is derived from an array of factors that affect the ease of starting, operating, and closing a business.
#'
#' Financial freedom is both an indicator of banking efficiency and a measure of independence from government control and interference in the financial sector. State ownership of banks and other financial institutions such as insurers and capital markets reduces competition and generally lowers access to credit.
#'
#' The investment freedom score reflects the degree of regulatory restrictions imposed on investment. Deductions are applied from the ideal score of 100 for each type of restriction. Countries with very high levels of restriction may receive a score of zero.
#'
#' @source Heritage Foundation, Index of Economic Freedom. See: \url{https://www.heritage.org/index/}
"heritage"


#' Global Financial Development Database (GFDB) Indicators
#'
#' A dataset containing selected indicators from the World Bank's Global Financial Development Database (GFDB), covering financial sector performance across countries and years. This data focuses on domestic credit provision and concentration of banking assets.
#'
#' @format A tibble with 6,848 rows and 4 variables:
#' \describe{
#'   \item{country_code}{A three-letter ISO 3166-1 alpha-3 country code.}
#'   \item{year}{The calendar year of the observation.}
#'   \item{wb_gfdb_oi_01}{Assets of the three largest commercial banks as a share of total commercial banking assets.
#'   Total assets include earning assets, cash, due from banks, foreclosed real estate, fixed assets, goodwill, intangibles, tax assets, and other financial assets. A higher value indicates greater banking sector concentration.}
#'   \item{wb_gfdb_di_01}{Measures the financial resources provided to the private sector by domestic money banks as a share of GDP.
#'   Domestic money banks comprise commercial banks and other financial institutions that accept transferable deposits, such as demand deposits.}
#' }
#'
#'
#'
#' @source World Bank, Global Financial Development Database. See: \url{https://www.worldbank.org/en/publication/gfdr/data/global-financial-development-database}
"gfdb"


#' OECD PMR Dataset - 2018 Edition
#'
#' This dataset contains a selection of indicators from the 2018 OECD Product Market Regulation (PMR)
#' database for 49 countries. These indicators measure various aspects of government involvement in
#' business, market openness, and regulatory quality.
#'
#' @format A tibble with 49 rows and 10 variables:
#' \describe{
#'   \item{country_code}{Three-letter ISO country code.}
#'   \item{year}{Year of observation (2018).}
#'   \item{oecd_pmr_2018_1_1}{Government ownership in business sectors.}
#'   \item{oecd_pmr_2018_1_2}{Government stake in the largest network firms.}
#'   \item{oecd_pmr_2018_1_3}{Government special rights in private firms.}
#'   \item{oecd_pmr_2018_1_4}{Stakeholder engagement in regulatory processes.}
#'   \item{oecd_pmr_2018_2_1}{Tariff regulation and competition-limiting rules.}
#'   \item{oecd_pmr_2018_2_2}{Autonomy and transparency of state-owned enterprises.}
#'   \item{oecd_pmr_2018_3_3}{Administrative simplification and communication.}
#'   \item{oecd_pmr_2018_6}{FDI restrictiveness and trade barriers.}
#' }
#'
#' @description
#' This dataset provides numeric scores for eight OECD PMR indicators, which assess the extent of
#' product market regulation across key domains. Higher scores generally indicate more restrictive
#' or interventionist policy environments.
#'
#' @details
#' \itemize{
#'   \item \strong{oecd_pmr_2018_1_1:} Measures whether the government controls at least one firm in a number of business sectors, with a higher weight given to key network sectors.
#'   \item \strong{oecd_pmr_2018_1_2:} Measures the size of the government’s stake in the largest firm in key network sectors.
#'   \item \strong{oecd_pmr_2018_1_3:} Measures the existence of special voting rights by the government in privately owned firms and constraints on the sale of government stakes.
#'   \item \strong{oecd_pmr_2018_1_4:} Captures how policymakers interact with stakeholders when shaping business regulations. Considers forward planning, consultation, feedback, RIA, and transparency.
#'   \item \strong{oecd_pmr_2018_2_1:} Measures whether tariffs are regulated and whether laws limit competition. Higher values imply worse performance.
#'   \item \strong{oecd_pmr_2018_2_2:} Measures SOE autonomy in market decisions (e.g. operating hours, routes), and whether utilities disclose tariff and usage info. Higher values are worse.
#'   \item \strong{oecd_pmr_2018_3_3:} Simple average of (i) use of one-stop shops/silence-is-consent rule and (ii) government communication to reduce administrative burden.
#'   \item \strong{oecd_pmr_2018_6:} Simple average of (i) restrictiveness of FDI rules (equity limits, approvals, staffing, operations) and (ii) average applied tariffs.
#' }
#'
#' @source OECD Product Market Regulation (PMR) Indicators, 2018. \url{https://www.oecd.org/economy/reform/oecdproductmarketregulationindicators.htm}
#'
#' @usage data(pmr)
#' @keywords datasets
"pmr"



#' OECD Employment Protection Legislation (EPL) Indicators
#'
#' This dataset includes composite indicators developed by the OECD to quantify the strength of employment protection legislation (EPL) for regular and temporary contracts. The indicators reflect rules and practices regarding individual dismissals and are part of the OECD Employment Protection Database.
#'
#' @format A tibble with 287 rows and 4 variables:
#' \describe{
#'   \item{country_code}{Three-letter ISO country code (e.g., "AUS", "FRA").}
#'   \item{year}{Observation year (e.g., 2013).}
#'   \item{oecd_epl_regular}{Composite indicator of employment protection legislation governing regular contracts (individual dismissals).}
#'   \item{oecd_epl_temporary}{Composite indicator of employment protection legislation governing temporary contracts (individual dismissals).}
#' }
#'
#' @description
#' Measures the strictness of rules and enforcement practices surrounding hiring and firing of workers under different types of contracts. A higher score indicates more stringent regulation.
#'
#' @details
#' \itemize{
#'   \item \strong{oecd_epl_regular:} Composite indicator of employment protection legislation governing individual dismissals for regular (permanent) contracts. It captures aspects such as procedural inconveniences, notice periods, and severance pay.
#'   \item \strong{oecd_epl_temporary:} Composite indicator of employment protection legislation for temporary contracts. This includes aspects such as valid grounds for fixed-term contracts, maximum number of renewals, and duration limits.
#' }
#'
#' @source OECD Employment Protection Database. \url{https://www.oecd.org/employment/emp/oecdindicatorsofemploymentprotection.htm}
#'
#' @usage data(epl)
#' @keywords datasets
"epl"



#' World Bank EFI Data 360 Indicators
#'
#' This dataset contains a cleaned slice of the World Bank EFI (Data 360) database.
#'
#' @format A data frame with 8878 rows and 223 variables:
#' \describe{
#'   \item{country_code}{The World Bank ISO-3166 country code}
#'   \item{year}{Year}
#'   \item{idea_gsod_v_21_05}{Measures the extent to which citizens have a right to a fair trial in practice, are not subject to arbitrary arrest, the right to reocgnition as a person before the law, and other civil liberties.}
#'   \item{idea_gsod_v_22_08}{Captures the extent to which freedoms of speech and press are affected by government censorship, including ownership of media outlets}
#'   \item{idea_gsod_v_22_16}{Captures whether workers have freedom of association at their workplaces and the right to bargain collectively with their employers}
#'   \item{imf_fm_g_x_g01_gdp_pt}{Expenditure (Percent of GDP)}
#'   \item{imf_fm_g_xwdg_g01_gdp_pt}{Gross debt (Percent of GDP)}
#'   \item{imf_fm_ggcb_g01_pgdp_pt}{Cyclically adjusted  balance Percent of  GDP}
#'   \item{imf_fm_ggcbp_g01_pgdp_pt}{Cyclically adjusted primary balance Percent of potential GDP}
#'   \item{imf_fm_ggr_g01_gdp_pt}{Government revenue, percent of GDP}
#'   \item{imf_fm_ggxcnl_g01_gdp_pt}{Net lending/borrowing (also referred as overall balance  percent  of GDP}
#'   \item{imf_fm_ggxonlb_g01_gdp_pt}{Primary net lending/borrowing (also referred as primary balance) (Percent of GDP)}
#'   \item{imf_fm_ggxwdn_g01_gdp_pt}{Net debt (Percent of GDP)}
#'   \item{imf_gfscofog_geaf_g14_gdp_pt}{Expenditure on fuel & energy, Percent of GDP}
#'   \item{imf_gfscofog_ged_g14_gdp_pt}{Expenditure on defense, Percent of GDP}
#'   \item{imf_gfscofog_gedc_g14_gdp_pt}{Expenditure on civil defense, Percent of GDP}
#'   \item{imf_gfscofog_gedm_g14_gdp_pt}{Expenditure on military defense, Percent of GDP}
#'   \item{imf_gfscofog_gednec_g14_gdp_pt}{Expenditure on defense n.e.c., Percent of GDP}
#'   \item{imf_gfscofog_gedr_g14_gdp_pt}{Expenditure on defense R&D, Percent of GDP}
#'   \item{imf_gfscofog_gedto_g14_pt}{Expenditure on defense, Percent of total expenditure}
#'   \item{imf_gfscofog_gee_g14_gdp_pt}{Expenditure on education, Percent of GDP}
#'   \item{imf_gfscofog_geee_g14_gdp_pt}{Expenditure on subsidiary services to education, Percent of GDP}
#'   \item{imf_gfscofog_geel_g14_gdp_pt}{Expenditure on education not definable by level, Percent of GDP}
#'   \item{imf_gfscofog_geen_g14_gdp_pt}{Expenditure on post-secondary non-tertiary education, Percent of GDP}
#'   \item{imf_gfscofog_geeo_g14_gdp_pt}{Expenditure on education n.e.c., Percent of GDP}
#'   \item{imf_gfscofog_geep_g14_gdp_pt}{Expenditure on pre-primary & primary education, Percent of GDP}
#'   \item{imf_gfscofog_geer_g14_gdp_pt}{Expenditure on education R&D, Percent of GDP}
#'   \item{imf_gfscofog_gees_g14_gdp_pt}{Expenditure on secondary education, Percent of GDP}
#'   \item{imf_gfscofog_geet_g14_gdp_pt}{Expenditure on tertiary education, Percent of GDP}
#'   \item{imf_gfscofog_geeto_g14_pt}{Expenditure on education, Percent of total expenditure}
#'   \item{imf_gfscofog_gegpb_g14_gdp_pt}{Expenditure on basic research, Percent of GDP}
#'   \item{imf_gfscofog_gegpc_g14_gdp_pt}{Expenditure on exec/leg, fiscal, & external affairs, Percent of GDP}
#'   \item{imf_gfscofog_gegpt_g14_gdp_pt}{Transfers between different levels of govt, Percent of GDP}
#'   \item{imf_gfscofog_gehw_g14_gdp_pt}{Expenditure on water supply, Percent of GDP}
#'   \item{imf_gfscofog_gel_g14_gdp_pt}{Expenditure on health, Percent of GDP}
#'   \item{imf_gfscofog_gelh_g14_gdp_pt}{Expenditure on hospital services, Percent of GDP}
#'   \item{imf_gfscofog_gelm_g14_gdp_pt}{Expenditure on medical products, appliances, & equip, Percent of GDP}
#'   \item{imf_gfscofog_gelp_g14_gdp_pt}{Expenditure on public health services, Percent of GDP}
#'   \item{imf_gfscofog_gelr_g14_gdp_pt}{Expenditure on health R&D, Percent of GDP}
#'   \item{imf_gfscofog_gelto_g14_pt}{Expenditure on health, Percent of total expenditure}
#'   \item{imf_gfscofog_genb_g14_gdp_pt}{Expenditure on biodiversity & landscape protection, Percent of GDP}
#'   \item{imf_gfscofog_genm_g14_gdp_pt}{Expenditure on waste management, Percent of GDP}
#'   \item{imf_gfscofog_geno_g14_gdp_pt}{Expenditure on environmental protection n.e.c., Percent of GDP}
#'   \item{imf_gfscofog_genp_g14_gdp_pt}{Expenditure on pollution abatement, Percent of GDP}
#'   \item{imf_gfscofog_genr_g14_gdp_pt}{Expenditure on environmental protection R&D, Percent of GDP}
#'   \item{imf_gfscofog_gento_g14_pt}{Expenditure on environment protection, Percent of total expenditure}
#'   \item{imf_gfscofog_genw_g14_gdp_pt}{Expenditure on waste water management, Percent of GDP}
#'   \item{imf_gfscofog_gep_g14_gdp_pt}{Expenditure on public order & safety, Percent of GDP}
#'   \item{imf_gfscofog_gepf_g14_gdp_pt}{Expenditure on fire protection services, Percent of GDP}
#'   \item{imf_gfscofog_gepl_g14_gdp_pt}{Expenditure on law courts, Percent of GDP}
#'   \item{imf_gfscofog_gepo_g14_gdp_pt}{Expenditure on public order & safety n.e.c., Percent of GDP}
#'   \item{imf_gfscofog_gepp_g14_gdp_pt}{Expenditure on prisons, Percent of GDP}
#'   \item{imf_gfscofog_gepr_g14_gdp_pt}{Expenditure on public order & safety R&D, Percent of GDP}
#'   \item{imf_gfscofog_geps_g14_gdp_pt}{Expenditure on police services, Percent of GDP}
#'   \item{imf_gfscofog_gepto_g14_pt}{Expenditure on public order & safety, Percent of total expenditure}
#'   \item{imf_gfscofog_gesp_g14_gdp_pt}{Expenditure on social protection, Percent of GDP}
#'   \item{imf_gfscofog_gespp_g14_gdp_pt}{Expenditure on social protection n.e.c., Percent of GDP}
#'   \item{imf_gfscofog_gespr_g14_gdp_pt}{Expenditure on social protection R&D, Percent of GDP}
#'   \item{imf_gfscofog_gesps_g14_gdp_pt}{Expenditure on sickness  & disability, Percent of GDP}
#'   \item{imf_gfscofog_gespto_g14_pt}{Expenditure on social protection, Percent of total expenditure}
#'   \item{imf_gfscofog_gespu_g14_gdp_pt}{Expenditure on unemployment, Percent of GDP}
#'   \item{imf_gfscofog_geto_g14_gdp_pt}{Expenditure, Percent of GDP}
#'   \item{rwb_pfi_index}{Captures freedom of the press or “the ability of journalists as individuals and collectives to select, produce, and disseminate news in the public interest independent of political, economic, legal, and social interference and in the absence of threats to their physical and mental safety”}
#'   \item{wb_es_ic_frm_corr_corr11}{Measures the percentage of firms identifying corruption as a "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_corr_crime9}{Measures the percent of firms identifying the courts system as a major constraint}
#'   \item{wb_es_ic_frm_infra_in12}{Measures the percent of firms identifying labor regulations as a "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_obs_obst1}{Measures the percentage of firms identifying access/cost of finance as a "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_reg_bus5}{Measures the percentage of firm's identifying business licensing and permits as "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_reg_reg5}{Measures the percentage of firms identifying tax administration as a "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_trd_tr9}{Measures the percentage of firm's identifying customs and trade regulations as a "major" or "very severe" obstacle}
#'   \item{wb_es_ic_frm_wrkf_wk9}{Measures the percent of firms identifying labor regulations as a "major" or "very severe" obstacle}
#'   \item{wb_pefa_pi_2016_05}{PI-5. Measures the comprehensiveness of information provided in the annual budget documentation as measured against a specified list of basic and additional elements}
#'   \item{wb_pefa_pi_2016_07}{PI-7. Measures the transparency and timelines of transfers to subnational governments}
#'   \item{wb_pefa_pi_2016_08}{PI-8. Captures the service delivery performance information}
#'   \item{wb_pefa_pi_2016_10}{PI-10. Captures the extent to which fiscal risks to central government are reported}
#'   \item{wb_pefa_pi_2016_11}{PI-11. Measures the extent to which the government conducts economic appraisals, selects, projects the costs, and monitors the implementation of public investment projects}
#'   \item{wb_pefa_pi_2016_12}{PI-12. Measures the quality of public financial management based on financial asset monitoring, non-financial asset monitoring, and transparency of asset disposal.}
#'   \item{wb_pefa_pi_2016_13}{PI-13. Measures the quality of debt management based on the recording and reporting of debt and guarantees, Approval of debt and guarantees, and debt management strategy}
#'   \item{wb_pefa_pi_2016_14}{PI-14. Measures a country's the ability to develop robust macroeconomic and fiscal forecasts}
#'   \item{wb_pefa_pi_2016_15}{PI-15. Measures the quality of a country's fiscal strategy based on the fiscal impact of policy proposals, and the fiscal strategy adoption.}
#'   \item{wb_pefa_pi_2016_16}{PI-16. Measures the extent to which expenditure budgets are developed for the medium term within explicit medium-term budget expenditure ceilings}
#'   \item{wb_pefa_pi_2016_17}{PI-17. Measures the effectiveness of participation by relevant stakeholders in the budget preparation process, including political leadership, and whether that participation is orderly and timely.}
#'   \item{wb_pefa_pi_2016_18}{PI-18. Measures the nature and extent of legislative scrutiny of the annual budget}
#'   \item{wb_pefa_pi_2016_19}{PI-19. Measures the quality of revenue administration based on rights and obligations for revenue measures, revenue risk management, revenue audit and investigation, and revenue arrears monitoring.}
#'   \item{wb_pefa_pi_2016_20}{PI-20. Measures the quality of procedures for recording and reporting revenue collections, consolidating revenues collected, and reconciling tax revenue accounts}
#'   \item{wb_pefa_pi_2016_21}{PI-21. Meaures the extent to which the central ministry of finance is able to forecast cash commitments and requirements and to provide reliable information on the availability of funds to budgetary units for service delivery.}
#'   \item{wb_pefa_pi_2016_22}{PI-22. Measures extent to which there is a stock of arrears, and whether any systemic problem in this regard is being addressed and brought under control}
#'   \item{wb_pefa_pi_2016_23}{PI-23. Measures the quality of payroll management, how changes are handled, and how consistency with personnel records management is achieved}
#'   \item{wb_pefa_pi_2016_24}{PI-24. Measures the quality of procurement monitoring, procurement methods, public access to procurement information, and procurement complaints management.}
#'   \item{wb_pefa_pi_2016_25}{PI-25. Measures the effectiveness of general internal controls for nonsalary expenditures.}
#'   \item{wb_pefa_pi_2016_26}{PI-26. Measures the effectiveness of the standards and procedures applied in internal audit}
#'   \item{wb_pefa_pi_2016_27}{PI-27. Measures the extent to which treasury bank accounts, suspense accounts, and advance accounts are regularly reconciled and how the processes in place support the integrity of financial data.}
#'   \item{wb_pefa_pi_2016_28}{PI-28. Measures the extent to which treasury bank accounts, suspense accounts, and advance accounts are regularly reconciled and how the processes support the integrity of financial data}
#'   \item{wb_pefa_pi_2016_29}{PI-29. Measures the extent to which annual financial statements are complete, timely, and consistent with generally accepted accounting principles and standards}
#'   \item{wb_pefa_pi_2016_30}{PI-30. Measures the effectiveness of external audits}
#'   \item{wb_wdi_iq_sci_mthd}{Methodology assessment of statistical capacity (scale 0 - 100)}
#'   \item{wb_wdi_iq_sci_prdc}{Periodicity and timeliness assessment of statistical capacity (scale 0 - 100)}
#'   \item{wb_wdi_si_pov_mdim}{The percentage of people who are multidimensionally poor}
#'   \item{wb_wdi_si_pov_mdim_it}{Average share of deprivations experienced by the poor}
#'   \item{wb_wdi_si_pov_mdim_xq}{Multidimensional poverty index, children (population ages 0-17) (scale 0-1)}
#'   \item{wb_wwbi_bi_emp_frml_pb_ed_zs}{Public sector employment, as a share of formal employment, by industry: Education}
#'   \item{wb_wwbi_bi_emp_frml_pb_he_zs}{Public sector employment, as a share of formal employment, by industry: Health}
#'   \item{wb_wwbi_bi_emp_frml_pb_zs}{Measures the number of public sector paid employees}
#'   \item{wb_wwbi_bi_emp_pwrk_ed_pb_zs}{Education workers, as a share of public paid employees}
#'   \item{wb_wwbi_bi_emp_pwrk_he_pb_zs}{Health workers, as a share of public paid employees}
#'   \item{wb_wwbi_bi_emp_totl_no}{Number of employed individuals}
#'   \item{wb_wwbi_bi_emp_totl_no_ed}{Number of employed employees, by industry: Education}
#'   \item{wb_wwbi_bi_emp_totl_no_he}{Number of employed employees, by industry: Health}
#'   \item{wb_wwbi_bi_emp_totl_no_pa}{Number of employed employees, by industry: Public adminstration}
#'   \item{wb_wwbi_bi_emp_totl_pb_tt_zs}{Proportion of total employees with tertiary education working in public sector}
#'   \item{wb_wwbi_bi_pwk_prvs_tt_zs}{Individuals with tertiary education as a share of private paid employees}
#'   \item{wb_wwbi_bi_pwk_pubs_fe_zs}{Number of female public paid employees/Total number of public paid employees.}
#'   \item{wb_wwbi_bi_pwk_pubs_no}{Number of public paid employees}
#'   \item{wb_wwbi_bi_pwk_pubs_no_ed}{Number of public paid employees, by industry: Education}
#'   \item{wb_wwbi_bi_pwk_pubs_no_he}{Number of public paid employees, by industry: Health}
#'   \item{wb_wwbi_bi_pwk_pubs_no_pa}{Number of public paid employees, by industry: Public adminstration}
#'   \item{wb_wwbi_bi_pwk_pubs_sn_fe_zs}{Number of female public paid employees who work as senior official (managers) / Number of public paid employees work as senior official (managers).}
#'   \item{wb_wwbi_bi_pwk_pubs_tt_zs}{Measures the number of public paid employees with tertiary education as a share of total public employment}
#'   \item{wb_wwbi_bi_pwk_totl_no}{Number of paid employees}
#'   \item{wb_wwbi_bi_pwk_totl_no_ed}{Number of paid employees, by industry: Education}
#'   \item{wb_wwbi_bi_pwk_totl_no_he}{Number of paid employees, by industry: Health}
#'   \item{wb_wwbi_bi_pwk_totl_no_pa}{Number of paid employees, by industry: Public adminstration}
#'   \item{wb_wwbi_bi_wag_cprs_pb_zs}{Ratios of the 90th percentile of weekly wage for public paid employees/10th percentile of weekly wage for public paid employees.}
#'   \item{wb_wwbi_bi_wag_cprs_pv_zs}{Pay compression ratio in private sector (ratio of 90th/10th percentile earners)}
#'   \item{wb_wwbi_bi_wag_prem_ed_gp}{Public sector wage premium, by industry: Education (compared to all private employees)}
#'   \item{wb_wwbi_bi_wag_prem_he_gp}{Public sector wage premium, by industry: Health (compared to all private employees)}
#'   \item{wb_wwbi_bi_wag_prem_pb_gp}{Percentage differences in public sector wages compared to private sector wages (in local currency units) controlling for education, age, gender, and location.}
#'   \item{wb_wwbi_bi_wag_totl_gd_zs}{General government wave bill in proportion to country GDP (based on PPP; 2009 dollars). The wage bill is defined as the total compensation (in cash or in-kind) payable to a government employee in exchange for work. Wage bill includes wages and salaries, allowances, and social security contributions made on behalf of employees to social insurance schemes.}
#'   \item{wb_wwbi_bi_wag_totl_pb_zs}{Measures the total compensation (in cash or in-kind) payable to a government employee in exchange for work.}
#'   \item{wjp_rol_1}{Captures the extent to which the legislature, the judiciary, and non-governmental institutions limit government powers}
#'   \item{wjp_rol_2}{Captures the extent to which state officials in the executive branch, the judicial branch, the legislative branch, and the police/military use public office for private gain}
#'   \item{wjp_rol_6}{Captures whether government regulations are effectively enforced without improper influence and unreasonable delays}
#'   \item{wjp_rol_6_6}{Measures whether the government respects the property rights of people and corporations, refrains from the illegal seizure of private property, and provides adequate compensation when property is legally expropriated}
#'   \item{bs_sgi_195}{Measures the existence of the following supervisory bodies (a) audit office, (b) ombuds office and (3) data protection authority}
#'   \item{bs_sgi_196}{Measures whether there is an independent and effective audit office}
#'   \item{bs_bti_q1_2}{Measures whether all relevant groups in society agree about citizenship and accept the nation-state as legitimate}
#'   \item{bs_bti_q12_1}{Measures the extent to which environmental concerns effectively taken into account}
#'   \item{bs_bti_q12_2}{To what extent are there solid institutions for basic, secondary and tertiary education, as well as for research and development?}
#'   \item{bs_bti_q14}{Measures whether the government manages reforms effectively and can achieve its policy priorities.}
#'   \item{bs_bti_q14_1}{To what extent does the government set and maintain strategic priorities?}
#'   \item{bs_bti_q14_2}{How effective is the government in implementing its own policies?}
#'   \item{bs_bti_q14_3}{How innovative and flexible is the government?}
#'   \item{bs_bti_q15_1}{Measures the extent to which the government makes efficient use of available human, financial and organizational resources}
#'   \item{bs_bti_q15_2}{To what extent can the government coordinate conflicting objectives into a coherent policy?}
#'   \item{bs_bti_q2_1}{Captures the extent to which elections are free and fair, considering factors such as suffrage, the secret ballot, electoral management, voter registration, media access, etc. (1 to 10 scoring)}
#'   \item{bs_bti_q2_3}{Captures freedom of association or the extent to which individuals can freely form and join independent political or civic groups}
#'   \item{bs_bti_q3_1}{Captures the extent to which there is a working separation of powers (i.e. checks and balances)}
#'   \item{bs_bti_q3_2}{Measures the independence of the judiciary (i.e. the ability and autonomy to interpret and review existing law, pursue its own reasoning free from the influence of political decision-makers or powerful groups and individual, etc)}
#'   \item{bs_bti_q7_2}{Captures  if free and fair competition is guaranteed by an institutional framework that ensures unrestricted participation in the market and a level playing field for all market participants.}
#'   \item{bs_bti_q7_4}{To what extent have a solid banking system and a functioning capital market been established?}
#'   \item{bs_bti_q8_1}{Measures the extent to which the monetary authority pursues and communicates a consistent monetary stabilization policy}
#'   \item{bs_bti_q8_2}{Measures the extent t which the government’s budgetary policies support fiscal stability}
#'   \item{bs_bti_si}{Composed of five underlying criteria: stateness, political participation, rule of law, stability of democratic institutions, and political and social integration}
#'   \item{fh_fiw_cl_rating}{Captures whether the media is free/independent, there is freedom of religion, there is educational freedom, and there is freedom of expression (0 to 4 scoring)}
#'   \item{fh_fiw_pr_rating}{Captures whether election management bodies impelement electoral laws in an impartial manner as well as whether the current executive and national legislature were elected through free and fair elections (1 to 7 scoring)}
#'   \item{ibp_obs_obi}{Captures the extent to which the public has access to timely and comprehensive budget information}
#'   \item{imf_world_rg_rm_gdp}{Total Grants in Percent of GDP}
#'   \item{imf_world_rs_rm_gdp}{Social Contributions in Percent of GDP}
#'   \item{imf_world_rt_rm_gdp}{Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtgse_rm_gdp}{Excise Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtgsgv_rm_gdp}{VAT Revenue in Percent of GDP}
#'   \item{imf_world_rti_rm_gdp}{Income Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtic_rm_gdp}{Corporate Income Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtii_rm_gdp}{Individual Income Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtp_rm_gdp}{Property Tax Revenue in Percent of GDP}
#'   \item{imf_world_rtpay_rm_gdp}{Taxes on Payroll and Workforce Revenue in Percent of GDP}
#'   \item{imf_world_rtt_rm_gdp}{Tax revenue (Percent of GDP)}
#'   \item{wb_spi_census_and_survey_index}{Standards and Methods indicator}
#'   \item{wb_spi_std_and_methods}{Censuses and Surveys indicator (EGVPI processed)}
#'   \item{wb_girg_6}{Captures how policymakers interact with stakeholders when shaping regulations affecting business communities}
#'   \item{wb_gtmi_cgsi}{Captures the key aspects of a whole-of-government approach, including government cloud, interoperability framework and other platforms.}
#'   \item{wb_gtmi_dcei}{Measures aspects of public participation platforms, citizen feedback mechanisms, open data, and open government portals.}
#'   \item{wb_gtmi_gtei}{Measures the strategy, institutions, laws, and regulations to foster GovTech as well as digital skills and innovation policies}
#'   \item{wb_gtmi_i_12}{Captures whether there is an e-Procurement portal in place}
#'   \item{wb_gtmi_i_13}{Captures whether there a Debt Management System (DMS) in place}
#'   \item{wb_gtmi_i_14}{Captures whether there a Public Investment Management System (PIMS) in place}
#'   \item{wb_gtmi_i_5}{Captures whether there is an operational FMIS in place to support core PFM functions}
#'   \item{wb_gtmi_i_6}{Captures whether there is a TSA supported by FMIS to automate payments and bank reconciliation}
#'   \item{wb_gtmi_i_7}{Captures whether there a Tax Management Information System in place}
#'   \item{wb_gtmi_i_8}{Captures whether there is a Customs Management Information System is in place}
#'   \item{wb_gtmi_psdi}{Measures the maturity of online public service portals with a focus on citizen centric design and universal accessibility.}
#'   \item{wb_lpi_lp_lpi_cust_xq}{Measures the efficiency of customs clearance processes (i.e. speed, simplicity and predictability of formalities) by border control agencies}
#'   \item{wb_wbl_sg_law_indx}{Measures gender equality in the private sector workforce based on several indicators related to mobility, workplace dynamics, pay, marriage, parenthood, entrepreneurship, assets, and pensions}
#'   \item{wb_wdi_dt_dod_mwbg_cd}{IBRD loans and IDA credits (DOD, current US$)}
#'   \item{wb_wdi_dt_nfl_pcbo_cd}{Commercial banks and other lending (PPG + PNG) (NFL, current US$)}
#'   \item{wb_wdi_gc_rev_xgrt_gd_zs}{Measures cash receipts from taxes, social contributions, and other revenues such as fines, fees, rent, and income from property or sales}
#'   \item{wb_wdi_gc_tax_expt_zs}{Taxes on exports (Percent of tax revenue)}
#'   \item{wb_wdi_gc_tax_gsrv_rv_zs}{Taxes on goods and services (Percent value added of industry and services)}
#'   \item{wb_wdi_gc_tax_impt_zs}{Customs and other import duties (Percent of tax revenue)}
#'   \item{wb_wdi_gc_tax_intt_rv_zs}{Taxes on international trade (Percent of revenue)}
#'   \item{wb_wdi_gc_xpn_comp_zs}{Compensation of employees (Percent of expense)}
#'   \item{wb_wdi_gc_xpn_gsrv_zs}{Goods and services expense (Percent of expense)}
#'   \item{wb_wdi_gc_xpn_trft_zs}{Subsidies and other transfers (Percent of expense)}
#'   \item{wb_wdi_ic_bus_ndns_zs}{New business density (new registrations per 1,000 people ages 15-64)}
#'   \item{wb_wdi_ic_bus_nreg}{New businesses registered (number)}
#'   \item{wb_wdi_ie_ppi_watr_cd}{Investment in water and sanitation with private participation (current US$)}
#'   \item{wb_wdi_iq_spi_ovrl}{Statistical performance indicators (SPI): Overall score (scale 0-100)}
#'   \item{wb_wdi_iq_spi_pil1}{Statistical performance indicators (SPI): Pillar 1 data use score (scale 0-100)}
#'   \item{wb_wdi_iq_spi_pil2}{Statistical performance indicators (SPI): Pillar 2 data services score (scale 0-100)}
#'   \item{wb_wdi_iq_spi_pil3}{Statistical performance indicators (SPI): Pillar 3 data products score (scale 0-100)}
#'   \item{wb_wdi_iq_spi_pil4}{Statistical performance indicators (SPI): Pillar 4 data sources score (scale 0-100)}
#'   \item{wb_wdi_iq_spi_pil5}{Statistical performance indicators (SPI): Pillar 5 data infrastructure score (scale 0-100)}
#'   \item{wb_wdi_tm_val_fuel_zs_un}{Fuel imports (Percent of merchandise imports)}
#'   \item{wjp_rol_2_2}{Measures whether judicial officials refrain from soliciting and accepting bribes to perform duties and whether the judiciary is free of improper influence by the government, private interests, or criminal organizations.}
#'   \item{wjp_rol_3_1}{Measures whether basic laws and information on legal rights are publicly available, presented in plain language, and made accessible in all languages used in the country or jurisdiction}
#'   \item{wjp_rol_3_2}{Measures whether requests for information held by a government agency are granted within a reasonable time period and at a reasonable cost without paying a bribe}
#'   \item{wjp_rol_3_4}{Measures whether people are able to bring specific complaints to the government about the provision of public services or the performance of government officers in carrying out their legal duties in practice as well as whether government officials respond to such complaints}
#'   \item{wjp_rol_4_3}{Measures whether the basic rights of criminal suspects are respected, including the presumption of innocence and the freedom from arbitrary arrest and unreasonable pre-trial detention}
#'   \item{wjp_rol_4_4}{Measures whether an independent media, civil society organizations, political parties, and individuals are free to report and comment on government policies without fear of retaliation}
#'   \item{wjp_rol_4_5}{Measures whether members of religious minorities can worship and conduct religious practices freely and publicly}
#'   \item{wjp_rol_4_6}{Measures whether the police or other government officials conduct physical searches without warrants, or intercept electronic communications of private individuals without judicial authorization}
#'   \item{wjp_rol_4_7}{Measures whether people can freely attend community meetings, join political organizations, hold peaceful public demonstrations, sign petitions, and express opinions against government policies and actions without fear of retaliation}
#'   \item{wjp_rol_4_8}{Measures the effective enforcement of fundamental labor rights, including freedom of association and the right to collective bargaining, the absence of discrimination with respect to employment, and freedom from forced labor and child labor.}
#'   \item{wjp_rol_6_2}{Measures whether the enforcement of regulations is subject to bribery or improper influence by private interests and whether public service are provided without bribery or other inducements}
#'   \item{wjp_rol_7_1}{Captures whether people can access and afford civil justice as well as whether it is free of discrimination, improper government influence, and unreasonable delays}
#'   \item{wjp_rol_7_5}{Measures whether civil justice proceedings are conducted and judgments are produced in a timely manner without unreasonable delay}
#'   \item{wjp_rol_7_6}{Measures the effectiveness and timeliness of the enforcement of civil justice decisions and judgments in practice}
#'   \item{wjp_rol_7_7}{Captures the accessibility, impartiality, and effectiveness of alternative dispute resolution mechanisms}
#'   \item{wjp_rol_8_1}{Measures whether perpetrators of crimes are effectively apprehended and charged as well as whether police, investigators, and prosecutors have adequate resources}
#'   \item{wjp_rol_8_2}{Captures the effectiveness and timeliness of the criminal investigation system is effective}
#'   \item{wjp_rol_8_4}{Measures whether the police and criminal judges are impartial and whether they discriminate in practice based on socio-economic status, gender, ethnicity, religion, national origin, sexual orientation, or gender identity}
#'   \item{wb_gtmi_pfm_mis}{Measures whether there is an operational FMIS, a TSA, a Tax MIS, a Customs MIS, a DMS, a PIMS, and e-procurement in place}
#' }
#'
#' @details
#' Below are the longer descriptions for each variable (when provided):
#' \itemize{
#'   \item \strong{idea_gsod_v_21_05}: Definition: The indicator specifies the extent to which citizens have the right to a fair trial in practice: they are not subjected to arbitrary arrest, detention or exile; and they have the right to recognition as a person before the law; the right to be under the jurisdiction of and seek redress from competent, independent and impartial tribunals; and the right to be heard and to be tried without undue delay if arrested, detained or charged with a criminal offence. Indicator Scale: 1. Severely restricted: Fair trials are very unlikely. The courts are totally subordinated to the will of government or the justice system is profoundly undermined by arbitrary arrests, incompetence, corruption and intimidation. 2. Substantially restricted: Some elements of fair trials exist but the courts are not fully independent of the government and/or the justice system is characterized by widespread corruption, intimidation and inefficiency. 3. Moderately restricted: The courts are generally independent of the government, but the justice system is characterized by moderate degrees of corruption or inefficiency. 4. Unrestricted: All elements of fair trails are respected. No arbitrary arrests take place, the courts are competent, independent and impartial; and hearings and trials generally follow arrest and charge within a reasonable time. Scaled to range from 0 (lowest score) to 1 (highest score). Hosted by GSOD. Original source: The Civil Liberty Dataset (Skaaning, 2020).
#'   \item \strong{idea_gsod_v_22_08}: The extent to which freedoms of speech and press are affected by government censorship, including ownership of media outlets. Censorship is any form of restriction that is placed on freedom of the press, speech or expression. Expression may also be in the form of art or music. There are different degrees of censorship. Censorship denies citizens freedom of speech and limits or prevents the media (print, online, or broadcast) to express views challenging the policies of the existing government. In many instances, the government owns and operates all forms of press and media. Component Scale: (0) Complete: If the government, in practice, owns all of any one aspect of the media, such as all radio stations or all television stations. (1) Some: The government places some restrictions yet does allow limited rights to freedom of speech and the press. (2) None: “No” censorship means the freedom to speak freely and to print opposing opinions without the fear of prosecution. “None” in no way implies absolute freedom, as there exists in all countries some restrictions on information and/or communication. Even in democracies there are restrictions placed on freedoms of speech and the press if these rights infringe on the rights of others or in any way endangers the welfare of others. Housed by GSOD, from CIRI.
#'   \item \strong{idea_gsod_v_22_16}: Workers should have freedom of association at their workplaces and the right to bargain collectively with their employers. In addition, they should have other rights at work. The 1984 Generalized System of Preferences (GSP) agreement of the World Trade Organization requires reporting on worker rights in GSP beneficiary countries. It states that internationally recognized worker rights include: (A) the right of association; (B) the right to organize and bargain collectively; (C) a prohibition on the use of any form of forced or compulsory labor; (D) a minimum age for the employment of children; and (E) acceptable conditions of work with respect to minimum wages, hours of work, and occupational safety and health. Composite measure, adding the values of seven individual variables (union_p + barg_p + hour_p + force_p + child_p + wage_p + safe_p), each of which is scored according to the following ordinal scale: 0: Severely restricted: If the government systematically violates the right of association and/or the right to organize and bargain collectively. 1: Somewhat restricted: If the government generally protects the rights to association and collective bargaining, but there are occasional violations of these rights or there are other significant violations of worker rights. 2: Fully protected: If the government consistently protects the exercise of these rights AND there are no mentions of violations of other worker rights. Hosted by GSOD, original from CIRI.
#'   \item \strong{imf_fm_g_x_g01_gdp_pt}: Government expenditure, percent of GDP.General government final consumption expenditure (formerly general government consumption) includes all government current expenditures for purchases of goods and services (including compensation of employees). It also includes most expenditures on national defense and security, but excludes government military expenditures that are part of government capital formation.
#'   \item \strong{imf_fm_g_xwdg_g01_gdp_pt}: WEO: Gross debt consists of all liabilities that require payment or payments of interest and/or principal by the debtor to the creditor at a date or dates in the future. This includes debt liabilities in the form of SDRs, currency and deposits, debt securities, loans, insurance, pensions and standardized guarantee schemes, and other accounts payable. Thus, all liabilities in the GFSM 2001 system are debt, except for equity and investment fund shares and financial derivatives and employee stock options. Debt can be valued at current market, nominal, or face values
#'   \item \strong{imf_fm_ggcb_g01_pgdp_pt}: Cyclically adjusted  balance Percent of  GDP
#'   \item \strong{imf_fm_ggcbp_g01_pgdp_pt}: Cyclically adjusted balance excluding net interest payment (interest expenditure minus interest revenue).
#'   \item \strong{imf_fm_ggr_g01_gdp_pt}: Government revenue, percent of GDP.Tax revenue refers to compulsory transfers to the central government for public purposes. Certain compulsory transfers such as fines, penalties, and most social security contributions are excluded. Refunds and corrections of erroneously collected tax revenue are treated as negative revenue.
#'   \item \strong{imf_fm_ggxcnl_g01_gdp_pt}: Net lending/borrowing (also referred as overall balance  percent  of GDP
#'   \item \strong{imf_fm_ggxonlb_g01_gdp_pt}: Overall balance excluding net interest payment (interest expenditure minus interest revenue).
#'   \item \strong{imf_fm_ggxwdn_g01_gdp_pt}: Gross debt minus financial assets corresponding to debt instruments. These financial assets are: monetary gold and SDRs, currency and deposits, debt securities, loans, insurance, pension, and standardized guarantee schemes, and other accounts receivable. In some countries the reported net debt can deviate from this definition on the basis of available information and national fiscal accounting practices.
#'   \item \strong{imf_gfscofog_geaf_g14_gdp_pt}: Expenditure on fuel & energy, Percent of GDP
#'   \item \strong{imf_gfscofog_ged_g14_gdp_pt}: Military expenditure (Percent of GDP).Military expenditures data from SIPRI are derived from the NATO definition, which includes all current and capital expenditures on the armed forces, including peacekeeping forces; defense ministries and other government agencies engaged in defense projects; paramilitary forces, if these are judged to be trained and equipped for military operations; and military space activities. Such expenditures include military and civil personnel, including retirement pensions of military personnel and social services for personnel; operation and maintenance; procurement; military research and development; and military aid (in the military expenditures of the donor country). Excluded are civil defense and current expenditures for previous military activities, such as for veterans' benefits, demobilization, conversion, and destruction of weapons. This definition cannot be applied for all countries, however, since that would require much more detailed information than is available about what is included in military budgets and off-budget military expenditure items. (For example, military budgets might or might not cover civil defense, reserves and auxiliary forces, police and paramilitary forces, dual-purpose forces such as military and civilian police, military grants in kind, pensions for military personnel, and social security contributions paid by one part of government to another.)
#'   \item \strong{imf_gfscofog_gedc_g14_gdp_pt}: Expenditure on civil defense, Percent of GDP. Civil defense Expenditure are part of the Government expenditure, percent of GDP
#'   \item \strong{imf_gfscofog_gedm_g14_gdp_pt}: Military expenditure percent of GDP): Military expenditures data from SIPRI are derived from the NATO definition, which includes all current and capital expenditures on the armed forces, including peacekeeping forces; defense ministries and other government agencies engaged in defense projects; paramilitary forces, if these are judged to be trained and equipped for military operations; and military space activities. Such expenditures include military and civil personnel, including retirement pensions of military personnel and social services for personnel; operation and maintenance; procurement; military research and development; and military aid (in the military expenditures of the donor country). Excluded are civil defense and current expenditures for previous military activities, such as for veterans' benefits, demobilization, conversion, and destruction of weapons. This definition cannot be applied for all countries, however, since that would require much more detailed information than is available about what is included in military budgets and off-budget military expenditure items. (For example, military budgets might or might not cover civil defense, reserves and auxiliary forces, police and paramilitary forces, dual-purpose forces such as military and civilian police, military grants in kind, pensions for military personnel, and social security contributions paid by one part of government to another.)
#'   \item \strong{imf_gfscofog_gednec_g14_gdp_pt}: Expenditure on police services, Percent of GDP
#'   \item \strong{imf_gfscofog_gedr_g14_gdp_pt}: Government defense R&D funding as a share of GDP
#'   \item \strong{imf_gfscofog_gedto_g14_pt}: Military expenditure as a percentage of GDP is calculated as the unweighted country average within each country group.
#'   \item \strong{imf_gfscofog_gee_g14_gdp_pt}: Government expenditure on education, total (percent of GDP) . Expenditure on education are part of the Government expenditure, percent of GDP
#'   \item \strong{imf_gfscofog_geee_g14_gdp_pt}: Expenditure on subsidiary services to education, Percent of GDP
#'   \item \strong{imf_gfscofog_geel_g14_gdp_pt}: Expenditure on education not definable by level, Percent of GDP
#'   \item \strong{imf_gfscofog_geen_g14_gdp_pt}: Expenditure on secondary and primary education (Percent of government expenditure on education)
#'   \item \strong{imf_gfscofog_geeo_g14_gdp_pt}: Gross domestic expenditures on research and development (R&D), expressed as a percent of GDP. They include both capital and current expenditures in the four main sectors: Business enterprise, Government, Higher education and Private non-profit. R&D covers basic research, applied research, and experimental development.
#'   \item \strong{imf_gfscofog_geep_g14_gdp_pt}: Expenditure on pre-primary & primary education, Percent of GDP
#'   \item \strong{imf_gfscofog_geer_g14_gdp_pt}: Public Expenditure on education R&D, Percent of GDP.Gross domestic expenditures on research and development (R&D), expressed as a percent of GDP. They include both capital and current expenditures in the four main sectors: Business enterprise, Government, Higher education and Private non-profit. R&D covers basic research, applied research, and experimental development.
#'   \item \strong{imf_gfscofog_gees_g14_gdp_pt}: Government expenditure on education, total (Percent of GDP)
#'   \item \strong{imf_gfscofog_geet_g14_gdp_pt}: Expenditure on tertiary education (Percent of government expenditure on education)
#'   \item \strong{imf_gfscofog_geeto_g14_pt}: Current health expenditure (Percent of GDP). General government expenditure on education (current, capital, and transfers) is expressed as a percentage of GDP. It includes expenditure funded by transfers from international sources to government. General government usually refers to local, regional and central governments.
#'   \item \strong{imf_gfscofog_gegpb_g14_gdp_pt}: Expenditure on basic research, Percent of GDP
#'   \item \strong{imf_gfscofog_gegpc_g14_gdp_pt}: Expenditure on exec/leg, fiscal, & external affairs, Percent of GDP
#'   \item \strong{imf_gfscofog_gegpt_g14_gdp_pt}: Transfers between different levels of govt, Percent of GDP
#'   \item \strong{imf_gfscofog_gehw_g14_gdp_pt}: Expenditure on water supply, Percent of GDP
#'   \item \strong{imf_gfscofog_gel_g14_gdp_pt}: Expenditure on health, Percent of GDP. Level of current health expenditure expressed as a percentage of GDP.  Estimates of current health expenditures include healthcare goods and services consumed during each year. This indicator does not include capital health expenditures such as buildings, machinery, IT and stocks of vaccines for emergency or outbreaks.
#'   \item \strong{imf_gfscofog_gelh_g14_gdp_pt}: Gross domestic expenditures on research and development (R&D), expressed as a percent of GDP. They include both capital and current expenditures in the four main sectors: Business enterprise, Government, Higher education and Private non-profit. R&D covers basic research, applied research, and experimental development.
#'   \item \strong{imf_gfscofog_gelm_g14_gdp_pt}: Expenditure on medical products, appliances, & equip (Percent of government expenditure on education)
#'   \item \strong{imf_gfscofog_gelp_g14_gdp_pt}: Expenditure on public health services, Percent of GDP.Level of current health expenditure expressed as a percentage of GDP.  Estimates of current health expenditures include healthcare goods and services consumed during each year. This indicator does not include capital health expenditures such as buildings, machinery, IT and stocks of vaccines for emergency or outbreaks.
#'   \item \strong{imf_gfscofog_gelr_g14_gdp_pt}: Expenditure on health R&D, Percent of GDP
#'   \item \strong{imf_gfscofog_gelto_g14_pt}: Total expenditure on health as a percentage of gross domestic product
#'   \item \strong{imf_gfscofog_genb_g14_gdp_pt}: Gross domestic expenditures on research and development (R&D), expressed as a percent of GDP  on biodiversity & landscape protection
#'   \item \strong{imf_gfscofog_genm_g14_gdp_pt}: Expenditure on waste management, Percent of GDP
#'   \item \strong{imf_gfscofog_geno_g14_gdp_pt}: Expenditure on environmental protection n.e.c., Percent of GDP
#'   \item \strong{imf_gfscofog_genp_g14_gdp_pt}: Expenditure on pollution abatement , Percent of GDP . International Monetary Fund (IMF), Statistics Department. 2021. Government Finance Statistics (GFS) Database. https://data.imf.org/?sk=a0867067-d23c-4ebc-ad23-d3b015045405. Accessed on 2023-06-17; International Monetary Fund (IMF), Statistics Department (Government Finance Division) Questionnaire.
#'   \item \strong{imf_gfscofog_genr_g14_gdp_pt}: Expenditure on environmental protection R&D as percent of GDP
#'   \item \strong{imf_gfscofog_gento_g14_pt}: Government spends on environmental protection measures, as a percentage of the country’s GDP. These measures are part of a specified set of activities, as outlined by the framework of the Classification of Functions of Government (COFOG), and include pollution abatement, protection of biodiversity, waste management and more.
#'   \item \strong{imf_gfscofog_genw_g14_gdp_pt}: Expenditure on waste water management, Percent of GDP
#'   \item \strong{imf_gfscofog_gep_g14_gdp_pt}: Expenditure on public order & safety, Percent of GDP
#'   \item \strong{imf_gfscofog_gepf_g14_gdp_pt}: Expenditure on fire protection services (Percent of government expenditure on civil defense spending)
#'   \item \strong{imf_gfscofog_gepl_g14_gdp_pt}: Expenditure on law courts, Percent of GDP
#'   \item \strong{imf_gfscofog_gepo_g14_gdp_pt}: Expenditure on public order & safety n.e.c., Percent of GDP
#'   \item \strong{imf_gfscofog_gepp_g14_gdp_pt}: Expenditure on prisons, Percent of GDP
#'   \item \strong{imf_gfscofog_gepr_g14_gdp_pt}: Government current expenditures: Public order and safety  R&D, Percent of GDP
#'   \item \strong{imf_gfscofog_geps_g14_gdp_pt}: Expenditure on police services, Percent of GDP
#'   \item \strong{imf_gfscofog_gepto_g14_pt}: Government expenditure on public order and safety, percent of total expenditure
#'   \item \strong{imf_gfscofog_gesp_g14_gdp_pt}: Expenditure on social protection, Percent of GDP.  Social spending is measured on the basis of annual data on government spending on health and education using a database created by the Fiscal Affairs Department (FAD), and checked for accuracy by IMF staff from each country desk.  Source: Social Spending and Social Protection in IMF-Supported Programs
#'   \item \strong{imf_gfscofog_gespp_g14_gdp_pt}: Government expenditures by function of social protection as percentage of GDP
#'   \item \strong{imf_gfscofog_gespr_g14_gdp_pt}: Public Expenditure social_x000D_  protection as_x000D_  Percent of GDP
#'   \item \strong{imf_gfscofog_gesps_g14_gdp_pt}: Expenditure on sickness  & disability (Percent of government expenditure on social spending)
#'   \item \strong{imf_gfscofog_gespto_g14_pt}: Social expenditure comprises cash benefits, direct in-kind provision of goods and services, and tax breaks with social purposes. Benefits may be targeted at low-income households, the elderly, disabled, sick, unemployed, or young persons. To be considered "social", programmes have to involve either redistribution of resources across households or compulsory participation. Social benefits are classified as public when general government (that is central, state, and local governments, including social security funds) controls the relevant financial flows. All social benefits not provided by general government are considered private. Private transfers between households are not considered as "social" and not included here. Net total social expenditure includes both public and private expenditure. It also accounts for the effect of the tax system by direct and indirect taxation and by tax breaks for social purposes. This indicator is measured as a percentage of GDP or USD per capita.
#'   \item \strong{imf_gfscofog_gespu_g14_gdp_pt}: Public unemployment spending total, percent of GDP. Unemployment spending  are sub-part of the Government expenditure, percent of GDP
#'   \item \strong{imf_gfscofog_geto_g14_gdp_pt}: Government expenditure, percent of GDP Percent of GDP. Source. https://www.imf.org/external/datamapper/exp@FPP/USA/FRA/JPN/GBR/SWE/ESP/ITA/ZAF/IND
#'   \item \strong{rwb_pfi_index}: The methodology is based on a definition of press freedom as “the ability of journalists as individuals and collectives to select, produce, and disseminate news in the public interest independent of political, economic, legal, and social interference and in the absence of threats to their physical and mental safety”. It uses five new indicators that shape the Index and provide a vision of press freedom in all its complexity: political context, legal framework, economic context, sociocultural context and safety. In the 180 countries and territories ranked by RSF, these indicators are evaluated on the basis of a quantitative tally of abuses against journalists and  media outlets, and a qualitative analysis based on the responses of hundreds of press freedom experts selected by RSF (including journalists, academics and human rights defenders) to more than 100 questions. Because of the change in methodology, care should be taken when comparing pre- and post-2021 rankings and scores.
#'   \item \strong{wb_es_ic_frm_corr_corr11}: Percentage of firms identifying corruption as a "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_corr_crime9}: Percent of firms identifying the courts system as a major constraint
#'   \item \strong{wb_es_ic_frm_infra_in12}: Percentage of firms identifying electricity as a "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_obs_obst1}: Percentage of firms identifying access/cost of finance as a "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_reg_bus5}: Percentage of firms identifying business licensing and permits as "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_reg_reg5}: Percentage of firms identifying tax administration as a "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_trd_tr9}: Percentage of firms identifying customs and trade regulations as a "major" or "very severe" obstacle.
#'   \item \strong{wb_es_ic_frm_wrkf_wk9}: Percentage of firms identifying labor regulations as a "major" or "very severe" obstacle.
#'   \item \strong{wb_pefa_pi_2016_05}: PI-5. The comprehensiveness of information provided in the annual budget documentation, as measured against a specified list of basic and additional elements
#'   \item \strong{wb_pefa_pi_2016_07}: PI-7. Measures the transparency and timeliness of transfers from central government to subnational governments with direct financial relationships to it.
#'   \item \strong{wb_pefa_pi_2016_08}: PI-8. Captures the service delivery performance information in the executive’s budget proposal or its supporting documentation in year-end reports. It determines whether performance audits or evaluations are carried out and if information is collected and reported on resources received by service delivery units.
#'   \item \strong{wb_pefa_pi_2016_10}: PI-10. The extent to which fiscal risks to central government are reported.
#'   \item \strong{wb_pefa_pi_2016_11}: PI-11.The extent to which the government conducts economic appraisals, selects, projects the costs, and monitors the implementation of public investment projects, with emphasis on the largest and most significant projects.
#'   \item \strong{wb_pefa_pi_2016_12}: PI-12. Public asset management. Based on Financial asset monitoring, Nonfinancial asset monitoring, and Transparency of asset disposal.
#'   \item \strong{wb_pefa_pi_2016_13}: PI-13 Debt management. Based on Recording and reporting of debt and guarantees, Approval of debt and guarantees, and Debt management strategy
#'   \item \strong{wb_pefa_pi_2016_14}: PI-14.The ability of a country to develop robust macroeconomic and fiscal forecasts, which are crucial to developing a sustainable fiscal strategy and ensuring greater predictability of budget allocations.
#'   \item \strong{wb_pefa_pi_2016_15}: PI-15 Fiscal strategy. Based on the Fiscal impact of policy proposals, and the Fiscal strategy adoption.
#'   \item \strong{wb_pefa_pi_2016_16}: PI-16. The extent to which expenditure budgets are developed for the medium term within explicit medium-term budget expenditure ceilings. It also examines the extent to which annual budgets are derived from medium-term estimates and the degree of alignment between medium-term budget estimates and strategic plans.
#'   \item \strong{wb_pefa_pi_2016_17}: PI-17. The effectiveness of participation by relevant stakeholders in the budget preparation process, including political leadership, and whether that participation is orderly and timely.
#'   \item \strong{wb_pefa_pi_2016_18}: PI-18. This indicator assesses the nature and extent of legislative scrutiny of the annual budget. It considers the extent to which the legislature scrutinizes, debates, and approves the annual budget, including the extent to which the legislature’s procedures for scrutiny are well established and adhered to. The indicator also assesses the existence of rules for in-year amendments to the budget without ex-ante approval by the legislature.
#'   \item \strong{wb_pefa_pi_2016_19}: PI-19 Revenue administration. Based on Rights and obligations for revenue measures, Revenue risk management, Revenue audit and investigation, Revenue arrears monitoring.
#'   \item \strong{wb_pefa_pi_2016_20}: PI-20. The procedures for recording and reporting revenue collections, consolidating revenues collected, and reconciling tax revenue accounts. It covers both tax and nontax revenues collected by the central government.
#'   \item \strong{wb_pefa_pi_2016_21}: PI-21. The extent to which the central ministry of finance is able to forecast cash commitments and requirements and to provide reliable information on the availability of funds to budgetary units for service delivery.
#'   \item \strong{wb_pefa_pi_2016_22}: PI-22. The extent to which there is a stock of arrears, and whether any systemic problem in this regard is being addressed and brought under control.
#'   \item \strong{wb_pefa_pi_2016_23}: PI-23. How the payroll for public servants is managed, how changes are handled, and how consistency with personnel records management is achieved.
#'   \item \strong{wb_pefa_pi_2016_24}: PI-24. Based on Procurement monitoring, Procurement methods, Public access to procurement information, and Procurement complaints management.
#'   \item \strong{wb_pefa_pi_2016_25}: PI-25. The effectiveness of general internal controls for nonsalary expenditures.
#'   \item \strong{wb_pefa_pi_2016_26}: PI-26. Measures the effectiveness of the standards and procedures applied in internal audit
#'   \item \strong{wb_pefa_pi_2016_27}: PI-27.Measures the extent to which treasury bank accounts, suspense accounts, and advance accounts are regularly reconciled and how the processes in place support the integrity of financial data.
#'   \item \strong{wb_pefa_pi_2016_28}: PI-28. The extent to which treasury bank accounts, suspense accounts, and advance accounts are regularly reconciled and how the processes support the integrity of financial data.
#'   \item \strong{wb_pefa_pi_2016_29}: PI-29. The extent to which annual financial statements are complete, timely, and consistent with generally accepted accounting principles and standards.
#'   \item \strong{wb_pefa_pi_2016_30}: PI-30. This indicator examines the characteristics of external audit. It considers the following four dimensions: audit coverage and standards, submission of audit reports to the legislature, external audit follow-up, and Supreme Audit Institution (SAI) independence.
#'   \item \strong{wb_wdi_iq_sci_mthd}: The methodology indicator measures a country’s ability to adhere to internationally recommended standards and methods. The methodology score is calculated as the weighted average of 10 underlying indicator scores. The final methodology score contributes 1/3 of the overall Statistical Capacity Indicator score
#'   \item \strong{wb_wdi_iq_sci_prdc}: The periodicity and timeliness indicator assesses the availability and periodicity of key socioeconomic indicators. It measures the extent to which data are made accessible to users through transformation of source data into timely statistical outputs. The periodicity score is calculated as the weighted average of 10 underlying indicator scores. The final periodicity score contributes 1/3 of the overall Statistical Capacity Indicator score.
#'   \item \strong{wb_wdi_si_pov_mdim}: The percentage of people who are multidimensionally poor
#'   \item \strong{wb_wdi_si_pov_mdim_it}: The average percentage of dimensions in which poor people are deprived
#'   \item \strong{wb_wdi_si_pov_mdim_xq}: Proportion of the child population that is multidimensionally poor adjusted by the intensity of the deprivations
#'   \item \strong{wb_wwbi_bi_emp_frml_pb_ed_zs}: Public sector employment, as a share of formal employment, by industry: Education
#'   \item \strong{wb_wwbi_bi_emp_frml_pb_he_zs}: Public sector employment, as a share of formal employment, by industry: Health
#'   \item \strong{wb_wwbi_bi_emp_frml_pb_zs}: Number of public sector paid employees/ Number of formal employees. Formal employment is defined by having access to at least one of following benefits (contract, health insurance, union membership, or social security)
#'   \item \strong{wb_wwbi_bi_emp_pwrk_ed_pb_zs}: Education workers, as a share of public paid employees
#'   \item \strong{wb_wwbi_bi_emp_pwrk_he_pb_zs}: Health workers, as a share of public paid employees
#'   \item \strong{wb_wwbi_bi_emp_totl_no}: Number of employed individuals
#'   \item \strong{wb_wwbi_bi_emp_totl_no_ed}: Number of employed employees, by industry: Education
#'   \item \strong{wb_wwbi_bi_emp_totl_no_he}: Number of employed employees, by industry: Health
#'   \item \strong{wb_wwbi_bi_emp_totl_no_pa}: Number of employed employees, by industry: Public adminstration
#'   \item \strong{wb_wwbi_bi_emp_totl_pb_tt_zs}: Proportion of total employees with tertiary education working in public sector
#'   \item \strong{wb_wwbi_bi_pwk_prvs_tt_zs}: Individuals with tertiary education as a share of private paid employees
#'   \item \strong{wb_wwbi_bi_pwk_pubs_fe_zs}: Number of female public paid employees/Total number of public paid employees. The indicator here is based on paid employee only. Thus, we exclude working individual with other employment type (selfemployed, non-paid employee, employer, etc.) when calculating this indicator. It should not be viewed as the share of female in labor force.
#'   \item \strong{wb_wwbi_bi_pwk_pubs_no}: Number of public paid employees
#'   \item \strong{wb_wwbi_bi_pwk_pubs_no_ed}: Number of public paid employees, by industry: Education
#'   \item \strong{wb_wwbi_bi_pwk_pubs_no_he}: Number of public paid employees, by industry: Health
#'   \item \strong{wb_wwbi_bi_pwk_pubs_no_pa}: Number of public paid employees, by industry: Public adminstration
#'   \item \strong{wb_wwbi_bi_pwk_pubs_sn_fe_zs}: Number of female public paid employees who work as senior official (managers) / Number of public paid employees work as senior official (managers). Managers plan, direct, coordinate and evaluate the overall activities of enterprises, governments, and other organizations. This classification includes chief executives, senior officials, legislators,_x000D_ and managers of any kind.
#'   \item \strong{wb_wwbi_bi_pwk_pubs_tt_zs}: Number of public (private) paid employees with tertiary education (no education, primary education, secondary education / Total number of public (private) paid employees
#'   \item \strong{wb_wwbi_bi_pwk_totl_no}: Number of paid employees
#'   \item \strong{wb_wwbi_bi_pwk_totl_no_ed}: Number of paid employees, by industry: Education
#'   \item \strong{wb_wwbi_bi_pwk_totl_no_he}: Number of paid employees, by industry: Health
#'   \item \strong{wb_wwbi_bi_pwk_totl_no_pa}: Number of paid employees, by industry: Public adminstration
#'   \item \strong{wb_wwbi_bi_wag_cprs_pb_zs}: Ratios of the 90th percentile of weekly wage for public paid employees/10th percentile of weekly wage for public paid employees.
#'   \item \strong{wb_wwbi_bi_wag_cprs_pv_zs}: Pay compression ratio in private sector (ratio of 90th/10th percentile earners)
#'   \item \strong{wb_wwbi_bi_wag_prem_ed_gp}: Public sector wage premium, by industry: Education (compared to all private employees)
#'   \item \strong{wb_wwbi_bi_wag_prem_he_gp}: Public sector wage premium, by industry: Health (compared to all private employees)
#'   \item \strong{wb_wwbi_bi_wag_prem_pb_gp}: Percentage differences in public sector wages compared to private sector wages (in local currency units) controlling for education, age, gender, and location.
#'   \item \strong{wb_wwbi_bi_wag_totl_gd_zs}: General government wave bill in proportion to country GDP (based on PPP; 2009 dollars). The wage bill is defined as the total compensation (in cash or in-kind) payable to a government employee in exchange for work. Wage bill includes wages and salaries, allowances, and social security contributions made on behalf of employees to social insurance schemes.
#'   \item \strong{wb_wwbi_bi_wag_totl_pb_zs}: The wage bill is defined as the total compensation (in cash or in-kind) payable to a government employee in exchange for work. Wage bill includes wages and salaries, allowances, and social security contributions made on behalf of employees to social insurance schemes.
#'   \item \strong{wjp_rol_1}: Government powers are effectively limited by the legislature; Government powers are effectively limited by the judiciary; Government powers are effectively limited by independent auditing and review; Government officials are sanctioned for misconduct; Government powers are subject to non-governmental checks; Transition of power is subject to the law.
#'   \item \strong{wjp_rol_2}: It is an index of 4 items: Government officials in the executive branch do not use public office for private gain; Government officials in the judicial branch do not use public office for private gain; Government officials in the police & the military do not use public office for private gain; Government officials in the legislative branch do not use public office for private gain.
#'   \item \strong{wjp_rol_6}: Government regulations are effectively enforced; Government regulations are applied & enforced without improper influence; Administrative proceedings are conducted without unreasonable delay; Due process is respected in administrative proceedings; The government does not expropriate without lawful process & adequate compensation.
#'   \item \strong{wjp_rol_6_6}: Measures whether the government respects the property rights of people and corporations, refrains from the illegal seizure of private property, and provides adequate compensation when property is legally expropriated.
#'   \item \strong{bs_sgi_195}: Measures the existence of the following supervisory bodies: (a) audit office, (b) ombuds office and (3) data protection authority.
#'   \item \strong{bs_sgi_196}: Does there exist an independent and effective audit office?
#'   \item \strong{bs_bti_q1_2}: To what extent do all relevant groups in society agree about citizenship and accept the nation-state as legitimate?
#'   \item \strong{bs_bti_q12_1}: To what extent are environmental concerns effectively taken into account?
#'   \item \strong{bs_bti_q12_2}: This question seeks to assess:_x000D_ · whether education policy is successful in delivering high-quality education and training_x000D_ · whether research and development receive effective support from the government_x000D_ When answering this question, your focus should not be on expenditures alone, but also on the quality and competitiveness_x000D_ of the education system and the research sector. Please also consider:_x000D_ · the structure of funding and knowledge providers (public, private, international cooperation)_x000D_ · the output of the educational and developmental efforts: enrollment rates, literacy rates, percentage of people_x000D_ with higher education, number of patent applications etc._x000D_ Please note that unequal access to education should be primarily discussed in indicator 10.2 (Equal Opportunity)._x000D_ Quantitative Reference Indicators: UN Education Index · Public expenditure on education · R&D expenditure
#'   \item \strong{bs_bti_q14}: Measures whether the government manages reforms effectively and can achieve its policy priorities. Index based on Prioritization (To what extent does the government set and maintain strategic priorities?), Implementation (How effective is the government in implementing its own policies?) and Policy Learning (How innovative and flexible is the government?).
#'   \item \strong{bs_bti_q14_1}: This question seeks to assess:_x000D_ · the political capability to take on a longer-term perspective going beyond immediate concerns of electoral_x000D_ competition and to maintain strategic priorities over periods of crisis and stalemate_x000D_ · the strategic capacity of the government to prioritize and organize its policy measures (gaining and organizing_x000D_ expertise, evidence-based policymaking, regulatory impact assessments, strategic planning units)_x000D_ The focus should be on the executive, including the administration and the cabinet. Make sure to identify reform_x000D_ drivers and defenders of the status quo, as political determination and institutional capacity may vary among different_x000D_ departments and ministries. Please also comment on how setting and maintaining strategic priorities might be_x000D_ constrained by government composition and by actors outside the government (e.g. powerful economic interests,_x000D_ lobbies, foreign governments, foreign donors)._x000D_ Please consider if the strategic priorities correspond with the normative framework of the BTI in terms of striving for_x000D_ democracy and a market economy. The maximum score for autocracies is 5 points.
#'   \item \strong{bs_bti_q14_2}: This question asks whether the political leadership involves civil society actors in:_x000D_ · agenda setting_x000D_ · policy formulation_x000D_ · deliberation and decision-making_x000D_ · policy implementation_x000D_ · performance monitoring_x000D_ Civil society actors include civic, economic and professional interest associations, religious, charity and communitybased_x000D_ organizations, intellectuals, scientists and journalists.
#'   \item \strong{bs_bti_q14_3}: Innovation in policymaking often comes from learning. This learning extends beyond changes in policy outputs to include_x000D_ changes in the basic beliefs guiding policy formulation. Learning opportunities are provided by:_x000D_ · learning from past experiences (effective monitoring and evaluation)_x000D_ · observation and knowledge exchange (good practices, international cooperation)_x000D_ · consultancy (academic experts and practitioners)_x000D_ Flexibility refers to a government’s ability to adapt to and take advantage of developmental opportunities inherent to_x000D_ a given political situation. Flexibility and learning allow governments to replace failed policies with innovative ones._x000D_ If possible, provide empirical evidence on whether policy learning happens coincidentally or if there are institutionalized_x000D_ mechanisms that facilitate innovation and flexibility in policymaking._x000D_ Please consider if innovation and flexibility correspond with the normative framework of the BTI in terms of striving_x000D_ for democracy and a market economy. The maximum score for autocracies is 5 points.
#'   \item \strong{bs_bti_q15_1}: To what extent does the government make efficient use of available human, financial and organizational resources?
#'   \item \strong{bs_bti_q15_2}: As many policies have conflicting objectives, reflect competing political interests and affect other policies, the government_x000D_ has to ensure that its overall policy is coherent._x000D_ Successful coordination should:_x000D_ · assure that trade-offs between policy goals are well balanced_x000D_ · introduce horizontal forms of coordination to mediate between different departments of the state administration_x000D_ · ascribe responsibilities in a transparent manner to avoid the negligence of tasks, redundancies or friction between_x000D_ different government branches._x000D_ Various coordination styles— hierarchic-bureaucratic, informal-network, personalist, centralized, decentralized_x000D_ etc. — are possible and may be functionally equivalent. What matters is their impact on policy coherence
#'   \item \strong{bs_bti_q2_1}: This indicator assesses if: general elections are regularly conducted on the national level; universal suffrage with secret ballot is ensured; several parties with different platforms are able to run; and if political posts are filled according to election outcome. For this indicator evaluated the quality of elections considering if; the electoral management body is impartial and effective; registration procedures for voters, candidates and parties are transparent and fair; the polling procedures, including vote count, results verification and complaint resolution, are conducted in a transparent, impartial and correct manner; fair and equal media access is ensured for all candidates and parties; polling is accessible, secure and secret to ensure effective participation. This indicator is graded on a 1 to 10 scale, and a score over 6 is considered free and fair elections
#'   \item \strong{bs_bti_q2_3}: This indicator assesses to what extent can individuals form and join independent political or civic groups? To what extent can these groups operate and assemble freely? This considers: if the constitution guarantees freedom of association and assembly, and if these laws are enforced; if there are severe restrictions on assembly and association for all citizens or for particular groups; if the government uses intimidation, harassment or threats of retaliation to prevent citizens from exercising the rights to association and assembly (e.g. by arbitrarily arresting, detaining and imprisoning peaceful demonstrators or using excessive force); if the government uses transparent and non-discriminatory criteria in evaluating requests for permits to associate and/or assemble; if groups are able to operate free from unwarranted state intrusion or interference in their affairs
#'   \item \strong{bs_bti_q3_1}: To what extent is there a working separation of powers (checks and balances)?
#'   \item \strong{bs_bti_q3_2}: An independent judiciary has the ability and autonomy to: interpret and review existing laws, legislation and policies, both public and civil, pursue its own reasoning, free from the influence of political decision-makers or powerful groups and individuals and from corruption, develop a differentiated organization, including legal education, jurisprudence, regulated appointment of the judiciary, rational proceedings, professionalism, channels of appeal and court administration
#'   \item \strong{bs_bti_q7_2}: To what level have the fundamentals of market-based competition developed? The main focus of this question is to assess if free and fair competition is guaranteed by an institutional framework that ensures unrestricted participation in the market and a level playing field for all market participants. From "Market competition is present only in small segments of the economy and its institutional framework is rudimentary. Rules for market participants are unreliable and frequently set arbitrarily. The informal sector is large." to "Market competition is consistently defined and implemented both macroeconomically and microeconomically. There are state-guaranteed rules for market competition with equal opportunities for all market participants. The informal sector is very small."
#'   \item \strong{bs_bti_q7_4}: International standards of banking systems are defined by the Basel Accords (www.bis.org). These standards require_x000D_ banks to hold a minimum share of capital equity in relation to their assets and to the risk the bank exposes itself to_x000D_ through its lending and investment practices. They also demand that banks undergo a supervisory review process,_x000D_ and that they disclose information about their economic activities._x000D_ A solid capital market is characterized by a past record of low shares of nonperforming loans, prudential requirements_x000D_ for bank transactions in foreign currency, enforcement of rules on disclosure, independence of financial regulators_x000D_ and hard budget constraints between companies, banks and the public sector._x000D_ Note: Please make sure you provide information on capital-adequacy ratios, disclosure rules, supervision, share of_x000D_ non-performing loans and hard budget constraints. You should also elaborate on reforms in the financial sector._x000D_ Quantitative Reference Indicators: Bank capital to assets ratio · Bank nonperforming loans
#'   \item \strong{bs_bti_q8_1}: To what extent does the monetary authority pursue and communicate a consistent monetary stabilization policy?
#'   \item \strong{bs_bti_q8_2}: To what extent do the government’s budgetary policies support fiscal stability?
#'   \item \strong{bs_bti_si}: The democracy status is made up of five criterion: Stateness, measured by the normative statement "There is clarity about the nation's existence as a state with adequately established and differentiated power structures"; Political Participation, measured by the normative statement "The populace decides who rules and it has other political freedoms"; Rule of Law measured by the normative statement "State powers check and balance one another and ensure civil rights"; Stability of Democratic Institutions, measured by the normative statement "Democratic Institutions are capable of performing, and they are adequately accepted"; and Political and Social Integration, measured by the normative statement "Stable patterns of representation exist for mediating between society and the state; there is also a consolidated civic culture"
#'   \item \strong{fh_fiw_cl_rating}: Civil Liberties is measured on a one-to-seven scale, with one representing the highest degree of Freedom and seven the lowest
#'   \item \strong{fh_fiw_pr_rating}: Political Rights is measured on a one-to-seven scale, with one representing the highest degree of Freedom and seven the lowest.
#'   \item \strong{ibp_obs_obi}: A country's budget transparency score, reflected on the Open Budget Index, assesses the public's access to timely and comprehensive budget information. A transparency score of 61 (out of 100) or higher indicates a country is publishing sufficient information to support informed public debate.
#'   \item \strong{imf_world_rg_rm_gdp}: Total Grants in Percent of GDP
#'   \item \strong{imf_world_rs_rm_gdp}: Social Contributions in Percent of GDP
#'   \item \strong{imf_world_rt_rm_gdp}: Captures compulsory transfers to the central government for public purposes. Certain compulsory transfers such as fines, penalties, and most social security contributions are excluded. Refunds and corrections of erroneously collected tax revenue are treated as negative revenue.
#'   \item \strong{imf_world_rtgse_rm_gdp}: Excise Tax Revenue in Percent of GDP
#'   \item \strong{imf_world_rtgsgv_rm_gdp}: VAT Revenue in Percent of GDP :Some countries refer to VAT as the tax as General Sales Tax (GST) or Goods and Services Tax (GST)
#'   \item \strong{imf_world_rti_rm_gdp}: Income Tax Revenue in Percent of GDP
#'   \item \strong{imf_world_rtic_rm_gdp}: Corporate Income Tax Revenue in Percent of GDP
#'   \item \strong{imf_world_rtii_rm_gdp}: Individual Income Tax Revenue in Percent of GDP
#'   \item \strong{imf_world_rtp_rm_gdp}: Property Tax Revenue in Percent of GDP
#'   \item \strong{imf_world_rtpay_rm_gdp}: Taxes on Payroll and Workforce Revenue in Percent of GDP
#'   \item \strong{imf_world_rtt_rm_gdp}: Trade Tax Revenue in Percent of GDP.Gross domestic expenditures on research and development (R&D), expressed as a percent of GDP. They include both capital and current expenditures in the four main sectors: Business enterprise (tade), Government, Higher education and Private non-profit. R&D covers basic research, applied research, and experimental development.
#'   \item \strong{wb_girg_6}: It captures how policymakers interact with stakeholders when shaping regulations affecting business communities. It considers: publication of forward regulatory plans; consultation on proposed regulations; report back on the results of that consultation process; conduct regulatory impact assessment; laws are made publicly accessible.
#'   \item \strong{wb_gtmi_cgsi}: The Core Government Systems Index (17 indicators) captures the key aspects of a whole-of-government approach, including government cloud, interoperability framework and other platforms.
#'   \item \strong{wb_gtmi_dcei}: The Digital Citizen Engagement Index (6 indicators) measures aspects of public participation platforms, citizen feedback mechanisms, open data, and open government portals.
#'   \item \strong{wb_gtmi_gtei}: The GovTech Enablers Index (16 indicators) captures strategy, Institutions, laws, and regulations, as well as digital skills, and innovation policies and programs, to foster GovTech.
#'   \item \strong{wb_gtmi_i_12}: Is there an e-Procurement portal? Measured by 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_13}: Is there a Debt Management System (DMS) in place? (foreign and domestic debt). This indicator is measured with the scale 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_14}: Is there a Public Investment Management System (PIMS) in place? Measured by 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_5}: Is there an operational FMIS in place to support core PFM functions? This is measured on the scale 0= No/Unknown, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_6}: Is there a TSA supported by FMIS to automate payments and bank reconciliation? Measured with the scale 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_7}: Is there a Tax Management Information System in place? Measured with scale 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_i_8}: Is there a Customs Management Information System in place? Measured by 0= No, 1= Implementation in progress, 2= Yes (in use)
#'   \item \strong{wb_gtmi_psdi}: The Public Service Delivery Index (9 indicators) measures the maturity of online public service portals, with a focus on citizen centric design and universal accessibility.
#'   \item \strong{wb_lpi_lp_lpi_cust_xq}: Efficiency of customs clearance processes (i.e. speed, simplicity and predictability of formalities) by border control agencies, including customs
#'   \item \strong{wb_wbl_sg_law_indx}: The index scores 35 data points across eight indicators composed of four or five binary questions, with each indicator representing a different phase of a woman’s life. Indicator-level scores are obtained by calculating the unweighted average of responses to the questions within that indicator and scaling the result to 100. Questions are related to gender equality around mobility, workplace, pay, marriage, parenthood, entrepreneurship, assets, and pension.
#'   \item \strong{wb_wdi_dt_dod_mwbg_cd}: IBRD loans and IDA credits are public and publicly guaranteed debt extended by the World Bank Group. The International Bank for Reconstruction and Development (IBRD) lends at market rates. Credits from the International Development Association (IDA) are at concessional rates. Data are in current U.S. dollars.
#'   \item \strong{wb_wdi_dt_nfl_pcbo_cd}: Commercial bank and other lending includes net commercial bank lending (public and publicly guaranteed and private nonguaranteed) and other private credits. Data are in current U.S. dollars.
#'   \item \strong{wb_wdi_gc_rev_xgrt_gd_zs}: Revenue is cash receipts from taxes, social contributions, and other revenues such as fines, fees, rent, and income from property or sales. Grants are also considered as revenue but are excluded here.
#'   \item \strong{wb_wdi_gc_tax_expt_zs}: Taxes on exports are all levies on goods being transported out of the country or services being delivered to nonresidents by residents. Rebates on exported goods that are repayments of previously paid general consumption taxes, excise taxes, or import duties are deducted from the gross amounts receivable from these taxes, not from amounts receivable from export taxes.
#'   \item \strong{wb_wdi_gc_tax_gsrv_rv_zs}: Taxes on goods and services include general sales and turnover or value added taxes, selective excises on goods, selective taxes on services, taxes on the use of goods or property, taxes on extraction and production of minerals, and profits of fiscal monopolies.
#'   \item \strong{wb_wdi_gc_tax_impt_zs}: Customs and other import duties are all levies collected on goods that are entering the country or services delivered by nonresidents to residents. They include levies imposed for revenue or protection purposes and determined on a specific or ad valorem basis as long as they are restricted to imported goods or services.
#'   \item \strong{wb_wdi_gc_tax_intt_rv_zs}: Taxes on international trade include import duties, export duties, profits of export or import monopolies, exchange profits, and exchange taxes.
#'   \item \strong{wb_wdi_gc_xpn_comp_zs}: Compensation of employees consists of all payments in cash, as well as in kind (such as food and housing), to employees in return for services rendered, and government contributions to social insurance schemes such as social security and pensions that provide benefits to employees.
#'   \item \strong{wb_wdi_gc_xpn_gsrv_zs}: Taxes on international trade include import duties, export duties, profits of export or import monopolies, exchange profits, and exchange taxes.
#'   \item \strong{wb_wdi_gc_xpn_trft_zs}: Goods and services include all government payments in exchange for goods and services used for the production of market and nonmarket goods and services. Own-account capital formation is excluded.
#'   \item \strong{wb_wdi_ic_bus_ndns_zs}: New businesses registered are the number of new limited liability corporations (or its equivalent) registered in the calendar year.
#'   \item \strong{wb_wdi_ic_bus_nreg}: New businesses registered are the number of new limited liability corporations (or its equivalent) registered in the calendar year.
#'   \item \strong{wb_wdi_ie_ppi_watr_cd}: Investment in water and sanitation projects with private participation refers to commitments to  infrastructure projects in water and sanitation that have reached financial closure and directly or indirectly serve the public. Movable assets, incinerators, standalone solid waste projects, and small projects are excluded. The types of projects included are management and lease contracts, operations and management contracts with major capital expenditure, greenfield projects (in which a private entity or a public-private joint venture builds and operates a new facility), and divestitures. Investment commitments are the sum of investments in facilities and investments in government assets. Investments in facilities are the resources the project company commits to invest during the contract period either in new facilities or in expansion and modernization of existing facilities. Investments in government assets are the resources the project company spends on acquiring government assets such as state-owned enterprises, rights to provide services in a specific area, or the use of specific radio spectrums. Data is presented based on investment year. Data are in current U.S. dollars.
#'   \item \strong{wb_wdi_iq_spi_ovrl}: The SPI overall score is a composite score measuing country performance across five pillars: data use, data services, data products, data sources, and data infrastructure.  The new Statistical Performance Indicators (SPI) will replace the Statistical Capacity Index (SCI), which the World Bank has regularly published since 2004. Although the goals are the same, to offer a better tool to measure the statistical systems of countries, the new SPI framework has expanded into new areas including in the areas of data use, administrative data, geospatial data, data services, and data infrastructure. The SPI provides a framework that can help countries measure where they stand in several dimensions and offers an ambitious measurement agenda for the international community.
#'   \item \strong{wb_wdi_iq_spi_pil1}: The data use overall score is a composite score measuring the demand side of the statistical system.  The data use  pillar is segmented by five types of users: (i) the legislature, (ii) the executive branch, (iii) civil society (including sub-national actors), (iv) academia and (v) international bodies.  Each dimension would have associated indicators to measure performance. A mature system would score well across all dimensions whereas a less mature one would have weaker scores along certain dimensions. The gaps would give insights into prioritization among user groups and help answer questions as to why the existing services are not resulting in higher use of national statistics in a particular segment.  Currently, the SPI only features indicators for one of the five dimensions of data use, which is data use by international organizations. Indicators on whether statistical systems are providing useful data to their national governments (legislature and executive branches), to civil society, and to academia are absent.  Thus the dashboard does not yet assess if national statistical systems are meeting the data needs of a large swathe of users.
#'   \item \strong{wb_wdi_iq_spi_pil2}: The data services pillar overall score is a composite indicator based on four dimensions of data services: (i) the quality of data releases, (ii) the richness and openness of online access, (iii) the effectiveness of advisory and analytical services related to statistics, and (iv) the availability and use of data access services such as secure microdata access. Advisory and analytical services might incorporate elements related to data stewardship services including input to national data strategies, advice on data ethics and calling out misuse of data in accordance with the Fundamental Principles of Official Statistics.
#'   \item \strong{wb_wdi_iq_spi_pil3}: The data products overall score is a composite score measureing whether the country is able to produce relevant indicators, primarily related to SDGs.  The data products (internal process) pillar is segmented by four topics and organized into (i) social, (ii) economic, (iii) environmental, and (iv) institutional dimensions using the typology of the Sustainable Development Goals (SDGs). This approach anchors the national statistical system’s performance around the essential data required to support the achievement of the 2030 global goals, and enables comparisons across countries so that a global view can be generated while enabling country specific emphasis to reflect the user needs of that country.
#'   \item \strong{wb_wdi_iq_spi_pil4}: The data sources overall score is a composity measure of whether countries have data available from the following sources: Censuses and surveys, administrative data, geospatial data, and private sector/citizen generated data.  The data sources (input) pillar is segmented by four types of sources generated by (i) the statistical office (censuses and surveys), and sources accessed from elsewhere such as (ii)  administrative data, (iii) geospatial data, and (iv) private sector data and citizen generated data. The appropriate balance between these source types will vary depending on a country’s institutional setting and the maturity of its statistical system. High scores should reflect the extent to which the sources being utilized enable the necessary statistical indicators to be generated. For example, a low score on environment statistics (in the data production pillar) may reflect a lack of use of (and low score for) geospatial data (in the data sources pillar). This type of linkage is inherent in the data cycle approach and can help highlight areas for investment required if country needs are to be met.
#'   \item \strong{wb_wdi_iq_spi_pil5}: The data infrastructure  pillar  overall score measures the hard and soft infrastructure segments, itemizing essential cross cutting requirements for an effective statistical system.  The segments are: (i) legislation and governance covering the existence of laws and a functioning institutional framework for the statistical system; (ii) standards and methods addressing compliance with recognized frameworks and concepts; (iii) skills including level of skills within the statistical system and among users (statistical literacy); (iv) partnerships reflecting the need for the statistical system to be inclusive and coherent; and (v) finance mobilized both domestically and from donors.
#'   \item \strong{wb_wdi_tm_val_fuel_zs_un}: Fuels comprise the commodities in SITC section 3 (mineral fuels, lubricants and related materials).
#'   \item \strong{wjp_rol_2_2}: Measures whether judges and judicial officials refrain from soliciting and accepting bribes to perform duties or expedite processes, and whether the judiciary and judicial rulings are free of improper influence by the government, private interests, or criminal organizations.
#'   \item \strong{wjp_rol_3_1}: Measures whether basic laws and information on legal rights are publicly available, presented in plain language, and made accessible in all languages used in the country or jurisdiction. It also measures the quality and accessibility of information published by the government in print or online, and whetheradministrative regulations, drafts of legislation, and high court decisions are made accessible to the public in a timely manner
#'   \item \strong{wjp_rol_3_2}: Measures whether requests for information held by a government agency are granted, whether these requests are granted within a reasonable time period, if the information provided is pertinent and complete, and if requests for information are granted at a reasonable cost and without having to pay a bribe. It also measures whether people are aware of their right to information, and whether relevant records are accessible to the public upon request. Coded from 0 to 1, with higher scores indicating stronger rights.
#'   \item \strong{wjp_rol_3_4}: Measures whether people are able to bring specific complaints to the government about the provision of public services or the performance of government officers in carrying out their legal duties in practice, and how government officials respond to such complaints. Coded from 0 to 1, with higher scores indicating stronger mechanisms.
#'   \item \strong{wjp_rol_4_3}: Measures whether the basic rights of criminal suspects are respected, including the presumption of innocence and the freedom from arbitrary arrest and unreasonable pre-trial detention. It also measures whether criminal suspects are able to access and challenge evidence used against them, whether they are subject to abusive treatment, and whether they are provided with adequate legal assistance. In addition, it measures whether the basic rights of prisoners are respected once they have been convicted of a crime.
#'   \item \strong{wjp_rol_4_4}: Measures whether an independent media, civil society organizations, political parties, and individuals are free to report and comment on government policies without fear of retaliation.
#'   \item \strong{wjp_rol_4_5}: Measures whether members of religious minorities can worship and conduct religious practices freely and publicly, and whether non-adherents are protected from having to submit to religious laws.
#'   \item \strong{wjp_rol_4_6}: Measures whether the police or other government officials conduct physical searches without warrants, or intercept electronic communications of private individuals without judicial authorization
#'   \item \strong{wjp_rol_4_7}: Measures whether people can freely attend community meetings, join political organizations, hold peaceful public demonstrations, sign petitions, and express opinions against government policies and actions without fear of retaliation.
#'   \item \strong{wjp_rol_4_8}: Measures the effective enforcement of fundamental labor rights, including freedom of association and the right to collective bargaining, the absence of discrimination with respect to employment, and freedom from forced labor and child labor.
#'   \item \strong{wjp_rol_6_2}: Measures whether the enforcement of regulations is subject to bribery or improper influence by private interests, and whether public services, such as the issuance of permits and licenses and the administration of public health services, are provided without bribery or other inducements.
#'   \item \strong{wjp_rol_7_1}: People can access & afford civil justice; Civil justice is free of discrimination; Civil justice is free of corruption; Civil justice is free of improper government influence; Civil justice is not subject to unreasonable delay; Civil justice is effectively enforced; Alternative dispute resolution mechanisms are accessible, impartial, and effective.
#'   \item \strong{wjp_rol_7_5}: Measures whether civil justice proceedings are conducted and judgments are produced in a timely manner without unreasonable delay.
#'   \item \strong{wjp_rol_7_6}: Measures the effectiveness and timeliness of the enforcement of civil justice decisions and judgments in practice.
#'   \item \strong{wjp_rol_7_7}: Alternative dispute resolution mechanisms are accessible, impartial, and effective (WJP Rule of Law Index)
#'   \item \strong{wjp_rol_8_1}: Measures whether perpetrators of crimes are effectively apprehended and charged. It also measures whether police, investigators, and prosecutors have adequate resources, are free of corruption, and perform their duties competently.
#'   \item \strong{wjp_rol_8_2}: Criminal investigation system is effective; Criminal adjudication system is timely and effective; Correctional system is effective in reducing criminal behavior; Criminal justice system is impartial; Criminal justice system is free of corruption; Criminal justice system is free of improper government influence; Due process of the law & rights of the accused.
#'   \item \strong{wjp_rol_8_4}: Measures whether the police and criminal judges are impartial and whether they discriminate in practice based on socio-economic status, gender, ethnicity, religion, national origin, sexual orientation, or gender identity.
#'   \item \strong{wb_gtmi_pfm_mis}: CLIAR made Index of PFM MIS based on GTMI data. Considers whether there's an operational FMIS (GTMI_I-5), a TSA (GTMI_I-6), a Tax MIS (GTMI_I-7), a DMS (GTMI_I-13), Customs MIS (GTMI_I-8), a PIMS (GTMI_I-14), and an e-Procurement system in place.
#' }
#'
#' @source World Bank EFI Data 360 (as provided by you)
#' @docType data
#' @name d360_efi_data
#' @keywords datasets governance institutions efi data360
#' @examples
#' data(d360_efi_data)
#' str(d360_efi_data)
#' head(d360_efi_data)
"d360_efi_data"


#' @title ASPIRE Social Protection Indicators
#'
#' @description
#' The ASPIRE (Atlas of Social Protection Indicators of Resilience and Equity) dataset provides standardized, cross-country indicators related to social protection and labor programs. It includes harmonized measures on adequacy and coverage of benefits, enabling regional and income-level comparisons over time.
#'
#' @format A data frame with 512 rows and 4 variables:
#' \describe{
#'   \item{\code{country_code}}{Character. ISO3 country code based on World Bank standards.}
#'   \item{\code{year}}{Numeric. Year of the observation.}
#'   \item{\code{wb_aspire_adequacy_benefits}}{Numeric. Average benefit received by beneficiaries as a percentage of the total welfare of the beneficiary population (proxy for adequacy).}
#'   \item{\code{wb_aspire_coverage}}{Numeric. Percentage of the population participating in social protection and labor programs (proxy for coverage).}
#' }
#'
#' @details
#' The ASPIRE indicators are derived from nationally representative household surveys and harmonized using consistent methodologies across countries. The dataset supports policy analysis, benchmarking, and global monitoring of social protection systems. For more information, see the [World Bank ASPIRE website](https://www.worldbank.org/en/data/datatopics/aspire).
"aspire"


#' Fraser Economic Freedom Dataset
#'
#' A dataset containing 4 selected indicators from the Fraser Institute's Economic Freedom of the World database.
#'
#' @format A data frame with 4,786 rows and 6 variables:
#' \describe{
#'   \item{\code{country_code}}{Character. The 3-letter ISO country code.}
#'   \item{\code{year}}{Numeric. The year of the observation.}
#'   \item{\code{fraser_efw_foreign_currency_bank_accounts}}{Numeric. Freedom to own foreign currency bank accounts.}
#'   \item{\code{fraser_efw_freedom_of_foreigners_to_visit}}{Numeric. Freedom of foreigners to visit.}
#'   \item{\code{fraser_efw_capital_controls}}{Numeric. Capital controls.}
#'   \item{\code{fraser_efw_credit_market_regulation}}{Numeric. Credit market regulations.}
#' }
#' @source \url{https://efotw.org/economic-freedom/dataset?geozone=world&page=dataset&min-year=2&max-year=0&filter=0}
#' @usage data(fraser)
#' @keywords datasets
"fraser"



