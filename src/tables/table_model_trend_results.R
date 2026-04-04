# purpose: Build and optionally save the GLS AR(1) long-run trend results table.
# inputs: trend_tbl from run_gls_models()$trend and the start and end years used in the subtitle.
# outputs: A formatted tibble and an optional saved table image in outputs/tables/table_model_gls_ar1_trend_summary.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the wide long-run trend summary table used in the main report.
make_table_model_trend_results <- function(
  trend_tbl,
  save_table = FALSE,
  year_start = 1879,
  year_end   = 2024
) {
  # Format the trend estimates and confidence intervals into a season-by-metric table.
  tbl <- build_wide_ci_table(
    trend_tbl,
    estimate_col = "trend_decade",
    lower_col    = "lower",
    upper_col    = "upper",
    digits       = 3
  )

  tbl <- tbl %>%
    dplyr::mutate(
      dplyr::across(c(Mean, Min, Max), ~ gsub("\\*", "", .x))
    )

  if (save_table) {
    # Estimate output size and build the table plot before saving it.
    dims  <- estimate_table_dims(tbl)
    p_tbl <- make_table_plot(
      tbl,
      title    = "GLS AR(1) Long-Run Warming Rates",
      subtitle = paste0(
        "Trend period: ", year_start, "\u2013", year_end,
        ". Format: estimate [95% CI] in \u00b0C per decade."
      )
    )

    save_table_jpg(
      p_tbl,
      filename = "table_model_gls_ar1_trend_summary.jpg",
      width    = dims$width,
      height   = dims$height
    )
  }

  tbl
}
