## code to prepare `credit_rating` dataset goes here
# last updated: 7/21/2026
devtools::load_all()

credit_rating_raw <- get_data360_api(
  "WEF_TTDI",
  "WEF_TTDI_INDCCREDITRATE",
  pivot = FALSE
)

credit_rating <- credit_rating_raw |> 
  filter(
    COMP_BREAKDOWN_1 == "WEF_TTDI_VAL"
  ) |> 
  pivot_data360() |> 
  rename(
    credit_rating = wef_ttdi_indccreditrate
  ) |> 
  mutate(
    credit_rating = as.numeric(credit_rating)
  )

credit_rating <- credit_rating |>
  add_plmetadata(
    source = "World Bank Data 360",
    other_info = "The data is from the World Bank Data 360 and represents the average credit rating of countries based on various credit rating agencies."
  )

usethis::use_data(credit_rating, overwrite = TRUE)
