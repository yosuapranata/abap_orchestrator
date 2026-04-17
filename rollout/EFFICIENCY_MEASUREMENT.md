# ABAP Orchestrator — Efficiency Measurement

**Version:** 1.0  
**Date:** April 2026  
**Status:** Draft — approach options listed; decisions required (marked with ← )

---

## Table of Contents

1. [Measurement Goal](#1-measurement-goal)
2. [Metric 1 — Time per Ticket](#2-metric-1--time-per-ticket)
3. [Metric 2 — Adoption Rate & Developer Satisfaction](#3-metric-2--adoption-rate--developer-satisfaction)
4. [Reporting Cadence](#4-reporting-cadence)
5. [Open Points](#5-open-points)

---

## 1. Measurement Goal

Quantify whether the ABAP Orchestrator meaningfully reduces the time from **CR assignment to TR handoff for functional testing**, and whether adoption grows and sustains across the team.

These two metrics are the primary signals:

| # | Metric | Question it answers |
|---|---|---|
| 1 | **Time per ticket** | Is AI-assisted development faster than the previous baseline? |
| 2 | **Adoption rate & satisfaction** | Are developers actually using the tool, and do they find it valuable? |

Measurement should begin **before the full rollout** to establish a baseline, then continue on a regular cadence after rollout.

---

## 2. Metric 1 — Time per Ticket

### 2.1 Definition

> **Time per ticket** = calendar days from "CR assigned to developer" to "TR released for functional testing."

This covers the entire development unit of work: understanding the requirement, analyzing affected objects, writing and reviewing code, running ATC, and releasing the TR. It excludes:
- Requester/FS clarification time (before assignment)
- Functional testing (after TR release)
- Transport import lead time

### 2.2 Measurement Approach Options

Three options are available, ranging from minimal friction (but lower data quality) to slightly more structured (higher quality):

---

#### Option A — Manual Spreadsheet

**How it works:** Each developer records two dates per CR in a shared spreadsheet: the date the CR was assigned to them and the date the TR was released.

| Field | Notes |
|---|---|
| CR Number | e.g. CR-12345 |
| Developer | Name or employee ID |
| Assigned Date | Date dev received the CR |
| TR Released Date | Date TR was released in SE09 |
| Used AI Orchestrator? | Yes / No |
| Notes | Optional friction notes |

**Effort:** Very low — 2-minute entry per ticket.

**Accuracy:** Medium — depends on developer discipline. Missing entries or retroactive estimates are common.

**Best for:** Pilot phase; quick start with minimal setup.

---

#### Option B — Git Commit Timestamps

**How it works:** Use the timestamp of the first commit to `project/<ticket-id>/03_change_log.md` as a proxy for "Stage 3 complete." This can be extracted automatically from git history.

```bash
# List all change log files and their first commit timestamps
git log --diff-filter=A --format="%ad %s" --date=short -- "project/*/03_change_log.md"
```

The assignment date still requires a manual source (SAP PS, Jira, or spreadsheet). Only the completion date is automated.

**Effort:** Low-Medium — requires scripting the git query; assignment date still needs a manual input.

**Accuracy:** Medium-High — git timestamps are objective, but only capture Stage 3 completion, not TR release.

**Best for:** Teams with a consistent git commit workflow.

---

#### Option C — Structured Fields in `03_change_log.md` *(Recommended)*

**How it works:** Add two date fields to the `03_change_log.md` template that the dev-agent fills in as part of Stage 3:

```markdown
## Ticket Metadata
- **CR Number:** CR-12345
- **Developer:** Firstname Lastname
- **CR Assigned Date:** YYYY-MM-DD        ← developer fills in at Stage 3 start
- **TR Released Date:** YYYY-MM-DD        ← developer fills in after SE09 release
- **AI Orchestrator Used:** Yes
```

A lightweight script can then aggregate these fields across all tickets into a report:

```bash
# Example: extract all metadata blocks from change logs
grep -r "CR Assigned Date\|TR Released Date\|AI Orchestrator" project/*/03_change_log.md
```

**Effort:** Medium — requires updating the `03_change_log.md` template (in `.claude/agents/dev.md`) and committing to filling in the TR release date after manual Stage 4.

**Accuracy:** High — data is embedded in the workflow artifact, not a separate system.

**Best for:** Post-pilot rollout; most reliable for long-term measurement.

---

#### Recommendation

Start with **Option A** during the pilot (minimal overhead, fast to stand up). Migrate to **Option C** once the team has settled into the workflow and the `03_change_log.md` template has stabilized.

### 2.3 Baseline

To measure improvement, establish a **pre-AI baseline** before or alongside the rollout.

| Data source | How to access | What it gives you |
|---|---|---|
| SAP SE09 / SE01 transport history | Filter by developer, date range, object type | TR release dates (completion proxy) |
| SAP Project System (PS) or Jira | Filter by developer assignment date | CR assignment dates |
| Manual spreadsheet (historical) | If already maintained by the team | Both dates, plus complexity category |

**Recommended baseline period:** The last 2–3 months of tickets before the rollout, focusing on tickets of comparable complexity (small/medium CRs — 1–5 objects).

**Stratify by complexity:** Tickets with 1–2 objects vs. 5+ objects will have very different baseline times. Measure separately to avoid skewing averages.

---

## 3. Metric 2 — Adoption Rate & Developer Satisfaction

### 3.1 Adoption Rate

**Definition:**

> **Adoption rate** = tickets processed through at least Stage 1 (FS Review) ÷ total CRs assigned to the team that sprint.

This measures whether developers are reaching for the tool, not whether they completed all three stages. Stage 1 output (`01_fs_questions.md`) is a reliable proxy — if it exists, the developer ran the orchestrator.

#### Measurement Approach Options

---

#### Option A — Manual Count

**How it works:** The team lead counts folders in `project/` that contain `01_fs_questions.md` each week, and divides by total CRs assigned.

**Effort:** Very low.

**Accuracy:** Medium — depends on the project folder being kept tidy.

---

#### Option B — Git File Count *(Recommended baseline)*

**How it works:** A script counts Stage 1 output files committed in the last N days.

```bash
# Count tickets with Stage 1 complete in the last 30 days
git log --since="30 days ago" --diff-filter=A --name-only --format="" \
  | grep "01_fs_questions.md" | wc -l
```

**Effort:** Low — a one-time script setup.

**Accuracy:** Medium-High — relies on developers committing output files (add this to team norms).

---

#### Option C — Survey + File Count *(Recommended for ongoing measurement)*

**How it works:** Combine the file count (for hard adoption numbers) with a bi-weekly pulse survey (for qualitative signals that the file count cannot capture — e.g. "I ran Stage 1 but the output wasn't useful so I didn't continue").

**Effort:** Medium — requires a survey tool (Microsoft Forms, Google Forms, or similar).

---

#### Recommendation

Use **Option B** for adoption tracking (automated, low overhead) and add **Option C** (pulse survey) bi-weekly once the rollout is past the pilot phase.

### 3.2 Satisfaction Survey

A short pulse survey — 5 questions, under 2 minutes to complete. Keep it anonymous to encourage honest feedback.

**Suggested questions:**

| # | Question | Response Format |
|---|---|---|
| 1 | Did you use the AI Orchestrator for your most recent CR? | Yes / No |
| 2 | *(If yes)* Rate the quality of the Stage 1 FS Review output. | 1 (poor) – 5 (excellent) |
| 3 | *(If yes)* Rate the quality of the Stage 2 Technical Spec output. | 1 (poor) – 5 (excellent) |
| 4 | *(If yes)* How much development time did the tool save on this ticket? | None / Less than 30 min / 30 min–2 hr / More than 2 hr |
| 5 | What was your biggest friction point or blocker this sprint? | Open text |

**Survey cadence:** Bi-weekly (aligned with your sprint rhythm if applicable).

**Tool options:** Microsoft Forms, Google Forms, Confluence page, or a simple shared Excel on SharePoint.

**Key signals to watch:**
- Questions 2 & 3: If average drops below 3.5, the agent prompts or SAP setup likely need investigation.
- Question 4: Tracks self-reported time savings; compare against the Metric 1 data.
- Question 5: Rich qualitative signal — surface themes monthly to the team.

---

## 4. Reporting Cadence

| Frequency | What | Who produces it | Audience |
|---|---|---|---|
| Weekly | Adoption file count (Option B script) | Team lead or designated owner | Team |
| Bi-weekly | Pulse survey distributed and collected | Team lead | Team |
| Monthly | Time-per-ticket comparison: AI-assisted vs. baseline | Team lead / analyst | Team + management |
| Quarterly | Trend review: adoption %, satisfaction scores, time savings trend | Team lead | Management |

**Suggested monthly report format (1 page):**

```
ABAP Orchestrator — Monthly Efficiency Report  [Month Year]

Tickets processed with AI orchestrator:  XX / YY assigned  (ZZ%)
Average time per ticket (AI):            X.X days
Average time per ticket (baseline):      X.X days
Estimated time saved this month:         XX hours

Stage-level quality (from survey):
  Stage 1 — FS Review:     X.X / 5
  Stage 2 — Technical Spec: X.X / 5
  Overall satisfaction:     X.X / 5

Top friction points reported this month:
  1. [Theme from Q5 responses]
  2. [Theme from Q5 responses]

Actions for next month:
  • [Action item based on data]
```

---

## 5. Open Points

The following decisions are needed before measurement can begin formally.

### 5.1 Baseline Data Source

**Question:** Where do we pull historical CR assignment and TR release dates for the pre-AI baseline?

**Options:**
- SAP SE09 transport history (TR release dates) + Jira/ServiceNow ticket dates (assignment dates)
- Historical team spreadsheet if one already exists
- SAP Project System (PS) if tickets are tracked there

**Owner / Decision needed:** ← assign

### 5.2 Measurement Owner

**Question:** Who is responsible for collecting, aggregating, and distributing the monthly report?

**Options:**
- Team lead
- A rotating role (one dev per sprint)
- A dedicated analyst or coordinator

**Owner / Decision needed:** ← assign

### 5.3 Survey Tool & Anonymity

**Question:** Which tool will host the pulse survey? Should responses be anonymous?

**Recommendation:** Responses should be anonymous to maximize honest feedback. Microsoft Forms or Google Forms both support anonymous responses.

**Owner / Decision needed:** ← assign

### 5.4 Complexity Stratification

**Question:** Should time-per-ticket be measured in aggregate, or stratified by ticket complexity (e.g. number of objects changed, functional area)?

**Recommendation:** Stratify by ticket size — at minimum, separate "simple" (1–3 objects) from "complex" (4+ objects). A 1-object CR and a 10-object CR are not comparable baselines.

**Owner / Decision needed:** ← assign

### 5.5 Reporting Dashboard Tool

**Question:** Should the monthly report be produced manually (Word/PowerPoint), in a spreadsheet (Excel/Google Sheets), or in a BI tool (Power BI, Tableau)?

**Recommendation for pilot:** Start with a shared Excel/Google Sheet. Upgrade to Power BI only if executive reporting requires a live dashboard.

**Owner / Decision needed:** ← assign

---

*Last updated: April 2026*
