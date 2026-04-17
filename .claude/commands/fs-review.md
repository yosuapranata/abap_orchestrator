---
name: fs-review
description: Run Stage 1 — FS Review for a given ticket.
---

Run Stage 1 (FS Review) for the ticket provided in $ARGUMENTS.

Parse the arguments as: `<ticket-id> <path-to-fs-document>`

## Setup

- Confirm `./project/<ticket-id>/input/` and `./project/<ticket-id>/src/` exist; create them if not.
- Copy the FS document to `./project/<ticket-id>/input/fs_original.md` if not already there.

## Spawn Agent

Spawn `fs-review-agent` with:
- Ticket ID: `<ticket-id>`
- Input FS path: `./project/<ticket-id>/input/fs_original.md`
- Connection profile: ZLLM_READ

Wait for completion.

## Review Gate

Confirm these output files exist:
- `./project/<ticket-id>/01_fs_questions.md`
- `./project/<ticket-id>/01_locked_objects.md`
- `./project/<ticket-id>/01_revised_fs.md`

If any are missing, report the failure and stop — do not proceed.

Display all three files to the developer, then ask:

> "Stage 1 complete. Review the outputs above. Type **CONTINUE** to proceed to Technical Specification, or **REVISE** to re-run Stage 1 with updated input."

- **CONTINUE** → done.
- **REVISE** → ask the developer for the updated FS path and re-run from Setup.
- Anything else → re-display the prompt.
