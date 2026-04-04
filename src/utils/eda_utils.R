# purpose: Define shared data-loading, rolling-summary, labelling, theme, and plot-saving helpers for the EDA workflow.
# inputs: Cleaned temperature files in processed/ and plot objects created by downstream plotting scripts.
# outputs: In-memory helper functions and saved figures in outputs/figures/ when eda_save_plot() is called.
# how it is called: Sourced by report plotting scripts and by reports/ST422_Professional_Technical_report.Rmd.

suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(tidyr)
})

# Define the shared colour mapping for the three temperature metrics.
eda_metric_palette <- c(
  mean = "#6F8FAF",
  min = "#94B49F",
  max = "#D98C73"
)

# Define the shared colour mapping for historical and recent comparison windows.
eda_period_palette <- c(
  historical = "#BCD7E8",
  recent = "#F2C7A4"
)

# Define the default ordering used for seasonal facets and tables.
eda_season_levels <- c("winter", "spring", "summer", "autumn", "annual")

# Load the three cleaned HadCET series and reshape them into one long-format tibble.
eda_load_hadcet_long <- function(include_annual = FALSE, year_min = NULL, year_max = NULL) {
  # Read the cleaned mean, minimum, and maximum series and tag each metric.
  mean_df <- readr::read_csv("processed/data_mean_cleaned.csv", show_col_types = FALSE) %>%
    mutate(metric = "mean")

  min_df <- readr::read_csv("processed/data_min_cleaned.csv", show_col_types = FALSE) %>%
    mutate(metric = "min")

  max_df <- readr::read_csv("processed/data_max_cleaned.csv", show_col_types = FALSE) %>%
    mutate(metric = "max")

  # Combine the three metric files and reshape seasons into one column.
  out <- bind_rows(mean_df, min_df, max_df) %>%
    pivot_longer(
      cols = c(winter, spring, summer, autumn, annual),
      names_to = "season",
      values_to = "temp_c"
    ) %>%
    mutate(
      year = as.integer(year),
      temp_c = as.numeric(temp_c),
      metric = factor(metric, levels = c("mean", "min", "max")),
      season = factor(season, levels = eda_season_levels)
    ) %>%
    filter(!is.na(year), !is.na(temp_c))

  if (!is.null(year_min)) {
    
    # Apply the lower year bound when a restricted analysis window is requested.
    out <- out %>% filter(year >= year_min)
  }

  if (!is.null(year_max)) {
    
    # Apply the upper year bound when a restricted analysis window is requested.
    out <- out %>% filter(year <= year_max)
  }

  if (!include_annual) {
    
    # Drop the annual summary when the downstream analysis is season-specific.
    out <- out %>% filter(season != "annual")
  }

  out
}

# Compute a trailing rolling mean with the requested window width.
eda_rolling_mean <- function(x, window = 30) {
  as.numeric(stats::filter(x, rep(1 / window, window), sides = 1))
}

# Compute a trailing rolling standard deviation with the requested window width.
eda_rolling_sd <- function(x, window = 30) {
  n <- length(x)
  out <- rep(NA_real_, n)

  if (n < window) {
    return(out)
  }

  for (i in seq(window, n)) {
    out[i] <- stats::sd(x[(i - window + 1):i], na.rm = TRUE)
  }

  out
}

# Define the shared ggplot theme used across EDA and model figures.
eda_base_theme <- function() {
  theme_minimal(base_size = 12) +
    theme(
      plot.title = element_text(size = 16, face = "bold", colour = "#2E3440"),
      plot.subtitle = element_text(size = 10.5, colour = "#5B6270"),
      plot.caption = element_text(size = 9, colour = "#6B7280"),
      axis.title = element_text(colour = "#2E3440"),
      axis.text = element_text(colour = "#4B5563"),
      legend.position = "bottom",
      legend.title = element_blank(),
      legend.text = element_text(colour = "#4B5563"),
      strip.text = element_text(face = "bold", colour = "#2E3440"),
      strip.background = element_rect(fill = "#F7F8FA", colour = NA),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(colour = "#E8EBEF", linewidth = 0.35),
      panel.grid.major.x = element_line(colour = "#EEF1F4", linewidth = 0.3),
      plot.background = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = "white", colour = NA)
    )
}

# Save a plot to the standard outputs/figures directory.
eda_save_plot <- function(plot_obj, filename, width = 11, height = 7, dpi = 320) {
  out_dir <- file.path("outputs", "figures")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  ggplot2::ggsave(
    filename = file.path(out_dir, filename),
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi,
    bg = "white"
  )
}

# Convert internal metric codes into report-ready labels.
eda_metric_label <- function(x) {
  dplyr::recode(as.character(x), mean = "Mean", min = "Minimum", max = "Maximum")
}

# Convert internal season codes into report-ready labels.
eda_season_label <- function(x) {
  dplyr::recode(as.character(x), winter = "Winter", spring = "Spring", summer = "Summer", autumn = "Autumn", annual = "Annual")
}
