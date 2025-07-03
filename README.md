<!-- README.md is generated from README.Rmd. Please edit that file -->

# cliaretl

<!-- badges: start -->

[![R-CMD-check](https://github.com/WB-PIDA-Data-Science-Shop/cliaretl/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WB-PIDA-Data-Science-Shop/cliaretl/actions/workflows/R-CMD-check.yaml)
[![R-CMD-check](https://github.com/WB-PIDA-Data-Science-Shop/cliaretl/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/WB-PIDA-Data-Science-Shop/cliaretl/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of cliaretl is to be the central data pipeline responsible for
sourcing, processing and delivering the data to the CLIAR dashboard. Its
primary function is to execute a robust Extract, Transform and Load
(ETL) process, ensuring the dashboard always has access to accurate and
harmonized data. It provides the following features:

-   Automated Data Extraction: Programmatically pulls raw data from
    various external services through efficient API calls.

-   Data Harmonization: Merges and standardizes data originating from
    both API endpoints and manual input sources. This ensures data
    consistency and reliability, regardless of its origin.

-   Data Preparation: Transforms raw and harmonized data into a clean,
    structured, and optimized format, making it available to use in the
    CLIAR dashboard. This process also facilitates version control for
    the data, ensuring traceability and reproducibility.

-   Data Quality Testing: Implements a modular testing approach to
    verify data quality at various stages of the ETL pipeline, ensuring
    data integrity and reliability before it reaches the dashboard.

## Installation

The package is still very early in development. However, you will be
able to install the development version of cliaretl from
[GitHub](https://github.com/) with:

    # install.packages("pak")
    # pak::pak("WB-PIDA-Data-Science-Shop/cliaretl")

## Access to the data

The complete list of raw data sources and to-dos is available \[here\]
(<https://worldbankgroup-my.sharepoint.com/:x:/g/personal/earias1_worldbank_org/EUmJLnSAxFlOpirD9fjkVCUBDCuC9kKU58yzYpIWjdDosw?CID=af6fb8a3-cb6e-1db1-27d4-7b6958825f9d>)
