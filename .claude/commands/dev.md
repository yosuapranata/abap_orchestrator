---
name: dev
description: Run Stage 3 — Development for a given ticket.
---

Run Stage 3 (Development) for the ticket provided in $ARGUMENTS.

Parse the arguments as: `<ticket-id>`

## Prerequisite Check

Verify both files exist:
- `./project/<ticket-id>/01_revised_fs.md` — if missing, halt: "Run `/fs-review` first."
- `./project/<ticket-id>/02_technical_spec.md` — if missing, halt: "Run `/ts-spec` first."

## Pre-flight Questions

Ask the developer before spawning:
1. "Which target system for SAP writes? (DS1 / DX1 / DD3 / DD1-with-approval)"
2. "Do you have an existing TR number to use, or should the agent create one?"

## Spawn Agent

Spawn `dev-agent` with:
- Ticket ID: `<ticket-id>`
- Revised FS path: `./project/<ticket-id>/01_revised_fs.md`
- Technical Spec path: `./project/<ticket-id>/02_technical_spec.md`
- Local ABAP folder: `./project/<ticket-id>/src/`
- Target system: (developer's answer)
- TR number: (developer's answer, or "create new")
- Connection profile: ZLLM_WRITE

The dev-agent will pause internally at its approval gate — do not interrupt that interaction.

Wait for dev-agent completion.

## Completion Check

Confirm these outputs exist:
- Modified ABAP files in `./project/<ticket-id>/src/`
- `./project/<ticket-id>/03_change_log.md`
- `./project/<ticket-id>/03_manual_changes.md`

If any are missing, report the failure to the developer and stop.

Otherwise display:

> "Stage 3 complete. Proceed to Stage 4 (Manual):
> 1. Verify objects in DD1 and confirm TR assignment in SE09.
> 2. Run Extended Code Check (SLIN).
> 3. Run ATC checks — zero Priority 1 errors required.
> 4. Execute test scenarios from `02_test_scenarios.md`.
> 5. Write code review document.
> 6. Release TR when all checks pass."
