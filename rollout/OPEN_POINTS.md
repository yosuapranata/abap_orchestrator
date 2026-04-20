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

*Last updated: April 2026*
