# purpose: Plot seasonal P10-to-P90 reference ranges for the 30-year and 10-year monitoring windows.
# inputs: thresholds_30 and thresholds_10 tibbles from compute_monitoring_thresholds().
# outputs: A ggplot object and an optional saved figure in outputs/figures/.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

make_monitoring_threshold_plot <- function(thresholds_30, thresholds_10, save_plot = FALSE) {

  df_30 <- thresholds_30 %>%
    dplyr::select(season_label, metric_label, p10, p90) %>%
    dplyr::mutate(window_label = "30-year (1991\u20132020)")

  df_10 <- thresholds_10 %>%
    dplyr::select(season_label, metric_label, p10, p90) %>%
    dplyr::mutate(window_label = "10-year (2015\u20132024)")

  plot_df <- dplyr::bind_rows(df_30, df_10) %>%
    dplyr::mutate(
      season_label = factor(season_label, levels = c("Winter", "Spring", "Summer", "Autumn")),
      metric_label = factor(metric_label, levels = c("Mean", "Minimum", "Maximum")),
      window_label = factor(
        window_label,
        levels = c("30-year (1991\u20132020)", "10-year (2015\u20132024)")
      )
    )

  metric_colours <- setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum"))

  p <- ggplot(plot_df, aes(
    x      = season_label,
    colour = metric_label
  )) +
    geom_errorbar(
      aes(ymin = p10, ymax = p90),
      position  = position_dodge(width = 0.45),
      width     = 0.18,
      linewidth = 0.7
    ) +
    facet_wrap(~ window_label, nrow = 1) +
    scale_colour_manual(values = metric_colours, name = NULL) +
    labs(
      title = "Seasonal Monitoring Ranges Across Seasons and Temperature Types",
      x     = NULL,
      y     = "Temperature (degC)"
    ) +
    eda_base_theme()

  if (save_plot) {
    eda_save_plot(
      p,
      "model_monitoring_threshold_ranges.jpg",
      width  = 8.5,
      height = 4
    )
  }

  p
}
