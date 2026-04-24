# Sample Incident — INC-2026-0421-001

This folder is a **sample scaffold** for the `/incident` workflow. It exists so the `incident/` folder convention is visible in the repository. It is not a real incident.

## How to use this folder for a real incident

1. Copy this folder structure to a new path keyed on your real incident number, e.g.:

   ```
   incident/INC-2026-0421-002/
   ├── input/
   └── src/
   ```

2. If the incident is on the source system VSP is configured to read (`.mcp.json -s`), leave `input/` empty — the agent will pull the dump and trace directly via `ListDumps` / `GetDump` / `ListTraces` / `GetTrace`.

3. If the incident is on a system VSP cannot reach (typically DQ1 or DP1), export the dump from ST22 and/or the trace from ST05/SAT into `input/` before running `/incident`. See `input/SAMPLE_shortdump.txt` for an example of the expected format.

4. Run the analysis:

   ```
   /incident INC-2026-0421-002
   ```

The agent will produce up to five output files in this folder:

| File | Always | Conditional |
|------|--------|-------------|
| `01_summary.md` | Always | — |
| `02_dump_analysis.md` | — | Only if a dump exists |
| `03_trace_analysis.md` | — | Only if a trace exists |
| `04_root_cause.md` | Always | — |
| `05_fix_recommendation.md` | Always | — |

At least one of `02_*` or `03_*` must be produced. The agent will halt with a request for more input if neither dump nor trace is available.

The `05_fix_recommendation.md` file always ends with a **Suggested next command** line — typically `/fs-review`, `/ts-spec`, `/dev`, or `no code change` — which the developer triggers manually.

## What this sample contains

- `input/SAMPLE_shortdump.txt` — placeholder ST22 dump excerpt with usage notes. **Delete or replace this for any real incident.**
- `src/.gitkeep` — empty placeholder so the source-download folder is tracked. The agent will populate this with `<NAME>.prog.abap` / `<NAME>.clas.abap` etc. at runtime.
