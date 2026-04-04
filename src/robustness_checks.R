# purpose:  Run targeted robustness checks against the primary GLS AR(1)
#           results: (1) segmented linear trend sensitivity with a fixed 1975
#           breakpoint, (2) exclusion of flagged extreme year-season observations.
# inputs:   eda_load_hadcet_long() for raw data; base model_results for comparison
# outputs:  named list of tibbles returned by run_all_robustness_checks()
# called by: reports/ST422_Professional_Technical_report.Rmd (validation-sources chunk)

suppressPackageStartupMessages(library(nlme))

# --------------------------------------------------------------------------- #
# 1. Segmented linear trend with fixed breakpoint at 1975
# --------------------------------------------------------------------------- #

fit_piecewise_trend_one <- function(df_group, knot_year = 1975) {
  g <- df_group %>%
    dplyr::arrange(year) %>%
    dplyr::mutate(
      year_c = year - mean(year, na.rm = TRUE),
      post_knot = pmax(year - knot_year, 0)
    )

  fit <- nlme::gls(
    temp_c ~ year_c + post_knot,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

  tt <- summary(fit)$tTable

  b1 <- tt["year_c", "Value"]
  b2 <- tt["post_knot", "Value"]
  rho <- as.numeric(coef(fit$modelStruct$corStruct, unconstrained = FALSE))

  vc_fix <- as.matrix(vcov(fit))
  var_b1 <- vc_fix["year_c", "year_c"]
  var_b2 <- vc_fix["post_knot", "post_knot"]
  cov_b1b2 <- vc_fix["year_c", "post_knot"]

  slope_post <- b1 + b2
  se_post <- sqrt(var_b1 + var_b2 + 2 * cov_b1b2)

  data.frame(
    trend_decade = slope_post * 10,
    lower        = (slope_post - 1.96 * se_post) * 10,
    upper        = (slope_post + 1.96 * se_post) * 10,
    rho_trend    = rho
  )
}

run_robustness_piecewise_trend <- function(model_df, knot_year = 1975) {
  model_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(~fit_piecewise_trend_one(.x, knot_year = knot_year)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(spec = paste0("Segmented AR(1), knot ", knot_year, " (post-knot slope)"))
}

# --------------------------------------------------------------------------- #
# 2. Exclude flagged extreme year-season observations
# --------------------------------------------------------------------------- #

# Flagged extreme year-season pairs identified during EDA screening:
#   1963 winter (anomalously cold), 1976 summer (anomalously hot),
#   2006 autumn, 2022 autumn, 2023 autumn (anomalously warm)
extreme_obs <- tibble::tibble(
  year   = c(1963, 1976, 2006, 2022, 2023),
  season = c("winter", "summer", "autumn", "autumn", "autumn")
)

run_robustness_excl_extremes <- function(model_df) {
  clean_df <- model_df %>%
    dplyr::anti_join(extreme_obs, by = c("year", "season"))

  results <- run_gls_models(clean_df)

  list(
    shift = results$shift %>%
      dplyr::mutate(spec = "Excluding extreme years"),
    trend = results$trend %>%
      dplyr::mutate(spec = "Excluding extreme years")
  )
}

# --------------------------------------------------------------------------- #
# Combined runner
# --------------------------------------------------------------------------- #

run_all_robustness_checks <- function(model_df, base_results) {
  pw_trend <- run_robustness_piecewise_trend(model_df, knot_year = 1975)
  excl     <- run_robustness_excl_extremes(model_df)

  base_shift <- base_results$shift %>%
    dplyr::mutate(spec = "Base (AR(1), client windows)")
  base_trend <- base_results$trend %>%
    dplyr::mutate(spec = "Base (AR(1), 1879-2024)")

  list(
    shift = dplyr::bind_rows(base_shift, excl$shift),
    trend = dplyr::bind_rows(
      base_trend,
      pw_trend,
      excl$trend
    )
  )
}
