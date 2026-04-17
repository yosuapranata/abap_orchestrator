class ZCL_FI_WASTAGE_RECLASS definition
  public
  final
  create public .

public section.

  types:
    BEGIN OF ty_email_rec,
        bname TYPE usr21-bname,
        email TYPE adr6-smtp_addr,
      END OF ty_email_rec .
  types:
    ty_r_invdocno TYPE RANGE OF invdocno_kk .
  types:
    ty_r_wastage  TYPE RANGE OF zde_wastage .
  types:
    ty_r_uname    TYPE RANGE OF usr21-bname .
  types:
    tt_extract    TYPE STANDARD TABLE OF zcds_fi_wastage_invdoc .
  types:
    tt_email_rec  TYPE STANDARD TABLE OF ty_email_rec .

*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
*-- End of Insert on 12.01.2026 for 6000018866 by P024736
  methods CONSTRUCTOR
    importing
      !IV_BUKRS type BUKRS
      !IV_BUDAT_FR type BUDAT
      !IV_BUDAT_TO type BUDAT
      !IRNG_INVNO type TY_R_INVDOCNO
      !IRNG_WASTAGE type TY_R_WASTAGE
      !IRNG_UNAME type TY_R_UNAME
      !IV_IS_DISP type ABAP_BOOL
      !IV_FI_POSTING_DATE type BUDAT .
  methods PROCESS_DATA .
  methods INITIALIZING .
  methods DISPLAY_EXTRACT
    changing
      !CT_EXTRACT type TT_EXTRACT .
  methods GET_MESSAGE_HANDLER
    returning
      value(RO_MESSAGE_HANDLER) type ref to ZCL_MESSAGE_HANDLER .
  methods PREPARE_FETCH_DATA
    returning
      value(RV_CONTINUE) type ABAP_BOOL .
  PROTECTED SECTION.

*-- Begin of Change on 12.01.2026 for 6000018866 by P024736
    CONSTANTS:
      gc_doc_type_gl_pst TYPE blart VALUE 'SX',
*-- End of Change on 12.01.2026 for 6000018866 by P024736
      gc_doc_stat_park   TYPE blart VALUE '2',
      gc_debit_key       TYPE bschl VALUE '40',
      gc_credit_key      TYPE bschl VALUE '50'.

    "Object Data
    DATA:
      mo_message_handler TYPE REF TO zcl_message_handler,
      mt_extract         TYPE tt_extract,
      mt_reclass         TYPE ztt_wastage_reclass_item,
      mt_reclass_gl      TYPE ztt_wastage_reclass_gl_item,
      mt_email_rec       TYPE tt_email_rec,
      mt_email_att       TYPE ztt_wastage_reclass_email,
      mv_belnr           TYPE belnr_d,
      mv_gjahr           TYPE gjahr.

    "Selection Screen Data
    DATA:
      mv_bukrs      TYPE bukrs,
      mv_budat_from TYPE budat,
      mv_budat_to   TYPE budat,
      mrng_invno    TYPE ty_r_invdocno,
      mrng_wastage  TYPE ty_r_wastage,
      mrng_uname    TYPE ty_r_uname,
      mv_is_disp    TYPE abap_bool.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    DATA mv_fi_posting_date TYPE budat.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

    METHODS:
      validate_input,
      check_authority,
      get_user_emails,
      extract_data,
      prepare_reclass_items,
      post_reclassification,
      send_email.

private section.
ENDCLASS.



CLASS ZCL_FI_WASTAGE_RECLASS IMPLEMENTATION.


  METHOD check_authority.
*-----------------------------------------------------------------------
************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Method Name        : CHECK_AUTHORITY
* Created by         : P024736
* Created on         : 10.11.2025
* Method Description :
*  Check user authorization for company code using authorization object F_BKPF_BUK
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*-----------------------------------------------------------------------
************************************************************************

    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD mv_bukrs
      ID 'ACTVT' FIELD '01'.

    IF sy-subrc <> 0.
      "Authorization is missing for company code &1.
      mo_message_handler->add_message(
        iv_msgty = 'E'
        iv_msgid = 'FKK_ML_SRV'
        iv_msgno = '025'
        iv_msgv1 = CONV sy-msgv2( mv_bukrs )
      ).
    ENDIF.

  ENDMETHOD.


  METHOD constructor.
*-----------------------------------------------------------------------
************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Method Name        : CONSTRUCTOR
* Created by         : P024736
* Created on         : 10.11.2025
* Method Description :
*  Initialize class instance with input parameters and create message handler
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*-----------------------------------------------------------------------
************************************************************************
    mv_bukrs     = iv_bukrs.
    mrng_invno   = irng_invno.
    mrng_wastage = irng_wastage.
    mrng_uname   = irng_uname.
    mv_is_disp   = iv_is_disp.
    mv_budat_from = iv_budat_fr.
    mv_budat_to   = iv_budat_to.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    mv_fi_posting_date = iv_fi_posting_date.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

    " Initialize message handler
    mo_message_handler = NEW zcl_message_handler( ).
  ENDMETHOD.


  METHOD display_extract.
*-----------------------------------------------------------------------
************************************************************************
* Method Name        : DISPLAY_EXTRACT
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    DATA: lr_alv     TYPE REF TO cl_salv_table,
          lr_columns TYPE REF TO cl_salv_columns.

    TRY.
        cl_salv_table=>factory(
          IMPORTING
            r_salv_table = lr_alv
          CHANGING
            t_table      = ct_extract ).

      CATCH cx_salv_msg INTO DATA(lx_salv).
        mo_message_handler->add_message_text(
          iv_msgty = 'E'
          iv_text  = lx_salv->get_text( )
        ).
        RETURN.
    ENDTRY.

    lr_columns = lr_alv->get_columns( ).
    lr_columns->set_optimize( abap_true ).
    lr_alv->get_functions( )->set_all( abap_true ).
    lr_alv->display( ).

  ENDMETHOD.


  METHOD extract_data.
*-----------------------------------------------------------------------
* Method Name        : EXTRACT_DATA
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    SELECT *
      FROM zcds_fi_wastage_invdoc(
         p_companycode     = @mv_bukrs,
         p_postingdatefrom = @mv_budat_from,
         p_postingdateto   = @mv_budat_to )
      WHERE invoicedocument   IN @mrng_invno
        AND wastageindicator  IN @mrng_wastage
      INTO TABLE @mt_extract.

    IF sy-subrc = 0.
      SORT mt_extract BY companycode sourceglaccount targetglaccount.

      DATA(lv_count) = lines( mt_extract ).

      mo_message_handler->add_message(
        iv_msgty = 'S'
        iv_msgid = 'RFM_MANAGE_EXC_REQ'
        iv_msgno = '039'
        iv_msgv1 = CONV sy-msgv1( lv_count )
      )..
    ENDIF.

  ENDMETHOD.


  METHOD get_message_handler.
    ro_message_handler = mo_message_handler.
  ENDMETHOD.


  METHOD get_user_emails.
*-----------------------------------------------------------------------
* Method Name        : GET_USER_EMAILS
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    SELECT usr~bname,
           adr~smtp_addr
      FROM usr21 AS usr
      INNER JOIN adr6 AS adr
        ON  adr~addrnumber = usr~addrnumber
        AND adr~persnumber = usr~persnumber
        AND adr~flgdefault = @abap_true
      WHERE usr~bname IN @mrng_uname
      INTO TABLE @mt_email_rec.

    IF mt_email_rec IS INITIAL.
      mo_message_handler->add_message(
        iv_msgty = 'E'
        iv_msgid = 'ESSC_GENERIC'
        iv_msgno = '303'
      ).
    ENDIF.

  ENDMETHOD.


  METHOD initializing.
    CLEAR:
        mt_extract[],
        mt_reclass[],
        mt_reclass_gl[],
        mt_email_att[],
        mt_email_rec[].
  ENDMETHOD.


  METHOD post_reclassification.
*-----------------------------------------------------------------------
* Method Name        : POST_RECLASSIFICATION
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    DATA: ls_doc_header TYPE bapiache09,
          lt_gl_account TYPE STANDARD TABLE OF bapiacgl09,
          lt_currency   TYPE STANDARD TABLE OF bapiaccr09,
          lt_return     TYPE STANDARD TABLE OF bapiret2,
          lv_objkey     TYPE bapiache09-obj_key.

    ls_doc_header-comp_code     = mv_bukrs.
    ls_doc_header-username      = sy-uname.
    ls_doc_header-doc_type      = gc_doc_type_gl_pst. "SX
*-- Begin of Insert on 13.01.2026 for 6000018866 by P024736
    DATA(lv_posting_date) = mv_fi_posting_date.
    IF lv_posting_date IS INITIAL.
      lv_posting_date = sy-datum.  "Fallback guard
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
      lv_fiscal_year   = lv_posting_date(4).
      lv_fiscal_period = lv_posting_date+4(2).
    ENDIF.

    ls_doc_header-doc_date   = lv_posting_date.
    ls_doc_header-pstng_date = lv_posting_date.
    ls_doc_header-fisc_year  = lv_fiscal_year.
    ls_doc_header-fis_period = lv_fiscal_period.
*-- End of Insert on 13.01.2026 for 6000018866 by P024736
    ls_doc_header-doc_status    = gc_doc_stat_park.
    ls_doc_header-header_txt    = 'Full Wastage/Refund Reclassification'(001).
    ls_doc_header-ref_doc_no    = 'Full Wastage/Refund Reclassification'(001).

    LOOP AT mt_reclass_gl INTO DATA(ls_reclass).
      DATA(lv_tabix) = sy-tabix.
      APPEND INITIAL LINE TO lt_gl_account ASSIGNING FIELD-SYMBOL(<lfs_gl_account>).
      APPEND INITIAL LINE TO lt_currency ASSIGNING FIELD-SYMBOL(<lfs_currency>).

      <lfs_gl_account>-itemno_acc = CONV posnr_kk( lv_tabix ).
      <lfs_gl_account>-gl_account = ls_reclass-glaccount.
      <lfs_gl_account>-profit_ctr = ls_reclass-profitcenter.

      <lfs_currency>-itemno_acc = CONV posnr_kk( lv_tabix ).
      <lfs_currency>-currency   = ls_reclass-currency.
      <lfs_currency>-amt_doccur = ls_reclass-totalamount.
    ENDLOOP.

    CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
      EXPORTING
        documentheader = ls_doc_header
      IMPORTING
        obj_key        = lv_objkey
      TABLES
        accountgl      = lt_gl_account
        currencyamount = lt_currency
        return         = lt_return.

    DATA(lv_is_posted) = abap_true.

    LOOP AT lt_return INTO DATA(ls_return_msg) WHERE type = 'E' OR type = 'A' OR type = 'X'.
      mo_message_handler->add_message(
        iv_msgty = ls_return_msg-type
        iv_msgid = ls_return_msg-id
        iv_msgno = ls_return_msg-number
        iv_msgv1 = ls_return_msg-message_v1
        iv_msgv2 = ls_return_msg-message_v2
        iv_msgv3 = ls_return_msg-message_v3
        iv_msgv4 = ls_return_msg-message_v4
      ).
      lv_is_posted = abap_false.
    ENDLOOP.

    IF lv_is_posted IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          wait = abap_true.

      mv_belnr = lv_objkey+0(10).
      mv_gjahr = lv_objkey+14(4).
    ENDIF.

  ENDMETHOD.


  METHOD prepare_fetch_data.
*-----------------------------------------------------------------------
* Method Name        : PREPARE_FETCH_DATA
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    mo_message_handler->clear_messages( ).
    validate_input( ).

    IF mo_message_handler->has_errors( ).
      rv_continue = abap_false.
      RETURN.
    ENDIF.

    check_authority( ).

    IF mo_message_handler->has_errors( ).
      rv_continue = abap_false.
      RETURN.
    ENDIF.

    get_user_emails( ).

    IF mo_message_handler->has_errors( ).
      rv_continue = abap_false.
      RETURN.
    ENDIF.

    extract_data( ).

    IF mt_extract IS INITIAL.
      mo_message_handler->add_message(
        iv_msgty = 'E'
        iv_msgid = 'FINS_REV_REC'
        iv_msgno = '135'
      ).
      rv_continue = abap_false.
      RETURN.
    ENDIF.

    rv_continue = abap_true.

  ENDMETHOD.


  METHOD prepare_reclass_items.
*-----------------------------------------------------------------------
* Method Name        : PREPARE_RECLASS_ITEMS
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    FIELD-SYMBOLS:
      <lfs_reclass>        TYPE zfi_wastage_reclass_item.
    DATA:
      ls_reclass_gl_src TYPE zfi_wastage_reclass_gl_item,
      ls_reclass_gl_tar TYPE zfi_wastage_reclass_gl_item.

    LOOP AT mt_extract INTO DATA(ls_extract).
      CLEAR:
        ls_reclass_gl_src,
        ls_reclass_gl_tar.

      ls_reclass_gl_src-companycode = ls_extract-companycode.
      ls_reclass_gl_src-currency = ls_extract-currency.
      ls_reclass_gl_src-profitcenter = ls_extract-profitcenter.
      ls_reclass_gl_tar = ls_reclass_gl_src.

      ls_reclass_gl_src-glaccount   = ls_extract-sourceglaccount.
      ls_reclass_gl_src-totalamount = ls_extract-amount.

      ls_reclass_gl_tar-glaccount   = ls_extract-targetglaccount.
      ls_reclass_gl_tar-totalamount = ls_extract-amount * -1.

      COLLECT ls_reclass_gl_src INTO mt_reclass_gl.
      COLLECT ls_reclass_gl_tar INTO mt_reclass_gl.

      IF <lfs_reclass> IS NOT ASSIGNED OR
         <lfs_reclass>-companycode <> ls_extract-companycode OR
         <lfs_reclass>-sourceglaccount <> ls_extract-sourceglaccount OR
         <lfs_reclass>-targetglaccount <> ls_extract-targetglaccount.

        APPEND INITIAL LINE TO mt_reclass ASSIGNING <lfs_reclass>.
        CHECK <lfs_reclass> IS ASSIGNED.
        MOVE-CORRESPONDING ls_extract TO <lfs_reclass>.
        <lfs_reclass>-totalamount = ls_extract-amount.
      ELSE.
        <lfs_reclass>-totalamount += ls_extract-amount.
      ENDIF.

      APPEND INITIAL LINE TO mt_email_att ASSIGNING FIELD-SYMBOL(<lfs_email_att>).
      IF sy-subrc = 0.
        MOVE-CORRESPONDING ls_extract TO <lfs_email_att>.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.


  METHOD process_data.
*-----------------------------------------------------------------------
* Method Name        : PROCESS_DATA
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    IF mv_is_disp = abap_false.
      prepare_reclass_items( ).
      post_reclassification( ).

      IF mo_message_handler->has_errors( ).
        RETURN.
      ENDIF.

      send_email( ).

      IF mo_message_handler->has_errors( ).
        RETURN.
      ENDIF.

      mo_message_handler->add_message(
        iv_msgty = 'S'
        iv_msgid = 'RE'
        iv_msgno = '000'
        iv_msgv1 = CONV sy-msgv2( mv_belnr )
      ).
    ELSE.
      display_extract( CHANGING ct_extract = mt_extract ).
    ENDIF.

  ENDMETHOD.


  METHOD send_email.
*-----------------------------------------------------------------------
* Method Name        : SEND_EMAIL
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    DATA: lo_email       TYPE REF TO zcl_email,
          lv_subject     TYPE zsd_s_email_attributes-subject,
          lt_body        TYPE bcsy_text,
          lr_email_att   TYPE REF TO data,
          lt_so10_text   TYPE STANDARD TABLE OF tline,
          ls_body        TYPE soli,
          lv_date_string TYPE string,
          lv_belnr_char  TYPE char10,
          lv_gjahr_char  TYPE char4,
          lv_bukrs_char  TYPE char4.

    TRY.
        lv_date_string = |{ sy-datum+6(2) }-{ sy-datum+4(2) }-{ sy-datum+0(4) }|.

        CONCATENATE 'Full Wastage/Refund Reclassification'(001) lv_date_string
              INTO lv_subject SEPARATED BY space.

        CALL FUNCTION 'READ_TEXT'
          EXPORTING
            id                      = 'ST'
            language                = sy-langu
            name                    = 'ZFI_WASTAGE_RECLASS_EMAIL'
            object                  = 'TEXT'
          TABLES
            lines                   = lt_so10_text
          EXCEPTIONS
            id                      = 1
            language                = 2
            name                    = 3
            not_found               = 4
            object                  = 5
            reference_check         = 6
            wrong_access_to_archive = 7
            OTHERS                  = 8.

        IF sy-subrc <> 0.
          mo_message_handler->add_message(
                  iv_msgty = 'E'
                  iv_msgid = 'M3'
                  iv_msgno = '521'
                  iv_msgv1 = 'ST'
                  iv_msgv2 = 'ZFI_WASTAGE_RECLASS_EMAIL' ).
          RETURN.
        ELSE.
          lv_belnr_char = mv_belnr.
          lv_gjahr_char = mv_gjahr.
          lv_bukrs_char = mv_bukrs.

          LOOP AT lt_so10_text INTO DATA(ls_so10_line).
            ls_body-line = ls_so10_line-tdline.
            REPLACE ALL OCCURRENCES OF '&BELNR&' IN ls_body-line WITH lv_belnr_char.
            REPLACE ALL OCCURRENCES OF '&GJAHR&' IN ls_body-line WITH lv_gjahr_char.
            REPLACE ALL OCCURRENCES OF '&BUKRS&' IN ls_body-line WITH lv_bukrs_char.
            APPEND ls_body TO lt_body.
          ENDLOOP.
        ENDIF.

        lo_email = NEW zcl_email(
          subject    = lv_subject
          email_type = 'RAW'
          t_body     = lt_body
        ).

        LOOP AT mt_email_rec INTO DATA(ls_email).
          IF ls_email-email IS NOT INITIAL.
            lo_email->add_recipient(
              recipient = ls_email-email
              type      = zcl_email=>c_to
            ).
          ENDIF.
        ENDLOOP.

        CREATE DATA lr_email_att LIKE mt_email_att.
        ASSIGN lr_email_att->* TO FIELD-SYMBOL(<lt_email_att>).
        <lt_email_att> = mt_email_att.

        lo_email->add_attachment_excel_format(
          content = lr_email_att
          name    = CONV zsd_s_email_attachments-name( lv_belnr_char )
          xlsx    = abap_true
        ).

        DATA(lv_result) = lo_email->send_email( ).

        IF lv_result = abap_true.
          mo_message_handler->add_message(
              iv_msgty = 'S'
              iv_msgid = 'FKKB_DM'
              iv_msgno = '132'
            ).
        ELSE.
          mo_message_handler->add_message(
              iv_msgty = 'E'
              iv_msgid = 'EHPRC_CPM_WORKLIST'
              iv_msgno = '043'
            ).
        ENDIF.

      CATCH cx_bcs INTO DATA(lx_bcs).
        mo_message_handler->add_message_text(
          iv_msgty = 'E'
          iv_text  = lx_bcs->get_text( )
        ).
      CATCH cx_root INTO DATA(lx_root).
        mo_message_handler->add_message_text(
          iv_msgty = 'E'
          iv_text  = lx_root->get_text( )
        ).
    ENDTRY.
  ENDMETHOD.


  METHOD validate_input.
*-----------------------------------------------------------------------
* Method Name        : VALIDATE_INPUT
* Created by         : P024736
* Created on         : 10.11.2025
*-----------------------------------------------------------------------
    IF mv_bukrs IS INITIAL.
      mo_message_handler->add_message(
        iv_msgty = 'E'
        iv_msgid = '/ACCGO/ACM_COMMON'
        iv_msgno = '211'
      ).
    ENDIF.

    IF mrng_uname IS INITIAL.
      mo_message_handler->add_message(
        iv_msgty = 'E'
        iv_msgid = 'GRAC_WF_REQUEST'
        iv_msgno = '200'
      ).
    ENDIF.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    IF mv_is_disp = abap_false.  "Post mode
      IF mv_fi_posting_date IS INITIAL.
        MESSAGE e152(vhurl).
      ENDIF.
    ENDIF.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

  ENDMETHOD.
ENDCLASS.
