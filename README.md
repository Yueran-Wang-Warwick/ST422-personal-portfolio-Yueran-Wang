# ST422 Personal Portfolio

This repository contains the full workflow for the ST422 consultancy portfolio on seasonal temperature change in Central England. The project starts from the raw HadCET seasonal totals files, rebuilds cleaned datasets, and renders the final technical report from a single R Markdown source.

```text
ST422_Personal_Portfolio_Yueran_Wang/
|
|-- raw/
|   |-- data-cleansing.Rmd
|   |-- mean/
|   |   |-- cet_v2-1-0-0_meantemp-seasonal-totals.csv
|   |   `-- cet_v2-1-0-0_meantemp-seasonal-ranked.csv
|   |-- min/
|   |   |-- cet_v2-1-0-0_mintemp-seasonal-totals.csv
|   |   `-- cet_v2-1-0-0_mintemp-seasonal-ranked.csv
|   `-- max/
|       |-- cet_v2-1-0-0_maxtemp-seasonal-totals.csv
|       `-- cet_v2-1-0-0_maxtemp-seasonal-ranked.csv
|-- processed/
|   |-- data_mean_cleaned.csv
|   |-- data_min_cleaned.csv
|   |-- data_max_cleaned.csv
|   |-- features/
|   |   |-- hadcet_long_with_flags.csv
|   |   `-- hadcet_wide_with_flags.csv
|   `-- qa/
|       |-- quality_summary.csv
|       |-- missingness_summary.csv
|       |-- outlier_summary.csv
|       `-- outlier_review.csv
|-- src/
|   |-- modeling_gls_ar1.R
|   |-- model_comparison.R
|   |-- model_diagnostics.R
|   |-- robustness_checks.R
|   |-- model_thresholds.R
|   |-- plot_eda_annotated_series.R
|   |-- plot_eda_warming_rate_curve.R
|   |-- plot_eda_distribution_checks.R
|   |-- plot_eda_rolling_variability.R
|   |-- model_plot_baseline_shift_gls_ar1.R
|   |-- model_plot_long_run_trend_gls_ar1.R
|   |-- model_plot_error_dependence_gls_ar1.R
|   |-- model_plot_qq_diagnostics.R
|   |-- model_plot_robustness.R
|   |-- table_model_shift_results.R
|   |-- table_model_trend_results.R
|   |-- table_monitoring_framework.R
|   `-- table_thresholds.R
|-- outputs/
|   |-- figures/
|   `-- tables/
|-- reports/
|   |-- cache/
|   |-- ST422_Professional_Technical_report.Rmd
|   `-- ST422_Professional_Technical_report.pdf
|-- cache/
|-- renv/
|   |-- activate.R
|   |-- settings.json
|   `-- library/
|-- renv.lock
|-- README.md
|-- .gitignore
|-- .Rprofile
|-- .Rproj.user/
|-- ST422_Personal_Portfolio_Yueran_Wang.Rproj
|-- .RData
`-- .Rhistory
```

## Determinism

The workflow is deterministic. It does not use random sampling, simulation, bootstrap methods, MCMC, or random initialisation. The GLS, OLS, AR(1), AR(2), diagnostics, threshold tables, and all report figures are deterministic numerical or graphical outputs conditional on unchanged data, code, and package versions. No random seed is required for the main analytical pipeline.

## Exact Run Sequence

Run the project from the repository root.

1. Open the project in RStudio or an R session with working directory set to the repository root.
2. Install or restore the required R packages listed in the environment section below.
3. Rebuild the cleaned data by running `raw/data-cleansing.Rmd`.
   - This recreates:
     - `processed/data_mean_cleaned.csv`
     - `processed/data_min_cleaned.csv`
     - `processed/data_max_cleaned.csv`
     - `processed/features/*`
     - `processed/qa/*`
4. Render the technical report from the repository root with:

```r
rmarkdown::render("reports/ST422_Professional_Technical_report.Rmd",
                  output_format = "pdf_document")
```

5. Confirm that the regenerated PDF appears at:

```text
reports/ST422_Professional_Technical_report.pdf
```

For a clean reproducibility check, delete `cache/`, `reports/cache/`, and any previous files under `outputs/` before rerunning steps 3 to 4.

## Data Access Instructions

All raw input files required for the current workflow are stored locally under `raw/`. These files come from the HadCET release:

Met Office (2025). *Seasonal Mean, Minimum and Maximum Central England Temperature (HadCET) series v2.1.0.0*. NERC EDS Centre for Environmental Data Analysis, 05 June 2025. doi:10.5285/ca43505702fa4eeeba4b65f1ce2c1e6a. <https://dx.doi.org/10.5285/ca43505702fa4eeeba4b65f1ce2c1e6a>

## Environment Management

The current codebase requires R plus the following core packages.

- `dplyr`
- `ggplot2`
- `knitr`
- `nlme`
- `purrr`
- `readr`
- `rmarkdown`
- `tidyr`
- `tibble`

The project is configured at the repository root with:

- `ST422_Personal_Portfolio_Yueran_Wang.Rproj`
- `.Rprofile`
- `renv/`
- `renv.lock`

This means the repository root is the project root for reproducibility purposes. The environment should be restored from the root-level `renv.lock`, not from any subdirectory.
