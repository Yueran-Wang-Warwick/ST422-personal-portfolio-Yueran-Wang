# purpose:  Build a concise material-change rule table for internal briefing.
# inputs:   none
# outputs:  tibble returned by make_threshold_table()
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

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

make_monitoring_thresholds_comparison_table <- function(
  thresholds_30,
  thresholds_10,
  digits = 2
) {
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

  thresholds_30_fmt <- fmt_thresholds(thresholds_30) %>%
    dplyr::rename(
      `P10 (30y)` = P10,
      `P50 (30y)` = P50,
      `P90 (30y)` = P90
    )

  thresholds_10_fmt <- fmt_thresholds(thresholds_10) %>%
    dplyr::rename(
      `P10 (10y)` = P10,
      `P50 (10y)` = P50,
      `P90 (10y)` = P90
    )

  thresholds_30_fmt %>%
    dplyr::left_join(thresholds_10_fmt, by = c("Season", "Metric"))
}
