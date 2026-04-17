# Functional Specification — CR-12345

## Change Request Summary

| Field | Value |
|---|---|
| CR Number | CR-12345 |
| Title | Add Rejection Reason to Sales Order Blocking Report |
| Functional Area | SD (Sales & Distribution) |
| Requested by | Regional Finance Team |
| Priority | Medium |
| Target System | DD1 (Production) |

---

## 1. Business Background

The current sales order blocking report (`ZSD_BLOCKED_ORDERS`) shows blocked sales orders but does not display the reason for the block. The finance and sales teams must manually open each order in VA03 to see the rejection reason, which is time-consuming when reviewing large backlogs.

---

## 2. Requirement

Add a new column **"Rejection Reason Text"** to the ALV output of `ZSD_BLOCKED_ORDERS`.

The rejection reason is stored in field `VBAP-ABGRU` (rejection reason code). The corresponding text must be read from table `TVAGT` using the language of the current user (`SY-LANGU`).

---

## 3. Scope

- **In scope**: Add `ABGRU` retrieval and `TVAGT` text lookup to the existing report; display in ALV.
- **Out of scope**: Changes to VA02, blocking logic, or any other programs.

---

## 4. Affected Objects

| Object | Type | System |
|---|---|---|
| `ZSD_BLOCKED_ORDERS` | ABAP Program | DD1 |

---

## 5. Acceptance Criteria

1. The ALV output includes a new column "Rejection Reason" showing the text for each item's rejection code.
2. Items with no rejection reason show a blank in that column (not an error).
3. Report execution time does not increase by more than 10% for a dataset of 10,000 orders.
4. Existing ALV columns and layout are unchanged.

---

## 6. Open Questions

- Should the rejection reason column be always visible, or optional (hidden by default)?
- Is the existing SELECT on `VBAP` fetching `ABGRU` already, or does the field need to be added?
