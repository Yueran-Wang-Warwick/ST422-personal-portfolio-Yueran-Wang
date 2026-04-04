# purpose: Plot estimated AR(1) rho values from the baseline-shift and long-run trend models in one combined chart.
# inputs: rho_tbl from run_gls_models()$rho.
# outputs: A ggplot object and an optional saved figure in outputs/figures/model_gls_ar1_combined_rho_by_model_season_metric.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the combined rho plot used to summarise serial dependence across model types.
make_model_combined_rho_plot <- function(rho_tbl, save_plot = FALSE) {
  # Reshape the rho summaries into a plotting dataset with display labels.
  plot_df <- rho_tbl %>%
    dplyr::transmute(
      season,
      mean_shift = rho_shift,
      mean_trend = rho_trend,
      metric = metric
    ) %>%
    tidyr::pivot_longer(
      cols = c(mean_shift, mean_trend),
      names_to = "model_type",
      values_to = "rho_value"
    ) %>%
    dplyr::mutate(
      model_short = dplyr::if_else(model_type == "mean_shift", "Base", "LR"),
      x_label = paste(model_short, eda_season_label(as.character(season))),
      x_label = factor(
        x_label,
        levels = c(
          "Base Winter", "LR Winter",
          "Base Spring", "LR Spring",
          "Base Summer", "LR Summer",
          "Base Autumn", "LR Autumn"
        )
      ),
      metric_label = factor(
        eda_metric_label(metric),
        levels = c("Mean", "Minimum", "Maximum")
      )
    )

  metric_fills <- setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum"))

  # Draw grouped bars for baseline and long-run rho estimates across seasons.
  p <- ggplot(plot_df, aes(x = x_label, y = rho_value, fill = metric_label)) +
    geom_col(position = position_dodge(width = 0.62), width = 0.42) +
    scale_fill_manual(values = metric_fills, name = NULL) +
    labs(
      title = "Serial Dependence in Baseline and Long-Run Models",
      x = NULL,
      y = expression(hat(rho) ~ "(AR(1) coefficient)")
    ) +
    eda_base_theme() +
    theme(
      axis.text.x = element_text(size = 9)
    )

  if (save_plot) {

    # Save the rho comparison plot to the standard figures directory.
    eda_save_plot(
      p,
      "model_gls_ar1_combined_rho_by_model_season_metric.jpg",
      width = 8.5,
      height = 4
    )
  }

  p
}
