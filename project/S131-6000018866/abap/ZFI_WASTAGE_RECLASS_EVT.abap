*-----------------------------------------------------------------------
************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name       : ZFI_WASTAGE_RECLASS_EVT
* Created by         : P024736
* Created on         : 08.01.2026
* Program Description: Event blocks for wastage reclass program
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author      |TR#         |Description
*08.01.2026|P024736     |DD1K9A18XF  |Initial creation
*12.01.2026|P024736     |DD1K9A18XF  |6000018866 : Screen dynamics for posting date; updated constructor call
*-----------------------------------------------------------------------

INITIALIZATION.
  " Initialization logic (if any)

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

START-OF-SELECTION.

  DATA(lo_reclass) = NEW zcl_fi_wastage_reclass(
    iv_bukrs           = p_bukrs
    iv_is_disp         = rb_extr
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
    iv_fi_posting_date = p_fidat
*-- End of Insert on 12.01.2026 for 6000018866 by P024736
    iv_vbeln           = s_vbeln[]
    iv_fkdat           = s_fkdat[]
  ).

  lo_reclass->check_authority( ).
  lo_reclass->validate_input( ).
  lo_reclass->process_data( ).

  IF rb_post = abap_true.
    lo_reclass->post_reclassification( ).
  ENDIF.
