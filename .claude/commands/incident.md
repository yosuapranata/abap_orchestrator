---
name: incident
description: Run incident analysis (Stage 0 — pre-pipeline RCA) for a given incident.
argument-hint: <incident-no>
---

Run incident analysis for the incident provided in $ARGUMENTS.

Parse the arguments as: `<incident-no>` (single argument). If no incident number is supplied, halt with:

> Usage: `/incident <incident-no>`
> Example: `/incident INC-2026-0421-001`

## Setup

### Step 0 — Derive source system

Read `.mcp.json` and extract the value passed after the `-s` flag in the `vibing_steampunk` MCP server's `args` array. This is the read-only source system the agent will query for dumps and traces.

If the `-s` flag or its value is missing, halt with:

> **CONFIGURATION ERROR — `/incident` halted.**
> The `vibing_steampunk` MCP entry in `.mcp.json` does not specify a source system via the `-s` flag.
> Add the `-s <SYSTEM_ID>` argument and restart the session.

Display the resolved system ID to the developer:

> Source system (from `.mcp.json -s`): `<source_system>`
> Dumps and traces will be pulled from this system. If the incident is on DQ1/DP1, upload the dump/trace to `incident/<incident-no>/input/` instead.

### Step 1 — Folder structure

Ensure the following exist (create idempotently with `mkdir -p`):
- `incident/<incident-no>/`
- `incident/<incident-no>/input/`
- `incident/<incident-no>/src/`

### Step 2 — Probe pre-uploaded inputs

List `incident/<incident-no>/input/` and capture the filenames. Display them to the developer:

> Pre-uploaded inputs found: `<comma-separated list, or "none">`

This list is passed to the agent so it knows which artifacts the developer has already supplied versus what it needs to pull from VSP.

## Spawn Agent

Spawn `incident-analyst-agent` (via the Task tool) with:
- Incident number: `<incident-no>`
- Source system: `<source_system>` (from Step 0)
- Working directory: absolute path to `incident/<incident-no>/`
- Pre-uploaded input files: the list from Step 2
- Connection profile: ZLLM_READ
- Instruction: the agent owns interactive questioning of the developer for dump/trace filters (date range, exception, user, dump_id, trace_id) and for any missing context about what was reported.

Wait for completion.

## MCP and SAP Connectivity

### If MCP tools are unavailable
If the agent reports an MCP unavailability halt, surface its message verbatim and stop. Do not retry. Do not produce any wrapper output.

### If MCP is available but the SAP connection fails
If the agent reports a SAP connection failure halt, surface its message verbatim and stop. Do not retry beyond the agent's own one-shot retry.

## Review Gate

Confirm at minimum the following output files exist:
- `incident/<incident-no>/01_summary.md`
- `incident/<incident-no>/04_root_cause.md`
- `incident/<incident-no>/05_fix_recommendation.md`

Plus at least one of:
- `incident/<incident-no>/02_dump_analysis.md`
- `incident/<incident-no>/03_trace_analysis.md`

If the mandatory files are missing, report which ones are absent and stop — do not proceed.

Display the file paths to the developer, then print inline:
- The **Severity** and **Fix category** lines from `05_fix_recommendation.md`
- The one-sentence root cause from the top of `04_root_cause.md`
- The **Suggested next command** line from `05_fix_recommendation.md`

Then ask:

> "Incident analysis complete. Review the outputs above.
> Type **PROCEED** to run the suggested next command, **REVISE** to re-run the incident analysis with updated input, or **CLOSE** if no further action is needed."

- **PROCEED** → print the suggested command from `05_fix_recommendation.md` and stop. Let the developer trigger it manually — do not auto-spawn the next stage.
- **REVISE** → ask the developer what to update (additional uploaded files, different dump/trace filters, more context) and re-run from Step 2.
- **CLOSE** → confirm the incident is closed without code change. Stop.
- Anything else → re-display the prompt.
