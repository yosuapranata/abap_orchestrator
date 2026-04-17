# Stage 1 — FS Clarification Questions
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Date:** 2026-04-16
**Reviewed by:** FS Review Agent (Claude)

---

## Q1 — Document Type Change: Conditional or Unconditional?

**Priority: HIGH — Design decision required**

The FS states: *"the JE type should be SX whenever IC GL 86600099 (DMart commission rev) is involved."*

This implies a **conditional** change: SX only when GL 86600099 appears in the posting lines.

However, the current implementation in `ZCL_FI_WASTAGE_RECLASS` has changed `gc_doc_type_gl_pst` **unconditionally** to `'SX'` — all documents posted by this program use SX regardless of which GLs are present.

**Question:** Should the SX doc type apply:
- **(A) Unconditionally** — all reclassification documents from this program are always SX (because all wastage/refund orders are assumed to involve GL 86600099)?
- **(B) Conditionally** — SX only if GL 86600099 appears in `mt_reclass_gl`; otherwise SA?

> _If the answer is (A), the current implementation is correct. If (B), additional logic is needed in `post_reclassification` to inspect the GL lines before setting the doc type._

---

## Q2 — Posting Date Field: Visibility in Extract Mode

The FS states the posting date is mandatory *"when the program is run with post reclassification option"*.

**Question:** In **Extract** mode (`rb_extr` selected), should the posting date field:
- **(A) Still be visible** on the screen but not mandatory (user can optionally enter a date)?
- **(B) Be hidden** using `AT SELECTION-SCREEN OUTPUT` when `rb_extr` is active?
- **(C) Be visible and always mandatory** regardless of mode?

> _The current class validates the date only when `mv_is_disp = abap_false` (post mode), which aligns with interpretation A. Confirming this avoids unnecessary screen-hide logic._

---

## Q3 — Text Symbol for the New Selection Screen Field

The new `P_BUDAT` parameter will appear on the selection screen. 

**Question:** What should the screen label text read?
- The FS suggests: *"Rec doc posting date"*
- Alternative: *"Reclassification Posting Date"*

> _A text symbol (e.g., TEXT-b04 or a parameter selection text) will need to be created. Confirm exact wording before development._

---

## Q4 — Which Screen Block for the Posting Date?

The selection screen currently has three blocks:
- **B01** — Company code + invoice date range + invoice/wastage filters
- **B02** — Processing mode (Extract / Post)
- **B03** — Recipient user IDs

**Question:** Where should the posting date field appear?
- **(A) In block B01** alongside the existing date range fields?
- **(B) In block B02** near the radio buttons (since it is mode-dependent)?
- **(C) In a new block B04**?

> _Recommendation: B02 is semantically appropriate since the field is only relevant in Post mode._

---

## Q5 — Fallback Behaviour When Posting Date Is Empty in Post Mode

The `post_reclassification` method currently has:
```abap
DATA(lv_posting_date) = mv_fi_posting_date.
IF lv_posting_date IS INITIAL.
  lv_posting_date = sy-datum.  "Fallback guard
ENDIF.
```

The `validate_input` method already enforces a mandatory check for post mode. This fallback (`sy-datum`) should theoretically never trigger.

**Question:** Is this fallback intentional as a safety net, or should it be removed since validation already blocks empty dates in post mode?

> _Keeping it is safe; removing it makes the intent clearer. Please confirm preference._

---

## Q6 — TR Assignment

The includes (`ZFI_WASTAGE_RECLASS_SSC`, `ZFI_WASTAGE_RECLASS_EVT`, `ZFI_WASTAGE_RECLASS_TOP`, `ZFI_WASTAGE_RECLASS`) are currently locked by **P024736** on **TR DD3K900402** in **DD3**.

**Question:** Should the remaining changes (SSC + EVT updates) be added to the **existing TR DD3K900402**, or should a new TR be created?

---
