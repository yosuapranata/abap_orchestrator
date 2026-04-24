************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name        : ZFI_WASTAGE_RECLASS_EVT
* Created by          : P024736
* Created on          : 10.11.2025
* Program Description :
*  Program ZFI_WASTAGE_RECLASS Event
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*12.01.2026|P024736       |DD3K900401|6000018866: Screen dynamics; posting date to constructor
*-----------------------------------------------------------------------
************************************************************************

INITIALIZATION.
  " Initialize wastage flag range with default values
  so_wstge-sign   = 'I'.
  so_wstge-option = 'EQ'.
  so_wstge-low    = '02'.
  APPEND so_wstge.

  so_wstge-sign   = 'I'.
  so_wstge-option = 'EQ'.
  so_wstge-low    = '04'.
  APPEND so_wstge.

AT SELECTION-SCREEN OUTPUT.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
  LOOP AT SCREEN.
    IF screen-group1 = 'PST'.
      IF rb_post = abap_true.
        screen-active   = '1'.
        screen-required = '1'.
      ELSE.  "rb_extr is selected
        screen-active   = '0'.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

AT SELECTION-SCREEN ON so_uname.
  " Validate that user IDs exist
  IF so_uname IS NOT INITIAL.
    SELECT COUNT(*)
      FROM usr21
      WHERE bname IN @so_uname.

    IF sy-subrc <> 0.
      "Invalid User ID. Please enter a user ID that exists in the system.
      MESSAGE e053(/grcpi/gria_exp_msg).
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.


START-OF-SELECTION.
  " Create utility instance
  CLEAR gr_wastage_util.

  CREATE OBJECT gr_wastage_util
    EXPORTING
      iv_bukrs           = p_bukrs
      iv_budat_fr        = p_date_f
      iv_budat_to        = p_date_t
      irng_invno         = CONV zcl_fi_wastage_reclass=>ty_r_invdocno( so_invno[] )
      irng_wastage       = CONV zcl_fi_wastage_reclass=>ty_r_wastage( so_wstge[] )
      irng_uname         = CONV zcl_fi_wastage_reclass=>ty_r_uname( so_uname[] )
      iv_is_disp         = rb_extr
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
      iv_fi_posting_date = p_fidat.
*-- End of Insert on 12.01.2026 for 6000018866 by P024736

  DATA(lo_message_handler) = gr_wastage_util->get_message_handler( ).
  " Prepare & fetch data
  DATA(lv_is_ok) = gr_wastage_util->prepare_fetch_data( ).

END-OF-SELECTION.
  IF lv_is_ok = abap_true.
    " Process data
    gr_wastage_util->process_data( ).
  ENDIF.
  lo_message_handler->write_messages( ).
