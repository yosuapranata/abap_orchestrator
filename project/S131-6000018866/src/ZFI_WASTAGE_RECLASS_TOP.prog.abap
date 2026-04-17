************************************************************************
* Confidential and Proprietary
* Copyright Delivery Hero, Germany
* All Rights Reserved
************************************************************************
* Program Name        : ZFI_WASTAGE_RECLASS_TOP
* Created by          : P024736
* Created on          : 10.11.2025
* Program Description :
*  Program ZFI_WASTAGE_RECLASS Top Include
*-----------------------------------------------------------------------
*Modification Log:
*Date      |Author        |TR#       |Description
*10.11.2025|P024736       |DD1K9A1691|Initial Creation
*-----------------------------------------------------------------------
************************************************************************

TABLES:
  dfkkinvdoc_h,
  dfkkinvdoc_i,
  usr21.

DATA:
  gr_wastage_util TYPE REF TO zcl_fi_wastage_reclass ##NEEDED.

CONSTANTS:
  gc_def_cocd        TYPE bukrs VALUE '3801'.
