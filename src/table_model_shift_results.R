# purpose:  Build and optionally save the GLS AR(1) baseline shift results table.
#           Formats estimates and 95% CIs as "estimate [lower, upper]" cells,
#           pivoted wide by metric with seasons as rows.
# inputs:   shift_tbl from run_gls_models()$shift
# outputs:  outputs/tables/table_model_gls_ar1_shift_summary.jpg (save_table=TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

make_table_model_shift_results <- function(
  shift_tbl,
  save_table       = FALSE,
  historical_start = 1961,
  historical_end   = 1990,
  recent_start     = 1991,
  recent_end       = 2020
) {
  tbl <- build_wide_ci_table(
    shift_tbl,
    estimate_col = "shift",
    lower_col    = "lower",
    upper_col    = "upper",
    digits       = 3
  ) %>%
    dplyr::mutate(
      dplyr::across(c(Mean, Min, Max), ~ gsub("\\*", "", .x))
    )

  if (save_table) {
    dims  <- estimate_table_dims(tbl)
    p_tbl <- make_table_plot(
      tbl,
      title    = "GLS AR(1) Baseline Shifts",
      subtitle = paste0(
        "beta_1 is the ", recent_start, "\u2013", recent_end,
        " minus ", historical_start, "\u2013", historical_end,
        " mean difference in \u00b0C. Format: estimate [95% CI]."
      )
    )
    save_table_jpg(
      p_tbl,
      filename = "table_model_gls_ar1_shift_summary.jpg",
      width    = dims$width,
      height   = dims$height
    )
  }

  tbl
}
