# purpose:  Build and optionally save the GLS AR(1) long-run trend results table.
#           Formats trend estimates and 95% CIs in degC per decade,
#           pivoted wide by metric with seasons as rows.
# inputs:   trend_tbl from run_gls_models()$trend
# outputs:  outputs/tables/table_model_gls_ar1_trend_summary.jpg (save_table=TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

make_table_model_trend_results <- function(
  trend_tbl,
  save_table = FALSE,
  year_start = 1879,
  year_end   = 2024
) {
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
