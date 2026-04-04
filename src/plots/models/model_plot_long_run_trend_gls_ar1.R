# purpose: Plot GLS AR(1) long-run trend estimates and confidence intervals by season and metric.
# inputs: trend_tbl from run_gls_models()$trend.
# outputs: A ggplot object and an optional saved figure in outputs/figures/model_gls_ar1_long_run_trend_by_season_metric.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the long-run trend summary plot used in the main model results section.
make_model_trend_plot <- function(trend_tbl, save_plot = FALSE) {
  # Add display labels for the season and metric categories used in the report figure.
  plot_df <- trend_tbl %>%
    dplyr::mutate(
      season_label = factor(
        eda_season_label(season),
        levels = c("Winter", "Spring", "Summer", "Autumn")
      ),
      metric_label = factor(
        eda_metric_label(metric),
        levels = c("Mean", "Minimum", "Maximum")
      )
    )

  metric_colours <- setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum"))

  # Draw point estimates and confidence intervals around the zero reference line.
  p <- ggplot(plot_df, aes(x = season_label, y = trend_decade, colour = metric_label)) +
    geom_hline(yintercept = 0, linewidth = 0.3, linetype = "dashed", colour = "#9CA3AF") +
    geom_errorbar(
      aes(ymin = lower, ymax = upper),
      position  = position_dodge(width = 0.45),
      width     = 0.18,
      linewidth = 0.6
    ) +
    geom_point(
      position = position_dodge(width = 0.45),
      size     = 2.2,
      alpha    = 0.9
    ) +
    scale_colour_manual(values = metric_colours, name = NULL) +
    labs(
      title = "Long-Run Warming Rates Across Seasons and Temperature Types",
      x = NULL,
      y = "Trend (degC per decade)"
    ) +
    eda_base_theme()

  if (save_plot) {

    # Save the long-run trend plot to the standard figures directory.
    eda_save_plot(
      p,
      "model_gls_ar1_long_run_trend_by_season_metric.jpg",
      width = 8,
      height = 3
    )
  }

  p
}
