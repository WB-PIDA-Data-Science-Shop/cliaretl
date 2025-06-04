library(haven)
library(ggplot2)

debt_test <- read_dta(
  here("data-raw", "input", "debt_transparency", "debt_transparency_2021-2022.dta")
)

# identify inconsistencies in the data
# in this case, we identify inconsistencies in 22/148 cases
debt_test |>
  mutate(
    debt_transp_index = round(debt_transp_index, 2)
  ) |>
  inner_join(
    debt_transparency_clean,
    by = c("country_code", "year")
  ) |>
  select(starts_with("debt_transp_index")) |>
  filter(
    debt_transp_index.x != debt_transp_index.y
  )

debt_test |>
  mutate(
    debt_transp_index = round(debt_transp_index, 2)
  ) |>
  inner_join(
    debt_transparency_clean,
    by = c("country_code", "year")
  ) |>
  ggplot(aes(
    x = debt_transp_index.x,
    y = debt_transp_index.y
  )) +
  geom_text(
    aes(label = country_code)
  ) +
  geom_abline(
    slope = 1, intercept = 0, color = "red3",
    linetype = "dashed"
  ) +
  labs(
    x = "Debt Transparency Index (Original)",
    y = "Debt Transparency Index (New)"
  ) +
  theme_minimal()
