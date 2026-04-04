make_eda_distribution_shift_plot <- function(
  save_plot = FALSE,
  historical_start = 1961,
  historical_end = 1990,
  recent_start = 1991,
  recent_end = 2020
) {
  dist_df <- eda_load_hadcet_long(include_annual = FALSE, year_min = 1879, year_max = 2024) %>%
    mutate(
      period = case_when(
        year >= historical_start & year <= historical_end ~ "historical",
        year >= recent_start & year <= recent_end ~ "recent",
        TRUE ~ NA_character_
      ),
      period = factor(period, levels = c("historical", "recent"))
    ) %>%
    filter(!is.na(period))

  p <- ggplot(dist_df, aes(x = metric, y = temp_c, fill = period)) +
    geom_violin(
      position = position_dodge(width = 0.72),
      alpha = 0.8,
      trim = FALSE,
      linewidth = 0,
      colour = NA
    ) +
    geom_boxplot(
      position = position_dodge(width = 0.72),
      width = 0.16,
      alpha = 0.8,
      outlier.alpha = 0.28,
      linewidth = 0.32,
      colour = "#5B6270"
    ) +
    stat_summary(
      fun = mean,
      geom = "point",
      position = position_dodge(width = 0.72),
      size = 1.9,
      shape = 21,
      stroke = 0.28,
      fill = "white",
      colour = "#2E3440",
      alpha = 0.8
    ) +
    facet_wrap(~season, ncol = 2, scales = "free_y", labeller = as_labeller(eda_season_label)) +
    scale_fill_manual(
      values = eda_period_palette,
      labels = c(
        historical = paste0(historical_start, "-", historical_end),
        recent = paste0(recent_start, "-", recent_end)
      )
    ) +
    scale_x_discrete(labels = eda_metric_label) +
    labs(
      title = paste0(
        "Distributional Comparison of ",
        historical_start, "-", historical_end,
        " and ",
        recent_start, "-", recent_end
      ),
      x = NULL,
      y = "Temperature (degC)"
    ) +
    eda_base_theme() +
    theme(panel.grid.major.x = element_blank())

  if (save_plot) {
    eda_save_plot(p, "eda_distribution_shift_historical_recent_refined.jpg", width = 11.6, height = 8.2)
  }

  p
}
