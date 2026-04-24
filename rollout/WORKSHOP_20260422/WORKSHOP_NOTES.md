# Workshop Notes — ABAP Orchestrator

> **How to use this file**
>
> Record feedback during or after each workshop session. Tag each entry:
> - `[Feedback]` — observation or opinion, no action required
> - `[Action → OP-XX]` — linked to an entry in [OPEN_POINTS.md](OPEN_POINTS.md)
> - `[Question]` — unresolved question; escalate to an OP if it needs tracking
>
> When you add an `[Action]` item here, add the corresponding OP entry to OPEN_POINTS.md in the same session.

---

## Session: 2026-04-22 — Taskforce Introduction

*(Minutes transcribed: 2026-04-24)*

---

### Gemini CLI + Superpower + fs-dev-planning MCP — Simulation Run

**Context:** Live simulation using ticket **6000019754** (ZFICA_IN_GUIDT housekeeping) on DD1 system, running Gemini CLI + Superpower + fs-dev-planning MCP.

**Environment notes:**

- `[Feedback]` The Gemini model available at DH is **Gemini 2.5**, not 3.1 as originally referenced.
- `[Feedback]` Gemini API has a quota limit; exact threshold is not yet known.

**Code generation observations:**

- `[Feedback]` `[Action → OP-09]` The agent created its own Transport Request instead of using the CHARM-generated TR. Root cause unclear (Gemini vs. VSP behaviour).
- `[Feedback]` Generated code contained a syntax error on first creation; resolved after providing corrective feedback to Gemini.
- `[Feedback]` At runtime, the program output the cut-off date as a numeric value (e.g. `Execution started. Cut-off date: 739.365`) instead of a formatted date. Gemini had difficulty correcting this autonomously.

**Document generation observations:**

- `[Feedback]` `[Action → OP-10]` Technical Specification formatting produced by the agent requires further refinement.

**Action items raised:**

- `[Action → OP-11]` ABAP coding guidelines must be incorporated into code generation and review. Will be handled by the orchestrator.
- `[Question]` `[Action → OP-10]` Should the Technical Specification be separated so the agent writes a fully independent TS, rather than augmenting or being diluted by the functional consultant's draft?
- `[Action → OP-09]` *(HIGH PRIORITY)* Agent must use the TR created in SOLMAN, not auto-create one.
- `[Action → OP-10]` *(HIGH PRIORITY)* Refine Technical Specification generation quality end-to-end.

---

### Orchestrator — Walkthrough

A walkthrough of the ABAP Orchestrator pipeline was presented to the audience.

**Action items raised:**

- `[Action → OP-12]` Merge **fs-dev-planning MCP** with the Orchestrator. This is the enabler for direct Google Drive read/write from the orchestrator. Exact integration approach still to be explored.
- `[Action → OP-12]` Incorporate the **Superpower plugin** into the orchestrator.
- `[Action → OP-09]` *(HIGH PRIORITY)* Agent must use the SOLMAN TR (or explicitly ask the user for confirmation). Berna Arici proposed the following lookup approach:
  > Query `E070` with `AS4TEXT LIKE *CR_NUMBER*`, `TRSTATUS = 'D'`, `TRFUNCTION = 'K'` → retrieve `TRKORR`. Prompt user for confirmation, then proceed.
- Pending budget resolution (target: **1 May 2026**):
  - Yosua to schedule a follow-up session to run **6000019754** end-to-end with the orchestrator.
  - `[Action → OP-12]` Yosua to schedule a call with **Efim Parshin** to discuss fs-dev-planning MCP + Orchestrator integration.

---

### General Q&A

- `[Feedback]` API budget constraints are being tracked under **GDP-14646**.
- `[Question]` Budget for external consultants using the tooling — not yet addressed; no owner assigned.

---

*Last updated: 2026-04-24*
