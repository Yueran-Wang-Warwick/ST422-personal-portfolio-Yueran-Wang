# purpose: Run targeted robustness checks for the main GLS AR(1) results under alternative trend and sample specifications.
# inputs: model_df prepared for the main analysis and base_results from run_gls_models() for comparison.
# outputs: A named list of robustness summary tibbles returned by run_all_robustness_checks().
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the validation-sources chunk.

suppressPackageStartupMessages(library(nlme))

# Fit a piecewise linear trend with a fixed breakpoint and return the post-break slope summary.
fit_piecewise_trend_one <- function(df_group, knot_year = 1975) {
  # Construct the centred time term and the post-break increment term.
  g <- df_group %>%
    dplyr::arrange(year) %>%
    dplyr::mutate(
      year_c = year - mean(year, na.rm = TRUE),
      post_knot = pmax(year - knot_year, 0)
    )

  # Fit the piecewise trend under the same AR(1) dependence structure as the main model.
  fit <- nlme::gls(
    temp_c ~ year_c + post_knot,
    data        = g,
    correlation = nlme::corAR1(form = ~year),
    method      = "REML"
  )

  # Recover the post-break slope and its standard error from the fitted coefficient matrix.
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

# Run the segmented-trend sensitivity check for every season-metric combination.
run_robustness_piecewise_trend <- function(model_df, knot_year = 1975) {
  model_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(~ fit_piecewise_trend_one(.x, knot_year = knot_year)) %>%
    dplyr::ungroup() %>%
    dplyr::mutate(spec = paste0("Segmented AR(1), knot ", knot_year, " (post-knot slope)"))
}

# Store the flagged influential year-season observations identified in EDA.
extreme_obs <- tibble::tibble(
  year   = c(1963, 1976, 2006, 2022, 2023),
  season = c("winter", "summer", "autumn", "autumn", "autumn")
)

# Refit the main GLS models after excluding the flagged influential observations.
run_robustness_excl_extremes <- function(model_df) {
  # Remove the flagged year-season pairs before refitting the main model set.
  clean_df <- model_df %>%
    dplyr::anti_join(extreme_obs, by = c("year", "season"))

  # Reuse the main model runner so the sensitivity check stays comparable to the base results.
  results <- run_gls_models(clean_df)

  list(
    shift = results$shift %>%
      dplyr::mutate(spec = "Excluding extreme years"),
    trend = results$trend %>%
      dplyr::mutate(spec = "Excluding extreme years")
  )
}

# Combine the base results with the segmented-trend and extreme-year sensitivity checks.
run_all_robustness_checks <- function(model_df, base_results) {
  # Run the two targeted robustness checks.
  pw_trend <- run_robustness_piecewise_trend(model_df, knot_year = 1975)
  excl     <- run_robustness_excl_extremes(model_df)

  # Label the base model outputs so they can be plotted alongside the alternatives.
  base_shift <- base_results$shift %>%
    dplyr::mutate(spec = "Base (AR(1), client windows)")

  base_trend <- base_results$trend %>%
    dplyr::mutate(spec = "Base (AR(1), 1879-2024)")

  # Return the combined robustness objects in the same list structure used downstream.
  list(
    shift = dplyr::bind_rows(base_shift, excl$shift),
    trend = dplyr::bind_rows(
      base_trend,
      pw_trend,
      excl$trend
    )
  )
}
