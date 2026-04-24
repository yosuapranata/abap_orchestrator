# ABAP Orchestrator — Open Points & Challenges

**Version:** 1.0  
**Date:** April 2026  
**Source document:** [ROLLOUT_PLAN.md](ROLLOUT_PLAN.md)

> This document is the **single source of truth for ownership and status** of all open points.  
> Each entry links back to the full context in [ROLLOUT_PLAN.md](ROLLOUT_PLAN.md).  
> Update the **Status** and **Owner** fields here as items are resolved.

---

## Summary Table

| ID | Title | Area | Impact | Status | Owner |
|---|---|---|---|---|---|
| [OP-06](#op-06--api-cost-per-ticket) | API Cost per Ticket | Finance | Financial | Resolved | Yosua |
| [OP-08](#op-08--windows-wsl-setup-guide-not-yet-published) | Windows WSL Setup Guide | Documentation | High (blocker for WSL users) | Resolved | Berna & Efim |
| [OP-09](#op-09--agent-must-use-solman-transport-request) | Agent Must Use SOLMAN Transport Request | Development | High — wrong TR used in every run | Open | Yosua |
| [OP-10](#op-10--technical-specification-quality-improvement) | Technical Specification Quality Improvement | Development | High — TS quality gates Stage 3 | Open | Yosua |
| [OP-11](#op-11--abap-coding-standards-enforcement-in-gemini-workflow) | ABAP Coding Standards in Gemini Workflow | Development | Medium | Open | TBD |
| [OP-12](#op-12--fs-dev-planning-mcp--orchestrator-integration) | fs-dev-planning MCP + Orchestrator Integration | Architecture | High — unlocks Google Drive & Superpower | Open | Yosua / Efim |

**Status values:** `Open` · `In Progress` · `Decided` · `Resolved` · `Won't Fix`

---

## OP-06 — API Cost per Ticket

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

## OP-08 — Windows WSL Setup Guide Not Yet Published

**← Full context:** [ROLLOUT_PLAN.md §2.1](ROLLOUT_PLAN.md#21-claude-code-via-litelm) · [ROLLOUT_PLAN.md §1 (Who This Guide Is For)](ROLLOUT_PLAN.md#who-this-guide-is-for)  
**Area:** Documentation  
**Impact:** High — blocks all Windows developers who are not on Cloudflare  
**Status:** Resolved  
**Owner:** Berna & Efim  
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

WSL setup instructions were added to the existing [Windows setup guide](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows). A separate guide was not needed — the existing page now covers both Cloudflare and WSL paths. References in ROLLOUT_PLAN.md, README.md, and ROADMAP.md updated to point to the live page.

---

## OP-09 — Agent Must Use SOLMAN Transport Request

**Area:** Development
**Impact:** High — agent auto-creates TRs instead of using the CHARM-generated TR on every run
**Status:** Open
**Owner:** Yosua
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

During the Gemini CLI simulation run (ticket 6000019754, DD1), the agent created its own Transport Request independently rather than using the TR generated in SOLMAN/CHARM. This is a compliance risk: changes must be traceable to the correct CR-linked TR.

The same gap applies to the ABAP Orchestrator — the dev-agent does not currently look up the SOLMAN TR before writing to the target system.

### Proposed Approach (Berna Arici)

Query table `E070` with:
- `AS4TEXT LIKE *<CR_NUMBER>*`
- `TRSTATUS = 'D'` (modifiable)
- `TRFUNCTION = 'K'` (main transport request)

→ Retrieve `TRKORR`. Present to user for confirmation before using it in any write operation.

### Actions Required

- Implement SOLMAN TR lookup in the dev-agent (or as an orchestrator pre-check step at Stage 3 gate).
- Add user confirmation prompt before the TR is used.
- Update `03_change_log.md` output to include the SOLMAN-sourced TR number.
- Validate on a real orchestrator run (ticket 6000019754, target: after 1 May 2026 budget resolution).

---

## OP-10 — Technical Specification Quality Improvement

**Area:** Development
**Impact:** High — TS quality directly gates Stage 3 code correctness
**Status:** Open
**Owner:** Yosua
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

Two issues observed with Technical Specification generation:

1. **Formatting** — the TS output from both the Gemini workflow and the orchestrator's `ts-agent` lacks consistent structure and readability.
2. **Separation of concerns** — the current approach has the agent augment or work within the functional consultant's FS document. This risks the agent's technical content being diluted or constrained by the FC's draft format. An alternative is to have the agent generate an independent, fully agent-authored TS alongside the FC document.

### Open Question

Should the TS be agent-authored independently, or should it remain a structured augmentation of the FC's document? Decision needed before implementation.

### Actions Required

- Define the target TS format/template that the `ts-agent` must produce.
- Decide on separation vs. augmentation approach (requires team alignment).
- Update the `ts-agent` system prompt and output schema accordingly.
- Validate output quality on a real run (ticket 6000019754, target: after 1 May 2026).

---

## OP-11 — ABAP Coding Standards Enforcement in Gemini Workflow

**Area:** Development
**Impact:** Medium — generated code may not comply with DH ABAP standards
**Status:** Open
**Owner:** TBD
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

The ABAP Orchestrator's `dev-agent` already has the full DH ABAP coding standards embedded in its system prompt (`.claude/agents/dev.md`). However, the parallel Gemini CLI + fs-dev-planning MCP workflow does not have equivalent guidelines incorporated. Code generated via the Gemini path may not comply with DH standards (naming conventions, OOP-only, AUTHORITY-CHECK, modification log comments, etc.).

### Actions Required

- Determine whether the Gemini workflow will be maintained long-term or sunset in favour of the orchestrator.
- If maintained: incorporate the DH ABAP coding standards into the Gemini / fs-dev-planning MCP configuration.
- If sunset: document the orchestrator as the sole sanctioned path and close this OP.

---

## OP-12 — fs-dev-planning MCP + Orchestrator Integration

**Area:** Architecture
**Impact:** High — unlocks Google Drive connectivity and Superpower plugin capabilities
**Status:** Open
**Owner:** Yosua / Efim Parshin
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

Two integration items were raised:

1. **Merge fs-dev-planning MCP into the Orchestrator** — the fs-dev-planning MCP server provides Google Drive read/write and additional capabilities (Superpower plugin). Merging these into the orchestrator would allow agents to read FS documents directly from Google Drive and write outputs back, removing the manual file-drop step (`project/<ticket>/input/fs_original.md`).

2. **Superpower plugin** — currently available in the Gemini workflow only. Should be incorporated into the Claude Code orchestrator setup.

The exact integration approach for both items requires exploration with Efim Parshin.

### Actions Required

- Yosua to schedule a call with Efim Parshin to discuss integration approach (target: after 1 May 2026 budget resolution).
- Investigate whether fs-dev-planning MCP can be added to `.mcp.json` alongside the existing `vibing-steampunk` server.
- Evaluate Google Drive OAuth/service-account setup for the orchestrator environment.
- Incorporate Superpower plugin into the Claude Code orchestrator configuration.
- Run integration test on ticket 6000019754 once budget is resolved.

---

*Last updated: 2026-04-24*
