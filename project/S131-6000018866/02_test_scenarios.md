# Stage 2 — Test Scenarios
**Ticket:** S131-6000018866 — 3801-Wastage reclass parking Doc
**Date:** 2026-04-16

---

## Test Execution Prerequisites

- System: DD1 (development) or QA system after transport
- Company code: 3801
- Test user must have `F_BKPF_BUK` authorization for company code 3801
- At least one wastage/refund invoice must exist for the test date range in CDS view `ZCDS_FI_WASTAGE_INVDOC`
- Verify GL 86600099 is present in at least one test invoice

---

## Happy Path Tests

### TC-01 — Extract Mode: Posting Date Not Required

**Objective:** Verify that Extract mode runs without entering a posting date.

**Preconditions:**
- Valid invoices exist for the selected date range

**Input:**
| Field | Value |
|-------|-------|
| Company code (P_BUKRS) | 3801 |
| Invoice date from (P_DATE_F) | First day of previous month |
| Invoice date to (P_DATE_T) | Last day of previous month |
| Processing mode | Extract only (RB_EXTR) |
| Rec doc posting date (P_BUDAT) | **(leave blank)** |
| Recipient users | <your SAP user ID> |

**Expected Result:**
- Program runs without error
- ALV grid displays extracted wastage/refund invoice lines
- No document is posted

**Pass Criteria:** No error message; ALV grid appears with data.

---

### TC-02 — Post Mode: With Valid Posting Date

**Objective:** Verify that Post mode with a valid posting date creates a parked document with doc type SX.

**Preconditions:**
- Valid invoices exist; GL 86600099 present in at least one invoice
- No existing parked document for the same period (to avoid duplicates)

**Input:**
| Field | Value |
|-------|-------|
| Company code (P_BUKRS) | 3801 |
| Invoice date from (P_DATE_F) | First day of previous month |
| Invoice date to (P_DATE_T) | Last day of previous month |
| Processing mode | Post reclassification (RB_POST) |
| Rec doc posting date (P_BUDAT) | Last day of previous month |
| Recipient users | <your SAP user ID> |

**Expected Result:**
- Program runs without error
- Success message: document number and year displayed
- Parked document created in FB03/FBV3 with **document type SX** (not SA)
- Posting date on the document matches the entered P_BUDAT
- Email notification sent to recipient

**Pass Criteria:**
1. Document type = SX in the parked document header
2. Posting date = P_BUDAT value entered
3. Fiscal year/period derived correctly from P_BUDAT via `FI_PERIOD_DETERMINE`

---

### TC-03 — Post Mode: Posting Date Defaults to sy-datum Safety Net

**Objective:** Verify the fallback guard in `post_reclassification` is never reached (validation blocks empty date before this point).

> This scenario tests the validation, not the fallback. The fallback should be unreachable.

**Input:**
| Field | Value |
|-------|-------|
| Processing mode | Post reclassification (RB_POST) |
| Rec doc posting date (P_BUDAT) | **(leave blank)** |

**Expected Result:**
- Error message appears at selection screen validation
- Program does NOT reach `START-OF-SELECTION`
- No document posted

**Pass Criteria:** Error message from `e152(vhurl)` appears; processing stopped before posting.

---

## Edge Case Tests

### TC-04 — Post Mode: Future Posting Date

**Objective:** Verify behavior when posting date is in the future.

**Input:**
| Field | Value |
|-------|-------|
| Processing mode | Post reclassification (RB_POST) |
| Rec doc posting date (P_BUDAT) | A date 1 month in the future |

**Expected Result:**
- The BAPI `BAPI_ACC_DOCUMENT_POST` may reject a future date depending on FI period configuration.
- If rejected: error message from BAPI is displayed; no document posted; rollback executed.
- If accepted: document parked with future posting date.

**Pass Criteria:** Graceful error handling — no dump; BAPI error messages shown to user.

---

### TC-05 — Post Mode: Posting Date in Closed Fiscal Period

**Objective:** Verify behavior when posting date falls in a closed posting period.

**Input:**
| Field | Value |
|-------|-------|
| Processing mode | Post reclassification (RB_POST) |
| Rec doc posting date (P_BUDAT) | A date in a closed period (e.g., 2+ months ago) |

**Expected Result:**
- BAPI returns period-closed error
- Error message displayed to user
- Rollback executed; no document posted

**Pass Criteria:** Error message "Posting period X/YYYY is not open" (or equivalent); no document created.

---

### TC-06 — Authorization Check

**Objective:** Verify that a user without F_BKPF_BUK authorization for 3801 cannot run the program.

**Preconditions:** Test with a user that has no FI posting authorization for company code 3801.

**Expected Result:**
- Error message: "Authorization is missing for company code 3801"
- Processing stopped; no data extracted

**Pass Criteria:** Error message appears immediately after selection screen submission.

---

### TC-07 — No Data Found for Selection Criteria

**Objective:** Verify behavior when no wastage invoices match the selection.

**Input:**
| Field | Value |
|-------|-------|
| Invoice date from / to | A date range with no wastage invoices (e.g., a future month) |

**Expected Result:**
- Error message: "No data found for selection criteria"
- No ALV grid / no document posted

**Pass Criteria:** Error message shown; program ends gracefully.

---

### TC-08 — Invalid User ID in Recipient Field

**Objective:** Verify validation of recipient user IDs.

**Input:**
| Field | Value |
|-------|-------|
| Recipient users (SO_UNAME) | A non-existent user ID (e.g., ZZINVALIDUSER) |

**Expected Result:**
- Error message: "Invalid User ID. Please enter a user ID that exists in the system."
- Processing stopped at selection screen validation

**Pass Criteria:** Validation error at `AT SELECTION-SCREEN ON so_uname`; no extract or posting performed.

---

## Regression Tests

### TC-09 — Document Type Regression (Verify SA is No Longer Used)

**Objective:** Confirm old document type SA is never created by this program.

**Steps:**
1. Run TC-02 (successful post)
2. Open the created document in FBV3
3. Check the document type field

**Pass Criteria:** Document type = **SX**. If SA appears, this is a regression.

---

### TC-10 — Extract Mode Still Works After SSC Change

**Objective:** Confirm that adding P_BUDAT to the selection screen did not break the Extract mode flow.

**Steps:**
1. Run TC-01 (extract mode, blank P_BUDAT)
2. Verify ALV grid appears

**Pass Criteria:** Extract mode unaffected; ALV grid displays correctly.

---

### TC-11 — Posting Date Used (Not sy-datum) in Posted Document

**Objective:** Confirm the program uses the entered posting date, not today's date.

**Input:** Run TC-02 with P_BUDAT = last day of previous month (a date ≠ today).

**Steps:**
1. After posting, open document in FBV3
2. Check Posting Date field

**Pass Criteria:** Posting date = P_BUDAT entered on selection screen, NOT sy-datum (today's date).

---

### TC-12 — Email Notification Still Sent After Posting Date Change

**Objective:** Verify the email notification was not broken by the new posting date changes.

**Steps:**
1. Run TC-02 successfully
2. Check recipient's inbox for the reclassification email

**Pass Criteria:** Email received with correct subject, body, and Excel attachment.

---

## Test Data Notes

- Use company code **3801** (Singapore) as per program default
- Wastage indicators in scope: **02** (full wastage), **04** (full refund) — these are pre-defaulted in INITIALIZATION
- To find test invoices: query `ZCDS_FI_WASTAGE_INVDOC` in SE16N with company code 3801 and a recent date range
- GL 86600099 (DMart commission rev) should appear in the source or target GL of at least one test invoice

---
