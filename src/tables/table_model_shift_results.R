# purpose: Build and optionally save the GLS AR(1) baseline-shift results table.
# inputs: shift_tbl from run_gls_models()$shift and the historical and recent window labels used in the subtitle.
# outputs: A formatted tibble and an optional saved table image in outputs/tables/table_model_gls_ar1_shift_summary.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the wide baseline-shift summary table used in the main report.
make_table_model_shift_results <- function(
  shift_tbl,
  save_table       = FALSE,
  historical_start = 1961,
  historical_end   = 1990,
  recent_start     = 1991,
  recent_end       = 2020
) {
  # Format the shift estimates and confidence intervals into a season-by-metric table.
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
    # Estimate output size and build the table plot before saving it.
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
