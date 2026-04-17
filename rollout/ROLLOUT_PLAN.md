# ABAP Orchestrator — Team Rollout Plan

**Version:** 1.0  
**Date:** April 2026  
**Status:** Draft — Open points tracked in [OPEN_POINTS.md](OPEN_POINTS.md)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Prerequisites](#2-prerequisites)
3. [Installation](#3-installation)
4. [How to Use](#4-how-to-use)
5. [DH ABAP Standards Enforced](#5-dh-abap-standards-enforced)
6. [Known Limitations & Manual Workarounds](#6-known-limitations--manual-workarounds)

---

## 1. Overview

The **ABAP Orchestrator** accelerates the ABAP development lifecycle by delegating three stages to AI agents, each coordinated by a single command. Agents communicate through the file system and require explicit developer approval before writing anything to SAP.

### The Three Automated Stages

```
 Developer drops FS document
         │
         ▼
 Stage 1 — FS Review         (read-only, ~5–15 min)
   • Review FS against live SAP objects
   • Produce clarification questions, locked object report, revised FS
         │
         ▼  developer types CONTINUE or REVISE
         │
 Stage 2 — Technical Spec    (read-only, ~10–20 min)
   • Generate exact change specifications and test scenarios
         │
         ▼  developer types CONTINUE or REVISE
         │
 Stage 3 — Development       (writes require explicit approval per object)
   • Generate ABAP diffs locally
   • Push to SAP only after developer types: APPROVE <OBJECT> to <SYSTEM>
         │
         ▼
 Stage 4 — Manual (not automated)
   SLIN → ATC → Test Execution → Code Review → TR Release
```

### Who This Guide Is For

Developers already using **Claude Code via LiteLLM** on this team. If you have not set up Claude Code yet, complete the setup guide for your platform first:

> - [Claude Code Setup Guide — Mac](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1266581586/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Mac)
> - [Claude Code Setup Guide — Windows (with Cloudflare)](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows)
> - Claude Code Setup Guide — Windows without Cloudflare (using WSL) — *guide not yet published, see [OP-08](OPEN_POINTS.md#op-08--windows-wsl-setup-guide-not-yet-published)*

---

## 2. Prerequisites

All four prerequisites must be in place before running the orchestrator.

### 2.1 Claude Code via LiteLLM

- Claude Code CLI installed and authenticated against the company LiteLLM endpoint.
- Verify: open a terminal, run `claude --version`. You should see a version number.

**Setup guides — select the guide for your platform and network setup:**

| Platform | Guide |
|---|---|
| Mac | [LiteLLM with Claude Code — Setup Guide for Mac](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1266581586/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Mac) |
| Windows — with Cloudflare | [LiteLLM with Claude Code — Setup Guide for Windows](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows) |
| Windows — without Cloudflare (WSL) | *Guide not yet published — see [OP-08](OPEN_POINTS.md#op-08--windows-wsl-setup-guide-not-yet-published)* |

### 2.2 vibing-steampunk MCP Binary

The `vsp.exe` binary is the SAP connector that allows Claude agents to read and write ABAP objects via RFC.

- **Required location:** `C:/Users/<YOUR_USERNAME>/.local/bin/vsp.exe`
- The `.mcp.json` in this repo already points to `C:/Users/YosuaPranata/.local/bin/vsp.exe`. Each developer must update this path if their username differs (see [Section 3.3](#33-configure-mcpjson)).
- **To obtain `vsp.exe`:** Go to [github.com/oisee/vibing-steampunk/releases/latest](https://github.com/oisee/vibing-steampunk/releases/latest) and download the binary for your platform:

  | Platform | File to download | Rename to |
  |---|---|---|
  | Windows | `vsp-windows-amd64.exe` | `vsp.exe` |
  | Mac (Apple Silicon) | `vsp-darwin-arm64` | `vsp` |

Verify it is working: after configuring `.mcp.json` and restarting Claude Code, look for the `vibing_steampunk` entry in Claude Code's connected MCP servers list.

### 2.3 Environment Variables

Copy `.env.template` to `.env` at the project root and fill in your SAP credentials:

```bash
cp .env.template .env
```

Then edit `.env`:

```
SAP_URL=https://<SAP_HOSTNAME>:8001
SAP_USER=<YOUR_SAP_USERNAME>
SAP_CLIENT=100
SAP_PASSWORD=<YOUR_SAP_PASSWORD>
```

`.env` is gitignored — do not commit it. `.env.template` (with placeholders) is tracked in git and is the starting point for every developer.

### 2.4 Network Access

The machine running Claude Code must be able to reach your SAP system RFC endpoints. Confirm with your Basis or network team if you are on VPN or working remotely.

---

## 3. Installation

### 3.1 Clone the Repo

```bash
git clone <internal-repo-url> abap_orchestrator
cd abap_orchestrator
```

Or pull the latest version if you already have it:

```bash
git pull
```

### 3.2 Configure SAP Connections

Copy the template and fill in your hostnames:

```bash
cp config/sap_connections.json.template config/sap_connections.json
```

Open `config/sap_connections.json` and replace each `<HOSTNAME>` placeholder with the actual RFC hostname for your landscape. This file is gitignored — do not commit it.

```json
{
  "ZLLM_READ": {
    "ashost": "<DD1_HOSTNAME>",
    "sysnr":   "00",
    "client":  "100",
    "user":    "ZLLM_READ",
    "passwd":  "${ZLLM_READ_PASSWORD}"
  },
  "ZLLM_WRITE": {
    "ashost": "<DS1_HOSTNAME>",
    "sysnr":   "00",
    "client":  "100",
    "user":    "ZLLM_WRITE",
    "passwd":  "${ZLLM_WRITE_PASSWORD}"
  }
}
```

> Note: `${ZLLM_READ_PASSWORD}` is resolved at runtime from the environment variable — do not replace this with the actual password.

### 3.3 Configure `.mcp.json`

Open `.mcp.json` at the project root. There are two values to update:

**1. Your vsp.exe path** — update if your Windows username differs:

```json
"command": "C:/Users/<YOUR_USERNAME>/.local/bin/vsp.exe"
```

**2. Your source system** — update `-s` to the SAP system ID you read from:

```json
"args": ["-s", "DD3", "--enable-transports", "--allow-transportable-edits"]
```

Change `"DD3"` to your source system ID (e.g. `"DD1"`, `"DS1"`). This tells all agents which system to read ABAP objects from.

> If you work across multiple source systems, you will need to update this value and restart Claude Code each time you switch.

### 3.4 Set Environment Variables

Add your SAP credentials to the `.env` file (see [Section 2.3](#23-environment-variables)).

### 3.5 Restart Claude Code

Close and reopen Claude Code (or reload the window) so it picks up the updated `.mcp.json` and environment variables. Confirm the MCP server is connected — you should see `vibing_steampunk` in the active MCP servers list.

### 3.6 Verify the Connection

In a Claude Code chat, run a quick test:

```
What is the current SAP connection? (call GetConnectionInfo)
```

If the connection is working, you will see your system ID, user, and client. If you see an error, recheck `.mcp.json`, your SAP hostname, and that your RFC user credentials are correct.

### 3.7 Prepare Your First Ticket Folder

The orchestrator creates the folder structure automatically when you run it. Alternatively, set it up manually:

```bash
mkdir -p project/CR-12345/input
# Drop the functional specification here:
cp /path/to/your/fs.md project/CR-12345/input/fs_original.md
```

A sample functional specification is provided at `project/CR-12345/input/fs_original.md` for reference.

---

## 4. How to Use

### 4.1 Full Pipeline (Recommended)

Run all three stages end-to-end with automatic pause gates:

```
/abap-orchestrator <ticket-id> ./project/<ticket-id>/input/fs_original.md
```

**Example:**
```
/abap-orchestrator CR-12345 ./project/CR-12345/input/fs_original.md
```

The orchestrator will:
1. Display the SAP source system it detected from `.mcp.json`.
2. Spawn the FS Review agent and display its findings.
3. **Pause** — you type `CONTINUE` or `REVISE`.
4. Spawn the Technical Spec agent and display the spec and test scenarios.
5. **Pause** — you type `CONTINUE` or `REVISE`.
6. Ask you to choose a target write system and provide a TR number.
7. Spawn the Development agent, which shows diffs and waits for your approval per object.

### 4.2 Pause Gates

At the end of Stages 1 and 2, the orchestrator stops and shows you the outputs. Respond with:

| Response | Effect |
|---|---|
| `CONTINUE` | Proceed to the next stage |
| `REVISE` | Re-run the current stage (useful if the FS was updated or you want a fresh pass) |

### 4.3 Development Approval Gate (Stage 3)

For each ABAP object the dev agent wants to modify, it will:
1. Show you a diff of the proposed change.
2. Wait for your explicit approval.

To approve a write to SAP:
```
APPROVE <OBJECT_NAME> to <SYSTEM_ID>
```

Example:
```
APPROVE ZFI_WASTAGE_RECLASS_SSC to DD3
```

To reject (skip that object without writing):
```
REJECT <OBJECT_NAME>
```

The agent will never write to SAP without a matching `APPROVE` typed in the session. Every approved write is logged in `project/<ticket-id>/03_change_log.md` before execution.

### 4.4 Individual Stages

You can run any stage on its own. This is useful when you want to re-run a single stage or pick up after a break.

```
# Stage 1 — FS Review
/fs-review <ticket-id> ./project/<ticket-id>/input/fs_original.md

# Stage 2 — Technical Specification  (requires Stage 1 output)
/ts-spec <ticket-id>

# Stage 3 — Development              (requires Stage 1 and 2 output)
/dev <ticket-id>
```

**Dependencies between stages:**
- `/ts-spec` requires `project/<ticket-id>/01_revised_fs.md`
- `/dev` requires `project/<ticket-id>/01_revised_fs.md` and `project/<ticket-id>/02_technical_spec.md`

### 4.5 Stage Outputs Reference

After each stage completes, you will find the following files:

```
project/<ticket-id>/
├── input/
│   └── fs_original.md          ← you provide this before Stage 1
├── src/                        ← local ABAP source copies (populated by dev-agent)
│
├── 01_fs_questions.md          ← Stage 1: clarification questions for the requester
├── 01_locked_objects.md        ← Stage 1: list of locked objects with TR and owner
├── 01_revised_fs.md            ← Stage 1: annotated FS used as input to Stage 2
│
├── 02_technical_spec.md        ← Stage 2: exact change specs per object
├── 02_test_scenarios.md        ← Stage 2: manual test checklist (BDD style)
│
├── 03_change_log.md            ← Stage 3: approval log (who approved, when, which system, TR)
└── 03_manual_changes.md        ← Stage 3: list of changes the agent could not write (do these in SE38)
```

### 4.6 Stage 4 — Manual Steps (Not Automated)

After Stage 3 completes, carry out the following manually in SAP:

1. **Review `03_manual_changes.md`** — apply any changes listed there (typically: include programs, function modules, message classes, text elements without ZADT_VSP).
2. **Verify objects in SE09** — confirm all changed objects are assigned to the correct TR.
3. **Run Extended Code Check (SLIN)** — transaction SLIN on each changed object.
4. **Run ATC checks** — transaction ATC or SE80. Zero Priority 1 findings required before releasing.
5. **Execute test scenarios** from `02_test_scenarios.md` — manual walkthrough in the target system.
6. **Peer code review** — have a second developer review `02_technical_spec.md` and the diffs in `src/`.
7. **Release the TR** — via SE09 when all checks pass.

---

## 5. DH ABAP Standards Enforced

The development agent automatically applies **Delivery Hero ABAP Guidelines V0.7** to all generated code. Key rules:

- **Naming:** `Z` prefix on all custom objects; functional area infix (e.g. `ZFI_`, `ZSD_`, `ZCL_FI_`)
- **OOP only:** No `FORM/PERFORM`; use static class methods
- **Syntax:** ABAP 7.40+ inline declarations, `VALUE`, `NEW`, field symbols
- **No hardcoding:** No generic variable names (`lv_flag`, `lv_temp` are prohibited)
- **Authority checks:** `AUTHORITY-CHECK` on every SAP access, with a comment explaining the authorization object
- **Standard table modifications:** BAPIs only — no `UPDATE/INSERT/DELETE` on SAP standard tables
- **Exception handling:** Class-based exceptions with `TRY/CATCH`; no `MESSAGE` in class or FM layers
- **Modification log:** Every code change wrapped in modification log comments: `Begin/End of Insert on <date> for <ticket> by <user>`

ATC checks in Stage 4 serve as the backstop for any standards violations not caught by the agent.

Full standards are embedded in `.claude/agents/dev.md`.

---

## 6. Known Limitations & Manual Workarounds

The vibing-steampunk MCP tools cover the most common object types, but several ABAP object types require manual SAP edits. The dev agent lists all required manual steps in `03_manual_changes.md`.

| Object Type | Read | Write via Agent | Workaround |
|---|---|---|---|
| Programs (`PROG`) | Yes | Yes | — |
| Classes (`CLAS`) | Yes | Yes | — |
| Interfaces (`INTF`) | Yes | Yes | — |
| CDS views (`DDLS`) | Yes | Yes | — |
| **Include programs (`INCL`)** | Yes | **No** | SE38 manual edit |
| **Function modules (`FUNC`)** | Yes | **No** | SE37 manual edit on parent FUGR |
| **Function groups (`FUGR`)** | Yes | **No** | SE37 manual edit |
| **Message classes (`MSAG`)** | Read only | **No** | SE91 manual edit |
| **Text elements** | Yes (with ZADT_VSP) | **No without ZADT_VSP** | SE38 Text Elements tab |
| **Transport release** | List/view only | **No** | SE09 manual release |
| **DDIC views / tables** | Read only | **No** | SE11 manual edit |

> **Most tickets that include include programs (INCL) will require manual SE38 edits.** This is the most common limitation encountered in practice. See the example in `CR-6000018866/` for a real walkthrough.

---

> **Open points and challenges** are tracked separately in [OPEN_POINTS.md](OPEN_POINTS.md).

*Last updated: April 2026*
