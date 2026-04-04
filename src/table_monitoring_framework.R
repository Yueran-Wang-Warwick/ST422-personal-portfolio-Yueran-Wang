# purpose:  Build compact tables for internal briefing on:
#           (1) core monitoring metrics to report
#           (2) role of 10/20/30-year baseline windows
# inputs:   none
# outputs:  tibbles returned by make_monitoring_framework_table() and
#           make_baseline_window_table()
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

make_monitoring_framework_table <- function() {
  tibble::tribble(
    ~`Metric reported`, ~`Role in internal briefing`,
    "Seasonal mean temperature",
    "Primary indicator of overall seasonal level relative to the recent climate baseline",
    "Seasonal minimum temperature",
    "Lower-tail context: indicates whether cool-end seasonal conditions are shifting with the mean",
    "Seasonal maximum temperature",
    "Upper-tail context: indicates whether warm-end seasonal conditions are shifting more strongly than the mean"
  )
}

make_baseline_window_table <- function() {
  tibble::tribble(
    ~`Recent window`, ~`Operational role`, ~`Used for formal decision statement`,
    "30-year (1991-2020)",
    "Primary decision baseline and threshold reference",
    "Yes",
    "20-year",
    "Secondary context window for transition monitoring",
    "No",
    "10-year",
    "Short-horizon surveillance signal for recent acceleration checks",
    "No"
  )
}
