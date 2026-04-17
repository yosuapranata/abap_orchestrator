# ABAP Orchestrator — Open Points & Challenges

**Version:** 1.0  
**Date:** April 2026  
**Source document:** [ROLLOUT_PLAN.md §7](ROLLOUT_PLAN.md#7-open-points--challenges)

> This document is the **single source of truth for ownership and status** of all open points.  
> Each entry links back to the full context in [ROLLOUT_PLAN.md](ROLLOUT_PLAN.md).  
> Update the **Status** and **Owner** fields here as items are resolved.

---

## Summary Table

| ID | Title | Area | Impact | Status | Owner |
|---|---|---|---|---|---|
| [OP-01](#op-01--per-developer-source-system-configuration) | Per-Developer Source System Configuration | Setup / UX | Medium | Open | — |
| [OP-02](#op-02--no-central-audit-log) | No Central Audit Log | Governance | Medium | Open | — |
| [OP-03](#op-03--stage-4-not-coordinated) | Stage 4 Not Coordinated | Workflow | Low-Medium | Open | — |
| [OP-04](#op-04--abap-standards-linting-is-prompt-based-not-automated) | ABAP Standards Linting Is Prompt-Based | Quality | Low | Open | — |
| [OP-05](#op-05--no-automated-test-execution) | No Automated Test Execution | Quality | Low-Medium | Open | — |
| [OP-06](#op-06--api-cost-per-ticket) | API Cost per Ticket | Finance | Financial | Resolved | Yosua |
| [OP-07](#op-07--single-source-system-per-session) | Single Source System per Session | Setup / UX | Low-Medium | Open | — |
| [OP-08](#op-08--windows-wsl-setup-guide-not-yet-published) | Windows WSL Setup Guide Not Yet Published | Documentation | High (blocker for WSL users) | Open | — |

**Status values:** `Open` · `In Progress` · `Decided` · `Resolved` · `Won't Fix`

---

## OP-01 — Per-Developer Source System Configuration

**← Full context:** [ROLLOUT_PLAN.md §7.1](ROLLOUT_PLAN.md#71-per-developer-source-system-configuration)  
**Area:** Setup / UX  
**Impact:** Medium  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

The `-s <SYSTEM_ID>` flag in `.mcp.json` is a single global setting per Claude Code session. A developer who handles tickets across multiple source systems in a day (e.g. DD1 and DD3) must edit `.mcp.json` and restart Claude Code each time they switch.

### Options

1. Add a system selector prompt to the orchestrator's Step 0 — developer is asked which system to read from at the start of each session. Orchestrator adjusts the MCP connection dynamically.
2. Provide a wrapper script that patches `-s` in `.mcp.json` and relaunches Claude Code with the chosen system.
3. Accept current behavior as a known constraint. Document the restart procedure in the rollout guide.

### Decision / Resolution

> *(to be filled in)*

---

## OP-02 — No Central Audit Log

**← Full context:** [ROLLOUT_PLAN.md §7.2](ROLLOUT_PLAN.md#72-no-central-audit-log)  
**Area:** Governance  
**Impact:** Medium  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

Each ticket's approval log lives in `project/<ticket-id>/03_change_log.md`. There is no aggregated view of all writes made across all tickets. Audit and compliance reviews require manual aggregation across many ticket folders.

### Options

1. Write a script that consolidates all `03_change_log.md` files into a single CSV/Excel report on demand.
2. Append each approval entry to a shared `project/AUDIT_LOG.md` at write time (dev-agent writes to both files simultaneously).
3. Integrate with an external system (SAP PS, Jira, SharePoint) to store approval records centrally.

### Decision / Resolution

> *(to be filled in)*

---

## OP-03 — Stage 4 Not Coordinated

**← Full context:** [ROLLOUT_PLAN.md §7.3](ROLLOUT_PLAN.md#73-stage-4-not-coordinated)  
**Area:** Workflow  
**Impact:** Low-Medium  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

Stage 4 (SLIN, ATC, test execution, code review, TR release) is entirely manual. There is no handoff notification, no tracking of which steps have been completed, and no visibility for a team lead into whether Stage 4 happened before a TR was released.

### Options

1. Add a `04_stage4_checklist.md` template that the dev-agent generates at the end of Stage 3. Developer ticks each box and commits the file when done.
2. Integrate with the ticketing system (Jira/ServiceNow): automatically transition the ticket status when the TR is released in SE09.
3. Accept the current manual discipline; monitor via the satisfaction survey open-text responses.

### Decision / Resolution

> *(to be filled in)*

---

## OP-04 — ABAP Standards Linting Is Prompt-Based, Not Automated

**← Full context:** [ROLLOUT_PLAN.md §7.4](ROLLOUT_PLAN.md#74-abap-standards-linting-is-prompt-based-not-automated)  
**Area:** Quality  
**Impact:** Low  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

The dev-agent enforces DH ABAP Guidelines V0.7 via its system prompt. Compliance depends on the quality of the model's output and is not validated by a separate static analysis step until ATC runs in Stage 4. There is a window where non-compliant code exists in the dev system before ATC finds it.

### Options

1. Run ATC (`RunATCCheck`) as part of Stage 3, immediately after each object is written. Surface findings to the developer before they approve the next object.
2. Accept the current behavior: ATC in Stage 4 is the backstop. No change required.

### Decision / Resolution

> *(to be filled in)*

---

## OP-05 — No Automated Test Execution

**← Full context:** [ROLLOUT_PLAN.md §7.5](ROLLOUT_PLAN.md#75-no-automated-test-execution)  
**Area:** Quality  
**Impact:** Low-Medium  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

`02_test_scenarios.md` is a manual checklist. No tool runs the test scenarios automatically or validates results. ABAP Unit Tests are not executed by the orchestrator even where they exist.

### Options

1. Run `RunUnitTests` at the end of Stage 3 on each changed object where ABAP Unit Tests exist. Append results to `03_change_log.md`.
2. Keep manual for now and revisit once the team has established baseline test coverage across the affected objects.

### Decision / Resolution

> *(to be filled in)*

---

## OP-06 — API Cost per Ticket

**← Full context:** [ROLLOUT_PLAN.md §7.6](ROLLOUT_PLAN.md#76-api-cost-per-ticket)  
**Area:** Finance  
**Impact:** Financial (scales with adoption)  
**Status:** Resolved  
**Owner:** Yosua  
**Last updated:** April 2026

### Description

All three agents run on `claude-opus-4-6`, the most capable model in the stack. For simple CRs (1–2 object changes), this may represent higher API cost than necessary. As team adoption grows, cost per sprint will grow proportionally.

### Actions Required

- Monitor cost per ticket using Claude Code session reports (`/gsd:session-report`) or the LiteLLM usage dashboard.
- Define a cost-per-ticket budget threshold that triggers a model review.
- Evaluate routing Stages 1–2 (read-only, pattern-matching tasks) to a lighter model (e.g. claude-sonnet-4-6) while keeping Stage 3 on Opus.

### Decision / Resolution

All three agents (`fs-review-agent`, `ts-agent`, `dev-agent`) moved from `claude-opus-4-6` to `claude-sonnet-4-6`. Sonnet offers comparable quality for SAP read/analysis tasks and code generation at significantly lower cost. Model selection is declared in each agent's frontmatter (`model:` field) and can be reverted per-agent if regressions are observed.

---

## OP-07 — Single Source System per Session

**← Full context:** [ROLLOUT_PLAN.md §7.7](ROLLOUT_PLAN.md#77-single-source-system-in-mcpjson)  
**Area:** Setup / UX  
**Impact:** Low-Medium  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

The MCP server is launched with a single `-s <SYSTEM_ID>` argument. All reads within a session are locked to that system. A developer cannot compare or cross-reference objects between two source systems (e.g. DD1 vs. DD3) within the same Claude Code session without restarting.

### Options

1. Accept as a known constraint. Document the restart procedure clearly in ROLLOUT_PLAN.md §3.3.
2. Investigate whether the vibing-steampunk MCP server supports multiple named connections that can be switched at runtime (feature request to the tool owner).

### Decision / Resolution

> *(to be filled in)*

---

## OP-08 — Windows WSL Setup Guide Not Yet Published

**← Full context:** [ROLLOUT_PLAN.md §2.1](ROLLOUT_PLAN.md#21-claude-code-via-litelm) · [ROLLOUT_PLAN.md §1 (Who This Guide Is For)](ROLLOUT_PLAN.md#who-this-guide-is-for)  
**Area:** Documentation  
**Impact:** High — blocks all Windows developers who are not on Cloudflare  
**Status:** Open  
**Owner:** —  
**Last updated:** April 2026

### Description

Two Claude Code + LiteLLM setup guides exist:

| Platform | Guide |
|---|---|
| Mac | [Setup Guide for Mac](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1266581586/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Mac) |
| Windows with Cloudflare | [Setup Guide for Windows](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows) |

A third guide — **Windows without Cloudflare using WSL (Windows Subsystem for Linux)** — is referenced in the rollout plan but has not been published yet. Developers in this setup cannot self-onboard.

### Minimum Content Required for the WSL Guide

The guide should cover at minimum:
1. Installing WSL2 and a Linux distro (Ubuntu recommended)
2. Installing Node.js and the Claude Code CLI inside WSL
3. Configuring the LiteLLM endpoint and API key inside WSL
4. Installing `vsp.exe` — note whether the Windows binary works from WSL or if a Linux build is needed
5. Configuring `.mcp.json` paths (Windows vs. WSL path conventions)
6. Verifying the connection end-to-end

### Actions Required

- Assign an author to draft the WSL guide on Confluence (FINDEVC space, alongside the existing guides).
- Publish the guide and update [ROLLOUT_PLAN.md §2.1](ROLLOUT_PLAN.md#21-claude-code-via-litelm) with the live Confluence link.
- Remove the "not yet published" note from this document once resolved.

### Decision / Resolution

> *(to be filled in — assign author and target publish date)*

---

*Last updated: April 2026*
