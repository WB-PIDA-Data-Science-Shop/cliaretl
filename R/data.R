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
#'   \item{\code{country_name}}{character The official name of the country or region.}
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
#'   \item{\code{wdi_gcrevxgrtgdzs}}{double Revenue, excluding grants (percentage of GDP).}
#'   \item{\code{wdi_nvsrvtotlzs}}{double Services, etc., value added (percentage of GDP).}
#'   \item{\code{wdi_gctaxtotlgdzs}}{double Tax revenue (percentage of GDP).}
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
#'   \item{\code{wdi_dcodatotlgnzs}}{double Net official development assistance and official aid received (percentage of GNI).}
#'   \item{\code{wdi_dttdsdppggnzs}}{double Debt service on external debt (percentage of exports of goods, services and primary income).}
#'   \item{\code{wdi_dttdsdectgnzs}}{double Debt service on external debt (percentage of GNI).}
#'   \item{\code{wdi_dtdodpvlxgnzs}}{double Present value of external debt (percentage of GNI).}
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
#'   \item{\code{wdi_shmedcmhwp3}}{double Community health workers (per 1,000 people).}
#'   \item{\code{wdi_shxpdchexgdzs}}{double Current health expenditure (percentage of GDP).}
#'   \item{\code{wdi_shxpdoopcchzs}}{double Out-of-pocket health expenditure (percentage of current health expenditure).}
#'   \item{\code{wdi_shxpdoopcppcd}}{double Out-of-pocket health expenditure per capita (current USD).}
#'   \item{\code{wdi_sipovmdim}}{double Multidimensional poverty headcount ratio (percentage of total population).}
#'   \item{\code{wdi_sipovmdimxq}}{double Multidimensional poverty index.}
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
#'   \item{vdem_core_v2lgfemleg}{Share of women in the legislature (percentage) (`v2lgfemleg`).}
#'   \item{vdem_core_v2cldiscm}{State‐based political discrimination against men (`v2cldiscm`).}
#'   \item{vdem_core_v2cldiscw}{State‐based political discrimination against women (`v2cldiscw`).}
#'   \item{vdem_core_v2caassemb}{Freedom of peaceful assembly (`v2caassemb`).}
#'   \item{vdem_core_v2cacamps}{Freedom of campus assembly (`v2cacamps`).}
#'   \item{vdem_core_v2peapsecon}{Socio‑economic power inequality (`v2peapsecon`).}
#'   \item{vdem_core_v2peasjsoecon}{Socio‑economic power by social group (`v2peasjsoecon`).}
#'   \item{vdem_core_v2peapsgen}{Political power inequality by gender (`v2peapsgen`).}
#'   \item{vdem_core_v2peasjgen}{Social group–gender power interaction (`v2peasjgen`).}
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
#'   \item{iso3}{A three-letter ISO 3166-1 alpha-3 country code.}
#'   \item{year}{The calendar year of the observation.}
#'   \item{wb_gfdb_ai_01}{Assets of the three largest commercial banks as a share of total commercial banking assets.
#'   Total assets include earning assets, cash, due from banks, foreclosed real estate, fixed assets, goodwill, intangibles, tax assets, and other financial assets. A higher value indicates greater banking sector concentration.}
#'   \item{wb_gfdb_di_01}{Domestic credit to the private sector by domestic money banks, as a share of GDP.
#'   Domestic money banks include commercial banks and other financial institutions that accept transferable deposits. This is a measure of financial resources extended to the private sector.}
#' }
#'
#' @details
#' \strong{wb_gfdb_di_01:} The financial resources provided to the private sector by domestic money banks as a share of GDP. Domestic money banks comprise commercial banks and other financial institutions that accept transferable deposits, such as demand deposits.
#'
#' \strong{wb_gfdb_ai_01:} Assets of the three largest commercial banks as a share of total commercial banking assets. Total assets include total earning assets, cash and due from banks, foreclosed real estate, fixed assets, goodwill, other intangibles, current tax assets, deferred tax assets, discontinued operations, and other assets.
#'
#' @source World Bank, Global Financial Development Database. See: \url{https://www.worldbank.org/en/publication/gfdr/data/global-financial-development-database}
"gfdb"
