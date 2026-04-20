# ABAP Orchestrator

AI-augmented ABAP development lifecycle using Claude Code agents and vibing-steampunk (MCP-based SAP connector).

---

## TL;DR

- Three Claude Code subagents handle FS Review, Technical Specification, and Development in sequence.
- One orchestrator skill (`/abap-orchestrator`) coordinates them end-to-end for a given ticket.
- Agents are read-only against DD1/DQ1. Writes to SAP require explicit developer approval at runtime.
- All stage outputs land in `./project/<ticket-id>/` — agents communicate through the file system, not memory.

---

## Folder Structure

```
abap_orchestrator/
├── .env                                ← your SAP credentials (gitignored — never commit)
├── .env.template                       ← credential template with placeholders (tracked in git)
├── .gitignore                          ← excludes .env; tracks .env.template
├── .mcp.json                           ← MCP server configuration (vibing-steampunk)
├── .claude/
│   ├── agents/
│   │   ├── fs-review.md               ← Stage 1: FS reviewer (read-only, claude-sonnet-4-6)
│   │   ├── ts-spec.md                 ← Stage 2: technical spec producer (read-only, claude-sonnet-4-6)
│   │   └── dev.md                     ← Stage 3: code writer with approval gate (claude-sonnet-4-6)
│   ├── commands/
│   │   ├── abap-orchestrator.md       ← /abap-orchestrator full pipeline command
│   │   ├── fs-review.md               ← /fs-review run Stage 1 only
│   │   ├── ts-spec.md                 ← /ts-spec run Stage 2 only
│   │   └── dev.md                     ← /dev run Stage 3 only
│   ├── skills/
│   │   └── abap-orchestrator.md       ← orchestrator logic (commands delegate here)
│   └── settings.json                  ← Claude Code permission settings
├── config/
│   ├── sap_connections.json           ← documentation only (not used at runtime)
│   └── access_policy.json             ← which agent can access which system/operation
└── project/                           ← runtime output: one subfolder per ticket
    └── <ticket-id>/                   ← e.g. CR-12345 (see project/CR-12345/ for sample)
        ├── input/
        │   └── fs_original.md         ← developer drops FS here before running
        ├── src/                       ← downloaded and modified ABAP source files
        ├── 01_fs_questions.md         ← Stage 1 output
        ├── 01_locked_objects.md       ← Stage 1 output
        ├── 01_revised_fs.md           ← Stage 1 output
        ├── 02_technical_spec.md       ← Stage 2 output
        ├── 02_test_scenarios.md       ← Stage 2 output
        ├── 03_change_log.md           ← Stage 3 output
        └── 03_manual_changes.md       ← Stage 3 output (non-code changes)
```

---

## Prerequisites

1. **Claude Code** CLI installed and authenticated against the company LiteLLM endpoint. See the setup guide for your platform:

   | Platform | Setup Guide |
   |---|---|
   | Mac | [LiteLLM with Claude Code — Setup Guide for Mac](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1266581586/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Mac) |
   | Windows | [LiteLLM with Claude Code — Setup Guide for Windows](https://atlassian.cloud.deliveryhero.group/wiki/spaces/FINDEVC/pages/1260716053/Lite+LLM+with+Claude+Code+-+Setup+Guide+for+Windows) |

2. **vibing-steampunk MCP binary** — download from [github.com/oisee/vibing-steampunk/releases/latest](https://github.com/oisee/vibing-steampunk/releases/latest) and place at `C:/Users/<YOUR_USERNAME>/.local/bin/`:

   | Platform | File to download | Rename to |
   |---|---|---|
   | Windows | `vsp-windows-amd64.exe` | `vsp.exe` |
   | Mac (Apple Silicon) | `vsp-darwin-arm64` | `vsp` |

   Update the path in `.mcp.json` if your username differs from the default.

3. **SAP credentials** — copy `.env.template` to `.env` and fill in your credentials:
   ```bash
   cp .env.template .env
   ```
   Then edit `.env` with your `SAP_URL`, `SAP_USER`, `SAP_CLIENT`, and `SAP_PASSWORD`. Never commit `.env`.

4. **`.mcp.json` — source system and binary path** — open `.mcp.json` at the project root and verify two values:

   ```json
   "command": "C:/Users/<YOUR_USERNAME>/.local/bin/vsp.exe",
   "args": ["-s", "DD3", "--enable-transports", "--allow-transportable-edits"]
   ```

   | Field | What to change |
   |---|---|
   | `command` | Update `<YOUR_USERNAME>` if it differs from the default |
   | `-s` | Set to the SAP system ID you want agents to **read from** (e.g. `DD1`, `DS1`, `DD3`) |

   Restart Claude Code after any change to `.mcp.json`. The write target system is selected interactively at Stage 3 — no config change needed for that.

---

## How to Run

### Option A — Full pipeline (recommended)

**1. Drop the FS document**

Place the functional specification in the ticket's input folder:

```
project/<ticket-id>/input/fs_original.md
```

A sample FS and folder structure is provided under `project/CR-12345/` for reference.

**2. Invoke the orchestrator**

```
/abap-orchestrator <ticket-id> ./project/<ticket-id>/input/fs_original.md
```

**3. Follow the prompts**

The orchestrator pauses at each stage boundary and asks you to type `CONTINUE` or `REVISE` before proceeding. At the development stage, the dev agent will display a diff and require:

```
APPROVE <OBJECT_NAME> to <SYSTEM_ID>
```

before writing anything to SAP.

---

### Option B — Individual stages

Run any stage independently. Each command checks that the previous stage's outputs exist before proceeding.

```
# Stage 1 — FS Review
/fs-review <ticket-id> ./project/<ticket-id>/input/fs_original.md

# Stage 2 — Technical Specification (requires Stage 1 output)
/ts-spec <ticket-id>

# Stage 3 — Development (requires Stage 1 and 2 output)
/dev <ticket-id>
```

This is useful for re-running a single stage after a REVISE without going through the full pipeline.

---

## Available Commands

All commands are invoked from the Claude Code chat prompt.

| Command | Arguments | Description |
|---|---|---|
| `/abap-orchestrator` | `<ticket-id> <path-to-fs>` | Run the full pipeline (Stages 1–3) end-to-end with pause gates between each stage |
| `/fs-review` | `<ticket-id> <path-to-fs>` | Stage 1 only — review the FS against live SAP objects, produce questions and revised FS |
| `/ts-spec` | `<ticket-id>` | Stage 2 only — produce Technical Specification and test scenarios from the revised FS |
| `/dev` | `<ticket-id>` | Stage 3 only — implement ABAP changes locally and push to SAP after per-object approval |

**Prerequisites between stages:**
- `/ts-spec` requires `01_revised_fs.md` (output of `/fs-review`)
- `/dev` requires `01_revised_fs.md` and `02_technical_spec.md` (outputs of Stages 1 and 2)

**Example — step-by-step for CR-12345:**

```
/fs-review CR-12345 ./project/CR-12345/input/fs_original.md
# → review 01_fs_questions.md, 01_locked_objects.md, 01_revised_fs.md
# → type CONTINUE or REVISE

/ts-spec CR-12345
# → review 02_technical_spec.md, 02_test_scenarios.md
# → type CONTINUE or REVISE

/dev CR-12345
# → select target system and TR, approve each object diff before it is pushed
```

---

## Agents

All agents run on `claude-sonnet-4-6`.

| Agent | File | Stage | SAP Access |
|-------|------|-------|------------|
| fs-review-agent | `.claude/agents/fs-review.md` | 1 — FS Review | Read-only (source system configured in `.mcp.json`) |
| ts-agent | `.claude/agents/ts-spec.md` | 2 — Technical Spec | Read-only (source system configured in `.mcp.json`) |
| dev-agent | `.claude/agents/dev.md` | 3 — Development | Read (source system in `.mcp.json`), Write (developer-selected at runtime; DQ1 and DP1 prohibited) |

---

## SAP System Access Policy

| System | Access | Notes |
|--------|--------|-------|
| DD1 (Development) | Read-only | Source read system for all agents; no agent-initiated writes |
| DQ1 (Quality) | Read-only | No writes under any circumstance |
| DP1 (Production) | No access | Absolutely prohibited |
| DS1 / DX1 / DD3 (Sandbox) | Read + Write | Typical write targets for dev-agent; writes require explicit per-object approval |

Enforced via `config/access_policy.json` and hardcoded in each agent's system prompt.

---

## Stage Outputs

| Stage | Output Files |
|-------|-------------|
| 1 — FS Review | `01_fs_questions.md`, `01_locked_objects.md`, `01_revised_fs.md` |
| 2 — Technical Spec | `02_technical_spec.md`, `02_test_scenarios.md` |
| 3 — Development | `03_change_log.md`, `03_manual_changes.md`, modified `src/*.abap` files |
| 4 — Manual (not automated) | ATC checks, extended code check, test execution, code review, TR release |

---

## Security Notes

- `.env` is gitignored — never commit it. Use `.env.template` as the starting point.
- SAP credentials (`SAP_URL`, `SAP_USER`, `SAP_CLIENT`, `SAP_PASSWORD`) are read from `.env` at runtime.
- The dev-agent will refuse to write to DQ1 or DP1 even if instructed to do so.
- Every write is logged with timestamp, approver name, target system, and TR number in `03_change_log.md`.

---

## ABAP Standards

All generated ABAP code follows **Delivery Hero ABAP Guidelines V0.7**:
- `Z` prefix for all custom objects
- OOP mandatory — no `FORM/PERFORM`
- ABAP 7.40+ syntax only
- No hardcoding, no generic variable names
- Authority checks on every SAP access
- BAPIs for all SAP standard table modifications

Full standards are embedded in `.claude/agents/dev.md`.
