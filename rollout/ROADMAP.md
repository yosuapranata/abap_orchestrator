# ABAP Orchestrator — Rollout Roadmap

> **Version:** 1.0
> **Created:** 2026-04-18
> **Target:** Full team adoption by end of May 2026
> **Status:** In Progress

---

## Milestone 1: Full Team Rollout (Apr 18 – May 30, 2026)

### Phase 1: Pre-Workshop Prep — `Apr 18–21` · Status: Completed ✓

**Goal:** Ensure everything is ready for a smooth workshop demo.

- [x] Resolve [OP-08](OPEN_POINTS.md): Windows/WSL setup guide — content added to existing Windows Confluence page
- [x] Prepare workshop agenda and demo script
- [x] Verify demo environment — DD1 connectivity, MCP tools working end-to-end
- [x] Prepare CR-6000018866 as walkthrough example
- [x] Set up ticket 6000019754 (ZFICA_IN_GUIDT housekeeping) as live simulation CR

**Success criteria:** Workshop can run without technical blockers.

---

### Phase 2: Discovery Workshop — `Apr 22` · Status: Completed ✓

**Goal:** Present the tool to the taskforce, run live simulation, collect structured feedback.

> **Note:** The workshop ran differently from the original plan. The live simulation used **Gemini CLI + Superpower + fs-dev-planning MCP** (not the ABAP Orchestrator) on ticket **6000019754** in DD1. The ABAP Orchestrator was presented as a separate walkthrough. A repeat run of 6000019754 end-to-end using the orchestrator is planned after the budget constraint is resolved (see [OP-09](OPEN_POINTS.md#op-09--agent-must-use-solman-transport-request) and GDP-14646).

- [x] Run live simulation on ticket 6000019754 using Gemini CLI + Superpower + fs-dev-planning MCP (DD1)
- [x] Present ABAP Orchestrator pipeline walkthrough to taskforce audience
- [x] Collect feedback in [WORKSHOP_NOTES.md](WORKSHOP_20260422/WORKSHOP_NOTES.md)
- [x] Capture new open points in [OPEN_POINTS.md](OPEN_POINTS.md) — raised OP-09, OP-10, OP-11, OP-12
- [ ] Identify volunteer pilot participants — not yet confirmed

**Success criteria:** Feedback captured, pilot group identified.

**Actuals:** Feedback and open points captured. Pilot participants not yet identified — carry forward to Phase 3.

---

### Phase 3: Feedback Incorporation — `Apr 23–28` · Status: In Progress

**Goal:** Triage and implement actionable feedback from the workshop.

> **Budget note:** Some follow-up work (e.g. orchestrator re-run of 6000019754) is blocked pending budget resolution under GDP-14646, targeted for 1 May 2026.

Open points from Phase 2 triaged by priority:

**Must-fix (HIGH PRIORITY — before pilot):**
- [ ] [OP-09](OPEN_POINTS.md#op-09--agent-must-use-solman-transport-request) — Agent must use SOLMAN TR (E070 lookup); implement in dev-agent or as Stage 3 pre-check
- [ ] [OP-10](OPEN_POINTS.md#op-10--technical-specification-quality-improvement) — Improve TS generation quality and formatting; decide on agent-authored vs. augmented approach

**Should-fix (before full rollout):**
- [ ] [OP-11](OPEN_POINTS.md#op-11--abap-coding-standards-enforcement-in-gemini-workflow) — Incorporate DH ABAP coding standards into Gemini workflow (or confirm orchestrator is the sole sanctioned path)
- [ ] [OP-12](OPEN_POINTS.md#op-12--fs-dev-planning-mcp--orchestrator-integration) — Explore fs-dev-planning MCP + Orchestrator integration (Google Drive, Superpower); Yosua to schedule call with Efim Parshin

**Carry-forward from Phase 2:**
- [ ] Identify volunteer pilot participants from workshop attendees

**Success criteria:** OP-09 and OP-10 resolved, pilot participants confirmed, OP-11 and OP-12 scoped.

---

### Phase 4: Pilot Simulation — `May 1–9` · Status: Not Started

**Goal:** Workshop attendees run real CRs end-to-end to validate the pipeline in production conditions.

> **Dependency:** Blocked on budget resolution (GDP-14646, target 1 May 2026). Kick-off planned after budget clears.

- [ ] Yosua to re-run ticket **6000019754** end-to-end using the ABAP Orchestrator as the reference pilot run
- [ ] Confirm pilot participants and assign 2–3 real CRs (varying complexity if possible)
- [ ] Provide a pilot runbook/checklist for consistent feedback capture
- [ ] Be available as support during pilot runs
- [ ] Track issues encountered — agent failures, MCP limitations, unclear outputs
- [ ] Collect per-CR feedback: time spent, pain points, manual steps needed

**Success criteria:** At least 2 CRs completed end-to-end with the orchestrator, issues documented.

---

### Phase 5: Pilot Retrospective & Fixes — `May 12–23` · Status: Not Started

**Goal:** Review pilot outcomes, fix issues, and finalize the tool and training materials before full-team rollout.

- [ ] Run retrospective session with pilot participants
- [ ] Prioritize and fix issues found during pilot
- [ ] Update agent definitions/skills based on real-world learnings
- [ ] Update documentation ([ROLLOUT_PLAN.md](ROLLOUT_PLAN.md), [CLAUDE.md](../CLAUDE.md)) with lessons learned
- [ ] Prepare training materials and onboarding checklist for full-team rollout

**Success criteria:** No critical issues outstanding, training materials ready, full team rollout unblocked.

---

### Phase 6: Full Team Training & Rollout — `May 26–30` · Status: Not Started

**Goal:** Onboard the entire development team in a single rollout wave.

- [ ] Run hands-on training session for all team members
- [ ] Walk through setup using [ROLLOUT_PLAN.md](ROLLOUT_PLAN.md)
- [ ] Distribute training materials and reference docs
- [ ] Each developer completes setup and runs their first CR (with support available)
- [ ] Announce full availability and support channels

**Success criteria:** All team members onboarded, tool available for all new CRs.

---

## Milestone 2: Efficiency Metrics (June 2026+)

**Goal:** Establish measurable metrics on the efficiency impact of this initiative.

Phases and tasks to be planned after Milestone 1 completion. Will build on the framework in [EFFICIENCY_MEASUREMENT.md](EFFICIENCY_MEASUREMENT.md), which has 5 open decisions to resolve:

1. Baseline data source (SE09 + Jira/PS historical data)
2. Measurement owner assignment
3. Survey tool selection
4. Complexity stratification criteria
5. BI dashboard selection

---

## References

| Document | Purpose |
|----------|---------|
| [ROLLOUT_PLAN.md](ROLLOUT_PLAN.md) | Setup, installation, and usage guide |
| [WORKSHOP_20260422/AGENDA.md](WORKSHOP_20260422/AGENDA.md) | Workshop agenda |
| [WORKSHOP_20260422/WORKSHOP_NOTES.md](WORKSHOP_20260422/WORKSHOP_NOTES.md) | Workshop feedback capture |
| [OPEN_POINTS.md](OPEN_POINTS.md) | Open decisions and blockers |
| [EFFICIENCY_MEASUREMENT.md](EFFICIENCY_MEASUREMENT.md) | Metrics framework for Milestone 2 |
| [CR-6000018866](../project/S131-6000018866/) | Completed example run |
