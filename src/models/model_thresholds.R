# purpose: Compute monitoring thresholds from a recent reference window for each season-metric combination.
# inputs: Cleaned HadCET data loaded through eda_load_hadcet_long() and the chosen recent window start and end years.
# outputs: A tibble of p10 and p90 thresholds returned by compute_monitoring_thresholds().
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Compute p10 and p90 monitoring thresholds for each season and metric.
compute_monitoring_thresholds <- function(recent_start = 1991,
                                          recent_end   = 2020) {
  eda_load_hadcet_long(include_annual = FALSE, year_min = 1879) %>%

    # Restrict the data to the recent reference window used for monitoring.
    dplyr::filter(year >= recent_start, year <= recent_end) %>%
    dplyr::group_by(metric, season) %>%
    dplyr::summarise(
      p10 = quantile(temp_c, 0.10, na.rm = TRUE),
      p90 = quantile(temp_c, 0.90, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      # Add presentation labels for report tables and briefing outputs.
      season_label = factor(
        eda_season_label(season),
        levels = c("Winter", "Spring", "Summer", "Autumn")
      ),
      metric_label = factor(
        eda_metric_label(metric),
        levels = c("Mean", "Minimum", "Maximum")
      )
    ) %>%
    dplyr::arrange(season_label, metric_label)
}
