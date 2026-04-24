*-----------------------------------------------------------------------
* CLASS ZCL_FI_WASTAGE_RECLASS - Changes for CR-6000018866
*-----------------------------------------------------------------------
* This file documents the specific code changes to be applied to
* ZCL_FI_WASTAGE_RECLASS in DD3. Each section shows the location,
* the BEFORE state, and the AFTER state with change markers.
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author      |TR#         |Description
*12.01.2026|P024736     |DD3K900401  |6000018866 : Doc type SA->SX, posting date logic
*-----------------------------------------------------------------------

*======================================================================
* CHANGE 1: Protected Constants Section
* Location: Class Definition -> Protected Section -> Constants
*======================================================================
* BEFORE:
*   CONSTANTS:
*     gc_doc_type_gl_pst TYPE blart VALUE 'SA'.
*
* AFTER:
*-- Begin of Change on 12.01.2026 for 6000018866 by P024736
  CONSTANTS:
    gc_doc_type_gl_pst TYPE blart VALUE 'SX'.
*-- End of Change on 12.01.2026 for 6000018866 by P024736

*======================================================================
* CHANGE 2: New Instance Attribute
* Location: Class Definition -> Protected Section -> Data
*======================================================================
* BEFORE: No mv_fi_posting_date attribute existed.
*
* AFTER (add to DATA section):
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
  DATA mv_fi_posting_date TYPE budat.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

*======================================================================
* CHANGE 3: Constructor Signature
* Location: Class Definition -> Public Section -> Methods -> constructor
*======================================================================
* BEFORE:
*   METHODS constructor
*     IMPORTING
*       iv_bukrs   TYPE bukrs
*       iv_is_disp TYPE abap_bool
*       " ... other parameters ...
*
* AFTER:
  METHODS constructor
    IMPORTING
      iv_bukrs           TYPE bukrs
      iv_is_disp         TYPE abap_bool
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
      iv_fi_posting_date TYPE budat
*-- End of Insert on 12.01.2026 for 6000018866 by P024736
      " ... other parameters ...

*======================================================================
* CHANGE 4: Constructor Implementation Body
* Location: Method constructor -> after mv_is_disp assignment
*======================================================================
* BEFORE:
*   mv_bukrs   = iv_bukrs.
*   mv_is_disp = iv_is_disp.
*
* AFTER:
  METHOD constructor.
    mv_bukrs           = iv_bukrs.
    mv_is_disp         = iv_is_disp.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    mv_fi_posting_date = iv_fi_posting_date.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736
  ENDMETHOD.

*======================================================================
* CHANGE 5: validate_input Method
* Location: Method validate_input -> at end of existing validation logic
*======================================================================
* BEFORE: No posting date validation existed.
*
* AFTER (add at end of validate_input method, before ENDMETHOD):
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    IF mv_is_disp = abap_false.  "Post mode
      IF mv_fi_posting_date IS INITIAL.
        " Standard SAP message: "Enter posting date"
        MESSAGE e152(vhurl).
      ENDIF.
    ENDIF.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

*======================================================================
* CHANGE 6: post_reclassification Method
* Location: Method post_reclassification -> BAPI header construction
*          After ls_doc_header-comp_code assignment
*======================================================================
* BEFORE:
*   ls_doc_header-doc_type   = gc_doc_type_gl_pst.  "Was 'SA'
*   ls_doc_header-comp_code  = mv_bukrs.
*   " doc_date and pstng_date not explicitly set
*   " fisc_year and fis_period not explicitly set
*
* AFTER:
  METHOD post_reclassification.
    " ... existing code ...
    ls_doc_header-doc_type   = gc_doc_type_gl_pst.  "Now 'SX' (changed in constant)
    ls_doc_header-comp_code  = mv_bukrs.

*-- Begin of Insert on 13.01.2026 for 6000018866 by P024736
    DATA(lv_posting_date) = mv_fi_posting_date.
    IF lv_posting_date IS INITIAL.
      lv_posting_date = sy-datum.  "Fallback guard -- should not reach here due to validate_input
    ENDIF.

    DATA: lv_fiscal_year   TYPE gjahr,
          lv_fiscal_period TYPE monat.

    CALL FUNCTION 'FI_PERIOD_DETERMINE'
      EXPORTING
        i_budat = lv_posting_date
        i_bukrs = mv_bukrs
      IMPORTING
        e_gjahr = lv_fiscal_year
        e_poper = lv_fiscal_period
      EXCEPTIONS
        OTHERS  = 1.

    IF sy-subrc <> 0.
      " Fallback: derive from date string for calendar year variants
      lv_fiscal_year   = lv_posting_date(4).      "YYYY portion
      lv_fiscal_period = lv_posting_date+4(2).     "MM portion
    ENDIF.

    ls_doc_header-doc_date   = lv_posting_date.   "BLDAT
    ls_doc_header-pstng_date = lv_posting_date.   "BUDAT
    ls_doc_header-fisc_year  = lv_fiscal_year.    "GJAHR
    ls_doc_header-fis_period = lv_fiscal_period.  "MONAT
*-- End of Insert on 13.01.2026 for 6000018866 by P024736

    " ... remainder of BAPI call ...
  ENDMETHOD.
