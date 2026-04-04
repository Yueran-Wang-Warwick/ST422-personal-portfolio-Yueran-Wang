suppressPackageStartupMessages({
  library(dplyr)
  library(nlme)
})

# purpose:  Compare OLS, GLS AR(1), and GLS AR(2) under a common mean
#           structure for the baseline shift model and the long-run trend model.
#           The comparison is intended for model tuning and dependence-order
#           selection prior to robustness analysis.
# inputs:   model_df from prepare_model_data()
# outputs:  list of detail and summary tibbles returned by run_model_comparison()
# called by: reports/ST422_Professional_Technical_report.Rmd

safe_acf_lag <- function(x, lag = 1) {
  x <- x[is.finite(x)]
  if (length(x) <= lag) {
    return(NA_real_)
  }

  acf_obj <- stats::acf(x, lag.max = lag, plot = FALSE, na.action = na.pass)
  as.numeric(acf_obj$acf)[lag + 1]
}

safe_ljung_p <- function(x, lag = 4) {
  x <- x[is.finite(x)]
  if (length(x) <= (lag + 5)) {
    return(NA_real_)
  }
  out <- tryCatch(
    stats::Box.test(x, lag = lag, type = "Ljung-Box"),
    error = function(e) NULL
  )
  if (is.null(out)) {
    return(NA_real_)
  }
  as.numeric(out$p.value)
}

compute_rolling_rmse <- function(data_df, fit_fun, min_train = 30) {
  n <- nrow(data_df)
  if (n <= min_train) {
    return(NA_real_)
  }

  sq_err <- c()
  for (i in seq(min_train, n - 1)) {
    train_df <- data_df[1:i, , drop = FALSE]
    test_df  <- data_df[i + 1, , drop = FALSE]

    fit <- tryCatch(fit_fun(train_df), error = function(e) NULL)
    if (is.null(fit)) {
      next
    }

    pred <- tryCatch(as.numeric(predict(fit, newdata = test_df)), error = function(e) NA_real_)
    if (!is.finite(pred)) {
      next
    }

    err <- test_df$temp_c - pred
    if (is.finite(err)) {
      sq_err <- c(sq_err, err^2)
    }
  }

  if (length(sq_err) == 0) {
    return(NA_real_)
  }
  sqrt(mean(sq_err))
}

extract_lm_stats <- function(fit, coef_name, scale_factor = 1) {
  tt  <- summary(fit)$coefficients
  est <- tt[coef_name, "Estimate"]
  se  <- tt[coef_name, "Std. Error"]
  res <- stats::residuals(fit)

  tibble::tibble(
    estimate   = est * scale_factor,
    lower      = (est - 1.96 * se) * scale_factor,
    upper      = (est + 1.96 * se) * scale_factor,
    ci_width   = 2 * 1.96 * se * scale_factor,
    aic        = AIC(fit),
    bic        = BIC(fit),
    lag1_acf   = safe_acf_lag(res, lag = 1),
    lag2_acf   = safe_acf_lag(res, lag = 2),
    ljung_p_lag4 = safe_ljung_p(res, lag = 4),
    rolling_rmse = NA_real_,
    rolling_nrmse = NA_real_,
    phi1       = NA_real_,
    phi2       = NA_real_,
    converged  = TRUE
  )
}

extract_gls_stats <- function(fit, coef_name, scale_factor = 1) {
  tt   <- summary(fit)$tTable
  est  <- tt[coef_name, "Value"]
  se   <- tt[coef_name, "Std.Error"]
  res  <- residuals(fit, type = "normalized")
  phi  <- as.numeric(coef(fit$modelStruct$corStruct, unconstrained = FALSE))
  phi1 <- if (length(phi) >= 1) phi[1] else NA_real_
  phi2 <- if (length(phi) >= 2) phi[2] else NA_real_

  tibble::tibble(
    estimate   = est * scale_factor,
    lower      = (est - 1.96 * se) * scale_factor,
    upper      = (est + 1.96 * se) * scale_factor,
    ci_width   = 2 * 1.96 * se * scale_factor,
    aic        = AIC(fit),
    bic        = BIC(fit),
    lag1_acf   = safe_acf_lag(res, lag = 1),
    lag2_acf   = safe_acf_lag(res, lag = 2),
    ljung_p_lag4 = safe_ljung_p(res, lag = 4),
    rolling_rmse = NA_real_,
    rolling_nrmse = NA_real_,
    phi1       = phi1,
    phi2       = phi2,
    converged  = TRUE
  )
}

compare_one_series <- function(df_group, model_type = c("shift", "trend")) {
  model_type <- match.arg(model_type)

  if (model_type == "shift") {
    g <- df_group %>%
      dplyr::filter(!is.na(period)) %>%
      dplyr::arrange(year) %>%
      dplyr::mutate(period = factor(period, levels = c("historical", "recent")))
    formula_obj  <- temp_c ~ period
    coef_name    <- "periodrecent"
    scale_factor <- 1
  } else {
    g <- df_group %>%
      dplyr::arrange(year) %>%
      dplyr::mutate(year_c = year - mean(year, na.rm = TRUE))
    formula_obj  <- temp_c ~ year_c
    coef_name    <- "year_c"
    scale_factor <- 10
  }

  fit_ols <- tryCatch(
    lm(formula_obj, data = g),
    error = function(e) NULL
  )

  fit_ar1 <- tryCatch(
    nlme::gls(
      formula_obj,
      data        = g,
      correlation = nlme::corAR1(form = ~year),
      method      = "ML",
      control     = nlme::glsControl(msMaxIter = 200)
    ),
    error = function(e) NULL
  )

  fit_ar2 <- tryCatch(
    nlme::gls(
      formula_obj,
      data        = g,
      correlation = nlme::corARMA(form = ~year, p = 2, q = 0),
      method      = "ML",
      control     = nlme::glsControl(msMaxIter = 200)
    ),
    error = function(e) NULL
  )

  out_ols <- if (is.null(fit_ols)) {
    tibble::tibble(
      specification = "OLS",
      estimate = NA_real_, lower = NA_real_, upper = NA_real_, ci_width = NA_real_,
      aic = NA_real_, bic = NA_real_, lag1_acf = NA_real_, lag2_acf = NA_real_,
      ljung_p_lag4 = NA_real_,
      rolling_rmse = NA_real_,
      rolling_nrmse = NA_real_,
      phi1 = NA_real_, phi2 = NA_real_, converged = FALSE
    )
  } else {
    extract_lm_stats(fit_ols, coef_name, scale_factor) %>%
      dplyr::mutate(specification = "OLS", .before = 1)
  }

  out_ar1 <- if (is.null(fit_ar1)) {
    tibble::tibble(
      specification = "GLS AR(1)",
      estimate = NA_real_, lower = NA_real_, upper = NA_real_, ci_width = NA_real_,
      aic = NA_real_, bic = NA_real_, lag1_acf = NA_real_, lag2_acf = NA_real_,
      ljung_p_lag4 = NA_real_,
      rolling_rmse = NA_real_,
      rolling_nrmse = NA_real_,
      phi1 = NA_real_, phi2 = NA_real_, converged = FALSE
    )
  } else {
    extract_gls_stats(fit_ar1, coef_name, scale_factor) %>%
      dplyr::mutate(specification = "GLS AR(1)", .before = 1)
  }

  out_ar2 <- if (is.null(fit_ar2)) {
    tibble::tibble(
      specification = "GLS AR(2)",
      estimate = NA_real_, lower = NA_real_, upper = NA_real_, ci_width = NA_real_,
      aic = NA_real_, bic = NA_real_, lag1_acf = NA_real_, lag2_acf = NA_real_,
      ljung_p_lag4 = NA_real_,
      rolling_rmse = NA_real_,
      rolling_nrmse = NA_real_,
      phi1 = NA_real_, phi2 = NA_real_, converged = FALSE
    )
  } else {
    extract_gls_stats(fit_ar2, coef_name, scale_factor) %>%
      dplyr::mutate(specification = "GLS AR(2)", .before = 1)
  }

  if (model_type == "trend") {
    rmse_ols <- compute_rolling_rmse(
      g,
      fit_fun = function(train_df) lm(formula_obj, data = train_df),
      min_train = 30
    )
    rmse_ar1 <- compute_rolling_rmse(
      g,
      fit_fun = function(train_df) {
        nlme::gls(
          formula_obj,
          data        = train_df,
          correlation = nlme::corAR1(form = ~year),
          method      = "ML",
          control     = nlme::glsControl(msMaxIter = 200)
        )
      },
      min_train = 30
    )
    rmse_ar2 <- compute_rolling_rmse(
      g,
      fit_fun = function(train_df) {
        nlme::gls(
          formula_obj,
          data        = train_df,
          correlation = nlme::corARMA(form = ~year, p = 2, q = 0),
          method      = "ML",
          control     = nlme::glsControl(msMaxIter = 200)
        )
      },
      min_train = 30
    )

    series_sd <- stats::sd(g$temp_c, na.rm = TRUE)
    nrmse_ols <- if (is.finite(series_sd) && series_sd > 0) rmse_ols / series_sd else NA_real_
    nrmse_ar1 <- if (is.finite(series_sd) && series_sd > 0) rmse_ar1 / series_sd else NA_real_
    nrmse_ar2 <- if (is.finite(series_sd) && series_sd > 0) rmse_ar2 / series_sd else NA_real_

    out_ols <- out_ols %>% dplyr::mutate(rolling_rmse = rmse_ols, rolling_nrmse = nrmse_ols)
    out_ar1 <- out_ar1 %>% dplyr::mutate(rolling_rmse = rmse_ar1, rolling_nrmse = nrmse_ar1)
    out_ar2 <- out_ar2 %>% dplyr::mutate(rolling_rmse = rmse_ar2, rolling_nrmse = nrmse_ar2)
  }

  dplyr::bind_rows(out_ols, out_ar1, out_ar2)
}

run_family_model_comparison <- function(model_df,
                                        model_type = c("shift", "trend"),
                                        year_min = NULL,
                                        year_max = NULL) {
  model_type <- match.arg(model_type)

  if (!is.null(year_min)) {
    model_df <- model_df %>% dplyr::filter(year >= year_min)
  }
  if (!is.null(year_max)) {
    model_df <- model_df %>% dplyr::filter(year <= year_max)
  }

  detail_tbl <- model_df %>%
    dplyr::group_by(metric, season) %>%
    dplyr::group_modify(~ compare_one_series(.x, model_type = model_type)) %>%
    dplyr::ungroup()

  summary_tbl <- detail_tbl %>%
    dplyr::group_by(specification) %>%
    dplyr::summarise(
      n_series                = sum(!is.na(aic)),
      mean_aic                = mean(aic, na.rm = TRUE),
      mean_bic                = mean(bic, na.rm = TRUE),
      mean_ci_width           = mean(ci_width, na.rm = TRUE),
      mean_rolling_rmse       = if (all(is.na(rolling_rmse))) NA_real_ else mean(rolling_rmse, na.rm = TRUE),
      mean_rolling_nrmse      = if (all(is.na(rolling_nrmse))) NA_real_ else mean(rolling_nrmse, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    dplyr::mutate(
      specification = factor(specification, levels = c("OLS", "GLS AR(1)", "GLS AR(2)"))
    ) %>%
    dplyr::arrange(specification)

  list(detail = detail_tbl, summary = summary_tbl)
}

format_model_comparison_summary <- function(summary_tbl, digits = 3) {
  fmt_num <- function(x) {
    out <- rep("NA", length(x))
    ok <- is.finite(x)
    out[ok] <- formatC(x[ok], digits = digits, format = "f")
    out
  }

  out <- summary_tbl %>%
    dplyr::mutate(
      specification = dplyr::recode(
        as.character(specification),
        "OLS" = "OLS",
        "GLS AR(1)" = "AR(1)",
        "GLS AR(2)" = "AR(2)"
      ),
      mean_aic          = fmt_num(mean_aic),
      mean_bic          = fmt_num(mean_bic),
      mean_ci_width     = fmt_num(mean_ci_width),
      mean_rolling_rmse = fmt_num(mean_rolling_rmse),
      mean_rolling_nrmse = fmt_num(mean_rolling_nrmse)
    )

  out <- out %>%
    dplyr::select(
      specification,
      mean_aic,
      mean_bic,
      mean_ci_width,
      mean_rolling_rmse,
      mean_rolling_nrmse
    ) %>%
    dplyr::rename(
      Model                = specification,
      `Avg AIC`            = mean_aic,
      `Avg BIC`            = mean_bic,
      `Avg CI width`       = mean_ci_width,
      `Avg roll RMSE`      = mean_rolling_rmse,
      `Avg roll NRMSE (RMSE/SD)` = mean_rolling_nrmse
    )

  out
}

run_model_comparison <- function(model_df) {
  shift_comp <- run_family_model_comparison(model_df, model_type = "shift")
  trend_comp <- run_family_model_comparison(model_df, model_type = "trend")

  list(
    shift_detail  = shift_comp$detail,
    shift_summary = shift_comp$summary,
    trend_detail  = trend_comp$detail,
    trend_summary = trend_comp$summary
  )
}
