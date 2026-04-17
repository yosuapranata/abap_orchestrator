# Stage 1 — Revised Functional Specification
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Original Author:** Pavithra S
**Revised by:** FS Review Agent (Claude), 2026-04-16
**Source system reviewed:** DD3

---

## Summary

Program `ZFI_WASTAGE_RECLASS` (Wastage/Refund Order — GL Reclassification) posts parking journal entries to reclassify FoodPanda revenue from revenue GLs into wastage/refund GLs for full-refund and full-wastage orders.

Two changes are in-scope for this ticket:

1. **Document type change** — The parking document should use doc type **SX** instead of SA (applies to all documents posted by this program, as all relate to wastage/refund reclassification which involves IC GL 86600099).
2. **Posting date parameter** — A new mandatory input field "Reclassification Posting Date" must be added to the selection screen. It is mandatory only when running in **Post Reclassification** mode.

---

## Current State (as-is in DD3)

### Program Structure

| Object | Type | Package | Description |
|--------|------|---------|-------------|
| ZFI_WASTAGE_RECLASS | PROG/P | ZFI_WASTAGE_RECLASSIFICATION | Main report program |
| ZFI_WASTAGE_RECLASS_TOP | PROG/I | Z_FI | Data declarations top include |
| ZFI_WASTAGE_RECLASS_SSC | PROG/I | Z_FI | Selection screen include |
| ZFI_WASTAGE_RECLASS_EVT | PROG/I | Z_FI | ABAP events (INITIALIZATION, START-OF-SELECTION) |
| ZCL_FI_WASTAGE_RECLASS | CLAS/OC | ZFI_WASTAGE_RECLASSIFICATION | Main processing class |

### Existing Selection Screen Parameters

**Block B01 (Document Selection):**
- `P_BUKRS` — Company code (obligatory, default 3801)
- `P_DATE_F` — Invoice date from (obligatory)
- `P_DATE_T` — Invoice date to (obligatory)
- `SO_INVNO` — Invoice document number (select-options)
- `SO_WSTGE` — Wastage indicator (select-options, defaults 02 and 04)

**Block B02 (Processing Mode):**
- `RB_EXTR` — Extract only (default selected)
- `RB_POST` — Post reclassification

**Block B03 (Recipients):**
- `SO_UNAME` — Recipient user IDs (obligatory)

### Change 1: Doc Type (Already Done — Active in DD3)

In `ZCL_FI_WASTAGE_RECLASS` (protected constants section):
```abap
*-- Begin of Change on 12.01.2026 for 6000018866 by P024736
CONSTANTS:
  gc_doc_type_gl_pst TYPE blart VALUE 'SX',
*-- End of Change on 12.01.2026 for 6000018866 by P024736
```
Previously `VALUE 'SA'`. This constant is used directly in `post_reclassification` → `ls_doc_header-doc_type = gc_doc_type_gl_pst`.

**Status: COMPLETE and active.**

### Change 2: Posting Date (Class done; SSC and EVT incomplete)

`ZCL_FI_WASTAGE_RECLASS` already has (active):
- Constructor parameter: `!IV_FI_POSTING_DATE TYPE BUDAT`
- Instance variable: `DATA mv_fi_posting_date TYPE budat`
- Validation (in `validate_input`): mandatory in post mode → `MESSAGE e152(vhurl)`
- Posting logic (in `post_reclassification`): `lv_posting_date = mv_fi_posting_date`, used for `doc_date`, `pstng_date`, fiscal year/period derivation via `FI_PERIOD_DETERMINE`

**Missing:** The selection screen include and event include have NOT yet been updated:
- `ZFI_WASTAGE_RECLASS_SSC` — no `P_BUDAT` parameter
- `ZFI_WASTAGE_RECLASS_EVT` — `CREATE OBJECT gr_wastage_util` does not pass `IV_FI_POSTING_DATE`

---

## To-Be Specification (What Must Still Be Implemented)

### Change 2a — Selection Screen (`ZFI_WASTAGE_RECLASS_SSC`)

Add a new parameter `P_BUDAT` (posting date) to **Block B02** (with the radio buttons), positioned after `RB_POST`:

```abap
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc ##NEEDED.
  "--- BEGIN OF INSERT for 6000018866 ---
  PARAMETERS:
    p_budat TYPE budat.   "Reclassification posting date
  "--- END OF INSERT for 6000018866 ---
SELECTION-SCREEN END OF BLOCK b02.
```

**Selection text for P_BUDAT:** `Rec doc posting date` (as per FS) — to be set in text elements.

**Screen behaviour:** P_BUDAT is always visible but the CLASS validates it as mandatory only in post mode. No `AT SELECTION-SCREEN OUTPUT` hide logic is required (confirmed by existing class validation pattern).

### Change 2b — Event Include (`ZFI_WASTAGE_RECLASS_EVT`)

Pass `p_budat` to the class constructor in `START-OF-SELECTION`:

```abap
START-OF-SELECTION.
  CLEAR gr_wastage_util.

  CREATE OBJECT gr_wastage_util
    EXPORTING
      iv_bukrs             = p_bukrs
      iv_budat_fr          = p_date_f
      iv_budat_to          = p_date_t
      irng_invno           = CONV zcl_fi_wastage_reclass=>ty_r_invdocno( so_invno[] )
      irng_wastage         = CONV zcl_fi_wastage_reclass=>ty_r_wastage( so_wstge[] )
      irng_uname           = CONV zcl_fi_wastage_reclass=>ty_r_uname( so_uname[] )
      iv_is_disp           = rb_extr
      "--- BEGIN OF INSERT for 6000018866 ---
      iv_fi_posting_date   = p_budat.
      "--- END OF INSERT for 6000018866 ---
```

---

## Out of Scope

- No changes to the CDS view `ZCDS_FI_WASTAGE_INVDOC`
- No changes to the email template `ZFI_WASTAGE_RECLASS_EMAIL`
- No changes to the wastage indicator defaulting logic
- No changes to authorization checks
- The doc type change does NOT need conditional GL-86600099 logic — the blanket SX approach already implemented in the class is confirmed correct

---

## Open Questions (Pending Developer/Functional Confirmation)

See `01_fs_questions.md` — particularly **Q1** (conditional vs unconditional SX) and **Q4** (screen block placement for posting date). These should be answered before Stage 2 begins.

---

## Transport Information

| TR | Contents |
|----|---------|
| DD3K900402 | ZFI_WASTAGE_RECLASS, ZFI_WASTAGE_RECLASS_SSC, ZFI_WASTAGE_RECLASS_EVT, ZFI_WASTAGE_RECLASS_TOP, text elements — all inactive, locked by P024736 |

Remaining development (SSC + EVT updates) should be added to **DD3K900402** to keep all changes in one TR.

---
