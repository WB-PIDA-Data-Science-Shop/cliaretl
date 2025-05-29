# getlcliar

*This project is currently under construction and undergoing active development.*

## Overview

The goal if  this package is to be the central data pipeline responsible for sourcing, processing, and delivering the data to the CLIAR dashboard. Its primary function is to execute a robust Extract, Transform, Load (ETL) process, ensuring the dashboard always has access to accurate and harmonized data. It provides the following features:

-   Automated Data Extraction: Programmatically pulls raw data from various external services through efficient API calls.

-   Data Harmonization: Merges and standardizes data originating from both API endpoints and manual input sources. This ensures data consistency and reliability, regardless of its origin.

-   Data Preparation: Transforms raw and harmonized data into a clean, structured, and optimized format, making it available to use in the CLIAR dashboard. This process also facilitates version control for the data, ensuring traceability and reproducibility.

-   Data Quality Testing: Implements a modular testing approach to verify data quality at various stages of the ETL pipeline, ensuring data integrity and reliability before it reaches the dashboard.

