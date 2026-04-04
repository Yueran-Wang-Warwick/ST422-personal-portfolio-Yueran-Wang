# purpose: Plot Q-Q diagnostics for GLS AR(1) normalised trend residuals across all season-metric combinations.
# inputs: gls_resid_df from compute_gls_trend_residuals().
# outputs: A ggplot object and an optional saved figure in outputs/figures/model_diagnostics_qq_gls_residuals.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the validation-sources chunk.

# Build the Q-Q diagnostic plot used to assess residual normality across the 12 series.
make_gls_qq_plot <- function(gls_resid_df, save_plot = FALSE) {
  # Add display labels for seasons and metrics before plotting.
  plot_df <- gls_resid_df %>%
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

  # Draw Q-Q points and reference lines for each season panel.
  p <- ggplot(plot_df, aes(sample = resid_gls, colour = metric_label)) +
    stat_qq(size = 0.8, alpha = 0.6) +
    stat_qq_line(linewidth = 0.5, colour = "#6B7280") +
    facet_wrap(~ season_label, nrow = 1) +
    scale_colour_manual(values = metric_colours, name = NULL) +
    labs(
      x = "Theoretical quantiles",
      y = "Sample quantiles"
    ) +
    eda_base_theme() +
    theme(panel.spacing = unit(0.6, "lines"))

  if (save_plot) {

    # Save the Q-Q diagnostic plot to the standard figures directory.
    eda_save_plot(
      p,
      "model_diagnostics_qq_gls_residuals.jpg",
      width = 9,
      height = 3.8
    )
  }

  p
}
