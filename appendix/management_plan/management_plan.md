# Appendix: Management Plan

Use this appendix to show **how you planned and managed delivery**, not just what analysis you produced. Keep it evidence-based and practical.

## Workplan and milestones

# Project Roadmap: Phases of Work


## Phase 1: Triage

**Clarify decision and scope**

-   **Purpose**: Agree on scope and limitations.
-   **Key Activities**:
    -   Read project brief.
    -   Confirm dataset (HadCET).
    -   Define excluded variables.
-   **Deliverables**: Signed-off `SELECTION.md` and scope notes.
-   **Owner**: **Shan Xue** (Project Lead)
-   **Deadline**: Week 6
-   **Definition of Done**: Scope is formally agreed upon by all leads.


## Phase 2: Data Readiness

**Ensure usable dataset**

-   **Purpose**: Acquire and validate data.
-   **Key Activities**:
    -   Download HadCET v2.1.0.0.
    -   Check for missing values.
    -   Format dates and schema.
-   **Deliverables**: Clean `.csv` file and data dictionary.
-   **Owner**: **Alex Zheng** (Data Steward)
-   **Deadline**: Week 7
-   **Definition of Done**: Reproducible cleaning script runs without error.


## Phase 3: Analysis

**Produce evidence**

-   **Purpose**: Generate statistical findings.
-   **Key Activities**:
    -   Calculate 30-year baselines.
    -   Run trend tests (e.g., Mann-Kendall).
    -   Plot time series data.
-   **Deliverables**: Draft figures and summary tables.
-   **Owner**: **Yueran Wang** (Analysis Lead)
-   **Deadline**: Week 8
-   **Definition of Done**: All claims are supported by p-values or confidence intervals.


## Phase 4: Interpretation & Reporting

**Write client output**

-   **Purpose**: Translate statistics into business meaning.
-   **Key Activities**:
    -   Draft internal briefing.
    -   Interpret trends vs. step-changes.
-   **Deliverables**: Draft report (RMarkdown).
-   **Owner**: **Lewis Parry** (Reporting Lead)
-   **Deadline**: Week 9
-   **Definition of Done**: Narrative aligns strictly with evidence; no over-claiming.


## Phase 5: QA

**Make it defensible**

-   **Purpose**: Verify correctness and reproducibility.
-   **Key Activities**:
    -   Conduct peer code review.
    -   Verify figure labels and units.
    -   Re-run full pipeline on a fresh machine.
-   **Deliverables**: Final `report.html` and QA log.
-   **Owner**: **Priya Kumar & Yunting Chen** (QA Leads)
-   **Deadline**: Week 10
-   **Definition of Done**: A fresh run reproduces identical outputs to the draft.


### Milestones and deadlines

| Milestone | What it means | Why it matters | Due date (Est.) | Owner(s) | Status |
|------------|------------|------------|------------|------------|------------|
| **Scope agreed** | Brief selected, out-of-scope defined | Prevents scope creep | Week 6 | Shan Xue | **Done** |
| **Data freeze** | Clean dataset version tagged | Stops moving targets | Week 7 (Mon) | Alex Zheng | **Done** |
| **First figures** | Core plots/tables drafted | Enables narrative early | Week 8 | Yueran Wang | **Done** |
| **Draft Report** | Full text draft ready | Reviews can begin | Week 9 | Lewis Parry | **Done** |
| **Code Review** | Code checked for logic/style | Ensures correctness | Week 9 | Priya/Yunting | **Done** |
| **Final QA sign-off** | Checklist complete | Confident submission | Week 10 | Priya/Yunting | **Done** |


### Allocation of responsibilities

| Role | Responsibilities | Outputs owned | Primary | Backup |
|---------------|---------------|---------------|---------------|---------------|
| **Project Lead** | Keep plan on track; chair meetings; remove blockers | Minutes and task board | **Shan Xue** | Lewis Parry |
| **Data Steward** | Data cleaning; data dictionary; versioning | Clean dataset and scripts | **Alex Zheng** | Yueran Wang |
| **Analysis Lead** | Main modelling/summaries; method notes | Results tables/figures | **Yueran Wang** | Alex Zheng |
| **Reporting Lead** | Client report and exec summary | Drafts and final text | **Lewis Parry** | Shan Xue |
| **QA Lead** | Check claims, figures, reproducibility | QA checklist and log | **Priya Kumar, Yunting Chen** | Alex Zheng |


## Risk register

| Risk (what could go wrong) | Likelihood (L/M/H) | Impact (L/M/H) | Mitigation (what you will do) | Owner | Status |
|------------|------------|------------|------------|------------|------------|
| **Scope creep** | M | H | Freeze scope in `SELECTION.md`; record out-of-scope items. | Shan Xue | Open |
| **Data interpretation errors** | L | H | Peer review of statistical claims (check p-values/CIs). | Priya/Yunting | Open |
| **Git merge conflicts** | M | M | Pull before push; communicate before editing same file. | Alex Zheng | Open |
| **Late integration** | H | H | Set "First Figures" milestone early (Week 8). | Lewis Parry | Open |
| **Reproducibility failure** | L | H | Run full pipeline on a fresh clone weekly. | Priya/Yunting | Open |


## Quality assurance plan

### Data quality checks (Owner: Alex Zheng)

| Check | How it is performed | Pass/Fail rule | When run |
|------------------|------------------|------------------|------------------|
| **Missingness** | Scripted summary | Flag if key months are missing in recent decades | Each update |
| **Duplicate check** | ID check on Year/Month | No duplicate time points | Each update |
| **Range check** | Rule-based | Temps must be reasonable (e.g., -20°C to +40°C) | Each update |

### Analysis robustness checks (Owner: Yueran Wang)

| Robustness check | Why it matters | What you change |
|------------------------|------------------------|------------------------|
| **Baseline Period** | Results depend on reference | Compare 1961-1990 w/ 1981-2010 |
| **Trend Method** | Parametric assumptions | Compare Linear Regression w/ Mann-Kendall |
| **Data Source** | Measurement artifacts | Check Min/Max trends vs Mean trends |

### Review process (peer review, code review, figure checking)

**Suggested approach:**

-   Schedule review as a milestone (not a last-minute activity).
-   Use a simple checklist so reviewers know what "good" looks like.

### Review process (peer review, code review, figure checking)

| Review type | What is reviewed | Reviewer(s) | Checklist / criteria used | How feedback is recorded | Date | Evidence link |
|:----------|:----------|:----------|:----------|:----------|:----------|:----------|
| **Code review** | Reproducibility, style, logic | **Shan Xue** | ; 1. No hard-coded paths; 2. MK-test logic correct | GitHub Pull Request (PR) comments | 03 Mar 2026 | <https://github.com/Yueran-Wang-Warwick/ST422-Team-3/pull/26#pullrequestreview-4058872496> |

### Reproducibility check (Owner: Priya Kumar, Yunting Chen)

-   **Goal:** Run the full pipeline on a "clean" machine/account.
-   **Command:** `rmarkdown::render("report/report.Rmd")`
-   **Success Criteria:** Output HTML/PDF matches the submitted version exactly.
