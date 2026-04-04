# purpose:  Plot GLS AR(1) long-run trend estimates (degC per decade, 1879-2024)
#           with 95% intervals as a point-range chart by season and metric.
# inputs:   trend_tbl from run_gls_models()$trend
# outputs:  outputs/figures/model_gls_ar1_long_run_trend_by_season_metric.jpg (save_plot=TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

make_model_trend_plot <- function(trend_tbl, save_plot = FALSE) {
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
      y = "Trend (°C per decade)"
    ) +
    eda_base_theme()

  if (save_plot) {
    eda_save_plot(p, "model_gls_ar1_long_run_trend_by_season_metric.jpg",
                  width = 8, height = 3)
  }

  p
}
