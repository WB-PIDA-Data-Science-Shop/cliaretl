% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{epl}
\alias{epl}
\title{OECD Employment Protection Legislation (EPL) Indicators}
\format{
A tibble with 287 rows and 4 variables:
\describe{
  \item{country_code}{Three-letter ISO country code (e.g., "AUS", "FRA").}
  \item{year}{Observation year (e.g., 2013).}
  \item{oecd_epl_regular}{Composite indicator of employment protection legislation governing regular contracts (individual dismissals).}
  \item{oecd_epl_temporary}{Composite indicator of employment protection legislation governing temporary contracts (individual dismissals).}
}
}
\source{
OECD Employment Protection Database. \url{https://www.oecd.org/employment/emp/oecdindicatorsofemploymentprotection.htm}
}
\usage{
data(epl)
}
\description{
Measures the strictness of rules and enforcement practices surrounding hiring and firing of workers under different types of contracts. A higher score indicates more stringent regulation.
}
\details{
This dataset includes composite indicators developed by the OECD to quantify the strength of employment protection legislation (EPL) for regular and temporary contracts. The indicators reflect rules and practices regarding individual dismissals and are part of the OECD Employment Protection Database.


\itemize{
  \item \strong{oecd_epl_regular:} Composite indicator of employment protection legislation governing individual dismissals for regular (permanent) contracts. It captures aspects such as procedural inconveniences, notice periods, and severance pay.
  \item \strong{oecd_epl_temporary:} Composite indicator of employment protection legislation for temporary contracts. This includes aspects such as valid grounds for fixed-term contracts, maximum number of renewals, and duration limits.
}
}
\keyword{datasets}
