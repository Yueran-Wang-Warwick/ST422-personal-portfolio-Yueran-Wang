# purpose:  Fit GLS AR(1) models for baseline shift and long-run trend,
#           separately for each season-metric combination.
#           Shift model: period indicator (recent vs historical) as regressor.
#           Trend model: centred year as regressor over full 1879-2024 series.
# inputs:   processed/data_mean_cleaned.csv
#           processed/data_min_cleaned.csv
#           processed/data_max_cleaned.csv  (via eda_load_hadcet_long)
# outputs:  list(shift = tbl, trend = tbl, rho = tbl) returned by run_gls_models()
# called by: reports/ST422_Professional_Technical_report.Rmd (model-sources chunk)

suppressPackageStartupMessages({
  library(dplyr)
  library(nlme)
})

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
      period = dplyr::case_when(
        year >= historical_start & year <= historical_end ~ "historical",
        year >= recent_start     & year <= recent_end     ~ "recent",
        TRUE                                              ~ NA_character_
      ),
      season = factor(season, levels = c("winter", "spring", "summer", "autumn")),
      metric = factor(metric, levels = c("mean", "min", "max"))
    )
}

fit_shift_one <- function(df_group) {
  g <- df_group %>%
    filter(!is.na(period)) %>%
    arrange(year) %>%
    mutate(period = factor(period, levels = c("historical", "recent")))

  fit <- nlme::gls(
    temp_c ~ period,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

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

fit_trend_one <- function(df_group) {
  g <- df_group %>%
    arrange(year) %>%
    mutate(year_c = year - mean(year, na.rm = TRUE))

  fit <- nlme::gls(
    temp_c ~ year_c,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

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

run_gls_models <- function(model_df) {
  shift_tbl <- model_df %>%
    group_by(metric, season) %>%
    group_modify(~fit_shift_one(.x)) %>%
    ungroup()

  trend_tbl <- model_df %>%
    group_by(metric, season) %>%
    group_modify(~fit_trend_one(.x)) %>%
    ungroup()

  rho_tbl <- shift_tbl %>%
    select(metric, season, rho_shift) %>%
    left_join(
      trend_tbl %>% select(metric, season, rho_trend),
      by = c("metric", "season")
    ) %>%
    mutate(rho_avg = (rho_shift + rho_trend) / 2)

  list(shift = shift_tbl, trend = trend_tbl, rho = rho_tbl)
}
