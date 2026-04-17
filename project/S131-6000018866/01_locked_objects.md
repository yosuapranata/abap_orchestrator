# Stage 1 — Locked / Inactive Objects Report
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Date:** 2026-04-16
**Source system:** DD3

---

## Inactive Objects (In-flight Changes by P024736)

All items below are currently **inactive** in DD3 and cannot be locked by another developer without first resolving the in-flight work.

| Object | Type | Locked By | Transport | Status |
|--------|------|-----------|-----------|--------|
| ZFI_WASTAGE_RECLASS | PROG/P | P024736 | DD3K900402 | Inactive — no source change visible |
| ZFI_WASTAGE_RECLASS | PROG/PX (text elements) | P024736 | DD3K900402 | Inactive |
| ZFI_WASTAGE_RECLASS_SSC | PROG/I (include) | P024736 | DD3K900402 | Inactive — **posting date param NOT yet added** |
| ZFI_WASTAGE_RECLASS_EVT | PROG/I (include) | P024736 | DD3K900402 | Inactive — **posting date not passed to constructor** |
| ZFI_WASTAGE_RECLASS_TOP | PROG/I (include) | P024736 | DD3K900402 | Inactive — no change visible in source |
| (unnamed object) | — | — | DD3K900401 | Unresolved — URI missing |
| (unnamed object) | — | — | (no TR) | Unresolved — URI missing |

---

## Objects Already Updated and Active

These objects were modified for this ticket and appear to be **active** (not in the inactive list):

| Object | Type | Package | Changes Applied |
|--------|------|---------|----------------|
| ZCL_FI_WASTAGE_RECLASS | CLAS/OC | ZFI_WASTAGE_RECLASSIFICATION | `gc_doc_type_gl_pst` → 'SX'; `IV_FI_POSTING_DATE` constructor param; `mv_fi_posting_date` member; validation and posting date logic |

---

## Risk Notes

1. **P024736 currently holds the lock on all program includes.** Development work on SSC and EVT must either be done by P024736, or P024736 must release the lock/TR first.

2. **Two unnamed inactive objects** (one on TR DD3K900401, one with no TR) were returned by the system. These could not be identified — developer should verify in SE03 / SE09 what these objects are.

3. **No locks detected on ZCL_FI_WASTAGE_RECLASS** — the class is active. Changes to the class can proceed freely.

---
