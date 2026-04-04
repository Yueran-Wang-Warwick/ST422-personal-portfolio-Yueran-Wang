# purpose:  Plot rolling 30-year warming rates through time by season and
#           temperature type, expressed in degrees Celsius per decade.
# inputs:   processed/data_mean_cleaned.csv
#           processed/data_min_cleaned.csv
#           processed/data_max_cleaned.csv  (via eda_load_hadcet_long)
# outputs:  outputs/figures/eda_rolling_30y_warming_rate_curve.jpg (save_plot = TRUE)
# called by: reports/ST422_Professional_Technical_report.Rmd (eda-sources chunk)

eda_rolling_slope_decade <- function(x, years, window = 30) {
  n <- length(x)
  out <- rep(NA_real_, n)

  if (n < window) {
    return(out)
  }

  for (i in seq(window, n)) {
    idx <- (i - window + 1):i
    fit <- stats::lm(x[idx] ~ years[idx])
    out[i] <- unname(stats::coef(fit)[2]) * 10
  }

  out
}

make_eda_warming_rate_curve_plot <- function(save_plot = FALSE, window = 30) {
  rate_df <- eda_load_hadcet_long(include_annual = FALSE, year_min = 1879, year_max = 2024) %>%
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
    mutate(rolling_rate_decade = eda_rolling_slope_decade(temp_c, year, window = window)) %>%
    ungroup()

  p <- ggplot(
    dplyr::filter(rate_df, !is.na(rolling_rate_decade)),
    aes(x = year, y = rolling_rate_decade, colour = metric_label)
  ) +
    geom_hline(yintercept = 0, colour = "#CBD5E1", linewidth = 0.4) +
    geom_line(linewidth = 0.9, alpha = 0.8) +
    facet_wrap(~ season_label, ncol = 2) +
    scale_colour_manual(
      values = setNames(eda_metric_palette, c("Mean", "Minimum", "Maximum")),
      name = NULL
    ) +
    labs(
      title = "Rolling 30-Year Warming Rates",
      x = "Year",
      y = "Estimated warming rate (degC per decade)"
    ) +
    eda_base_theme()

  if (save_plot) {
    eda_save_plot(p, "eda_rolling_30y_warming_rate_curve.jpg", width = 11.4, height = 7.8)
  }

  p
}
