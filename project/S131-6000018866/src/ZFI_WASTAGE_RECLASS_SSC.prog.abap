************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name        : ZFI_WASTAGE_RECLASS_SSC
* Created by          : P024736
* Created on          : 10.11.2025
* Program Description :
*  Program ZFI_WASTAGE_RECLASS Selection Screen
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*16.04.2026|P024736       |DD3K900402|Add posting date param (6000018866)
*-----------------------------------------------------------------------
************************************************************************

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS:
    p_bukrs  TYPE bukrs OBLIGATORY DEFAULT gc_def_cocd,
    p_date_f TYPE dfkkinvdoc_h-budat OBLIGATORY,
    p_date_t TYPE dfkkinvdoc_h-budat OBLIGATORY.

  SELECT-OPTIONS:
    so_invno FOR dfkkinvdoc_h-invdocno,
    so_wstge FOR dfkkinvdoc_i-zz_wastage.

SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc ##NEEDED.
*-- Begin of Insert on 16.04.2026 for 6000018866 by P024736
  PARAMETERS:
    p_budat TYPE budat.
*-- End of Insert on 16.04.2026 for 6000018866 by P024736
SELECTION-SCREEN END OF BLOCK b02.

SELECTION-SCREEN BEGIN OF BLOCK b03 WITH FRAME TITLE TEXT-b03.
  SELECT-OPTIONS:
    so_uname FOR usr21-bname OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b03.
