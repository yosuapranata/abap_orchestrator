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
| [OP-09](#op-09--agent-must-use-solman-transport-request) | Agent Must Use SOLMAN Transport Request | Development | Medium | Open | Yosua |
| [OP-10](#op-10--technical-specification-google-drive-formatting) | TS Google Drive Formatting | Development | High — raw Markdown unreadable in Google Docs | Open | Yosua |
| [OP-11](#op-11--abap-coding-standards-enforcement-in-gemini-workflow) | ABAP Coding Standards in Gemini Workflow | Development | Medium | Open | TBD |
| [OP-12](#op-12--fs-dev-planning-mcp--orchestrator-integration) | fs-dev-planning MCP + Orchestrator Integration | Architecture | High — enables FS fetch + TS push via Google Drive | Open | Yosua / Efim |
| [OP-13](#op-13--api-budget-constraints) | API Budget Constraints | Finance | Medium | Open | Robert |
| [OP-14](#op-14--external-consultant-tooling-budget) | External Consultant Tooling Budget | Finance | Low | Open | TBD |

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
**Impact:** Medium
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

## OP-10 — Technical Specification Google Drive Formatting

**Area:** Development
**Impact:** High — TS written to Google Drive is unreadable (raw Markdown symbols visible in Google Docs)
**Status:** Open
**Owner:** Yosua
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22; refined 2026-04-24

### Description

This OP is the formatting sub-problem of [OP-12](#op-12--fs-dev-planning-mcp--orchestrator-integration).

When the fs-dev-planning MCP writes the Technical Specification to a Google Drive document, it passes
the content as a raw Markdown string. Google Docs renders this as plain text — `**bold**`, `## Heading`,
and ` ```code blocks``` ` appear literally as typed symbols, making the document unreadable.

The local `02_technical_spec.md` file (written to `project/<ticket>/`) should remain as Markdown — this
is fine for local use. The formatting fix applies only to the Google Drive upload path.

**Root cause:** No Markdown-to-Docs conversion step exists between `ts-agent` output and the
fs-dev-planning MCP write call.

### Open Question

Should the TS be a fully agent-authored independent document (standalone TS), or an augmentation of the
functional consultant's FS document? This affects the TS structure and template. Decision needed before
the `ts-agent` prompt is refined.

### Actions Required

- Blocked on OP-12 (MCP must be available first to determine write tool capabilities).
- Once MCP is available: determine whether the write tool accepts structured content (paragraph styles,
  bold, lists) or plain text only. This dictates the conversion approach:
  - Structured → convert Markdown AST to MCP's structured format in the orchestrator skill
  - Plain text only → strip Markdown syntax to clean readable plain text before upload
- Decide on standalone vs. augmented TS approach (team alignment required).
- Define the TS Google Docs template/target format.
- Validate on ticket 6000019754 after MCP integration is complete.

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
**Impact:** High — unlocks Google Drive read/write directly from the orchestrator pipeline
**Status:** Open
**Owner:** Yosua / Efim Parshin
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22; refined 2026-04-24

### Description

The fs-dev-planning MCP is an **npm package / executable** that exposes Google Drive read/write
capabilities to Claude Code. Adding it to the orchestrator's `.mcp.json` alongside `vibing_steampunk`
enables two new integration points in the pipeline:

**Point 1 — FS Fetch (replaces manual file drop):**
Currently: developer manually copies the FS document to `project/<ticket>/input/fs_original.md`.
With integration: the orchestrator calls the MCP with the CR/ticket number → MCP fetches the FS
directly from Google Drive → orchestrator saves it as `project/<ticket>/input/fs_original.md`.
The `fs-review-agent` reads the local file as before — no agent changes required.

**Point 2 — TS Push (new step after Stage 2):**
After `ts-agent` writes `02_technical_spec.md` locally, the orchestrator calls the MCP to upload
the TS as a new Google Doc. The CONTINUE/REVISE gate then includes the Google Drive document URL.
The formatting issue (OP-10) must be resolved before this step produces a readable document.

**Key design decision:** Google Drive integration is handled entirely by the **orchestrator skill**,
not the agents. Agents remain SAP-only. Commands are unchanged or minimally adjusted.

### Prerequisite

The fs-dev-planning MCP npm package must be obtained from Efim Parshin and installed.

### Actions Required

- Yosua to schedule a call with Efim Parshin (target: after 1 May 2026 budget resolution).
- Obtain and install the fs-dev-planning MCP npm package.
- Add MCP server entry to `.mcp.json` alongside `vibing_steampunk`.
- Enumerate exposed tools: confirm read tool (CR number → FS content) and write tool (CR number + content → Google Doc) signatures.
- Implement FS fetch step in `.claude/skills/abap-orchestrator.md` (Step 0 pre-check).
- Implement TS push step in `.claude/skills/abap-orchestrator.md` (after Stage 2 gate).
- Apply OP-10 formatting fix in the TS push step.
- Run integration test on ticket 6000019754 after MCP is configured.

---

## OP-13 — API Budget Constraints

**Area:** Finance
**Impact:** Medium
**Status:** Open
**Owner:** Robert
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

API budget constraints (covering Claude API costs and Gemini API quota) are currently being tracked under **GDP-14646**. The Gemini API quota limit observed during the simulation run is not yet fully characterised — the exact threshold is unknown. As adoption grows, API costs will scale proportionally with the number of CRs processed.

### Actions Required

- Monitor progress of GDP-14646 for budget resolution (target: 1 May 2026).
- Once resolved, confirm API quota limits for both Claude and Gemini.
- Define a cost-per-ticket budget threshold that triggers a model or workflow review.

---

## OP-14 — External Consultant Tooling Budget

**Area:** Finance
**Impact:** Low
**Status:** Open
**Owner:** TBD
**Last updated:** 2026-04-24
**Source:** Workshop session 2026-04-22

### Description

Whether external consultants working on DH projects can access and use the ABAP Orchestrator tooling has not been addressed. No budget allocation or licensing decision has been made for this group, and no owner has been assigned.

### Actions Required

- Determine if external consultants are in scope for this tooling.
- If yes: identify budget owner and assess licensing/access requirements.
- If no: document the decision and close this OP.

---

*Last updated: 2026-04-24*
