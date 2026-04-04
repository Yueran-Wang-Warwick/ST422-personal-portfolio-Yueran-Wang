# purpose: Build small reference tables for the internal monitoring framework section of the report.
# inputs: None.
# outputs: Tibbles returned by make_monitoring_framework_table() and make_baseline_window_table().
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

# Build the table that explains which seasonal metrics should be reported internally.
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

# Build the table that explains how different recent baseline windows are used.
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
