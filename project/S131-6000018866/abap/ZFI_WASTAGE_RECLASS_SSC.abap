*-----------------------------------------------------------------------
************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name       : ZFI_WASTAGE_RECLASS_SSC
* Created by         : P024736
* Created on         : 08.01.2026
* Program Description: Selection screen include for wastage reclass
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author      |TR#         |Description
*08.01.2026|P024736     |DD1K9A18XF  |Initial creation
*12.01.2026|P024736     |DD1K9A18XF  |6000018866 : Added posting date field
*-----------------------------------------------------------------------

SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE TEXT-b01.
  PARAMETERS:
    p_bukrs TYPE bukrs DEFAULT '3801' OBLIGATORY.
  SELECT-OPTIONS:
    s_vbeln FOR vbrk-vbeln,
    s_fkdat FOR vbrk-fkdat.
SELECTION-SCREEN END OF BLOCK b01.

SELECTION-SCREEN BEGIN OF BLOCK b02 WITH FRAME TITLE TEXT-b02.
  PARAMETERS:
    rb_extr RADIOBUTTON GROUP proc USER-COMMAND proc DEFAULT 'X',
    rb_post RADIOBUTTON GROUP proc.
*-- Begin of Insert on 12.01.2026 for 6000018866 by P024736
  PARAMETERS:
    p_fidat TYPE budat MODIF ID pst.  "Reclass Posting Date
*-- End of Insert on 12.01.2026 for 6000018866 by P024736
SELECTION-SCREEN END OF BLOCK b02.
