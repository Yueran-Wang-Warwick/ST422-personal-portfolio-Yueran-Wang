# Overview

This document is a template for the assessed **Consultancy Portfolio** 
and the **Workshop Presentation and Discussion (Group)**.

## Submission rules

- Submit **one PDF** for the main portfolio (maximum **20 pages**, including
  figures, tables, graphics, and data output).
- Submit code as a **separate technical appendix** (does **not** count towards
  the 20-page limit).
- Code must be **reproducible**: another analyst must be able to recreate all
  reported results **without editing any files**.


# Consultancy Portfolio

The portfolio consists of several elements where you bring together
individually the totality of the work you and your team undertook. 
The client and technical reports are written by you based on the work and 
analysis completed by your team.

Only material in the appendices does **not** count towards the **20 pages**
limit. This page limit is a hard limit and anything beyond the 20 page limit
will not be read and will not contribute towards the final mark.

**Front matter. Start of 20 page limit requirement** Material from the cover
page until the **End of 20 page limit requirement** is included in the limit.

## Cover page

Include:

- Module code and assessment title
- Student name and student ID
- Project title and group identifier
- Date of submission

## Table of contents

This is automatically generated when `toc: true` is enabled in the YAML header.

## Contribution declaration

Write a concise statement covering:

- Your role(s) in the project (what you led, what you delivered, what you reviewed).
- The specific outputs you produced (analysis, figures, tables, writing, code, QA).
- Where evidence is located (minutes dates, task-board items, commit IDs, review notes).
- Confirmation that the work in this portfolio is your own and accurately
  reflects your contribution.

Suggested structure:
- Summary of your main contributions:
  1. [...]
  2. [...]
  3. [...]
- Items you reviewed or quality-assured:
  1. [...]
  2. [...]
- Evidence pointers:
  - Meeting minutes: [dates]
  - Task board: [items]
  - Version control: [repo link/commit IDs]
  - Drafts/review notes: [file names]


## Client report

The following sets out guidance on a broad structure and considerations for the
client report. Each client and report will be different and you **must** evaluate
what the client is asking and how to write to that intended audience. The
following is guidance around how to structure your client report you will need
to adapt to the specific context of the client question.

### Executive summary

#### Client question and decision context

- What decision is the client trying to make?
- What would they do differently depending on the evidence?

#### Headline findings

- Each bullet must be specific, falsifiable, and supported by evidence in the
  report.
- Include key numbers (not just adjectives).

#### Recommendation(s)

- What action is recommended for the client to take now?
- What is the expected benefit and what are the risks?

#### Evidence anchors

- Reference the specific figures/tables used to justify the recommendation(s).
- Example: "See Figure 2 and Table 1."

#### Key uncertainty and limitations

- What are the main reasons the conclusion might be wrong?
- What would change your recommendation?


### Client brief and scope

- Restate the client's question.
- Scope boundaries: what you did and did not do.
- Brief outline of approach (plain language).

### Data and context

- Data sources and time period covered
- Definitions of the key outcome(s) and covariates used
- Data quality issues (missingness, bias, measurement error) and implications

### Findings

You could structure as 2 to 4 subsections, each with a single clear message.

For each subsection include:

- Claim
- Evidence (numbers + a table/figure)
- Interpretation in plain language
- Practical implication for the client

#### [Finding title]

- Claim:
- Evidence:
- Figure/Table reference:
- Key numbers:
- Interpretation:
- Implication:

### Uncertainty and limitations

- Method and data limitations that materially affect the decision.
- Sensitivity checks or robustness checks performed (if any) and what they show.
- What additional data or analysis would reduce uncertainty.

### Recommendations and next steps

- Recommendations (specific, implementable actions)
- Dependencies, risks, and mitigations
- Next steps (short-term and longer-term)

## Professional technical report

**Purpose.** This technical report provides a complete, auditable justification
for the methods and analytical choices used to support the client-facing report.
It is written for an expert statistically trained reader and is intended to make
the work reproducible, defensible, and open to critique.

The following sets out guidance on a broad structure and considerations for the
professional technical report report. Each report will be different and you 
**must** evaluate what is appropriate and relevant to include.

### Technical abstract

- The client question, the core analytical approach, and the headline technical
  conclusion.
- Main limitations and how they were handled.

### Problem definition

- Client decision question translated into a statistical question.
- Primary outcome(s), exposure/treatment/segment definition (if relevant).
- Target population and time window.
- The estimand: what quantity you are trying to estimate (e.g., mean difference,
  risk ratio, trend, association, predictive performance).
- Success criteria: what would count as evidence strong enough to act on.

### Data provenance and structure

- Data sources, versions, extraction date(s), and any joins/merges.
- Unit of analysis (customer, transaction, session, region, week, etc.).
- Key fields used and how they map to the client narrative.
- Inclusion/exclusion criteria and rationale.
- Known data limitations (coverage, recording changes, missingness, measurement
  error).

### Pre-processing and feature construction

- Cleaning rules (duplicates, inconsistent IDs, invalid values, date parsing).
- Handling of missing data (mechanism assumptions, imputation vs complete-case).
- Derived variables and coding decisions (bins, transformations, 
  standardisation).
- Outlier handling and influence controls.
- Rationale: why each choice is appropriate for the question and what could go
  wrong.

### Exploratory analysis and descriptive checks

- EDA objectives: what was checked before modelling and why.
- Baseline summaries / balance checks (if comparative).
- Distributional checks and assumptions diagnostics (skew, zero inflation, heavy
  tails).
- Visual checks supporting modelling choices (trend, seasonality, heterogeneity).

### Primary methodology

For each primary method used, include:

#### Method statement

- Model/technique (e.g., regression, mixed model, time-series decomposition,
  causal matching, classification model).
- Formal specification (equations or pseudo-equations where appropriate).
- Estimation procedure (MLE/Bayes/OLS/regularisation), and software
  implementation details.
- Why the method is suitable for the estimand and data structure.

#### Assumptions

- Key assumptions required for validity (e.g., ignorability, linearity,
  independence, stationarity).
- How assumptions were assessed, partially verified, or defended conceptually.

#### Interpretation

- How parameters/outputs map to the client-facing claims.
- Practical interpretation (units, effect sizes, marginal effects, predicted
  probabilities).

### Model selection and tuning

- Candidate models considered and why.
- Selection criteria (AIC/BIC, cross-validation, predictive metrics, parsimony).
- Hyperparameter tuning approach and safeguards against leakage.
- Final model justification (including trade-offs).

### Validation and diagnostics

- Goodness-of-fit and residual diagnostics.
- Calibration and discrimination (if predictive).
- Overfitting checks and generalisation assessment.
- Stress tests: sensitivity to influential points, alternative functional forms.

### Robustness and sensitivity analysis

- Targeted sensitivity checks tailored to the project:

  - Alternative preprocessing choices (missingness/outliers/transformations).
  - Alternative model specifications.
  - Subgroup consistency checks.
  - Alternative outcome definitions or time windows.
  
- Summary of how conclusions change (or remain stable) and what that implies.

### Uncertainty quantification

- Uncertainty method used (CI, bootstrap, Bayesian credible intervals).
- What uncertainty is captured vs not captured (sampling vs model
  misspecification).
- Practical interpretation as decision risk.

### Threats to validity and limitations

- Internal validity (confounding, selection bias, measurement error).
- External validity (generalisation to other settings/time periods).
- Construct validity (are you measuring what you think you are measuring?).
- Failure modes: what would most plausibly break the conclusion.

### Alternative approaches considered

- Describe plausible alternatives and why they were not chosen.
- What would have to be true for an alternative to be preferred.

### Traceability to client report

- Map each client-facing claim/recommendation to technical evidence:
  - Claim 1 -> Table/Figure/Model output location
  - Claim 2 -> Table/Figure/Model output location
- Clarify any simplifications made for the client report and why they are acceptable.

### Reproducibility and audit trail

- Repository/project structure and "source of truth" conventions.
- Exact run sequence (README.md).
- Environment management (renv/requirements, versions, OS notes).
- Data access instructions (including secure handling if applicable).
- Determinism: random seeds, sampling, and how to reproduce identical outputs.
- Output inventory: where tables/figures/models are saved and how they are named.


**End of 20 page limit requirement**

## Appendix: Individual reflection


### Key judgement calls you made

- What decision did you make about the analysis and communication?
- Why did you choose that option rather than alternatives?

### Trade-offs

- What did you choose to simplify or omit and why?
- What risks did that introduce?

### What you learned and what you would do differently
- Focus on consulting practice: clarity, defensibility, uncertainty, and stakeholder needs.


## Appendix: Evidence of group contact and professional working

Teams should see the `ST422_Audit_pack` and `Group_contact_log` for a suggestion
of how to complete this section so that you can paste the output here.

### Group contact log

Provide evidence, for example, using `Group_contact_log` and the output `.md`
file, with:

- Date
- Attendees
- Duration
- Agenda
- Actions agreed
- Owner for each action
- Deadline
- Status (completed / in progress / blocked)
- Evidence pointer (minutes / screenshot / message link)

### Your actions undertaken and completed

Provide evidence of, for example, using `ST422_Audit_pack` and the output `.md`
file which can be pasted here.

- Task (as an issue) / deliverable
- Date started
- Date completed
- Output produced (file name / slide / figure / code script)
- Evidence pointer (commit ID / minutes date / task-board item)
- Outcome (one sentence)

## Appendix: Management plan

You must include your teams management plan. 

If you use the `management_plan_template`, then you can just paste in your teams
submission of the management plan template.

### Workplan and milestones

- Phases of work (triage -> analysis -> interpretation -> reporting -> QA)
- Milestones and deadlines
- Allocation of responsibilities (roles, not just names)

### Risk register

Provide a table with:

- Risk (what could go wrong)
- Likelihood (low/medium/high)
- Impact (low/medium/high)
- Mitigation (what you did to reduce risk)
- Owner
- Status (open/closed)

### Quality assurance plan

- Checks for data quality (missingness, outliers, duplicates, validity)
- Checks for analysis robustness (sensitivity, alternative specs, sanity checks)
- Review process (peer review, code review, figure checking)
- Reproducibility check (fresh run on a clean environment)

# Technical appendix (separate submission; does not count towards 20 pages)

You must provide a `zip` repo that meets our agreed reproducibility requirements.
We have discussed a suggested structure but you may need to adapt to your
project. An example basic structure is below.

- `data/` (or instructions for securely retrieving data if restricted)
- `src/` (numbered scripts recommended)
- `outputs/` (generated tables/figures)
- `report/` (source `.Rmd`)
- Environment lockfile (`renv.lock`)
- `README.md`(remember your output policy)

Give careful consideration to code style and commenting standard. As a team
you must ensure that the `src` code has a consistent style. So you must agree
on standards to ensure handover. For example, 

- Every script must begin with a short header explaining:
  - purpose
  - inputs
  - outputs
  - how it is called
- Functions must have short docstrings/comments.
- No hard-coded local file paths.
- All paths must be relative to the project root.

# Appendix: Critical evaluation of others' outputs (separate submission after workshop)

As a Team you will critically review the workshop presentation of another group.
Each individual will then submit a critical evaluation based on their group's
evaluation.

## Review identification

- Group reviewed: [Group ID]
- Date/time: [Workshop session]
- Materials reviewed: slides + Q&A notes (or slides only)

## Rubric-based critique

### A. Decision clarity

- Did they state the client's decision and why it matters?
- Was the recommendation explicit and actionable?

### B. Evidence and defensibility

- Were claims specific and supported by numbers/figures on the slides?
- Did they avoid over-claiming beyond what the evidence supports?
- Were limitations framed as decision risk (what might change the conclusion)?

### C. Narrative and structure

- Was there a clear storyline: question to evidence to implication to recommendation?
- Did slide content match what was spoken (no hidden or contradictory messages)?

### D. Visual communication

- Were charts readable, labelled, and interpretable in real time?
- Did visuals support a single message per slide?

### E. Q&A performance

- Were answers consistent with the evidence shown?
- Did they handle uncertainty appropriately (admit limits, propose next checks)?
- Could more than one member answer questions (shared ownership)?

## Strengths

At least three strengths that are evidence-based.

- Strength 1: [what it was] + [where seen: slide number / moment in Q&A]
- Strength 2: ...
- Strength 3: ...

## Areas for improvements

At least three areas for improvement and they must be actionable.

- Improvement 1: [what to change] + [why it matters] + [how to implement]
- Improvement 2: ...
- Improvement 3: ...

## Highest leverage recommendation

If the group could change only one thing to improve decision usefulness, what
would it be and why?


<!--- --------------------------------------------------------------------- --->




<!--- --------------------------------------------------------------------- --->

# Workshop presentation and discussion

The presentation will last for 10 minutes and then there will be questions to
the team.

The following is designed as a broad guide and you **must** adapt to the 
specific context of your consultancy question.

- Slide 1: Title, presenters and decision question

  - Client decision and why it matters
  
- Slide 2: Data overview and scope
  - Data, time period, key outcome(s), key caveats
  
- Slide 3: Finding 1 (single message)
  - Claim and key numbers and figure and implication
  
- Slide 4: Finding 2 (single message)
  - Claim and key numbers and figure and implication
  
- (Optional) Slide 5: Finding 3 or segmentation
  - Claim and key numbers and figure and implication
  
- Slide 6: Recommendations
  - Action now and expected benefit and risks
  
- Slide 7: Uncertainty and limitations
  - What could change the conclusion
  
- Slide 8: Next steps
  - What you would do next if the client extends the work

## Q&A readiness checklist (each member must be able to answer)

- Explain figure/table in detail (what it shows and what it does not).
- Defend key assumptions.
- Explain limitations that materially affects the recommendation.
- Describe how the results would change under a plausible alternative.
