# purpose:  Plot raw annual HadCET temperature records (1879-2024) by season,
#           with rolling 30-year mean lines (mean/min/max) overlaid and the two
#           baseline comparison windows shaded, so that the long-run drift and
#           the window placement can be assessed together in a single view.
# inputs:   processed/data_mean_cleaned.csv
#           processed/data_min_cleaned.csv
#           processed/data_max_cleaned.csv  (via eda_load_hadcet_long)
# outputs:  outputs/figures/eda_annotated_series_1879_2024.jpg (save_plot = TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (eda-sources chunk)

make_eda_annotated_series_plot <- function(save_plot = FALSE) {
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

  windows_df <- tibble::tibble(
    xmin  = c(1961, 1991),
    xmax  = c(1990, 2020),
    label = factor(c("1961-1990", "1991-2020"))
  )

  window_fills <- c(
    "1961-1990" = unname(eda_period_palette["historical"]),
    "1991-2020" = unname(eda_period_palette["recent"])
  )

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
    eda_save_plot(p, "eda_annotated_series_1879_2024.jpg", width = 11, height = 4.5)
  }

  p
}
