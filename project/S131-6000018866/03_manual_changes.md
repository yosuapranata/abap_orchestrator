# Stage 3 — Manual Changes Required
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Date:** 2026-04-16
**TR:** DD3K900402
**Author:** P024736

---

## Why Manual

The MCP server (`vibing_steampunk`) cannot write to ABAP includes (object subtype `PROG/I`). The `EditSource`, `WriteSource`, and `ImportFromFile` tools all fail for this subtype. The two remaining code changes must be applied manually in SE38 or ADT.

The **local source files** in `src/` are fully correct and can be used as the reference for copy-paste.

---

## 1. ZFI_WASTAGE_RECLASS_SSC — Add P_BUDAT parameter

**How to open:** SE38 → `ZFI_WASTAGE_RECLASS_SSC` → Change, or ADT → open include directly.

**Step 1 — Update modification log** (in header, after the existing Initial Creation line):
```abap
*16.04.2026|P024736       |DD3K900402|Add posting date param (6000018866)
```

**Step 2 — Add P_BUDAT in Block B02** (after `rb_post` line, before `SELECTION-SCREEN END OF BLOCK b02.`):
```abap
*-- Begin of Insert on 16.04.2026 for 6000018866 by P024736
  PARAMETERS:
    p_budat TYPE budat.
*-- End of Insert on 16.04.2026 for 6000018866 by P024736
```

**Full resulting Block B02:**
```abap
SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc ##NEEDED.
*-- Begin of Insert on 16.04.2026 for 6000018866 by P024736
  PARAMETERS:
    p_budat TYPE budat.
*-- End of Insert on 16.04.2026 for 6000018866 by P024736
SELECTION-SCREEN END OF BLOCK b02.
```

**Save → assign to TR DD3K900402.**

Reference file: `src/ZFI_WASTAGE_RECLASS_SSC.prog.abap`

---

## 2. ZFI_WASTAGE_RECLASS_EVT — Pass posting date to constructor

**How to open:** SE38 → `ZFI_WASTAGE_RECLASS_EVT` → Change, or ADT → open include directly.

**Step 1 — Update modification log** (in header):
```abap
*16.04.2026|P024736       |DD3K900402|Pass posting date to constructor (6000018866)
```

**Step 2 — Modify the CREATE OBJECT call in START-OF-SELECTION:**

Remove the period from `iv_is_disp = rb_extr.` and add the new parameter below it:

```abap
      iv_is_disp   = rb_extr
*-- Begin of Insert on 16.04.2026 for 6000018866 by P024736
      iv_fi_posting_date = p_budat.
*-- End of Insert on 16.04.2026 for 6000018866 by P024736
```

**Full resulting CREATE OBJECT block:**
```abap
  CREATE OBJECT gr_wastage_util
    EXPORTING
      iv_bukrs     = p_bukrs
      iv_budat_fr  = p_date_f
      iv_budat_to  = p_date_t
      irng_invno   = CONV zcl_fi_wastage_reclass=>ty_r_invdocno( so_invno[] )
      irng_wastage = CONV zcl_fi_wastage_reclass=>ty_r_wastage( so_wstge[] )
      irng_uname   = CONV zcl_fi_wastage_reclass=>ty_r_uname( so_uname[] )
      iv_is_disp   = rb_extr
*-- Begin of Insert on 16.04.2026 for 6000018866 by P024736
      iv_fi_posting_date = p_budat.
*-- End of Insert on 16.04.2026 for 6000018866 by P024736
```

**Save → assign to TR DD3K900402.**

Reference file: `src/ZFI_WASTAGE_RECLASS_EVT.prog.abap`

---

## 3. After Manual Changes — Remaining Automated Steps

Once steps 1 and 2 above are saved in SAP, come back and run the following (or let the orchestrator do it):

### 3a. Push main program mod log
The `EditSource` call for `ZFI_WASTAGE_RECLASS` is ready but was blocked by a syntax error (because EVT still had the old constructor call). Once EVT is fixed, this will go through.

### 3b. Activate in order
```
1. ZFI_WASTAGE_RECLASS_SSC
2. ZFI_WASTAGE_RECLASS_EVT
3. ZFI_WASTAGE_RECLASS_TOP  (no changes, but currently inactive)
4. ZFI_WASTAGE_RECLASS       (main program + text elements)
```

### 3c. Text element (manual — SetTextElements requires ZADT_VSP)
In SE38 → `ZFI_WASTAGE_RECLASS` → Goto → Text Elements → Selection Texts:

| Field name | Text |
|------------|------|
| P_BUDAT | Rec doc posting date |

Save and assign to TR DD3K900402.

---

## 4. Post-Deployment Checklist (Manual — Stage 4)

- [ ] ATC check on `ZFI_WASTAGE_RECLASS` and includes
- [ ] SLIN check (extended syntax)
- [ ] Unit test run per `02_test_scenarios.md`
- [ ] TC-01: Post mode with valid P_BUDAT — confirm doc type SX, correct posting date
- [ ] TC-04: Post mode with blank P_BUDAT — confirm error message e152(vhurl)
- [ ] TC-09: Extract mode with blank P_BUDAT — confirm no error raised
- [ ] TR release: DD3K900402 → transport to DQ1/DP1 per normal release process
