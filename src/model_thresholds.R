# purpose:  Compute monitoring thresholds from the 1991-2020 reference window
#           for each season-metric combination, expressed as the 10th, 50th,
#           and 90th percentiles of the observed seasonal temperature distribution.
# inputs:   eda_load_hadcet_long() (via eda_utils.R)
# outputs:  tibble returned by compute_monitoring_thresholds()
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

compute_monitoring_thresholds <- function(recent_start = 1991,
                                          recent_end   = 2020) {
  eda_load_hadcet_long(include_annual = FALSE, year_min = 1879) %>%
    dplyr::filter(year >= recent_start, year <= recent_end) %>%
    dplyr::group_by(metric, season) %>%
    dplyr::summarise(
      p10 = quantile(temp_c, 0.10, na.rm = TRUE),
      p50 = quantile(temp_c, 0.50, na.rm = TRUE),
      p90 = quantile(temp_c, 0.90, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
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
