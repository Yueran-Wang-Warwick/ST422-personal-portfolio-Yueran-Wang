---
output:
  html_document: default
  pdf_document: default
---

# Minutes of Meeting

**Project:** Brief 6  
**Group:** Group 3  
**Meeting type:** Weekly sync  
**Date:** 2026/02/23  
**Time:** 10:37–10:50, 11:30–11:55  
**Location/Platform:** MB0.07  
**Minute-taker:** Shan Xue

## 1. Attendees

- Alex Zheng (present)
- Lewis Parry (present)
- Yueran Wang (present)
- Yunting Chen (present)
- Priya Kumar (present)
- Shan Xue (present)

## 2. Agenda

1.  Client requested meeting: interim progress.  
2.  QA discussion with client.  
3.  Action log evidence pointer structure  

## 3. Key Decisions Made

- **Decision 1:** The team will independently determine the most appropriate temperature metrics for modelling and justification.  
  **Rationale:** The client has no preferred metric and expects evidence-based justification.  
  **Implication:** Metric selection must be defensible, clearly documented, and supported by analysis.

- **Decision 2:** The team will propose a statistically stable historical baseline period.  
  **Rationale:** No preferred baseline was provided by the client.  
  **Implication:** Baseline sensitivity analysis will be included in robustness checks.

- **Decision 3:** Action log updates must include GitHub evidence links in the “Evidence Pointer” column after peer review.  
  **Rationale:** To strengthen auditability and reproducibility.  
  **Implication:** All completed actions must reference an Issue, PR, or commit link.

## 4. Discussion notes

**Q1.** Are there specific temperature metric that should be prioritised?   
**A:** Client has no preference; we should choose appropriate metrics ourselves and justify with evidence.

**Q2:** In practical decision terms, what outcome would be most useful from this analysis?    
**A:** Most useful outcome aligns with the first point in the client brief; outputs must be robust and defensible. Client is relying on our
analysis and expects it to stand up to scrutiny and answer likely follow-up questions.

**Q3:** Do you have a preferred historical baseline period for comparison, or should we propose one based on statistical stability?  
**A:** No preferred historical baseline period.

**Q4.** Action log evidence pointer structure    
**A:** After peer review, action log should be updated in the approved minute and the relate GitHub link should be attached in the ‘pointer period’ section.

## 5. Action log

| Action | Owner | Deadline | Status | Evidence Pointer |
|--------|--------|----------|--------|------------------|
| Data cleaning and validation | Alex Zheng | 2026-02-25 | Completed | `data/processed/data_max_cleaned.csv`, `data/processed/data_mean_cleaned.csv`, `data/processed/data_min_cleaned.csv` |
| EDA visualisation and narrative integration | Yueran Wang | 2026-02-25 | Completed | `reports.Rmd` |
| Upload draft minutes | Shan Xue | 2026-02-23 | Completed | `Minutes/2026-02-23_meeting_DRAFT.md` |
| Complete action log and approved minutes | Yunting Chen | 2026-02-27 | Completed | `Minutes/2026-02-23_meeting_APPROVED.md` |
| Peer review of data cleaning | Lewis Parry | 2026-02-27 | Completed | PR #6 reviewed and approved |
| Peer review of EDA outputs | Yunting Chen | 2026-02-27 | Completed | PR #5 reviewed and approved |
| Peer review of README file | Yunting Chen | 2026-02-27 | Completed | PR #7 reviewed and approved |
| Peer review of Management plan | Alex Zheng | 2026-02-27 | Completed | `management_plan.md` |
| Draft section titles and report structure | Lewis Parry | 2026-02-27 | Completed | Report outline draft |
| Confidence statement (Client Q1) | Yueran Wang | 2026-02-28 | Completed | `client_meeting_Q1_brief6.md` |
| Uncertainty and Bias Framing (Client Q2) | Shan Xue | 2026-02-28 | Completed | `client_meeting_q2_uncertainty.md` |
| Robustness checks (Client Q3) | Priya Kumar | 2026-02-28 | Completed | ------- |

## 6. Risks / blockers / dependencies

- **Dependency:** Completion of peer review before merging modelling outputs or file change.  
  **Due:** 2026-02-27  
  **Status:** Open  

## 7. Reproducibility / QA checks

- [ ] Figures/tables regenerate without manual edits  
- [ ] Peer review completed (link evidence)  

## 8. Next meeting

**Date/time:** Week 8 Monday  
**Location/Platform:** MB0.07  
**Provisional agenda:**   
1. Present modelling results and robustness checks.  
2. Confirm baseline selection rationale.  
3. Review action log and QA evidence.
