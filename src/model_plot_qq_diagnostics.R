# purpose:  Q-Q plot of GLS AR(1) normalised trend residuals for all 12
#           season-metric combinations, to assess the normality assumption.
# inputs:   gls_resid_df from compute_gls_trend_residuals()
# outputs:  outputs/figures/model_diagnostics_qq_gls_residuals.jpg (save_plot=TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (validation-sources chunk)

make_gls_qq_plot <- function(gls_resid_df, save_plot = FALSE) {
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
    eda_save_plot(p, "model_diagnostics_qq_gls_residuals.jpg",
                  width = 9, height = 3.8)
  }

  p
}
