# purpose: Compute residual diagnostics and simple model-form comparisons for the long-run trend model.
# inputs: model_df from prepare_model_data(), containing year, season, metric, and temperature columns.
# outputs: Tibbles returned by the functions in this script. No files are written directly.
# how it is called: Sourced by reports/ST422_Professional_Technical_report.Rmd in the validation-sources chunk.

suppressPackageStartupMessages(library(nlme))

# Extract OLS residuals for the linear long-run trend model within each season-metric series.
compute_ols_trend_residuals <- function(model_df) {
  model_df %>%
    dplyr::arrange(metric, season, year) %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(function(df, key) {

      # Re-centre year within each series so the fitted trend matches the main model specification.
      g <- df %>% dplyr::arrange(year) %>%
        dplyr::mutate(year_c = year - mean(year, na.rm = TRUE))

      # Fit the OLS benchmark used for residual autocorrelation comparison.
      fit <- lm(temp_c ~ year_c, data = g)

      # Return residuals aligned to the original year index.
      tibble::tibble(year = g$year, resid_ols = residuals(fit))
    }) %>%
    dplyr::ungroup()
}

# Extract normalised GLS AR(1) residuals for the linear long-run trend model.
compute_gls_trend_residuals <- function(model_df) {
  model_df %>%
    dplyr::arrange(metric, season, year) %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(function(df, key) {

      # Match the centred-year specification used in the fitted GLS trend model.
      g <- df %>% dplyr::arrange(year) %>%
        dplyr::mutate(year_c = year - mean(year, na.rm = TRUE))

      # Fit the working AR(1) model and retain normalised residuals for Q-Q assessment.
      fit <- nlme::gls(
        temp_c ~ year_c,
        data        = g,
        correlation = nlme::corAR1(form = ~year),
        method      = "REML"
      )

      tibble::tibble(
        year      = g$year,
        resid_gls = residuals(fit, type = "normalized")
      )
    }) %>%
    dplyr::ungroup()
}

# Compute lag-1 autocorrelation for a supplied residual column within each series.
compute_acf_lag1 <- function(residuals_df, resid_col) {
  residuals_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::summarise(
      lag1_acf = {

        # Remove missing values before computing the first residual autocorrelation.
        x <- .data[[resid_col]]
        acf_vals <- stats::acf(x[!is.na(x)], lag.max = 1, plot = FALSE)
        as.numeric(acf_vals$acf)[2]
      },
      .groups = "drop"
    )
}

# Compare AR(1) and AR(2) dependence structures for the same linear trend specification.
compare_ar_orders <- function(model_df) {
  model_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(function(df, key) {

      # Use the same centred-year mean structure in both dependence specifications.
      g <- df %>% dplyr::arrange(year) %>%
        dplyr::mutate(year_c = year - mean(year, na.rm = TRUE))

      # Fit the two candidate dependence structures under maximum likelihood for AIC comparison.
      fit1 <- nlme::gls(
        temp_c ~ year_c, data = g,
        correlation = nlme::corAR1(form = ~year), method = "ML"
      )

      fit2 <- nlme::gls(
        temp_c ~ year_c, data = g,
        correlation = nlme::corARMA(form = ~year, p = 2, q = 0), method = "ML"
      )

      tibble::tibble(
        aic_ar1 = AIC(fit1),
        aic_ar2 = AIC(fit2),
        preferred = if_else(AIC(fit1) <= AIC(fit2), "AR(1)", "AR(2)")
      )
    }) %>%
    dplyr::ungroup()
}

# Compare linear and quadratic mean structures under the same AR(1) dependence model.
compare_trend_forms <- function(model_df) {
  model_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(function(df, key) {

      # Build centred linear and quadratic time terms for model-form comparison.
      g <- df %>% dplyr::arrange(year) %>%
        dplyr::mutate(
          year_c  = year - mean(year, na.rm = TRUE),
          year_c2 = year_c^2
        )

      # Fit both mean structures under the same AR(1) working correlation.
      fit_lin  <- nlme::gls(
        temp_c ~ year_c, data = g,
        correlation = nlme::corAR1(form = ~year), method = "ML"
      )

      fit_quad <- nlme::gls(
        temp_c ~ year_c + year_c2, data = g,
        correlation = nlme::corAR1(form = ~year), method = "ML"
      )

      tibble::tibble(
        aic_linear    = AIC(fit_lin),
        aic_quadratic = AIC(fit_quad),
        preferred     = if_else(AIC(fit_lin) <= AIC(fit_quad), "Linear", "Quadratic")
      )
    }) %>%
    dplyr::ungroup()
}
