# purpose: Plot annual seasonal temperature trajectories with rolling means and shaded baseline windows.
# inputs: Cleaned HadCET data loaded through eda_load_hadcet_long().
# outputs: A ggplot object and an optional saved figure in outputs/figures/eda_annotated_series_1879_2024.jpg.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the eda-sources chunk.

# Build the annotated series plot used to show long-run movement and baseline window placement.
make_eda_annotated_series_plot <- function(save_plot = FALSE) {
  # Load the season-level data and add report-ready facet and legend labels.
  df <- eda_load_hadcet_long(include_annual = FALSE, year_min = 1879) %>%
    mutate(
      season_label = factor(
        eda_season_label(season),
        levels = c("Winter", "Spring", "Summer", "Autumn")
      ),
      metric_label = factor(
        eda_metric_label(metric),
        levels = c("Mean", "Minimum", "Maximum")
      )
    ) %>%
    arrange(metric, season, year) %>%
    group_by(metric, season) %>%
    mutate(rolling_mean = eda_rolling_mean(temp_c, window = 30)) %>%
    ungroup()

  metric_colours <- setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum"))

  # Define the two baseline windows highlighted in the figure background.
  windows_df <- tibble::tibble(
    xmin  = c(1961, 1991),
    xmax  = c(1990, 2020),
    label = factor(c("1961-1990", "1991-2020"))
  )

  window_fills <- c(
    "1961-1990" = unname(eda_period_palette["historical"]),
    "1991-2020" = unname(eda_period_palette["recent"])
  )

  # Draw raw points, rolling means, and shaded baseline windows in one view.
  p <- ggplot(df, aes(x = year, y = temp_c, colour = metric_label)) +
    geom_rect(
      data        = windows_df,
      aes(xmin = xmin, xmax = xmax, ymin = -Inf, ymax = Inf, fill = label),
      inherit.aes = FALSE,
      alpha       = 0.18
    ) +
    geom_point(size = 0.35, alpha = 0.20) +
    geom_line(
      data      = dplyr::filter(df, !is.na(rolling_mean)),
      aes(y     = rolling_mean),
      linewidth = 0.85
    ) +
    facet_wrap(~ season_label, nrow = 1) +
    scale_colour_manual(values = metric_colours, name = NULL) +
    scale_fill_manual(values = window_fills, name = "Baseline window") +
    labs(
      title = "Seasonal Temperature Trajectories and Baseline Windows",
      x = "Year",
      y = "Temperature (degC)"
    ) +
    eda_base_theme() +
    theme(
      panel.spacing   = unit(0.6, "lines"),
      legend.position = "bottom"
    )

  if (save_plot) {

    # Save the annotated trajectory plot to the standard figures directory.
    eda_save_plot(p, "eda_annotated_series_1879_2024.jpg", width = 11, height = 4.5)
  }

  p
}
