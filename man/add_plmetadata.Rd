% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/pipeline_management.R
\name{add_plmetadata}
\alias{add_plmetadata}
\title{Add Metadata Attributes to a Dataset}
\usage{
add_plmetadata(df, source, other_info)
}
\arguments{
\item{df}{A `data.frame` object to which metadata will be added.}

\item{source}{A `character` string indicating the URL or source of the dataset.}

\item{other_info}{A `character` string containing any additional metadata or descriptive information.}
}
\value{
The input `data.frame` with additional attributes:
\describe{
  \item{`source`}{The URL or source location of the dataset.}
  \item{`other info`}{Any user-supplied contextual information.}
  \item{`download_date`}{The date when the data was processed or downloaded.}
}
}
\description{
Adds metadata to a `data.frame`, such as the source URL, download date, and any additional information.
}
\examples{
df <- data.frame(x = 1:5)
df_meta <- add_plmetadata(df,
                          source = "https://example.com/data.csv",
                          other_info = "Mock dataset for demo")
attributes(df_meta)

}
