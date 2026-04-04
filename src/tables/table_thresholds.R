# purpose: Build threshold reference tables for internal monitoring and briefing.
# inputs: None for make_threshold_table(), and 30-year and 10-year threshold tibbles for the comparison table.
# outputs: Tibbles returned by make_threshold_table() and make_monitoring_thresholds_comparison_table().
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the compact material-change rule table used in the monitoring section.
make_threshold_table <- function() {
  tibble::tribble(
    ~`Status level`, ~`Trigger relative to 1991-2020 seasonal distribution`, ~`Planning action`,
    "Reference",
    "Within p10 to p90; p50 used as centreline for communication",
    "Continue routine monitoring",
    "Watch",
    "Single-season value outside p10 or p90",
    "Flag in briefing and track next season",
    "Action",
    "Two consecutive seasons outside p10/p90, or single-season breach beyond p05/p95",
    "Escalate to planning review with seasonal impact note",
    "Escalation",
    "At least two of mean/min/max reach Action status in the same season",
    "Trigger internal planning memo and cross-team response discussion"
  )
}

# Build the combined 30-year versus 10-year monitoring-threshold comparison table.
make_monitoring_thresholds_comparison_table <- function(
  thresholds_30,
  thresholds_10,
  digits = 2
) {
  # Round and relabel one threshold table before it is merged with the other window.
  fmt_thresholds <- function(df) {
    df %>%
      dplyr::select(season_label, metric_label, p10, p50, p90) %>%
      dplyr::mutate(
        p10 = round(p10, digits),
        p50 = round(p50, digits),
        p90 = round(p90, digits)
      ) %>%
      dplyr::rename(
        Season = season_label,
        Metric = metric_label,
        P10 = p10,
        P50 = p50,
        P90 = p90
      )
  }

  # Label the 30-year threshold columns before joining.
  thresholds_30_fmt <- fmt_thresholds(thresholds_30) %>%
    dplyr::rename(
      `P10 (30y)` = P10,
      `P50 (30y)` = P50,
      `P90 (30y)` = P90
    )

  # Label the 10-year threshold columns before joining.
  thresholds_10_fmt <- fmt_thresholds(thresholds_10) %>%
    dplyr::rename(
      `P10 (10y)` = P10,
      `P50 (10y)` = P50,
      `P90 (10y)` = P90
    )

  # Join the two windows into one comparison table keyed by season and metric.
  thresholds_30_fmt %>%
    dplyr::left_join(thresholds_10_fmt, by = c("Season", "Metric"))
}
