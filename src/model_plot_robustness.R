# purpose:  Plot robustness comparison for targeted trend sensitivity checks,
#           faceted by season with metrics distinguished by colour.
# inputs:   robustness_results from run_all_robustness_checks()
# outputs:  outputs/figures/model_robustness_trend_segmented_1975.jpg
#           outputs/figures/model_robustness_trend_excluding_extremes.jpg (save_plot=TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (validation-sources chunk)

make_robustness_trend_plot <- function(
  robustness_results,
  save_plot = FALSE,
  title = NULL,
  filename = "model_robustness_trend_comparison.jpg"
) {
  short_spec_label <- function(x) {
    dplyr::case_when(
      x == "Base (AR(1), 1879-2024)" ~ "Base AR(1)",
      x == "Segmented AR(1), knot 1975 (post-knot slope)" ~ "Segmented 1975+",
      x == "Excluding extreme years" ~ "Excl. extremes",
      TRUE ~ x
    )
  }

  plot_df <- robustness_results$trend %>%
    dplyr::mutate(
      season_label = factor(
        eda_season_label(season),
        levels = c("Winter", "Spring", "Summer", "Autumn")
      ),
      metric_label = factor(
        eda_metric_label(metric),
        levels = c("Mean", "Minimum", "Maximum")
      ),
      spec_short = short_spec_label(as.character(spec)),
      spec_short = factor(spec_short, levels = unique(spec_short))
    )

  metric_colours <- setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum"))

  p <- ggplot(
    plot_df,
    aes(x = spec_short, y = trend_decade, colour = metric_label)
  ) +
    geom_hline(
      yintercept = 0,
      linetype = "dashed",
      colour = "#9CA3AF",
      linewidth = 0.4
    ) +
    geom_errorbar(
      aes(ymin = lower, ymax = upper),
      position = position_dodge(width = 0.6),
      width = 0.16,
      linewidth = 0.5,
      na.rm = TRUE
    ) +
    geom_point(
      position = position_dodge(width = 0.6),
      size = 1.8,
      na.rm = TRUE
    ) +
    facet_wrap(~ season_label, nrow = 1) +
    scale_colour_manual(values = metric_colours, name = NULL) +
    labs(x = NULL, y = "Trend (degC per decade)", title = title) +
    eda_base_theme() +
    theme(
      panel.spacing = unit(0.6, "lines"),
      axis.text.x = element_text(size = 8, angle = 0, hjust = 0.5),
      axis.text.y = element_text(size = 8)
    )

  if (save_plot) {
    eda_save_plot(
      p,
      filename,
      width = 10,
      height = 4.5
    )
  }

  p
}

make_segmented_trend_sensitivity_plot <- function(robustness_results, save_plot = FALSE) {
  rob_piecewise <- list(
    trend = robustness_results$trend %>%
      dplyr::filter(
        spec %in% c(
          "Base (AR(1), 1879-2024)",
          "Segmented AR(1), knot 1975 (post-knot slope)"
        )
      )
  )

  make_robustness_trend_plot(
    rob_piecewise,
    save_plot = save_plot,
    title = "Segmented vs Base Long-Run Trends (1975 Breakpoint)",
    filename = "model_robustness_trend_segmented_1975.jpg"
  )
}

make_influential_trend_sensitivity_plot <- function(robustness_results, save_plot = FALSE) {
  rob_influential <- list(
    trend = robustness_results$trend %>%
      dplyr::filter(
        spec %in% c(
          "Base (AR(1), 1879-2024)",
          "Excluding extreme years"
        )
      )
  )

  make_robustness_trend_plot(
    rob_influential,
    save_plot = save_plot,
    title = "Long-Run Trend Sensitivity to Influential Years",
    filename = "model_robustness_trend_excluding_extremes.jpg"
  )
}
