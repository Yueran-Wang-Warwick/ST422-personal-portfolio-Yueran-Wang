# purpose: Provide shared helpers for formatting, plotting, and saving report tables.
# inputs: Tibbles supplied by downstream table-building scripts and plot titles or filenames when required.
# outputs: In-memory table objects, ggplot table images, and saved JPG files in outputs/tables/ when requested.
# how it is called: Sourced by downstream table scripts and by reports/ST422_Professional_Technical_report.Rmd.

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
})

# Estimate a sensible output size for a table based on its dimensions.
estimate_table_dims <- function(df) {
  width  <- max(7, 1.9 * ncol(df) + 1.2)
  height <- max(3, 0.42 * (nrow(df) + 1) + 1.3)
  list(width = width, height = height)
}

# Convert a tibble into a simple table-style ggplot object.
make_table_plot <- function(df, title = NULL, subtitle = NULL) {
  # Convert all values to character so they can be drawn consistently in the plot table.
  display_df <- df %>%
    mutate(across(everything(), as.character))

  col_names <- names(display_df)
  n_rows    <- nrow(display_df)

  # Build one long-format block for the table body.
  body_long <- display_df %>%
    mutate(.row_id = row_number()) %>%
    pivot_longer(
      cols      = all_of(col_names),
      names_to  = ".col",
      values_to = ".value"
    ) %>%
    mutate(
      .col  = factor(.col, levels = col_names),
      .y    = n_rows - .row_id + 1,
      .band = if_else(.row_id %% 2 == 0, "even", "odd"),
      .font = "plain"
    ) %>%
    select(.col, .y, .value, .band, .font)

  # Add a separate header row so column names can be styled differently.
  header_long <- tibble(
    .col   = factor(col_names, levels = col_names),
    .y     = n_rows + 1,
    .value = col_names,
    .band  = "header",
    .font  = "bold"
  )

  # Draw the body and header together as one table-like figure.
  plot_df <- bind_rows(body_long, header_long)

  ggplot(plot_df, aes(x = .col, y = .y)) +
    geom_tile(
      aes(fill = .band),
      color     = "#D9D9D9",
      linewidth = 0.35,
      width     = 1,
      height    = 1
    ) +
    geom_text(
      aes(label = .value, fontface = .font),
      size   = 3.5,
      family = "sans"
    ) +
    scale_fill_manual(
      values = c(header = "#E9ECEF", odd = "#FFFFFF", even = "#F7F9FB")
    ) +
    scale_y_continuous(breaks = NULL, expand = expansion(mult = c(0.02, 0.02))) +
    labs(title = title, subtitle = subtitle) +
    theme_void(base_size = 12) +
    theme(
      legend.position = "none",
      plot.title      = element_text(face = "bold"),
      plot.margin     = margin(10, 15, 10, 15)
    )
}

# Save a table plot to the standard outputs/tables directory.
save_table_jpg <- function(table_plot, filename, width = 10, height = 4, dpi = 300) {
  out_dir <- file.path("outputs", "tables")
  dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  ggplot2::ggsave(
    filename = file.path(out_dir, filename),
    plot     = table_plot,
    width    = width,
    height   = height,
    dpi      = dpi,
    bg       = "white",
    quality  = 95
  )
}

# Convert a lower-case season label into title case.
to_title_case <- function(x) {
  x_chr <- as.character(x)
  paste0(toupper(substr(x_chr, 1, 1)), substring(x_chr, 2))
}

# Build a wide season-by-metric table with formatted estimates and confidence intervals.
build_wide_ci_table <- function(df, estimate_col, lower_col, upper_col, digits = 3) {
  fmt <- paste0("%+.", digits, "f [%+.", digits, "f, %+.", digits, "f]%s")

  df %>%
    mutate(
      # Standardise the required numeric columns before formatting table cells.
      season = as.character(season),
      metric = as.character(metric),
      est    = as.numeric(.data[[estimate_col]]),
      low    = as.numeric(.data[[lower_col]]),
      up     = as.numeric(.data[[upper_col]]),
      sig    = if_else(low > 0 | up < 0, "*", ""),
      cell   = sprintf(fmt, est, low, up, sig)
    ) %>%
    mutate(
      # Impose the report ordering before pivoting to the final wide format.
      season = factor(season, levels = c("winter", "spring", "summer", "autumn")),
      metric = factor(metric, levels = c("mean", "min", "max"))
    ) %>%
    arrange(season, metric) %>%
    select(season, metric, cell) %>%
    pivot_wider(names_from = metric, values_from = cell) %>%
    mutate(season = to_title_case(as.character(season))) %>%
    rename(Season = season, Mean = mean, Min = min, Max = max)
}
