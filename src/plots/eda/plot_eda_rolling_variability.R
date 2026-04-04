# purpose: Plot rolling 30-year variability for each season and temperature metric.
# inputs: Cleaned HadCET data loaded through eda_load_hadcet_long() and the chosen rolling window width.
# outputs: A ggplot object and an optional saved figure in outputs/figures/eda_rolling_30y_variability_sd_refined.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd for appendix variability checks.

# Build the rolling standard deviation plot used to summarise long-run variability changes.
make_eda_rolling_variability_plot <- function(save_plot = FALSE, window = 30) {
  # Compute rolling standard deviations within each season-metric series.
  variability_df <- eda_load_hadcet_long(include_annual = FALSE, year_min = 1879, year_max = 2024) %>%
    arrange(metric, season, year) %>%
    group_by(metric, season) %>%
    mutate(rolling_sd = eda_rolling_sd(temp_c, window = window)) %>%
    ungroup()

  # Draw the rolling variability curves with one panel per season.
  p <- ggplot(variability_df, aes(x = year, y = rolling_sd, colour = metric)) +
    geom_line(linewidth = 0.9, alpha = 0.8, na.rm = TRUE) +
    facet_wrap(~ season, ncol = 2, scales = "free_y", labeller = as_labeller(eda_season_label)) +
    scale_colour_manual(values = eda_metric_palette, labels = eda_metric_label) +
    labs(
      title = "Rolling 30-Year Standard Deviations",
      x = "Year",
      y = "Rolling standard deviation (degC)"
    ) +
    eda_base_theme()

  if (save_plot) {

    # Save the rolling variability plot to the standard figures directory.
    eda_save_plot(p, "eda_rolling_30y_variability_sd_refined.jpg", width = 11.4, height = 7.8)
  }

  p
}
