---
name: ts-spec
description: Run Stage 2 — Technical Specification for a given ticket.
---

Run Stage 2 (Technical Specification) for the ticket provided in $ARGUMENTS.

Parse the arguments as: `<ticket-id>`

## Prerequisite Check

Verify `./project/<ticket-id>/01_revised_fs.md` exists.
If missing, halt: "Stage 1 output not found. Run `/fs-review <ticket-id> <path-to-fs>` first."

## Spawn Agent

Spawn `ts-agent` with:
- Ticket ID: `<ticket-id>`
- Revised FS path: `./project/<ticket-id>/01_revised_fs.md`
- Local ABAP folder: `./project/<ticket-id>/src/`
- Connection profile: ZLLM_READ

Wait for completion.

## Review Gate

Confirm these output files exist:
- `./project/<ticket-id>/02_technical_spec.md`
- `./project/<ticket-id>/02_test_scenarios.md`

If any are missing, report the failure and stop — do not proceed.

Display both files to the developer, then ask:

> "Stage 2 complete. Review the Technical Specification. Type **CONTINUE** to proceed to Development, or **REVISE** to re-run Stage 2."

- **CONTINUE** → done.
- **REVISE** → re-run from Spawn Agent.
- Anything else → re-display the prompt.
