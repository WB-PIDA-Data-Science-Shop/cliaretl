% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{gfdb}
\alias{gfdb}
\title{Global Financial Development Database (GFDB) Indicators}
\format{
A tibble with 6,848 rows and 4 variables:
\describe{
  \item{iso3}{A three-letter ISO 3166-1 alpha-3 country code.}
  \item{year}{The calendar year of the observation.}
  \item{wb_gfdb_ai_01}{Assets of the three largest commercial banks as a share of total commercial banking assets.
  Total assets include earning assets, cash, due from banks, foreclosed real estate, fixed assets, goodwill, intangibles, tax assets, and other financial assets. A higher value indicates greater banking sector concentration.}
  \item{wb_gfdb_di_01}{Domestic credit to the private sector by domestic money banks, as a share of GDP.
  Domestic money banks include commercial banks and other financial institutions that accept transferable deposits. This is a measure of financial resources extended to the private sector.}
}
}
\source{
World Bank, Global Financial Development Database. See: \url{https://www.worldbank.org/en/publication/gfdr/data/global-financial-development-database}
}
\usage{
gfdb
}
\description{
A dataset containing selected indicators from the World Bank's Global Financial Development Database (GFDB), covering financial sector performance across countries and years. This data focuses on domestic credit provision and concentration of banking assets.
}
\details{
\strong{wb_gfdb_di_01:} The financial resources provided to the private sector by domestic money banks as a share of GDP. Domestic money banks comprise commercial banks and other financial institutions that accept transferable deposits, such as demand deposits.

\strong{wb_gfdb_ai_01:} Assets of the three largest commercial banks as a share of total commercial banking assets. Total assets include total earning assets, cash and due from banks, foreclosed real estate, fixed assets, goodwill, other intangibles, current tax assets, deferred tax assets, discontinued operations, and other assets.
}
\keyword{datasets}
