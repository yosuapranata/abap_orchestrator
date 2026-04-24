# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## What This Repo Does

AI-augmented ABAP development lifecycle using three Claude Code subagents coordinated by an orchestrator skill. Agents communicate through the file system — not memory. All stage outputs land in `./project/<ticket-id>/`.

**Pipeline:** FS Review → Technical Specification → Development → (Manual: ATC, code review, TR release)

---

## How to Run

### Full pipeline

```
/abap-orchestrator <ticket-id> ./project/<ticket-id>/input/fs_original.md
```

The orchestrator pauses at each stage boundary and asks for `CONTINUE` or `REVISE`. At Stage 3 the dev-agent shows a diff and requires explicit per-object approval:

```
APPROVE <OBJECT_NAME> to <SYSTEM_ID>
```

### Individual stages

```
/fs-review <ticket-id> ./project/<ticket-id>/input/fs_original.md   # Stage 1
/ts-spec   <ticket-id>                                               # Stage 2 (needs Stage 1 output)
/dev       <ticket-id>                                               # Stage 3 (needs Stage 1+2 output)
```

### Incident analysis (pre-pipeline)

```
/incident <incident-no>                                              # Stage 0 — read-only RCA
```

Read-only root-cause analysis from short dumps (ST22) and SQL/runtime traces (ST05/SAT). The agent pulls dumps and traces directly from the source system via VSP; for incidents on systems VSP cannot reach (DQ1/DP1), upload the exported dump/trace to `incident/<incident-no>/input/` first. Output is a 5-file analysis package whose final artifact (`05_fix_recommendation.md`) is structured for handoff to `/fs-review` or `/ts-spec`.

---

## Prerequisites

1. **vibing-steampunk MCP binary** — `vsp.exe` must be installed at `C:/Users/YosuaPranata/.local/bin/vsp.exe`. The `.mcp.json` already points to it.

2. **SAP credentials** — copy `.env.template` to `.env` at the project root and fill in `SAP_URL`, `SAP_USER`, `SAP_CLIENT`, and `SAP_PASSWORD` with your credentials.

3. **Transport flag** — the MCP server is started with `--enable-transports` (already set in `.mcp.json`). Remove this flag if transport APIs cause errors on a system that doesn't support them.

---

## Architecture

### Agent / Skill Structure

| File | Role |
|------|------|
| `.claude/skills/abap-orchestrator.md` | Core orchestrator logic — spawns subagents, manages pause gates |
| `.claude/commands/abap-orchestrator.md` | `/abap-orchestrator` command — delegates to the skill |
| `.claude/commands/fs-review.md` | `/fs-review` standalone command |
| `.claude/commands/ts-spec.md` | `/ts-spec` standalone command |
| `.claude/commands/dev.md` | `/dev` standalone command |
| `.claude/commands/incident.md` | `/incident` standalone command (Stage 0 — pre-pipeline RCA) |
| `.claude/agents/fs-review.md` | Stage 1 subagent definition (`fs-review-agent`) |
| `.claude/agents/ts-spec.md` | Stage 2 subagent definition (`ts-agent`) |
| `.claude/agents/dev.md` | Stage 3 subagent definition (`dev-agent`), also contains the full DH ABAP coding standards |
| `.claude/agents/incident.md` | Stage 0 subagent definition (`incident-analyst-agent`) — read-only dump/trace analysis |

### SAP Access Policy (`config/access_policy.json`)

The **read (source) system** is not hardcoded — it is derived at runtime from the `-s` argument in `.mcp.json`. The orchestrator reads this at Step 0 and passes it to all subagents.

| Agent | Connection | Read System | Write System | Writes |
|-------|-----------|-------------|--------------|--------|
| `incident-analyst-agent` | ZLLM_READ | from `.mcp.json -s` | None | Prohibited |
| `fs-review-agent` | ZLLM_READ | from `.mcp.json -s` | None | Prohibited |
| `ts-agent` | ZLLM_READ | from `.mcp.json -s` | None | Prohibited |
| `dev-agent` | ZLLM_READ / ZLLM_WRITE | from `.mcp.json -s` | Developer-selected at Stage 3 | Per-object approval required; DQ1 and DP1 are absolutely prohibited |

### Project Folder Convention

```
project/<ticket-id>/
├── input/fs_original.md      ← developer drops FS here before running
├── src/                      ← local copies of downloaded/modified ABAP source
├── 01_fs_questions.md        ← Stage 1 output
├── 01_locked_objects.md      ← Stage 1 output
├── 01_revised_fs.md          ← Stage 1 output (input to Stage 2)
├── 02_technical_spec.md      ← Stage 2 output (input to Stage 3)
├── 02_test_scenarios.md      ← Stage 2 output
├── 03_change_log.md          ← Stage 3 output — approval log with timestamp/author/TR
└── 03_manual_changes.md      ← Stage 3 output — customizing or table entries to do manually
```

`CR-6000018866/` in the repo root is a completed example. `project/CR-12345/` is a minimal sample scaffold.

### Incident Folder Convention

Incident analysis (Stage 0, `/incident`) lives in a parallel root folder, separate from `project/` because incidents do not always lead to a code change:

```
incident/<incident-no>/
├── input/                          ← optional fallback uploads (shortdump.txt, sqltrace.txt) — only when VSP cannot reach the system that produced the incident
├── src/                            ← downloaded ABAP source for objects in the dump stack / trace top-N
├── 01_summary.md                   ← reported issue + acquisition log (which dump_id / trace_id, which system, which filters)
├── 02_dump_analysis.md             ← parsed short dump: exception, fault location, call stack, variable state (omitted if no dump)
├── 03_trace_analysis.md            ← parsed SQL/runtime trace: hot statements, table accesses, time profile (omitted if no trace)
├── 04_root_cause.md                ← consolidated RCA hypothesis with cited evidence
└── 05_fix_recommendation.md        ← proposed fix — structured for handoff to `/fs-review` or `/ts-spec`
```

The agent pulls dumps and traces directly from the source system via VSP (`ListDumps`, `GetDump`, `ListSQLTraces`, `ListTraces`, `GetTrace`). At least one of `02_dump_analysis.md` / `03_trace_analysis.md` must be produced — otherwise there is no diagnostic evidence to analyze.

---

## MCP Tool Limitations

Key constraints when working with `vibing_steampunk` tools — full details in `VIBING_STEAMPUNK_LIMITATIONS.md`:

- **`WriteSource`** supports: `PROG`, `CLAS`, `INTF`, `DDLS`, `BDEF`, `SRVD`. It does **not** support `INCL`, `FUNC`, `FUGR`, `VIEW`, `TABL`, `MSAG`. For unsupported types, fall back to `ImportFromFile` or document as a manual change in `03_manual_changes.md`.
- **`EditSource`** requires the `old_string` to be unique in the source (or use `replace_all: true`).
- **`CallRFC`, `RunReport`, `MoveObject`, `GitExport`** require ZADT_VSP deployed on the target SAP system.
- **Transport tools** require `--enable-transports` or `--allow-transportable-edits` flag on startup (already set in `.mcp.json`).

---

## DH ABAP Coding Standards (Summary)

The full standards are embedded in `.claude/agents/dev.md`. Key rules enforced in all generated code:

- `Z` prefix on all custom objects; functional area infix (e.g. `ZFI_`, `ZSD_`, `ZCL_FI_`)
- OOP only — no `FORM/PERFORM`; use static class methods
- ABAP 7.40+ syntax — inline declarations, `VALUE`, `NEW`, field symbols
- No hardcoding; no generic variable names (`lv_flag`, `lv_temp` forbidden)
- `AUTHORITY-CHECK` on every SAP access, with comment explaining purpose
- BAPIs for all SAP standard table modifications — never `UPDATE`/`INSERT`/`DELETE` on standard tables
- Class-based exceptions with `TRY/CATCH`; no `MESSAGE` in class/FM layers
- Every code change wrapped in modification log comments (`Begin of Insert on ... for ... by ...`)
- Change log header block required on every new program/method

---

## Security Notes

- `.env` is gitignored — never commit it. Copy `.env.template` to `.env` and fill in credentials locally.
- SAP credentials (`SAP_URL`, `SAP_USER`, `SAP_CLIENT`, `SAP_PASSWORD`) are read from `.env` at runtime.
- `dev-agent` will refuse to write to DQ1 or DP1 even if instructed. This is enforced in the agent system prompt.
- Every approved write is logged with timestamp, approver name, target system, and TR in `03_change_log.md` before the write executes.
