# Workshop Agenda — ABAP Orchestrator Taskforce Introduction

**Date:** 2026-04-22  
**Audience:** FIN Dev C taskforce  
**Duration:** ~90 minutes  
**Facilitator:** Yosua  
**Notes:** [WORKSHOP_NOTES.md](WORKSHOP_NOTES.md)

---

| # | Topic | Time |
|---|---|---|
| 1 | [Why this initiative](#1-why-this-initiative) | 10 min |
| 2 | [Roadmap overview](#2-roadmap-overview) | 10 min |
| 3 | [Tool architecture](#3-tool-architecture) | 10 min |
| 4 | [Live demo — CR-6000018866](#4-live-demo--cr-6000018866) | 25 min |
| 5 | [Known limitations](#5-known-limitations) | 10 min |
| 6 | [Setup status check](#6-setup-status-check) | 5 min |
| 7 | [Q&A and open discussion](#7-qa-and-open-discussion) | 10 min |
| 8 | [Feedback capture](#8-feedback-capture) | 5 min |
| 9 | [Pilot volunteer sign-up](#9-pilot-volunteer-sign-up) | 5 min |

---

## 1. Why This Initiative

**Goal:** Set context before the demo; align the team on what this workshop is trying to achieve.

- We already have an AI tool in place (LiteLLM with Claude Code) and it is being used today
- **Objective 1:** We need a streamlined, consistent way of working for the whole development team that incorporates the AI tool — not just individual usage
- **Objective 2:** Once the new ways of working are rolled out, we need a way to measure the efficiency gain across the team

This workshop is the first step toward both: agreeing on a shared workflow and identifying how to track its impact.

---

## 2. Roadmap Overview

**Goal:** Orient the taskforce on where this is heading and what is being asked of them.

- Current status: tool is working end-to-end, used on real CRs
- Milestone 1 timeline: workshop → pilot (Apr 29) → Wave 1 (May 19) → Wave 2 (May 27)
- What the taskforce is being asked to do: attend today, consider joining the pilot

Reference: [ROADMAP.md](../ROADMAP.md)

---

## 3. Tool Architecture

**Goal:** Answer the "will it write to SAP without my knowing?" question before it derails the demo.

- Three automated stages: FS Review (read-only) → Technical Spec (read-only) → Development (writes require explicit approval)
- Agents communicate through the file system — outputs land in `project/<ticket-id>/`
- Stage 3 approval gate: dev agent shows a diff and waits for `APPROVE <OBJECT> to <SYSTEM>` before writing anything
- DQ1 and DP1 are hard-blocked — no write possible under any circumstance

---

## 4. Live Demo — CR-6000018866

**Goal:** Show the full pipeline end-to-end on a real, completed CR.

- Walk through the input FS document
- Show Stage 1 outputs: `01_fs_questions.md`, `01_locked_objects.md`, `01_revised_fs.md`
- Show Stage 2 outputs: `02_technical_spec.md`, `02_test_scenarios.md`
- Show Stage 3 outputs: `03_change_log.md`, `03_manual_changes.md`, and source diffs in `src/`
- Highlight the approval gate interaction

Reference: [CR-6000018866 project folder](../../project/S131-6000018866/)

---

## 5. Known Limitations

**Goal:** Set realistic pilot expectations upfront; avoid disappointment on the first real CR.

- Unsupported write targets: include programs (INCL), function modules (FUNC), function groups (FUGR), message classes (MSAG), DDIC views/tables
- Most CRs that touch INCL will need manual SE38 edits — this is the most common limitation
- The dev agent lists all required manual steps in `03_manual_changes.md` so nothing is silently skipped
- Text elements and transport release are also manual

---

## 6. Setup Status Check

**Goal:** Identify who is ready to pilot and who still needs onboarding support.

Quick show of hands:
- Who has Claude Code installed and authenticated against the LiteLLM endpoint?
- Who has `vsp.exe` installed and the MCP server connecting?
- Who has access to a sandbox system (DD3, DS1, or DX1) for writing?

Setup guide: [LiteLLM with Claude Code — Setup Guide for Windows](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows)

---

## 7. Q&A and Open Discussion

**Goal:** Surface concerns and questions before the feedback capture.

Likely topics:
- SAP write safety and audit trail
- What happens if the agent produces wrong code
- Performance vs. a developer doing it manually
- Which CR types are most suitable for piloting

Capture unresolved questions in [WORKSHOP_NOTES.md](WORKSHOP_NOTES.md) tagged as `[Question]`.

---

## 8. Feedback Capture

**Goal:** Structured feedback for the Phase 3 triage (Apr 23–28).

Ask the group to rate and comment on:
- What worked or looked promising
- Concerns or blockers
- Suggestions for improvement

Record all items in [WORKSHOP_NOTES.md](WORKSHOP_NOTES.md) using the tagging format defined there.

---

## 9. Pilot Volunteer Sign-Up

**Goal:** Identify 2–3 pilot participants for the Apr 29 – May 9 pilot simulation.

- Pilot participants will run 1–2 real CRs end-to-end using the orchestrator
- Support will be available throughout
- Feedback from the pilot directly shapes Wave 1 rollout

Sign up → record names in [WORKSHOP_NOTES.md](WORKSHOP_NOTES.md).
