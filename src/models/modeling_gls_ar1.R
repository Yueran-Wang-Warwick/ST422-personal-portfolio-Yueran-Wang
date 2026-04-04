# purpose: Fit the main GLS AR(1) baseline-shift and long-run trend models for each season-metric series.
# inputs: Cleaned HadCET data loaded through eda_load_hadcet_long() and the historical and recent window settings.
# outputs: A list containing shift, trend, and rho summary tibbles returned by run_gls_models().
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the model-sources chunk.

suppressPackageStartupMessages({
  library(dplyr)
  library(nlme)
})

# Build the modelling dataset with consistent season, metric, and baseline-window labels.
prepare_model_data <- function(
  year_min        = 1879,
  year_max        = 2024,
  historical_start = 1961,
  historical_end   = 1990,
  recent_start     = 1991,
  recent_end       = 2020
) {
  eda_load_hadcet_long(include_annual = FALSE, year_min = year_min, year_max = year_max) %>%
    mutate(
      # Classify each year into the historical and recent comparison windows.
      period = dplyr::case_when(
        year >= historical_start & year <= historical_end ~ "historical",
        year >= recent_start     & year <= recent_end     ~ "recent",
        TRUE                                              ~ NA_character_
      ),
      season = factor(season, levels = c("winter", "spring", "summer", "autumn")),
      metric = factor(metric, levels = c("mean", "min", "max"))
    )
}

# Fit one GLS AR(1) baseline-shift model for a single season-metric series.
fit_shift_one <- function(df_group) {
  # Restrict the data to the two comparison windows used in the shift model.
  g <- df_group %>%
    filter(!is.na(period)) %>%
    arrange(year) %>%
    mutate(period = factor(period, levels = c("historical", "recent")))

  # Fit the baseline-shift model with an AR(1) working correlation.
  fit <- nlme::gls(
    temp_c ~ period,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

  # Extract the recent-minus-historical contrast, its interval, and the fitted rho value.
  tt  <- summary(fit)$tTable
  est <- tt["periodrecent", "Value"]
  se  <- tt["periodrecent", "Std.Error"]
  rho <- as.numeric(coef(fit$modelStruct$corStruct, unconstrained = FALSE))

  data.frame(
    shift     = est,
    lower     = est - 1.96 * se,
    upper     = est + 1.96 * se,
    rho_shift = rho
  )
}

# Fit one GLS AR(1) long-run trend model for a single season-metric series.
fit_trend_one <- function(df_group) {
  # Centre year within the full series so the slope is interpretable and stable.
  g <- df_group %>%
    arrange(year) %>%
    mutate(year_c = year - mean(year, na.rm = TRUE))

  # Fit the long-run linear trend under the same AR(1) dependence structure.
  fit <- nlme::gls(
    temp_c ~ year_c,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

  # Convert the annual slope and interval into degrees Celsius per decade.
  tt   <- summary(fit)$tTable
  beta <- tt["year_c", "Value"]
  se   <- tt["year_c", "Std.Error"]
  rho  <- as.numeric(coef(fit$modelStruct$corStruct, unconstrained = FALSE))

  data.frame(
    trend_decade = beta * 10,
    lower        = (beta - 1.96 * se) * 10,
    upper        = (beta + 1.96 * se) * 10,
    rho_trend    = rho
  )
}

# Run both GLS model families across all season-metric combinations and collect their summaries.
run_gls_models <- function(model_df) {
  # Fit the baseline-shift model for each series.
  shift_tbl <- model_df %>%
    group_by(metric, season) %>%
    group_modify(~fit_shift_one(.x)) %>%
    ungroup()

  # Fit the long-run trend model for each series.
  trend_tbl <- model_df %>%
    group_by(metric, season) %>%
    group_modify(~fit_trend_one(.x)) %>%
    ungroup()

  # Combine the two rho summaries so they can be plotted in one chart later.
  rho_tbl <- shift_tbl %>%
    select(metric, season, rho_shift) %>%
    left_join(
      trend_tbl %>% select(metric, season, rho_trend),
      by = c("metric", "season")
    ) %>%
    mutate(rho_avg = (rho_shift + rho_trend) / 2)

  list(shift = shift_tbl, trend = trend_tbl, rho = rho_tbl)
}
