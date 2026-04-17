# Stage 2 — Technical Specification
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Date:** 2026-04-16
**Source System:** DD3
**TR:** DD3K900402 (existing, P024736)

---

## 1. Scope Summary

| # | Requirement | Status |
|---|------------|--------|
| R1 | Change parking document type from SA to SX | ✅ Done — active in ZCL_FI_WASTAGE_RECLASS |
| R2 | Add "Rec doc posting date" mandatory field to selection screen | ⚠️ Partial — class done; SSC and EVT still need changes |

Only **two includes** require code changes:
- `ZFI_WASTAGE_RECLASS_SSC` — add `P_BUDAT` parameter
- `ZFI_WASTAGE_RECLASS_EVT` — pass `P_BUDAT` to constructor

---

## 2. Object Inventory

| Object | Type | Package | Change Required |
|--------|------|---------|----------------|
| ZFI_WASTAGE_RECLASS | PROG/P | ZFI_WASTAGE_RECLASSIFICATION | None — wrapper only |
| ZFI_WASTAGE_RECLASS_TOP | PROG/I | Z_FI | None |
| **ZFI_WASTAGE_RECLASS_SSC** | PROG/I | Z_FI | **YES — add P_BUDAT** |
| **ZFI_WASTAGE_RECLASS_EVT** | PROG/I | Z_FI | **YES — pass P_BUDAT to constructor** |
| ZCL_FI_WASTAGE_RECLASS | CLAS/OC | ZFI_WASTAGE_RECLASSIFICATION | None — already active with all changes |

---

## 3. Detailed Change Specifications

---

### 3.1 ZFI_WASTAGE_RECLASS_SSC — Add Posting Date Parameter

**Object:** `ZFI_WASTAGE_RECLASS_SSC` (PROG/I)
**ADT URL:** `/sap/bc/adt/programs/includes/zfi_wastage_reclass_ssc`
**Transport:** DD3K900402
**Currently inactive/locked by:** P024736

#### Current Source (relevant block):
```abap
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc ##NEEDED.
SELECTION-SCREEN END OF BLOCK b02.
```

#### Change Required:

Add parameter `P_BUDAT TYPE budat` inside block B02, after `RB_POST`.

**Insertion point:** After `rb_post RADIOBUTTON GROUP proc ##NEEDED.`, before `SELECTION-SCREEN END OF BLOCK b02.`

#### Target Source (changed lines only):
```abap
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc ##NEEDED.
*-- Begin of Insert on <date> for 6000018866 by <author>
  PARAMETERS:
    p_budat TYPE budat.
*-- End of Insert on <date> for 6000018866 by <author>
SELECTION-SCREEN END OF BLOCK b02.
```

**Parameter type:** `BUDAT` (standard date type — same as existing `P_DATE_F` / `P_DATE_T`)
**Mandatory flag:** NOT declared as `OBLIGATORY` — mandatory enforcement is done by the class's `validate_input` method in post mode only. Making it OBLIGATORY on the screen would block extract-mode runs.

#### Text Element Required:

A selection text for `P_BUDAT` must be set in the program's text elements:

| Parameter | Text |
|-----------|------|
| P_BUDAT | Rec doc posting date |

This is set via SE38 → Text Elements → Selection Texts (or via `SetTextElements` MCP tool on the main program `ZFI_WASTAGE_RECLASS`).

---

### 3.2 ZFI_WASTAGE_RECLASS_EVT — Pass Posting Date to Constructor

**Object:** `ZFI_WASTAGE_RECLASS_EVT` (PROG/I)
**ADT URL:** `/sap/bc/adt/programs/includes/zfi_wastage_reclass_evt`
**Transport:** DD3K900402
**Currently inactive/locked by:** P024736

#### Current Source (START-OF-SELECTION block):
```abap
START-OF-SELECTION.
  " Create utility instance
  CLEAR gr_wastage_util.

  CREATE OBJECT gr_wastage_util
    EXPORTING
      iv_bukrs     = p_bukrs
      iv_budat_fr  = p_date_f
      iv_budat_to  = p_date_t
      irng_invno   = CONV zcl_fi_wastage_reclass=>ty_r_invdocno( so_invno[] )
      irng_wastage = CONV zcl_fi_wastage_reclass=>ty_r_wastage( so_wstge[] )
      irng_uname   = CONV zcl_fi_wastage_reclass=>ty_r_uname( so_uname[] )
      iv_is_disp   = rb_extr.
```

#### Change Required:

Add `iv_fi_posting_date = p_budat` to the `CREATE OBJECT` / `NEW` constructor call.

**Insertion point:** After `iv_is_disp = rb_extr.`, changing the period to a comma and adding the new parameter.

#### Target Source (changed lines only):
```abap
START-OF-SELECTION.
  " Create utility instance
  CLEAR gr_wastage_util.

  CREATE OBJECT gr_wastage_util
    EXPORTING
      iv_bukrs     = p_bukrs
      iv_budat_fr  = p_date_f
      iv_budat_to  = p_date_t
      irng_invno   = CONV zcl_fi_wastage_reclass=>ty_r_invdocno( so_invno[] )
      irng_wastage = CONV zcl_fi_wastage_reclass=>ty_r_wastage( so_wstge[] )
      irng_uname   = CONV zcl_fi_wastage_reclass=>ty_r_uname( so_uname[] )
      iv_is_disp   = rb_extr
*-- Begin of Insert on <date> for 6000018866 by <author>
      iv_fi_posting_date = p_budat.
*-- End of Insert on <date> for 6000018866 by <author>
```

> **Note:** `CREATE OBJECT` syntax — the last parameter ends with a period. When adding `iv_fi_posting_date`, the period moves from `iv_is_disp = rb_extr.` to `iv_fi_posting_date = p_budat.`

#### No other changes needed in EVT.

The rest of the EVT (INITIALIZATION, AT SELECTION-SCREEN ON so_uname, END-OF-SELECTION) does not require modification.

---

### 3.3 ZFI_WASTAGE_RECLASS (Main Program) — Modification Log Update Only

**Object:** `ZFI_WASTAGE_RECLASS` (PROG/P)
**Change required:** Update the modification log header to record this ticket.

#### Current Modification Log:
```abap
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
```

#### Target Modification Log:
```abap
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*<date>    |<author>      |DD3K900402|Change doc type to SX; add posting date param (6000018866)
```

---

### 3.4 Already Done — No Action Required

**`ZCL_FI_WASTAGE_RECLASS`** — All class changes are active. No further changes needed.

For reference, what is already implemented in the class:

| Method | Change | Mod-log date |
|--------|--------|-------------|
| (class constant) | `gc_doc_type_gl_pst` changed to `'SX'` | 12.01.2026 |
| `CONSTRUCTOR` | `IV_FI_POSTING_DATE TYPE BUDAT` parameter added; assigned to `mv_fi_posting_date` | 12.01.2026 |
| `VALIDATE_INPUT` | If post mode (`mv_is_disp = abap_false`) and `mv_fi_posting_date IS INITIAL` → `MESSAGE e152(vhurl)` | 12.01.2026 |
| `POST_RECLASSIFICATION` | Posting date logic: `lv_posting_date = mv_fi_posting_date` with `sy-datum` fallback; fiscal year/period via `FI_PERIOD_DETERMINE`; assigned to `ls_doc_header-doc_date` and `ls_doc_header-pstng_date` | 13.01.2026 |

---

## 4. Data Flow

```
Selection Screen
  P_BUDAT (budat)          ← NEW field
      │
      ▼
EVT START-OF-SELECTION
  CREATE OBJECT gr_wastage_util
    iv_fi_posting_date = p_budat   ← NEW
      │
      ▼
ZCL_FI_WASTAGE_RECLASS CONSTRUCTOR
  mv_fi_posting_date = iv_fi_posting_date   ← already done
      │
      ▼
ZCL_FI_WASTAGE_RECLASS→VALIDATE_INPUT
  IF post mode AND mv_fi_posting_date IS INITIAL → error e152   ← already done
      │
      ▼
ZCL_FI_WASTAGE_RECLASS→POST_RECLASSIFICATION
  ls_doc_header-doc_type    = gc_doc_type_gl_pst  ('SX')   ← already done
  ls_doc_header-pstng_date  = mv_fi_posting_date           ← already done
  ls_doc_header-doc_date    = mv_fi_posting_date           ← already done
  BAPI_ACC_DOCUMENT_POST                                    ← unchanged
```

---

## 5. Referenced Function Modules / BAPIs

| FM / BAPI | Purpose | Change? |
|-----------|---------|---------|
| `BAPI_ACC_DOCUMENT_POST` | Posts the parking GL document | None — doc type and posting date now set correctly upstream |
| `BAPI_TRANSACTION_COMMIT` | Commits posted document | None |
| `BAPI_TRANSACTION_ROLLBACK` | Rolls back on error | None |
| `FI_PERIOD_DETERMINE` | Derives fiscal year/period from posting date | None — already called with `mv_fi_posting_date` |
| `READ_TEXT` | Reads SO10 email body template | None |

---

## 6. Authorization Impact

No new authorization objects are introduced. The existing `AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'` in `check_authority` covers the company code. No changes required.

---

## 7. Database Impact

No new tables, views, or data elements are created or modified. `BUDAT` is a standard SAP data element — no DDIC work needed.

---

## 8. Risk and Dependencies

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| SSC change causes syntax error in main program (active source mismatch) | Low | Activate includes and main program together |
| `FI_PERIOD_DETERMINE` fails for custom fiscal year variant | Low | Code already handles `sy-subrc <> 0` with fallback |
| P_BUDAT visible in Extract mode confuses users | Low | Add selection text clearly labelled "Rec doc posting date (Post mode only)" |
| Objects still inactive — activation conflict | Medium | Ensure all objects in DD3K900402 are activated in one batch |

---

## 9. Activation Order

Activate in this sequence to avoid dependency errors:

1. `ZFI_WASTAGE_RECLASS_SSC` (include)
2. `ZFI_WASTAGE_RECLASS_EVT` (include)
3. `ZFI_WASTAGE_RECLASS_TOP` (include — no changes, but currently inactive)
4. `ZFI_WASTAGE_RECLASS` (main program + text elements)

---
